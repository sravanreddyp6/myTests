public with sharing class IdentityHomeController {

    public String srchFNameDel {get; set;}
    public String srchLNameDel {get; set;}
    public String srchFNameNonEmp {get; set;}
    public String srchLNameNonEmp {get; set;}
    public String tmnSearchStr {get; set;}
    public String generatedKey1 {get; set;}
    public String generatedKey2 {get; set;}
    public String aliasName {get; set;}
    public String getAliasName(){
        if(mySubordinates.isEmpty() && delegateFor.isEmpty()){
            aliasName = delegateFor[0].Delegate_for_Name__c;
        }else{
            aliasName = tmnName;
        }
        return aliasName;
    }   
    public List<TMN_User__c> Records {get; set;}
    public List<TMN_User__c> mySubordinates {get; set;}
    public List<TMN_User__c> searchResult {get; set;}
    public List<TMN_User__c> searchDelegateResult {get; set;}
    public List<TMN_User__c> searchNonEmpResult {get; set;}
    public List<TMN_User__c> tmnUserList {get; set;}
    public TMN_User__c theTMNUser {get; set;}
    public ID selectedID {get; set;}
    public Boolean displayPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    Date currentDate = Date.today();
    Date endDate = currentDate.addDays(30);
    
    String[] operatingGroups = new String[]{};
    String[] myId = new String[]{};
    
    User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    String userId = u.id;
    
    TMN_User__c t = [SELECT Id,Name,Operating_Group__c,Manager_Name__c,Email__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:userId LIMIT 1];
    public String tmnName = t.Name;
    public String tmnId = t.Id;
    public String tmnOG = t.Operating_Group__c;
    public String tmnEmail = t.Email__c;
    
    public IdentityHomeController() {
        Records = [SELECT Name,Email__c,Professional_Title__c,Job_Status__c,Current_Person_Type__c 
                   FROM TMN_User__c WHERE lastvieweddate != null ORDER BY lastvieweddate desc LIMIT 10];
                        
        mySubordinates = [SELECT Id FROM TMN_User__c WHERE Manager_Name__c=:tmnName];
        
        aliasName = getAliasName();
        
        delegateFor = [SELECT Delegate_for_Name__c,TMN_Delegate_For__c,Delegate_for_Email__c,Delegation_Complete__c
                       FROM TMN_User_Delegate__c 
                       WHERE TMN_Delegate_Name__c =:tmnId
                       AND Delegation_Complete__c = FALSE];
                                                                                                                    
    }

    List<TMN_User_Delegate__c> delegateFor;
    public List<TMN_User_Delegate__c> getDelegateFor(){
        delegateFor = [SELECT Delegate_for_Name__c,TMN_Delegate_For__c,Delegate_for_Email__c,Delegation_Complete__c
                       FROM TMN_User_Delegate__c 
                       WHERE TMN_Delegate_Name__c =:tmnId
                       AND Delegation_Complete__c = FALSE];
        return delegateFor;
    }

    List<TMN_User__c> attestNonEmployees;
    public List<TMN_User__c> getattestNonEmployees() {
        attestNonEmployees = [SELECT Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,
                   Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,
                   Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,
                   Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c,Last_Day__c,Current_Person_Type__c 
                   FROM TMN_User__c 
                   WHERE Manager_Name__c=:aliasName 
                   AND Current_Person_Type__c NOT IN ('Employee')
                   AND Last_Day__c<=:endDate ORDER BY Last_Day__c ASC];
        return attestNonEmployees;
    }
    
    List<TMN_User_Delegate__c> myDelegates;        
    public List<TMN_User_Delegate__c> getMyDelegates() {
        myDelegates = [SELECT Name,Time_Assigned__c,Delegate_for_Name__c 
                       FROM TMN_User_Delegate__c 
                       WHERE TMN_Delegate_For__c=:tmnId 
                       AND Delegation_Complete__c = FALSE];
        return myDelegates;
    }
    
    List<TMN_User__c> myEmployees;
    public List<TMN_User__c> getMyEmployees() {
        myEmployees = [SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c 
                       FROM TMN_User__c 
                       WHERE Manager_Name__c=:aliasName 
                       AND Current_Person_Type__c IN ('Employee') ];
        return myEmployees;    
    }
    
    List<TMN_User__c> myWorkforce;
    public List<TMN_User__c> getmyWorkforce() {
        myWorkforce = [SELECT Name,Email__c,Professional_Title__c,Job_Status__c,Current_Person_Type__c 
                       FROM TMN_User__c 
                       WHERE  Manager_Name__c=:aliasName
                       AND Job_Status__c IN ('Active','Pending')
                       ORDER BY Last_Name__c ASC];        
        return myWorkforce;
    }                           

    public List<SelectOption> getDelValues(){
        List<SelectOption> dl = new List<SelectOption>();
        if(mySubordinates.size()>0){
            dl.add(new SelectOption(tmnName,'Myself'));    
        }
        for(TMN_User_Delegate__c td:[SELECT Delegate_for_Name__c,TMN_Delegate_For__c FROM TMN_User_Delegate__c WHERE TMN_Delegate_Name__c =:tmnId AND Delegation_Complete__c = FALSE]){
            dl.add(new SelectOption(td.Delegate_for_Name__c,td.Delegate_for_Name__c));
        }
        return dl;
    }

//    String tmnMgrLName;
//    public String getTmnMgrLName() {
//        tmnMgrLName = t.Manager_Last_Name__c;
//        return tmnMgrLName;
//    }

//    String tmnMgrFName;
//    public String getTmnMgrFName() {
//        tmnMgrFName = t.Manager_First_Name__c;
//        return tmnMgrFName;
//    }

    String tmnAliasUsr;
    public String getTmnAliasUsr() {
        tmnAliasUsr = aliasName;
        return tmnAliasUsr;
    }

    Boolean isDelegate;
    public Boolean getIsDelegate() {
        if(delegateFor.size()<1){
            isDelegate = false;
        }else{
            isDelegate = true;
        } 
    return isDelegate;    
    }

    Boolean hasAccess;
    public Boolean getHasAccess() {
        if(mySubordinates.isEmpty() && delegateFor.isEmpty()){
            hasAccess = false;
        }else{
            hasAccess = true;
        }
        return hasAccess;
    }

    Boolean noAccess;
    public Boolean getNoAccess(){
        if(hasAccess == false){
            noAccess = true;
        }else{
            noAccess = false;
        }
        return noAccess;
    }

    Boolean hasSubs;
    public Boolean getHasSubs(){
        if(mySubordinates.isEmpty()){
            hasSubs = false;
        }else{
            hasSubs = true;
        }
        return hasSubs;
    }

    Boolean btnDisable = true;
    public Boolean getbtnDisable() {
        return btnDisable;
    }  

    public void removeDel() {
        TMN_User_Delegate__c userToRemove;
            try {
                userToRemove = [SELECT Id,Delegation_Complete__c,Time_Removed__c,TMN_Delegate_Name__c FROM TMN_User_Delegate__c WHERE Id=:selectedId LIMIT 1];
                userToRemove.Delegation_Complete__c = TRUE;
                userToRemove.Time_Removed__c = datetime.now();
                update userToRemove;
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage()));
            }
    }

    public void addDel() {
        TMN_User_Delegate__c userToAdd = new TMN_User_Delegate__c();
        List<TMN_User__c> userDel = [SELECT Id,Name,Email__c FROM TMN_User__c WHERE Id=:selectedId LIMIT 1];
        String delId = userDel[0].Id;
        String delName = userDel[0].Name;
        String delEmail = userDel[0].Email__c;
        List<TMN_User_Delegate__c> userDup = [SELECT Id FROM TMN_User_Delegate__c WHERE TMN_Delegate_For__c =:tmnId AND TMN_Delegate_Name__c =:delId AND Delegation_Complete__c = FALSE];
        if(delId==tmnId){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You cannot assign yourself as a delegate! Please choose another person as your delegate.'));
        }else if(userDup.size()>0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, delName +' is already assigned as one of your delegates! Please choose another person as your delegate.'));
        }else{    
            try { 
                userToAdd.Name = delName;      
                userToAdd.TMN_Delegate_Name__c = delId;
                userToAdd.Delegate_Email__c = delEmail;
                userToAdd.Delegate_for_Name__c = tmnName;
                userToAdd.TMN_Delegate_For__c = tmnId;
                userToAdd.Delegate_for_Email__c = tmnEmail;
                userToAdd.Time_Assigned__c = datetime.now();
                upsert (userToAdd);
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'An unexpected error has occurred: ' + e.getMessage()));
            }
        }             
    }         

      public void delSearch(){
          generatedKey1 = Soundex.toSoundex(srchLNameDel);
          generatedKey2 = Soundex.toSoundex(srchFNameDel);
          doQueryDel();
      }
      
      public PageReference doQueryDel(){
          if (String.IsBlank(srchFNameDel) && String.IsBlank(srchLNameDel)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter a first name, last name or both.'));
          }else if (srchFNameDel.length()<2 && srchLNameDel.length()<2){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter at least two characters in the first name or last name fields.'));
          }else if (String.IsNotBlank(srchFNameDel) && String.IsBlank(srchLNameDel)){   
              searchDelegateResult = [SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c,Prf_First_Name_Soundex_Key__c,Prf_Last_Name_Soundex_Key__c FROM TMN_User__c WHERE (First_Name_Soundex_Key__c = :generatedKey2 OR Prf_First_Name_Soundex_Key__c = :generatedKey2) AND Current_Person_Type__c IN ('Employee') ORDER BY Last_Name__c ASC];              
          }else if (String.IsBlank(srchFNameDel) && String.IsNotBlank(srchLNameDel)){
              searchDelegateResult = [SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c,Prf_First_Name_Soundex_Key__c,Prf_Last_Name_Soundex_Key__c FROM TMN_User__c WHERE (Last_Name_Soundex_Key__c = :generatedKey1 OR Prf_Last_Name_Soundex_Key__c = :generatedKey1) AND Current_Person_Type__c IN ('Employee') ORDER BY Last_Name__c ASC];                              
          }else if (String.IsNotBlank(srchFNameDel) && String.IsNotBlank(srchLNameDel)){
              searchDelegateResult = [SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c,Prf_First_Name_Soundex_Key__c,Prf_Last_Name_Soundex_Key__c FROM TMN_User__c WHERE (Last_Name_Soundex_Key__c = :generatedKey1 OR First_Name_Soundex_Key__c = :generatedKey2 OR Prf_Last_Name_Soundex_Key__c = :generatedKey1 OR Prf_First_Name_Soundex_Key__c = :generatedKey2) AND Current_Person_Type__c IN ('Employee') ORDER BY Last_Name__c ASC];
                if(searchDelegateResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Possible matches matches were found.')); 
                }              
          }
          return null;
      }       

      public void nonEmpSearch(){
          generatedKey1 = Soundex.toSoundex(srchLNameNonEmp);
          generatedKey2 = Soundex.toSoundex(srchFNameNonEmp);
          doQuery();
      }
      
      public PageReference doQuery(){
          if (String.IsBlank(srchFNameNonEmp) && String.IsBlank(srchLNameNonEmp)){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter a first name, last name or both.'));
              btnDisable = true;
          }else if (srchFNameNonEmp.length()<2 && srchLNameNonEmp.length()<2){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter at least two characters in the first name or last name fields.'));
              btnDisable = true;
          }else if (String.IsNotBlank(srchFNameNonEmp) && String.IsBlank(srchLNameNonEmp)){   
              searchNonEmpResult = [SELECT Name,Professional_Title__c,Manager_Name__c,Operating_Group__c,Current_Person_Type__c,Job_Status__c,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c,Prf_First_Name_Soundex_Key__c,Prf_Last_Name_Soundex_Key__c FROM TMN_User__c WHERE First_Name_Soundex_Key__c = :generatedKey2 OR Prf_First_Name_Soundex_Key__c = :generatedKey2 ORDER BY Hire_Date__c ASC];
              btnDisable = false;
              showPopup();
                if(searchNonEmpResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Possible matches matches were found. Click Create New Identity Record to create the new identity record.')); 
                }else if(searchNonEmpResult.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some potential matches have been found for the name you entered. If none of the results match the person you are trying to create, click Create New Identity Record to create the new identity record.'));
                }              
          }else if (String.IsBlank(srchFNameNonEmp) && String.IsNotBlank(srchLNameNonEmp)){
              searchNonEmpResult = [SELECT Name,Professional_Title__c,Manager_Name__c,Operating_Group__c,Current_Person_Type__c,Job_Status__c,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c,Prf_First_Name_Soundex_Key__c,Prf_Last_Name_Soundex_Key__c FROM TMN_User__c WHERE Last_Name_Soundex_Key__c = :generatedKey1 OR Prf_Last_Name_Soundex_Key__c = :generatedKey1 ORDER BY Hire_Date__c ASC];
              btnDisable = false;
              showPopup();
                if(searchNonEmpResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Possible matches matches were found. Click Create New Identity Record to create the new identity record.')); 
                }else if(searchNonEmpResult.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some potential matches have been found for the name you entered. If none of the results match the person you are trying to create, click Create New Identity Record to create the new identity record.'));
                }                              
          }else if (String.IsNotBlank(srchFNameNonEmp) && String.IsNotBlank(srchLNameNonEmp)){
              searchNonEmpResult = [SELECT Name,Professional_Title__c,Manager_Name__c,Operating_Group__c,Current_Person_Type__c,Job_Status__c,First_Name_Soundex_Key__c,Last_Name_Soundex_Key__c,Prf_First_Name_Soundex_Key__c,Prf_Last_Name_Soundex_Key__c FROM TMN_User__c WHERE Last_Name_Soundex_Key__c = :generatedKey1 OR First_Name_Soundex_Key__c = :generatedKey2 OR Prf_Last_Name_Soundex_Key__c = :generatedKey1 OR Prf_First_Name_Soundex_Key__c = :generatedKey2 ORDER BY Hire_Date__c ASC];
              btnDisable = false;
              showPopup();
                if(searchNonEmpResult.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Possible matches matches were found. Click Create New Identity Record to create the new identity record.')); 
                }else if(searchNonEmpResult.size()>0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some potential matches have been found for the name you entered. If none of the results match the person you are trying to create, click Create New Identity Record to create the new identity record.'));
                }              
          }
          return null;
      }      

      Public void tmnSearch() {
          tmnUserList = New List<TMN_User__c>();
          if(tmnSearchStr.length() > 2) {
              String searchStr1 = tmnSearchStr+'*';
              String searchQuery = 'FIND\'' + searchStr1 + '\' IN NAME FIELDS RETURNING TMN_User__c(Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c WHERE Operating_Group__c =\''+tmnOG+'\')';
              List<List <sObject>> searchList = search.query(searchQuery);
              tmnUserList = ((List<TMN_User__c>)searchList[0]);
                  if(tmnUserList.size() == 0) {
                      apexPages.addmessage(new apexpages.message(apexpages.severity.INFO, 'The search did not find any possible matches! Please check the name and try again.'));
                  }
          } else {
              apexPages.addmessage(new apexpages.message(apexpages.severity.WARNING, 'Please enter at least three characters to search.'));
          }
      }
      
      public PageReference newTmnUser() {
          PageReference pageRef = Page.identity_create;
          pageRef.getParameters().put('FN', srchFNameNonEmp);
          pageRef.getParameters().put('LN', srchLNameNonEmp);
          pageRef.getParameters().put('retURL', '/apex/identity_nonemployees');
          pageRef.getParameters().put('TAU',aliasName);
          return pageRef;
      }
      
      public void add30Days() {
          TMN_User__c userToExt;
          try {
                userToExt = [SELECT Id,Last_Day__c FROM TMN_User__c WHERE Id=:selectedId LIMIT 1];
                Date curLDate = userToExt.Last_Day__c;
                userToExt.Last_Day__c = curLDate.addDays(30);
                update userToExt;
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage()));
            }
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