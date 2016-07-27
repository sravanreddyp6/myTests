trigger PBSSoundExTrigger on Account (before insert, before update) {
    SoundExTriggerUtil util= new SoundExTriggerUtil();
    util.generateKeys(System.trigger.new);
}