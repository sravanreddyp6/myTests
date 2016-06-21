public without sharing class TmnProviderTriggerHandler {
	private boolean m_isExecuting = false;

	public TmnProviderTriggerHandler(boolean isExecuting){
		m_isExecuting = isExecuting;
	}

	public void OnBeforeInsert(Tmn_Provider__c[] oldObjects, Tmn_Provider__c[] updatedObjects, Map<Id, Tmn_Provider__c> oldObjMap, Map<Id,Tmn_Provider__c> newObjMap) {
		generateSoundExKeys(updatedObjects);
		updateNames(updatedObjects);
	}

	public void OnBeforeUpdate(Tmn_Provider__c[] oldObjects, Tmn_Provider__c[] updatedObjects, Map<Id, Tmn_Provider__c> oldObjMap, Map<Id,Tmn_Provider__c> newObjMap) {
		generateSoundExKeys(updatedObjects);
		updateNames(updatedObjects);
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
}
