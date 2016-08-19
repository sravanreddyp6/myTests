@isTest
public with sharing class ReportCaseManagementNoteSummaryTest {
	public static testmethod void simpleTests() {
	    Tmn_Generic_Core_TestData testData = new Tmn_Generic_Core_TestData();
	
			Map<String, Schema.RecordTypeInfo> progressNoteRTMap = Progress_Note__c.SObjectType.getDescribe().getRecordTypeInfosByName();
			TestUtils.ProgressNoteBuilder progressNoteBuilder = new TestUtils.ProgressNoteBuilder();
			Progress_Note__c[] progressNotes = new Progress_Note__c[] {
				progressNoteBuilder
					.setServiceAssignmentId(testData.theSA.Id)
					.setAdmissionId(testData.theAdm.Id)
					.setStartTime(Date.today().addDays(-5))
					.setEndTime(Date.today())
					.setPersonBeingServedId(testData.contactId)
					.setNoApprovalNeeded(true)
					.setApprovalStatus('Approved')
					.setStatus('Final')
					.setPurposeServiceIsBillable(true)
					.setRecordType('Case Management Note')
					.getInstance()
			};
			insert progressNotes;
			PageReference pageRef = Page.ReportCaseManagementNoteSummary;
			Test.setCurrentPage(pageRef);
        	Apexpages.currentPage().getParameters().put('saID', testData.theSA.Id);  
        	ReportCaseMgmtNoteSummaryExt controller = new ReportCaseMgmtNoteSummaryExt ();
        	controller.StartDate = Date.Today();
	      	try { 
	        	controller.runRpt();
	        } catch (Exception e) {
	        	System.Assert( e.getMessage().contains('Please choose valid start and end dates'), e.getMessage() );
	        }
	        controller.EndDate = Date.today().addDays(-1);
	        try {
	        	controller.runRpt();
	        } catch (Exception e) {
	        	System.Assert( e.getMessage().contains('Please choose valid start and end dates'), e.getMessage() );
	        }
        	controller.StartDate = date.today().adddays(-10);
        	controller.EndDate = date.today();
        	pagereference pr =  controller.runRpt();
        	System.assertEquals(true, controller.rptData.size()>0);
        	pagereference pr1 =  controller.runPdf();
        	pagereference pr2 =  controller.cancelToNewRun();    
	}
}