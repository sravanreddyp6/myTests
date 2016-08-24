@isTest
private class ORISPPrintTest {
	
	@testSetup
	static void setUp() {
		Case_Management_Plan__c testIsp;
		
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();

    	List<RecordType> rt = [ select id from Recordtype where sobjecttype = 'Case_Management_Plan__c' and developername = 'OR_Combined_ISP' ];
    	system.assertEquals(1, rt.size());
    		
		testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
        testIsp.Service_Assignment__c = testData.theSA.id;
        testIsp.Status__c = 'Active Final';
        insert testIsp;
        
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and developername = 'Desired_Outcomes' ];
    	system.assertEquals(1, rt.size());
        
        // desired outcomes
        Evaluation_Response__c evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
        	ISP_What_is_the_desired_result__c = 'Desired result 1',
        	ISP_Key_Steps_to_work_toward_outcome__c = 'Key steps 1 include...',
        	ISP_Is_there_a_paid_Service__c = 'Yes',
        	ISP_Paid_Services__c = 'Employment Services',
        	ISP_Who_is_responsible__c = 'Respsonsible parties 1',
        	ISP_Timelines_Frequency_when__c = 'Timeline frequency 1',
        	ISP_Where_to_Record_progress__c = 'Progress record location 1',
        	ISP_Note_if_Written_Implementation__c = 'The written note 1'
        );
        insert evalResp;

		// employment outcomes
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and developername = 'Employment_Outcomes' ];
    	system.assertEquals(1, rt.size());
        
		evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
        	ISP_What_is_the_desired_result__c = 'Desired result 2',
        	ISP_Key_Steps_to_work_toward_outcome__c = 'Key steps 2 include...',
        	ISP_Is_there_a_paid_Service__c = 'Yes',
        	ISP_Paid_Services__c = 'Employment Services',
        	ISP_Who_is_responsible__c = 'Respsonsible parties 2',
        	ISP_Timelines_Frequency_when__c = 'Timeline frequency 2',
        	ISP_Where_to_Record_progress__c = 'Progress record location 2',
        	ISP_Note_if_Written_Implementation__c = 'The written note 2'
        );
        insert evalResp;

		// other support services
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and developername = 'Other_Services_Supports' ];
    	system.assertEquals(1, rt.size());
        
		evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
			ISP_Describe_Chosen_Services_Supports__c = 'Chosen services shall... 1',
			ISP_Supports_Services_Provided_by__c = 'Services provided by 1'
        );
        insert evalResp;

		// kPlan Services
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and developername = 'K_Plan_Services' ];
    	system.assertEquals(1, rt.size());
        
		evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
        	ISP_Service_Element_Service_Code__c = '149-OR100-Attendant Care-ADL',
        	ISP_Units__c = 52,
        	ISP_Unit_Type__c = 'Day(s)',
        	ISP_Per_Frequency__c = 'Week',
        	Label__c = 'Label 1',
        	ISP_Same_as_plan_year__c = true,
			ISP_Describe_Chosen_Services_Supports__c = 'Chosen services shall... 2',
        	ISP_Identified_needs__c = 'Needs identified include... 2',
        	ISP_Person_Preference_Service_Delivery__c = 'Lunchtime'
        );
        insert evalResp;

		// Waiver Services
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and developername = 'Waiver_Services' ];
    	system.assertEquals(1, rt.size());
        
		evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
//        	ISP_Service_Element_Service_Code__c = '149-OR406-Community Transition, Extend; per service',
        	ISP_Units__c = 52,
        	ISP_Unit_Type__c = 'Day(s)',
        	ISP_Per_Frequency__c = 'Week',
        	Label__c = 'Label 3',
        	ISP_Same_as_plan_year__c = true,
			ISP_Describe_Chosen_Services_Supports__c = 'Chosen services shall... 3',
        	ISP_Identified_needs__c = 'Needs identified include... 3',
        	ISP_Person_Preference_Service_Delivery__c = 'Lunchtime 3'
        );
        insert evalResp;

		// Community Trans Services
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and developername = 'Community_Transportation_Services' ];
    	system.assertEquals(1, rt.size());
        
		evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
        	ISP_Transportation_Type__c = 'Van Transportation',
        	ISP_Same_as_plan_year__c = true,
			ISP_Describe_Chosen_Services_Supports__c = 'Chosen services shall... 4'
        );
        insert evalResp;

		// Additional Services
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and developername = 'Additional_Chosen_Services' ];
    	system.assertEquals(1, rt.size());
        
		evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
        	ISP_Describe_service_setting__c = 'Service setting shall... 1',
        	ISP_Identified_needs__c = 'The needs identified include...',
			ISP_Person_Preference_Service_Delivery__c = 'Lunchtime 4'
        );
        insert evalResp;

		// Contributors
        rt = [ select id from Recordtype where sobjecttype = 'Evaluation_Response__c' and Name = 'Contributors & Signatures' order by CreatedDate asc];
    	system.assertEquals(1, rt.size());
        
		evalResp = new Evaluation_Response__c (
        	Case_Management_Plan__c = testIsp.Id,
        	recordtypeid = rt[0].Id,
        	ISP_Contributor_Name__c = 'John Hancock',
        	ISP_Title_Relationship_Person__c = 'Parent',
        	ISP_Contributor_Risk_Identification_Tool__c = true,
        	ISP_Signature_Required__c = true,
        	ISP_Present_at_Meeting__c = 'Yes',
        	ISP_Type_of_Contributor__c = 'TypeA',
			ISP_Contributor_Origin_Id__c = 'Origin'
        );
        insert evalResp;
	}
    
    static testMethod void testDesiredOutcomes() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.desiredOutcomes.size());
    	system.assertEquals('Desired result 1', ctl.desiredOutcomes[0].ISP_What_is_the_desired_result__c);
    }
	
    static testMethod void testEmploymentOutcomes() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.employmentOutcomes.size());
    	system.assertEquals('Desired result 2', ctl.employmentOutcomes[0].ISP_What_is_the_desired_result__c);
    }
    
    static testMethod void testOtherServicesSupports() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.otherServicesSupports.size());
    	system.assertEquals('Services provided by 1', ctl.otherServicesSupports[0].ISP_Supports_Services_Provided_by__c);
    }
    
    static testMethod void testKplanServices() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.kPlanServices.size());
    	system.assertEquals('149-OR100-Attendant Care-ADL', ctl.kPlanServices[0].ISP_Service_Element_Service_Code__c);
    }
    
    static testMethod void testWaiverServices() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.waiverServices.size());
    	system.assertEquals('Lunchtime 3', ctl.waiverServices[0].ISP_Person_Preference_Service_Delivery__c);
    }
    
    static testMethod void testCommTransServicess() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.commTransServices.size());
    	system.assertEquals('Chosen services shall... 4', ctl.commTransServices[0].ISP_Describe_Chosen_Services_Supports__c);
    }
    
    static testMethod void testAdditionalServices() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.additionalServices.size());
    	system.assertEquals('Lunchtime 4', ctl.additionalServices[0].ISP_Person_Preference_Service_Delivery__c);
    }
    
    static testMethod void testContributors() {
    	ORISPPrint ctl = initController();
    	
    	system.assertEquals(1, ctl.contributors.size());
    	system.assertEquals('John Hancock', ctl.contributors[0].ISP_Contributor_Name__c);
    }
    
    private static ORISPPrint initController() {
		ApexPages.StandardController sc;
		List<Case_Management_Plan__c> testIsp;
		
		testIsp = [select id from Case_Management_Plan__c where Name = 'Test plan 1' limit 1];
    	sc = new ApexPages.StandardController(testIsp[0]);
    	return new ORISPPrint(sc);
    }
	
    static testMethod void testGetPrintView() {
     	ORISPPrint ctl;
     	ApexPages.StandardController sc;
		List<Case_Management_Plan__c> testIsp;
		
		testIsp = [select id from Case_Management_Plan__c where Name = 'Test plan 1' limit 1];
    	sc = new ApexPages.StandardController(testIsp[0]);
    	ctl = new ORISPPrint(sc);
        System.assertEquals('<!--[if gte mso 9]><xml><w:WordDocument><w:View>Print</w:View><w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/></w:WordDocument></xml><![endif]>', ctl.getPrintView());
        
    }
}