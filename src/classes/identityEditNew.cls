// comment added to create diff by AV
public class identityEditNew {

    Date currentDate = Date.today();
    Date defaultLastDay = currentDate.addDays(90);
    public TMN_User__c TMNUser { get;  set; }
    /*User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    String userId = u.id; Sravan - 03/08/2016*/
    TMN_User__c loggedinTMNUser = [SELECT Id, Name, Operating_Group__c, Manager_Name__c, Business_unit__c, Manager_lookup__c, Alias__c, Approval_Level__c, Salesforce_User_Account__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:userinfo.getUserId() LIMIT 1];
    public String myManager {
        get{return (loggedinTMNUser.Manager_Name__c);}
        set{loggedinTMNUser.Manager_Name__c = value;}
    }
    public String myOpGroup {
        get{return (loggedinTMNUser.Operating_Group__c);}
        set{loggedinTMNUser.Operating_Group__c = value;}
    }
    public string loggedinUserAlias{
    	get{return loggedinTMNUser.Alias__c;}
    }
    public boolean cmpDirPermset{get; set;} //Check whether company directory permset is assigned or not
    public List<ProxyAttachment> newAttachments { get ; set; }
    public String FN = System.currentPageReference().getParameters().get('FN');
    public String LN = System.currentPageReference().getParameters().get('LN');
    public String retURL = ApexPages.currentPage().getParameters().get('retURL');
    public String TAU = ApexPages.currentPage().getParameters().get('TAU');
    public String aliasName {set;get { return TAU;}}
    public Boolean isNewUser {set;get;}
    public String therapistSection {set;get;}
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

  /* TMN_User__c tmn = [SELECT Id,Name,Operating_Group__c,Manager_Name__c,Email__c,Approval_Level__c
                     FROM TMN_User__c
                     WHERE Salesforce_User_Account__c=:UserInfo.getUserId()
                     LIMIT 1];
      public Integer ApprovalLevel {get{
    			List<TMN_User__c> managerList = [select id,Manager_Lookup__c from TMN_User__c where  Manager_Lookup__c = : tmn.id];
    				if (managerList!=null && managerList.size()>0){
    					return Integer.valueOf(tmn.Approval_Level__c);
    				}
    				return 0;
    		}set;} ------Sravan Commenting unnecessary code - 03/08/2016*/
    public Boolean canTerminate{set;get;}

    public list<SelectOption> disciplineValues{get{
		if(disciplineValues == null){
			disciplineValues = new List<SelectOption>();
			Schema.DescribeFieldResult fieldResult = TMN_User__c.Discipline__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			disciplineValues.add(new selectOption('', '--None--'));
			for(Schema.PicklistEntry f : ple){
				string label = f.getLabel();
				if(myOpGroup == 'NeuroRestorative'){
							if(label == 'Dietitian' || label == 'Speech Therapy' || label == 'Social Services'
							|| label=='Respiratory' || label== 'PT-Massage' || label== 'Physical Therapy' || label== 'Occupational Therapy'){

								continue;
							}
				}else if(myOpGroup == 'Care Meridian'){
					if(label =='PT' || label == 'OT' || label == 'SLP' || label == 'Counselling' || label=='BIT'
						|| label == 'Recreation Therapy' || label == 'Woodshop' || label== 'Productive Activity'){

						continue;

					}

				}

				disciplineValues.add(new selectOption(f.getValue(), f.getLabel()));
			}
		}

		return disciplineValues;

	}
	set;}

    public identityEditNew(ApexPages.StandardController controller) {

        Id id = ApexPages.currentPage().getParameters().get('ID');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        cmpDirPermset = checkCompanyDirectory();
//        Alias__c auAlias = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name
//            FROM Alias__c
//            WHERE Alias_unique__c =: aliasUser.Alias__c];

        if(myOpGroup=='NeuroRestorative'){
        	therapistSection = 'NeuroRestorative Therapist Information';
        }
        else if(myOpGroup=='Care Meridian'){
        	therapistSection = 'Care Meridian Therapist Information';
        }
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
            Personal_Location__c, Personal_Zip__c, Rate__c,Custodians__c,Pre_Hire_ID__c,Job_Code__c,Recruiter_Name__c,Recruiter_Email_Address__c,other_Vendor_name__c
            FROM TMN_User__c
            WHERE Id = :id];
         newAttachments = new List<ProxyAttachment>();
        if(TMNUser.id!=null) {
        	if( TMNUser.Current_Person_Type__c=='Non-Employee' && TMNUser.Vendor_list__c!=null && !(TMNUser.Vendor_list__c=='OTHER' || TMNUser.Vendor_list__c=='INDEPENDENT CONTRACTOR' )){
    			TMNUser.BAA_Signed__c =true;
        	}
	        /*if(ApprovalLevel>=3 && ApprovalLevel>TMNUser.Approval_Level__c){
	         	canTerminate = true;
	         }else {
	         	canTerminate = false;
	         } Sravan - 03/08/2016*/
	         canTerminate = canTerminate();
             attachments=[select Id, ParentId, Name, LastModifiedDate,Description,CreatedDate,Owner.Name, OwnerID ,LastModifiedById, CreatedById, BodyLength,IsPrivate,CreatedBy.name,LastModifiedBy.name from Attachment where parentId=:TMNUser.id order by createddate ];
             for(integer i = attachments.size(); i<3;i++){
             	newAttachments.add(new  ProxyAttachment(new Attachment()));
        	 }
        }else{
	        newAttachments.add(new  ProxyAttachment(new Attachment()));
	        newAttachments.add(new ProxyAttachment(new Attachment()));
	        newAttachments.add(new ProxyAttachment(new Attachment()));
        }



    if(TMNUser.Id == null){
    	isNewUser = true;
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
        TMNUser.other_Vendor_name__c = aliasUser.other_Vendor_name__c;
        TMNUser.Last_Day__c = defaultLastDay;
    }else {
    	isNewUser = false;
    }
 }

 	public List<SelectOption> getVendorvalues() {
		List<SelectOption> Options = new List<SelectOption>();
		Options.add(new SelectOption('NONE','NONE') );
		List<TMN_Corp_Contract__c> tmnContract = [select id,name,Supplier__r.name,Type_of_Contract__c,Description__c,BAA_HIPAA_in_Contract__c from TMN_Corp_Contract__c  where (Type_of_Contract__c = 'BAA' OR BAA_HIPAA_in_Contract__c = 'Yes') AND Status__c in ('NEW','ACTIVE','RENEWED') order by Supplier__r.name];
				for(TMN_Corp_Contract__c contract:tmnContract){
					Options.add(new SelectOption(contract.Supplier__r.name,contract.Supplier__r.name));
				}
		Options.add(new SelectOption('INDEPENDENT CONTRACTOR','INDEPENDENT CONTRACTOR'));
		Options.add(new SelectOption('OTHER','OTHER'));

		return Options;
	}


 	public List<TMN_User__c> tmnManagerList {set;get;}
 	public String managerFirstName  {set;get;}
 	public String managerLastName  {set;get;}
 			public PageReference getManagerList() {
 				list<AggregateResult> userAggregateResult;
 					if(managerFirstName!=null && managerFirstName.length() > 0 && (managerLastName ==null || managerLastName.length() ==0)){
 				 		userAggregateResult = [select Manager_lookup__c from TMN_User__c where Manager_First_Name__c like : '%'+managerFirstName +'%' and Manager_lookup__c != null group by Manager_lookup__c limit 100];
 					} else if(managerFirstName==null || managerFirstName.length() == 0 && (managerLastName !=null && managerLastName.length() >0)){
 						userAggregateResult = [select Manager_lookup__c from TMN_User__c where Manager_Last_Name__c like : '%'+managerLastName +'%' and Manager_lookup__c != null group by Manager_lookup__c limit 500];
 					} else {
 						userAggregateResult = [select Manager_lookup__c from TMN_User__c where Manager_First_Name__c like : '%'+managerFirstName +'%' and Manager_Last_Name__c like : '%'+managerLastName +'%' and Manager_lookup__c != null group by Manager_lookup__c limit 100];
 					}
					 tmnManagerList = new List<TMN_User__c>();
					Set<String> managerIds = new Set<String>();
					for(AggregateResult tmn:userAggregateResult) {
						List<TMN_User__c> tmnManager = [select id,Name,Email__c,Employee_Number__c,Employee_Type__c,Job_Title__c,Manager_Email__c,Work_State__c,Operating_Group__c from TMN_User__c where Id =:string.valueof(tmn.get('Manager_lookup__c'))  limit 1];
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

    public Attachment attDeatils {set;get;}
 	public Boolean enableDelete {set;get;}
 	public ProxyAttachment attachmentView {set;get {
 		  attchmentId =  System.currentPageReference().getParameters().get('attchmentId');
       if(attchmentId!=null) {
       		attDeatils =   [select Id, ParentId, Name, LastModifiedDate,Description,CreatedDate,Owner.Name, OwnerID ,LastModifiedById, CreatedById, BodyLength,IsPrivate,CreatedBy.name,LastModifiedBy.name  from Attachment where id=:attchmentId order by createddate limit 1];
     		 system.debug(' attDeatils :' + attDeatils);
      		ProxyAttachment  view = (new ProxyAttachment(attDeatils));
       		if(attDeatils.OwnerID.equals(UserInfo.getUserId())){
        		enableDelete = true;
        	}else {
        		enableDelete = false;
        	}
      return view;
    } return null;}   }

	public  PageReference attachmentDeatils() {
		 if(attchmentId!=null){
			attDeatils =   [select Id, ParentId, Name, LastModifiedDate,Description,CreatedDate,Owner.Name, OwnerID ,LastModifiedById, CreatedById, BodyLength,IsPrivate,CreatedBy.name,LastModifiedBy.name  from Attachment where id=:attchmentId order by createddate limit 1];
		 	attachmentView = (new ProxyAttachment(attDeatils));
		 }
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
        return  goEdit();
    }

        public PageReference updateAttachment () {
            update attDeatils;
            attachments=[select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID from Attachment where parentId=:TMNUser.id order by createddate ];
            return goEdit();
        }

    /*TMN_User__c t = [SELECT Id, Name, Operating_Group__c,Manager_Name__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:userId LIMIT 1];
    public String tmnName = t.Name;
    public String tmnId = t.Id;
    public String tmnOG = t.Operating_Group__c; -----Sravan Commenting this unnecessary code 03/08/2016-----*/

   public TMN_User__c aliasUser {set;get{ List<TMN_User__c> aliasUserList = [SELECT Accountable_Approval_Manager__c,Accountable_Manager_Mentor_Email__c,Alias__c,Approval_Level__c,
            Business_Unit_Region__c,Business_Unit__c,Current_Person_Type__c,Email__c,Employee_Number__c,Alias_Lookup__c,
            Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Level__c,Job_Status__c,Job_Title__c,
            Last_Day__c,Last_Name__c,Manager_Email__c,Manager_First_Name__c,Manager_Last_Name__c,Manager_Name__c,
            Mentor_Cell_Phone__c,Middle_Name__c,Name,Network_Username__c,Office_Location__c,Office_Phone__c,
            Operating_Group__c,Pay_Basis__c,Personal_Email__c,Personal_Phone__c,Salesforce_User_Account__c,
            Service_Line__c,Service_Region__c,Suppress_External_Update__c,Termination_Date__c,Manager_Lookup__c,Program_String__c,
            Unique_Id__c,Work_State_Code__c,Work_State__c,Work_City__c,Zip_Code__c,Work_County__c, Office_Location_PickList__c, BAA_Signed__c,Location_Name__c,phone_ext__c,Custodians__c,
            Pre_Hire_ID__c,Job_Code__c,Recruiter_Name__c,Recruiter_Email_Address__c,other_Vendor_name__c
            FROM TMN_User__c
            WHERE Id = :aliasName];
                               if(aliasUserList.size()>0){
                                              return aliasUserList[0];
                                          }
                                        return null; }} // This change to prevent error when the user tring to access tmn user record with ID only[without TAU OR retUrl]. If you see  different behavior please revert back to previous code

  public Alias__c auAlias {set;get{ if (aliasUser!=null) {  return [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name
                        FROM Alias__c
                        WHERE Alias_unique__c =: aliasUser.Alias__c];
                        }
                               return null;  }}// This change to prevent error when the user tring to access tmn user record with ID only[without  OR retUrl]

    public PageReference saveDiscipline() {
        String therapydiscipline = Apexpages.currentPage().getParameters().get('therapyDisc');
        TMNUser.Discipline__c = therapydiscipline;
        pagereference pr = save();
        return pr;
    } 
    
    public PageReference save() {
		Boolean error = false;
    	 List<TMN_User__c> location =  [select location_name__c, office_location__c, office_location_2__c, work_city__c , work_state__c, office_location_picklist__c, zip_code__c,Manager_Name__c from tmn_user__c where location_name__c  =:TMNUser.Location_Name__c limit 1];
       	if(location.size() == 0){
       		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Search and select valid Location Name in order to save this record.'));
    	 	error = true;
       	}

		if(isNewUser && TMNUser.Current_Person_Type__c!=null && TMNUser.Current_Person_Type__c == 'Non-Employee' &&  TMNUser.Hire_Date__c!=null && TMNUser.Last_Day__c!=null && TMNUser.Hire_Date__c.daysBetween(TMNUser.Last_Day__c)>90){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'End Date can\'t be more than 90 days from Start Date.'));
    	 	error = true;
		}
		if(!isNewUser && TMNUser.Current_Person_Type__c!=null && TMNUser.Current_Person_Type__c == 'Non-Employee' &&  TMNUser.Last_Day__c!=null && Date.Today().daysBetween(TMNUser.Last_Day__c)>90){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'End Date can\'t be more than 90 days from Current Date.'));
    	 	error = true;
		}

		if(TMNUser.Hire_Date__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date is required to save this record'));
    	 	error = true;
        }
        if(TMNUser.Current_Person_Type__c!=null && TMNUser.Current_Person_Type__c == 'Non-Employee' && (TMNUser.Vendor_list__c == null || TMNUser.Vendor_list__c =='NONE')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Vendor information is required to save this record'));
    	 	error = true;
        }

		if(TMNUser.Personal_Email__c !=null && TMNUser.Personal_Email__c.length()>0 ){
    	 	if(!validate(TMNUser.Personal_Email__c)) {
    	 	 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Personal Email: Enter a valid email address'));
                error = true;
    	 	}
        }
        if(!(TMNUser.Operating_Group__c =='Care Meridian') && TMNUser.Vendor_list__c =='OTHER' && ( TMNUser.other_Vendor_name__c == null || TMNUser.other_Vendor_name__c.length()== 0 ) ){
    	 	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Vendor Name: Vendor Name is required in order to save this record'));
                error = true;
        }

		if(error){
			return null;
		}

        ID managerId = TMNUser.Manager_Lookup__c;
        String managerEmail = TMNUser.Manager_Email__c;
        ID aliasId = TMNUser.Alias_Lookup__c;
        TMN_User__c managerInfo ;
        List<TMN_User__c> managerInfoList = [SELECT Id, Email__c, Name, Employee_Number__c,Approval_Level__c, Manager_lookup__c, Manager_Email__c FROM TMN_User__c WHERE Id = :managerId LIMIT 1];
		if(managerInfoList!=null&& managerInfoList.size()>0){
				managerInfo = managerInfoList[0];
		}else {
			managerInfoList = [SELECT Id,Email__c,Name,Employee_Number__c, Approval_Level__c, Manager_lookup__c, Manager_Email__c FROM TMN_User__c WHERE Manager_Email__c = :managerEmail LIMIT 1];
			if(managerInfoList!=null&& managerInfoList.size()>0){
				managerInfo = managerInfoList[0];
			}
		}
        Alias__c aliasInfo = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name FROM Alias__c WHERE Id = :aliasID LIMIT 1];
        TMNUser.Manager_Email__c = managerInfo.Email__c;
        TMNUser.Manager_Name__c = managerInfo.Name;
        TMNUser.Manager_Employee_Id__c = managerInfo.Employee_Number__c; //Sravan:01/25/2016 - EPIM-283
        TMNUser.Alias__c = aliasInfo.Alias_unique__c;
        TMNUser.Alias_Lookup__c = aliasInfo.Id;
        TMNUser.Business_Unit__c = aliasInfo.Alias_Business_Unit__c;
        TMNUser.Service_Region__c = aliasInfo.Alias_Region__c;
        TMNUser.Service_Line__c = aliasInfo.Alias_Service_Line__c;
        TMNUser.Program_String__c = aliasInfo.Alias_Description__c;
        //<----------------Sravan: EPIM-283 -- Accountable Approval logic -- Start----------------------------->
        if(null != managerInfo.Approval_Level__c && managerInfo.Approval_Level__c >= 3){
        	TMNUser.Accountable_Approval_Manager__c = managerInfo.Name;
        	TMNUser.Accountable_Manager_Mentor_Email__c = managerInfo.Email__c;
        }else{

        	id manager3Id = null;
        	string manager3Email = null;
        	id manager4Id = null;
        	string manager4Email = null;

        	List<TMN_User__c> manager2 = new List<TMN_User__c>();
        	List<TMN_User__c> manager3 = new List<TMN_User__c>();
        	List<TMN_User__c> manager4 = new List<TMN_User__c>();
        	// If immediate manager does not have approval level >= 3, move one more level up.
        	if(null != managerInfo.Manager_lookup__c){
        		manager2 = [SELECT Id, Name, Manager_lookup__c, Email__c, Manager_Email__c, Approval_Level__c FROM TMN_User__c WHERE Id =:managerInfo.Manager_lookup__c LIMIT 1];
        		manager3Id = manager2[0].Manager_lookup__c;
        	}else if(null != managerInfo.Manager_Email__c){
        		manager2 = [SELECT Id, Name, Manager_lookup__c, Email__c, Manager_Email__c, Approval_Level__c FROM TMN_User__c WHERE Email__c =:managerInfo.Email__c LIMIT 1];
        		manager3Email = manager2[0].Manager_Email__c;
        	}

        	if(manager2.size() > 0){
        		if(null != manager2[0].Approval_Level__c && manager2[0].Approval_Level__c >= 3){
        			TMNUser.Accountable_Approval_Manager__c = manager2[0].Name;
        			TMNUser.Accountable_Manager_Mentor_Email__c = manager2[0].Email__c;
        		}else{
        			//move one more level up
        			if(null != manager3Id){
        				manager3 = [SELECT Id, Name, Email__c, Manager_lookup__c, Manager_Email__c, Approval_Level__c FROM TMN_User__c WHERE Id =:manager3Id LIMIT 1];
		        		manager4Id = manager3[0].Manager_lookup__c;
        			}else if(null != manager3Email){
        				manager3 = [SELECT Id, Name, Email__c, Manager_lookup__c, Manager_Email__c, Approval_Level__c FROM TMN_User__c WHERE Email__c =:manager3Email LIMIT 1];
		        		manager4Email = manager3[0].Manager_Email__c;
        			}

        			if(manager3.size() > 0){
        				if(null != manager3[0].Approval_Level__c && manager3[0].Approval_Level__c >= 3){
        					TMNUser.Accountable_Approval_Manager__c = manager3[0].Name;
        					TMNUser.Accountable_Manager_Mentor_Email__c = manager3[0].Email__c;
        				}else{//one final level
        					if(null != manager4Id){
				        		 manager4 = [SELECT Id, Name, Email__c, Manager_lookup__c, Approval_Level__c FROM TMN_User__c WHERE Id =:manager4Id LIMIT 1];
				        	}else if(null != manager4Email){
				        		manager4 = [SELECT Id, Name, Email__c, Manager_lookup__c, Approval_Level__c FROM TMN_User__c WHERE Email__c =:manager4Email LIMIT 1];
				        	}

        					if(manager4.size() > 0){
        						TMNUser.Accountable_Approval_Manager__c = manager4[0].Name;
				    			TMNUser.Accountable_Manager_Mentor_Email__c = manager4[0].Email__c;
        					}
        				}

        			}

        		}

        	}

        }
        //<------------------- Accountable Approval logic -- End --------------------------------------------------->
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

            sendEmail(TMNUser);
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

    public void sendEmail (TMN_User__c TMNUser) {
    	if(TMNUser.Current_Person_Type__c == 'Employee' && TMNUser.Last_Day__c!=null) {
    		List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
   			List<TMN_User__c> tmnManagerInfo = [select id,name,email__c,Salesforce_User_Account__c from TMN_User__c where Salesforce_User_Account__r.isActive = true and email__c =: TMNUser.Manager_Email__c];
    		if(tmnManagerInfo!=null && tmnManagerInfo.size()>0) {
    			Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
    			mail.setTargetObjectId(tmnManagerInfo[0].Salesforce_User_Account__c);
    	  		String Template = '<H4> Hello '+TMNUser.Manager_First_Name__c+' '+ TMNUser.Manager_Last_Name__c + ', </H4>';
    	    	Template  += '<P> You are receiving this message because you are listed as the manager for <B>'+TMNUser.First_Name__c+' '+ TMNUser.Last_Name__c +'</B> in TMNAccess. The End Date on employee record has been ';
    	    	Template  += 'modified and the account has been set to terminate on '+TMNUser.Last_Day__c +' </P> ';
    	    	Template  += 'If you are not the manager for the employee mentioned in this email or have other questions in regards, please either log into TMNAccess ('+URL.getSalesforceBaseUrl().toExternalForm()+'/'+TMNUser.id;
    	    	Template  += ') or contact IT Service Center at 888-774-4872 for assistance.' ;
    	    	Template  += '<P>This is an automated message sent by the TMNAccess application. If you have any questions or see any discrepancies in the below information please contact the IT Service Center.</P>';
				Template  += '<BR/> Thank you,<BR/> MENTOR IT';
				mail.setHtmlBody(Template);
				mail.setSubject('End Date entered  for '+TMNUser.First_Name__c+' '+ TMNUser.Last_Name__c );
				mail.SaveAsActivity = false;
				mails.add(mail);
    			Messaging.sendEmail(mails);
    		}
      	}

    }

    public List<Attachment> attachments {set;get;}

    public String attchmentId{set;get;}

    public void saveAttachment(){
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
            }else if(t.Last_Day__c < Date.today() && (t.Current_Person_Type__c == 'Non-Employee' || t.Current_Person_Type__c == 'Employee')){ //Sravan: 04/11/2016
                t.Job_Status__c = 'Inactive';
            }
        }
    }


    public static void sendPreHireEmail (TMN_User__c[] preHireList){
    		 		List<Messaging.SingleEmailMessage> mails =   new List<Messaging.SingleEmailMessage>();
    		 for (TMN_User__c preHire :preHireList){
    			if(preHire.Current_Person_Type__c == 'Pre-hire'){
    				List<OrgWideEmailAddress> owa = [Select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName = 'TMN Access' LIMIT 1];
    		List<TMN_User__c> recruiterInfo = [select id,name,email__c,Salesforce_User_Account__c from TMN_User__c where Salesforce_User_Account__r.isActive = true and email__c =: preHire.Recruiter_Email_Address__c];
    			if(recruiterInfo!=null && recruiterInfo.size()>0) {
    			Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
		  String	emailTemplate = '<H4> Hello '+preHire.Recruiter_Name__c + ', </H4>';
					emailTemplate += '<P> You are receiving this message because you are listed as the recruiter for a pre-hire record created recently in TMNAccess. ';
					emailTemplate += '<BR>Please log into TMNAccess('+URL.getSalesforceBaseUrl().toExternalForm()+'/'+preHire.id+')  to take any required actions on the Pre-hire record.';
					emailTemplate += '<P>If you are not the recruiter for pre-hire mentioned in this email or have other questions in regards to Pre-hire termination, please contact IT Service Center at 888-774-4872 for assistance.</P> <BR/><BR/>';
					emailTemplate += '<P>This is an automated message sent by the TMNAccess application. If you have any questions or see any discrepancies in the above information please contact the IT Service Center.</P> ';
					emailTemplate += 'Thank you,<BR/> MENTOR IT.';
					mail.setTargetObjectId(recruiterInfo[0].Salesforce_User_Account__c);
					mail.setHtmlBody(emailTemplate);
					mail.setSubject('***TAKE ACTION*** TMNAccess – New Pre-Hire Record');
					mail.SaveAsActivity = false;
					mail.setOrgWideEmailAddressId(owa[0].Id);
					mails.add(mail);
					}
			}
				if(mails.size()>0){
				Messaging.sendEmail(mails);
				}
    		 }
	    }

    public PageReference goEdit(){
        Id id = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        	if(retURL== null){
        			 retURL = '/apex/identity_nonemployees';
        	}
        String TAU = ApexPages.currentPage().getParameters().get('TAU');
        		if(TAU == null) {
        			TAU = TMNUser.Manager_lookup__c;
        			//TAU = UserInfo.getUserEmail(); - Sravan - Moving away from using Email
        		}
        PageReference editPage = new PageReference('/apex/identity_edittmnu?id=' + id + '&retURL=' + retURL + '&TAU=' + TAU);
        editPage.setRedirect(true);
        return editPage;
    }

    public PageReference goAttachmentEdit(){
        PageReference AttachmentEdit = new PageReference('/apex/identity_attachmentView?id=' + tmnuser.id + '&retURL=' + retURL + '&TAU=' + TAU +'&attchmentId='+attchmentId);
        AttachmentEdit.setRedirect(true);
        return AttachmentEdit;
    }

    public PageReference goCancel() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference cancelPage =  new PageReference('/apex/identity_view?id=' + id + '&retURL=' + retURL + '&TAU=' + TAU);
        cancelPage.setRedirect(true);
        return cancelPage;
    }

 	public PageReference createCancel() {
        PageReference createPage =  new PageReference('/apex/identity_nonemployees?cancel=true&TAU=' + TAU);
        createPage.setRedirect(true);
        return createPage;
    }
    public PageReference goTerminate() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL== null){
        			 retURL = '/apex/identity_nonemployees';
        	}
        String TAU = ApexPages.currentPage().getParameters().get('TAU');
        		if(TAU == null) {
        			TAU = TMNUser.Manager_lookup__c;
        			//TAU = UserInfo.getUserEmail(); - Sravan - Moving away from using Email
        		}
        PageReference terminatePage =  new PageReference('/apex/identity_Terminate?id=' + id + '&retURL=' + retURL + '&TAU=' + TAU );
        terminatePage.setRedirect(true);
        return terminatePage;
    }

    public PageReference goRequestAccess() {
		String url = '';
		List<Site_URL__c> siteList =	[select id,name,Prefix__c from Site_URL__c where name = 'EasyVistaUrl'];
		if(siteList.size()>0){
			url = siteList[0].Prefix__c;
		}else {
		 	Id id = ApexPages.currentPage().getParameters().get('id');
        	String retURL = ApexPages.currentPage().getParameters().get('retURL');
        	url = '/apex/RequestAccess?id=' + id + '&retURL=' + retURL + '&TAU=' + TAU;
		}
        PageReference requestAccessPage =  new PageReference(url);
        requestAccessPage.setRedirect(true);
        return requestAccessPage;
    }

    public PageReference goBack() {
        if(retURL == null){
            PageReference backPage = new PageReference('/apex/identity_nonemployees?cancel=true&TAU=' + TAU);
            backPage.setRedirect(true);
            return backPage;
        }
		PageReference backPage = new PageReference(retURL+'?cancel=true&TAU=' + TAU);
        backPage.setRedirect(true);
        return backPage;
    }
  //Updates on Entering End Date -- begin  --- --EPIM-282 - Sravan---------------------------------------------------------------------
   public boolean canTerminate(){

   		if(loggedinTMNUser.Alias__c == Identity_Utility__c.getInstance().ITSSC_Alias__c ){ //ITSSC Can terminate anyone - Alias - 001160
   			return true;
   		}else if([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :loggedinTMNUser.Salesforce_User_Account__c AND PermissionSet.Name = 'TMNAccess_Recruiter'].size() > 0 && loggedinTMNUser.Business_Unit__c == TMNUser.Business_Unit__c){
   			return true;
   		}else if(loggedinTMNUser.Approval_Level__c >= 3 &&  (loggedinTMNUser.Approval_Level__c > TMNUser.Approval_Level__c)){  //Approval level is greater
   			return true;
   		}else if(loggedinTMNUser.Id == TMNUser.Manager_lookup__c){ //Direct Manager
   			return true;
   		}else{ //Delegate for Manager
   			List<TMN_User_Delegate__c> managerDelegate =  [SELECT TMN_Delegate_Name__c,TMN_Delegate_For__c, Delegation_Complete__c FROM TMN_User_Delegate__c WHERE TMN_Delegate_Name__c = :loggedinTMNUser.Id  AND TMN_Delegate_For__c = :TMNUser.Manager_lookup__c AND Delegation_Complete__c = false LIMIT 1];
   			if(managerDelegate.size() > 0){
   				return true;
   			}
   		}

   	return false;
   }
   //Updates on Entering End Date -- End  --- --EPIM-282 ---------------------------------------------------------------------------------------

//pop-up section
    public boolean displayPopup {get; set;}

    public void closePopup() {
        displayPopup = false;
    }
    public void showPopup() {
        displayPopup = true;
    }
//end pop-up section

//Check the current users permission Set
public Boolean checkCompanyDirectory(){
	List<PermissionSetAssignment> companyDirectory = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :loggedinTMNUser.Salesforce_user_Account__c AND PermissionSet.name = 'Company_Directory_Editor' LIMIT 1];
	if(companyDirectory.size() > 0){
		return true;
	}else{
		return false;
	}
}

 @testVisible class ProxyAttachment {
                @testVisible Attachment attachment;
                public ID Id { get { return attachment.ID; } set { attachment.ID = value; } }
                public ID ParentId { get { return attachment.ParentId; } set { attachment.ParentId = value; } }
                public String Name { get { return attachment.Name; } set { attachment.Name = value; } }
                public Blob Body { get { return attachment.Body; } set { attachment.Body = value; } }
                public String Description { get { return attachment.Description; } set { attachment.Description = value; } }
                public String OwnerName { set;get {  return this.attachment.Owner.Name; }}
                public String OwnerId {set; get { return this.attachment.OwnerId; }}
                public String LastModifiedDate {set; get { return attachment.LastModifiedDate.format('MM/dd/yyyy hh:mm a'); }}
         		public String CreatedDate { set;get {return attachment.CreatedDate.format('MM/dd/yyyy hh:mm a'); }}
         		public String LastModifiedBy { get { return attachment.LastModifiedBy.name; }}
         		public String CreatedBy { get { return attachment.CreatedBy.Name;}}
         		public String BodyLength { get { return attachment.BodyLength/1024+' KB';}}
                public ProxyAttachment(Attachment attachment) {
                        this.attachment = attachment;
                }
                public Attachment getSObject() {
                        return attachment;
                }
        }



}