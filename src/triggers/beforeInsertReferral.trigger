trigger beforeInsertReferral on Referral__c (before insert) {
    ReferralTrigger_Helper.updateName(trigger.new);
}