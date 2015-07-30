public with sharing class ProgressNote_EditRedirect {
    Progress_Note__c note = new Progress_Note__c();
    string prefix {get; set;}
    public pagereference checkType(){
        prefix = string.valueof(note.id);
        prefix = prefix.left(3);
       if(!test.IsRunningTest() && note.recordtype.DeveloperName == 'Shift_Note'){
       //ActionPlanForm
       
       		// EC-196 CM has a different shift note form
       		for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
         		if (TU.Operating_Group__c == 'Care Meridian') { 
         			return new PageReference('/apex/shiftnote_narrative_form?id=' + note.id + '&edit=1');
         		} else {
         			return new PageReference('/apex/shiftnote_basic_form?id='+note.id + '&edit=1');
         		} 
        	}
           
       
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