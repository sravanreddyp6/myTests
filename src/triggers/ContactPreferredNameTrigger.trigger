/**
 * EIFB-27 - If the preferred first or last name is blank, use the regular first
 *		and/or last name to populate it.
 */
trigger ContactPreferredNameTrigger on Contact (before insert, before update) {
	
	Contact[] contacts = Trigger.new;
	
	for (Contact contact : contacts){
	    if (contact.Preferred_First_Name__c == '')
	    	contact.Preferred_First_Name__c = contact.FirstName;
	    
	    if (contact.Preferred_Last_Name__c == '')
	    	contact.Preferred_Last_Name__c = contact.LastName;
	}
	
    
}