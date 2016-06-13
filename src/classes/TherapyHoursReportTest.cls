@isTest
private class TherapyHoursReportTest {
    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();   
        createObjects(testData);

        TherapyHoursReport extension = new TherapyHoursReport();
        Test.setCurrentPage(extension.cancelToNewRun());
        extension.StartDate = Date.newinstance(2015, 10, 1);
        extension.EndDate = Date.newinstance(2015, 10, 10);
        extension.selectedPrograms = new list<Id>();
        for(selectOption prgms : extension.programslist){
            extension.selectedPrograms.add((Id)prgms.getValue());
        }
        extension.AddPrograms();
		for(selectOption pbs : extension.PBSList){
            extension.selectedPBS.add((Id)pbs.getValue());
        }
        extension.runReport();
        System.assertEquals(1,extension.therapyHrs.size());
    }
    
    private static void createObjects(TMN_Generic_Core_TestData testData){
            // create a new salesforce user
            User careMeridianUser = TMN_Generic_Core_TestData.createUser('ESD General', 'cmuser', 'cmuser@cm.com', 'cmFname', 'CmLName', 'Care Meridian');
            List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Notes_Intaker', 'iServe_Tier_III'};
            system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
                TMN_Generic_Core_TestData.permsetAssign(permsets, careMeridianUser.Id);
            }
            // update the TMN user Therapist fields for this salesforce user
            Tmn_User__c tmnUser = [select Account_Number__c,CPR_Expires__c,Discipline__c,GL_Code__c,IC_Agreement_Executed_Date__c,
                                    Insurance_Expires__c, License_Expires__c,Notes__c,Personal_City__c,Personal_Location__c,
                                    Personal_Zip__c,Rate__c,Vendor_Name__c 
                                    from Tmn_User__c where Salesforce_User_Account__c =: careMeridianUser.Id];
            tmnUser.Account_Number__c = '1234';
            tmnUser.CPR_Expires__c = Date.today().addYears(1);
            tmnUser.Discipline__c = 'Physical Therapy';
            tmnUser.GL_Code__c= '542009';
            tmnUser.IC_Agreement_Executed_Date__c = Date.today().addYears(1); 
            tmnUser.Insurance_Expires__c = Date.today().addYears(1);
            tmnUser.License_Expires__c = Date.today().addYears(1);
            tmnUser.Rate__c = 99;
            tmnUser.Vendor_Name__c = 'TEST VENDOR';                 
            upsert tmnUser;
                        
            list<Therapy_Hour__c> hours = new list<Therapy_Hour__c>();
            Therapy_Hour__c therapyHr = new Therapy_Hour__c();
            therapyHr.Service_Assignment__c = testData.theSA.Id;
            therapyHr.Appointment_Type__c = 'Individual Treatment';
            therapyHr.Start_Time__c = DateTime.valueOf('2015-10-01 01:00:00');
            therapyHr.End_Time__c = DateTime.valueOf('2015-10-01 02:00:00');
            therapyHr.Narrative_Note__c = 'narrativeNotes';
            therapyHr.Status_Time__c = Datetime.now();
            therapyHr.Status__c = 'Approved';
            therapyHr.Approver__c = userInfo.getUserId();
            therapyHr.ownerId = careMeridianUser.Id;
            hours.add(therapyHr);
            insert(hours);
    }
    

}