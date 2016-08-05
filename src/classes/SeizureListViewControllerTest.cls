@isTest
private class SeizureListViewControllerTest {

    static testmethod void simpleTests(){
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        
        Datetime stEndTime = Datetime.now().addDays(-2);
        
        List<Seizure__c> seizures = new List<Seizure__c>();

        For(integer i=0; i < 10; i++){
            Seizure__c s = new Seizure__c();
            s.Service_Assignment__c = testData.theSA.Id;
            s.Start_DateTime__c = stEndTime.addHours(i);
            s.End_DateTime__c = stEndTime.addHours(i+1);
            seizures.add(s);
        }
        
        insert seizures;
        
        PageReference pageRef = Page.SeizureListView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('saId', testData.theSA.Id);
        
        SeizureListViewController controller = new SeizureListViewController();
        system.assert(controller.seizures.size() == 10);
        controller.toggleSort();        
    }

}