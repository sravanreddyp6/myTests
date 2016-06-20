public with sharing class ORriskTool {
	
	private Apexpages.StandardController controller;
	public Case_Management_Plan__c cmPlan {get;set;}
	public ID cmID { get; set; }
	public Case_Management_Plan__c thisCM { get; set; }
	public string evalType { get; set; }
	public string subCat { get; set; }
	public string cat { get; set; }
	public string evalSecId { get; set; }
	public string evalSecType { get; set; }
	public Boolean canEdit { get; set; }
	//public Id currentAssessId { get; set; }
	public String key { get; set; }
	
	
	public Boolean isBatchInsert { get; set; }
	public Boolean isBatchUpsert { get; set; }
	
    
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
				'CreatedBy.Name'
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
    
    public ORriskTool(){
    	
    	
    	
    	
    	
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