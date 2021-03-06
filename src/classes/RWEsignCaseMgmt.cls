public with sharing class RWEsignCaseMgmt implements AuthenticatedAction {
    public PageReference handle(Id recordId, Id userId) {
        string recId = string.valueOf(recordId);
        user u = [select firstname,lastname from user where Id =: userId];
        Progress_note__c progNote = [Select Id, Status__c,Signature_on_File__c,Esigned_At__c,Esigned_by__c,RW_Signature_required__c from progress_note__c where id =:recordId];
        if ( progNote.RW_Signature_required__c == true ) {
            progNote.esigned_by__c = u.firstname + ' ' + u.lastname;
           progNote.Esigned_At__c = system.now();  
            progNote.Signature_on_File__c = 'Y';
            update progNote;            
        
         PageReference pageRef = new PageReference('/apex/Notes_ProgressNote_CaseManagement_ESPDF');
            pageRef.getParameters().put('id', progNote.id);
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.parentId = progNote.id;
            attachmentPDF.Name = 'Esign.pdf';          
            if(Test.isrunningtest()==false){ 
                attachmentPDF.body = pageRef.getContent();
            }
            else{
                Blob testBlob = Blob.valueOf('TEST 123');
                attachmentPDF.body = testBlob;
            }           
            insert attachmentPDF;
        }
        return null;
    }
}