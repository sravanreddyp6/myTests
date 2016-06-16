public without sharing class ServiceTrackingList {
    public String actionPlanId {get; set;}
    public date serviceTrackingMonth {get; set;}
    public String objResultId {get; set;}
    public String wsId {get; set;}
    public transient Action_Summary__c summary {get; set;}
    
    public list<ServiceObj> serviceTrakingResults {get; set;}

    public ServiceTrackingList(ApexPages.StandardController controller) {
    	this(controller.getRecord().Id);
    }
    
    public ServiceTrackingList(ID input) {
    	map<Id,Action_Plan_Objective__c> objectives;
        map<String, ServiceObj> serDetails = new map<String, ServiceObj>();
            	
    	if (input.getSObjectType().getDescribe().getName() == 'Action_Plan_Worksheet__c'){
	    	this.wsId = input;
	        Action_Plan_Worksheet__c ws = [select Name, Start_Date__c, Action_Plan__c, action_Plan__r.Status__c,        
	                                             Action_Plan__r.Service_Assignment__r.Admission__r.State__c, Action_Plan__r.Service_Assignment__c, 
	                                             Action_Plan__r.Service_Assignment__r.Admission__c, Action_Plan__r.Service_Assignment__r.Admission__r.Person_Being_Served__c 
	                                        from Action_Plan_Worksheet__c
	                                        where Id = : this.wsId];
	
	        this.actionPlanId = ws.Action_Plan__c;
	        this.serviceTrackingMonth = ws.Start_Date__c;
	        
	        objectives = new map<Id, Action_Plan_Objective__c> ([select Id, Former_Id__c, Type__c, Status__c, Description__c,
                                                                        CreatedDate, Effective_Date__c, Target_End_Date__c, sort_order__c, action_plan_goal__r.sort_order__c
									                               from  Action_Plan_Objective__c
									                              where Action_Plan_Goal__r.Action_Plan__c = : ws.Action_Plan__c
									                                and ((effective_date__c >= : ws.Start_Date__c) or (effective_date__c = null))
									                                and ((target_end_date__c < : ws.Start_Date__c.addMonths(1)) or (target_end_date__c = null))
									                                and Type__c IN ('Yes/No', 'Yes/No w/time') 
									                              order by type__c, sort_order__c, action_plan_goal__r.sort_order__c ]);
        } else if (input.getSObjectType().getDescribe().getName() == 'Action_Summary__c') {
	        summary = [select Id, Name, Comments__c, Duration__c, End_Date__c, Service_Assignment__c, Start_Date__c, Status__c, 
	                                            Unique_Check__c, Finalized_By__c, Finalized_Date__c, New_Version__c, Approver__c 
	                                       from Action_Summary__c where id = : input];
	        objectives = new Map<Id, Action_Plan_Objective__c>([
												                SELECT Id, Former_Id__c, Type__c, Status__c, Description__c,
												                       CreatedDate, Effective_Date__c, Target_End_Date__c, sort_order__c, action_plan_goal__r.sort_order__c
												                  FROM Action_Plan_Objective__c
												                 WHERE Effective_Date__c <= :summary.End_Date__c
												                   AND Target_End_Date__c >= :summary.Start_Date__c
												                   AND action_plan_goal__r.action_plan__r.Service_Assignment__c = :summary.Service_Assignment__c
												                   AND (action_plan_goal__r.action_plan__r.Status__c = 'Inactive Final'
												                    OR action_plan_goal__r.action_plan__r.Status__c = 'Active Final')
												                   AND action_plan_goal__r.action_plan__r.Effective_Date__c < :summary.End_Date__c
												                   AND action_plan_goal__r.action_plan__r.Target_Date__c >= :summary.Start_Date__c
												                   AND type__c IN ('Yes/No', 'Yes/No w/time')
												                ORDER BY type__c, sort_order__c, action_plan_goal__r.sort_order__c 
												            ]);
												            
	        for(Action_Plan_Objective__c obj : objectives.values() ) {
	            if (! serDetails.containsKey(String.ValueOf(obj.Id))) 
	               serDetails.put(String.ValueOf(obj.Id), new ServiceObj(obj) );
	        }									            
        }

        set<Id> objectiveIds = objectives.keySet();
        list<string> selectFields = new list<string>();
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Action_Objective_Result__c').getDescribe().Fields.getMap();
            if (fMap != null) {
                for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
                }
            }
        selectFields.addAll(new List<String>{'Action_Plan_Objective__r.Action_Plan_Goal__r.Action_Plan__c','Action_Plan_Objective__r.Description__c','Action_Plan_Objective__r.Type__c'});
        String strSQL =  'SELECT ' + String.join(selectFields, ',') + ' FROM Action_Objective_Result__c WHERE RecordType.Name = '+ ' \'Service_Objective\' ' + ' And Action_Plan_Objective__c in :objectiveIds order by Service_Date_Part__c nulls last, Service_Time__c nulls last';
        list<Action_Objective_Result__c> objectiveResults = (list<Action_Objective_Result__c>) Database.query(strSQL);

        for(Action_Objective_Result__c objectiveResult : objectiveResults){
        	if (! serDetails.containsKey(String.ValueOf(objectiveResult.Action_Plan_Objective__c))) 
        	   serDetails.put(String.ValueOf(objectiveResult.Action_Plan_Objective__c), new ServiceObj(objectives.get(objectiveResult.Action_Plan_Objective__c)) );
        	   
        	ServiceObj service = serDetails.get(String.ValueOf(objectiveResult.Action_Plan_Objective__c));
        	service.trackingResults.add(new ServiceTracking.ObjResultWrapper(objectiveResult));
        }
        
        for (ServiceObj ser : serDetails.values()){
        	ser.trackingResults.sort();
        } 
        this.serviceTrakingResults = new list<ServiceObj>();
        this.serviceTrakingResults.addAll(serDetails.values());
    }

    public pagereference editServiceData(){
            PageReference pr = Page.ServiceTracking;
            pr.getParameters().put('Id', this.objResultId);
            pr.getParameters().put('Edit', 'true');
            pr.setRedirect(true);
            return pr;
    }

    public pagereference newServiceData(){
    	boolean isDspPage = ApexPages.currentPage().getUrl().containsIgnoreCase('DSP') ? true : false;
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

    public pagereference submitTxnRequest(){
        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Edit Service';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = this.objResultId;
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
    }
    
    public class ServiceObj {
        public string QuestionID {get; set;}
        public string description {get; set;}
        public date effective_Date {get; set;}
        public date target_end_date {get; set;}
        public string type {get; set;}
        public string Status {get; set;}
        public date revisedDate {get; set;}
        
        public list<ServiceTracking.ObjResultWrapper> trackingResults {get; set;}

        public ServiceObj(Action_Plan_Objective__c tmpObj){
        	this.QuestionID = tmpObj.Id;
            this.description = tmpObj.Description__c;
            this.effective_Date = tmpObj.effective_Date__c;
            this.target_end_date = tmpObj.Target_end_date__c;
            this.type = tmpObj.type__c;
            this.status = tmpObj.Status__c;
            this.trackingResults = new list<ServiceTracking.ObjResultWrapper>();
            this.revisedDate = (tmpObj.Former_ID__c instanceOf ID) ? date.newinstance(tmpObj.CreatedDate.year(), tmpObj.CreatedDate.month(), tmpObj.CreatedDate.day()) : null;
        }
        
        /* public Integer hashCode() {
            return this.QuestionID.hashCode();
        }
        public boolean equals(Object obj) {
            if (obj instanceof ServiceObj) {
                ServiceObj o = (ServiceObj) obj;
                return this.QuestionID == o.QuestionID;
            }
            return false;
        }*/

    }
    
}