public with sharing class fallAssessmentComponentController {
	public Evaluation__c evaluation { get; set; }

	//  private Apexpages.StandardController controller { get; set; }
	public Assessment__c asmt { get; set; }
	public Id thisevaluationId { get; set; }
	public string domainName { get; set; }
	public Boolean displayError { get; set; }

	//Maps
	public Map<ID, Assessment_Domain__c> MapDomains = new Map<ID, Assessment_Domain__c>();
	public Map<ID , Assessment_Domain__c> getMapDomains() {
		return MapDomains;
	}
	//the id is from the question
	public Map<ID , Assessment_Response__c> MapAnswers = new Map<ID , Assessment_Response__c>();
	public Map<ID , Assessment_Response__c> getMapAnswers ()
	{return MapAnswers;}
	public Map<ID , Assessment_Question__c> MapQuestions = new Map<ID , Assessment_Question__c>();
	public Map<ID , Assessment_Question__c> getMapQuestions() {
		return MapQuestions;
	}
	//VF args
	public id questionID { get; set; }
	public id DomainResultID { get; set; }
	public string MyRating { get; set; }
	public string MyColor { get; set; }
	public double MyScore { get; set; }
	//end VF args

	//Constructor
	public fallAssessmentComponentController() {
		thisevaluationId = ApexPages.currentPage().getParameters().get('evalID');
		evaluation = [SELECT Id, Name, MAR_Section_Completed__c  FROM Evaluation__c WHERE Id = :thisevaluationId];
		Assessment__c[] assmts = [
			SELECT Id, Name,Previous__c, Type__c, Evaluation__c, AssessmentQuestionCount__c, AssessmentResponseCount__c
			  FROM Assessment__c where Evaluation__c = :thisevaluationId AND Type__c = 'Resident Assessment' limit 1];
		if (assmts.size() > 0) {
			this.asmt = assmts[0];
		}
		displayError = false;
	}

	//Initialization
	public void LoadData(Assessment__c TheVoidsAssessment){
		//Loops to set maps up
		for (Assessment_Domain__c me : ListForMapDomains){
			MapDomains.put(me.id,  me);
		} //End Loop

		for (Assessment_Question__c mee : ListForMapQuestions){
			MapQuestions.put(mee.ID,  mee);
		}
		//End loop

		for(Assessment_Response__c meee : getListForMapCurrentResponses()) {
			MapAnswers.put(meee.Question__c,  meee);
		}
	}

	//End of Initialization
	//Action from VF Page
	public pageReference myUpsert() {
		Assessment_Question__c aq = new Assessment_Question__c();
		aq = MapQuestions.get(questionID);
		Assessment_Response__c ar = new Assessment_Response__c();
		ar = MapAnswers.get(questionID);
		ar.Color__c = MyColor;

		if (aq.Is_MultiSelect__c && ar.Rating__c != null){
			ar.Rating__c += ';'+MyRating;
			ar.Score__c += MyScore;
		} else {
			ar.Rating__c = MyRating;
			ar.Score__c = MyScore;
		}

		if (aq.Is_MultiSelect__c && ar.Rating__c.Contains('None')){
			ar.Rating__c = MyRating;
			ar.Score__c = MyScore;
		}
		try {
			upsert ar;
			updateEvalValue(this.domainName);

		} catch(DMLException e) {
			ApexPages.addMessages(e);
		}
		//odd that this isn't needed ->  MapAnswers.put(questionID, AR);
		return null;

	}

	public PageReference clearSelection() {
		Assessment_Response__c ar = new Assessment_Response__c();
		ar = MapAnswers.get(questionID);
		ar.Rating__c = null;
		ar.Score__c = null;
		try {
			update ar;
			updateEvalValue(this.domainName);
		} catch(DMLException e) {
			ApexPages.addMessages(e);
		}

		return null;
	}

	public void updateEvalValue(string domainName) {
		if (domainName == 'Fall Risk Assessment Domain') {
			displayError = fallAssessmentComponentController.validateError(this.evaluation.Id, 'Fall Risk Assessment Domain');
			Eval_Value__c[] value = [
				SELECT Id, Boolean__c
				  FROM Eval_Value__c
				 WHERE What_Id__c = :this.evaluation.Id AND Eval__r.Field_Name__c = 'IsValid'
				   AND Eval__r.Category__c = 'Fall Risk Assessment'
				   AND Eval__r.Sub_Category__c = 'Fall Assessment'
			];
			if (value.size() > 0) {
				value[0].Boolean__c = !displayError;
				update value[0];
			}
		}

		if (domainName == 'Skin Assessment Domain') {
			displayError = fallAssessmentComponentController.validateError(this.evaluation.Id, 'Skin Assessment Domain');
			Eval_Value__c[] value = [
				SELECT Id, Boolean__c
				  FROM Eval_Value__c
				 WHERE What_Id__c = :this.evaluation.Id
				   AND Eval__r.Field_Name__c = 'IsValid'
				   AND Eval__r.Category__c = 'Skin/Body'
				   AND Eval__r.Sub_Category__c = 'Skin Assessment'
			];
			if (value.size() > 0) {
				value[0].Boolean__c = !displayError;
				update value[0];
			}
		}
	}

	public static boolean validateError(Id evalId, string DomainName) {
		Boolean error = false;
		List<Assessment_Response__c> currentResponses = [
			SELECT Id, Rating__c
			  FROM Assessment_Response__c
			 WHERE Assessment__r.Evaluation__c = :evalId
			   AND Question__r.Question_Domain__r.Name = :DomainName
		];
		for(Assessment_Response__c resp: currentResponses){
			if(resp.Rating__c == null){
				error = true;
				break;
			}
		}
		return error;
	}

	//This is used in the VF Page, it is the root repeat.

	public List<Assessment_Domain_Result__c> ThisRecordsDomains;
	public List<Assessment_Domain_Result__c> getThisRecordsDomains() {
		LoadData(this.asmt);
		return [
			Select Name, ID, Sort_Order__c, Assessment_Domain__c, Title__c, Total_Questions__c,
			       Answered_Questions__c, Score__c
			  From Assessment_Domain_Result__c
			 Where Assessment__c = :this.asmt.Id
			   And Assessment_Domain__r.Name = :domainName Order By Sort_Order__c
		];
	}



	//This is loaded into a map
	//Get a list of current responses.

	public List<Assessment_Response__c> getListForMapCurrentResponses(){
		return [
			Select ID,  Name, Question__c,Score__c, Rating__c, Color__c,
			       Question__r.Question_Domain__r.Name, Question__r.Question_Title__c
			  From Assessment_Response__c
			 Where Assessment__c = :this.asmt.id
			   And Assessment_Domain_Result__r.Assessment_Domain__r.Name = :domainName
		];
	}



	//This is loaded into a map
	//The Inner Select is used to loop through on the VF page. The sort by is key
	public List<Assessment_Question__c> ListForMapQuestions
	{
		get {
			return [
				Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c,
				       Assessment_Type__c, Is_MultiSelect__c, Question_Domain__r.Name,
				       (Select Name, Score__c, Rating__c, Color__c, Rating_Description__c
				          From Assessment_Question_Option__r
				        Order By sort_order__c asc)
				  From Assessment_Question__c
				 Where Question_Domain__r.Assessment_Type2__c = 'Resident Assessment'
				   And Question_Domain__r.Name= :domainName
			];
		}
		set;
	}

	//Same as all questions

	public List<Assessment_Domain__c> ListForMapDomains
	{
		get {
			return [
				Select ID,  Name, Description__c, Assessment_Type__c,
				       (Select Name, ID, Question_Description__c, Is_MultiSelect__c, Question_Title__c, Question_Number__c
				          From Question__r
				        Order By Question_Number__c)
				  From Assessment_Domain__c
				 Where Assessment_Type2__c = 'Resident Assessment'
				   And Name= :domainName
			];
		}
		set;
	}
}