@isTest
public with sharing class CareMeridianEvaluationCommonTests {
    static testmethod void simpleTests() {
        insert new Anoto_Form_Handler__c(
            Name = 'CareMeridian Evaluation',
            App_Id__c = '999',
            Handler__c = 'Handler'
        );
        insert new Anoto_Settings__c(
            Username__c = 'testUsername',
            Password__c = 'testPassword',
            Consumer_Key__c = 'key',
            Consumer_Secret__c = 'secret'
        );
        Person_Being_Referred__c pbr = new Person_Being_Referred__c(
            Last_Name__c = 'Test PBR',
            Date_of_Birth__c = Date.newInstance(1980, 11, 11)
        );
        insert pbr;
        Referral__c referral = new Referral__c(
            Person_Being_Referred__c=pbr.Id,
            Agency_Name__c = 'Test Agency',
            Case_Manager_Name__c = 'Case Manager Name'
        );
        insert referral;
        Evaluation__c evaluation = new Evaluation__c(
            Referral__c = referral.Id,
            Pen_Upload_Error__c = 'Test Errors',
            Rancho_Level__c = '(1) No Response',
            Discharge_To__c = 'Acute Rehab',
            prior_living_situation__c = '1 Story;2 Story',
            awareness_of_deficits__c = 'Intact',
            endurance__c = 'Not Tested',
            hygiene__c = 'CGA',
            Evaluation_Date__c = Date.newInstance(2013, 12, 10),
            Combative__c = true,
            Number_of_Children__c = 2
        );
        insert evaluation;
        System.debug('decan: ' + ((Object) evaluation.get('Decannulated_Placement_Date__c') instanceof Date));
        CareMeridianEvaluationCommonController controller = new CareMeridianEvaluationCommonController(
            new ApexPages.StandardController(evaluation)
        );
        System.assertEquals(null, controller.bodyMapUrl);
        controller.clearPenUploadErrors();
        evaluation = [
            SELECT Id, Pen_Upload_Error__c FROM Evaluation__c
            WHERE Id=:evaluation.Id
        ];
        System.assertEquals(null, evaluation.Pen_Upload_Error__c);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        controller.generatePaperForm();
        System.assertEquals('http://test.com/test.pdf', controller.pdfExistenceUrl);
        Test.stopTest();
    }

    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('http://test.com/test.pdf');
            res.setStatusCode(200);
            return res;
        }
    }
}