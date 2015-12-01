public with sharing class EvalResp_ShowAllList {
    public EvalResp_ShowAllList() {

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
}