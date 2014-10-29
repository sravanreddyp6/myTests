@isTest
public with sharing class EvaluationResponseTableControllerTest {
    static testmethod void simpleTests() {
        Referral__c referral = new Referral__c();
        insert referral;
        Evaluation__c evaluation = new Evaluation__c(Referral__c=referral.Id);
        insert evaluation;
        EvaluationResponseTableController controller = new EvaluationResponseTableController();
        controller.evaluationId = evaluation.Id;
        Component.Apex.PageBlockSection section = controller.getDialog();
        controller.responseType = 'Allergy';
        controller.showAddResponse();
        System.assertEquals(null, controller.currentResponse.Id);
        Evaluation_Response__c resp = new Evaluation_Response__c(
            Evaluation__c=evaluation.Id,
            RecordTypeId=Utility.getEvaluationResponseRecordType('Allergy')
        );
        insert resp;
        controller.currentResponseId = resp.Id;
        controller.showEditResponse();
        System.assertEquals(resp.Id, controller.currentResponse.Id);
        controller.currentResponse.Allergy_Details__c = 'Test Detail';
        controller.saveResponse();

        Contact pbs = new Contact(LastName='Test');
        insert pbs;
        controller.pbsId = pbs.Id;
        controller.showAddResponse();
        System.assertEquals(null, controller.currentResponse.Id);
    }
}