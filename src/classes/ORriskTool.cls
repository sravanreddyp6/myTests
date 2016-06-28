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
	
	public Map<string, string> errorMap		{ get; set; }
    
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
		
		errorMap = new map<string,string>();
		handlePanels();
    }
    
    private void handlePanels(){
    	set<string> cats = new set<string>{'Health and Medical', 'Safety','Behavior','Mental Health', 'Financial'};
    	List<Eval_Value__c> vals = [SELECT Id, Eval__r.Field_Name__c, Eval__r.category__c, Text_Over_250__c, Boolean__c, What_Id__c FROM Eval_Value__c WHERE Eval__r.Category__c IN: cats AND What_ID__c = :cmID AND What_ID_Object__c = 'Case_Management_Plan__c' AND Eval__r.Field_name__c = 'IsValid'];
    	Map<String, set<Boolean>> catValueMap = new Map<string, set<Boolean>>();
    	
    	for(string s : cats){
    		catValueMap.put(s, new set<Boolean>());
    	}
    	
    	for(Eval_value__c v: vals){
    		catValueMap.get(v.Eval__r.category__c).add(v.Boolean__c);
    	}
    	
    	for(string s : cats){
    		if(catValueMap.containsKey(s)){
    			if(catValueMap.get(s).Contains(false)){
    				errorMap.put(s,'-error');
    			}else{
    				errorMap.put(s,'-success');
    			}
    			
    		}else{
    			errorMap.put(s,'');
    		}
    	}
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
	
	public pageReference refresh(){
		handlePanels();
		return null;
	}
	
	
	
}