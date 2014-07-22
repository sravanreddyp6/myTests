/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Assessment_IssaForm_TEST {

    static testMethod void hideEditAndReviseButtonFromLevel1User() {
        // We need business logic that prevents a Level 1 user from accessing the Edit and Revise button, per note on RBO-289 from Kristen Lewis, 7/18/14, 8:54 AM.  To test:
        
        	TMN_Generic_Core_TestData myTestData = new TMN_Generic_Core_TestData();
        
	        // First, create users with the "Level 1-3" profile / permission set combinations.
	        Profile esdGeneralPlatform = [ SELECT Id FROM Profile WHERE Name = 'ESD General' LIMIT 1 ];
	        Profile sysAdminProfile = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ];
	        
	        List<User> testUsers = new List<User>();
	        List<PermissionSet> testPermissionSets = new List<PermissionSet>();
	        
	       	PermissionSet commonPs = [ SELECT Id FROM PermissionSet WHERE Name = 'ESD_Notes_Common' ];
	        
	        for(Integer i = 1; i<4; i++) {
		        //Create the 4 User records
		        User aUser = new User(Alias = 'lv' + i + 'user', Email='level' + i + 'user@testorg.com', 
	      									EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	      									LocaleSidKey='en_US', ProfileId = esdGeneralPlatform.Id, 
	      									TimeZoneSidKey='America/New_York', UserName='level' + i + 'user@testorg.com');
				testUsers.add(aUser);

				// Query for the 4 permission sets
		        PermissionSet ps = Database.query('SELECT Id FROM PermissionSet WHERE Name = \'ESD_Notes_RW_Level_' + i + '\'');
		        testPermissionSets.add(ps);
	        }
	        
	        User adminUser = new User(Alias = 'admuser', Email='adminuser@testorg.com', 
	      									EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	      									LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, 
	      									TimeZoneSidKey='America/New_York', UserName='admuser@testorg.com');
	        
	        testUsers.add(adminUser);
	        
	        insert testUsers;
	        	        
	        
	        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
	        
	        // Create the 3 permission set assignments four our 4 users with the 4 RW Level permission sets, respectively.
	        for(Integer i = 0; i < 3; i++) {
		        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = testUsers[i].Id, PermissionSetId = testPermissionSets[i].Id);
		        PermissionSetAssignment psaCommonPs = new PermissionSetAssignment(AssigneeId = testUsers[i].Id, PermissionSetId = commonPs.Id);
		        psaList.add(psa);
		        psaList.add(psaCommonPs);
	        }
	        
	        insert psaList;
	        
	        
	        // Create an ISSA assessment.
	        Assessment__c myIssa = TMN_Generic_Core_TestData.createAssessment(myTestData.theAdm, myTestData.theSA, 'ISSA', null, null, false);
		    
		    List<Assessment_Response__c> ars = [ SELECT Response__c, Rating__c FROM Assessment_Response__c WHERE Assessment__c = : myIssa.Id ];
		    for(Assessment_Response__c ar : ars) {
		    	ar.Response__c = 'TEST';
		    	ar.Rating__c = 'Yes';
		    }
		    update ars;
		    myIssa.Status__c = 'Active Final';
		    myIssa.Approval_Date__c = date.newInstance(2014, 01, 01);
		    update myIssa;
		        	        
		    Test.startTest();
		    
		    	AggregateResult howManyIssas = [ SELECT COUNT(Id)countIssas FROM Assessment__c WHERE Type__c = 'ISSA' ];
		    	Object numberOfIssas = howManyIssas.get('countIssas');
		    	Integer n = Integer.valueOf(numberOfIssas);
		    	System.debug('n: ' + n);
		    
		        for(Integer i = 0; i < 4; i++) {
		     		myIssa.OwnerId = testUsers[i].Id;
				    update myIssa;
			        
			        AggregateResult howManyIssasAfterOwnerUpdate = [ SELECT COUNT(Id)countIssasAgain FROM Assessment__c WHERE Type__c = 'ISSA' ];
		    		Object numberOfIssasAfterOwnerUpdate = howManyIssasAfterOwnerUpdate.get('countIssasAgain');
			        Integer nAfterOwnerUpdate = Integer.valueOf(numberOfIssasAfterOwnerUpdate);
			        System.debug('myIssa.Admission__c: ' + myIssa.Admission__c);
			        System.debug('nAfterOwnerUpdate: ' + nAfterOwnerUpdate);
			        // Use "RunAs" to operate as that user.
			        System.runAs(testUsers[i]) {
				        
				        Schema.DescribeSObjectResult d = Assessment__c.sObjectType.getDescribe();
				        System.debug('d: ' + d);
				        System.debug('d.createable: ' + d.createable);
				        
				        // Instantiate the controller for ISSA page.       
				        Assessment_IssaForm controller = new Assessment_IssaForm(new ApexPages.StandardController(myIssa));
				        
				        
				        // To conditionally render the two command buttons, they need to have the canEditRisk boolean included in the rendered attribute of the command button.  I
				        // can't easily confirm that both / any instances of a button with value "Edit" or "Revise" has a value of true or false for the rendered attribute, but I CAN at least
				        // test that the flag itself (canEditRisk) is set to false for the Level 1 user context.  Unfortunately, that test will run and PASS, even without fixing the problem here,
				        // as the value of that boolean is CORRECTLY hiding the first pair of buttons at the top of the page, but the second set of the bottom of the page are incorrectly revealed
				        // because "&& canEditRisk" didn't make it into the rendered attribute for the latter.  I'm implementing the test of the boolean as my "best attempt" at TDD in this case.
			        	if(i==0) {
			        		System.debug('Testing canEditRisk for ' + testUsers[i].Alias);
			        		System.debug('controller.canEditRisk = ' + controller.canEditRisk);
			        		System.assert(controller.canEditRisk==false);
			        		System.debug('Value of myIssa.Status__c: ' + myIssa.Status__c);
			        		System.debug('Value of controller.getCanReviseAssess(): ' + controller.getCanReviseAssess());
			        		System.assert((controller.getCanReviseAssess() && d.createable)==false);    
			        	}
			        	else {
			        		// As of 7/22/14, the Level 2 permission set is not being used according to Kristen Lewis, based on 
			        		// conversations she had with Kate S-J.  For now, I'm adding an if statement with condition i!=1 to 
			        		// skip the Level 2 user.  J. Gilliam, 7/22/14.
			     			if(i!=1) {
				     			System.debug('Testing canEditRisk for ' + testUsers[i].Alias);
				        		System.debug('controller.canEditRisk = ' + controller.canEditRisk);
				        		System.assert(controller.canEditRisk==true);
				        		System.debug('Value of myIssa.Status__c: ' + myIssa.Status__c);
				        		System.debug('Value of controller.getCanReviseAssess(): ' + controller.getCanReviseAssess());
				        		System.assert((controller.getCanReviseAssess() && d.createable)==true);
			     			}
			        	}
			        }
		        }
    		Test.stopTest();
    }
}