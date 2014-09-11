public with sharing class ProgressNote_EditRedirect {
    Progress_Note__c note = new Progress_Note__c();
    string prefix {get; set;}
    public pagereference checkType(){
        prefix = string.valueof(note.id);
        prefix = prefix.left(3);
       if(note.recordtype.DeveloperName == 'Shift_Note'){
       //ActionPlanForm
           return new PageReference('/apex/shiftnote_basic_form?id='+note.id + '&edit=1');
       
       } 
       else{
           return new PageReference('/' + prefix + '/e?id='+ note.id +'&retURL=/' + note.id);       
       }


        return null;
    }
    public ProgressNote_EditRedirect(ApexPages.StandardController controller) {
        note = (Progress_Note__c )controller.getRecord();
    }

}