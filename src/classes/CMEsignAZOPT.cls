public with sharing class CMEsignAZOPT implements AuthenticatedAction {
    public PageReference handle(Id recordId, Id userId) {
        string recId = string.valueOf(recordId);
        Progress_note__C progNote = [Select Id, Status__c,Signature_on_File__c,Number_of_Required_Signatures__c from progress_note__c where id =:recordId];
        if ( progNote.Number_of_Required_Signatures__c > 0 ) {
            
                progNote.Signature_on_File__c = 'Y';
                update progNote;            
        }
        return null;
    }
}