/*
	Put all the common functions here
	Panel Coloring
	Finalize
	Revise

*/

public with sharing class ORISPHelper {
	
	private Apexpages.StandardController 	controller;
    public  Case_Management_plan__c isp 	{get; set;}
	public Map<string, string> errorMap		{get; set;}
	public boolean noriskToolErrors 		{get; set;}
	private final set<string> 	cats 	= 	new set<string>{'Health and Medical', 'Safety','Behavior','Mental Health', 'Financial'};
	
	
	public Boolean canFinalize {
		get {
			 return this.isp.Status__c == 'Inactive Draft' 
			 		&& this.isp.ACK_isValid__c
			 		&& this.isp.Agreement_isValid__c
			 		&& this.isp.CDP_IsValid__c
			 		&& this.isp.CCMS_isValid__c
			 		&& this.isp.Desired_Outcomes_IsValid__c
			 		&& this.isp.Differences_Isvalid__c
			 		&& this.isp.Kplan_isValid__c
			 		&& this.isp.KPR_isValid__c
			 		&& this.isp.Leg_isValid__c
			 		&& this.isp.NaturalSupports_isValid__c
			 		&& this.isp.Profile_isValid__c
			 		&& this.isp.PD_Isvalid__c
			 		&& this.isp.Risk_Isvalid__c
			 		&& this.isp.SPPC_IsValid__c
			 		&& this.isp.Waiver_isValid__c
			 		&& noriskToolErrors;
		}
	}
	
	public Boolean canRevise {
		get {
			return this.isp.Status__c == 'Active Final';
		}
	}
	
	public ORISPHelper(Apexpages.StandardController controller){
		
		this.controller = controller;
		this.isp = (Case_Management_Plan__c) controller.getRecord();
		errorMap = new map<string,string>();
		handlePanels();
	}
	
	
	public PageReference finalize() {
		this.isp.Status__c = 'Active Final';
		update this.isp;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		if(page.getUrl().Contains('apex/ORcombinedISP')){
			params.put('mode', 'EDIT');
			params.put('id', this.isp.Id);
			params.put('section', 'planDates');
			page.setRedirect(true);
			return page;
		}else if(page.getUrl().Contains('apex/ORriskTool')){
			params.put('id', this.isp.Id);
			params.put('category', 'Health and Medical');
			params.put('evalType', 'Risk Identification Tool');
			page.setRedirect(true);
			return page;
		}
		
		return null;
	}
	
	public pageReference revise(){
		
		SavePoint sp = Database.SetSavePoint(); //initialize the save point here
		PageReference page = ApexPages.currentPage();
		string ispID = this.isp.id;
		Case_Management_Plan__c newIsp = new case_Management_plan__c();
		if(page.getUrl().Contains('apex/ORcombinedISP')){
			newIsp = this.isp.clone(false);
		}else if(page.getUrl().Contains('apex/ORriskTool')){
			string query = Utility.getCreatableFieldsSOQL('Case_Management_Plan__c', 'Id =:ispID');
			system.debug('Query>>>>>>>>>'+query);
			Case_Management_Plan__c thisISP = Database.Query(query);
			newIsp = thisISP.clone(false);
		}
		
		newIsp.Status__c = 'Inactive Draft';
		insert newIsp;
		this.isp.Status__c = 'Inactive Final';
		update this.isp;
		
		
		list<Evaluation_Response__c> clonedResponses   = new List<Evaluation_Response__c>(); //clone evaluation response records
		list<Eval_Value__c> clonedValues 			   = new list<Eval_value__c>(); //clone eval value records to populate Risk tool
		
		//Evaluation Responses Clone
		set<string> responseRectypes = new set<string>{'Desired_Outcomes','Employment_Outcomes','K_Plan_Services', 'Other_Services_Supports', 'Transportation_Services','Waiver_Services', 'Additional_Chosen_Services, Contributors_Signatures,Evaluation'};
        FieldSet copyresponseFields = SObjectType.Evaluation_Response__c.FieldSets.ISPCloneResponses;
       
        String respQuery ='SELECT ';
        for(Schema.FieldSetMember f : copyresponseFields.getFields()) {
            respQuery +=f.getFieldPath() + ', ';
        }
		
        respQuery += 'Name, RecordType.Name FROM Evaluation_Response__c WHERE Case_Management_Plan__c =:ispID AND RecordType.DeveloperName IN:responseRectypes';
        list<Evaluation_Response__c> ispResponses = database.query(respQuery);
        if(ispResponses!=null){
            for(Evaluation_Response__c erp : ispResponses){
                Evaluation_Response__c newRec = erp.clone(false);
                newRec.Case_Management_plan__c = newIsp.Id;
                clonedResponses.add(newRec);
            }
        }
        
        // Eval Value Records Clone
     	String sectionId = 	UserInfo.getUserId() + '-' + String.valueOf(DateTime.now().getTime());
     	for(Eval_Value__c val: [SELECT Id, Boolean__c, Currency__c, Date_time__c, Eval_Record_Number__c, Eval_Section_type__c, EVal__c, Number_No_Decimal__c,Text_Over_250__c, Text_Under_250__c, What_ID_Object__c FROM Eval_Value__c WHERE What_ID__c =: this.Isp.Id AND What_ID_Object__c = 'Case_Management_Plan__c']){
     		Eval_Value__c v 		= val.Clone(false);
     		v.What_ID__c    		= newIsp.Id;
     		v.Eval_Section_Id__c	= sectionId;
     		
     		clonedValues.add(v);
     	}
        										
        
        try{
    	  	if(clonedResponses.size() > 0){
            	insert clonedResponses;
            }
        	if(clonedValues.size() > 0){
        		insert clonedValues;
        	}
        }
        catch(DMLException e){
        	Database.rollback(sp); //Making sure to roll back all changes in this transaction
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There is an error in Revising the Oregon Combined ISP. Please Contact your Administrator'));
        	return null;
        }
		
	//	PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		if(page.getUrl().Contains('apex/ORcombinedISP')){
			params.put('mode', 'EDIT');
			params.put('id', newIsp.Id);
			params.put('section', 'planDates');
			page.setRedirect(true);
			return page;
		}else if(page.getUrl().Contains('apex/ORriskTool')){
			params.put('id', newIsp.Id);
			params.put('category', 'Health and Medical');
			params.put('evalType', 'Risk Identification Tool');
			page.setRedirect(true);
			return page;
		}
		
		return null;
	}
	
	private void handlePanels(){
    	
    	List<Eval_Value__c> vals = [SELECT Id, Eval__r.Field_Name__c, Eval__r.category__c, Text_Over_250__c, Boolean__c, What_Id__c FROM Eval_Value__c WHERE Eval__r.Category__c IN: cats AND What_ID__c = :isp.Id AND What_ID_Object__c = 'Case_Management_Plan__c' AND Eval__r.Field_name__c = 'IsValid'];
    	Map<String, set<Boolean>> catValueMap = new Map<string, set<Boolean>>();
    	
    	for(string s : cats){
    		catValueMap.put(s, new set<Boolean>());
    	}
    	
    	for(Eval_value__c v: vals){
    		catValueMap.get(v.Eval__r.category__c).add(v.Boolean__c);
    	}
    	
    	for(string s : cats){
    		if(catValueMap.containsKey(s) && !catValueMap.get(s).isEmpty()){
    			if(catValueMap.get(s).Contains(false)){
    				errorMap.put(s,'-error');
    			}else{
    				errorMap.put(s,'-success');
    			}
    			
    		}else{
    			errorMap.put(s,'');
    		}
    	}
    	
    	noriskToolErrors = true;
    	for(string s: errorMap.keySet()){
    		if(errorMap.get(s) == '' || errorMap.get(s) == '-error'){
    			noriskToolErrors = false;
    			break;
    		}
    	}
    	
 
    }
    
    public pageReference refresh(){
		handlePanels();
		update this.isp;
		return null;
	}
    
}