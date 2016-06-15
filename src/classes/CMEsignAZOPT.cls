public with sharing class CMEsignAZOPT implements AuthenticatedAction {
    public PageReference handle(Id recordId, Id userId) {
        string recId = string.valueOf(recordId);
        user u = [select firstname,lastname from user where Id =: userId];
        Progress_note__C progNote = [Select Id, Status__c,Signature_on_File__c,Esigned_At__c,Esigned_by__c,Number_of_Required_Signatures__c from progress_note__c where id =:recordId];
        if ( progNote.Number_of_Required_Signatures__c > 0 ) {
            progNote.esigned_by__c = u.firstname + ' ' + u.lastname;
           progNote.Esigned_At__c = system.now();  
            progNote.Signature_on_File__c = 'Y';
            update progNote;            
        }
        return null;
    }
}