trigger FundSrc_Link_SA_Ref on Funding_Source__c (before insert, before update) {

for(Funding_Source__c  funder: trigger.new){
    if(funder.IDofPBS_FromRef__c != null && funder.Service_Assignment__c == null){
        
        for(Service_Assignment__c sa :[select id from Service_Assignment__c where person_being_served__c = :funder.IDofPBS_FromRef__c and Status__c ='active' Order By CreatedDate Limit 1] ){
            funder.Service_Assignment__c = sa.id;
        }
    }
    
    if(funder.IDofPBS_FromSA__c != null && funder.Referral__c == null){
        for(referral__c  ref: [select id from referral__c where person_being_served__c = :funder.IDofPBS_FromSA__c order by createddate limit 1]){
          funder.referral__c = ref.id;  
        }
        
    }

}
}