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
			application.Name = String.format('{0} {1} Application {2}', new String[] {
				providerMap.get(application.Provider__c).First_Name__c,
				providerMap.get(application.Provider__c).Last_Name__c,
				String.valueOf(providerNumApplicationMap.get(application.Provider__c))
			});

		}
	}
}