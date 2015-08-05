public class identityEditNew {

    Date currentDate = Date.today(); 
    Date defaultLastDay = currentDate.addDays(120);
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
   public List<Attachment> newAttachments { get;  set; }
    public String FN = System.currentPageReference().getParameters().get('FN');
    public String LN = System.currentPageReference().getParameters().get('LN');
    public String retURL = ApexPages.currentPage().getParameters().get('retURL');
    public String TAU = ApexPages.currentPage().getParameters().get('TAU');
    
    public String aliasName = TAU;
    
    public identityEditNew() {
        Id id = ApexPages.currentPage().getParameters().get('ID');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
//        Alias__c auAlias = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name 
//            FROM Alias__c 
//            WHERE Alias_unique__c =: aliasUser.Alias__c];
        
        TMNUser = (id == null) ? new TMN_User__c() : 
            [SELECT Accountable_Approval_Manager__c,Accountable_Manager_Mentor_Email__c,Alias__c,Approval_Level__c,
            Business_Unit_Region__c,Business_Unit__c,Current_Person_Type__c,Email__c,Employee_Number__c,Alias_Lookup__c,
            Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Level__c,Job_Status__c,Job_Title__c,
            Last_Day__c,Last_Name__c,Manager_Email__c,Manager_First_Name__c,Manager_Last_Name__c,Manager_Name__c,
            Mentor_Cell_Phone__c,Middle_Name__c,Name,Network_Username__c,Office_Location__c,Office_Phone__c,
            Operating_Group__c,Pay_Basis__c,Personal_Email__c,Personal_Phone__c,Salesforce_User_Account__c,
            Service_Line__c,Service_Region__c,Suppress_External_Update__c,Termination_Date__c,
            Unique_Id__c,Work_State_Code__c,Work_State__c,Preferred_First_Name__c,Preferred_Last_Name__c,Manager_Lookup__c,
            Work_City__c,Zip_Code__c,Professional_Title__c,Location_Name__c,Office_Location_2__c,Work_County__c, Office_Location_PickList__c, BAA_Signed__c 
            FROM TMN_User__c 
            WHERE Id = :id];
    
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
        TMNUser.Current_Person_Type__c = 'Non-Employee';
        TMNUser.Work_City__c = aliasUser.Work_City__c;
        TMNUser.Office_Location_PickList__c = aliasUser.Office_Location_PickList__c;
        TMNUser.Service_Region__c = auAlias.Alias_Region__c;
        TMNUser.Service_Line__c = auAlias.Alias_Service_Line__c;
        TMNUser.Zip_Code__c = aliasUser.Zip_Code__c;
        TMNUser.BAA_Signed__c = aliasUser.BAA_Signed__c;
        TMNUser.Last_Day__c = defaultLastDay;
    }
        
    }
     @RemoteAction
    public static TMN_User__c LocationDetails(String location) {
       return   [select location_name__c, office_location__c, office_location_2__c, work_city__c , work_state__c, office_location_picklist__c, zip_code__c from tmn_user__c where current_person_type__c <> 'Non-Employee' and location_name__c <> '' and location_name__c like : '%'+location +'%' limit 1];
    }
    
    TMN_User__c t = [SELECT Id, Name, Operating_Group__c,Manager_Name__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:userId LIMIT 1];
    public String tmnName = t.Name;
    public String tmnId = t.Id;
    public String tmnOG = t.Operating_Group__c;
    
    TMN_User__c aliasUser = [SELECT Accountable_Approval_Manager__c,Accountable_Manager_Mentor_Email__c,Alias__c,Approval_Level__c,
            Business_Unit_Region__c,Business_Unit__c,Current_Person_Type__c,Email__c,Employee_Number__c,Alias_Lookup__c,
            Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Level__c,Job_Status__c,Job_Title__c,
            Last_Day__c,Last_Name__c,Manager_Email__c,Manager_First_Name__c,Manager_Last_Name__c,Manager_Name__c,
            Mentor_Cell_Phone__c,Middle_Name__c,Name,Network_Username__c,Office_Location__c,Office_Phone__c,
            Operating_Group__c,Pay_Basis__c,Personal_Email__c,Personal_Phone__c,Salesforce_User_Account__c,
            Service_Line__c,Service_Region__c,Suppress_External_Update__c,Termination_Date__c,Manager_Lookup__c, 
            Unique_Id__c,Work_State_Code__c,Work_State__c,Work_City__c,Zip_Code__c,Work_County__c, Office_Location_PickList__c, BAA_Signed__c  
            FROM TMN_User__c 
            WHERE Email__c = :aliasName];
            
    Alias__c auAlias = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name 
                        FROM Alias__c 
                        WHERE Alias_unique__c =: aliasUser.Alias__c];        
     
    public PageReference save() {
        ID managerId = TMNUser.Manager_Lookup__c;
        ID aliasId = TMNUser.Alias_Lookup__c;
        TMN_User__c managerInfo = [SELECT Id,Email__c,Name FROM TMN_User__c WHERE Id = :managerId LIMIT 1];
        Alias__c aliasInfo = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name FROM Alias__c WHERE Id = :aliasID LIMIT 1];
        TMNUser.Manager_Email__c = managerInfo.Email__c;
        TMNUser.Manager_Name__c = managerInfo.Name;
        TMNUser.Alias__c = aliasInfo.Alias_unique__c;
        TMNUser.Alias_Lookup__c = aliasInfo.Id;
        TMNUser.Business_Unit__c = aliasInfo.Alias_Business_Unit__c;
        TMNUser.Service_Region__c = aliasInfo.Alias_Region__c;
        TMNUser.Service_Line__c = aliasInfo.Alias_Service_Line__c;
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
    public void addAttachment () {
        system.debug('in addAttachment');
        if(TMNUser.id != null) {
            attachments=[select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID from Attachment where parentId=:TMNUser.id order by createddate ]; 
            for (Integer i=0;i<3;i++){
                newAttachments.add(new Attachment() );
            }
        }else {
             newAttachments.add(new Attachment() );
             newAttachments.add(new Attachment() );
             newAttachments.add(new Attachment() );
        }
             
    }

    public PageReference saveAttachment()
    {
        List<Attachment> toInsert=new List<Attachment>();
        Integer index = 0;
        for (Attachment newAtt : newAttachments)
        {
            
            if (newAtt.Body!=null)
            {
                newAtt.parentId=TMNUser.id;
                toInsert.add(newAtt);
            }
            index ++;
        }
        insert toInsert;
        attachments=null;
        return null;
    }
    
    
    
    public pageReference updateAliasInfo(){
        Alias__c a = [SELECT Alias_Business_Unit__c,Alias_Description__c,Alias_Parent__c,Alias_Region__c,Alias_Service_Line__c,Alias_State__c,Alias_unique__c,Id,Name 
                      FROM Alias__c 
                      WHERE Id = :TMNUser.Alias_Lookup__c];
        TMNUser.Alias__c = a.Alias_unique__c;              
        TMNUser.Business_Unit__c = a.Alias_Business_Unit__c;
        TMNUser.Service_Region__c = a.Alias_Region__c;
        TMNUser.Service_Line__c = a.Alias_Service_Line__c;
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
        PageReference cancelPage = new PageReference(retURL);
        cancelPage.setRedirect(true);   
        return cancelPage;
    }

    public PageReference goBack() {
        if(retURL == null){
            PageReference backPage = new PageReference('/apex/identity_home');
            backPage.setRedirect(true);   
            return backPage;
        }
        PageReference backPage = new PageReference(retURL);
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
    
}