@isTest
public with sharing class PbsRelatedPartiesTest {
	public static testmethod void simpleTests() {
		TestUtils.CoreDataGenerator generator = new TestUtils.CoreDataGenerator();
		TestUtils.CoreData coreData = generator.persistData();

		PbsRelatedParties controller = new PbsRelatedParties();
		controller.rows = 1000;
		controller.contact = [
			SELECT Id
			  FROM Contact
			 WHERE Id = :coreData.pbsId
		];
		System.assertNotEquals(null, controller.relatedParty);
		controller.showAddRelatedParty();
		Related_Party__c rp = PbsRelatedParties.saveRelatedParty(
			null,
			'another rp',
			'Guardian',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			coreData.pbsId
		);
		System.assertEquals(1, controller.getRelatedParties().size());
		System.assertEquals(rp.Type__c, PbsRelatedParties.loadRelatedParty(rp.Id).Type__c);
		rp = PbsRelatedParties.saveRelatedParty(
			rp.Id,
			'another rp',
			'Guardian',
			'111223333',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			coreData.pbsId
		);
		System.assertEquals(rp.Phone__c, PbsRelatedParties.loadRelatedParty(rp.Id).Phone__c);
		System.assertNotEquals('', controller.relatedPartiesJson);
		controller.getRelatedPartyReport();
	}
}