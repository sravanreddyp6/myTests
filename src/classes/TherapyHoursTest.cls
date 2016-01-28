@isTest
private class TherapyHoursTest {
    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();	
        PageReference pageRef = Page.TherapyHours;
        Test.setCurrentPage(pageRef);
        TherapyHours th = new TherapyHours();
        system.assertequals(true, th.getProgramslist().contains('--Select--'));
        String formData = '{"selectprograms":"a0vg0000002JEFlAAO","pbsList":"' + testData.theSA.Id + '","entryType":"Individual Treatment","startDateTime":"2015-10-01T01:00","endDateTime":"2015-10-01T02:00","narrativeNotes":"the test class entry."}';
        TherapyHours.saveFields(formData);
        system.assertequals(1, [select id from Therapy_Hour__c].size() );
    }

}