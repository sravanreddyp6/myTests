public with sharing class AuthorizationTherapyCostNR {
    //comment added to create diff by AV
    Final String rateMissingMSG = 'You will not be able to save, There isn\'t an Authorization with the status of Final for this Service Assignment';
    public string saID { get; set; }

    public service_assignment__c theSA {get; set;}
    public Authorization__c authorization { get; set; }
    public boolean displayPopup {get; set;}
    public id ProcessId{get;set;} 
    public AuthorizationTherapyCostNR(ApexPages.StandardController controller) {

         // service assignment ID is passed in - get the other params needed for personal record connection
        authorization = (Authorization__c)controller.getRecord();
        saID = ApexPages.currentPage().getParameters().get('saID'); 
        ID authID = ApexPages.currentPage().getParameters().get('ID');
        List<Funding_Source__c> fsources;
        fsources = new List<Funding_Source__c>(); 
        if (authorization.id != null){
            theSA = [select id, admission__c, person_being_served__c, Service_Location__r.Room_and_Board_Rate__c, Service_Location__r.PRN_DS_Per_Hour__c, Service_Location__r.Per_Productive_Unit__c from service_assignment__c where id = :authorization.service_assignment__c LIMIT 1];            
        }
        else {
            theSA = [ select id, admission__c, person_being_served__c, person_being_served__r.name, Service_Location__r.Room_and_Board_Rate__c, Service_Location__r.PRN_DS_Per_Hour__c, Service_Location__r.Per_Productive_Unit__c from service_assignment__c where id = :saID LIMIT 1];
            authorization.recordtypeid = [select id from recordtype where SobjectType = 'Authorization__c' and developername = 'Costs_TherapyNR'].id;
            
            for(authorization__c a : [select id, rate__c from authorization__c where authorization_status__c = 'Active Final' and service_assignment__c = :saID and recordtype.developername = 'Funding_Source_Auth_NR']){
                authorization.rate__c = a.rate__c;
                authorization.Master_Authorization__c = a.id;
            }
            if (authorization.rate__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, rateMissingMSG));
                
            authorization.Person_Being_Served__c = theSA.person_being_served__c;
            authorization.service_assignment__c = theSA.id;
            authorization.Approval_Status__c = 'Not Submitted';
        }
        list<ProcessInstanceWorkitem> ProcessList = New list<ProcessInstanceWorkitem>();
            ProcessList = [Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: authorization.Id ];
            if(processlist.size()>0){
                ProcessId = ProcessList[0].Id;
            }
       // else
        //    
        displayPopup = false;

    }


    public pageReference redirectToView( ID authId, ID servAssign ) {
            PageReference pr = new PageReference('/apex/AuthorizationTherapyCostNRView?id=' + authId + '&saID=' + servAssign);
            pr.setRedirect( true);
            return pr;
    }
    
    public pageReference saveAuth() {
    	
                 
        List<String> fielderrs = new List<String>();
          
        if ( string.isblank(authorization.Case_Manager__c) ) {
            fielderrs.add('Please choose a Case Manager');  
        }   
        
        if ( authorization.Effective_Date_of_Cost_Therapy__c ==null ) {
            fielderrs.add('Please choose an Effective Date of Cost/Therapy');  
        }
         
        if ( authorization.Term_Date_of_Cost_Therapy__c == null ) {
            fielderrs.add('Please choose a Term Date of Cost/Therapy');
        }
         
        if (string.isBlank(authorization.Rate__c)) {
            fielderrs.add('Rate is blank');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, rateMissingMSG));
        }  
              
        if ( string.isblank(authorization.Staffing_Ratio_1_1__c) ) {
            fielderrs.add('Please choose a Staffing Ratio');  
        }
         
        if ( string.isblank(authorization.Number_of_Hrs_Expected__c) ) {
            fielderrs.add('Please choose Number of Hrs. Expected');  
        }
        
        if ( string.isblank(authorization.Auth_Units_Grand_Total__c)) {
            fielderrs.add('Please calculate Auth Units Grand Total');
        }
        
        if ( string.isblank(authorization.Total_Weekly_Auth_Therapy_Units__c)) {
            fielderrs.add('Please calculate Total Weekly Auth Therapy Units');
        }
        
        
                                             
        if ( fielderrs.size() > 0 ) {
        
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in these fields to finalize the authorization:'));
            for ( String e : fielderrs) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e));
            }
            return null;
        }
      
        upsert authorization;
        
        return redirectToView( authorization.Id, saID );
                     
        
    }
    public pageReference cancelAuth() {
            if(authorization.Id != null){
                PageReference pr = new PageReference('/apex/AuthorizationTherapyCostNRView?id=' + authorization.Id);
                pr.setRedirect( true);
                return pr;
            }
                PageReference pr = new PageReference('/apex/ServiceAssignmentEditNew?id=' + theSA.Id);
                pr.setRedirect( true);
                return pr;
            
    }
    public pageReference editAuth() {
            PageReference pr = new PageReference('/apex/AuthorizationTherapyCostNREdit?id=' + authorization.Id);
            pr.setRedirect( true);
            return pr;
    }      
    
    public pageReference disregardAuth(){
    	
		User integrateUser = [ SELECT Id FROM User WHERE Username LIKE 'integration%' LIMIT 1];
		Id integrateUserId = integrateUser.Id;
		DateTime n = DateTime.now();
		try{
			// get the auth without any other changes that may be present on the screen
			Authorization__c a = [SELECT Id,Person_Being_Served__c,Locked__c,No_Approval_Needed__c, Authorization_Status__c FROM Authorization__c WHERE Id =:authorization.Id ]; // To make sure only Status field is in scope.

			Boolean resetLocked = a.Locked__c;

			// briefly unlock to get around validation rule
			if (resetLocked) {
				a.No_Approval_Needed__c  = false;
				a.Locked__c  = false;
				update a;
			}

			a.Approval_Status__c = 'Disregard';
			if (resetLocked)
			a.No_Approval_Needed__c  = resetLocked;
			update a;

			// Create a task reminder that indicates who marked the Progress Note as one to "Disregard."
			Task t = new Task(Subject = 'Disregard', Status = 'Completed', Priority = 'Normal', OwnerId = integrateUserId, Description = 'Cost & Therapy disregarded by ' + UserInfo.getName() + ', ' + n.format('MM/dd/yyyy hh:mm a'), WhoId = a.Person_Being_Served__c, WhatId = a.Id, ActivityDate = n.date());
			insert t;

			return redirectToView( a.Id, saID );
 
		}
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
	}
    /** Finalize Validations And then rendering of the finalize popup on the screen Logic**/ 
    public pagereference showPopup() { 
    	List<String> fielderrs = new List<String>();
    	  
        if ( authorization.Days_Authorized_from__c == null) {
            fielderrs.add('You must fill Days Authorized From before finalizing.');
        }
        if ( authorization.Days_Authorized_To__c == null) {
            fielderrs.add('You must fill Days Authorized To before finalizing.');
        }
                                             
        if ( fielderrs.size() > 0 ) {
        
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in these fields to finalize the authorization:'));
            for ( String e : fielderrs) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e));
            }
            return null;
        }
            displayPopup = true; 
            return null;
        }
    public void closePopup() {        
        displayPopup = false;    
    }
     public pagereference SubmitForApp(){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(authorization.id);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setProcessDefinitionNameOrId('Costs_Therapy_Authorization');
        req1.setSkipEntryCriteria(true);
        list<id> listids = new list<id>();
        listids.add(authorization.Approval_User__c);
        req1.setNextApproverIds(listids);
        try{
            Approval.ProcessResult result = Approval.process(req1);
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'The following exception has occurred: ' + e.getMessage()));
        }
        pagereference pageref = new Pagereference('/apex/AuthorizationTherapyCostNRView?id='+authorization.id+'&IsSubmitted=Yes');
        pageref.setredirect(true);
        return pageref;
    }  
    public void myFinal(){
        displayPopup = false;
        try{
        	authorization.Approval_Status__c = 'Approved';
            update authorization;
        }
            catch(DMLException e){
                authorization.addError(e.getMessage());
            }      
        
    }
        transient public List<ProcessInstanceHistory> approvalHistory;
		public List<ProcessInstanceHistory> getApprovalHistory () {
		approvalHIstory = new List<ProcessInstanceHistory>();
		List<ProcessInstance> pi = [
			SELECT Id, (SELECT Id, actorid, actor.name, StepStatus, Comments, createddate
			              FROM StepsAndWorkitems
			            ORDER BY createddate desc)
			FROM ProcessInstance where  targetobjectid = :authorization.Id
			ORDER BY createddate desc];

		for ( ProcessInstance p : pi ) {
			approvalHistory.addAll (p.stepsandworkitems);
		}
		return approvalHistory;

    }
}