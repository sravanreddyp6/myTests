public with sharing class IncidentInvestigationModel {
	public static Im_Investigation__c createInvestigation(Id incidentId) {
		Im_Investigation__c investigation = new Im_Investigation__c(
			Status__c = 'Draft',
			Im_Incident__c = incidentId
		);
		insert investigation;
		return investigation;
	}

	public static List<TMN_User__c> findInternalInvestigatingParties(String searchTerm) {
		return [
			select Id, Name, email__c, job_title__c
			  from TMN_User__c
			 where Job_Status__c = 'Active'
			   and Name like :searchTerm
			   and approval_level__c >= 3
			 order by Name
		];
	}

	public static Boolean validateManualAssociation(Evaluation_Response__c response) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();

		if (response.Incident_Number__c == null) {
			response.Incident_Number__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Date_of_Incident__c == null) {
			response.Date_of_Incident__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Final_Level__c == null) {
			response.Final_Level__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Program_Association__c == null) {
			response.Program_Association__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Source__c == null) {
			response.Source__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Comment__c == null) {
			response.Comment__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Date_of_Association__c == null) {
			response.Date_of_Association__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Association_Made_By__c == null) {
			response.Association_Made_By__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}

		return noError;
	}

	public static Boolean validateAutoAssociation(Evaluation_Response__c response) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();

		if (response.ImIncident__c == null) {
			response.ImIncident__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Source__c == null) {
			response.Source__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Comment__c == null) {
			response.Comment__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Date_of_Association__c == null) {
			response.Date_of_Association__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (response.Association_Made_By__c == null) {
			response.Association_Made_By__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}

		return noError;
	}

	public static Boolean saveValidation(Im_Investigation__c investigation) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();
		if (investigation.Investigation_Start_Date__c == null) {
			investigation.Investigation_Start_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		} else if (investigation.Investigation_Start_Date__c < investigation.Im_Incident__r.CreatedDate) {
			investigation.Investigation_Start_Date__c.addError('must be later than Incident Qualification Date');
			noError = false;
		}

		return noError;
	}

	public static Boolean finalizeValidation(Im_Investigation__c investigation) {
		Boolean noError = saveValidation(investigation);

		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();
		if (investigation.Investigation_End_Date__c == null) {
			investigation.Investigation_End_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		} else if (investigation.Investigation_End_Date__c < investigation.Im_Incident__r.CreatedDate) {
			investigation.Investigation_End_Date__c.addError('must be later than Incident Qualification Date');
			noError = false;
		} else if (investigation.Investigation_End_Date__c < investigation.Investigation_Start_Date__c) {
			investigation.Investigation_End_Date__c.addError('must be later than Investigation Start Date');
			noError = false;
		}

		if (investigation.Factual_Findings__c == null) {
			investigation.Factual_Findings__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (investigation.Conclusion_of_Fact__c == null) {
			investigation.Conclusion_of_Fact__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (investigation.Summary_on_Conclusion__c == null) {
			investigation.Summary_on_Conclusion__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}

		return noError;
	}
}