public with sharing class AssessmentForm {

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
//end maps
//VF args
public id questionID {get;set;}
public id DomainResultID {get; set;}
public string MyRating {get;set;}
public string MyColor {get; set;}
public double MyScore {get;set;}
//end VF args
//This Record gets set via LoadData
public Assessment__c ThisAssessment;


//instantiation Standard controller
    public AssessmentForm(ApexPages.StandardController controller) {
        Assessment__c temp = new Assessment__c();        
        temp = (Assessment__c)controller.getRecord(); 
        LoadData(temp); 
    }
//instantiation  Test Unit
    public AssessmentForm (Assessment__c a) {
          a = a;
          LoadData(a);
    }
// End instantiation    
//Initialization  
    public void LoadData(Assessment__c TheVoidsAssessment){
      ThisAssessment = [Select ID, Name, Assessment_Type__c, Assessment_Type_ID__c, Assessment__c.Admission__r.Id From Assessment__c Where id = :TheVoidsAssessment.id];
      //Loops to set maps up
      for (Assessment_Domain__c me : ListForMapDomains)
              {MapDomains.put(me.id,  me);}//End Loop
      
      for (Assessment_Question__c mee : ListForMapQuestions)
              {MapQuestions.put(mee.ID,  mee);}//End loop      

      for (Assessment_Response__c meee : ListForMapCurrentResponses)
              {MapAnswers.put(meee.Question__c,  meee);}//End Loop                     
    } 

//End of Initialization

//Action from VF Page
public PageReference myUpsert() {

    Assessment_Response__c ar = new Assessment_Response__c();
    
        ar = MapAnswers.get(questionID); 
        ar.Rating__c = MyRating;
        ar.Color__c = MyColor;
        ar.Score__c = MyScore;
        try{
                upsert ar;
        }
        catch(DMLException e){
                ApexPages.addMessages(e);
        }
  //odd that this isn't needed ->  MapAnswers.put(questionID, AR);
return null;

}

//Lists


//This is used in the VF Page, it is the root repeat.
         
   public List<Assessment_Domain_Result__c> ThisRecordsDomains
    {
        get{
                return 
                        [Select Name, ID, Sort_Order__c, Assessment_Domain__c, Title__c, Total_Questions__c, Answered_Questions__c, Score__c
                                From Assessment_Domain_Result__c 
                                Where Assessment__c = :ThisAssessment.Id Order By Sort_Order__c ];
        }
    set;}
    

//This is loaded into a map
//Get a list of current responses.

public List<Assessment_Response__c> ListForMapCurrentResponses
    {
        get{
                
            return 
                [Select ID,  Name, Question__c, Rating__c, Color__c 
                        From Assessment_Response__c 
                        Where Assessment__c = :ThisAssessment.id ];
        }
    set;}           


//This is loaded into a map
//The Inner Select is used to loop through on the VF page. The sort by is key

public List<Assessment_Question__c> ListForMapQuestions
    {
        get{return 
                [Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c, 
                        (Select 
                                Name, Score__c, Rating__c, Color__c, Rating_Description__c 
                                From Assessment_Question_Option__r 
                                Order By Rating__c)  
                From Assessment_Question__c 
                Where Assessment_Type__c Like :ThisAssessment.Assessment_Type_ID__c];}
    set;} 

//Same as all questions

public List<Assessment_Domain__c> ListForMapDomains
    {
        get{
            return 
                [Select ID,  Name, Description__c, Assessment_Type__c,  
                        (Select Name, ID, Question_Description__c, Question_Title__c, Question_Number__c 
                                From Question__r 
                                Order By Question_Number__c) 
                From Assessment_Domain__c Where Assessment_Type__c = :ThisAssessment.Assessment_Type__c ];
        }
    set;}    
    
}