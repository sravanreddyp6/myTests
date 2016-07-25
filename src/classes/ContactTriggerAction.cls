/**
 * Trigger handler class for contacts preferred name trigger.
 */
public with sharing class ContactTriggerAction {
	
	/**
	 * Method invoked for either the before insert or before update event to 
	 * ensure that preferred name fields are correctly populated.
	 */
	public void onBeforeInsertUpdate(Account[] accounts) {
		
		system.debug('account count=' + accounts.size());
		
		for (Account account : accounts){
			system.debug('preferred first name=' + account.Preferred_First_Name__pc +
					'; last name=' + account.Preferred_Last_Name__pc);
		    if (account.Preferred_First_Name__pc == null || account.Preferred_First_Name__pc.length() == 0) {
		    	account.Preferred_First_Name__pc = account.FirstName;
		    }
		    
		    if (account.Preferred_Last_Name__pc == null || account.Preferred_Last_Name__pc.length() == 0) {
		    	account.Preferred_Last_Name__pc = account.LastName;
		    }
		}
	    
	}
    
}