public with sharing class CMShiftAssessmentEsign implements AuthenticatedAction {
    public PageReference handle(Id recordId, Id userId) {
    	
    	//Moving the logic to Evaluation__c object
       /* Evaluation_Response__c currentResponse = new Evaluation_Response__c();
        currentResponse.RecordTypeId = Utility.getEvaluationResponseRecordType('E-Signature');
        currentResponse.Evaluation__c = recordId;
        insert currentResponse;*/
        
        Evaluation__c assessment = [SELECT Id, Status__c,Head_to_toe_Status__c,Is_Being_Signed__c, Is_Signed__c, Recordtype.Name, ServiceAssignment__c FROM Evaluation__c WHERE id=: recordId];
        list<Service_Assignment__c> servAssign = [SELECT ID, (SELECT Id FROM Evaluations__r Where Status__c != 'Disregard' AND Recordtype.Name ='NursesAssessment' order by createdDate asc) FROM Service_Assignment__c WHERE Id=: assessment.ServiceAssignment__c LIMIT 1];
        
        if(assessment.Recordtype.name == 'CMShiftAssessment' && assessment.Head_to_toe_Status__c == 'Draft'){
        	assessment.Head_to_Toe_Status__c = 'Final'; // Whe finalize head to toe button is clicked
        	assessment.Head_to_Toe_Signed_At__c = System.Now();
        	
        }
        else if(assessment.Recordtype.name == 'CMShiftAssessment' && assessment.Head_to_toe_Status__c == 'Final'){
        	assessment.Status__c = 'Completed'; // When Done button is clicked.
        	assessment.Signed_At__c = system.Now();
        }
        else if(assessment.Recordtype.Name == 'NursesAssessment' && assessment.Id == servAssign[0].Evaluations__r[0].Id){
				assessment.Status__c = 'Final Admission';
				assessment.Signed_At__c = system.Now();
		}
		else if(assessment.Recordtype.Name == 'NursesAssessment' && assessment.Id != servAssign[0].Evaluations__r[0].Id){
			assessment.Status__c = 'Final Revision';
			assessment.Signed_At__c = system.Now();
		}
		
	//	assessment.Is_Signed__c = true;
		
		update assessment;
		
		return null;
     /*   Evaluation__c assessment = new Evaluation__c(
            Id = recordId,
            
            Status__c = EvalDynamicExt.determineEvalStatus(recordId)
        );
        update assessment;
        return null;*/
    }
}