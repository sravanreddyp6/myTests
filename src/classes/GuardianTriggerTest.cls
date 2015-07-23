@isTest
public with sharing class GuardianTriggerTest {
	static testmethod void modifyTests() {
		Related_Party__c[] guardians = bootstrap(true, false);
		
		// Type stays the same, name matches -> change info
		Related_Party__c g1 = guardians[0];
		System.debug('Current g1 PBS Guardian Name: ' + g1.Person_Being_Served__r.Guardian1_Name__c);
		g1.Name = 'Different Guardian One';
		upsert g1;
		g1 = [
			SELECT Name, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID=:g1.ID
		];
		System.assertEquals(g1.Name, g1.Person_Being_Served__r.Guardian1_Name__c);

		// Type stays the same, name doesn't match -> do nothing
		Related_Party__c g2 = guardians[1];
		g2.Name = 'Different Guandian Two';
		upsert g2;
		g2 = [
			SELECT Name, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID=:g2.ID
		];
		System.assertNotEquals(g2.Name, g2.Person_Being_Served__r.Guardian1_Name__c);

		// Type changes, name doesn't match, over/under 18, more than 1 guardian -> do nothing
		guardians = bootstrap(true, false);
		g1 = guardians[0];
		g2 = guardians[1];
		g2.Type__c = 'Other';
		upsert g2;
		g1 = [
			SELECT Name, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID=:g1.ID
		];
		System.assertNotEquals(g2.Name, g1.Person_Being_Served__r.Guardian1_Name__c);

		// Type changes, name doesn't match, over/under 18, only 1 guardian.
		// Should never happen!

		// Type changes, name matches, more than 1 guardian, over/under 18 -> copy guardian info
		guardians = bootstrap(true, false);
		g1 = guardians[0];
		g2 = guardians[1];
		g1.Type__c = 'Other';
		upsert g1;
		g1 = [
			SELECT Name, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID=:g1.ID
		];
		System.assertEquals(g2.Name, g1.Person_Being_Served__r.Guardian1_Name__c);
		
		// Type changes, name matches, under 18, only 1 guardian -> error
		guardians = bootstrap(false, true);
		g1 = guardians[0];
		g1.Type__c = 'Other';
		Boolean errorFound = false;
		try {
			upsert g1;
		} catch (DMLException e) {
			errorFound = true;
		}
		System.assertEquals(true, errorFound);
	}
	static testmethod void deleteTests() {
		Related_Party__c[] guardians = bootstrap(true, false);
		Related_Party__c g1 = guardians[0];
		Related_Party__c g2 = guardians[1];

		// Name doesn't match, do nothing
		delete g2;
		g1 = [
			SELECT Name, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID=:g1.ID
		];
		System.assertEquals(g1.Name, g1.Person_Being_Served__r.Guardian1_Name__c);
		
		// Name matches, over 18, only 1 guardian -> remove all guardian fields
		guardians = bootstrap(false, false);
		g1 = guardians[0];
		String contactId = g1.Person_Being_Served__c;
		Contact c = [SELECT ID, Guardian1_Name__c FROM Contact WHERE ID=:contactId];
		System.assertEquals(g1.Name, c.Guardian1_Name__c);
		delete g1;
		c = [SELECT ID, Guardian1_Name__c FROM Contact WHERE ID=:contactId];
		System.assertEquals(null, c.Guardian1_Name__c);

		// Name matches, over 18, more than 1 guardians -> new guardian fields
		guardians = bootstrap(true, false);
		g1 = guardians[0];
		g2 = guardians[1];
		delete g1;
		g2 = [
			SELECT Name, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID=:g2.ID
		];
		System.assertEquals(g2.Name, g2.Person_Being_Served__r.Guardian1_Name__c);
		
		// Name matches, under 18, only 1 guardian -> error
		guardians = bootstrap(false, true);
		g1 = guardians[0];
		Boolean errorFound = false;
		try {
			delete g1;
			System.assert(false);
		} catch (DMLException e) {
			errorFound = true;
		}
		System.assertEquals(true, errorFound);
		
		// Name matches, under 18, more than 1 guardians -> new guardian fields
		guardians = bootstrap(true, true);
		g1 = guardians[0];
		g2 = guardians[1];
		delete g1;
		g2 = [
			SELECT Name, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID=:g2.ID
		];
		System.assertEquals(g2.Name, g2.Person_Being_Served__r.Guardian1_Name__c);
	}
	static testmethod void newTests() {
		Contact person = new Contact(
            LastName = 'Last'
        );
        insert person;
        Related_Party__c g1 = new Related_Party__c(
            Person_Being_Served__c = person.ID,
            Name = 'Guardian One',
            Type__c='Guardian'
        );
        insert g1;
        person = [SELECT ID, Guardian1_Name__c FROM Contact WHERE ID=:person.ID];
        System.assertEquals(g1.Name, person.Guardian1_Name__c);
	}
	static Related_Party__c[] bootstrap(Boolean multipleGuardians, Boolean under18) {
		String[] guardianIds = new String[] {};
		Contact person = new Contact(
			LastName = 'Last',
			Guardian1_Name__c = 'Guardian One'
		);
		if (under18) {
			person.Birthdate = System.Today();
		} else {
			person.Birthdate = date.newinstance(1970, 1, 1);
		}
			
		insert person;
		Related_Party__c g1 = new Related_Party__c(
			Person_Being_Served__c = person.ID,
			Name = 'Guardian One',
			Type__c='Guardian'
		);
		insert g1;
		guardianIds.add(g1.ID);
		if (multipleGuardians) {
			Related_Party__c g2 = new Related_Party__c(
				Person_Being_Served__c = person.ID,
				Name = 'Guardian Two',
				Type__c='Guardian'
			);
			insert g2;
			guardianIds.add(g2.ID);
		}
		return [
			SELECT ID, Name, Person_Being_Served__c, Person_Being_Served__r.Guardian1_Name__c
			FROM Related_Party__c WHERE ID in :guardianIds
		];
	}
}