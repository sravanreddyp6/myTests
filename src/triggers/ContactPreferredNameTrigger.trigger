/**
 * EIFB-27 - If the preferred first or last name is blank, use the regular first
 *		and/or last name to populate it.
 */
trigger ContactPreferredNameTrigger on Contact (before insert, before update) {

	ContactTriggerAction action = new ContactTriggerAction();
	
	action.onBeforeInsertUpdate(Trigger.new);	
    
}