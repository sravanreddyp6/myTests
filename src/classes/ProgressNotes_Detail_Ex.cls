public with sharing class ProgressNotes_Detail_Ex {
    Progress_Note__c note = new Progress_Note__c();
    public ProgressNotes_Detail_Ex(ApexPages.StandardController controller) {
        note = (Progress_Note__c )controller.getRecord();
    }
    public pagereference checkType(){
    	
       if(note.recordtype.DeveloperName == 'Shift_Note'){
       //ActionPlanForm
       
           for(TMN_User__c TU: [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]){
         		if (TU.Operating_Group__c == 'Care Meridian') { 
         			return new PageReference('/apex/shiftnote_narrative_form?id=' + note.id );
         		} else {
         			return new PageReference('/apex/shiftnote_basic_form?id='+note.id );
         		} 
        	}
       
       
       } 


        return null;
    }
}