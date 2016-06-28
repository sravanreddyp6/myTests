trigger TMN_UserSoundexTrigger on TMN_User__c (before insert, before update) {
	SoundExTriggerUtil util = new SoundExTriggerUtil();
    util.generateKeys(System.trigger.new);
}