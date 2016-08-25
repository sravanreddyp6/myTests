public with sharing class PBS_controller_helper {

    public PBS_Controller_Helper(ApexPages.standardController ctl){}

    @RemoteAction
    public static Diagnosis__c loadDiagnosis(string diagnosisId) {
            Diagnosis__c diagnosis =
                [select Id, Name, Type__c,Status__c,PBS__c,Effective_Date__c, createddate, ICD__c, ICD__r.Name
                 from Diagnosis__c where id = :diagnosisId];
            return diagnosis;
     }

    @RemoteAction
    public static Diagnosis__c saveDiagnosis(string diagnosisId, string diagnosisType, string status, string effectiveTime, string ICD, string PBSId) {
      Diagnosis__c diagnosis;
      if (String.isEmpty(diagnosisId)) {
        diagnosis = new Diagnosis__c(Type__c = diagnosisType, Status__c = status, ICD__c = ICD, PBS__c = PBSId );
      } else {
         diagnosis = new Diagnosis__c(ID = diagnosisId, Type__c = diagnosisType, Status__c = status,ICD__c = ICD, PBS__c = PBSId);
      }
      diagnosis.Effective_Date__c = (!String.isEmpty(effectiveTime)) ? Datetime.parse(effectiveTime) : (Datetime) null;
      upsert diagnosis;
      return diagnosis;
    }

    //Check whether there is an Active Service Assignment with an Active Diagnosis linked that the user trying to Inactivate
    @RemoteAction
    public static boolean preventDiagInactivation(string diagnosisId, string PBSId){
    	List<ServiceAssignment_Diagnosis_JO__c> dg = [SELECT Id FROM ServiceAssignment_Diagnosis_JO__c WHERE Diagnosis__c = :diagnosisId AND Service_Assignment__r.Status__c = 'Active' AND Service_Assignment__r.Person_being_served__c = :PBSId LIMIT 1];
    	return dg.size() > 0;
    }
     // calculation of whether user is allowed to make this change
        public static Boolean isUserLevel1or2() {

                List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];
                for ( PermissionSetAssignment p : userperms ) {

                        // user can only update if in one of these three permission sets
                        if ( p.PermissionSet.Name.Contains('Level_1') || p.PermissionSet.Name.Contains('Level_2') ) {
                                System.Debug('User is level1 or level2.');
                                return true;
                        }
                }
                return false;
        }

}