@isTest
private class TMNPrehireEmailBatchTest {
	
	private static User recruiter, testuser;
	
	static testMethod void recuiterHasSalesforceAcctHiredMoreThan8DaysAgo() {
		// Setup
		setupUsers(13, true);
		
		// Execute
		executeTest();
		
		// assertions
		List<TMN_User__c> updatedUser = [select Last_Day__c from TMN_User__c where Salesforce_User_Account__c = :testuser.id and Job_Status__c = 'Inactive'];
		system.assertequals(1, updatedUser.size(),'Expecting only 1 updated user');
		system.assertequals(system.today(), updatedUser[0].Last_Day__c,'Invalid last day');
	}
	
	static testMethod void recuiterHasSalesforceAcctHiredLessThan8DaysAgo() {
		// Setup
		setupUsers(8, true);
		
		// Execute
		executeTest();
		
		// assertions
		List<TMN_User__c> updatedUser = [select Last_Day__c from TMN_User__c where Salesforce_User_Account__c = :testuser.id and Job_Status__c = 'Inactive'];
		system.assertequals(0, updatedUser.size(),'Expecting no updated user');
	}
	
	static testMethod void recuiterNotSalesforceAcctHiredMoreThan8DaysAgo() {
		// Setup
		setupUsers(13, false);
		
		// Execute
		executeTest();
		
		// assertions
		List<TMN_User__c> updatedUser = [select Last_Day__c from TMN_User__c where Salesforce_User_Account__c = :testuser.id and Job_Status__c = 'Inactive'];
		system.assertequals(1, updatedUser.size(),'Expecting only 1 updated user');
		system.assertequals(system.today(), updatedUser[0].Last_Day__c,'Invalid last day');
	}
	
	static testMethod void recuiterNotSalesforceAcctHiredLessThan8DaysAgo() {
		// Setup
		setupUsers(8, false);
		
		// Execute
		executeTest();
		
		// assertions
		List<TMN_User__c> updatedUser = [select Last_Day__c from TMN_User__c where Salesforce_User_Account__c = :testuser.id and Job_Status__c = 'Inactive'];
		system.assertequals(0, updatedUser.size(),'Expecting no updated user');
	}
	
	private static void executeTest() {
		Test.startTest();
		
		TMNPrehireEmailBatch b = new TMNPrehireEmailBatch();
		Database.executeBatch(b);
		
		Test.stopTest();
	}
	
	private static void setupUsers(Integer days, boolean hasSFAcct) {
		// Recruiter User
    	recruiter = TMN_Generic_Core_TestData.createUser('Mentor Recruiter','recruit', 'recruiter@tmn.test.com', 'Test', 'Recruiter', 'Care Meridian');
    	if (hasSFAcct) {
	    	TMN_User__c rcrtUser = [ select id, discipline__c, job_status__c from tmn_user__c where salesforce_user_account__c = :recruiter.id LIMIT 1];
    		rcrtUser.email__c = 'recruiter@tmn.test.com';
	    	update rcrtUser;
    	}
		
		// New hire person
    	testuser = TMN_Generic_Core_TestData.createUser('iServe-TherapistMobile','ther', 'therapist@tmn.test.com', 'Test', 'Therapist', 'Care Meridian');
    	// TMN_Generic_Core_TestData.permsetAssign(new String[] {'iServe_TherapistMobile'}, testuser.Id);
    	TMN_User__c myuser = [ select id, discipline__c, job_status__c from tmn_user__c where salesforce_user_account__c = :testuser.id LIMIT 1];
    	myuser.job_status__c = 'Active';
    	myuser.Current_Person_Type__c = 'Pre-hire';
    	myuser.Hire_Date__c = system.today().addDays(-days);
    	myuser.Recruiter_Email_Address__c = 'recruiter@tmn.test.com';
    	update myuser;
	}
    
}