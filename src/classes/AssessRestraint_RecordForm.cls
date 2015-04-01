public with sharing class AssessRestraint_RecordForm {
	public string saID {get; set;}
	public string assessID {get; set;}

	public class applicationException extends Exception {}	
	public Assessment__c assess {get; set;}
	public Assessment_Domain_Result__c assessDoaminResult {get; set;}
	public integer questionIndexToSave{get; set;}

	public Service_Assignment__c saForNewAssess {get; set;}
	public List<QuestionModel> Questions {get; set;}
	Public Id evalId{get; set;}
	public Evaluation__C thisEval {get; set;}
	public string getPBSid(){ return assess.id == null ? saForNewAssess.Person_Being_Served__c : assess.AccountPerson__r.PersonContactId; }
	public string getAdmitid(){ return assess.id == null ? saForNewAssess.Admission__c : assess.Admission__c; }

	public boolean hasError {get; set;}
	public boolean isDraftMostRecent {get; set;}
	public boolean hasDraft {get; set;}	
	public AssessRestraint_RecordForm() {
		
		system.debug('SA - ' + this.saID);
		system.debug('ASSess - ' + this.assessID);
		evalID =  ApexPages.currentPage().getParameters().get('evalID');
		this.thisEval = [SELECT Id, serviceassignment__c FROM Evaluation__c WHERE Id=: evalID];
		
		//saID = ApexPages.currentPage().getParameters().get('SAid');
		saID = thisEval.serviceassignment__c;
		assessID = ApexPages.currentPage().getParameters().get('AssessID');
		if (assessID == null){
			assessID = ApexPages.currentPage().getParameters().get('id');
		}		
		Construct(saID, assessID);
	}

//***********************************
//the big one...  resets most of the Properties in this class
//***********************************	
	private void Construct(ID SA_ID, ID ASSESS_ID){
		system.debug('SA2 - ' + SA_ID);
		system.debug('ASSess2 - ' + ASSESS_ID);
		hasDraft = false;
		isDraftMostRecent = false;
		if(ASSESS_ID == null){
			assess = newAssess(SA_ID);
		}
		else{
			assess = currentAssess(ASSESS_ID);
		}
		//use a loop here b/c you get a no row error if you try an put this query in an object
		//if there is an item in the query
		//we'll check the id with the curretn assess id, if there is a match the form will allow editing
		for(Assessment__c item: [SELECT id, name 
									FROM assessment__c 
									WHERE Service_Assignment__c = :SA_ID 
									AND Disregard__c = false 
									AND Status__C = 'Draft' 
									AND Type__c = 'Restraint Reduction'
									ORDER BY Assessment_Date__c DESC, CreatedDate DESC 
									limit 1]){
			hasDraft = true;
			system.debug('cur draft - ' + item.id);
			if(item.id == ASSESS_ID){
				isDraftMostRecent = true;
			}
		}
		Assessment_Response__c []  curRes = [select id, Question__c, OptionID__c, Score__c, Rating__c, Comment__c,
												Question__r.Is_MultiSelect__c 
													from Assessment_Response__c 
													where Assessment__c = :assess.id];	
		Questions = setAllQuestions(curRes);														
	}


//******************************
//helpers
//******************************

	private Assessment__c newAssess(ID SA_ID){
			Assessment__c azz = new Assessment__c();
			saForNewAssess = [select id, name, Person_Being_Served__r.AccountId, admission__c, Person_Being_Served__c from Service_Assignment__c where id = :SA_ID];
			azz.Status__c = 'Draft';
			azz.assessment_date__c = system.today();
			azz.Type__c = 'Restraint Reduction';
			azz.Service_Assignment__c = saForNewAssess.id;
			azz.Admission__c = saForNewAssess.admission__c;
			azz.External_ID__c = genID(16);
			assessDoaminResult = new Assessment_Domain_Result__c();
				assessment__c tmpAssess = new Assessment__c(External_ID__c = azz.External_ID__c);
			assessDoaminResult.Assessment__r = tmpAssess;
			assessDoaminResult.Assessment_Domain__c = [select id from Assessment_Domain__c where Assessment_Type2__c = 'Restraint Reduction' Limit 1].ID;
			assessDoaminResult.External_ID__c = genID(16);
			return	azz;
	}
	private Assessment__c currentAssess(ID ASSESS_ID){
		Assessment__c azz =  [select id, name, Service_Assignment__c, Admission__c, AccountPerson__r.PersonContactId, 
					Disregard__c, Assessment_Date__c, Owner.id,  
					CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, Finalized_Date__c, Status__c, Approved_By__c 
					From  Assessment__c
					Where id = :ASSESS_ID];
		assessDoaminResult = [select id, name from Assessment_Domain_Result__c where Assessment__c = :azz.id];
		return azz;

	}
	public Assessment__c mostRecFinalAssess {set; get{
			Assessment__c a = new Assessment__c();
			for(Assessment__c item: [SELECT id, name 
										FROM assessment__c 
										WHERE Service_Assignment__c = :assess.Service_assignment__c 
										AND Disregard__c = false 
										AND Status__C = 'Final' 
										ORDER BY Assessment_Date__c DESC, CreatedDate DESC 
										limit 1]){
				a = item;
			}
			return a;
		}}	

    private string GenId(integer len){
        Blob b = Crypto.GenerateAESKey(128); String h = EncodingUtil.ConvertTohex(b);  return h.substring(0,len);}

//*************************************
//Page Methods
//*************************************   
	public PageReference myCancel(){
		return null;
	}     
	public PageReference myDisregard(){
		try{
			hasError = false;
			assess.disregard__c = true;
			upsert assess;
		}
        catch(Exception e){
        	hasError = true;
            ApexPages.addMessages(e);
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getStackTraceString() );
			//ApexPages.addMessage(myMsg);            
        }		
		return null;
	}
	public PageReference myRevise(){
		try{
			//assess.disregard__c = true;
			//upsert assess;
			hasError = false;
			Assessment__c newA = new Assessment__c ();
			newA.Service_Assignment__c = assess.Service_Assignment__c;
			newA.Admission__c = assess.Admission__c;
			newA.AccountPerson__c = assess.AccountPerson__c;
			newA.Status__c = 'Draft';
			newA.Assessment_Date__c = system.today();
			newA.Type__c = 'Restraint Reduction';
			insert newA;

			Assessment_Domain_Result__c newDR = new Assessment_Domain_Result__c();
			newDR.Assessment_Domain__c = [select id from Assessment_Domain__c where Assessment_Type2__c = 'Restraint Reduction' Limit 1].ID;
			newDR.Assessment__c = newA.id;
			insert newDR;


			Assessment_Response__c []  curRes = [select id, Question__c, OptionID__c, Score__c, Rating__c, Comment__c,
												Question__r.Is_MultiSelect__c 
													from Assessment_Response__c 
													where Assessment__c = :assess.id];

			List<Assessment_Response__c> newAllRes = new list<Assessment_Response__c>();
			for(Assessment_Response__c item : curRes){
				Assessment_Response__c newRes = item.clone();
				newRes.Assessment_Domain_Result__c = newDR.id;
				newRes.Assessment__c = newA.id;
				newAllRes.add(newRes);
			}
			insert newAllRes;
	        PageReference ref = new PageReference('/apex/Assess_Restraint_Form?id=' + newA.id);
	 		ref.setRedirect(true); 	
	 		return ref; 			

		}
        catch(Exception e){
        	hasError = true;
            ApexPages.addMessages(e);
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getStackTraceString() );
			//ApexPages.addMessage(myMsg);            
        }		
		return null;
	}		
	public PageReference mySave(){
		try{
			/*
			Questions.get(questionIndexToSave).finalRes()
			*/
			hasError = false;
			List<Assessment_Response__c> resToUpdate = new list<Assessment_Response__c>();
			for(QuestionModel item: Questions){
				resToUpdate.add(item.finalRes() );
			}
			
			

			upsert assess;
			if(assessDoaminResult != null && assessDoaminResult.id == null){
				insert assessDoaminResult;
			}
			
			upsert resToUpdate;
			Construct(null, assess.id);
        	//setQuestions(); 

		}
        catch(Exception e){
        	hasError = true;
            ApexPages.addMessages(e);
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getStackTraceString() );
			//ApexPages.addMessage(myMsg);            
        }
 
		return null;
	}
	public PageReference myFinal(){
		try{
			
			hasError = false;
			for(QuestionModel item: Questions){
				if(item.finalRes().Rating__c == null || item.finalRes().Rating__c == ''){
					hasError = true;
					//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, item.getqTitle() + ' is required' );
					//ApexPages.addMessage(myMsg);
					item.qRec.Question_Title__c.addError(item.getqTitle() + ' is required', false);
				}
			}						
			if(hasError){
				return null;
			}
		}
        catch(Exception e){
        	hasError = true;
            ApexPages.addMessages(e);
			//ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getStackTraceString() );
			//ApexPages.addMessage(myMsg);            
        }		
		return null;
	}

//***********************************
//page helpers
//***********************************
	public boolean blockForm {set; get{
			blockForm = false;
			if(hasDraft && !isDraftMostRecent){
				blockForm = true;
			}
			return blockForm;
		}}
	public integer totalScore{ set; get{
		decimal t = 0;
		for(QuestionModel item: Questions){
			t += item.finalRes().Score__c;
		}
		return integer.valueof(t) ;
		}}
	public string GL {set; get{
		string GL = '';
		if(totalScore > 34 ){
			return 'Poor';
		}
		else if(totalScore > 20){
			return 'Good';
		}
		else{
			return 'Priority';
		}
		return GL;
		}}
	public boolean canSave{ set; get{
		if( blockForm){
			return false;
		}
		canSave = false;
		if( assess.owner.id == UserInfo.getUserId() || assess.id == null){
			canSave = true;
		}	
		if(assess.Status__c == 'Final'){
			canSave = false;
		}	
		if(assess.Disregard__c){
			canSave = false;
		}		
		return canSave;
		}
	}
	public boolean canDisregard{ set; get{
		if(assess.id == null){
			return false;
		}		
		if( !assess.disregard__c && assess.status__c != 'Final'){
			return true;
		}

		return false;
		}
	}
	public boolean canRevise{ set; get{
		if( blockForm){
			return false;
		}		
		if(assess.id == null || assess.owner.id != UserInfo.getUserId() ){
			return false;
		}		
		return assess.id == mostRecFinalAssess.id;
		}
	}
	public boolean canFinalize{ set; get{
		if( blockForm){
			return false;
		}		
		if(assess.id == null){
			return false;
		}
		if( !assess.disregard__c && assess.status__c != 'Final'  ){
			return true;
		}		
		return false;
		}
	}	

//*************************************
//start inner question class
//*************************************
	public class QuestionModel{
		public integer index {get; set;}
		public string selectedOption {get; set;}
		public list<string> selectedOptions {get; set;}
		public Assessment_Question__c qRec {get; set;}
		public Assessment_Response__c qResp {get; set;}
		public List<Assessment_Question_Option__c> options {get; set;}

		public QuestionModel(Assessment_Response__c ar){
			
			qResp = ar;
			options = new List<Assessment_Question_Option__c>();
			selectedOptions = new list<string>();

		}
		public List<SelectOption> qOptions {set; get{ 
			qOptions = new List<SelectOption>();
			for(Assessment_Question_Option__c item : options){
				qOptions.add(new SelectOption(item.id, item.Rating__c) );
			}
			return qOptions;} 
		}
		public string getqTitle(){return qRec.Question_Title__c;}
		public integer getScore(){return integer.valueof(finalRes().score__c);}

		public Assessment_Response__c finalRes(){
			qResp.Score__c = 0;
			if(qRec.Is_MultiSelect__c){ qResp.Rating__c = ''; qResp.OptionID__c = '';				
				for(Assessment_Question_Option__c item : options){
					if ( selectedOptionsSet.contains(item.id) ){
						qResp.Score__c += item.Score__c; qResp.Rating__c += item.Rating__c + ', '; qResp.OptionID__c += item.id + ',';}
				}
				qResp.OptionID__c = qResp.OptionID__c.removeEnd(','); qResp.Rating__c = qResp.Rating__c.removeEnd(', ');
			}else{
				for(Assessment_Question_Option__c item : options){
					if (item.id == selectedOption){
						qResp.Score__c = item.Score__c; qResp.Rating__c = item.Rating__c; qResp.OptionID__c = item.id; }
				}				
			}

			return qResp;
		}

		public set<string> selectedOptionsSet{ set; get{
				selectedOptionsSet = new set<string>();
				for( string item : selectedOptions ){ selectedOptionsSet.add(item); }
				return selectedOptionsSet;
			}
		}

	}

	//end inner question class
//*******************************
//a big thinker behind the big one
//reset some public properties and returns a list of the questionModel class we created above
//*******************************	
	public list<QuestionModel> setAllQuestions(list<Assessment_Response__c> allCurRes){
		list<QuestionModel> allQuestions = new list<QuestionModel>();
		// we ned to put the current responses in a map 
		// so we can lookup via Question ID
		map<id, Assessment_Response__c> questionToResp = new map<id, Assessment_Response__c>();
		for(Assessment_Response__c item : allCurRes){
			questionToResp.put(item.Question__c, item);
		}
		
		//we'll use this map on the option loop to see if we have been given a respose
		map<id, Assessment_Response__c> mapallCurRes = new map<id, Assessment_Response__c>(); 
		for(Assessment_Response__c item: allCurRes){
			if( !item.Question__r.Is_MultiSelect__c ){
				mapallCurRes.put(item.OptionID__c,item);
			}
		}
		integer index = -1;
		//lets loop over the questions - ques style
		for( Assessment_Question__c ques : getAllQuestions() ){			
			//the order of events helps us get our allQuestions list set correctly
			//step 1:
			// we'll set the default, a blank response with a score of 0
			Assessment_Response__c tmpRes = new Assessment_Response__c( score__c = 0);
			
			//step 2:
			//lets see if we were given a response record for this question
			tmpRes = questionToResp.get( ques.id );

			//step 3: Prep responses?
			//was the doamin ever set and if so has it been inserted?
			//if the domain record is null then it didn't need to get set and the record isn't new and never was
			//if the domain record isn't null we also need to make sure that this isn't the second pass through of this function
			//i.e. the user saved and we refreshed the screen but not the whole control in this case the domain wouldn't be null
			if( assessDoaminResult != null && assessDoaminResult.id == null ){
				Assessment_Domain_Result__c tmpADR = new Assessment_Domain_Result__c( External_ID__c = assessDoaminResult.External_ID__c );
				assessment__c tmpAssess = new Assessment__c( External_ID__c = assess.External_ID__c );
				tmpRes = new Assessment_Response__c ( Question__c = ques.id, Assessment__r = tmpAssess, Assessment_Domain_Result__r = tmpADR );
			}
			//this is the model item we'llput in the return list
			QuestionModel modelItem = new QuestionModel(tmpRes);
			//if its a multi select we need to seperate the options seletected
			if( ques.Is_MultiSelect__c && tmpRes.OptionID__c != null){
				modelItem.selectedOptions = tmpRes.OptionID__c.split(',');}
			//let the model know the question in scope
			modelItem.qRec = ques;

			//for each question option we'll add it to the model
			// and we have a response record we'll link that up
			for(Assessment_Question_Option__c otp : ques.Assessment_Question_Option__r){
				modelItem.options.add(otp);
				if(mapallCurRes.containsKey(otp.id) ) {
					modelItem.qResp = mapallCurRes.get(otp.id); modelItem.selectedOption = otp.id;}				
			}
			//just get swiming
			//just keep swiming
			index +=1;
			modelItem.index = index;
			//add this bad boy to the return list
			allQuestions.add(modelItem);
		}

		return allQuestions;
	}	
	private list<Assessment_Question__c> getAllQuestions(){
		return [select id, name, Is_MultiSelect__c, 
													Question_Number__c, Question_Title__c, Question_Description__c,
													
													(select id, name, Rating__c, Score__c, Rating_Description__c, sort_order__c from Assessment_Question_Option__r ORDER BY sort_order__c ASC) 

													From Assessment_Question__c
													Where Question_Domain__r.Assessment_Type2__c ='Restraint Reduction'

													ORDER BY Question_Number__c ASC];
	}
}