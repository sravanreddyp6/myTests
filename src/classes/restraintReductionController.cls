public with sharing class restraintReductionController {
	
	public ID assId{get;  set;}
	
	public List<Assessment_Question__c> questions{get{
		
			if(questions == null){
				List<Assessment_Question__c> restraintQuestions= [Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c, Is_MultiSelect__c,Question_Domain__c, Question_Domain__r.Name, 
                            		(Select Name, Score__c, Rating__c, Color__c, Rating_Description__c 
                                    From Assessment_Question_Option__r 
                                    Order By sort_order__c asc)  
                   					From Assessment_Question__c 
                    				Where Question_Domain__r.Name = 'Restraint Questions' AND  Question_Domain__r.Assessment_Type2__c = 'Restraint Reduction'];
				return restraintQuestions;
			}
				return null;
				
		}
		
		set;}
		
	public Assessment__c assessment{get{
		if(assessment == null){
			assessment = [SELECT Id, Name, Status__c, Disregard__c FROM Assessment__c WHERE Id=: assId];
			
		}
		return assessment;
		}
		set;}
	
	//VF Args
	public id questionID {get;set;}
    //public id DomainResultID {get; set;}
    public string MyRating {get;set;}
    public string MyColor {get; set;}
    public double MyScore {get;set;}
    
	public Map<id,Assessment_Response__c> questionResponseMap {get{
		Map<id,Assessment_Response__c> respMap = new Map<id,Assessment_Response__c>();
		List<Assessment_Response__c> restraintResponses =  [Select ID,  Name, Question__c,Score__c, Rating__c, Color__c, Question__r.Question_Domain__r.Name, Question__r.Question_Title__c
                            								From Assessment_Response__c 
                           									Where Assessment__c = :assId AND Assessment_Domain_Result__r.Assessment_Domain__r.Name = 'Restraint Questions'];
		
		for(Assessment_Response__c ar: restraintResponses){
			respMap.put(ar.Question__c, ar);
		}
		
		return respMap;
	}
	 set;}
		 
	public Map<id,Assessment_Question__c> questionsMap{get{
		
		Map<id,Assessment_Question__c> qMAp = new Map<id,Assessment_Question__c>();
			for(Assessment_Question__c q: questions){
      			qMAp.put(q.Id,q);
      		}
		
			return qMAp;
	}	
	set;}
	//public List<Assessment_Question__c> questions{get;set;}
	
	public restraintReductionController(){
	//Nothing in Constructor because attribute value loads after constructor is executed
	
	}
	
	public pageReference myUpsert() {
        system.debug('I am inside Upserttttttttt');
        Assessment_Question__c aq = new Assessment_Question__c();
        aq = questionsMap.get(questionID);
        Assessment_Response__c ar = new Assessment_Response__c();
            ar = questionResponseMap.get(questionID); 
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
                    //updateevalValue(this.domainName);
                    
            }
            catch(DMLException e){
                    ApexPages.addMessages(e);
            }
            
        return null;

    }
    
    public pageReference disregard(){
    	assessment.Status__c = 'Disregard';
    	assessment.Disregard__c = true;
    	update assessment;
    	return null;
    }
    
    

}