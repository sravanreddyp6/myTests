trigger Agency_Link_Ref_Pbs on Agency_Involved_With_Individual__c (before insert, before update) {

for(Agency_Involved_With_Individual__c agn: trigger.new){
    if(agn.Referral__c == null){
        for(Referral__c  ref: [select id from Referral__c Where Person_Being_Referred__c = :agn.IDofPBR_FromPBS__c Order By CreatedDate Desc limit 1 ] ){
            agn.Referral__c = ref.id;
        }
        
    }
    if(agn.Person_Being_Served__c == null){
        agn.Person_Being_Served__c = agn.IDofPBS_FromRef__c;
    }

}
    

}