public with sharing class Notes_ProgressNote_GetFieldsAudit_PDF {
    public Progress_Note__c RecID {get; set;}
    public Progress_Note__c PN = new Progress_Note__c();
    public Progress_Note__c getPN()
        { return [Select Service_Code__r.Service_Value__c, Authorization__r.Display_Name__c from Progress_Note__c Where ID = :RecID.Id];}
    public Notes_ProgressNote_GetFieldsAudit_PDF(ApexPages.StandardController controller) {
        this.RecID =  (Progress_Note__c)controller.getRecord();
    }

}