public with sharing class IdentityHomeController {

    public String srchFNameDel {get; set;}
    public String srchLNameDel {get; set;}
    public String srchFNameNonEmp {get; set;}
    public String srchLNameNonEmp {get; set;}
    public String tmnSearchStr {get; set;}
    public String generatedKey1 {get; set;}
    public String generatedKey2 {get; set;}
    public String aliasName {get; set;}  
    public List<TMN_User__c> Records {get; set;}
    public List<TMN_User__c> mySubordinates {get; set;}
    public List<TMN_User__c> searchResult {get; set;}
    public List<TMN_User__c> searchDelegateResult ;
    public List<TMN_User__c> searchNonEmpResult ;
    public List<TMN_User__c> tmnUserList {get; set;}
    public List<TMN_User_Delegate__c> myDelegation {get; set;}
    public List<PermissionSetAssignment> hasRecruiter {get; set;}
    public TMN_User__c theTMNUser {get; set;}
    public ID selectedID {get; set;}
    public Boolean displayPopup {get; set;}
    public Boolean displayDelSrch {get; set;}   
    private Integer totalRecsNE = 0;
    private Integer offsetSizeNE = 0;
    private Integer limitSizeNE = 10;
    private Integer totalRecsDel = 0;
    private Integer offsetSizeDel = 0;
    private Integer limitSizeDel = 10;
    @testVisible  private String searchType{set;get;}
	@testVisible private String tmlUserQuery;
	@testVisible private Integer noOfRecords {get;set;}
    public List<Attachment> attachments {get; set;}
    Date currentDate = Date.today();
    Date endDate = currentDate.addDays(30);
    
    String[] myId = new String[]{};
    
    User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    String userId = u.id;
    
    TMN_User__c t = [SELECT Id,Name,Operating_Group__c,Manager_Name__c,Email__c 
                     FROM TMN_User__c 
                     WHERE Salesforce_User_Account__c=:userId 
                     LIMIT 1];
                     
    public String tmnName = t.Name;
    public String tmnId = t.Id;
    public String tmnOG = t.Operating_Group__c;
    public String tmnEmail = t.Email__c;                          
    public Boolean onloadDialog {set;get;}
    public IdentityHomeController() {
       searchDelegateResult = new List<TMN_User__c> (); 
        searchNonEmpResult = new List<TMN_User__c> (); 
        Records = [SELECT Name,Email__c,Professional_Title__c,Job_Status__c,Current_Person_Type__c 
                   FROM TMN_User__c 
                   WHERE lastvieweddate != null 
                   ORDER BY lastvieweddate desc 
                   LIMIT 10];
        System.debug('Records Count is ' + Records.size());
                        
        mySubordinates = [SELECT Id 
                          FROM TMN_User__c 
                          WHERE Manager_Email__c=:tmnEmail];
        System.debug('mySubordinates Count is ' + mySubordinates.size());

        myDelegation = [SELECT Delegate_for_Name__c,TMN_Delegate_For__c,Delegate_for_Email__c,Delegation_Complete__c
                        FROM TMN_User_Delegate__c 
                        WHERE TMN_Delegate_Name__c =:tmnId
                        AND Delegation_Complete__c = FALSE
                        LIMIT 1];
        System.debug('myDelegation Count is ' + myDelegation.size());
        
        hasRecruiter = [SELECT PermissionSetId,PermissionSet.Name 
                        FROM PermissionSetAssignment WHERE assignee.Id = :userId 
                        AND PermissionSet.Name = 'TMNAccess_Recruiter' 
                        LIMIT 1];
        System.debug('hasRecruiter count is ' + hasRecruiter.size());
                      
        aliasName = getAliasNameValue();
        System.Debug('Value of aliasName is ' + aliasName);      
        List<SelectOption> dl=getDelValues();
         	if(dl.size()>1){
             onloadDialog = true;
        	}else{
            onloadDialog = false;
        	} 
        	
        	if(ApexPages.currentPage().getParameters().get('cancel')!=null){
        	onloadDialog = false;
        	}    
                                                                                                                                                                                                         
    }

    //Standard Default Edit page
    Public PageReference stdEditPage(){
        PageReference ePage = new PageReference('/'+selectedID+'/e?retURL=/apex/identity_admin');
        return ePage;
    }
	
	Public PageReference selectDelegate(){
        System.debug('aliasName:' + aliasName);
        return null;
    }
    
    // Method used to set aliasName value on page load.
    String aliasNameValue; 
    String getAliasNameValue(){
        if(mySubordinates.isEmpty()){
            if(myDelegation.isEmpty()){
                aliasNameValue = tmnEmail;
            }else{
                TMN_User_Delegate__c ud = [SELECT Delegate_for_Name__c,TMN_Delegate_For__c,Delegate_for_Email__c,Delegation_Complete__c
                                   FROM TMN_User_Delegate__c 
                                   WHERE TMN_Delegate_Name__c =:tmnId
                                   AND Delegation_Complete__c = FALSE
                                   LIMIT 1];
                aliasNameValue = ud.Delegate_for_Email__c;
            }
        }else{
            aliasNameValue = tmnEmail;
        }
        System.debug('Value of aliasNameValue is ' + aliasNameValue);
        return aliasNameValue;
    }
    
    //Get list of people the user is assigned delegation rights for.
    List<TMN_User_Delegate__c> delegateFor;
    public List<TMN_User_Delegate__c> getDelegateFor(){
        delegateFor = [SELECT Delegate_for_Name__c,TMN_Delegate_For__c,Delegate_for_Email__c,Delegation_Complete__c
                       FROM TMN_User_Delegate__c 
                       WHERE TMN_Delegate_Name__c =:tmnId
                       AND Delegation_Complete__c = FALSE];
        return delegateFor;
    }


    //Get list of assigned delegates for the user.    
    List<TMN_User_Delegate__c> myDelegates;        
    public List<TMN_User_Delegate__c> getMyDelegates() {
        myDelegates = [SELECT Name,Time_Assigned__c,Delegate_for_Name__c 
                       FROM TMN_User_Delegate__c 
                       WHERE TMN_Delegate_For__c=:tmnId 
                       AND Delegation_Complete__c = FALSE];
        return myDelegates;
    }
    
    // Get list of direct reports who are employees for user.
    List<TMN_User__c> myEmployees;
    public List<TMN_User__c> getMyEmployees() {
        myEmployees = [SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c,Salesforce_User_Account__c 
                       FROM TMN_User__c 
                       WHERE Manager_Email__c=:aliasName 
                       AND Current_Person_Type__c IN ('Employee')
                       AND Job_Status__c IN ('Active') ];
        return myEmployees;
    }
    
    //Get list of all direct reports for user.
    List<TMN_User__c> myWorkforce;
    public List<TMN_User__c> getmyWorkforce() {
        myWorkforce = [SELECT Name,Email__c,Professional_Title__c,Job_Status__c,Current_Person_Type__c 
                       FROM TMN_User__c 
                       WHERE  Manager_Email__c=:aliasName
                       AND Job_Status__c IN ('Active','Pending')
                       ORDER BY Last_Name__c ASC];        
        return myWorkforce;
    }                           

    //Build select option list for creation of TMN_User__c records on behalf of.
    public List<SelectOption> getDelValues(){
        List<SelectOption> dl = new List<SelectOption>();
        if(mySubordinates.size()>=0){
            dl.add(new SelectOption(tmnEmail,'Myself'));    
        }
        for(TMN_User_Delegate__c td:[SELECT name,Delegate_Email__c,Delegate_for_Name__c,TMN_Delegate_For__c,Delegate_for_Email__c FROM TMN_User_Delegate__c WHERE TMN_Delegate_Name__c =:tmnId AND Delegation_Complete__c = FALSE]){
            dl.add(new SelectOption(td.Delegate_for_Email__c,td.Delegate_for_Name__c));
        }
        if( dl.size()>1){
             dl.add(0,new SelectOption('',''));
        }
        return dl;
    }
    
    //Get current aliasUser value for passing parameters to IdentityEditNew controller.
    String tmnAliasUsr;
    public String getTmnAliasUsr() {
        tmnAliasUsr = aliasName;
        return tmnAliasUsr;
    }

    //Boolean value to show if someone is a delegate. Used to conditionally render page panels.
    Boolean isDelegate;
    public Boolean getIsDelegate() {
        if(myDelegation.isEmpty()){
            isDelegate = false;
        }else{
            isDelegate = true;
        } 
    return isDelegate;    
    }

    //Boolean value to show if someone should see any output on the page. Used to conditionally render page panels.
    Boolean hasAccess;
    public Boolean getHasAccess() {
        if(mySubordinates.isEmpty() && myDelegation.isEmpty()){
                if(hasRecruiter.isEmpty()){
                    hasAccess = false;
                }else{
                    hasAccess = true;
                }
        }else{
            hasAccess = true;
        }
        return hasAccess;
    }

    //Used to conditionally render page panel for users with hasAccess equal to false.
    Boolean noAccess;
    public Boolean getNoAccess(){
        if(hasAccess == false){
            noAccess = true;
        }else{
            noAccess = false;
        }
        return noAccess;
    }

    //Used to conditionally render link to delegation management.
    Boolean hasSubs;
    public Boolean getHasSubs(){
        if(mySubordinates.isEmpty()){
            hasSubs = false;
        }else{
            hasSubs = true;
        }
        return hasSubs;
    }

    Boolean isRecruiter;
    public Boolean getIsRecruiter(){
        if(hasRecruiter.isEmpty()){
            isRecruiter = false;
        }else{
            isRecruiter = true;
        }
        return isRecruiter;    
    }

    Boolean btnDisable = true;
    public Boolean getbtnDisable() {
        return btnDisable;
    }  

    //Method to remove delegate assignment.
    public void removeDel() {
        TMN_User_Delegate__c userToRemove;
            try {
                userToRemove = [SELECT Id,Delegation_Complete__c,Time_Removed__c,TMN_Delegate_Name__c FROM TMN_User_Delegate__c WHERE Id=:selectedId LIMIT 1];
                userToRemove.Delegation_Complete__c = TRUE;
                userToRemove.Time_Removed__c = datetime.now();
                update userToRemove;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'The delegate has been successfully removed.'));
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage()));
            }
    }

    //Method to add a delegate.
    public void addDel() {
        TMN_User_Delegate__c userToAdd = new TMN_User_Delegate__c();
        List<TMN_User__c> userDel = [SELECT Id,Name,Email__c FROM TMN_User__c WHERE Id=:selectedId LIMIT 1];
        String delId = userDel[0].Id;
        String delName = userDel[0].Name;
        String delEmail = userDel[0].Email__c;
        List<TMN_User_Delegate__c> userDup = [SELECT Id FROM TMN_User_Delegate__c WHERE TMN_Delegate_For__c =:tmnId AND TMN_Delegate_Name__c =:delId AND Delegation_Complete__c = FALSE];
        List<TMN_User_Delegate__c> delCount = [SELECT Id FROM TMN_User_Delegate__c WHERE TMN_Delegate_For__c =:tmnId AND Delegation_Complete__c = FALSE];
        srchFNameDel = null;
        srchLNameDel = null;
        totalRecsDel = 0;
        offsetSizeDel = 0;
        closeDelSrch();
        if(delId==tmnId){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You cannot assign yourself as a delegate! Please choose another person as your delegate.'));
        }else if(userDup.size()>0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, delName +' is already assigned as one of your delegates! Please choose another person as your delegate.'));
        }else if(delCount.size()>0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You have the maximum allowed number of delegates! Please remove a current delegate to add ' + delName +'.'));
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'The delegate has been successfully added.'));
            } catch(DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'An unexpected error has occurred: ' + e.getMessage()));
            }
        }           
    }         

    //Method for delegate search.
    public void delSearch(){
        generatedKey1 = srchLNameDel;
        generatedKey2 = srchFNameDel;
        doQueryDel();
        showDelSrch();
    }
    
     public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null && tmlUserQuery!=null){
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(tmlUserQuery));
                setCon.setPageSize(limitSizeDel);
                noOfRecords = setCon.getResultSize();
            if(noOfRecords == 0 && searchType.equals('Delegate') ) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Possible matches matches were found.')); 
            } else if(noOfRecords == 0 && searchType.equals('Non-employee')) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Possible matches matches were found. Click Create Non Employee Record to create the Non Employee record.')); 
            }else if(noOfRecords > 0 && searchType.equals('Non-employee')){
       			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some potential matches have been found for the name you entered. If none of the results match the person you are trying to create, click Create New Identity Record to create the new identity record.'));
              }  
           }     
            return setCon;
        }set;
    }
	Public List<TMN_User__c> getsearchDelegateResult(){
        List<TMN_User__c> Tlist = new List<TMN_User__c>();
        if(setCon!=null){
        for(TMN_User__c t : (List<TMN_User__c>)setCon.getRecords()){
            Tlist.add(t);
        }
        }    
        return Tlist;
    }
    
    	Public List<TMN_User__c> getsearchNonEmpResult(){
        List<TMN_User__c> Tlist = new List<TMN_User__c>();
            if(setCon!=null){
        for(TMN_User__c t : (List<TMN_User__c>)setCon.getRecords()){
            Tlist.add(t);
        }
        }        
        return Tlist;
    }

    //Delegate search      
    public PageReference doQueryDel(){
        searchType = 'Delegate';
    	setCon = null;
        searchDelegateResult.clear();
        if (String.IsBlank(srchFNameDel) && String.IsBlank(srchLNameDel)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter a first name, last name or both.'));
            return null;
        }else if (srchFNameDel.length()<2 && srchLNameDel.length()<2){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter at least two characters in the first name or last name fields.'));
            return null;
        }else if (String.IsNotBlank(srchFNameDel) && String.IsBlank(srchLNameDel)){
            tmlUserQuery = 'SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Preferred_Last_Name__c,Salesforce_User_Account__c  FROM TMN_User__c '; 
            tmlUserQuery += ' WHERE (First_Name__c like \'%'+  generatedKey2 +'%\' OR Preferred_First_Name__c like \'%'+   generatedKey2 +'%\') ';
            tmlUserQuery += '  AND (Current_Person_Type__c IN (\'Employee\') AND Job_Status__c IN (\'Active\')) ';
            tmlUserQuery +=  '  ORDER BY First_Name__c,Last_Name__c';
        }else if (String.IsBlank(srchFNameDel) && String.IsNotBlank(srchLNameDel)){
            tmlUserQuery =  'SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Preferred_Last_Name__c,Salesforce_User_Account__c   FROM TMN_User__c'; 
            tmlUserQuery += ' WHERE (Last_Name__c like \'%'+ generatedKey1 +'%\' OR Preferred_Last_Name__c like \'%'+ generatedKey1 +'%\') ';  
            tmlUserQuery += ' AND (Current_Person_Type__c IN (\'Employee\') AND Job_Status__c IN (\'Active\')) ORDER BY First_Name__c,Last_Name__c';
        }else if (String.IsNotBlank(srchFNameDel) && String.IsNotBlank(srchLNameDel)){
            tmlUserQuery = 'SELECT Name,Email__c,Professional_Title__c,Manager_Name__c,Operating_Group__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Preferred_Last_Name__c,Salesforce_User_Account__c  FROM TMN_User__c';
            tmlUserQuery +=' WHERE ((Last_Name__c like \'%'+  generatedKey1 +'%\' AND First_Name__c like \'%'+  generatedKey2 +'%\') ';
            tmlUserQuery +=' OR (Preferred_Last_Name__c like \'%'+  generatedKey1 +'%\' AND Preferred_First_Name__c like \'%'+  generatedKey2 +'%\') ';
            tmlUserQuery +=' OR (Last_Name__c like \'%'+  generatedKey1 +'%\' AND Preferred_First_Name__c like \'%'+ generatedKey2 +'%\')'; 
            tmlUserQuery +=' OR (Preferred_Last_Name__c like \'%'+ generatedKey1 +'%\' AND First_Name__c like \'%'+ generatedKey2 +'%\')) ';
            tmlUserQuery +=' AND (Current_Person_Type__c IN (\'Employee\') AND Job_Status__c IN (\'Active\'))  ORDER BY First_Name__c,Last_Name__c' ;
        }
        return null;
    }       

    //Clear delegate search
    public void clearDelSrch(){
        srchFNameDel = null;
        srchLNameDel = null;
        searchDelegateResult.clear();
    }

    //Method for non-employee search
    public void nonEmpSearch(){
        generatedKey1 = srchLNameNonEmp;
        generatedKey2 = srchFNameNonEmp;
        doQuery();
    }
   
    //Non-employee search.      
    public PageReference doQuery(){
        searchType = 'Non-employee';
        setCon = null;
        searchNonEmpResult.clear();
        if (String.IsBlank(srchFNameNonEmp) && String.IsBlank(srchLNameNonEmp)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter a first name, last name or both.'));
            btnDisable = true;
        }else if (srchFNameNonEmp.length()<2 && srchLNameNonEmp.length()<2){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must enter at least two characters in the first name or last name fields.'));
            btnDisable = true;
        }else if (String.IsNotBlank(srchFNameNonEmp) && String.IsBlank(srchLNameNonEmp)){
             tmlUserQuery  = 'SELECT Name,Professional_Title__c,Manager_Name__c,Operating_Group__c,Current_Person_Type__c,Job_Status__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Preferred_Last_Name__c FROM TMN_User__c '; 
            tmlUserQuery += ' WHERE (First_Name__c like \'%'+  generatedKey2 +'%\' OR Preferred_First_Name__c like \'%'+ generatedKey2 +'%\')'; 
            tmlUserQuery += '  ORDER BY Last_Name__c,First_Name__c';
            btnDisable = false;
            showPopup();
        }else if (String.IsBlank(srchFNameNonEmp) && String.IsNotBlank(srchLNameNonEmp)){
             tmlUserQuery = 'SELECT Name,Professional_Title__c,Manager_Name__c,Operating_Group__c,Current_Person_Type__c,Job_Status__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Preferred_Last_Name__c  FROM TMN_User__c '; 
             tmlUserQuery += ' WHERE (Last_Name__c like \'%'+ generatedKey1 +'%\' OR Preferred_Last_Name__c like \'%'+  generatedKey1 +'%\') ';
             tmlUserQuery += '  ORDER BY Last_Name__c,First_Name__c ';
            btnDisable = false;
           showPopup();
        }else if (String.IsNotBlank(srchFNameNonEmp) && String.IsNotBlank(srchLNameNonEmp)){
             tmlUserQuery  = 'SELECT Name,Professional_Title__c,Manager_Name__c,Operating_Group__c,Current_Person_Type__c,Job_Status__c,First_Name__c,Last_Name__c,Preferred_First_Name__c,Preferred_Last_Name__c FROM TMN_User__c '; 
             tmlUserQuery += ' WHERE ((Last_Name__c like \'%'+  generatedKey1 +'%\' AND First_Name__c like \'%'+ generatedKey2 +'%\') '; 
             tmlUserQuery += ' OR (Preferred_Last_Name__c like \'%'+ generatedKey1 +'%\' AND Preferred_First_Name__c like \'%'+ generatedKey2 +'%\')'; 
             tmlUserQuery += ' OR (Last_Name__c like \'%'+ generatedKey1 +'%\' AND Preferred_First_Name__c like \'%'+  generatedKey2 +'%\') ';
             tmlUserQuery += ' OR (Preferred_Last_Name__c like \'%'+ generatedKey1 +'%\' AND First_Name__c like \'%'+  generatedKey2 +'%\'))  ORDER BY Last_Name__c,First_Name__c';
            btnDisable = false;
        	showPopup();
        }
        onloadDialog = false;
        return null;
    }      

      // SOSL Search for TMN_Users on identity_admin page. 
      //Currently not used, but didn't want to remove in case of changes in requirements to bring it back.
    Public void tmnSearch() {
        tmnUserList = New List<TMN_User__c>();
        if(tmnSearchStr.length() > 2) {
            String searchStr1 = tmnSearchStr+'*';
            String searchQuery = 'FIND\'' + searchStr1 + '\' IN NAME FIELDS RETURNING TMN_User__c(Email__c,Employee_Number__c,Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Status__c,Job_Title__c,Last_Name__c,Manager_Email__c,Manager_Name__c,Name,Network_Username__c,Operating_Group__c,Pay_Basis__c,Personal_Email__c,Salesforce_User_Account__c,Unique_Id__c,Work_State__c)';
            List<List <sObject>> searchList = search.query(searchQuery);
            tmnUserList = ((List<TMN_User__c>)searchList[0]);
                if(tmnUserList.size() == 0) {
                    apexPages.addmessage(new apexpages.message(apexpages.severity.INFO, 'The search did not find any possible matches! Please check the name and try again.'));
                }
        } else {
            apexPages.addmessage(new apexpages.message(apexpages.severity.WARNING, 'Please enter at least three characters to search.'));
        }
    }

    //Set parameters to pass to identityEditNew controller for record creation.      
    public PageReference newTmnUser() {
        totalRecsNE = 0;
        offsetSizeNE = 0;
        PageReference pageRef = Page.identity_create;
        pageRef.getParameters().put('FN', srchFNameNonEmp);
        pageRef.getParameters().put('LN', srchLNameNonEmp);
        pageRef.getParameters().put('retURL', '/apex/identity_nonemployees');
        pageRef.getParameters().put('TAU',aliasName);
        return pageRef;
    }

    //Add 30 days to end date for employee attestation Removed from Page     
//    public void add30Days() {
//        TMN_User__c userToExt;
//        try {
//              userToExt = [SELECT Id,Last_Day__c FROM TMN_User__c WHERE Id=:selectedId LIMIT 1];
//              Date curLDate = userToExt.Last_Day__c;
//              userToExt.Last_Day__c = curLDate.addDays(30);
//              update userToExt;
//          } catch(DmlException e) {
//              System.debug('An unexpected error has occurred: ' + e.getMessage());
//              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Error: ' + e.getMessage()));
//          }
//    } 

    //Popups show and close methods
    public void closePopup() {
        totalRecsNE = 0;
        offsetSizeNE = 0;
        srchFNameNonEmp = null;
        srchLNameNonEmp = null;        
        displayPopup = false;    
        onloadDialog = false;
        ApexPages.getMessages().clear();
    } 
        
    public void showPopup() {        
        displayPopup = true;    
    }

    public void showDelSrch(){
        displayDelSrch = true;
    }

    public void closeDelSrch(){
        displayDelSrch = false;
    }

    public Boolean displayInfo {get; set;}
    public void showInfo(){
        displayInfo = true;
    }
    public void closeInfo(){
        displayInfo = false;
    }

    //View TMN User Record
    public PageReference viewTmnUser(){
        theTMNUser = [SELECT Accountable_Approval_Manager__c,Accountable_Manager_Mentor_Email__c,Alias__c,Approval_Level__c,
                            Business_Unit_Region__c,Business_Unit__c,Current_Person_Type__c,Email__c,Employee_Number__c,
                            Employee_Type__c,First_Name__c,Hire_Date__c,Id,Job_Level__c,Job_Status__c,Job_Title__c,Identity_ID__c,
                            Last_Day__c,Last_Name__c,Manager_Email__c,Manager_First_Name__c,Manager_Last_Name__c,Manager_Name__c,
                            Mentor_Cell_Phone__c,Middle_Name__c,Name,Network_Username__c,Office_Location__c,Office_Phone__c,
                            Operating_Group__c,Pay_Basis__c,Personal_Email__c,Personal_Phone__c,Salesforce_User_Account__c,
                            Service_Line__c,Service_Region__c,Suppress_External_Update__c,Termination_Date__c,Teleo_ID__c,
                            Unique_Id__c,Work_State_Code__c,Work_State__c,Preferred_First_Name__c,Preferred_Last_Name__c,Manager_Lookup__c,Program_String__c ,
                            Work_City__c,Zip_Code__c,Professional_Title__c,Location_Name__c,Office_Location_2__c,Work_County__c, Office_Location_PickList__c,
                            BAA_Signed__c,Vendor_Name__c ,Vendor_list__c,Job_Code__c,Recruiter_Name__c,Recruiter_Email_Address__c,Custodians__c,office_flag__c,Pre_Hire_ID__c
                            FROM TMN_User__c 
                            WHERE Id =:selectedID];    
        attachments=[select Id, ParentId, Name, Description,CreatedDate,Owner.Name, OwnerID from Attachment where parentId=:theTMNUser.id order by createddate desc];               
        showInfo();
        onloadDialog = false;
        return null;
    }

 public Boolean hasNext {
        get {
            if(setCon!=null){
            return setCon.getHasNext();
            }
            return false;
        }
        set;
    }
    public Boolean hasPrevious {
        get {
             if(setCon!=null){
            return setCon.getHasPrevious();
            }
            return false;     
        }
        set;
    }
  
   
    public void previous() {
        if(setCon!=null){
            setCon.previous();
        }    
    }
  
    public void next() {
        if(setCon!=null){
        setCon.next();
        }      
    }
        
     public void first() {
         if(setCon!=null){
        setCon.first();
         }      
    }
  
    public void last() {
        if(setCon!=null){
        setCon.last();
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