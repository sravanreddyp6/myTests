public with sharing class createShiftAssessment {
	public Evaluation__c evaluation {get; set;}
	public ApexPages.StandardController controller;
	public Service_Assignment__c SA;
	
	public createShiftAssessment (ApexPages.StandardController stdController) {
		this.controller = stdController;
		this.evaluation = (Evaluation__c) stdController.getRecord();
		this.SA = [SELECT ID, NAME, Admission__r.Person_Being_Served__r.LastName FROM Service_Assignment__c WHERE Id=:Apexpages.Currentpage().getParameters().get('SA_ID')];
		
		
	}
	public pageReference proceed() {
			String pbsLastName = SA.Admission__r.Person_Being_Served__r.LastName;
        	if(pbsLastName == null) pbsLastName = '';
        	evaluation.Name = pbsLastName+'ShiftAssessment'+DateTime.Now().format('MMddyy');
			evaluation.RecordtypeId = Utility.getEValuationRecordType('CMShiftAssessment');
			evaluation.ServiceAssignment__c = this.SA.ID;
			evaluation.Status__c = 'Draft';
			
		try{
			insert evaluation;
			return new PageReference ('/apex/CMShiftAssessmentEdit?id='+evaluation.id);
		}
		catch (Exception e ){
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
       		 'An error occurred in creating the Shift Assessment. ' + e.getMessage()));
	    }
	    
	   return null;
	    
	}

}