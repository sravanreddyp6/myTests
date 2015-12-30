@isTest
private class CmBillingRptTest {

static testMethod void testPageLoad() {
    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
    upsert myData.theSA;
    
    PageReference pageRef = Page.CmPersonBillingRpt;
    Test.setCurrentPage(pageRef);
    
    CmBillingRpt cntl = new CmBillingRpt();
    system.assert(cntl.getProgramslist().size() > 0);
    system.assert(cntl.getSelect2list().size() == 0);
    system.assert(cntl.getPBSList().size() == 0);
}


static testMethod void testAddRemoveProgram() {
    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
    upsert myData.theSA;
    
    PageReference pageRef = Page.CmPersonBillingRpt;
    Test.setCurrentPage(pageRef);
    CmBillingRpt cntl = new CmBillingRpt();
    cntl.startdate =  Date.newInstance(2015,1,1);
    cntl.enddate = Date.newInstance(2015,1,5);
    
    cntl.selectedPrograms = new List<Id>();
    cntl.selectedPrograms.add(cntl.getProgramslist().get(0).getValue());
    
    cntl.AddPrograms();
    
    system.assert(cntl.getProgramslist().size() == 0);
    system.assert(cntl.getSelect2list().size() > 0);
    system.assert(cntl.getPBSList().size() == 0);
    
    cntl.select2PrmIds = new List<Id>();
    cntl.select2PrmIds.add(cntl.getSelect2list().get(0).getValue());
        
    cntl.RemovePrograms();
    
    system.assert(cntl.cancelToNewRun() != null);
}

static testMethod void testAddProgramWithEval() {
    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    myData.theSA.Service_Location__c =  Referral_CreateTestData.createServiceLocation('11111').Id;
    upsert myData.theSA;

    list<Evaluation__c> evaluations = new list<Evaluation__c>();
    evaluations.add(new Evaluation__c ( Status__c = 'Draft', RecordtypeId = Utility.getEvaluationRecordType('CMShiftAssessment'),
                                            Shift_Start_Time__c = datetime.newInstance(2015, 1, 2, 0, 2, 2), Shift_End_Time__c = datetime.newInstance(2015, 1, 3, 0, 2, 2), 
                                            Head_to_Toe_Status__c = 'Final', ServiceAssignment__c = myData.theSA.Id ));
    insert evaluations;
    
    PageReference pageRef = Page.CmPersonBillingRpt;
    Test.setCurrentPage(pageRef);
    CmBillingRpt cntl = new CmBillingRpt();
    cntl.startdate =  Date.newInstance(2015,1,1);
    cntl.enddate = Date.newInstance(2015,1,5);
    
    cntl.selectedPrograms = new List<Id>();
    cntl.selectedPrograms.add(cntl.getProgramslist().get(0).getValue());
    
    cntl.AddPrograms();
    
    system.assert(cntl.getProgramslist().size() == 0);
    system.assert(cntl.getSelect2list().size() > 0);
    system.assert(cntl.getPBSList().size() > 0);
}





}