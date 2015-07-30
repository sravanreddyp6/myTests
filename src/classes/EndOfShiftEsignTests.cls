@isTest
public with sharing class EndOfShiftEsignTests {
	static testmethod void simpleTests() {
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		Evaluation__c evaluation = new Evaluation__c(
			ServiceAssignment__c = testData.theSA.Id,
			RecordTypeId = Utility.getEvaluationRecordType('CMShiftAssessment')
		);
		insert evaluation;
		EndOfShiftEsign handler = new EndOfShiftEsign();
		User user = [ SELECT Id FROM User LIMIT 1 ];
		handler.handle(evaluation.Id, user.Id);
		evaluation = [
			SELECT Id, Signed_At__c, Signed_By__c, Status__c
			FROM Evaluation__c
			WHERE Id=:evaluation.Id
		];
		System.assertEquals('End of Shift', evaluation.Status__c);
	}
}