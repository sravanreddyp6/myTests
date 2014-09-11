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
private class Notes_ServAssign_CodeSel_TEST {

    static testMethod void myUnitTest() {
             
        Contact testContact = new Contact(
    		LastName = 'TestLastName'
    	);
    	insert testContact;
    	
    	Admission__c testAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = testContact.Id,
            Effective_Date__c = date.today(),
            state__c = 'NC'
    	);
    	insert testAdm;
        
        Service_Assignment__c testServAssignment = new Service_Assignment__c(
        	Admission__c = testAdm.Id,
        	Person_Being_Served__c = testContact.Id,
        	Program__c = 'TEST PROGRAM',
        	Location_Region__c = 'TEST LOCATION'
        );
        insert testServAssignment;
  
  
  		RecordType assessID = [Select id, developername from recordtype where developername='Assessment_only' limit 1];
        Service_Assignment__c testServAssignmentAssess = new Service_Assignment__c(
        	Admission__c = testAdm.Id,
        	Person_Being_Served__c = testContact.Id,
        	Program__c = 'TEST PROGRAM',
        	Location_Region__c = 'TEST LOCATION',
        	RecordTypeID = assessID.Id 
        );
        insert testServAssignmentAssess;
              
        Service_Code__c testServCode = new Service_Code__c(
        	Service_Code__c = 'TEST SVC CODE',
        	FacilityID__c = 'TEST FAC ID',
        	Program_Code__c = 'TEST PROGRAM CODE',
        	Program__c = 'TEST PROGRAM',
        	Location__c = 'TEST LOCATION',
        	Service_Line__c = 'TEST SERVICE LINE',
        	start_Date__c = date.newinstance(2012,1,1) ,
        	state__c = 'NC'
        	        );
        insert testServCode;
        
        Service_Code__c testServCode2 = new Service_Code__c(
        	Service_Code__c = 'TEST SVC CODE-OH',
        	FacilityID__c = 'TEST FAC ID-OH',
        	Program_Code__c = 'TEST PROGRAM CODE-OH',
        	Program__c = 'TEST PROGRAM-OH',
        	Location__c = 'TEST LOCATION-OH',
        	Service_Line__c = 'TEST SERVICE LINE-OH',
        	start_Date__c = date.newinstance(2012,1,1) ,
        	state__c = 'OH'
        	        );
        insert testServCode2;
        
        
        ServiceAssignment_ServiceCode_JO__c testSASCJO = new ServiceAssignment_ServiceCode_JO__c(
        	Service_Code__c = testServCode.Id,
        	Service_Assignment__c = testServAssignment.Id
        );
        insert testSASCJO;
        
        
        PageReference pageRef = Page.Notes_ServiceAssignment_CodeSelection;
        Test.setCurrentPageReference(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testServAssignment);
        Notes_ServiceAssignment_CodeSelection objTestNSACS = new Notes_ServiceAssignment_CodeSelection(sc);
        
        // add the JO refrence to the SA object
        objTestNSACS.currentRecord = testServAssignment;
        objTestNSACS.currentState = objTestNSACS.currentRecord.Admission__r.state__c; 
        objTestNSACS.SelectedCodeID = testServCode.Id;
        objTestNSACS.SelectedJoID = testSASCJO.Id;
        objTestNSACS.CreateCodeJO();
        
        // get current service codes - should be 2 including --NONE--
        objTestNSACS.getCurrentCodes();
        system.debug ('Available Codes: ' +objTestNSACS.CurrentCodes);
        system.debug( 'My Locations: ' + objtestNSACS.MyLocations);
        
        System.AssertEquals( objTestNSACS.CurrentCodes.Size(), 2);
        
        // get available service codes - should be 0
        objTestNSACS.getMyServiceCodes();
        System.AssertEquals( objTestNSACS.MyServiceCodes.Size(), 0);
        
        // get current programs - should be 2 including --NONE--
        objTestNSACS.getMyPrograms();
        System.AssertEquals( objTestNSACS.myPrograms.size(), 2);
        
        // get current locations - should be 1 including --NONE--
        objTestNSACS.getMyLocations();
        System.AssertEquals( objTestNSACS.myLocations.size(), 1);
        
        // now delete the JO
        objTestNSACS.DeleteCodeJO();
        system.debug ( 'My Codes: ' + objTestNSACS.MyServiceCodes );
        
        // re test size
        // get current service codes - should be 1 including --NONE--
        objTestNSACS.getCurrentCodes();
        System.AssertEquals( objTestNSACS.CurrentCodes.Size(), 1);
        system.debug ( 'Available codes: ' + objTestNSACS.currentCodes );
        
        
        // add the JO refrence to the SA object
        objTestNSACS.currentRecord = testServAssignmentAssess;
        objTestNSACS.currentState = objTestNSACS.currentRecord.Admission__r.state__c; 
		objTestNSACS.assessmentonly = true;
		objTestNSACS.getMyLocations();
        System.AssertEquals(objTestNSACS.myLocations.size(), 1 );
        
            Service_Code__c testServCode3 = new Service_Code__c(
        	Service_Code__c = 'TEST SVC CODE- ASSESS',
        	FacilityID__c = 'TEST FAC ID-ASSESS',
        	Program_Code__c = 'TEST PROGRAM CODE-ASSESS',
        	Program__c = 'TEST PROGRAM-ASSESS',
        	Location__c = 'TEST LOCATION-ASSESS',
        	Service_Line__c = 'TEST SERVICE LINE-ASSESS',
        	start_Date__c = date.newinstance(2012,1,1) ,
        	state__c = 'NC',
        	assessment_only__c = true
        	        );
        insert testServCode3;
        
        
        objTestNSACS.selectedCodeID = testServCode3.id;
		objTestNSACS.CreateCodeJO();        
        
		objTestNSACS.getMyLocations();
        System.AssertEquals(objTestNSACS.myLocations.size(), 1 );
        
        
        
    }
}