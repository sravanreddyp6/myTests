public with sharing class GuardianTriggeredActions {
	public void beforeDelete(Related_Party__c[] old, Map<ID, Related_Party__c> oldMap) {
		Contact c;
		for (Related_Party__c item : [SELECT ID, Type__c, Person_Being_Served__r.Guardian1_Name__c,
											 Person_Being_Served__r.Age__c, Name
									  FROM Related_Party__c WHERE ID in :old]) {
			c = null;
			if (item.Type__c != 'Guardian') {
				continue;
			}
			if (item.Person_Being_Served__c == null || item.Person_Being_Served__r.Guardian1_Name__c != item.Name) {
				// Name doesn't match, do nothing
				continue;
			}
			// Here, we know that name is matched
			Related_Party__c[] otherGuardians = getGuardiansWithExclusion(item.Person_Being_Served__c, item.ID);
			c = [SELECT ID FROM Contact WHERE ID=:item.Person_Being_Served__c];
			if (otherGuardians.size() == 0) {  // No other guardian
				if (item.Person_Being_Served__r.Age__c >= 18) {
					c.Guardian1_Name__c = '';
					c.Guardian_1_Address__c = '';
					c.Guardian_Phone_Number__c = '';
					c.Guardian_1_E_Mail__c = '';
					update c;
				} else {
					oldMap.get(item.ID).addError('A person under 18 years old must have a guardian');
				}
			} else {
				// Change info in the contact
				c.Guardian1_Name__c = otherGuardians[0].Name;
				c.Guardian_1_Address__c = otherGuardians[0].Address__c;
				c.Guardian_Phone_Number__c = otherGuardians[0].Phone__c;
				c.Guardian_1_E_Mail__c = otherGuardians[0].Email__c;
				update c;
			}
		}
	}
	
	public void beforeModify(Map<ID, Related_Party__c> oldMap, Map<ID, Related_Party__c> newMap) {
		Contact c;
		for (Related_Party__c item : [SELECT ID, Type__c, Person_Being_Served__r.Guardian1_Name__c,
											 Person_Being_Served__r.Age__c, Name
									  FROM Related_Party__c WHERE ID in :oldMap.keySet()]) {
			c = null;
			if (item.Type__c != 'Guardian') {
				System.debug('Type is not Guardian, move on!');
				continue;
			}
			if (item.Person_Being_Served__c == null || item.Person_Being_Served__r.Guardian1_Name__c != item.Name) {
				// Name doesn't match, do nothing
				System.debug('Name does not match, move on!');
				continue;
			}
			// Here, we know that name is matched
			c = [SELECT ID FROM Contact WHERE ID=:item.Person_Being_Served__c];
			// Check whether type is changed
			if (newMap.get(item.ID).Type__c=='Guardian') {
				// Type isn't changed (and name is matched), so update the
				// Guardian information on Contact.
				System.debug('Type is not changed, update with new info!');
				c.Guardian1_Name__c = newMap.get(item.ID).Name;
				c.Guardian_1_Address__c = newMap.get(item.ID).Address__c;
				c.Guardian_Phone_Number__c = newMap.get(item.ID).Phone__c;
				c.Guardian_1_E_Mail__c = newMap.get(item.ID).Email__c;
				update c;
			} else {
				// Type is changed (and name is matched).
				Related_Party__c[] otherGuardians = getGuardiansWithExclusion(item.Person_Being_Served__c, item.ID);
				if (otherGuardians.size() == 0) {  // No other guardian
					System.debug('Type is not changed, person under 18, error!');
					oldMap.get(item.ID).addError('A person under 18 years old must have a guardian');
				} else {
					System.debug('Type is changed, update with new info!');
					System.debug('New guardian: ' + otherGuardians[0]);
					c.Guardian1_Name__c = otherGuardians[0].Name;
					c.Guardian_1_Address__c = otherGuardians[0].Address__c;
					c.Guardian_Phone_Number__c = otherGuardians[0].Phone__c;
					c.Guardian_1_E_Mail__c = otherGuardians[0].Email__c;
					update c;
				}
			}
			
		}
	}
	public void afterInsert(List<Related_Party__c> newParties) {
		Contact pbs;
		for (Related_Party__c party: newParties) {
			if (party.Type__c != 'Guardian') {
				continue;
			}
			if (party.Person_Being_Served__c == null) {
				continue;
			}
			party = [
			    SELECT Person_Being_Served__r.Guardian1_Name__c, Person_Being_Served__c,
			           Name, Address__c, Phone__c, Email__c
			    FROM Related_Party__c
			    WHERE ID=:party.ID
			];  // because by default SF won't fetch related record
			if (party.Person_Being_Served__r.Guardian1_Name__c != null) {
				continue;
			}
			ID pbsID = party.Person_Being_Served__c;
			pbs = [SELECT ID FROM Contact WHERE ID=:party.Person_Being_Served__c];
			pbs.Guardian1_Name__c = party.Name;
            pbs.Guardian_1_Address__c = party.Address__c;
            pbs.Guardian_Phone_Number__c = party.Phone__c;
            pbs.Guardian_1_E_Mail__c = party.Email__c;
            update pbs;
		}
	}
	// Get the guardians for a particular Contact, excluding the input one
	public Related_Party__c[] getGuardiansWithExclusion(String contactId, String excludedGuardianId) {
		return [
			SELECT ID, Name, Email__c, Address__c, Phone__c, Person_Being_Served__c,
				   Person_Being_Served__r.Age__c
			FROM Related_Party__c
			WHERE Person_Being_Served__c=:contactId AND ID!=:excludedGuardianId AND Type__c='Guardian'
		];
	}
}