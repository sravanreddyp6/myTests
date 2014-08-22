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
private class Notes_Plan_Approval_TEST {
/*
J. Gilliam, 3/28/13: I have added a lot to this test class in an effort to try to increase code coverage.  I think the
uncovered lines in Notes_Plan_Approval.cls could, possibly, be covered by getting the Total_Valid_[...]__c fields on the Plan__c
object to equal 1 and then set the plan status to "Active."  However, I couldn't manually set those "...Valid..." values, and I
couldn't get references to other VF pages to make those values change either (except Total_Valid_Interventions__c would be set to 1
by one of the VF pages, which had me totally confounded).  I'm leaving what I added in spite of the fact that it might make this
test script a little less clear, because I'd like to come back to this someday and get a better understanding of how
Plan_ServiceAssignment_mJO__c and the VF pages and classes work together in this context.
*/
    static testMethod void myUnitTest() {
        Contact testContact = new Contact(
            LastName = 'TestLastName'
        );
        insert testContact;
        
        Admission__c testAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = testContact.Id,
            Effective_Date__c = date.today(),
            Network_Offering__c = 'ARY'
        );
        insert testAdm;
        
        Service_Assignment__c testServAssignment = new Service_Assignment__c(
            Admission__c = testAdm.Id,
            Person_Being_Served__c = testContact.Id
        );
        insert testServAssignment;
        
        Service_Code__c testServCode = new Service_Code__c(
            Service_Code__c = 'TEST SVC CODE',
            FacilityID__c = 'TEST FAC ID',
            Program_Code__c = 'TEST PROGRAM CODE',            
            Start_Date__c =  date.newInstance(2000, 1, 1)
        );
        insert testServCode;
        
        Progress_Note__c testPN = new Progress_Note__c(
            Service_Assignment__c = testServAssignment.Id, 
            Service_Code__c = testServCode.Id, 
            Admission__c = testAdm.ID,
            Start_Time__c = datetime.newInstance(2012, 1, 1, 13, 0, 0),
            End_Time__c = datetime.newInstance(2012, 1, 1, 15, 0, 0),
            Person_Being_Served__c = testContact.Id,
            No_Approval_Needed__c = true,
            Approval_Status__c = 'Approved'
        );
        insert testPN;
        
        
        Plan__c testPlan = new Plan__c(
            Total_Interventions__c = 1,
            Total_Objectives__c = 1,
            Total_Short_Term_Goals__c = 1,
            Status__c = 'Inactive',
            Admission__c = testAdm.Id,
            Long_term_Goal_1__c = 'TEST LONG TERM GOAL',
            Person_Being_Served__c = testContact.Id        
        );
        insert testPlan;

        PageReference pageRef3 = Page.V2SA_ConstructSTG;
        Test.setCurrentPageReference(pageRef3);
       
        Short_Term_Goal__c testSTG = new Short_Term_Goal__c(
            Short_Term_Goal_Description__c = 'TEST STG DESC',
            Plan__c = testPlan.Id,
            Status__c = 'In Progress',
            Start_Date__c = date.today(),
            End_Date__c = date.today(),
            Frequency_and_Duration__c = 'TEST FREQ AND DUR'
        );
        insert testSTG;
 	
 		
        
        Plan_ServiceAssignment_mJO__c testJoEntry = new Plan_ServiceAssignment_mJO__c(
        	Short_Term_Goal__c = testSTG.Id,
        	Service_Assignment__c = testServAssignment.Id
        );
        insert testJoEntry;


        
        System.Debug('Show me testJoEntry: ' + testJoEntry);
        System.Debug('Show me testJoEntry RECORD TYPE: ' + testJoEntry.RecordType);
 
 
        
        Objective__c testOBJ = new Objective__c(
            Plan__c = testPlan.Id,
            Short_Term_Goal__c = testSTG.Id
        );
        insert testOBJ;
        
        Intervention__c testINT = new Intervention__c(
            Objective__c = testOBJ.Id
        );
        insert testINT;
               

        System.Debug('A testPlan.Total_Valid_Interventions__c: ' + testPlan.Total_Valid_Interventions__c);
        System.Debug('A testPlan.Total_Interventions__c: ' + testPlan.Total_Interventions__c);
        System.Debug('A testPlan.Total_Valid_Objectives__c: ' + testPlan.Total_Valid_Objectives__c);
        System.Debug('A testPlan.Total_Objectives__c: ' + testPlan.Total_Objectives__c);
        System.Debug('A testPlan.Total_Valid_Short_Term_Goals__c: ' + testPlan.Total_Valid_Short_Term_Goals__c);
        System.Debug('A testPlan.Total_Short_Term_Goals__c: ' + testPlan.Total_Short_Term_Goals__c);
  
        
        RecordType stgRecordType = [SELECT Id FROM RecordType WHERE Name='SA-Short-term Goal JO' AND SobjectType='Plan_ServiceAssignment_mJO__c' Limit 1];
        RecordType objRecordType = [SELECT Id FROM RecordType WHERE Name = 'SA-Objective JO' AND SobjectType='Plan_ServiceAssignment_mJO__c' Limit 1];
		RecordType intRecordType = [SELECT Id FROM RecordType WHERE Name = 'SA Intervention JO' AND SobjectType='Plan_ServiceAssignment_mJO__c' Limit 1];
        


        Plan_ServiceAssignment_mJO__c testJoEntry2 = new Plan_ServiceAssignment_mJO__c(
        	Short_Term_Goal__c = testSTG.Id,
        	Objective__c = testOBJ.Id,
        	Service_Assignment__c = testServAssignment.Id
        );
        insert testJoEntry2;
        
        System.Debug('Show me testJoEntry2: ' + testJoEntry2);
        System.Debug('Show me testJoEntry2 RECORD TYPE: ' + testJoEntry2.RecordType);
        
        Plan_ServiceAssignment_mJO__c testJoEntry3 = new Plan_ServiceAssignment_mJO__c(
        	Short_Term_Goal__c = testSTG.Id,
        	Objective__c = testOBJ.Id,
        	Intervention__c = testINT.Id,
        	Service_Assignment__c = testServAssignment.Id
        );
        insert testJoEntry3;
        
        System.Debug('Show me testJoEntry3: ' + testJoEntry3);
        System.Debug('Show me testJoEntry3 RECORD TYPE: ' + testJoEntry3.RecordType);



		List<Plan_ServiceAssignment_mJO__c> myJoSelectTest = [Select id, recordtype.name, Short_Term_Goal__c, Intervention__c, Objective__c From Plan_ServiceAssignment_MJO__c Where Short_Term_Goal__r.Plan__r.id = :testPlan.Id];

		System.Debug('myJoSelectTest: ' + myJoSelectTest);


        System.Debug('B testPlan.Total_Valid_Interventions__c: ' + testPlan.Total_Valid_Interventions__c);
        System.Debug('B testPlan.Total_Interventions__c: ' + testPlan.Total_Interventions__c);
        System.Debug('B testPlan.Total_Valid_Objectives__c: ' + testPlan.Total_Valid_Objectives__c);
        System.Debug('B testPlan.Total_Objectives__c: ' + testPlan.Total_Objectives__c);
        System.Debug('B testPlan.Total_Valid_Short_Term_Goals__c: ' + testPlan.Total_Valid_Short_Term_Goals__c);
        System.Debug('B testPlan.Total_Short_Term_Goals__c: ' + testPlan.Total_Short_Term_Goals__c);
 

        ApexPages.Standardcontroller scA = new ApexPages.StandardController(testSTG);
        V2SA_ConstructSTG objTryStgConstruct = new V2SA_ConstructSTG(testPlan.Id);


        PageReference pageRef1 = Page.Notes_Plan_ApprovaInclude;
        Test.setCurrentPageReference(pageRef1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testPlan);
        Notes_Plan_Approval objTestNPAI = new Notes_Plan_Approval(sc);
        
        PageReference pageRef2 = Page.V2SA_PlanView;
        Test.setCurrentPageReference(pageRef2);
        

        
        objTestNPAI.MarkApproved();
        objTestNPAI.getThePlan();
 		
 		//testPlan.Status__c = 'Active';
 		//update testPlan;
 		
 		System.Debug('testPlan.Status__c: ' + testPlan.Status__c);
        
        System.Debug('C testPlan.Total_Valid_Interventions__c: ' + testPlan.Total_Valid_Interventions__c);
        System.Debug('C testPlan.Total_Interventions__c: ' + testPlan.Total_Interventions__c);
        System.Debug('C testPlan.Total_Valid_Objectives__c: ' + testPlan.Total_Valid_Objectives__c);
        System.Debug('C testPlan.Total_Objectives__c: ' + testPlan.Total_Objectives__c);
        System.Debug('C testPlan.Total_Valid_Short_Term_Goals__c: ' + testPlan.Total_Valid_Short_Term_Goals__c);
        System.Debug('C testPlan.Total_Short_Term_Goals__c: ' + testPlan.Total_Short_Term_Goals__c);
        
       
    }
}