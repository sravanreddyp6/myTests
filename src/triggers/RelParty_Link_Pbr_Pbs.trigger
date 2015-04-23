trigger RelParty_Link_Pbr_Pbs on Related_Party__c (before insert, before update) {

    for(Related_Party__c rp: trigger.new){
        if(rp.Person_Being_Referred__c == null && rp.IDofPBR_FromPBS__c != null){
            rp.Person_Being_Referred__c = rp.IDofPBR_FromPBS__c;
        }
        if(rp.Person_Being_Served__c == null && rp.IDofPBS_FromPBR__c != null){
            rp.Person_Being_Served__c = rp.IDofPBS_FromPBR__c;
        }
    }

}