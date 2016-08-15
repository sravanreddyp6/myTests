@isTest
private class AdmissionViewExtensionTest {
    static testmethod void simpleTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
        PageReference ref = new PageReference('/apex/AdmissionView?id='+myData.theAdm.ID);
        Test.setCurrentPage(ref); 
        AdmissionViewExtension controller = new AdmissionViewExtension(new ApexPages.StandardController(myData.theAdm));
        // The controller really doesn't do anything other than fetching the
        // record, so we just check to make sure the record is fetch correctly
        System.assertEquals(myData.theAdm.ID, controller.admission.ID);
        
        Assessment_Type__c newtype = new Assessment_Type__c( name='Risk');
        insert newtype;
        
        newtype = new Assessment_Type__c( name='risk');
        insert newtype;
        
        newtype = new Assessment_Type__c( name='CANS');
        insert newtype;
        
        // fetch assessments
        Assessment__c[] assess = controller.riskAssessments;
        System.assertEquals( 0, assess.size());
        
        boolean cansee = controller.showCANS;        
        assess = controller.CANSAssessments;
        System.assertEquals( 0, assess.size());
        
        ID cansID = controller.getCANsID();
        
        // create risk assessment
        if ( controller.createRiskAssess() != null )
        {
            assess = controller.riskAssessments;
            //System.assertEquals( 1, assess.size());
        }
        
        Task intTsk = controller.intakeTask;
        System.assertEquals(intTsk.Status, 'Not Started');
        System.assertEquals(intTsk.Priority, 'Normal');

        
        AdmissionViewExtension.IgnoreSharing noshare = new AdmissionViewExtension.IgnoreSharing();
        
        System.Assert(noshare.getallSA( controller.admission.ID).size() > 0 );
        
        
    }
    static testmethod void unitTest() {
        
        User testUser = new User(alias = 'tester',
                                 email='testusern@TMN.com',
                                 emailencodingkey='UTF-8',
                                 lastname='testn',firstname='testn', languagelocalekey='en_US',
                                 localesidkey='en_US',
                                 profileid = [select id from Profile limit 1].id,
                                 timezonesidkey='America/Los_Angeles',
                                 username='tesn@test.com' + System.currentTimeMillis());
        insert testUser ;        
        
        Tmn_user__c tmnUser= new Tmn_user__c(operating_group__c = 'Redwood', salesforce_user_account__c = testUser.Id);
        insert tmnuser;
        
        system.runas( testUser ) {
            
            TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
            myData.theAccount.Flavor__pc = 'Oregon'; update myData.theAccount;
            
            PageReference ref = new PageReference('/apex/AdmissionView?id='+myData.theAdm.ID);
            Test.setCurrentPage(ref); 
            AdmissionViewExtension controller = new AdmissionViewExtension(new ApexPages.StandardController(myData.theAdm));
            
            System.assertEquals(myData.theAdm.ID, controller.admission.ID);
            
           
            String strDate = controller.getStartDateValue();
            boolean reqAdmtFrom = controller.reqAdmittedFrom;
            boolean reqDcTo = controller.reqDcTo;
            boolean shwDcTo = controller.shwDcTo;
            controller.createIssaAssess();
            
            controller.showAddIntakeTask();
            controller.saveIntakeTask();        
            system.assert(controller.intakeSteps.size() == 1); 
            String editintakeTaskId = controller.editintakeTaskId;
            String editintakeTId = controller.intakeSteps[0].id;
            ApexPages.currentPage().getParameters().put('editintakeTaskId',editintakeTId);
            controller.showEditIntakeTask();
            controller.closeIntakeTask();
            controller.dummyTask.OwnerId = testUser.Id;
            controller.createIntakeSteps();
         
            
        }
    }
}