public with sharing class CM_ESign_PDFController {
    public Progress_Note__c pNote { get; set; }
    public CM_ESign_PDFController() {
    	user u = [select firstname,lastname from user where Id = :UserInfo.getUserId() LIMIT 1];
    	pNote =  [SELECT Id,Start_Time__c, Type_of_Contact__c, People_Present__c, RW_Signature_required__c, Purpose_Service_is_Billable__c, CM_Billable_Category__c, Narrative__c,
    				Next_Appt_Date_Time__c, Esigned_By__c, Esigned_At__c FROM Progress_Note__c WHERE Id= :ApexPages.currentPage().getParameters().get('id') ];
    				if(pNote.Esigned_By__c == null){
    					pNote.Esigned_By__c = u.firstname + ' ' + u.lastname;
    					pNote.Esigned_At__c = dateTime.now();
    				}
    }
}