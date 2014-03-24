@isTest
public with sharing class RESTAnotoOutputControllerTests {
    static testmethod void simpleTests() {
        insert new Anoto_Form_Handler__c(
            Name = 'Test',
            App_Id__c = '999',
            Handler__c = 'RESTAnotoOutputControllerTests.MockHandler'
        );
        Contact c = new Contact(LastName = 'Test');
        insert c;
        System.RestContext.request = new RestRequest();
        System.RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/AnotoOutput';
        RestContext.request.addParameter('app_id' , '998');
        RestContext.request.addParameter('id' , c.Id);
        // No content-type
        RestContext.request.addHeader('Content-Type', null);
        System.assertNotEquals('Handled', RESTAnotoOutputController.postOutput());
        // Wrong content-type
        RestContext.request.addHeader('Content-Type', 'wrong/format');
        System.assertNotEquals('Handled', RESTAnotoOutputController.postOutput());
        // No handler
        RestContext.request.addHeader('Content-Type', 'text/xml');
        System.assertNotEquals('Handled', RESTAnotoOutputController.postOutput());
        // Right
        RestContext.request.addParameter('app_id' , '999');
        RestContext.request.addHeader('Content-Type', 'text/xml');
        System.assertEquals('Handled', RESTAnotoOutputController.postOutput());
    }

    public class MockHandler implements AnotoFormHandler {
        public String handle(Id evaluationId, String fileType, Blob fileContent, RestRequest req, RestResponse response) {
            return 'Handled';
        }
    }
}