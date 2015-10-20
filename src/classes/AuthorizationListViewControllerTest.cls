@isTest
private class AuthorizationListViewControllerTest {

    static testmethod void simpleTests(){
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        
        List<Authorization__c> auths = new List<Authorization__c>();

        For(integer i=0; i < 10; i++){
            Authorization__c s = new Authorization__c();
            Funding_Source__c f = new Funding_Source__c(Service_Assignment__c = testData.theSA.Id, Type_of_Coverage__c='Primary');
            insert f;
            s.Funding_Source__c = f.id;
            s.Person_Being_Served__c = testData.contactID;
            auths.add(s);
        }
        
        insert auths;
        
        PageReference pageRef = Page.AuthorizationListView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('saId', testData.theSA.Id);
        
        AuthorizationListViewController controller = new AuthorizationListViewController();
        system.assert(controller.auths.size() == 10);
        controller.toggleSort();        
    }

}