public with sharing class AssessmentControllerExtension {

   
    public String message {get;set;}
    public integer countOfAnswersExpected {get;set;}
    public Boolean unlockAllowed {get;set;}
    public Boolean disregardAllowed {get;set;}
    
    private final Assessment__c assmt;
    
    public AssessmentControllerExtension(ApexPages.StandardController stdController) {
        this.assmt = (Assessment__c)stdController.getRecord();
        //List<Assessment_Question__c> countOfAnswersQuery = [SELECT Id FROM Assessment_Question__c WHERE Assessment_Type__c = :this.assmt.Assessment_Type__c];
        //countOfAnswersExpected = countOfAnswersQuery.size();
        //system.debug('countOfAnswersExpected: ' + countOfAnswersExpected);
        unlockAllowed = IsUnlockAllowed(this.assmt);   
        disregardAllowed = isDisregardAllowed(this.assmt);        
    }  
    
    public PageReference SaveAndLock(){
        PageReference pgRef = new PageReference('/' + assmt.Admission__r.Id);
 
                Savepoint sp = Database.setSavepoint();
 
          try{       
            assmt.Locked__c = true;
            if(assmt.Status__c == 'Locked'){
                // Do nothing...popup?
            }
            else {
                assmt.Status__c = 'Locked';
            }
            if(Test.isRunningTest() == true && assmt.Name == 'TEST ASSMT2'){
                // REMOVE A REQUIRED FIELD TO CAUSE ERROR TO OCCUR IF THIS IS A TEST...
                assmt.TFC_Family_Vistas__c = null;
            }
            upsert assmt;
            return pgRef;
          }
          catch(DMLException e){
                assmt.Locked__c = false;
                ApexPages.addMessages(e);
                string varForLinkAssmtId = assmt.Id;
                string newLinkVar = varForLinkAssmtId.substring(0,15);
                PageReference pgRef2 = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/apex/AssessmentSubmitError?link='+newLinkVar);
                return pgRef2 ;
          }
          
          return null;
        
    }
    
    public PageReference Unlock(){
        
        
        PageReference pgRef = new PageReference('/' + assmt.Admission__r.Id);
        
        try{
              if(assmt.Locked__c == true){
                assmt.Locked__c = false;
                assmt.Status__c = 'Re-opened';
                upsert assmt;
                return pgRef;
              }
        }
        catch(Exception e){
                ApexPages.addMessages(e);
        }
        
        return null;

    }
    
    public Boolean IsUnlockAllowed(Assessment__c assmt){
        if(IsUnlockAllowed_SecondCheck()){
            return true;
        }

        Boolean unlockAllowed = false;
        
        ESD_DetermineParentRoles parentRoleIds = new ESD_DetermineParentRoles(assmt.OwnerId);
        for(Id thisRole : parentRoleIds.allParents){
            if(thisRole == UserInfo.getUserRoleId() ){
                unlockAllowed = true;
            }
        }
        
        return unlockAllowed;
        
    }
    public boolean IsUnlockAllowed_SecondCheck(){
        boolean inScope = false;
       List<PermissionSetAssignment> userperms = [ select id, permissionset.Name , assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];
         
        for ( PermissionSetAssignment p : userperms ) {                        
            // user can only update if in one of these three permission sets
            system.debug('set = ' + p.PermissionSet.Name);
            if ( p.PermissionSet.Name == 'ESD_Notes_Supervisor' ) {
                inScope = true;
            }        
        
        }
        if(inScope){
                if(!Test.isRunningTest()){
                    User u = [SELECT UserRoleId FROM User WHERE Id = :assmt.OwnerId];
                    
                    if(u.UserRoleId  == UserInfo.getUserRoleId()){
                        return true;
                    }
                }  
                
                if(UserInfo.getUserId() == assmt.OWNERID){
                    return true;    
                }  

        }
                
    
    
        return false;
    }
  
    // calculation of whether user is allowed to make this change
    public Boolean isDisregardAllowed(Assessment__c assmt) {
        
        List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()]; 
        for ( PermissionSetAssignment p : userperms ) {
            
            // user can only update if in one of these three permission sets
            if (
                p.PermissionSet.Name.Contains('ESD_Notes_Supervisor') || 
                p.PermissionSet.Name.Contains('ESD_Notes_Case_Handler')  ||
                ( p.PermissionSet.Name.Contains('ESD_Notes_Clinical_Data_User') && assmt.OwnerID == UserInfo.getUserId()) ||
                ( p.PermissionSet.Name.Contains('ESD_Assessments_Only') && assmt.OwnerID == UserInfo.getUserId()) ) {
                System.Debug('User is allowed.');
                return true;    
                }
        }
        return false;
    }
      
    // updates the billable flag on the record then redirects to detail view of Progress Note
    public PageReference setDisregard () {
        
            assmt.Disregard__c = true;
            update assmt;
            System.Debug('turned on disregard: ' + assmt);
            return new PageReference('/' + assmt.Id);
    }
      
      
    
}