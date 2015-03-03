@isTest
private class SeizureTrackingRptTest {

   static testmethod void simpleTests(){
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        
        Datetime stEndTime = Datetime.newInstance(2015,1,5).addDays(-2);
        
        List<Seizure__c> seizures = new List<Seizure__c>();

        For(integer i=0; i < 10; i++){
            Seizure__c s = new Seizure__c();
            s.Service_Assignment__c = testData.theSA.Id;
            s.Start_DateTime__c = stEndTime.addHours(i);
            s.End_DateTime__c = stEndTime.addHours(i+1);
            seizures.add(s);
        }
        insert seizures;
        
        PageReference pageRef = Page.SeizureTrackingRpt;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('saId', testData.theSA.Id);
        
        SeizureTrackingRpt controller = new SeizureTrackingRpt();
        controller.startdtStr = 'January 2015';
        
        controller.runreport();
        system.assert(controller.getSeizures().size() == 10);
    }
    
}