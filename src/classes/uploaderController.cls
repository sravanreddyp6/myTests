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
		public String isHeadShot { get; set; }
		public String isPlanOfCare { get; set; }
		public ProxyAttachment(Attachment attachment) {
			this.attachment = attachment;
			isHeadShot = 'false';
			isPlanOfCare = 'false';
		}
		public Attachment getSObject() {
			return attachment;
		}
	}

	public Boolean showPersonalRecord{ get; set; }


	// the parent object it
	public Id sobjId {get; set{
		sobjId = value;
		String sObjectName = sobjId.getSObjectType().getDescribe().getLocalName();
		if (sObjectName=='Contact') {
			showHeadShotSelection = true;
			showPersonalRecord = true;
			showPlanOfCareSelection = false;
		} else if(sObjectName=='Referral__c') {
			showHeadShotSelection = false;
			showPersonalRecord = false;
			Referral__c ref = [ SELECT Id, RecordType.Name FROM Referral__c WHERE ID=:sObjId];
			if (ref.RecordType.Name == 'NeuroRestorative') {
				showPlanOfCareSelection = true;
			} else {
				showPlanOfCareSelection = false;
			}
		} else {
			showHeadShotSelection = false;
			showPersonalRecord = false;
			showPlanOfCareSelection = false;
		}
		System.debug('fileUpload :::' + fileUpload);
		if ( fileUpload != null  && fileUpload.equals('true')){
		showHeadShotSelection = false;
		}
	}}
	public String fileUpload { get; set; }
	public Boolean showHeadShotSelection { get; set; }
	public Boolean showPlanOfCareSelection { get; set; }
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
		System.debug('Save called!');
		List<Attachment> toInsert=new List<Attachment>();
		Integer index = 0;
		Boolean headShotFound = false; // only use 1 photo as the headshot
		Boolean planOfCareFound = false;
		for (ProxyAttachment newProxyAtt : newAttachments)
		{
			Attachment newAtt = newProxyAtt.getSObject();
			if (newAtt.Body!=null)
			{
				System.debug('Body not null');
				if (newProxyAtt.isHeadShot=='true' && !headShotFound) {
					System.debug('This is the headshot');
					newAtt = manageHeadShotName(newAtt);
					headShotFound = true;
				}
				if (newProxyAtt.isPlanOfCare=='true' && !planOfCareFound) {
					newAtt = managePlanOfCareName(newAtt);
					planOfCareFound = true;
				}
				newAtt.parentId=sobjId;
				toInsert.add(newAtt);
			}
			index ++;
		}
		insert toInsert;
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

	private String findExtension(String fileName) {
		List<String> nameParts = fileName.split('\\.');
		if (nameParts.size()<=1) {
			return '';
		}
		return '.' + nameParts[nameParts.size()-1];
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