global with sharing class TmnProviderExpirationBatch implements Database.Batchable<sObject>, Schedulable {
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT Id, Status__c
			  FROM Tmn_Provider_Application__c
			 WHERE Status__c = 'Approved'
			   AND Expiration_Date__c <= :Date.today()
		]);
	}

	global void execute(Database.BatchableContext BC, List<Tmn_Provider_Application__c> applications) {
		Tmn_Provider_Application__c[] applicationsToUpdate = new Tmn_Provider_Application__c[]{};

		for (Tmn_Provider_Application__c application: applications) {
			applicationsToUpdate.add(
				new Tmn_Provider_Application__c(
					Id = application.Id,
					Status__c = 'Expired'
				)
			);
		}
		update applicationsToUpdate;
	}

	global void finish(Database.BatchableContext BC) {}

	//Scheduling the batch
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new TmnProviderExpirationBatch(), 100);
	}
}