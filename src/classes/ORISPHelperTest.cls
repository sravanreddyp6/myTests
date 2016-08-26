@isTest
private class ORISPHelperTest {

	private static Case_Management_Plan__c testIsp;
	
	private static List<RecordType> rt;
	
	private static ORISPHelper testHelper;

//	@testSetup
	private static void setUp() {
//		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

    	rt = [ select id from Recordtype where sobjecttype = 'Case_Management_Plan__c' and developername = 'OR_Combined_ISP' ];
    	system.assertEquals(1, rt.size());
    		
	}
	
    static testMethod void testCanFinalizeISP() {
		ApexPages.StandardController sc;

    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
//		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'InActive Draft';
        initializeGoodIsp(testIsp);
 		
        insert testIsp;
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
        
        System.assert(testHelper.canFinalizeISP);
        
 		testIsp.Desired_Outcomes_IsValid__c = false;
        update testIsp;
        
        System.assert(!testHelper.canFinalizeISP);
    }

    static testMethod void testCanReviseISP() {
		ApexPages.StandardController sc;

    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
        testIsp.Status__c = 'Active Final';
        insert testIsp;
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
        
        System.assert(testHelper.canReviseISP);
        
        testIsp.Status__c = 'InActive Draft';
        update testIsp;
        
        System.assert(!testHelper.canReviseISP);
        
	}
	
	static testMethod void testFinalizeISPCombISP() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'InActive Draft';
        insert testIsp;
        
        PageReference combIsp = Page.ORCombinedISP;
        Test.setCurrentPage(combIsp);
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		PageReference result = testHelper.finalizeISP();
		
		Map<String, String> params = result.getParameters();
		System.assertEquals(params.get('mode'), 'EDIT');
		System.assertEquals(params.get('id'), testIsp.Id);
		System.assertEquals(params.get('section'), '');
	}
	
	static testMethod void testFinalizeISPRiskTool() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'InActive Draft';
        insert testIsp;
        
        PageReference riskTool = Page.ORriskTool;
        Test.setCurrentPage(riskTool);
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		PageReference result = testHelper.finalizeISP();
		
		Map<String, String> params = result.getParameters();
		System.assertEquals(params.get('evalType'), 'Risk Identification Tool');
		System.assertEquals(params.get('id'), testIsp.Id);
		System.assertEquals(params.get('category'), '');
	}
	
	static testMethod void testReviseISPCombISP() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Evaluation Response Creation
//    	rt = [ select id from Recordtype where sobjecttype = 'Case_Management_Plan__c' and developername = 'Waiver_Services' ];
//    	system.assertEquals(1, rt.size());
    	
        Evaluation_Response__c er = new Evaluation_Response__c(
        	Case_Management_Plan__c = testIsp.Id,
//        	RecordType = rt.Id,
        	ISP_Service_Element_Service_Code__c = '149-OR100-Attendant Care-ADL',
        	ISP_Units__c = 5,
        	ISP_Unit_Type__c = 'Day(s)',
        	ISP_Per_Frequency__c = 'Week',
        	Label__c = 'Test Label',
        	ISP_Same_as_plan_year__c = true,
        	ISP_Describe_Chosen_Services_Supports__c = 'The services and supports include...',
        	ISP_List_Needs_Identified__c = 'Eating/Drinking',
        	ISP_Person_Preference_Service_Delivery__c = 'Morning'
        );
        insert er;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		PageReference result = testHelper.reviseISP();
		
		// validate results
		Map<String, String> params = result.getParameters();
		System.assertEquals(params.get('mode'), 'EDIT');
		System.assertNotEquals(params.get('id'), testIsp.Id);
		System.assertEquals(params.get('section'), 'hdSection');
		
		Case_Management_Plan__c newIsp = [select Status__c, Desired_Outcomes_IsValid__c, PCI_HD_Errors__c, PCI_CN_Errors__c,
					PCI_LL_Errors__c, PCI_PE_Errors__c, PCI_SL_Errors__c, PCI_CS_Errors__c, PCI_RL_Errors__c, PCI_HW_Errors__c, 
					PCI_FL_Errors__c, PCI_PA_Errors__c, PCI_CC_Errors__c, PCI_SR_Errors__c, PCI_MH_Errors__c, PCI_BH_Errors__c, 
					PCI_TP_Errors__c, PCI_ADT_Errors__c, PCI_EM_Errors__c, PCI_OP_Errors__c, Agreement_isValid__c, CDP_IsValid__c, 
					CCMS_isValid__c, Differences_Isvalid__c, Kplan_isValid__c, KPR_isValid__c, PD_Isvalid__c, 
					Leg_isValid__c, NaturalSupports_isValid__c, Profile_isValid__c, Risk_Isvalid__c, SPPC_IsValid__c, Waiver_isValid__c
				from Case_Management_Plan__c where Id = :params.get('id')];
		
		System.assertEquals('Inactive Draft', newIsp.Status__c);
		System.assertEquals(testIsp.PCI_HD_Errors__c, newIsp.PCI_HD_Errors__c);
		System.assertEquals(testIsp.PCI_CN_Errors__c, newIsp.PCI_CN_Errors__c);
		System.assertEquals(testIsp.PCI_LL_Errors__c, newIsp.PCI_LL_Errors__c);
		System.assertEquals(testIsp.PCI_PE_Errors__c, newIsp.PCI_PE_Errors__c);
		System.assertEquals(testIsp.PCI_SL_Errors__c, newIsp.PCI_SL_Errors__c);
		System.assertEquals(testIsp.PCI_CS_Errors__c, newIsp.PCI_CS_Errors__c);
		System.assertEquals(testIsp.PCI_RL_Errors__c, newIsp.PCI_RL_Errors__c);
		System.assertEquals(testIsp.PCI_HW_Errors__c, newIsp.PCI_HW_Errors__c);
		System.assertEquals(testIsp.PCI_FL_Errors__c, newIsp.PCI_FL_Errors__c);
		System.assertEquals(testIsp.PCI_PA_Errors__c, newIsp.PCI_PA_Errors__c);
		System.assertEquals(testIsp.PCI_CC_Errors__c, newIsp.PCI_CC_Errors__c);
		System.assertEquals(testIsp.PCI_SR_Errors__c, newIsp.PCI_SR_Errors__c);
		System.assertEquals(testIsp.PCI_MH_Errors__c, newIsp.PCI_MH_Errors__c);
		System.assertEquals(testIsp.PCI_BH_Errors__c, newIsp.PCI_BH_Errors__c);
		System.assertEquals(testIsp.PCI_TP_Errors__c, newIsp.PCI_TP_Errors__c);
		System.assertEquals(testIsp.PCI_ADT_Errors__c, newIsp.PCI_ADT_Errors__c);
		System.assertEquals(testIsp.PCI_EM_Errors__c, newIsp.PCI_EM_Errors__c);
		System.assertEquals(testIsp.PCI_OP_Errors__c, newIsp.PCI_OP_Errors__c);
		System.assertEquals(testIsp.Agreement_isValid__c, newIsp.Agreement_isValid__c);
		System.assertEquals(testIsp.CDP_IsValid__c, newIsp.CDP_IsValid__c);
		System.assertEquals(testIsp.CCMS_isValid__c, newIsp.CCMS_isValid__c);
		System.assertEquals(testIsp.Desired_Outcomes_IsValid__c, newIsp.Desired_Outcomes_IsValid__c);
		System.assertEquals(testIsp.Differences_Isvalid__c, newIsp.Differences_Isvalid__c);
		System.assertEquals(testIsp.Kplan_isValid__c, newIsp.Kplan_isValid__c);
		System.assertEquals(testIsp.KPR_isValid__c, newIsp.KPR_isValid__c);
		System.assertEquals(testIsp.Leg_isValid__c, newIsp.Leg_isValid__c);
		System.assertEquals(testIsp.NaturalSupports_isValid__c, newIsp.NaturalSupports_isValid__c);
		System.assertEquals(testIsp.Profile_isValid__c, newIsp.Profile_isValid__c);
		System.assertEquals(testIsp.PD_Isvalid__c, newIsp.PD_Isvalid__c);
		System.assertEquals(testIsp.Risk_Isvalid__c, newIsp.Risk_Isvalid__c);
		System.assertEquals(testIsp.SPPC_IsValid__c, newIsp.SPPC_IsValid__c);
		System.assertEquals(testIsp.Waiver_isValid__c, newIsp.Waiver_isValid__c);
		
/*		Leaving eval responses as TBD for now
		Evaluation_Response__c erCloned = [select ISP_Service_Element_Service_Code__c, ISP_Units__c, ISP_Unit_Type__c,
						ISP_Per_Frequency__c, Label__c, ISP_Same_as_plan_year__c, ISP_Describe_Chosen_Services_Supports__c,
						ISP_List_Needs_Identified__c, ISP_Person_Preference_Service_Delivery__c
				from Evaluation_Response__c 
				where Case_Management_Plan__c = :newIsp.Id ];
*/
	}
	
	static testMethod void testRefresh() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		testHelper.refresh();
	}
	
	static testMethod void testSetLinkTrue() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		testHelper.setLinkTrue();
	}
	
	static testMethod void testRedirectSectionTrue() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        System.currentPageReference().getParameters().put('isSection', 'true');
        System.currentPageReference().getParameters().put('targetSec', 'Health and Wellness');
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		PageReference result = testHelper.redirect();
		
		System.assert(result.getUrl().contains('/apex/ORcombinedISP'));
		Map<String, String> params = result.getParameters();
		System.assertEquals('EDIT', params.get('mode'));
		System.assertEquals(testIsp.Id, params.get('id'));
		System.assertEquals('Health and Wellness', params.get('section'));
	}
	
	static testMethod void testRedirectSectionFalse() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        System.currentPageReference().getParameters().put('isSection', 'false');
        System.currentPageReference().getParameters().put('targetSec', 'Health and Wellness');
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		PageReference result = testHelper.redirect();
		
		System.assert(result.getUrl().contains('/apex/ORriskTool'));
		Map<String, String> params = result.getParameters();
		System.assertEquals('Risk Identification Tool', params.get('evalType'));
		System.assertEquals(testIsp.Id, params.get('id'));
		System.assertEquals('Health and Wellness', params.get('category'));
	}
	
	static testMethod void testPCIPanelStatus() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		System.assertEquals('success', testHelper.PCIPanelStatus);
		
		testIsp.Status__c = 'Inactive Draft';
		update testIsp;
		System.assertEquals('success', testHelper.PCIPanelStatus);
		
		testIsp.PCI_HD_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
		testIsp.PCI_HD_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_HD_Errors__c = 'No Errors';
 		testIsp.PCI_CN_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_CN_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_CN_Errors__c = 'No Errors';
 		testIsp.PCI_LL_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_LL_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_LL_Errors__c = 'No Errors';
 		testIsp.PCI_PE_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_PE_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_PE_Errors__c = 'No Errors';
 		testIsp.PCI_SL_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_SL_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_SL_Errors__c = 'No Errors';
 		testIsp.PCI_CS_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_CS_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_CS_Errors__c = 'No Errors';
 		testIsp.PCI_RL_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_RL_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_RL_Errors__c = 'No Errors';
 		testIsp.PCI_HW_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_HW_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_HW_Errors__c = 'No Errors';
 		testIsp.PCI_FL_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_FL_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_FL_Errors__c = 'No Errors';
 		testIsp.PCI_PA_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_PA_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_PA_Errors__c = 'No Errors';
 		testIsp.PCI_CC_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_CC_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_CC_Errors__c = 'No Errors';
 		testIsp.PCI_SR_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_SR_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_SR_Errors__c = 'No Errors';
 		testIsp.PCI_MH_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_MH_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_MH_Errors__c = 'No Errors';
 		testIsp.PCI_BH_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_BH_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_BH_Errors__c = 'No Errors';
 		testIsp.PCI_TP_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_TP_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_TP_Errors__c = 'No Errors';
 		testIsp.PCI_ADT_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_ADT_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_ADT_Errors__c = 'No Errors';
 		testIsp.PCI_EM_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_EM_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
		
		testIsp.PCI_EM_Errors__c = 'No Errors';
 		testIsp.PCI_OP_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.PCIPanelStatus);
 		testIsp.PCI_OP_Errors__c = '';
		update testIsp;
		System.assertEquals('warning', testHelper.PCIPanelStatus);
	}
	
	static testMethod void testRiskPanelStatus() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        System.currentPageReference().getParameters().put('isSection', 'false');
        System.currentPageReference().getParameters().put('targetSec', 'Health and Wellness');
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		System.assertEquals('success', testHelper.RiskPanelStatus);
		
		// TBD: Not sure how to update the error map to test warning and error conditions
	}
	
	static testMethod void testISPPanelStatus() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        System.currentPageReference().getParameters().put('isSection', 'false');
        System.currentPageReference().getParameters().put('targetSec', 'Health and Wellness');
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		System.assertEquals('success', testHelper.ISPPanelStatus);
		
		testIsp.Status__c = 'Inactive Draft';
		update testIsp;
		System.assertEquals('warning', testHelper.ISPPanelStatus);
		
		testIsp.PD_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.PD_Errors__c = 'No Errors';
		testIsp.Profile_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.Profile_Errors__c = 'No Errors';
		testIsp.Desired_outcomes_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.Desired_outcomes_Errors__c = 'No Errors';
		testIsp.CDP_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.CDP_Errors__c = 'No Errors';
		testIsp.Risk_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.Risk_Errors__c = 'No Errors';
		testIsp.CCMS_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.CCMS_Errors__c = 'No Errors';
		testIsp.SPPC_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.SPPC_Errors__c = 'No Errors';
		testIsp.Kplan_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.Kplan_Errors__c = 'No Errors';
		testIsp.Waiver_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.Waiver_Errors__c = 'No Errors';
		testIsp.KPR_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
		
		testIsp.KPR_Errors__c = 'No Errors';
		testIsp.Differences_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ISPPanelStatus);
	}
	
	static testMethod void testContribPanelStatus() {
		ApexPages.StandardController sc;

		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
    	setUp();
    	
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
		testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        initializeGoodIsp(testIsp);
        
        insert testIsp;
        
        // Run test
        PageReference combIsp = Page.ORcombinedISP;
        Test.setCurrentPage(combIsp);
        System.currentPageReference().getParameters().put('isSection', 'false');
        System.currentPageReference().getParameters().put('targetSec', 'Health and Wellness');
        
        sc = new ApexPages.StandardController(testIsp);
        
        testHelper = new ORISPHelper(sc);
		
		System.assertEquals('warning', testHelper.ContribPanelStatus);
		
		testIsp.Leg_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ContribPanelStatus);
		
		testIsp.Leg_Errors__c = 'No Errors';
		testIsp.Agreement_Errors__c = 'Errors';
		update testIsp;
		System.assertEquals('error', testHelper.ContribPanelStatus);
		
		testIsp.Agreement_Errors__c = 'No Errors';
		update testIsp;
		System.assertEquals('success', testHelper.ContribPanelStatus);
	}
	
	private static void initializeGoodIsp(Case_Management_Plan__c isp) {
 		isp.PCI_HD_Errors__c = 'No Errors';
 		isp.PCI_CN_Errors__c = 'No Errors';
 		isp.PCI_LL_Errors__c = 'No Errors';
 		isp.PCI_PE_Errors__c = 'No Errors';
 		isp.PCI_SL_Errors__c = 'No Errors';
 		isp.PCI_CS_Errors__c = 'No Errors';
 		isp.PCI_RL_Errors__c = 'No Errors';
 		isp.PCI_HW_Errors__c = 'No Errors';
 		isp.PCI_FL_Errors__c = 'No Errors';
 		isp.PCI_PA_Errors__c = 'No Errors';
 		isp.PCI_CC_Errors__c = 'No Errors';
 		isp.PCI_SR_Errors__c = 'No Errors';
 		isp.PCI_MH_Errors__c = 'No Errors';
 		isp.PCI_BH_Errors__c = 'No Errors';
 		isp.PCI_TP_Errors__c = 'No Errors';
 		isp.PCI_ADT_Errors__c = 'No Errors';
 		isp.PCI_EM_Errors__c = 'No Errors';
 		isp.PCI_OP_Errors__c = 'No Errors';
 		isp.Agreement_isValid__c = true;
 		isp.CDP_IsValid__c = true;
 		isp.CCMS_isValid__c = true;
 		isp.Desired_Outcomes_IsValid__c = true;
 		isp.Differences_Isvalid__c = true;
 		isp.Kplan_isValid__c = true;
 		isp.KPR_isValid__c = true;
 		isp.Leg_isValid__c = true;
 		isp.NaturalSupports_isValid__c = true;
 		isp.Profile_isValid__c = true;
 		isp.PD_Isvalid__c = true;
 		isp.Risk_Isvalid__c = true;
 		isp.SPPC_IsValid__c = true;
 		isp.Waiver_isValid__c = true;
	}
}