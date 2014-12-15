public with sharing class AttachmentTriggeredActions {
    private boolean m_isExecuting = false;

    public AttachmentTriggeredActions(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Attachment[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
    }

    public void OnAfterInsert(Attachment[] newObjects){
        // EXECUTE AFTER INSERT LOGIC

        // Mark evals as having plan of care attached when attachments of certain
        // names are added to the referral
        String referralObjPrefix;
        Set<Id> referralSet = new Set<Id>();
        Evaluation__c[] evalsToUpdate = new Evaluation__c[] {};
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values())
        {
            if(objectInstance.getDescribe().getName() == 'Referral__c') {
                referralObjPrefix = objectInstance.getDescribe().getKeyPrefix();
            }
        }
        for (Attachment a: newObjects) {
            // Mark the referral/eval record as having Plan Of Care attached
            // if necessary
            if (referralObjPrefix == String.ValueOf(a.parentId).substring(0, 3) && a.Name.startsWith('PlanOfCare')) {
                referralSet.add(a.parentId);
            }
        }
        Referral__c[] affectedReferrals = [
            SELECT Id,
                   (SELECT Id FROM Evaluations__r WHERE RecordType.Name = 'NeuroRestorative')
              FROM Referral__c WHERE Id IN :referralSet
        ];
        for (Referral__c referral: affectedReferrals) {
            if (referral.Evaluations__r.size() > 0) {
                evalsToUpdate.add(new Evaluation__c(Id=referral.Evaluations__r[0].Id, Plan_of_Care_Attached__c=true));
            }
        }
        update evalsToUpdate;
    }

    public void OnBeforeUpdate(Attachment[] oldObjects, Attachment[] updatedObjects, Map<Id,Attachment> newObjMap, Map<Id, Attachment> oldObjMap){
        // BEFORE UPDATE LOGIC
    }

    public void OnAfterUpdate(Attachment[] oldObjects, Attachment[] updatedObjects, Map<Id,Attachment> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Attachment[] ObjectsToDelete, Map<Id,Attachment> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Attachment[] deletedObjects, Map<Id,Attachment> oldObjMap){
        // AFTER DELETE LOGIC

        // Get the current user's profile name
        Profile prof = [
            select Name from Profile where Id = :UserInfo.getProfileId()
        ];

        Set<String> contractObjPrefixes = new Set<String>();
        String referralObjPrefix;
        Set<Id> referralSet = new Set<Id>();

        // ECDN-11 - 2014-05-09 - allow deletion of contract attachments
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values())
        {
            if(objectInstance.getDescribe().getName().Contains('Contract')) {
                contractObjPrefixes.Add(objectInstance.getDescribe().getKeyPrefix());
            }
            if(objectInstance.getDescribe().getName() == 'Referral__c') {
                referralObjPrefix = objectInstance.getDescribe().getKeyPrefix();
            }
        }

        System.Debug( 'LIST OF CONTRACT OBJECT PREFIXES: ' + contractObjPrefixes);
        // If current user is not a System Administrator, do not allow Attachments to be deleted
        if (!'System Administrator'.equalsIgnoreCase(prof.Name) && !'System Administrator (Custom)'.equalsIgnoreCase(Prof.Name)) {
            for (Attachment a : deletedObjects) {
                // ECDN-11 - 2014-05-09 - allow deletion of contract attachments
                if (!(contractObjPrefixes.Contains(String.ValueOf(a.parentId).substring(0, 3)))) {
                    a.addError('Unable to delete attachments.');
                }
            }
        } else {
            for (Attachment a: deletedObjects) {
                // Mark the referral/eval record as having Plan Of Care attached
                // if necessary
                if (referralObjPrefix == String.ValueOf(a.parentId).substring(0, 3)) {
                    referralSet.add(a.parentId);
                }
            }
            Referral__c[] affectedReferrals = [
                SELECT Id,
                       (SELECT Id FROM Attachments WHERE Name LIKE 'PlanOfCare%'),
                       (SELECT Id FROM Evaluations__r WHERE RecordType.Name = 'NeuroRestorative')
                  FROM Referral__c WHERE Id IN :referralSet
            ];
            Evaluation__c[] evalsToUpdate = new Evaluation__c[] {};
            for (Referral__c ref: affectedReferrals) {
                if (ref.Evaluations__r.size() > 0 && ref.Attachments.size() > 0) {
                    evalsToUpdate.add(new Evaluation__c(Id=ref.Evaluations__r[0].Id, Plan_of_Care_Attached__c=true));
                } else if (ref.Evaluations__r.size() > 0 && ref.Attachments.size() == 0) {
                    evalsToUpdate.add(new Evaluation__c(Id=ref.Evaluations__r[0].Id, Plan_of_Care_Attached__c=false));
                }
            }
            update evalsToUpdate;
        }
    }

    public void OnUndelete(Attachment[] restoredObjects){
        // AFTER UNDELETE LOGIC

    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}