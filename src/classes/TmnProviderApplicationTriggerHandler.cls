public with sharing class TmnProviderApplicationTriggerHandler {
	private boolean m_isExecuting = false;

	public TmnProviderApplicationTriggerHandler(boolean isExecuting){
		m_isExecuting = isExecuting;
	}

	public void onBeforeInsert(Tmn_Provider_Application__c[] oldObjects, Tmn_Provider_Application__c[] updatedObjects, Map<Id, Tmn_Provider_Application__c> oldObjMap, Map<Id,Tmn_Provider_Application__c> newObjMap) {
		updateNames(updatedObjects);
	}

	public void onBeforeUpdate(Tmn_Provider_Application__c[] oldObjects, Tmn_Provider_Application__c[] updatedObjects, Map<Id, Tmn_Provider_Application__c> oldObjMap, Map<Id,Tmn_Provider_Application__c> newObjMap) {
		updateNames(updatedObjects);
	}

	public void onAfterInsert(Tmn_Provider_Application__c[] oldObjects, Tmn_Provider_Application__c[] updatedObjects, Map<Id, Tmn_Provider_Application__c> oldObjMap, Map<Id,Tmn_Provider_Application__c> newObjMap) {
		updateProviders(updatedObjects, oldObjMap);
		createDocuments(updatedObjects);
	}

	public void onAfterUpdate(Tmn_Provider_Application__c[] oldObjects, Tmn_Provider_Application__c[] updatedObjects, Map<Id, Tmn_Provider_Application__c> oldObjMap, Map<Id,Tmn_Provider_Application__c> newObjMap) {
		updateProviders(updatedObjects, oldObjMap);
	}

	private static void createDocuments(Tmn_Provider_Application__c[] applications) {
		Pb_DocPacket_Document_JO__c[] docs = [
			SELECT Id, DocPacket__c, Document__c, Document__r.Due__c, DocPacket__r.Recordtype.name
			  FROM PB_DocPacket_Document_JO__c
			 WHERE Document__r.Status__c = 'Active'
			   AND DocPacket__r.Status__c = 'Active'
			   AND DocPacket__r.Default_Admission_Packet__c = true
			   AND DocPacket__r.Recordtype.Name = 'Tmn Provider Application'
		];

		List<PB_AssociatedDoc__c> assocDocs = new List<PB_AssociatedDoc__c>();
		for (Tmn_Provider_Application__c application: applications){
			for(PB_DocPacket_Document_JO__c doc: docs){
				assocDocs.add(new PB_AssociatedDoc__c(
					DocPacket__c = doc.DocPacket__c,
					Document__c = doc.Document__c,
					IsAdded__c = true,
					sObject_Id__c = application.Id,
					sObject_Type__c = 'Tmn_Provider_Application__c',
					Status__c = 'Pending'
				));
			}
		} // end-For all admissions

		if(assocDocs.size() > 0){
			insert assocDocs;
		}
	}

	private static void updateProviders(Tmn_Provider_Application__c[] applications, Map<Id, Tmn_Provider_Application__c> oldApplicationMap) {
		applications = [
			SELECT Id, Status__c, Address_Street_1__c, Address_Street_2__c, City__c, State__c,
			       Zip__c, Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c, Provider__c,
			       Provider__r.Status__c, Disqualified__c, Disqualification_Date__c,
			       Reason_for_Disqualification__c
			  FROM Tmn_Provider_Application__c
			 WHERE Id IN :applications
		];
		Tmn_Provider__c[] providers = new Tmn_Provider__c[]{};
		// This variable keeps track of which provider will be disqualified, and also map to the
		// application that leads to that disqualification - mainly we need to disqualify other
		// active applications with the same date & reason later on.
		Map<Id, Tmn_Provider_Application__c> providersToDisqualify = new Map<Id, Tmn_Provider_Application__c>();
		for (Tmn_Provider_Application__c application: applications) {
			Tmn_Provider__c provider = new Tmn_Provider__c(
				Id = application.Provider__c
			);
			if (application.Status__c != 'Pending Approval' || String.isBlank(application.Provider__r.Status__c)) {
				// Since provider can only be Pending once, at the very beginning of the process
				provider.Status__c = application.Status__c;
			}
			if (application.Status__c == 'Approved' && application.Disqualified__c && application.Provider__r.Status__c != 'Disqualified') {
				provider.Status__c = 'Disqualified';
				provider.Status_Date__c = DateTime.now();
				providersToDisqualify.put(provider.Id, application);
			}
			if (application.Status__c == 'Expired' && application.Provider__r.Status__c == 'Approved') {
				provider.Status__c = 'Expired';
				provider.Status_Date__c = DateTime.now();
			}
			if (application.Provider__r.Status__c == '' || application.Provider__r.Status__c == 'Pending Approval' || application.Status__c == 'Approved') {
				provider.Address_Street_1__c = application.Address_Street_1__c;
				provider.Address_Street_2__c = application.Address_Street_2__c;
				provider.City__c = application.City__c;
				provider.State__c = application.State__c;
				provider.Zip__c = application.Zip__c;
				provider.Phone_1__c = application.Phone_1__c;
				provider.Phone_2__c = application.Phone_2__c;
				provider.Fax__c = application.Fax__c;
				provider.Primary_Email__c = application.Primary_Email__c;
			}
			if ((oldApplicationMap == null && String.isBlank(application.Provider__r.Status__c)) || (oldApplicationMap != null && application.Status__c != oldApplicationMap.get(application.Id).Status__c)) {
				provider.Status_Date__c = DateTime.now();
			}

			providers.add(provider);
		}
		update providers;

		// We also need to set the Disqualified flag on all active applications on the disqualified
		// provider
		Tmn_Provider_Application__c[] applicationsToDisqualify = new Tmn_Provider_Application__c[]{};
		for (Tmn_Provider_Application__c application: [
				SELECT Id, Provider__c
				  FROM Tmn_Provider_Application__c
				 WHERE Provider__c IN :providersToDisqualify.keySet()
				   AND Status__c = 'Pending Approval'
		]) {
			application.Status__c = 'Disqualified';
			application.Disqualified__c = true;
			application.Disqualification_Date__c = providersToDisqualify.get(application.Provider__c).Disqualification_Date__c;
			application.Reason_for_Disqualification__c = providersToDisqualify.get(application.Provider__c).Reason_for_Disqualification__c;
			applicationsToDisqualify.add(application);
		}
		update applicationsToDisqualify;

		//service provision association is disqualified if the Provider becomes disqualified for any reason
		Service_Assignment_Provider_JO__c[] sassocDisqualify = new Service_Assignment_Provider_JO__c[]{};
		for (Service_Assignment_Provider_JO__c saProv: [
				SELECT Id, Status__c, TMN_Provider__c
				  FROM Service_Assignment_Provider_JO__c
				 WHERE TMN_Provider__c IN :providers
				   AND Status__c = 'Active'
				   AND TMN_Provider__r.Status__c = 'Disqualified'
		]) {
			saProv.Status__c = 'Disqualified';
			sassocDisqualify.add(saProv);
		}
		update sassocDisqualify;
	}

	private static void updateNames(Tmn_Provider_Application__c[] applications) {
		Set<Id> providerIds = new Set<Id>();
		for (Tmn_Provider_Application__c application: applications) {
			providerIds.add(application.Provider__c);
		}
		AggregateResult[] results = [
			SELECT COUNT(Id) numApplications, Provider__c
			  FROM Tmn_Provider_Application__c
			 WHERE Provider__c IN :providerIds
			 GROUP BY Provider__c
		];
		Map<Id, Tmn_Provider__c> providerMap = new Map<Id, Tmn_Provider__c>([
			SELECT Id, First_Name__c, Last_Name__c
			  FROM Tmn_Provider__c
			 WHERE Id IN :providerIds
		]);
		Map<Id, Integer> providerNumApplicationMap = new Map<Id, Integer>();
		for (AggregateResult result: results) {
			providerNumApplicationMap.put((Id) result.get('Provider__c'), (Integer) result.get('numApplications'));
		}
		for (Tmn_Provider_Application__c application: applications) {
			if (application.Name == null || application.Name == '') {
				application.Name = String.format('{0} {1} Application {2}', new String[] {
					providerMap.get(application.Provider__c).First_Name__c,
					providerMap.get(application.Provider__c).Last_Name__c,
					providerNumApplicationMap.containsKey(application.Provider__c) ? String.valueOf(providerNumApplicationMap.get(application.Provider__c) + 1) : '1'
				});
			}
		}
	}
}