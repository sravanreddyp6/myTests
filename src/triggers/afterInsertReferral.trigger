trigger afterInsertReferral on Referral__c (after Insert,after update) {
    if(trigger.isInsert){
        Id NeuroRTId= Utility.getRecordTypeForReferral('NeuroRestorative');
        List<Referral_View__c> rv = new List<Referral_View__c>();
    
        for(Referral__c r: trigger.new){
            if(r.recordTypeId == NeuroRTId){
                rv.add(new Referral_View__c(name = r.name,referral_ID__c = r.id, contact_Id__c= r.target_org_contact_id__c,account_id__c=r.target_org_company_Id__c,status__c=r.referral_status__c));
            }
        } 
    
        if(!rv.isEmpty()){
            try{
                Database.Insert(rv,false);
            }catch(DmlException e){
        
            }
        }
    }
    
    if(trigger.isUpdate){
        Id NeuroRTId= Utility.getRecordTypeForReferral('NeuroRestorative');
        Set<String> chgdRIds = new Set<String>();
        List<Referral_View__c> rvs2Update = new List<Referral_View__c>(); 
        for(Referral__c r: trigger.new){
            if(r.recordTypeId == NeuroRTId && !(trigger.newMap.get(r.id).name == trigger.OldMap.get(r.id).name &&
               trigger.newMap.get(r.id).target_org_contact_id__c == trigger.OldMap.get(r.id).target_org_contact_id__c &&
               trigger.newMap.get(r.id).target_org_company_id__c == trigger.OldMap.get(r.id).target_org_company_id__c &&
               trigger.newMap.get(r.id).referral_status__c == trigger.OldMap.get(r.id).referral_status__c
            )){
                chgdRIds.add(r.id);
            }
        }
        
        for(Referral_View__c rv: [select referral_Id__c, name, account_Id__c, contact_id__c, status__c from referral_view__c where referral_ID__c in :chgdRIds]){
            rv.name = trigger.newMap.get((Id) rv.referral_Id__c).name;
            rv.account_Id__c = trigger.newMap.get((Id) rv.referral_Id__c).target_org_company_Id__c;
            rv.contact_Id__c = trigger.newMap.get((Id) rv.referral_Id__c).target_org_contact_Id__c;
            rv.status__c = trigger.newMap.get((Id) rv.referral_Id__c).referral_status__c;
            
            rvs2Update.add(rv);
        }
        
        if(!rvs2Update.IsEmpty()){
            try{
                update rvs2Update;
            }catch(DmlException e){
            
            }
        }
    }
}