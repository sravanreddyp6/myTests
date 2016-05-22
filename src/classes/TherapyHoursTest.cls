@isTest
private class TherapyHoursTest {
    static testMethod void myUnitTest() {
    	
   	
        // create a test account with discipline
    	User testuser = TMN_Generic_Core_TestData.createUser('iServe-TherapistMobile','ther', 'therapist@tmn.test.com', 'Test', 'Therapist', 'Care Meridian');
    	TMN_Generic_Core_TestData.permsetAssign(new String[] {'iServe_TherapistMobile'}, testuser.Id);
    	TMN_User__c myuser = [ select id, discipline__c, job_status__c from tmn_user__c where salesforce_user_account__c = :testuser.id LIMIT 1];
    	myuser.discipline__c = 'PT';
    	myuser.job_status__c = 'Active';
    	update myuser;
        
        system.runas( testuser ) {	
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
        
        PageReference pageRef = Page.TherapyHours;
        Test.setCurrentPage(pageRef);
        TherapyHours th = new TherapyHours();
        system.assertequals(true, th.getProgramslist().contains('--Select--'));
        Integer i = th.getProgramsList().indexOf('a0v');
        String selpgm = '';
        system.debug (' index is ' + i );
        if ( i > 0) {
        	selpgm=th.getProgramsList().substring( i, i+18);
        	system.debug( selpgm);
        }
        String formData = '{"selectprograms":"' + selpgm + '","pbsList":"' + testData.theSA.Id + '","entryType":"Individual Treatment","startDateTime":"2015-10-01T01:00","endDateTime":"2015-10-01T02:00","narrativeNotes":"the test class entry."}';
        TherapyHours.saveFields(formData);
        system.assertequals(1, [select id from Therapy_Hour__c].size() );
        
        }
    }

}