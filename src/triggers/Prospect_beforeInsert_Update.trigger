trigger Prospect_beforeInsert_Update on Prospects__c (before insert, before update) {
   For (Prospects__c P : trigger.new){
    if(p.Provider_Agreement_Signature_Date__c != null){
        p.Status__c = 'Mentor';
    
    }
   }

}