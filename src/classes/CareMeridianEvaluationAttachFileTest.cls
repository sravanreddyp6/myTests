@isTest
public with sharing class CareMeridianEvaluationAttachFileTest {
    static testmethod void simpleTests() {
        PageReference pageRef = Page.CareMeridianEsignPostBack;
        Test.setCurrentPage(pageRef);
        Referral__c referral = new Referral__c();
        insert referral;
        Evaluation__c evaluation = new Evaluation__c(Referral__c=referral.Id);
        insert evaluation;
        CareMeridianEvaluationAttachFile controller = new CareMeridianEvaluationAttachFile();
        ApexPages.currentPage().getParameters().put('id', evaluation.Id);
        ApexPages.currentPage().getParameters().put('img', 'SGVsbG8gV29ybGQ=');
        controller.upload();
        System.assertNotEquals(0, [SELECT ID FROM Attachment WHERE ParentId=:referral.Id].size());
    }
}