@isTest
public with sharing class Report_AzClinicalDataUserProdRpt_TEST {

    static testMethod void myUnitTest() {    	
/*
    	// Well, I'm making a report that's supposed to feed out line items for what Kate called an Arizona "Clinical Data User," by which she meant
    	// a clinician, not necessarily someone who has the "ESD - Notes - Clinical Data User" permission set.  So, I need a user.
    	
    	TMN_Generic_Core_TestData myTestDataObj = new TMN_Generic_Core_TestData();
    	
    	// User to get notes.
    	User myTestUser = TMN_Generic_Core_TestData.createUser('ESD General', 'test9876', 'test9876@test.com', 'Test', 'User', 'Redwood');
    	// User without notes / lines in report.
    	User myTestUser2 = TMN_Generic_Core_TestData.createUser('ESD General', 'test5432', 'test5432@test.com', 'Test2', 'User2', 'Redwood');
    	
    	// The User needs to have an associated Person Being Served with billing line items.
    	
    	// NOTES ON RECORDS CREATED AUTOMATICALLY BY TMN_Generic_Core_TestData INSTANTIATION:
	    	// myTestDataObj.theAccount is the PBS.
	    	// myTestDataObj.theAdm is the Admission.
	    	// myTestDataObj.theSA is the Service Assignment.
	    	// myTestDataObj.theServiceCode is the Service Code.
    	
    	Datetime firstNoteStartDatetime = datetime.newInstance(2014, 1, 1, 13, 0, 0);
    	Datetime firstNoteEndDatetime = datetime.newInstance(2014, 1, 2, 15, 0, 0);
    	List<Progress_Note__c> progressNotesToUpdate = new List<Progress_Note__c>();    	    	
    	
    	System.runAs(myTestUser) {
	    	for(Integer i = 10; i > 0; i++) {
	    		Progress_Note__c thisProgressNote = TMN_Generic_Core_TestData.createProgressNote(myTestDataObj.theSA, myTestDataObj.theAdm, myTestDataObj.theServiceCode, myTestDataObj.contactID, firstNoteStartDatetime, firstNoteEndDatetime);
	    		
	    		thisProgressNote.Units__c = 1;
	    		
	    		if(math.mod(i,2)==0) {
	    			thisProgressNote.Purpose_Service_is_Billable__c = true;
	    		}
	    		else {
	    			thisProgressNote.Purpose_Service_is_Billable__c = false;
	    		}
	    		
	    		progressNotesToUpdate.add(thisProgressNote);
	    		
	    		firstNoteStartDatetime = firstNoteStartDatetime + 1;
	    		firstNoteEndDatetime = firstNoteEndDatetime + 1;
	    	}
    	}
    	
    	update progressNotesToUpdate;
    	
    	// Instantiate the Report_AzClinicalDataUserProductivityRpt class
    	Report_AzClinicalDataUserProductivityRpt myRptRun = new Report_AzClinicalDataUserProductivityRpt();
    	
    	// Run the report method.
    	PageReference pgRef = myRptRun.runReport();
    
		// We need a line item in the report for each service line, and a summary line.  I'm thinking of accomplishing this by creating a wrapper class for the line items with
		// properties for User, a List<Progress_Note__c> for the line items that includes Person_Being_Served__c name, billable/non-billable status, units, etc., and 
		// data for a summation line (which might be an inner class on the wrapper class, or just primitive properties; I'll try the inner class idea first).  So, the Visualforce page 
		// will be passed a List<DataForCDU> that will be looped through to create the report records.  For this test, we'll assert that the list of Progress_Note__C includes 
		// the 10 records we created above, and that the Units__c and Purpose_Service_is_Billable__c values in the summation line are correct.
		Decimal hoursThisCDU = 0;
		Decimal billableHoursThisCDU = 0;
		Decimal nonbillableHoursThisCDU = 0;
		
		// Not yet developed...
		
		List<User> allUsers = [ SELECT Id FROM User ];
		for(User u : allUsers) {
			for(Report_AzClinicalDataUserProductivityRpt.DataForCDU d : myRptRun.listDataForCDU) {
				for(Report_AzClinicalDataUserProductivityRpt.WrappedPn p : d.pns) {
					if(p.thePn.CreatedBy.Id==u.Id) {
						hoursThisCDU = hoursThisCDU + (p.thePn.Total_Time__c / 60);
						if(p.thePn.Purpose_Service_is_Billable__c==true) {
							billableHoursThisCDU = billableHoursThisCDU + (p.thePn.Total_Time__c / 60);
						}
						else {
							nonbillableHoursThisCDU = nonbillableHoursThisCDU+ (p.thePn.Total_Time__c / 60);
						}
					}
				}
			}

	    	if(u.Id==myTestUser.Id) {
		    	// Here we assert that we've got 10 lines (list of Progress_Note__c size == 10), 10 units total, 5 billable and 5 non-billable, for the user with notes. 
				
				// Not yet developed...	
					//System.assert(myRptRun.listOfDataForCDU.listOfProgressNotes.size()==10);
		    	System.assert(hoursThisCDU==20);
		    	System.assert(billableHoursThisCDU==10);
		    	System.assert(nonbillableHoursThisCDU==10);
		    	// Check that the summary row for the CDU has the expected number of units.
		    	//System.assert(myRptRun.listDataForCDU.SummaryRow.totalHours==10);
		    	//System.assert(myRptRun.listDataForCDU.SummaryRow.billableHours==5);
		    	//System.assert(myRptRun.listDataForCDU.SummaryRow.nonBillableHours==5);
	    	}
	    	else {
	    		// Our user without notes should not have notes or a summary row.
				
				// Not yet developed...	
					//System.assert(myRptRun.listOfDataForCDU.listOfProgressNotes.size()==10);
		    	System.assert(hoursThisCDU==0);
		    	System.assert(billableHoursThisCDU==0);
		    	System.assert(nonBillableHoursThisCDU==0);
		    	// Check that the summary row for the CDU has the expected number of units.
		    	//System.assert(myRptRun.listOfDataForCDU.SummaryRow.Hours==10);
		    	//System.assert(myRptRun.listOfDataForCDU.SummaryRow.billableHours==5);
		    	//System.assert(myRptRun.listOfDataForCDU.SummaryRow.nonBillableHours==5);	    	
	    	}


			hoursThisCDU = 0;
			billableHoursThisCDU = 0;
			nonBillableHoursThisCDU = 0;	
			
		} 
    	
    */		
    }

}