@isTest
private class ServiceTrackingListTest {

    static testMethod void myUnitTest() {
        PageReference pageRef = Page.ServiceTracking;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', null);

    }
}