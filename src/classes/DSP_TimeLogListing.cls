public with sharing class DSP_TimeLogListing {
    public Id SaId {get; set;}
    public Id pbsId {get; set;}
    public DSP_TimeLogListing(Id saId) {
        this.saId = saId;
        this.pbsId = [select person_being_served__c from Service_Assignment__c where id =: saId].person_being_served__c;
        populateTimeLogs();
    }
	class CustomException extends Exception {}
    public DSP_TimeLogListing(TxnQueueResponseController controller) {
        if (controller.thisTxn.input_params__c instanceof Id) this((Id) controller.thisTxn.input_params__c);
        else 
			throw new CustomException('Invalid input param for the TransactionQueue.');
    }
    public void populateTimeLogs() {
    }

}