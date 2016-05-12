/**
 * Trigger handler class for contacts preferred name trigger.
 */
public with sharing class ContactTriggerAction {
	
	/**
	 * Method invoked for either the before insert or before update event to 
	 * ensure that preferred name fields are correctly populated.
	 */
	public void onBeforeInsertUpdate(Contact[] contacts) {
		
		system.debug('contact count=' + contacts.size());
		
		for (Contact contact : contacts){
			system.debug('preferred first name=' + contact.Preferred_First_Name__c +
					'; last name=' + contact.Preferred_Last_Name__c);
		    if (contact.Preferred_First_Name__c.length() == 0) {
		    	contact.Preferred_First_Name__c = contact.FirstName;
		    }
		    
		    if (contact.Preferred_Last_Name__c.length() == 0) {
		    	contact.Preferred_Last_Name__c = contact.LastName;
		    }
		}
	    
	}
    
}