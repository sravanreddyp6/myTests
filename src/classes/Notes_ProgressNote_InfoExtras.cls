public with sharing class Notes_ProgressNote_InfoExtras {

	public Progress_Note__c thePN { get; set;}

    public Notes_ProgressNote_InfoExtras(ApexPages.StandardController controller) {
        this.thePN = (Progress_Note__c)controller.getRecord();
        LoadData(thePN);
    }
     
    private void LoadData(Progress_Note__c tmp){
        thePN = [select Service_Assignment__r.Alias__c from Progress_Note__c where id= :tmp.id limit 1];
            
    }
}