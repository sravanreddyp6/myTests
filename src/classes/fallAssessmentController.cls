public with sharing class fallAssessmentController {
	
	public Evaluation__c evaluation {get; set;}
	private Apexpages.StandardController controller {get;set;}
	public Assessment__c asmt {get; set;}
	
	//Maps
	public Map<ID, Assessment_Domain__c> MapDomains = new Map<ID, Assessment_Domain__c>();
	public Map<ID , Assessment_Domain__c> getMapDomains()
	        {return MapDomains;}
	//the id is from the question
	public Map<ID , Assessment_Response__c> MapAnswers = new Map<ID , Assessment_Response__c>();
	public Map<ID , Assessment_Response__c> getMapAnswers ()
	        {return MapAnswers;}
	public Map<ID , Assessment_Question__c> MapQuestions = new Map<ID , Assessment_Question__c>();
	public Map<ID , Assessment_Question__c> getMapQuestions() 
	        {return MapQuestions;}
	//Extending the fucntionality for SKin Assessment.        
	public Map<ID, Assessment_Domain__c> MapskinDomains = new Map<ID, Assessment_Domain__c>();
	public Map<ID , Assessment_Domain__c> getMapskinDomains()
	        {return MapskinDomains;}
	//the id is from the question
	public Map<ID , Assessment_Response__c> MapskinAnswers = new Map<ID , Assessment_Response__c>();
	public Map<ID , Assessment_Response__c> getMapskinAnswers ()
	        {return MapskinAnswers;}
	public Map<ID , Assessment_Question__c> MapskinQuestions = new Map<ID , Assessment_Question__c>();
	public Map<ID , Assessment_Question__c> getMapskinQuestions() 
	        {return MapskinQuestions;}
	//end maps
	//VF args
	public id questionID {get;set;}
	public id DomainResultID {get; set;}
	public string MyRating {get;set;}
	public string MyColor {get; set;}
	public double MyScore {get;set;}
	//end VF args
		
	//Constructor
	public fallAssessmentController(ApexPages.StandardController controller){
		this.controller = controller;
		evaluation = (Evaluation__c)controller.getRecord();
		this.asmt = [SELECT Id, Name,Previous__c, Type__c, Evaluation__c, AssessmentQuestionCount__c, AssessmentResponseCount__c 
						FROM Assessment__c where Evaluation__c = :this.evaluation.id AND Type__c = 'Resident Assessment' limit 1];
		LoadData(this.asmt);
		
	}
	
	//Initialization  
    public void LoadData(Assessment__c TheVoidsAssessment){
    	
	Assessment_Response__c ageResponse = new Assessment_Response__c();
      //Loops to set maps up
      for (Assessment_Domain__c me : ListForMapDomains){
      		if(me.Name =='Fall Risk Assessment Domain'){
      			MapDomains.put(me.id,  me);
      		}
      		if(me.Name == 'Skin Assessment Domain'){
      			MapskinDomains.put(me.Id, me);
      		}
      } //End Loop
              
              	
      
      for (Assessment_Question__c mee : ListForMapQuestions){
      		if(mee.Question_Domain__r.Name == 'Fall Risk Assessment Domain'){
      			MapQuestions.put(mee.ID,  mee);
      			
      		}
      		if(mee.Question_Domain__r.Name == 'Skin Assessment Domain'){
      			MapskinQuestions.put(mee.Id, mee);
      		}
      }
              //End loop      

      for (Assessment_Response__c meee : ListForMapCurrentResponses) {
      		if(meee.Question__r.Question_Domain__r.Name == 'Fall Risk Assessment Domain'){
      			MapAnswers.put(meee.Question__c,  meee);
      		}
      		if(meee.Question__r.Question_Domain__r.Name == 'Skin Assessment Domain'){
      			MapskinAnswers.put(meee.Question__c,  meee);
      		}
      		
      }
      	
     // update ageResponse;
                                 
    } 

//End of Initialization
	//Action from VF Page
	public PageReference myUpsert() {
		
		Assessment_Question__c aq = new Assessment_Question__c();
		aq = MapQuestions.get(questionID);
	    Assessment_Response__c ar = new Assessment_Response__c();
	        ar = MapAnswers.get(questionID); 
	        ar.Color__c = MyColor;
	       
	        if(aq.Is_MultiSelect__c && ar.Rating__c != null){
	        	ar.Rating__c += ';'+MyRating;
	        	ar.Score__c += MyScore;
	        }
	        else{
	        	ar.Rating__c = MyRating;
	        	 ar.Score__c = MyScore;
	        }
	        
	        if(aq.Is_MultiSelect__c && ar.Rating__c.Contains('None')){
	        	ar.Rating__c = MyRating;
	        	 ar.Score__c = MyScore;	
	        }
	        try{
	                upsert ar;
	        }
	        catch(DMLException e){
	                ApexPages.addMessages(e);
	        }
	  //odd that this isn't needed ->  MapAnswers.put(questionID, AR);
		return null;

	}
	
	//Upsert for Skin Assessment. Can be done in above method but do not want to overload it - Sravan - 02/17/2015 10:50 AM
	public pageReference myUpsert2 () {
		Assessment_Response__c ar = new Assessment_Response__c();
	        ar = MapskinAnswers.get(questionID);
	        ar.Rating__c = MyRating;
	       	ar.Score__c = MyScore;
		 try{
	                upsert ar;
	        }
	        catch(DMLException e){
	                ApexPages.addMessages(e);
	        }
	        
		return null;
		
	}
	
	public PageReference clearSelection() {
		Assessment_Response__c ar = new Assessment_Response__c();
		ar = MapAnswers.get(questionID);
		ar.Rating__c = null;
		ar.Score__c = null;
		try{
                update ar;
        }
        catch(DMLException e){
                ApexPages.addMessages(e);
        }
		
		return null;
	}
	
	public static boolean validateError(Id i, string DomainName){
		Boolean error = false;
		List<Assessment_Response__c> currentResponses = [SELECT Id, Rating__c FROM Assessment_Response__c WHERE Assessment__r.Evaluation__c = :i AND Question__r.Question_Domain__r.Name = :DomainName];
		for(Assessment_Response__c resp: currentResponses){
			if(resp.Rating__c == null){
				error = true;
				break;
			}
			
		}
		
		return error;
	}
	
	//This is used in the VF Page, it is the root repeat.
         
    public List<Assessment_Domain_Result__c> ThisRecordsDomains
	    {
	        get{
	                return 
	                        [Select Name, ID, Sort_Order__c, Assessment_Domain__c, Title__c, Total_Questions__c, Answered_Questions__c, Score__c
	                                From Assessment_Domain_Result__c 
	                                Where Assessment__c = :this.asmt.Id Order By Sort_Order__c ];
	        }
	    set;}
	    
	    
	   
	//This is loaded into a map
	//Get a list of current responses.
	
	 public  List<Assessment_Response__c> ListForMapCurrentResponses
	    {
	        get{
	                
	            return 
	                [Select ID,  Name, Question__c,Score__c, Rating__c, Color__c, Question__r.Question_Domain__r.Name, Question__r.Question_Title__c
	                        From Assessment_Response__c 
	                        Where Assessment__c = :this.asmt.id ];
	        }
	    set;}           
	
	
	//This is loaded into a map
	//The Inner Select is used to loop through on the VF page. The sort by is key
	
	 public List<Assessment_Question__c> ListForMapQuestions
	    {
	        get{return 
	                [Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c, Is_MultiSelect__c, Question_Domain__r.Name, 
	                        (Select 
	                                Name, Score__c, Rating__c, Color__c, Rating_Description__c 
	                                From Assessment_Question_Option__r 
	                                Order By sort_order__c asc)  
	                From Assessment_Question__c 
	                Where Question_Domain__r.Assessment_Type2__c = 'Resident Assessment'];}
	    set;} 
	
	//Same as all questions
	
	 public List<Assessment_Domain__c> ListForMapDomains
	    {
	        get{
	            return 
	                [Select ID,  Name, Description__c, Assessment_Type__c,  
	                        (Select Name, ID, Question_Description__c, Is_MultiSelect__c, Question_Title__c, Question_Number__c 
	                                From Question__r 
	                                Order By Question_Number__c) 
	                From Assessment_Domain__c Where Assessment_Type2__c = 'Resident Assessment'];
	        }
	    set;}    
	

}