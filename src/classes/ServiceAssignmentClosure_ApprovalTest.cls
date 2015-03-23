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
private class ServiceAssignmentClosure_ApprovalTest {

    static testMethod void myUnitTest() {
    	
    	TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    	
    	Service_Assignment_Closure__c mysac = TMN_Generic_Core_TestData.createServiceAssignmentClosure(myData.theSA);
    	Assessment__c fadInitial = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'FAD Summary', 'Locked', 'Initial', false);
    	Assessment__c fad3Month = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'FAD Summary', 'Locked', '3 Month', false);
    	Assessment__c fadFinal = TMN_Generic_Core_TestData.createAssessment(myData.theAdm, myData.theSA, 'FAD Summary', 'Locked', 'Final', false);
    	
    	PageReference myPage = new PageReference('/apex/ServiceAssignmentClosureApproval');
    	Test.setCurrentPage(myPage);
    	Apexpages.currentpage().getparameters().put('ServAssignCloseId', mysac.Id);
    	
        ServiceAssignmentClosure_Approval contExt = new ServiceAssignmentClosure_Approval(new ApexPages.StandardController(mysac));
        contExt.submit();
        contExt.cancelSubmission();

        // Set the Service Assignment Closure No_Approval_Needed__c value to true, set all the fields validated at submission
        // to a value so the code gets to the point of the self-approval submission case, and kick off submit() to test that case.
        mysac.No_Approval_Needed__c = true;
        mysac.Discharge_Type__c = 'Final Discharge';
        mysac.Placement_Status_at_Discharge__c = 'Maintained Family Placement';
        mysac.Reason_for_Discharge__c = 'Completed treatment';
        mysac.Primary_Treatment_Goal__c = 'A goal...';
        mysac.FCS_Staff_Report__c = '1 = Problem Worsened';
        mysac.Family_Individual_Report__c = '1 = Problem Worsened';
        mysac.Family_Individual_Rating__c = 'Agree';
        mysac.Follow_up_Request_Received__c = 'Yes';
        mysac.Aftercare_Plan_Services__c= 'Discharge from IFCS: Family will request support if they should need or desire it';
        
        update mysac;
        contExt = new ServiceAssignmentClosure_Approval(new ApexPages.StandardController(mysac));
        contExt.submit(); 
 
 
        // Set the Service Assignment Closure No_Approval_Needed__c value to false, with all the fields validated at submission
        // still set to a value so the code gets to the point of the approval submission, and kick off submit() to test that case.
        mysac.No_Approval_Needed__c = false;
        mysac.Status__c = 'Open';
        update mysac;
        contExt = new ServiceAssignmentClosure_Approval(new ApexPages.StandardController(mysac));
        contExt.submit();         
        
        
        // Call the submit() method when the Status__c value is 'Locked' and confirm error message.
        mysac.Status__c = 'Locked';
        update mysac;
        contExt = new ServiceAssignmentClosure_Approval(new ApexPages.StandardController(mysac));
        contExt.submit();
        
        // Call the submit() method when the Status__c value is 'Pending Approval' and confirm error message.
        mysac.Status__c = 'Pending Approval';
        update mysac;
        contExt = new ServiceAssignmentClosure_Approval(new ApexPages.StandardController(mysac));
        contExt.submit();

		// Set up case where FADs are missing, and confirm error message.
		delete fadInitial;
		mysac.Status__c = 'Open';
		update mysac;
        contExt = new ServiceAssignmentClosure_Approval(new ApexPages.StandardController(mysac));
        contExt.submit();		

    }
}