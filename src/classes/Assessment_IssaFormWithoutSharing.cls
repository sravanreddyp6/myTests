public with sharing class Assessment_IssaFormWithoutSharing extends Assessment_AbstractForm implements DSP_AssessmentResponseType{
    public string glbListSeperator {get{return ';';} set;}
    public string glbItemSeperator {get{return '__';} set;}

    public List<id> DomainsInScopeIDs = new List<id>();
    public List<id> QuestionsInScopeIDs = new List<id>();
    public List<id> OptionsInScope = new List<id>();
    public List<Assessment_Response__c> CurrentResps = new List<Assessment_Response__c>();
    public List<Assessment_Response__c> getCurrentResps(){ return CurrentResps;}
    
    public Map<id, Assessment_Response__c> mapCurrentResps {get;set;}
    
    public List<WrappedResponse> listOfWrappedResponses { get; set; }
    public List<WrappedResponseLists> listOfWrappedResponseLists { get; set; }        
     
    
    public map<string, List<string>> mapQuestions = new map<string, List<string>>();
    
    public map<string, List<string>> getMapQuestions(){ return mapQuestions ;}

    
    public map<id, boolean> mapDomainHasRisk = new map<id, boolean>();
    public map<id, boolean> getmapDomainHasRisk  (){ return mapDomainHasRisk ;}    
    
    Public List<Assessment_Domain__c> DomainsInScope = new List<Assessment_Domain__c>();
    Public List<Assessment_Domain__c> getDomainsInScope() {return DomainsInScope;}
  
    public List<Assessment__c> AllAsses = new List<Assessment__c>();
    public List<Assessment__c> getAllAsses(){return AllAsses ;}


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

    public Assessment_IssaFormWithoutSharing(Id assessmentId) {
        super(assessmentId);
        mapCurrentResps  = new Map<id, Assessment_Response__c>();
        
        CurrentResps = [Select id, Rating__c, Response__c, Yes_No__c, Description_of_Risk__c, Plan_to_reduce_Risk__c, Assessment_Domain_Result__c, Question__c, Question__r.Question_Domain__c, Question__r.Question_Title__c From Assessment_Response__c Where assessment__c = :assessment.id];
       
        for(Assessment_Response__c local: CurrentResps){
            DomainsInScopeIDs.Add(local.Question__r.Question_Domain__c);
            QuestionsInScopeIDs.Add(local.Question__c);
            mapCurrentResps.put(local.Question__c, local);
            //listOfWrappedResponses.add(new WrappedResponse(local.Question__c,local));
        }
        
        List<Assessment_Question__c > tmpQ = [Select ID, Question_Number__c, Question_Title__c, Name, Question_Description__c, Assessment_Type__c, Question_Domain__c,
                        (Select Name, Score__c, Rating__c, Color__c, Rating_Description__c, Show_These_Fields__c, id
                                From Assessment_Question_Option__r 
                                Order By Sort_Order__c)  
                From Assessment_Question__c 
                Where ID in  :QuestionsInScopeIDs];
        
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
            }
            
            DomainsInScope= [Select ID,  Name, Description__c, Assessment_Type__c, Header__c,  
                        (Select Name, ID, Question_Description__c, Question_Title__c, Question_Number__c
                                From Question__r 
                                Where ID in :QuestionsInScopeIDs
                                Order By Question_Number__c) 
                From Assessment_Domain__c Where id in :DomainsInScopeIDs Order By Sort_Order__c];
            
    }

   
}