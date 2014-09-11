@isTest
public class referralResults_Controller_Test{
    static testMethod void test() {
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        
        PageReference pageRef = Page.referralSearch;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('referralId', ref.id);
        referralResults_Controller controller = new referralResults_Controller();
        system.assert(controller.referralRecord.First_Name__c == 'Doug');
        controller.searchRefs();
        system.assert(controller.refResults.size() == 1);
        
        ApexPages.currentPage().getParameters().put('referralNumber', '111');
        ApexPages.currentPage().getParameters().put('firstName', 'Not found');
        ApexPages.currentPage().getParameters().put('lastName', 'Not found');
        ApexPages.currentPage().getParameters().put('dob', '1/1/1900');
        ApexPages.currentPage().getParameters().put('age', '99');
        controller = new referralResults_Controller();
        controller.searchRefs();
        //system.assert(controller.refResults.size() == 1);
        
        ApexPages.currentPage().getParameters().put('pbrId', pbr.Id);
        controller = new referralResults_Controller();
        controller.searchRefs();
        
        
    }
}