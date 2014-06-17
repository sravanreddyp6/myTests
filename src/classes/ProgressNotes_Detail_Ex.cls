public with sharing class ProgressNotes_Detail_Ex {
    Progress_Note__c note = new Progress_Note__c();
    public ProgressNotes_Detail_Ex(ApexPages.StandardController controller) {
        note = (Progress_Note__c )controller.getRecord();
    }
    public pagereference checkType(){
       if(note.recordtype.DeveloperName == 'Shift_Note'){
       //ActionPlanForm
           return new PageReference('/apex/shiftnote_basic_form?id='+note.id);
       
       } 


        return null;
    }
}