public with sharing class ORriskTool {
	
	private Apexpages.StandardController 	controller;
	public Case_Management_Plan__c cmPlan 	{get;set;}
	public ID cmID 							{ get; set; }
	public Case_Management_Plan__c thisCM 	{ get; set; }
	public string evalType 					{ get; set; }
	public string subCat 					{ get; set; }
	public string cat 						{ get; set; }
	public string evalSecId 				{ get; set; }
	public string evalSecType 				{ get; set; }
	public Boolean canEdit 					{ get; set; }
	
	public String key 						{ get; set; }
	
	public Boolean isBatchInsert 			{ get; set; }
	public Boolean isBatchUpsert 			{ get; set; }
	
	
    
    public ORriskTool(Apexpages.StandardController controller){
    	this.controller = controller;
    	if(!test.isRunningTest()){
			controller.addFields(new List<string>{
				'Service_Assignment__c',
				'Service_Assignment__r.Admission__c',
				'Service_Assignment__r.Admission__r.Person_being_Served__c',
				'Service_Assignment__r.Admission__r.Person_being_Served__r.FirstName',
				'Service_Assignment__r.Admission__r.Person_being_Served__r.LastName',
				'Service_Assignment__r.Admission__r.Person_being_Served__r.Prime_Number__c',
				'Status__c',
				'CDP_WA_Check_Apply_int_Employment__c',
				'CDP_WA_Check_Apply_nonworking__c',
				'CDP_NE_Check_Apply_Decision_Not_Explore__c',
				'KPR_Included_Services__c',
				'KPR_Additional_Services__c',
				'CreatedBy.Name',
				'LastModifiedDate',
				'ACK_isValid__c',
				'Agreement_isValid__c',
				'CDP_IsValid__c',
				'CCMS_isValid__c',
				'Desired_Outcomes_IsValid__c',
				'Differences_Isvalid__c',
				'Kplan_isValid__c',
				'KPR_isValid__c',
				'Leg_isValid__c',
				'NaturalSupports_isValid__c',
				'Profile_isValid__c',
				'PD_Isvalid__c',
				'Risk_Isvalid__c',
				'SPPC_IsValid__c',
				'Waiver_isValid__c',
				'ACK_Errors__c',
				'Agreement_Errors__c',
				'CDP_Errors__c',
				'CCMS_Errors__c',
				'Desired_outcomes_Errors__c',
				'Differences_Errors__c',
				'Kplan_Errors__c',
				'KPR_Errors__c',
				'Leg_Errors__c',
				'NaturalSupports_Errors__c',
				'Profile_Errors__c',
				'PD_Errors__c',
				'Risk_Errors__c',
				'SPPC_Errors__c',
				'Waiver_Errors__c',
				'PCI_HD_Errors__c',
			 	'PCI_CN_Errors__c',
			 	'PCI_LL_Errors__c',
			 	'PCI_PE_Errors__c',
			 	'PCI_ES_Errors__c',
			 	'PCI_EP_Errors__c',
			 	'PCI_SL_Errors__c',
			 	'PCI_CS_Errors__c',
			 	'PCI_RM_Errors__c',
			 	'PCI_RL_Errors__c',
			 	'PCI_HW_Errors__c',
			 	'PCI_FL_Errors__c',
			 	'PCI_PA_Errors__c',
			 	'PCI_CC_Errors__c',
			 	'PCI_SR_Errors__c',
			 	'PCI_MH_Errors__c',
			 	'PCI_BH_Errors__c',
			 	'PCI_TP_Errors__c',
			 	'PCI_ADT_Errors__c',
			 	'PCI_EM_Errors__c',
			 	'PCI_OP_Errors__c'
			});
		}
    	this.cmPlan = (Case_Management_Plan__c) controller.getRecord();
    	
    	cmID =  this.cmPlan.Id;
		evalType = ApexPages.currentPage().getParameters().get('evaltype');
		cat = ApexPages.currentPage().getParameters().get('Category');
		subCat = ApexPages.currentPage().getParameters().get('SubCategory');
		evalSecType = ApexPages.currentPage().getParameters().get('Category');
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		
    }
    
    private void batchSetup() {
		canEdit = true;
		subCat = '';
		evalSecType = '';
		evalSecId = UserInfo.getUserId() + '-' + Datetime.now().getTime();
	}
	public void batchInsert() {
		isBatchInsert = true;
		isBatchUpsert = false;
		batchSetup();
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
	
	}
	public void batchUpsert() {
		isBatchUpsert = true;
		isBatchInsert = false;
		batchSetup();
		key = evalType+'~'+cat+'~'+subCat+'~'+evalSecType;
		
	}
	
	
	
}