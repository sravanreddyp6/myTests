public with sharing class IdentityHomeController {

    public String searchUser {get; set;}
    public String srchFName {get; set;}
    public String srchLName {get; set;}
    public String srchMngFName {get; set;}
    public String srchMngLName {get; set;}
    public String srchFNameNonEmp {get; set;}
    public String srchLNameNonEmp {get; set;}
    public String srchMngFNameNonEmp {get; set;}
    public String srchMngLNameNonEmp {get; set;}    
    public String srchOpGroup {get; set;}
    public String generatedKey1 {get; set;}
    public String generatedKey2 {get; set;}
    public List<TMN_User__c> Records {get; set;}
    public List<TMN_User__c> mySubordinates {get; set;}
    public List<TMN_User__c> searchResult {get; set;}
    public List<TMN_User__c> searchDelegateResult {get; set;}
    public List<TMN_User__c> searchNonEmpResult {get; set;}
    public TMN_User__c theTMNUser {get; set;}
    public ID selectedID {get; set;}
    Public List<TMN_User__c> tmnUserList {get; set;}
    Public String tmnSearchStr {get; set;}
    
    Date currentDate = Date.today();
    Date endDate = currentDate.addDays(-45);
    
    String[] operatingGroups = new String[]{};
    String[] myId = new String[]{};
    
    User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    String userId = u.id;
    
    TMN_User__c t = [SELECT Id, Name, Operating_Group__c,Delegate_For__c,Manager_Name__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:userId LIMIT 1];
    public String tmnName = t.Name;
    public String tmnId = t.Id;
    public String tmnOG = t.Operating_Group__c;
    public String tmnDelegateFor = t.Delegate_For__c;
    
    String aliasName = getaliasName();
    String getaliasName(){
        if (String.isEmpty(tmnDelegateFor)){
            aliasName=tmnName;
        }else{
            TMN_User__c alias = [SELECT Id, Name, Operating_Group__c,Delegate_For__c,Manager_Name__c FROM TMN_User__c WHERE Id=:tmnDelegateFor LIMIT 1];
            aliasName = alias.Name;        
        }
    return aliasName;    
    }
    
    public IdentityHomeController() {
        Records = [SELECT Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,
                    Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,
                    Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,
                    Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c 
                    FROM TMN_User__c WHERE lastvieweddate != null ORDER BY lastvieweddate desc LIMIT 10];
       
        mySubordinates = [SELECT Id FROM TMN_User__c WHERE Manager_Name__c=:tmnName];                                                                                                            
    }

    List<TMN_User__c> attestNonEmployees;
    public List<TMN_User__c> getattestNonEmployees() {
         attestNonEmployees = [SELECT Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,
                   Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,
                   Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,
                   Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c,Last_Day__c 
                   FROM TMN_User__c WHERE (Manager_Name__c=:tmnName OR Manager_Name__c=:aliasName) 
                   AND Current_Person_Type__c NOT IN ('Employee')
                   AND Last_Day__c>=:endDate];
                   return attestNonEmployees;
    }
    
    List<TMN_User__c> myDelegates;        
    public List<TMN_User__c> getMyDelegates() {
        myDelegates = [SELECT Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,
                   Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,
                   Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,
                   Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c,Last_Day__c,Delegate_For__c 
                   FROM TMN_User__c WHERE Delegate_For__c=:tmnId];
                   return myDelegates;
    }
    
    List<TMN_User__c> myEmployees;
    public List<TMN_User__c> getMyEmployees() {
        myEmployees = [SELECT Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,
                    Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,
                    Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,
                    Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c,Delegate_For__c 
                    FROM TMN_User__c WHERE (Manager_Name__c=:tmnName OR Manager_Name__c=:aliasName) AND Current_Person_Type__c='Employee'];
                    return myEmployees;    
    }
    
    List<TMN_User__c> myNonEmployees;
    public List<TMN_User__c> getmyNonEmployees() {
        myNonEmployees = [SELECT Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,
                    Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,
                    Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,
                    Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c 
                    FROM TMN_User__c WHERE (Manager_Name__c=:tmnName OR Manager_Name__c=:aliasName) AND Current_Person_Type__c NOT IN ('Employee')];        
        return myNonEmployees;
    }                           

    String tmnMgrLName;
    public String getTmnMgrLName() {
        tmnMgrLName = t.Manager_Last_Name__c;
        return tmnMgrLName;
    }

    String tmnMgrFName;
    public String getTmnMgrFName() {
        tmnMgrFName = t.Manager_First_Name__c;
        return tmnMgrFName;
    }

    Boolean isDelegate;
    public Boolean getisDelegate() {
        if(String.isEmpty(tmnDelegateFor) && mySubordinates.isEmpty()){
            isDelegate = false;
        }else{
            isDelegate = true;
        } 
    return isDelegate;    
    }

    Boolean hasAccess;
    public Boolean gethasAccess() {
        if(mySubordinates.isEmpty()){
            hasAccess = false;
        }else{
            hasAccess = true;
        }
        return hasAccess;
    }

    Boolean btnDisable = true;
    public Boolean getbtnDisable() {
        return btnDisable;
    }  
        
    public void removeDel() {
        TMN_User__c userToRemove;
            try {
                userToRemove = [SELECT Id,Delegate_For__c FROM TMN_User__c WHERE Id=:selectedId LIMIT 1];
                userToRemove.Delegate_For__c = NULL;
                update userToRemove;
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage()));
            }
    }
    
    public void addDel() {
        TMN_User__c userToAdd;
        List<TMN_User__c> inDelegate;
        inDelegate = [SELECT Id FROM TMN_User__c WHERE Delegate_For__c =:tmnId];
        if(inDelegate.isEmpty()) {       
            try {
                userToAdd = [SELECT Id,Delegate_For__c FROM TMN_User__c WHERE Id=:selectedId LIMIT 1];
                userToAdd.Delegate_For__c = tmnId;
                update userToAdd;
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'An unexpected error has occurred: ' + e.getMessage()));
            }
        }else{
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, 'You already have a delegate assigned. Remove the currently assigned delegate and try again.');
            ApexPages.addMessage(msg);
        }         
    }    
    

    public void delSearch() {       
        if (String.IsBlank(srchFName) && String.IsBlank(srchLName) && String.IsBlank(srchMngFName) && String.IsBlank(srchMngLName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter something into one of the search boxes to complete the search.'));
        } else if (srchFName.length()<3 && srchLName.length()<3 && srchMngFName.length()<3 && srchMngLName.length()<3) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter at least three characters in one of the search boxes to complete the search.'));
        } else {
            String searchDel='SELECT Email__c,First_Name__c,Last_Name__c,Operating_Group__c,Manager_Email__c,Manager_Name__c,Manager_Last_Name__c,Manager_First_Name__c,Id FROM TMN_User__c WHERE First_Name__c LIKE \'%'+srchFName+'%\' AND Last_Name__c LIKE \'%'+srchLName+'%\' AND Manager_Last_Name__c LIKE \'%'+srchMngLName+'%\' AND Manager_First_Name__c LIKE \'%'+srchMngFName+'%\' AND Operating_Group__c =\''+tmnOG+'\' ORDER BY Last_Name__c ASC LIMIT 200';
            searchDelegateResult = Database.query(searchDel);
                if(searchDelegateResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The search did not find any possible matches! Please check the name and try again.')); 
                }           

            }
        }      

      public void nonEmpSearch(){
          generatedKey1 = Soundex.toSoundex(srchLNameNonEmp);
          generatedKey2 = Soundex.toSoundex(srchFNameNonEmp);
          doQuery();
      }
      
      public PageReference doQuery(){
          if (String.IsBlank(srchFNameNonEmp) && String.IsBlank(srchLNameNonEmp)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter something into one of the search boxes to complete the search.'));
              btnDisable = true;
          }else if (srchFNameNonEmp.length()<3 && srchLNameNonEmp.length()<3){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter at least three characters in one of the search boxes to complete the search.'));
              btnDisable = true;
          }else if (String.IsNotBlank(srchFNameNonEmp) && String.IsBlank(srchLNameNonEmp)){   
              searchNonEmpResult = [SELECT Email__c,First_Name__c,Last_Name__c,Operating_Group__c,Manager_Email__c,Manager_Name__c,Manager_Last_Name__c,Manager_First_Name__c,Id,Name,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c FROM TMN_User__c WHERE First_Name_Soundex_Key__c = :generatedKey2 ORDER BY Last_Name__c ASC];
              btnDisable = false;
                if(searchNonEmpResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The search did not find any possible matches. Please check the name and try again or Create a New Non-Employee.')); 
                }              
          }else if (String.IsBlank(srchFNameNonEmp) && String.IsNotBlank(srchLNameNonEmp)){
              searchNonEmpResult = [SELECT Email__c,First_Name__c,Last_Name__c,Operating_Group__c,Manager_Email__c,Manager_Name__c,Manager_Last_Name__c,Manager_First_Name__c,Id,Name,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c FROM TMN_User__c WHERE Last_Name_Soundex_Key__c = :generatedKey1 ORDER BY Last_Name__c ASC];
              btnDisable = false;
                if(searchNonEmpResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The search did not find any possible matches. Please check the name and try again or Create a New Non-Employee.')); 
                }              
          }else if (String.IsNotBlank(srchFNameNonEmp) && String.IsNotBlank(srchLNameNonEmp)){
              searchNonEmpResult = [SELECT Email__c,First_Name__c,Last_Name__c,Operating_Group__c,Manager_Email__c,Manager_Name__c,Manager_Last_Name__c,Manager_First_Name__c,Id,Name,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c FROM TMN_User__c WHERE Last_Name_Soundex_Key__c = :generatedKey1 OR First_Name_Soundex_Key__c = :generatedKey2 ORDER BY Last_Name__c ASC];
              btnDisable = false;
                if(searchNonEmpResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The search did not find any possible matches. Please check the name and try again or Create a New Non-Employee.')); 
                }              
          }
          return null;
      }
      
//    public void nonEmpSearch() {       
//        if (String.IsBlank(srchFNameNonEmp) && String.IsBlank(srchLNameNonEmp) && String.IsBlank(srchMngFNameNonEmp) && String.IsBlank(srchMngLNameNonEmp)) {
//            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter something into one of the search boxes to complete the search.'));
//            btnDisable = true;
//        } else if (srchFNameNonEmp.length()<3 && srchLNameNonEmp.length()<3 && srchMngFNameNonEmp.length()<3 && srchMngLNameNonEmp.length()<3) {
//            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter at least three characters in one of the search boxes to complete the search.'));
//            btnDisable = true;
//        } else {
//            String searchNonEmp='SELECT Email__c,First_Name__c,Last_Name__c,Operating_Group__c,Manager_Email__c,Manager_Name__c,Manager_Last_Name__c,Manager_First_Name__c,Id,Name FROM TMN_User__c WHERE First_Name__c LIKE \'%'+srchFNameNonEmp+'%\' AND Last_Name__c LIKE \'%'+srchLNameNonEmp+'%\' AND Manager_Last_Name__c LIKE \'%'+srchMngLNameNonEmp+'%\' AND Manager_First_Name__c LIKE \'%'+srchMngFNameNonEmp+'%\' ORDER BY Last_Name__c ASC LIMIT 200';
//            searchNonEmpResult = Database.query(searchNonEmp);
//            btnDisable = false;
//                if(searchNonEmpResult.isEmpty()) {
//                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The search did not find any possible matches! Please check the name and try again.')); 
//                }          
//            }
//        }

    Public void tmnSearch() {
        tmnUserList = New List<TMN_User__c>();
        if(tmnSearchStr.length() > 2) {
            String searchStr1 = tmnSearchStr+'*';
            String searchQuery = 'FIND\'' + searchStr1 + '\' IN NAME FIELDS RETURNING TMN_User__c(Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c,Delegate_For__c WHERE Operating_Group__c =\''+tmnOG+'\')';
            List<List <sObject>> searchList = search.query(searchQuery);
            tmnUserList = ((List<TMN_User__c>)searchList[0]);
            if(tmnUserList.size() == 0) {
                apexPages.addmessage(new apexpages.message(apexpages.severity.INFO, 'The search did not find any possible matches! Please check the name and try again.'));
            }
        } else {
            apexPages.addmessage(new apexpages.message(apexpages.severity.WARNING, 'Please enter at least three characters to search.'));
        }
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Care Meridian','Care Meridian'));
            options.add(new SelectOption('Corporate','Corporate'));
            options.add(new SelectOption('Cambridge','Hastings'));
            options.add(new SelectOption('NeuroRestorative','NeuroRestorative'));
            options.add(new SelectOption('Redwood','Redwood'));
            return options;
    }
    
    public String[] getoperatingGroups() {
        return operatingGroups;
    }
    
    public void setoperatingGroups(String[] operatingGroups) {
        this.operatingGroups = operatingGroups;
    }
    
}
//Script to update Soundex Keys
//List<TMN_User__c> tmnusers = [select id,name,Last_Name_Soundex_Key__c,First_Name_Soundex_Key__c 
//                              from TMN_User__c
//                              where Last_Name_Soundex_Key__c = null];
//for (TMN_User__c tu:tmnusers){
//    tu.Last_Name_Soundex_Key__c = Soundex.toSoundex(tu.Last_Name__c);
//    tu.First_Name_Soundex_Key__c = Soundex.toSoundex(tu.First_Name__c);
//}
//update tmnusers;