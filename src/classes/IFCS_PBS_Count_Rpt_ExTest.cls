@isTest
private class IFCS_PBS_Count_Rpt_ExTest {
	
   static testmethod void simpleTest(){
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        
        PageReference pageRef = Page.IFCS_PBS_Count_Rpt;
        Test.setCurrentPage(pageRef);
        IFCS_PBS_Count_Rpt_Ex controller = new IFCS_PBS_Count_Rpt_Ex();
        controller.fStartDate = Date.today().addDays(-30);
        controller.fEndDate = Date.today();
        
        controller.runreport();
        
        system.assert(controller.filteredResults.size() > 0);
    }
 
    static testmethod void invalidDatesTest(){
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        
        PageReference pageRef = Page.IFCS_PBS_Count_Rpt;
        Test.setCurrentPage(pageRef);
        IFCS_PBS_Count_Rpt_Ex controller = new IFCS_PBS_Count_Rpt_Ex();
        controller.fStartDate = Date.today();
        controller.fEndDate = Date.today().addDays(-30);
        controller.runreport();
        system.assert(Apexpages.hasMessages());
    }
       
}