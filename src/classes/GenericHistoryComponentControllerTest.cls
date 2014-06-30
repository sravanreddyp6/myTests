@isTest
public with sharing class GenericHistoryComponentControllerTest {
    static testmethod void simpleTests() {
        
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
           
        myData.theAdm.Active__c = true;
        myData.theAdm.Name = 'Test Admission Updated';
        myData.theAdm.State__c = 'OH';
        update myData.theAdm;
        
        myData.theAdm.Name = 'Test Admission Updated';
        myData.theAdm.State__c = 'IN';
        update myData.theAdm;
        

        GenericHistoryComponentController controller = new GenericHistoryComponentController();
        controller.myObject = myData.theAdm;
        controller.getObjectHistory();
        System.assertEquals('Admission Name', GenericHistoryComponentController.returnFieldLabel('name'));
        GenericHistoryComponentController.objectHistoryLine line =
            new GenericHistoryComponentController.objectHistoryLine();
        System.assertEquals(null, line.theDate);
        System.assertEquals(null, line.who);
        System.assertEquals(null, line.userId);
        System.assertEquals(null, line.action);
    }
}