public with sharing class Assessment_IssaForm {
   public string glbListSeperator {get{return ';';} set;}
   public string glbItemSeperator {get{return '__';} set;}
   public boolean hasErrorOnFinalize {get; set;} 

    public List<id> DomainsInScopeIDs = new List<id>();
    public List<id> QuestionsInScopeIDs = new List<id>();
    public List<id> OptionsInScope = new List<id>();
    public List<Assessment_Response__c> CurrentResps = new List<Assessment_Response__c>();
    public List<Assessment_Response__c> getCurrentResps(){ return CurrentResps;}
    
    public Map<id, Assessment_Response__c> mapCurrentResps {get;set;}
    
    public List<WrappedResponse> listOfWrappedResponses { get; set; }
    public List<WrappedResponseLists> listOfWrappedResponseLists { get; set; }        
     
    public Map<id, List<SelectOption>> mapOptions = new Map<id, List<SelectOption>>();
    public Map<id, List<SelectOption>> getMapOptions(){return mapOptions ;}
    public Map<Id, WrappedSelectOptions> mapWrappedSelectOptions { get; set; }
    
    string assessID = ApexPages.currentPage().getParameters().get('id');
    public string thetest{get;set;}
    
    public map<string, List<string>> mapQuestions = new map<string, List<string>>();
    
    public map<string, List<string>> getMapQuestions(){ return mapQuestions ;}

    
    public map<id, boolean> mapDomainHasRisk = new map<id, boolean>();
    public map<id, boolean> getmapDomainHasRisk  (){ return mapDomainHasRisk ;}    
    
    Public List<Assessment_Domain__c> DomainsInScope = new List<Assessment_Domain__c>();
    Public List<Assessment_Domain__c> getDomainsInScope() {return DomainsInScope;}


    public Assessment__c assessment { get; set; }
    //dang page
    public ApexPages.standardController stdController;

  
    public boolean editMode{get; set;}
    public string mode{get; set;}
    public List<Assessment__c> AllAsses = new List<Assessment__c>();
    public List<Assessment__c> getAllAsses(){return AllAsses ;}

  //  public List<String> lstRecDayServicesStaffingRatio {get; set;}
  //  public List<String> getlstRecDayServicesStaffingRatio(){return lstRecDayServicesStaffingRatio ;}
    
    
    

    
    public Boolean canEditRisk { get {
        
     List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :assessment.Id ];
		System.debug('acls.size(): ' + acls.size());
        if (acls.size() > 0) {
            return acls[0].HasEditAccess;
        } else { return false;} 
        
    } set; }
    
    public Boolean canFinalize { get {
        // do not allow level 1 or 2 to finalize
        return (!isUserLevel1or2());
        }
        set;
    }
    

    
    public Boolean staffingRatioInFlavor {
        get {
                return assessment.Admission__r.State__c=='MN';
        }
    }
    public Boolean dayServicesInFlavor {
        get {
                return assessment.Admission__r.State__c=='MN' || assessment.Admission__r.State__c=='IN';
        }
    }
    public Boolean showConfirmationButton {
        get {
            for (Acknowledgment__c c: assessment.Acknowledgments__r) {
                if (c.User__c == UserInfo.getUserId() && assessment.ID == c.Assessment__c) {
                    return false;
                }
            }
            if(assessment.status__c != 'Active Final'){ return false;}
            return true;
        }
    }
    
    public PageReference myEdit() {
    
        mode = 'edit';
        return null;
    
    }    
	
	public class WrappedSelectOptions {
		public Boolean isYesNo { get; set; }
		public List<SelectOption> listOfSelectOptions { get; set; }
		
		public WrappedSelectOptions(List<SelectOption> l) {
			listOfSelectOptions = l;
			if(listOfSelectOptions.size()>0) {
				isYesNo = true;
			}
			else {
				isYesNo = false;
			}
		}
		
	}
	
	public class WrappedResponse implements comparable {
		public Assessment_Question__c theQuestion { get; set; }
		public Id theQuestionId { get; set; }
		public Assessment_Response__c theAR { get; set; }
		
		public WrappedResponse(Id aqId, Assessment_Response__c ar) {
			theQuestionId = aqId;
			theAR = ar;
		}

		public Integer compareTo(Object compareTo) {
			
			WrappedResponse compareToWR = (WrappedResponse) compareTo; 
			
			Integer returnValue = 0;
			if(theQuestion.Id > compareToWR.theQuestion.Id) {
				returnValue = 1;
			}
			if(theQuestion.Id < compareToWR.theQuestion.Id) {
				returnValue = -1;
			}

			return returnValue;
		}
		
	}
	
	
	public class WrappedResponseLists {
		public Map<Id, List<Assessment_Response__c>> mapRespLists { get; set; }
		
		
		public WrappedResponseLists(List<WrappedResponse> lwr) {
			lwr.sort();
			
			List<Assessment_Response__c> arList = new List<Assessment_Response__c>();
			Id previousQuestionId;
			
			for(Integer i = 0; i < lwr.size(); i++) {
				if(lwr[i].theQuestion.Id!=previousQuestionId && previousQuestionId!=null) {
					mapRespLists.put(previousQuestionId, arList);
					arList.clear();
				}
				
				if(i==lwr.size()) {
					mapRespLists.put(lwr[i].theQuestion.Id, arList);
				}
				
				arList.add(lwr[i].theAR);
				
				previousQuestionId = lwr[i].theQuestion.Id;
			}
		}
		
	}
	
    
    public Assessment_IssaForm(ApexPages.StandardController controller) {

        this.assessment = (Assessment__c) controller.getRecord();
        mode = 'view';
        hasErrorOnFinalize = false;
               
        
        if(ApexPages.currentPage().getParameters().get('summary') == '1')
            { mode = 'summary';  }
            
        if(ApexPages.currentPage().getParameters().get('new') == '1')
            { mode = 'edit';  }            
        
        if (assessment.id == null)
            {mode='edit';}
        mapCurrentResps  = new Map<id, Assessment_Response__c>();
        //listOfWrappedResponses = new List<WrappedResponse>();
        
        CurrentResps = [Select id, Rating__c, Response__c, Yes_No__c, Description_of_Risk__c, Plan_to_reduce_Risk__c, Assessment_Domain_Result__c, Question__c, Question__r.Question_Domain__c, Question__r.Question_Title__c From Assessment_Response__c Where assessment__c = :assessment.id];
       // system.debug(currentresps);
       
        ID idDomId = null;
        for(Assessment_Response__c local: CurrentResps){
        
            idDomId = local.Question__r.Question_Domain__c;
            
            DomainsInScopeIDs.Add(idDomId);
            QuestionsInScopeIDs.Add(local.Question__c);
            mapCurrentResps.put(local.Question__c, local);
            //listOfWrappedResponses.add(new WrappedResponse(local.Question__c,local));
            
            // calculate whether this domain as a whole has risk
            if (mapDomainHasRisk.containsKey(idDomId) && mapDomainHasRisk.get(idDomId)) {
                continue;
            } else {
            
                if(local.rating__c != null  &&  local.rating__c.equalsIgnoreCase('yes') ) {
                    mapDomainHasRisk.put(idDomId,true);
                    //system.debug('Putting ' + idDomId + ' into hasrisk list with true');
                } else {
                    mapDomainHasRisk.put(idDomId,false);
                } 
                    
            }
        }
        
        //WrappedResponseLists myWRL = new WrappedResponseLists(listOfWrappedResponses);
        //listOfWrappedResponseLists = new List<WrappedResponseLists>();
        //listOfWrappedResponseLists.add(myWRL);
        
        List<Assessment_Question__c > tmpQ = [Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c, Question_Domain__c,
                        (Select 
                                Name, Score__c, Rating__c, Color__c, Rating_Description__c, Show_These_Fields__c, id
                                From Assessment_Question_Option__r 
                                Order By Sort_Order__c)  
                From Assessment_Question__c 
                Where ID in  :QuestionsInScopeIDs];
        
        	mapWrappedSelectOptions = new Map<Id, WrappedSelectOptions>();
        
            for(Assessment_Question__c local : tmpQ){
                List<SelectOption> tmpSO = new List<SelectOption>();
                List<SelectOption> sortedTmpSO = new List<SelectOption>();
                
                // always show the extra questions - we'll do the show/hide toggle on the front end
                List<String> showFields= new List<String>{'Description_of_risk__c'};
                List<String> emptyList= new List<String>();
                    
                    for(Assessment_Question_Option__c QO : local.Assessment_Question_Option__r ){
                    
                        // create the options for a yes/no question
                        tmpSO.ADD(new SelectOption(QO.Rating__c, QO.Rating__c));       

						// if the question contains the words 'supports' then add the extra field to show                        
                        if ( local.Question_title__c.contains('supports')) {
                         system.debug('here: '+local.id+QO.Rating__c + ' - showfields: ' + showfields);	
                       	 mapQuestions.put(local.id+QO.Rating__c, showfields);      
                        } else
                        	mapQuestions.put(local.id+QO.Rating__c, emptyList);
                    }
                   
                    // add the question options for when the radio button is not selected
                    if ( local.Question_title__c.contains('supports'))
                    	mapQuestions.put(local.id, showFields);
                    else
                    	mapQuestions.put(local.id, emptyList);
                    
                tmpSO.sort();
                for(Integer i = tmpSO.size()-1; i>=0; i--) {
                	sortedTmpSO.add(tmpSO.get(i));
                }
                    
                mapOptions.Put(local.id, sortedTmpSO);
                mapWrappedSelectOptions.put(local.id, new WrappedSelectOptions(sortedTmpSO));   
            
            }
            system.debug('MAP QUESTIONS:' + mapquestions);
            
            DomainsInScope= [Select ID,  Name, Description__c, Assessment_Type__c, Header__c,  
                        (Select Name, ID, Question_Description__c, Question_Title__c, Question_Number__c
                                From Question__r 
                                Where ID in :QuestionsInScopeIDs
                                Order By Question_Number__c) 
                From Assessment_Domain__c Where id in :DomainsInScopeIDs Order By Sort_Order__c];
            
    }

   
    public PageReference myConfirm(){ 
        try{
            Acknowledgment__c confirmRec = new Acknowledgment__c(Assessment__c = assessment.id, User__c = UserInfo.getUserId());
            insert confirmRec;
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
        //ctr.save();
        return ctr.view();   
        }
            catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
        return null;
        
             
    }
    
    public PageReference myCancel(){ 
        //used only on new form
        try{
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
            assessment.Delete_Assessment__c =true;            
            ctr.save();
            PageReference ref =  new PageReference('/'+this.assessment.admission__c);
            
            return ref; 
              
        }
            catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
        return null;
        
             
    }    
    
    public PageReference mySave(){ 
        List<Assessment_Response__c> tmpRes = new List<Assessment_Response__c>();
        tmpRes = mapCurrentResps.values();
        boolean hasAnError = false;
 
 		
 		// THE FOLLOWING DOESN'T WORK.  LEAVE TO SHOW PAUL P. THE CONCEPT...  J. Gilliam, 7/10/14
 		//for(Assessment_Response__c ar : tmpRes) {
 		//	if(ar.Response__c!=null && ar.Rating__c==null) {
 		//		ar.Rating__c = 'ANSWER IN RATING__C';
 		//	}
 		//}
 
        // Without initializing a new stdcontroller, sometimes the controller
        // refuses to save        
        try{                  
            update tmpRes;
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
           // upsert assessment;
            ctr.save();
            return ctr.view();
        }
        
        catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
      
        return null;
    
    }


    public PageReference myRevise(){ 
    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Recommended Day Services Staffing Ratio is not provided'));
        try{
            Assessment__c curAssess = new Assessment__c();
            Assessment__c newAssess = new Assessment__c();
            curAssess = [Select id, Assessment_Type__c, Admission__c, AccountPerson__c, Type__c from Assessment__c Where ID = :assessment.id];
            newAssess = curAssess.clone();
            newAssess.Previous__c = curAssess.id;
            newAssess.Status__c = 'Inactive Draft';
            insert newAssess;
            
            assessment.status__c = 'Active Final';  
            update assessment ;          
            
            ApexPages.StandardController ctr = new ApexPages.StandardController(newAssess);
            return ctr.view();
        }
            catch(System.DmlException e){
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    
    }
    
    public PageReference myApprove(){ 
     
        
        try{
            hasErrorOnFinalize = false;
            boolean hasDesError = false;
            
            for(Assessment_Response__c local :  mapCurrentResps.values()){
                if(local.Rating__c != null && local.Question__r.question_title__c.contains('supports') && local.Rating__c.equalsIgnoreCase('yes')){
                    system.debug('entered loop for ' + local.id);
                    IF(string.isblank(local.Description_of_Risk__c  ))
                        {
                            hasDesError =true;
                            system.debug('true ' + local.id);
                            local.Description_of_Risk__c.addError('Support Plan must be entered');
                        }
                   
                }                   
            } 
           // this.validateHardcodedQuestions(true);
            if(hasDesError ){
                mode='edit';
              /*
 	            List<Apexpages.Message> msgs = ApexPages.getMessages();
				for(Apexpages.Message msg:msgs){
			    	msg.getDetail().replace('Description of Risk', ''));
				}
              */
                return null;
            }
	            
            update mapCurrentResps.values() ;
			
            try {
                Assessment__c currFinal = [select id, status__c from assessment__c where Admission__c = :assessment.Admission__c AND Assessment_Type__c = :assessment.Assessment_Type__c and status__C = 'Active Final' LIMIT 1];
                currFinal.Status__c = 'Inactive Final';
                update currFinal;
            }
            catch (Exception e) {
                mode= 'edit';
                // ok to let this go through.. 
            }
            
            Assessment.Status__c = 'Active Final';            
            Assessment.Finalized_Date__c = system.today();
            Assessment.Approved_By__c = UserInfo.getUserId() ;
            
            update Assessment;            
            ApexPages.StandardController ctr = new ApexPages.StandardController(this.assessment);
            notifyNewAssessmentVersion();
            return ctr.view();
        }
        catch(Exception e){
            Assessment.Status__c = 'Inactive Draft'; 
            Assessment.Finalized_Date__c = null;
            Assessment.Approved_By__c = null ; 
            mode='edit'; 
            hasErrorOnFinalize = true;
            system.debug('error is: ' + e.getMessage());
            e.setMessage(e.getMessage().replace('Description of Risk', ''));
            ApexPages.addMessages(e); 
        }
        
        return null;        
        
    }

    class InputException extends Exception {}
        
    private Boolean isNumber(String input) {
        // Check whether a String is a Number or not
        try {
            Decimal.valueOf(input);
            return True;
        } catch (System.TypeException ex) {
            return False;
        }
    }

    /**
     * Notify people who have confirmed reading older version of this assessment
     * when the new version is finalized.
     */
    public void notifyNewAssessmentVersion() {
        System.debug('Start notifying people');
        if (this.assessment.Previous__c==null || this.assessment.Status__c!='Active Final') {
                System.debug('Conditions not met! Return now.');
                System.debug('Previous: ' + this.assessment.Previous__c);
                System.debug('Status: ' + this.assessment.Status__c);
            return;
        }
        System.debug('Conditions met to notify people');
        User[] usersToNotify = [
           SELECT ID, ContactID FROM User
           WHERE ID IN (SELECT User__c FROM Acknowledgment__c WHERE Assessment__c=:this.assessment.Previous__c)
        ];
        System.debug('Users to notify: ' + usersToNotify);
        List<Task> tasks = new List<Task>();
        for (User userToNotify: usersToNotify) {
            tasks.add(new Task(
                WhatId = this.assessment.ID,
                OwnerId = userToNotify.ID,
                ActivityDate = this.assessment.Approval_Date__c,
                Subject = 'Assessment Confirmation',
                Description = 'Please confirm that you have read the new version of the assessment',
                WhoId = this.assessment.Admission__r.Person_Being_Served__c
            ));
        }
        System.debug('Tasks to create: ' + tasks);
        insert tasks;
    }
    
    public boolean getCanReviseAssess(){
        boolean canit = false;
        List<Assessment__c> newestAssessment = [
            SELECT ID, Status__c FROM Assessment__c
            WHERE Admission__c = :assessment.Admission__c 
              AND Type__c = :assessment.Type__c
            ORDER BY CreatedDate DESC 
        ];
        
        for(Assessment__c a : newestAssessment ){
            if (assessment.Id==a.Id && a.Status__c=='Active Final') {
                    canit = true;
            }
            if(a.Status__c =='Inactive Draft'){ return false;}
        }
        return canit;
    
    }

    
    // calculation of whether user is allowed to make this change
    private Boolean isUserLevel1or2() {
        
        List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];
         
        for ( PermissionSetAssignment p : userperms ) {

            //System.Debug( p.permissionset.name );
                        
            // user can only update if in one of these three permission sets
            if ( p.PermissionSet.Name.Contains('Level_1') || p.PermissionSet.Name.Contains('Level_2') ) {
                System.Debug('User is level1 or level2.');
                return true;    
            }
        }
        return false;
    }
    
    public void addOther() {
    	
    	Assessment_Domain_Result__c myAdr = [ SELECT Id, Assessment_Domain__c FROM Assessment_Domain_Result__c WHERE Assessment__r.Type__c = 'ISSA' AND Assessment_Domain__r.Name = 'Other' AND Assessment__c = :assessment.Id LIMIT 1 ];
    	Assessment_Question__c myQ = [ SELECT Id FROM Assessment_Question__c WHERE Question_Domain__c = :myAdr.Assessment_Domain__c AND Question_Title__c = 'Other' LIMIT 1 ];
    	
    	Assessment_Response__c ar = new Assessment_Response__c(
    		Assessment__c = assessment.Id,
    		Assessment_Domain_Result__c = myAdr.Id,
    		Question__c = myQ.Id
    	);
    	insert ar;
    	
    	mySave();
    }
}