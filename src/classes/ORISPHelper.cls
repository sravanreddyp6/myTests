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
	public boolean showLink 				{get;set;}
	
	public boolean canFinalize {get; set;} //stub
	public boolean canRevise {get; set;} //stub
	
	public void finalize(){
		
		//stub
	}
	
	public void revise(){
		
		//stub
	}
	
	
	public Boolean canFinalizeISP {
		get {
			 return this.isp.Status__c == 'Inactive Draft'
			 		&& this.isp.PCI_HD_Errors__c == 'No Errors'
			 		&& this.isp.PCI_CN_Errors__c == 'No Errors'
			 		&& this.isp.PCI_LL_Errors__c == 'No Errors'
			 		&& this.isp.PCI_PE_Errors__c == 'No Errors'
			 		&& this.isp.PCI_SL_Errors__c == 'No Errors'
			 		&& this.isp.PCI_CS_Errors__c == 'No Errors'
			 		&& this.isp.PCI_RL_Errors__c == 'No Errors'
			 		&& this.isp.PCI_HW_Errors__c == 'No Errors'
			 		&& this.isp.PCI_FL_Errors__c == 'No Errors'
			 		&& this.isp.PCI_PA_Errors__c == 'No Errors'
			 		&& this.isp.PCI_CC_Errors__c == 'No Errors'
			 		&& this.isp.PCI_SR_Errors__c == 'No Errors'
			 		&& this.isp.PCI_MH_Errors__c == 'No Errors'
			 		&& this.isp.PCI_BH_Errors__c == 'No Errors'
			 		&& this.isp.PCI_TP_Errors__c == 'No Errors'
			 		&& this.isp.PCI_ADT_Errors__c == 'No Errors'
			 		&& this.isp.PCI_EM_Errors__c == 'No Errors'
			 		&& this.isp.PCI_OP_Errors__c == 'No Errors'
			 		//&& this.isp.ACK_isValid__c
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
	
	public Boolean canReviseISP {
		get {
			List<Case_management_Plan__c> latestDraft = [SELECT Id FROM Case_management_plan__c WHERE Service_Assignment__c = :this.isp.Service_Assignment__c AND Status__c= 'Inactive Draft' AND createdDate > :this.isp.createdDate LIMIT 1];
			return latestDraft.isEmpty() && this.isp.Status__c == 'Active Final';
		}
	}
	
	public ORISPHelper(Apexpages.StandardController controller){
		
		this.controller = controller;
		this.isp = (Case_Management_Plan__c) controller.getRecord();
		showLink = false;
		errorMap = new map<string,string>();
		handlePanels();
	}
	
	
	public PageReference finalizeISP() {
		this.isp.Status__c = 'Active Final';
		update this.isp;
		
		List<Case_Management_Plan__c> prevActiveFinal = [SELECT id, Status__c FROM Case_Management_Plan__c WHERE Service_Assignment__c = :this.isp.Service_Assignment__c AND Status__c = 'Active Final' AND Id !=: this.isp.id order by CreatedDate desc LIMIT 1]; //Sorting not needed in production
		if(!prevActiveFinal.isEmpty()){
			prevActiveFinal[0].Status__c = 'Inactive Final';
			update prevActiveFinal[0];
		}
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		if(page.getUrl().Contains('apex/ORcombinedISP')){
			params.put('mode', 'EDIT');
			params.put('id', this.isp.Id);
			params.put('section', '');
			page.setRedirect(true);
			return page;
		}else if(page.getUrl().Contains('apex/ORriskTool')){
			params.put('id', this.isp.Id);
			params.put('category', '');
			params.put('evalType', 'Risk Identification Tool');
			page.setRedirect(true);
			return page;
		}
		
		return null;
	}
	
	public pageReference reviseISP(){
		
		SavePoint sp = Database.SetSavePoint(); //initialize the save point here
		PageReference page = ApexPages.currentPage();
		string ispID = this.isp.id;
		FieldSet donotRevise =  SObjectType.Case_management_Plan__c.FieldSets.Do_Not_Revise;
		
		Case_Management_Plan__c newIsp = new case_Management_plan__c();
		if(page.getUrl().Contains('apex/ORcombinedISP')){
			newIsp = this.isp.clone(false);
			
		}else if(page.getUrl().Contains('apex/ORriskTool')){
			string query = Utility.getCreatableFieldsSOQL('Case_Management_Plan__c', 'Id =:ispID');
			system.debug('Query>>>>>>>>>1111'+query);
			Case_Management_Plan__c thisISP = Database.Query(query);
			newIsp = thisISP.clone(false);
		}
		
		newIsp.Status__c = 'Inactive Draft';
		for(Schema.FieldSetMember f : donotRevise.getFields()) {
			newIsp.put(f.getFieldPath(), f.getType() ==  Schema.DisplayType.Boolean ? false : null);
		}
		
		insert newIsp;
		
		
		
		
		
		list<Evaluation_Response__c> clonedResponses   = new List<Evaluation_Response__c>(); //clone evaluation response records
		list<Eval_Value__c> clonedValues 			   = new list<Eval_value__c>(); //clone eval value records to populate Risk tool
		list<Attachment> clonedattachments             = new list<Attachment>(); //Clone Attachments and populate the parentId with new record       
		
		//Evaluation Responses Clone
		set<string> responseRectypes = new set<string>{'Desired_Outcomes','Employment_Outcomes','K_Plan_Services', 'Other_Services_Supports', 'Transportation_Services','Waiver_Services', 'Additional_Chosen_Services', 'Contributors_Signatures','Evaluation'};
        FieldSet copyresponseFields = SObjectType.Evaluation_Response__c.FieldSets.ISPCloneResponses;
       
        String respQuery ='SELECT ';
        for(Schema.FieldSetMember f : copyresponseFields.getFields()) {
            respQuery +=f.getFieldPath() + ',';
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
     	
     	//Attachments to clone
     	for(Attachment a: [SELECT Name, Description, body FROM attachment WHERE ParentId =:this.Isp.Id]){
     		Attachment att = new Attachment();
     		att.Name = a.Name;
     		att.Description = a.Description;
     		att.body = a.body;
     		att.ParentId = newIsp.Id; //Assigning the parentId with new record id
     		clonedattachments.add(att);
     	}
     	
        										
        
        try{
    	  	if(!clonedResponses.isEmpty()){
            	insert clonedResponses;
            }
        	if(!clonedValues.isEmpty()){
        		insert clonedValues;
        	}
        	if(!clonedattachments.isEmpty()){
        		insert clonedattachments;
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
			params.put('section', 'hdSection');
			page.setRedirect(true);
			return page;
		}else if(page.getUrl().Contains('apex/ORriskTool')){
			params.put('id', newIsp.Id);
			params.put('category', '');
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
    				errorMap.put(s,'error');
    			}else{
    				errorMap.put(s,'success');
    			}
    			
    		}else{
    			errorMap.put(s,'warning');
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
		showLink = true;
		update this.isp;
		return null;
	}
	
	public void setLinkTrue(){
		showLink = true;
	}
	
	public pageReference redirect(){
		string sectionCat = ApexPages.CurrentPage().getParameters().get('targetSec');
		string isSection = ApexPages.CurrentPage().getParameters().get('isSection');
		
		if(isSection == 'true'){
			PageReference page = new PageReference('/apex/ORcombinedISP');
			Map<String, String> params = page.getParameters();
			params.clear();
			params.put('mode', 'EDIT');
			params.put('id', this.isp.Id);
			params.put('section', sectionCat);
			page.setRedirect(true);
			return page;
		}else if(isSection == 'false'){
			PageReference page2 =  new PageReference('/apex/ORriskTool');
			Map<String, String> params = page2.getParameters();
			params.clear();
			params.put('id', this.isp.Id);
			params.put('category', sectionCat);
			params.put('evalType', 'Risk Identification Tool');
			page2.setRedirect(true);
			return page2;
		}
		
		return null;
		
	}
	
	
	public String PCIPanelStatus { get { 
		if (this.isp.Status__c.Contains('Final'))
			return ('success');
		
		integer numBlank = 0;
		
		// check for at least 1 error and keep track of # blank on the way	
		if ( this.isp.PCI_HD_Errors__c != 'No Errors' )
			if (!String.isBlank(this.isp.PCI_HD_Errors__c) )
				return ('error');
			else
				numBlank += 1;
				
		if (  this.isp.PCI_CN_Errors__c != 'No Errors' )
			if (!String.isBlank(this.isp.PCI_CN_Errors__c) )
				return ('error');
			else
				numBlank += 1;
				
		if (  this.isp.PCI_LL_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_LL_Errors__c))
				return ('error');
			else
				numBlank += 1;
				
		if (  this.isp.PCI_PE_Errors__c != 'No Errors' )
			if (  !String.isBlank(this.isp.PCI_PE_Errors__c) )
				return ('error');
			else
				numBlank +=1 ;
					
		if (  this.isp.PCI_SL_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_SL_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.PCI_CS_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_CS_Errors__c))
				return ('error');
			else
				numBlank += 1;
				
		if (  this.isp.PCI_RL_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_RL_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
					
		if (  this.isp.PCI_HW_Errors__c != 'No Errors' )
			if (!String.isBlank(this.isp.PCI_HW_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.PCI_FL_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_FL_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_PA_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_PA_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_CC_Errors__c != 'No Errors' )
			if (  !String.isBlank(this.isp.PCI_CC_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
					
		if (  this.isp.PCI_SR_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_SR_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_MH_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_MH_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_BH_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_BH_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_TP_Errors__c != 'No Errors' )
			if (!String.isBlank(this.isp.PCI_TP_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_ADT_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_ADT_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_EM_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_EM_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
				
		if (  this.isp.PCI_OP_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PCI_OP_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
			
		// check for at least 1 incomplete sections
		if ( numBlank > 0 )
			return ('warning');
			
		// if we're still here, then they're all no-error
		return ('success');
		
	} }
	
	public String RiskPanelStatus { get {
		if (this.isp.Status__c.Contains('Final'))
			return ('success');
		
		integer numBlank = 0;
		
		for(string s: errorMap.keySet()){
    		if( errorMap.get(s) == 'error'){
    			return('error');
    		} else {
    			if ( errorMap.get(s) == 'warning' ) {
    				numBlank += 1;
    			} 
    		}
		}
		
		if ( numBlank > 0 )
			return 'warning';
		else
			return 'success';
			
	}}
	
	public string ISPPanelStatus { get {
		
		if (this.isp.Status__c.Contains('Final'))
			return ('success');
		
		integer numBlank = 0;
		if (  this.isp.PD_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.PD_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.Profile_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Profile_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.Desired_outcomes_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Desired_outcomes_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.CDP_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.CDP_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.Risk_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Risk_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.CCMS_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.CCMS_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.SPPC_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.SPPC_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.Kplan_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Kplan_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.Waiver_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Waiver_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.KPR_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.KPR_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.Differences_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Differences_Errors__c))
				return ('error');
			else
				numBlank +=1 ;

		if ( numBlank > 0 )
			return 'warning';
		else
			return 'success';
	}}
	
	
	public string ContribPanelStatus { get {

		integer numBlank = 0;
				
		if (  this.isp.Leg_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Leg_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
		if (  this.isp.Agreement_Errors__c != 'No Errors' )
			if ( !String.isBlank(this.isp.Agreement_Errors__c))
				return ('error');
			else
				numBlank +=1 ;
			
		// check for at least 1 incomplete sections
		if ( numBlank > 0 )
			return ('warning');
			
		// if we're still here, then they're all no-error
		return ('success');
		
	}}
	
    
}