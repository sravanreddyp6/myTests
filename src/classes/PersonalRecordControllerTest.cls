@isTest
private class PersonalRecordControllerTest {
    static testMethod void simpleGetterSetterTest() {
        PersonalRecordController prc = new PersonalRecordController();
        prc.primaryDiagnosis = 'Cambridge';
        String prd = prc.primaryDiagnosis;
        prc.primaryPhysician = 'test';
        String prp = prc.primaryPhysician;
        prc.primaryPhysicianPhone = 'Work';
        String prpp = prc.primaryPhysicianPhone; 
        prc.isolationStatus = 'Isolated';
        String iss = prc.isolationStatus;
        prc.isolationType = 'Isolated';
        String ist = prc.isolationType;
        prc.getevalType();
        prc.getrecType();
    }    
    static testMethod void primaryPhysicianPhoneTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        Related_Party__c rp = new Related_Party__c( Name='Test',Phone_2_Type__c = 'Work', Person_Being_Served__c = myData.contactId, Type__c = 'Physician - Primary');
        insert rp;
        PersonalRecordController prc = new PersonalRecordController();
        prc.contactId = myData.contactId;
        String prpp = prc.primaryPhysicianPhone;
    }
    static testMethod void simpleTest() {        
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        Related_Party__c rp = new Related_Party__c( Name='Test',Phone_1_Type__c='Work',Phone_2_Type__c = 'Work', Person_Being_Served__c = myData.contactId, Type__c = 'Physician - Primary');
        insert rp;
        PersonalRecordController prc = new PersonalRecordController();
        prc.contactId = myData.contactId;
        System.AssertEquals(0, prc.guardianCount);
        System.AssertEquals( false, prc.hasPhoto);
        System.AssertEquals( prc.con.Id, myData.contactID);
        prc.parentPageName = 'Test Page';
        prc.admissionId = '11111';
        prc.saId = '22222';
        prc.saNew = false;
        prc.assessmentId = '11111';
        prc.assessmentType = 'Test';
        prc.planId = '33333';
        prc.servAssignClosure = 'Test';
        PageReference pg = Prc.breadcrumb;
        prc.evalId = '11111';
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        prc.photo = bodyBlob;
        prc.uploadPhoto( );
        
        
        TMN_User__c tmnRW  = new TMN_User__c(Operating_Group__c = 'Redwood', Salesforce_User_Account__c= UserInfo.getUserId() );    
        insert tmnRW;
        
        ApexPages.currentPage().getParameters().put('evalType','test');
        prc.getevalType();
        ApexPages.currentPage().getParameters().put('recType','test');
        prc.getrecType();
        String og = prc.opGrp;
        String prd = prc.primaryDiagnosis;
        String prp = prc.primaryPhysician;
        String prpp = prc.primaryPhysicianPhone;
        String iss = prc.isolationStatus;
        String ist = prc.isolationType;
        String addid = prc.admissionId;
       
        
    }
}