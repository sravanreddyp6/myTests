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
	}

	public void onAfterUpdate(Tmn_Provider_Application__c[] oldObjects, Tmn_Provider_Application__c[] updatedObjects, Map<Id, Tmn_Provider_Application__c> oldObjMap, Map<Id,Tmn_Provider_Application__c> newObjMap) {
		updateProviders(updatedObjects, oldObjMap);
	}

	private static void updateProviders(Tmn_Provider_Application__c[] applications, Map<Id, Tmn_Provider_Application__c> oldApplicationMap) {
		applications = [
			SELECT Id, Status__c, Address_Street_1__c, Address_Street_2__c, City__c, State__c,
			       Zip__c, Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c, Provider__c,
			       Provider__r.Status__c
			  FROM Tmn_Provider_Application__c
			 WHERE Id IN :applications
		];
		Tmn_Provider__c[] providers = new Tmn_Provider__c[]{};
		for (Tmn_Provider_Application__c application: applications) {
			Tmn_Provider__c provider = new Tmn_Provider__c(
				Id = application.Provider__c
			);
			if (application.Status__c != 'Pending Approval' || String.isBlank(application.Provider__r.Status__c)) {
				// Since provider can only be Pending once, at the very beginning of the process
				provider.Status__c = application.Status__c;
			}
			if (application.Provider__r.Status__c == 'Pending Approval' || application.Status__c == 'Approved') {
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
			if ((oldApplicationMap == null && String.isBlank(application.Provider__r.Status__c)) || application.Status__c != oldApplicationMap.get(application.Id).Status__c) {
				provider.Status_Date__c = DateTime.now();
			}

			providers.add(provider);
		}
		update providers;
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