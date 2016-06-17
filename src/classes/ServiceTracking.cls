public without sharing class ServiceTracking {
    private static final boolean isDspPage = ApexPages.currentPage().getUrl().containsIgnoreCase('DSP') ? true : false;
    public String wsId {get;set;}
    public Action_Plan_Worksheet__c ws {get;set;}
    
    public ServiceTracking() {
         this((Id)ApexPages.currentPage().getParameters().get('Id'));
    }
        
    public ServiceTracking(ID wsID, ID objID) {
    	this.wsId = wsID;
        this.ws = [select id, Name, Start_Date__c, Action_Plan__c, action_Plan__r.Status__c,        
                          Action_Plan__r.Service_Assignment__r.Admission__r.State__c, Action_Plan__r.Service_Assignment__c, 
						  Action_Plan__r.Service_Assignment__r.Admission__c, Action_Plan__r.Service_Assignment__r.Person_Being_Served__c 
                     from Action_Plan_Worksheet__c
					where Id = :wsID];
        if ( ws != null ) {
	        Action_Objective_Result__c objectiveResult = new Action_Objective_Result__c();	        
	        objectiveResult.RecordTypeId = [select id from recordtype where DeveloperName='Service_Objective' and SobjectType='Action_Objective_Result__c' limit 1].id;
            this.objResultWrapper = new ObjResultWrapper(objectiveResult);
            this.objResultWrapper.action_Plan = ws.Action_Plan__c;
            this.objResultWrapper.service_Time = system.now();
            this.objResultWrapper.createdBy = UserInfo.getName();
            this.editMode = true;
         
            this.objectives = [select Id, Description__c, effective_Date__c, Target_end_date__c, type__c, Status__c  
			                   from  Action_Plan_Objective__c
			                  where Action_Plan_Goal__r.Action_Plan__c = : ws.Action_Plan__c
			                    and ((effective_date__c >= : ws.Start_Date__c) or (effective_date__c = null))
			                    and ((target_end_date__c < : ws.Start_Date__c.addMonths(1)) or (target_end_date__c = null))
			                    and Type__c IN ('Yes/No', 'Yes/No w/time') 
			                    and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
			                  order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
                                 
        }
    }

    //this is called for view/edit for a known objective tracking record
    public ServiceTracking(Id actionObjectiveResultId) {
        if (!actionObjectiveResultId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Action_Objective_Result__c')) this(actionObjectiveResultId, null);
    	else {
	        list<string> selectFields = new list<string>();
	        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Action_Objective_Result__c').getDescribe().Fields.getMap();
	            if (fMap != null) {
	                for (Schema.SObjectField ft : fMap.values()){
	                    Schema.DescribeFieldResult fd = ft.getDescribe();
	                    selectFields.add(fd.getName());
	                }
	            }
	        selectFields.addAll(new List<String>{'Action_Plan_Objective__r.Action_Plan_Goal__r.Action_Plan__c','Action_Plan_Objective__r.Description__c','Action_Plan_Objective__r.Type__c', 'CreatedBy.Name'});
	
	        String strSQL =  'SELECT ' + String.join(selectFields, ',') + ' FROM Action_Objective_Result__c WHERE Id = \'' + actionObjectiveResultId + '\'';
	        Action_Objective_Result__c objectiveResult = (Action_Objective_Result__c) Database.query(strSQL)[0];
	        this.objResultWrapper = new ObjResultWrapper(objectiveResult);
	        
	        this.objectives = [select Id, Description__c, effective_Date__c, Target_end_date__c, type__c, Status__c  
	                               from  Action_Plan_Objective__c where id =: objectiveResult.Action_Plan_Objective__c];
	                               
		    this.ws = [select   id, Name, Start_Date__c, Action_Plan__c, action_Plan__r.Status__c,        
		                        Action_Plan__r.Service_Assignment__r.Admission__r.State__c, Action_Plan__r.Service_Assignment__c, 
		                        Action_Plan__r.Service_Assignment__r.Admission__c, Action_Plan__r.Service_Assignment__r.Person_Being_Served__c
	                       from Action_Plan_Worksheet__c 
	                      where action_plan__c =: this.objResultWrapper.action_Plan and recordtype.developername = 'Monthly_Service_Result' order by Start_Date__c desc limit 1];
	        this.wsId = this.ws.id;                                                                                                                            
	        this.editMode = false;
	        
	        if (!isDspPage) {
                this.editMode = ApexPages.currentPage().getParameters().get('Edit') == 'true';
	        }
    	}
    }

    private list<Action_Plan_Objective__c> objectives;
    public String getObjectives(){
    	return JSON.serialize(this.objectives);
    }
        
	public ObjResultWrapper objResultWrapper {get;set;}
	public boolean editMode {get; set;}
	
	public List<SelectOption> getServiceProvidedOpts() {
	    List<SelectOption> options = new List<SelectOption>();
	    options.add(new SelectOption('','--Select--'));
	    options.add(new SelectOption('Yes','Yes'));
	    options.add(new SelectOption('No','No'));
	    return options;
	}
	public List<SelectOption> getServiceStatusOpts() {
	    List<SelectOption> options = new List<SelectOption>();
	    options.add(new SelectOption('','--Select--'));
	    options.add(new SelectOption('Leave/Absent','Leave/Absent'));
	    options.add(new SelectOption('Sick','Sick'));
	    options.add(new SelectOption('Hospitalized','Hospitalized'));
	    options.add(new SelectOption('Holiday','Holiday'));
	    return options;
	}
	
	public class ObjResultWrapper implements Comparable {
	    public Id id {get;set;}
	    public datetime service_Time {get;set;}
	    public String service_Date  {get;set;}    
	    public String reason {get;set;}
	    public String service_Provided {get;set;}
	    public String initials {get;set;}
	    public String status {get;set;}
	    public Id action_Plan_Objective {get;set;}
	    public String action_Plan_Objective_Description {get;set;}
	    public String action_Plan_Objective_Type {get;set;}
	    public String recordTypeId {get;set;}
	    public Id action_Plan {get;set;}
	    public String createdBy {get;set;}
	    public Id createdById {get;set;}
	    
	    public ObjResultWrapper(){}
	    public ObjResultWrapper(Action_Objective_Result__c result){
	        this.id = result.id;
	        this.service_Time = result.Service_Time__c;
	        this.service_Date = (result.Service_Date_Part__c == null ? '' : result.Service_Date_Part__c.format());
	        this.reason = result.Reason__c;
	        this.service_Provided = result.Service_Provided__c;
	        this.initials = result.Initials__c;
	        this.status = result.Status__c;
	        this.action_Plan_Objective = result.Action_Plan_Objective__c;
	        this.action_Plan_Objective_Description = result.Action_Plan_Objective__r.Description__c;
	        this.action_Plan_Objective_Type = result.Action_Plan_Objective__r.Type__c;
	        this.RecordTypeid = result.RecordTypeid;
	        this.action_Plan = (result.id != null ? result.Action_Plan_Objective__r.Action_Plan_Goal__r.Action_Plan__c : null);
	        this.createdBy = (result.createdBy == null ? UserInfo.getName() : result.createdBy.Name );
	        this.createdById = (result.createdBy == null ? UserInfo.getUserId() : result.createdBy.Id );
	    }
	    
	    public Action_Objective_Result__c ObjResultSObject(){
	        return new Action_Objective_Result__c(
	                    id = this.id,
	                    Service_Time__c = this.service_time,
	                    Service_Date_Part__c = (String.isEmpty(this.service_Date)? null : Date.parse(this.service_Date)),
	                    Reason__c = this.reason,
	                    Service_Provided__c = this.service_Provided,
	                    Initials__c = this.initials,
	                    Status__c = this.status,
	                    Action_Plan_Objective__c = this.action_Plan_Objective,
	                    recordTypeId = this.recordTypeId );
	    }
	    
        public Integer compareTo(Object anotherResultObject) {
            ObjResultWrapper anotherResult = (ObjResultWrapper) anotherResultObject;
            // it the objective is of type Y/N w/time, then the datetime to determine the sort else the date 
            if (String.IsNotBlank(this.action_Plan_Objective_Type) && this.action_Plan_Objective_Type.equalsIgnoreCase('Yes/No')){
                if (Date.parse(this.service_Date) < Date.parse(anotherResult.service_Date)) {
                    return -1;
                } else if (Date.parse(this.service_Date) == Date.parse(anotherResult.service_Date)) {
                    return 0;
                } else {
                    return 1;
                }               
            } else if (String.IsNotBlank(this.action_Plan_Objective_Type) && this.action_Plan_Objective_Type.equalsIgnoreCase('Yes/No w/time')){
                if (this.service_Time < anotherResult.service_Time) {
                    return -1;
                } else if (this.service_Time == anotherResult.service_Time) {
                    return 0;
                } else {
                    return 1;
                }
            }
            return 0;            
        }
	}
    
    public pagereference mySave(){
        if (isDspPage){
	        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
	        txn.request_type__c = 'Update Service';
	        txn.requested_date_time__c = DateTime.Now();
	            
	        Map<String, String> inputs = new Map<String, String>{'payload.ActionObjResult' => json.serialize(this.objResultWrapper.ObjResultSObject())};
	        txn.input_params__c = json.serialize(inputs);
	        system.debug('form values: ' + inputs);
	       try { 
	            insert txn;
	            PageReference pr =  Page.DSPServiceTracking;
	            pr.getParameters().put('txnID', txn.ID);
	            pr.setRedirect(true);
	            return pr;
	        } catch (Exception e) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	            return null;
	        }
        } else {
        	Action_Objective_Result__c obj = this.objResultWrapper.ObjResultSObject();
        	upsert obj;
            PageReference pr = Page.ServiceTracking;
            pr.getParameters().put('Id', obj.Id);
            pr.setRedirect(true);
            return pr;
        }        
    }
    
    public pagereference myEdit(){
        if (isDspPage){
	        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
	        txn.request_type__c = 'Edit Service';
	        txn.requested_date_time__c = DateTime.Now();
	        txn.input_params__c = this.objResultWrapper.Id;
	       try { 
	            insert txn;
	            PageReference pr = Page.DSPServiceTracking;
	            pr.getParameters().put('txnID', txn.ID);
	            pr.setRedirect(true);
	            return pr;
	        } catch (Exception e) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	            return null;
	        }
        } else {
        	this.editMode = true;
        	return null;
        }
        
    }
    
    public pagereference servicesList(){
        if (isDspPage){
	        DSPSubmitTxn txnService = new DSPSubmitTxn();
	        txnService.requestType = 'ServiceList';
	        txnService.inputArgs = this.objResultWrapper.action_Plan;
	        return txnService.submitTxnRequest();
        }else {
            PageReference pr = Page.ServiceTrackingList;
            pr.getParameters().put('Id', this.wsId);
            pr.setRedirect(true);
            return pr;
        }
    }

    public pagereference newServiceData(){
        if (isDspPage){
            DSPSubmitTxn txnService = new DSPSubmitTxn();
            txnService.requestType = 'Service';
            txnService.inputArgs = this.wsId;
            return txnService.submitTxnRequest();
        }else {
            PageReference pr = Page.ServiceTracking;
            pr.getParameters().put('Id', this.wsId);
            pr.setRedirect(true);
            return pr;
        }       
    }

}