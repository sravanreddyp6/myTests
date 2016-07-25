public with sharing class EvalResp_ShowAllList {
    public EvalResp_ShowAllList() {
		RWL1 = isRWL1();
    }	
    public list<string> getImmuneReqFields(){
      list<string> tmp = new list<string>();
      tmp.add('Allergy_Details__c');
      tmp.add('Life_Threatening__c');
      tmp.add('Date__c');
      tmp.add('Dosage__c');
      tmp.add('Vaccine_Type__c');
      tmp.add('Dosage_Number__c');
      tmp.add('Location__c');
      tmp.add('Lot__c');
      tmp.add('Expiration_Date__c');
      tmp.add('Administered_By__c');
      return tmp;
    } 
    
    public boolean RWL1 {get; set;}
    private Boolean isRWL1() {
        
        List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];        
        for ( PermissionSetAssignment p : userperms ) {
            if ( p.PermissionSet.Name.Equals('ESD_Notes_RW_Level_1') ) {
                return true;    
            }
        }
        return false;
    }     
}