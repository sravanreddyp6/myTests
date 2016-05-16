/*
 * Controller for multi attachment component
 */

global with sharing class uploaderController
{
	/**
	 * This proxy class is used to add the Head Shot choosing ability, because
	 * we can't actually add custom fields to Attachment.
	 */
	private class ProxyAttachment {
		private Attachment attachment;
		public ID Id { get { return attachment.ID; } set { attachment.ID = value; } }
		public ID ParentId { get { return attachment.ParentId; } set { attachment.ParentId = value; } }
		public String Name { get { return attachment.Name; } set { attachment.Name = value; } }
		public Blob Body { get { return attachment.Body; } set { attachment.Body = value; } }
		public String Description { get { return attachment.Description; } set { attachment.Description = value; } }
		public Boolean isHeadShot { get; set; }
		public Boolean isPlanOfCare { get; set; }
		public Boolean isISP { get; set; }
		public ProxyAttachment(Attachment attachment) {
			this.attachment = attachment;
			isHeadShot = false;
			isPlanOfCare = false;
			isISP = false;
		}
		public Attachment getSObject() {
			return attachment;
		}
	}

	public Boolean showPersonalRecord{ get; set; }
	private ID whoforTask; // the PBS on the action plan ISP attachment 

	// the parent object
	public Id sobjId {get; set{
		sobjId = value;
		String sObjectName = sobjId.getSObjectType().getDescribe().getLocalName();
		// initialize all selectors to false
		showHeadShotSelection = false;
		showPersonalRecord = false;
		showPlanOfCareSelection = false;
		showISPSelection = false;
		
		if (sObjectName=='Contact') {
			showHeadShotSelection = true;
			showPersonalRecord = true;
		} else if(sObjectName=='Referral__c') {
			Referral__c ref = [ SELECT Id, RecordType.Name FROM Referral__c WHERE ID=:sObjId];
			if (ref.RecordType.Name == 'NeuroRestorative') {
				showPlanOfCareSelection = true;
			}
		} else if (sObjectName == 'Action_Plan__c') {
			Action_Plan__c ap = [ select id, service_assignment__r.flavor__c, service_assignment__r.service_location__r.state__c, service_assignment__r.service_location__r.network_offering__c, service_assignment__r.admission__r.person_being_served__c  from action_plan__c where id = :sObjId];
			if ( ap.service_assignment__r.service_location__r.state__c == 'OH' &&
				 ap.service_assignment__r.service_location__r.network_offering__c == 'IDD' ) { 
				showISPSelection = true;
				whoforTask = ap.service_assignment__r.admission__r.person_being_served__c;
				 } 
		} 
		//System.debug('fileUpload :::' + fileUpload);
		if ( fileUpload != null  && fileUpload.equals('true')){
			showHeadShotSelection = false;
		}
	}}
	public String fileUpload { get; set; }
	public Boolean showHeadShotSelection { get; set; }
	public Boolean showPlanOfCareSelection { get; set; }
	public Boolean showISPSelection { get; set; }
	public String headShotPhotoIndex { get; set; }
	public Boolean hideAddMoreButton { get; set; }
	public String loginUserId { 
    get {
        return UserInfo.getUserId();
    }}
	// list of existing attachments - populated on demand
	public List<Attachment> attachments;

	// list of new attachments to add
	public List<ProxyAttachment> newAttachments {get; set;}

	// the number of new attachments to add to the list when the user clicks 'Add More'
	public static final Integer NUM_ATTACHMENTS_TO_ADD=5;

	public uploaderController()
	{
		// instantiate the list with a single attachment
		newAttachments=new List<ProxyAttachment>{new ProxyAttachment(new Attachment())};
		
		whoforTask = null;
		
	}

	// retrieve the existing attachments
	public List<AttachmentView> getAttachments()
	{    List<AttachmentView> attchmentList = new List<AttachmentView>();
		attachments=[select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID from Attachment where parentId=:sobjId order by createddate desc limit 10];
			for(Attachment att : attachments){
			attchmentList.add( new AttachmentView(att));
			}
		return attchmentList;
	}

	// Add more attachments action method
	public PageReference addMore()
	{
		// Clear out the current newAttachments first, otherwise we'll run into
		// View State maximum limit
		newAttachments.clear();
		// append NUM_ATTACHMENTS_TO_ADD to the new attachments list
		for (Integer idx=0; idx<NUM_ATTACHMENTS_TO_ADD; idx++)
		{
			newAttachments.add(new ProxyAttachment(new Attachment()));
		}
		hideAddMoreButton = true;
		return null;
	}

	// Save action method
	public PageReference save()
	{
		//System.debug('Save called!');
		List<Attachment> toInsert=new List<Attachment>();
		Integer index = 0;
		Integer ispIndex = -1;
		Boolean headShotFound = false; // only use 1 photo as the headshot
		Boolean planOfCareFound = false;
		Boolean ispFound = false;
		
		for (ProxyAttachment newProxyAtt : newAttachments)
		{
			Attachment newAtt = newProxyAtt.getSObject();
			if (newAtt.Body!=null)
			{
				//System.debug('Body not null');
				if (newProxyAtt.isHeadShot && !headShotFound) {
					//System.debug('This is the headshot');
					newAtt = manageHeadShotName(newAtt);
					headShotFound = true;
				}
				if (newProxyAtt.isPlanOfCare && !planOfCareFound) {
					newAtt = managePlanOfCareName(newAtt);
					planOfCareFound = true;
				}
				if (newProxyAtt.isISP && !ispFound) {
					newAtt = manageISPName(newAtt);
					ispFound = true;
					ispIndex = index;
				}
				newAtt.parentId=sobjId;
				toInsert.add(newAtt);
			}
			index++;
		}
		
		// need results of call to trigger acknowledgment for ISP
		Database.SaveResult[] res = Database.Insert( toInsert, false);
		
		// result array matches original array - find the ISP
		if ( ispIndex > -1 && res[ispIndex].isSuccess() )
			SetAcknowledgmentTasks(res[ispIndex].getId(), sobjId);  

		newAttachments.clear();
		newAttachments.add(new ProxyAttachment(new Attachment()));
		hideAddMoreButton = false;
		// null the list of existing attachments - this will be rebuilt when the page is refreshed
		attachments=null;
		return null;
	}

	public PageReference chooseHeadshot() {
		String attachmentId = Apexpages.currentPage().getParameters().get('aId');
		String attachmentName = Apexpages.currentPage().getParameters().get('aName');
		Attachment a = new Attachment(id=attachmentId, Name=attachmentName);
		a = manageHeadShotName(a);
		upsert a;
		return null;
	}

	public Attachment manageHeadShotName(Attachment a) {
		for (Attachment current: attachments) {
			if (current.Name.indexOf('HeadShot-Current')!=-1) {
				current.Name = 'HeadShot-' + Date.today().format() + findExtension(current.Name);
			}
		}
		upsert attachments;
		a.Name = 'HeadShot-Current' + findExtension(a.Name);
		return a;
	}

	public Attachment managePlanOfCareName(Attachment a) {
		a.Name = 'PlanOfCare-' + Datetime.now().format('MM-dd-yyyy hh:mm:ss a z') + findExtension(a.Name);
		return a;
	}

	public Attachment manageISPName(Attachment a) {
		a.Name = 'ISP-' + Datetime.now().format('MM-dd-yyyy hh:mm:ss a z') + findExtension(a.Name);
		return a;
	}

	private String findExtension(String fileName) {
		List<String> nameParts = fileName.split('\\.');
		if (nameParts.size()<=1) {
			return '';
		}
		return '.' + nameParts[nameParts.size()-1];
	}
	
	// OH-11 
	private void setAcknowledgmentTasks ( ID attachID, ID pId) {
		// for anyone who has acknowledged this action plan's last ISP, set task to re-ack
		Map<Id, Attachment> oldISPs = new Map<ID, Attachment>([ select id from Attachment where parentid = :pId and name like 'ISP%']);
		
		if ( oldISPs.size() == 0 ) 
			return;
		
		Set<ID> userids = new Set<ID>();
		
		// don't want duplicate tasks, so group by user__c - same as distinct
		for( Acknowledgment__c a : [Select user__c from Acknowledgment__c where attachment__c in :oldISPs.keyset() and user__r.isactive = true ]){
			userids.add( a.user__c);
		}
		
		List<Task> newtasks = new List<Task>();
		
		for ( User u : [ select id from User where id in :userids ]) {
            task tmpTask = new task();

            tmpTask.whatid= pID;
            tmptask.OwnerId = u.id;
            tmpTask.Subject = 'ISP Acknowledgment';
            tmpTask.Description = 'Please acknowledge that you have read the new version of the ISP (attached to Action Plan)';
            tmpTask.whoID = whoforTask ;
            newtasks.add(tmpTask);
        }
        insert newtasks;
        
	}

	// Action method when the user is done
	public PageReference done()
	{
		// send the user to the detail page for the sobject
		return new PageReference('/' + sobjId);
	}


		
	    class AttachmentView implements Comparable {
        public Attachment attachment { get; set; }
        public String Name { get {
            return this.attachment.Name;
        }}
        public String OwnerName { get {
            return this.attachment.Owner.Name;
        }}
        public String OwnerId { get {
            return this.attachment.OwnerId;
        }}
        public ID ID { get {
            return attachment.Id;
        }}
        public String LastModifiedDate { get {
            return attachment.LastModifiedDate.format('MM/dd/yyyy hh:mm a');
        }}
       public String CreatedDate { get {
            return attachment.CreatedDate.format('MM/dd/yyyy hh:mm a');
        }}
        public String Description { get {
            return attachment.Description;
        }}
        public AttachmentView(Attachment attachment) {
            this.attachment = attachment;
        }
        public Integer compareTo(Object objToCompare) {
            AttachmentView obj = (AttachmentView) objToCompare;
            if (this.CreatedDate == obj.CreatedDate) return 0;
            if (this.CreatedDate > obj.CreatedDate) return -1;
            return 1;
        }
    }
	
	
	
	
}