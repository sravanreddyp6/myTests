trigger referralHighRiskTrigger on Referral__c (before insert, before update) {
    ReferralTrigger_Helper.markHighRisk(Trigger.isInsert, Trigger.new, Trigger.newMap, Trigger.oldMap);
}