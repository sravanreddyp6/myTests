public class identityEditNew {

    Date currentDate = Date.today(); 
    Date defaultLastDay = currentDate.addDays(90);
    public TMN_User__c TMNUser { get;  set; }
    User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    String userId = u.id;
    TMN_User__c myTMN = [SELECT Id, Name, Operating_Group__c, Manager_Name__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:userId LIMIT 1];   
    public String myManager {
        get{return (myTMN.Manager_Name__c);}
        set{myTMN.Manager_Name__c = value;}
    }   
    public String myOpGroup {
        get{return (myTMN.Operating_Group__c);}
        set{myTMN.Operating_Group__c = value;}
    }
    public List<ProxyAttachment> newAttachments { get ; set; }
    public String FN = System.currentPageReference().getParameters().get('FN');
    public String LN = System.currentPageReference().getParameters().get('LN');
    public String retURL = ApexPages.currentPage().getParameters().get('retURL');
    public String TAU = ApexPages.currentPage().getParameters().get('TAU'); 
    public String attchmentId {set;get;}
    public String aliasName = TAU;
    
  private static final String EMAIL_PATTERN = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
  public static boolean validate(String email) {
    return Pattern.matches(EMAIL_PATTERN, email);
  }
    public String getGlCodesForTherapist(){
    	map<String, String> keyVal = new map<String, String>();
    	keyVal.put('Physical Therapy','542009');
    	keyVal.put('PT-Massage','542009');
		keyVal.put('Occupational Therapy','542010');
		keyVal.put('Speech Therapy','542011');
		keyVal.put('Social Services','542003');
		keyVal.put('Respiratory','542003');
		keyVal.put('Dietitian','542003');
    	return JSON.Serialize(keyVal); 
    }
    
    public identityEditNew() {
                                    
        Id id = ApexPages.currentPage().getParameters().get('ID');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
//        Alias__c auAlias = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name 
//            FROM Alias__c 
//            WHERE Alias_unique__c =: aliasUser.Alias__c];
        
        TMNUser = (id == null) ? new TMN_User__c() : 
            [SELECT Accountable_Approval_Manager__c,Accountable_Manager_Mentor_Email__c,Alias__c,Approval_Level__c,
            Business_Unit_Region__c,Business_Unit__c,Current_Person_Type__c,Email__c,Employee_Number__c,Alias_Lookup__c,
            Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Level__c,Job_Status__c,Job_Title__c,Identity_ID__c, 
            Last_Day__c,Last_Name__c,Manager_Email__c,Manager_First_Name__c,Manager_Last_Name__c,Manager_Name__c,
            Mentor_Cell_Phone__c,Middle_Name__c,Name,Network_Username__c,Office_Location__c,Office_Phone__c,Teleo_ID__c,
            Operating_Group__c,Pay_Basis__c,Personal_Email__c,Personal_Phone__c,Salesforce_User_Account__c,
            Service_Line__c,Service_Region__c,Suppress_External_Update__c,Termination_Date__c,Program_String__c,
            Unique_Id__c,Work_State_Code__c,Work_State__c,Preferred_First_Name__c,Preferred_Last_Name__c,Manager_Lookup__c,
            Work_City__c,Zip_Code__c,Professional_Title__c,Location_Name__c,Office_Location_2__c,Work_County__c, Office_Location_PickList__c, BAA_Signed__c,Vendor_list__c,Vendor_Name__c,phone_ext__c,Office_Flag__c,
            Account_Number__c, CPR_Expires__c, Discipline__c, GL_Code__c, IC_Agreement_Executed_Date__c, Insurance_Expires__c, License_Expires__c, Notes__c, Personal_City__c,
            Personal_Location__c, Personal_Zip__c, Rate__c,Custodians__c 
            FROM TMN_User__c 
            WHERE Id = :id];
         newAttachments = new List<ProxyAttachment>();
        if(TMNUser.id!=null) {
                attachments=[select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID from Attachment where parentId=:TMNUser.id order by createddate ];
             for(integer i = attachments.size(); i<3;i++){
                        newAttachments.add(new  ProxyAttachment(new Attachment())); 
            }           
        }else {
        newAttachments.add(new  ProxyAttachment(new Attachment())); 
        newAttachments.add(new ProxyAttachment(new Attachment()));
        newAttachments.add(new ProxyAttachment(new Attachment()));
        }
 
    
    
    if(TMNUser.Id == null){
        TMNUser.First_Name__c = FN;
        TMNUser.Last_Name__c = LN;
        TMNUser.Preferred_First_Name__c = FN;
        TMNUser.Preferred_Last_Name__c = LN;
        TMNUser.Manager_Lookup__c = aliasUser.Id;
        TMNUser.Work_State__c = aliasUser.Work_State__c;
        TMNUser.Alias__c = auAlias.Alias_unique__c;
        TMNUser.Alias_Lookup__c = auAlias.Id;
        TMNUser.Manager_Name__c = aliasUser.Name;
        TMNUser.Manager_Email__c = aliasUser.Email__c;
        TMNUser.Operating_Group__c = aliasUser.Operating_Group__c;
        TMNUser.Office_Location__c = aliasUser.Office_Location__c;
        TMNUser.Business_Unit__c = auAlias.Alias_Business_Unit__c;
        TMNUser.Program_String__c = auAlias.Alias_Description__c;
        TMNUser.Current_Person_Type__c = 'Non-Employee';
        TMNUser.Work_City__c = aliasUser.Work_City__c;
        TMNUser.Office_Location_PickList__c = aliasUser.Office_Location_PickList__c;
        TMNUser.Service_Region__c = auAlias.Alias_Region__c;
        TMNUser.Service_Line__c = auAlias.Alias_Service_Line__c;
        TMNUser.Zip_Code__c = aliasUser.Zip_Code__c;
        TMNUser.BAA_Signed__c = aliasUser.BAA_Signed__c;
        TMNUser.Location_Name__c = aliasUser.Location_Name__c;
        TMNUser.Last_Day__c = defaultLastDay;
    }
 }
 
 	public List<TMN_User__c> tmnManagerList {set;get;}
 	public String managerFirstName  {set;get;}
 	public String managerLastName  {set;get;}
 			public PageReference getManagerList() {
 				list<AggregateResult> userAggregateResult;
 					if(managerFirstName!=null && managerFirstName.length() > 0 && (managerLastName ==null || managerLastName.length() ==0)){
 				 userAggregateResult = [select Manager_Email__c from TMN_User__c where Manager_First_Name__c like : '%'+managerFirstName +'%' and manager_email__c <> '' group by Manager_Email__c limit 100];
 					} else 	if(managerFirstName==null || managerFirstName.length() == 0 && (managerLastName !=null && managerLastName.length() >0)){
 						userAggregateResult = [select Manager_Email__c from TMN_User__c where Manager_Last_Name__c like : '%'+managerLastName +'%' and Manager_Email__c <> '' group by Manager_Email__c limit 500];
 					} else {
 					userAggregateResult = [select Manager_Email__c from TMN_User__c where Manager_First_Name__c like : '%'+managerFirstName +'%' and Manager_Last_Name__c like : '%'+managerLastName +'%' and manager_email__c <> '' group by Manager_Email__c limit 100];
 					}
					 tmnManagerList = new List<TMN_User__c>();
					 Set<String> managerIds = new Set<String>();
					for(AggregateResult tmn:userAggregateResult) {
						List<TMN_User__c> tmnManager = [select id,Name,Email__c,Employee_Number__c,Employee_Type__c,Job_Title__c,Manager_Email__c,Work_State__c,Operating_Group__c from TMN_User__c where Email__c =:string.valueof(tmn.get('Manager_Email__c'))   limit 1];
							if(tmnManager!=null && tmnManager.size()>0 && !managerIds.Contains(tmnManager[0].id)){
								managerIds.add(tmnManager[0].id);
								tmnManagerList.addAll(tmnManager);
							}
					} 				
 			return null;
 			}
 
 
 
     @RemoteAction
    public static TMN_User__c LocationDetails(String location) {
       return   [select location_name__c, office_location__c, office_location_2__c, work_city__c , work_state__c, office_flag__c, zip_code__c,Manager_Name__c from tmn_user__c where current_person_type__c = 'Employee' and location_name__c <> '' and location_name__c like : '%'+location +'%' limit 1];
    }
    
    public  Attachment attDeatils {set;get;}
 
    public  PageReference attachmentDeatils() {
       attDeatils =   [select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID,CreatedBy.name,LastModifiedBy.name from Attachment where id=:attchmentId order by createddate limit 1];
      return null;
    }

    public  PageReference deleteattachment() {
            try {
                delete attDeatils;
                  attachments=[select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID from Attachment where parentId=:TMNUser.id order by createddate ];
               newAttachments = new List<ProxyAttachment>();
                  for(integer i = attachments.size(); i<3;i++){
                        newAttachments.add(new  ProxyAttachment(new Attachment())); 
            } 
        } catch(System.DMLException e) {
            return null;
        }
        return  null; 
    }

        public PageReference updateAttachment () {
                update attDeatils;
                attachments=[select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID from Attachment where parentId=:TMNUser.id order by createddate ];
                    return null;
        }
    
    TMN_User__c t = [SELECT Id, Name, Operating_Group__c,Manager_Name__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:userId LIMIT 1];
    public String tmnName = t.Name;
    public String tmnId = t.Id;
    public String tmnOG = t.Operating_Group__c;
    
   @testVisible TMN_User__c aliasUser = [SELECT Accountable_Approval_Manager__c,Accountable_Manager_Mentor_Email__c,Alias__c,Approval_Level__c,
            Business_Unit_Region__c,Business_Unit__c,Current_Person_Type__c,Email__c,Employee_Number__c,Alias_Lookup__c,
            Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Level__c,Job_Status__c,Job_Title__c,
            Last_Day__c,Last_Name__c,Manager_Email__c,Manager_First_Name__c,Manager_Last_Name__c,Manager_Name__c,
            Mentor_Cell_Phone__c,Middle_Name__c,Name,Network_Username__c,Office_Location__c,Office_Phone__c,
            Operating_Group__c,Pay_Basis__c,Personal_Email__c,Personal_Phone__c,Salesforce_User_Account__c,
            Service_Line__c,Service_Region__c,Suppress_External_Update__c,Termination_Date__c,Manager_Lookup__c,Program_String__c,
            Unique_Id__c,Work_State_Code__c,Work_State__c,Work_City__c,Zip_Code__c,Work_County__c, Office_Location_PickList__c, BAA_Signed__c,Location_Name__c,phone_ext__c,Custodians__c,Pre_Hire_ID__c,Job_Code__c,Recruiter_Name__c,Recruiter_Email_Address__c  
            FROM TMN_User__c 
            WHERE Email__c = :aliasName];
            
 @testVisible   Alias__c auAlias = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name 
                        FROM Alias__c 
                        WHERE Alias_unique__c =: aliasUser.Alias__c];        
     
    public PageReference save() {
		Boolean error = false;
    	 List<TMN_User__c> location =  [select location_name__c, office_location__c, office_location_2__c, work_city__c , work_state__c, office_location_picklist__c, zip_code__c,Manager_Name__c from tmn_user__c where location_name__c  =:TMNUser.Location_Name__c limit 1];
       	if(location.size() == 0){
       	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Search and select valid Location Name in order to save this record.'));
    	 	error = true;
       	}
		
		if(TMNUser.Hire_Date__c!=null && TMNUser.Last_Day__c!=null && TMNUser.Hire_Date__c.daysBetween(TMNUser.Last_Day__c)>90){
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'End Date can\'t be more than 90 days from Start Date.'));
    	 	error = true;
		}
		if(TMNUser.Hire_Date__c ==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date is required to save this record'));
    	 	error = true;
        }
        if(TMNUser.Vendor_list__c ==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Vendor information is required to save this record'));
    	 	error = true;
        }
		
		if(TMNUser.Personal_Email__c !=null && TMNUser.Personal_Email__c.length()>0 ){
    	 	if(!validate(TMNUser.Personal_Email__c)) {
    	 	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Personal Email: Enter a valid email address'));
                error = true;
    	 	}
        }
        
		
		if(error){
		return null;
		}
	
        ID managerId = TMNUser.Manager_Lookup__c;
        String managerEmail = TMNUser.Manager_Email__c;
        ID aliasId = TMNUser.Alias_Lookup__c;
        TMN_User__c managerInfo ;
        List<TMN_User__c> managerInfoList = [SELECT Id,Email__c,Name FROM TMN_User__c WHERE Id = :managerId LIMIT 1];
        		if(managerInfoList!=null&& managerInfoList.size()>0){
        				managerInfo = managerInfoList[0];
        		}else {
        		managerInfoList = [SELECT Id,Email__c,Name FROM TMN_User__c WHERE Manager_Email__c = :managerEmail LIMIT 1];
        				if(managerInfoList!=null&& managerInfoList.size()>0){
        				managerInfo = managerInfoList[0];
        			}		
        		}
        
        Alias__c aliasInfo = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name FROM Alias__c WHERE Id = :aliasID LIMIT 1];
        TMNUser.Manager_Email__c = managerInfo.Email__c;
        TMNUser.Manager_Name__c = managerInfo.Name;
        TMNUser.Alias__c = aliasInfo.Alias_unique__c;
        TMNUser.Alias_Lookup__c = aliasInfo.Id;
        TMNUser.Business_Unit__c = aliasInfo.Alias_Business_Unit__c;
        TMNUser.Service_Region__c = aliasInfo.Alias_Region__c;
        TMNUser.Service_Line__c = aliasInfo.Alias_Service_Line__c;
        TMNUser.Program_String__c = aliasInfo.Alias_Description__c;
        if(TMNUser.Preferred_First_Name__c == null && TMNUser.Preferred_Last_Name__c == null){
            TMNUser.Name = TMNUser.First_Name__c + ' ' + TMNUser.Last_Name__c;    
        }else if(TMNUser.Preferred_First_Name__c != null && TMNUser.Preferred_Last_Name__c == null){
            TMNUser.Name = TMNUser.Preferred_First_Name__c + ' ' + TMNUser.Last_Name__c;
        }else if(TMNUser.Preferred_First_Name__c == null && TMNUser.Preferred_Last_Name__c != null){
            TMNUser.Name = TMNUser.First_Name__c + ' ' + TMNUser.Preferred_Last_Name__c;
        }else if(TMNUser.Preferred_First_Name__c != null && TMNUser.Preferred_Last_Name__c != null){
            TMNUser.Name = TMNUser.Preferred_First_Name__c + ' ' + TMNUser.Preferred_Last_Name__c;
        }
             
        try {
            
            upsert(TMNUser);
             saveAttachment();
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        Id id = TMNUser.Id;
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        String TAU = ApexPages.currentPage().getParameters().get('TAU');
        PageReference viewPage = new PageReference('/apex/identity_view?id=' + id + '&retURL=' + retURL + '&TAU=' + TAU);
        viewPage.setRedirect(true);
        return viewPage;
    }
    
    public List<Attachment> attachments {set;get;}

    public void saveAttachment()       {
                List<Attachment> toInsert=new List<Attachment>();
                Integer index = 0;
                for (ProxyAttachment newProxyAtt : newAttachments)
                {
                        Attachment newAtt = newProxyAtt.getSObject();
                        if (newAtt.Body!=null)
                        {
                                newAtt.parentId=TMNUser.id;
                                toInsert.add(newAtt);
                        }
                        index ++;
                }
                try {
                insert toInsert;
                toInsert = new List<Attachment>();
                newAttachments = new List<ProxyAttachment>();
                }catch (Exception e ) {
                newAttachments = new List<ProxyAttachment>();
                }
        }
    
    
    
    public pageReference updateAliasInfo(){
        Alias__c a = [SELECT Alias_Operating_Group__c,Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name 
                      FROM Alias__c 
                      WHERE Id = :TMNUser.Alias_Lookup__c];
        TMNUser.Alias__c = a.Alias_unique__c;              
        TMNUser.Business_Unit__c = a.Alias_Business_Unit__c;
        TMNUser.Service_Region__c = a.Alias_Region__c;
        TMNUser.Service_Line__c = a.Alias_Service_Line__c;
        TMNUser.Program_String__c = a.Alias_Description__c;
        TMNUser.Operating_Group__c = a.Alias_Operating_Group__c;
        return null;              
    }
    
    public static void setJobStatus(TMN_User__c[] jobstatus){
        for (TMN_User__c t :jobstatus){                
            if(t.Hire_Date__c > Date.today() && t.Current_Person_Type__c == 'Non-Employee'){
                t.Job_Status__c = 'Pending';
            }else if(t.Hire_Date__c <= Date.today() && t.Last_Day__c >= Date.today() && t.Current_Person_Type__c == 'Non-Employee'){
                t.Job_Status__c = 'Active';
            }else if(t.Last_Day__c < Date.today() && t.Current_Person_Type__c == 'Non-Employee'){
                t.Job_Status__c = 'Inactive';
            }            
        }
    }
    
    public PageReference goEdit(){
        Id id = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        String TAU = ApexPages.currentPage().getParameters().get('TAU');
        PageReference editPage = new PageReference('/apex/identity_edittmnu?id=' + id + '&retURL=' + retURL + '&TAU=' + TAU);
        editPage.setRedirect(true);
        return editPage;
    }
    
    public PageReference goCancel() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        	retURL = retURL+'?cancel=true';
        PageReference cancelPage = new PageReference(retURL);
        cancelPage.setRedirect(true);   
        return cancelPage;
    }

    public PageReference goBack() {
        if(retURL == null){
			PageReference backPage = new PageReference('/apex/identity_nonemployees?cancel=true');
            backPage.setRedirect(true);   
            return backPage;
        }
        PageReference backPage = new PageReference(retURL+'?cancel=true');
        backPage.setRedirect(true);   
        return backPage;
    }
     
//pop-up section    
    public boolean displayPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
//end pop-up section

 @testVisible class ProxyAttachment {
                @testVisible Attachment attachment;
                public ID Id { get { return attachment.ID; } set { attachment.ID = value; } }
                public ID ParentId { get { return attachment.ParentId; } set { attachment.ParentId = value; } }
                public String Name { get { return attachment.Name; } set { attachment.Name = value; } }
                public Blob Body { get { return attachment.Body; } set { attachment.Body = value; } }
                public String Description { get { return attachment.Description; } set { attachment.Description = value; } }
                public ProxyAttachment(Attachment attachment) {
                        this.attachment = attachment;
                }
                public Attachment getSObject() {
                        return attachment;
                }
        }
 
    
}