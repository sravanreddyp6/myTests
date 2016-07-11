public without sharing class TmnProviderTriggerHandler {
	private boolean m_isExecuting = false;

	public TmnProviderTriggerHandler(boolean isExecuting){
		m_isExecuting = isExecuting;
	}

	public void onBeforeInsert(Tmn_Provider__c[] oldObjects, Tmn_Provider__c[] updatedObjects, Map<Id, Tmn_Provider__c> oldObjMap, Map<Id,Tmn_Provider__c> newObjMap) {
		generateSoundExKeys(updatedObjects);
		updateNames(updatedObjects);
	}

	public void onBeforeUpdate(Tmn_Provider__c[] oldObjects, Tmn_Provider__c[] updatedObjects, Map<Id, Tmn_Provider__c> oldObjMap, Map<Id,Tmn_Provider__c> newObjMap) {
		generateSoundExKeys(updatedObjects);
		updateNames(updatedObjects);
	}

	public void onAfterUpdate(Tmn_Provider__c[] oldObjects, Tmn_Provider__c[] updatedObjects, Map<Id, Tmn_Provider__c> oldObjMap, Map<Id,Tmn_Provider__c> newObjMap) {
		Tmn_Provider__c[] disqualifiedProviders = new Tmn_Provider__c[]{};
		Tmn_Provider__c[] expiredProviders = new Tmn_Provider__c[]{};

		for (Tmn_Provider__c provider: updatedObjects) {
			if (provider.Status__c == 'Disqualified') {
				disqualifiedProviders.add(provider);
			} else if (provider.Status__c == 'Expired') {
				expiredProviders.add(provider);
			}
		}
		if (disqualifiedProviders.size() > 0) {
			notifyPersonalAgents(disqualifiedProviders, Status.DISQUALIFIED);
		}
		if (expiredProviders.size() > 0) {
			notifyPersonalAgents(expiredProviders, Status.EXPIRED);
		}
	}

	private static void generateSoundExKeys(Tmn_Provider__c[] updatedObjects) {
		SoundExTriggerUtil util = new SoundExTriggerUtil();
		util.generateKeys(updatedObjects);
	}

	private static void updateNames(Tmn_Provider__c[] updatedObjects) {
		for (Tmn_Provider__c provider: updatedObjects) {
			provider.Name = String.format('{0} {1}', new String[]{ provider.First_Name__c, provider.Last_Name__c });
		}
	}

	private enum Status { DISQUALIFIED, EXPIRED }

	private static void notifyPersonalAgents(Tmn_Provider__c[] providers, Status providerStatus) {
		Service_Assignment_Provider_JO__c[] associations = [
			SELECT Id, Tmn_Provider__c, Service_Assignment__c, Tmn_Provider__r.Name,
			       Service_Assignment__r.Name,
			       Service_Assignment__r.Person_Being_Served__r.CreatedById
			  FROM Service_Assignment_Provider_JO__c
			 WHERE Tmn_Provider__c IN :providers
		];
		Map<Id, Id> saToPbsOwner = new Map<Id, Id>();
		Map<Id, Id[]> saToUsersNotified = new Map<Id, Id[]>();
		Map<Id, Service_Assignment_Provider_JO__c[]> saToAssociations = new Map<Id, Service_Assignment_Provider_JO__c[]>();
		for (Service_Assignment_Provider_JO__c association: associations) {
			saToPbsOwner.put(association.Service_Assignment__c, association.Service_Assignment__r.Person_Being_Served__r.CreatedById);
			saToUsersNotified.put(association.Service_Assignment__c, new Id[]{});
			if (!saToAssociations.containsKey(association.Service_Assignment__c)) {
				saToAssociations.put(association.Service_Assignment__c, new Service_Assignment_Provider_JO__c[]{});
			}
			saToAssociations.get(association.Service_Assignment__c).add(association);
		}
		Service_Assignment_Personal_Agent__c[] personalAgentAssociations = [
			SELECT Id, Service_Assignment__c, Personal_Agent__r.Salesforce_User_Account__c
			  FROM Service_Assignment_Personal_Agent__c
			 WHERE Service_Assignment__c IN :saToUsersNotified.keySet()
			   AND Status__c = 'Active'
		];
		for (Service_Assignment_Personal_Agent__c paAssociation: personalAgentAssociations) {
			saToUsersNotified.get(paAssociation.Service_Assignment__c).add(paAssociation.Personal_Agent__r.Salesforce_User_Account__c);
		}
		// If no Active Personal Agents was found, notify the PBS Owner
		for (Id saId: saToUsersNotified.keySet()) {
			if (saToUsersNotified.get(saId).size() == 0) {
				saToUsersNotified.get(saId).add(saToPbsOwner.get(saId));
			}
		}

		// Actually creating Task for these users
		Task[] tasksToCreate = new Task[]{};
		for (Id saId: saToUsersNotified.keySet()) {
			for (Id userId: saToUsersNotified.get(saId)) {
				for (Service_Assignment_Provider_JO__c association: saToAssociations.get(saId)) {
					Task task = new Task(
						Status = 'In Progress',
						Priority = 'High',
						OwnerId = userId,
						WhatId = saId,
						RecordTypeId = TmnProvider.TASK_RECORD_TYPE
					);
					if (providerStatus == Status.DISQUALIFIED) {
						task.Subject = 'Provider Disqualification Notification';
						task.Description = String.format(
							'Provider {0} for Service Assignment: {1} has been disqualified. Please select another approved provider for this Person Being Served.',
							new String[]{
								association.Tmn_Provider__r.Name,
								association.Service_Assignment__r.Name
							}
						);
					} else if (providerStatus == Status.EXPIRED) {
						task.Subject = 'Provider Expiration Notification';
						task.Description = String.format(
							'Provider {0} for Service Assignment: {1} has expired. Please perform the applicable provider renewal activities or select another approved provider for this Person Being Served.',
							new String[]{
								association.Tmn_Provider__r.Name,
								association.Service_Assignment__r.Name
							}
						);
					}
					tasksToCreate.add(task);
				}
			}
		}
		insert tasksToCreate;
	}
}