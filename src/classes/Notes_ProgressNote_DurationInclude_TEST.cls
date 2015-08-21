@isTest
public with sharing class Notes_ProgressNote_DurationInclude_TEST {

    static testMethod void myUnitTest() {       
        Test.startTest(); 
        TMN_Generic_Core_TestData myTestDataObj = new TMN_Generic_Core_TestData();// User to get notes.
        
        // The User needs to have an associated Person Being Served with billing line items.
        Datetime firstNoteStartDatetime = datetime.newInstance(2014, 1, 1, 13, 0, 0);
        Datetime firstNoteEndDatetime = datetime.newInstance(2014, 1, 2, 15, 0, 0);
           
        Progress_Note__c thisProgressNote = TMN_Generic_Core_TestData.createProgressNote(myTestDataObj.theSA, myTestDataObj.theAdm, myTestDataObj.theServiceCode, myTestDataObj.contactID, firstNoteStartDatetime, firstNoteEndDatetime);
        
        // Instantiate the Report_AzClinicalDataUserProductivityRpt class
        Notes_ProgressNote_DurationInclude ProgNoteDurationInclude = new Notes_ProgressNote_DurationInclude(new ApexPages.Standardcontroller(thisProgressNote));
        Test.StopTest();
        
            
    }

}