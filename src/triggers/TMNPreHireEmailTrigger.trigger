trigger TMNPreHireEmailTrigger on TMN_User__c (after insert) {

TMN_User__c[] preHireList = Trigger.new;
    identityEditNew.sendPreHireEmail(preHireList);
}