/*
Created By     : Doug Surfleet (Appirio)
Updated Date   : April 24, 2013
Description    : Trigger for PersonBeingReferred object. Currently only handles populating/overridding Age field.
Update:
5/7/2013 by Doug Surfleet - added Soundex to trigger
*/
trigger PersonBeingReferred_Trigger on Person_Being_Referred__c (before insert, before update) {
	for(Person_Being_Referred__c pbr: trigger.new) {
       	PersonBeingReferred_TriggerHandler.UpdateAge(pbr);
    }
    
    SoundExTriggerUtil util= new SoundExTriggerUtil();
    util.generateKeys(System.trigger.new);
}