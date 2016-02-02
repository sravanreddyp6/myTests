@isTest
public with sharing class Report_AzClinicalDataUserProdRpt_TEST {

    static testMethod void myUnitTest() {       
         
        TMN_Generic_Core_TestData myTestDataObj = new TMN_Generic_Core_TestData();
        
        // User to get notes.
        User myTestUser = TMN_Generic_Core_TestData.createUser('ESD General', 'test9876', 'test9876@test.com', 'Test', 'User', 'Redwood');
        // User without notes / lines in report.
        User myTestUser2 = TMN_Generic_Core_TestData.createUser('ESD General', 'test5432', 'test5432@test.com', 'Test2', 'User2', 'Redwood');
        // put users into the correct role
        UserRole userRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'AZ_Phoenix_Clinical_Users' LIMIT 1];
        List<User> users  = [ select id, userroleid from user where id in (:myTestUser.Id, :mytestuser2.id)];
        for (User u: users ){
            u.userroleid = userRole.Id;
        }
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
        Update users;
        } 
        // The User needs to have an associated Person Being Served with billing line items.
        Datetime firstNoteStartDatetime = datetime.newInstance(2014, 1, 1, 13, 0, 0);
        Datetime firstNoteEndDatetime = datetime.newInstance(2014, 1, 2, 15, 0, 0);
        List<Progress_Note__c> progressNotesToUpdate = new List<Progress_Note__c>();                
        System.runAs(myTestUser) {
            for(Integer i = 0; i< 4; i++) {
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
        System.runAs(myTestUser) {
        	Report_AzClinicalDataUserProductivityRpt myRptRun = new Report_AzClinicalDataUserProductivityRpt();
        	List<SelectOption> userlist = myRptRun.users;
        	System.Assert( userList.size() > 0); // this includes users who are already there (we see users in test method)
        
        	myRptRun.fStartDate = date.newInstance(2014, 1, 1);
        	myRptRun.fEndDate = myRptRun.fStartDate - 5;
        
        	PageReference pgRef = myRptRun.runReport();
        	// will throw error
        
        	myRptRun.fStartDate = date.newInstance(2014, 1, 1);
        	myRptRun.fEndDate = myRptRun.fStartDate + 5;
        
        	List<String> selectedUsers = new List<String>{myTestUser.id, myTestUser2.id};
        	myRptRun.uiselUsers = myTestUser.id + ',' + myTestUser2.id;
        
        	pgRef = myRptRun.runReport();
        }
    }

}