public with sharing class Im_InvolvedPartyTriggerHandler {
	private boolean m_isExecuting = false;

	public Im_InvolvedPartyTriggerHandler(boolean isExecuting){
		m_isExecuting = isExecuting;
	}

	public void OnBeforeInsert(Im_InvolvedParty__c[] oldObjects, Im_InvolvedParty__c[] updatedObjects, Map<Id, Im_InvolvedParty__c> oldObjMap, Map<Id,Im_InvolvedParty__c> newObjMap){
		// Not bulkified yet, but bulk insert to this table would be rare and even if they do, this logic can still handle ~100 rec before we hit the SF SOQL limits
		// leaving it this way until someone reports this being a problem
		for(Im_InvolvedParty__c prty : updatedObjects){
			list<Im_InvolvedParty__c> existingRecs = [
				select id
				  from Im_InvolvedParty__c
				 where (im_incident__c =: prty.im_incident__c and Type__c =: prty.Type__c and Person_Being_Served_Involved__c != null and Person_Being_Served_Involved__c =: prty.Person_Being_Served_Involved__c)
				    or (im_incident__c =: prty.im_incident__c and Type__c =: prty.Type__c and Staff_Involved__c != null and Staff_Involved__c =: prty.Staff_Involved__c)
			];
			if (existingRecs.size() > 0 ){
				prty.addError('DUPLICATE RECORD - Involved party already added.');
			}
		}
		IncidentInvolvedPartyModel.updateNames(updatedObjects);
	}

	public void OnAfterUpdate(Im_InvolvedParty__c[] oldObjects, Im_InvolvedParty__c[] updatedObjects, Map<Id, Im_InvolvedParty__c> oldObjMap, Map<Id,Im_InvolvedParty__c> newObjMap){
	}

}