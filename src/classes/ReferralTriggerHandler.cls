public with sharing class ReferralTriggerHandler {
    private boolean m_isExecuting = false;

    public ReferralTriggerHandler (boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Referral__c[] newObjects){            
        updateAnticipatedAdmDate(newObjects);
    }
    
    public void OnBeforeUpdate(Referral__c[] oldObjects, Referral__c[] updatedObjects, Map<Id,Referral__c> newObjMap, Map<Id, Referral__c> oldObjMap){    	
        updateAnticipatedAdmDate(updatedObjects);
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    private void updateAnticipatedAdmDate(Referral__c[] referrals){
        for(Referral__c ref: referrals){
        	if ( ref.Anticipated_Admission_DateTime__c != null )
        	   ref.Anticipated_Admission_Date__c = ref.Anticipated_Admission_DateTime__c.date();
        }
    }
}