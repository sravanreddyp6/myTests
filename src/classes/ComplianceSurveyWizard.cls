public with sharing class ComplianceSurveyWizard {
//this is not code
    public void Back() {
        if(Savepoints.size() >= 1){
            Savepoints.remove(Savepoints.size()-1);
        }
        if(Savepoints.size() >= 1){
            QuestionID = Savepoints.get(Savepoints.size()-1).QuestionIDSavepoint;
            Response = Savepoints.get(Savepoints.size()-1).ResponseSavepoint.clone(false,true);
            if(Replies.size() >= 1){
                Replies.remove(Replies.size()-1);
            }
        } else {
            QuestionID = 'Welcome';
            Response = new Response__c();
            Response.Note__c = '<h2>' + Survey.Name + '</h2><br/>';
            TMN_User = null;
        }
 
    }

    
    public ComplianceSurveyWizard(){
        Boolean Submitted = [SELECT Id FROM Response__c WHERE TMN_User__r.Employee_Number__c =: getUserID()].size() >= 1; 
        //if(Submitted || ApexPages.currentPage().getCookies().get('submitted') != null){
        if(Submitted){
            QuestionID = 'Submitted';
        } else {
            QuestionID = 'Welcome';
            Response.Note__c = '<h2>' + Survey.Name + '</h2><br/>';
            if(UserID == null || UserID == ''){
                QuestionID = 'User Data';
                TMN_User = new TMN_User__c();
            }
        }
        Savepoints = new List<Savepoint>();
    }
    
    public String SurveyID = ApexPages.currentpage().getParameters().get('id');
    public String UserID = ApexPages.currentpage().getParameters().get('uid');
    
    public String getUserID() {
        return UserID;
    }
    
    public String getResponseID(){
        return ApexPages.currentpage().getParameters().get('rid');
    }
    
    public String QuestionID {get; set;}
    
    public TMN_User__c TMN_User {
        get{
            if(TMN_User == null){
                List<String> sObjectFields = new List<String>{};
                sObjectFields.addAll(Schema.getGlobalDescribe().get('TMN_User__c').getDescribe().fields.getMap().keySet());
                String Query = 'SELECT ' + sObjectFields.get(0);
                for (Integer i=1 ; i < sObjectFields.size() ; i++){
                    Query += ', ' + sObjectFields.get(i);
                }
                string useridstr = getUserID();
                Query += ' FROM TMN_User__c WHERE Employee_Number__c = :useridstr';
                try{
                    TMN_User = Database.query(Query);
                } catch (QueryException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User Id is not available'));
                }
            }
            return TMN_User;
        }
        set;
    }
    
    List<TMN_User__c> TMN_Users {
        get;
        set;
    }
    
    public Survey__c Survey{
        get{
            if(Survey == null)
                try{
                    Survey = [SELECT Name, ID__c, Id FROM Survey__c WHERE ID__c =: SurveyId];
                } catch(QueryException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Survey Id is not available'));
                    Survey = new Survey__c();
                }
            return Survey;
        }
        set;
    }
    
    public List<Question__c> Questions{
        get{
            if(Questions == null && Survey != null)
                try{
                    Questions = [SELECT Id, Response_Status_Y__c, Response_Status_N__c, Show_Title__c, Action__c, Describe_Y__c, Describe_N__c, Describe_Title_Y__c, Describe_Title_N__c, Describe_Description_Y__c, Describe_Description_N__c, Survey__c, Title__c, Content__c, Link__c, Reminder__c, Type__c, Next_Question_Y__c, Next_Question_N__c FROM Question__c WHERE Survey__c =: Survey.Id ORDER BY Title__c];
                } catch(QueryException e){
                
                }
            return Questions;
        }
        set;
    }
    
    public Question__c Question{
        get{
            if(Questions != null)
                for(Question__c q : Questions){
                    if(QuestionID != 'Final' && QuestionID != 'User Data' && QuestionID != 'Welcome' && QuestionID != 'Submitted' && QuestionID == q.Id){
                        Question = q;
                        break;
                    } else if(QuestionID == 'Welcome' && q.Type__c == 'First Question'){
                        Question = q;
                        break;
                    }                   
                }
            return Question;
        }
        set;
    }
    
    public Response__c Response{
        get{
            if(Response == null && getResponseID() == null)
                Response = new Response__c();
            else if(getResponseID() != null){
                List<String> sObjectFields = new List<String>{};
                sObjectFields.addAll(Schema.getGlobalDescribe().get('Response__c').getDescribe().fields.getMap().keySet());
                String Query = 'SELECT ' + sObjectFields.get(0);
                for (Integer i=1 ; i < sObjectFields.size() ; i++){
                    Query += ', ' + sObjectFields.get(i);
                }
                string responseidstr = getResponseID();
                Query += ' FROM Response__c WHERE Id = :responseidstr';
                try{
                    Response = Database.query(Query);
                } catch (QueryException e){}
            }    
            return Response;
        }
        set;
    }
    
    public class Savepoint{
        public String QuestionIDSavepoint {get;set;}
        public Response__c ResponseSavepoint {get;set;}
        public Savepoint(String qID, Response__c Res){
            QuestionIDSavepoint = qId;
            ResponseSavepoint = Res;
        }
    }
    
    public List<Savepoint> Savepoints{get;set;}
    
    public List<Reply__c> Replies {
        get{
            if(Replies == null)
                Replies = new List<Reply__c>();
            return Replies;
        }
        set;
    }
    
    public Reply__c Reply {
        get{
            if(Reply == null)
                Reply = new Reply__c();
            return Reply;
        }
        set;
    }
    
    public PageReference Yes(){
        if(QuestionID == 'Welcome'){
            Response.TMN_User__c = TMN_User.Id;
            Response.First_Name__c = TMN_User.First_Name__c;
            Response.Last_Name__c = TMN_User.Last_Name__c;
            Response.Email__c = TMN_User.Email__c;
            Response.Job_Title__c = TMN_User.Job_Title__c;
            Response.Note__c += 'I am ' + Response.First_Name__c + ' ' + Response.Last_Name__c + '<br/> Yes <br/><br/>';
            for(Question__c q : Questions){
                if(q.Type__c == 'First Question'){
                   QuestionID = q.Id;
                   for(Schema.FieldSetMember f : SObjectType.Response__c.FieldSets.Wizard.getFields()){
                        if(Response.get(f.getFieldPath()) != null){
                            Response.Note__c += f.getLabel() + ': ' + TMN_User.get(f.getFieldPath()) + '<br/>';
                        }
                    }
                    Response.Note__c += '<br/>';
                    break;
                }            
            }
        } else if(QuestionID == 'User Data'){
            for(Question__c q : Questions)
                if(q.Type__c == 'First Question'){
                    QuestionID = q.Id;
                    for(Schema.FieldSetMember f : SObjectType.Response__c.FieldSets.Wizard.getFields()){
                        if(Response.get(f.getFieldPath()) != null){
                            Response.Note__c += f.getLabel() + ': ' + Response.get(f.getFieldPath()) + '<br/>';
                        }
                    }
                    Response.Note__c += '<br/>';
                    break;
                }
        } else {
        
            for(Question__c q : Questions)
            {
                if(QuestionID == q.Id){
                
                    if(Reply.Describe__c != null){
                        if(Reply.Describe__c.length() >= 10 && Reply.Describe__c.length() <= 300){
                            Response.Note__c += q.Title__c + '<br/>' + q.Content__c +'<br/> Yes <br/><br/>';
                            Response.Note__c += 'Describe:<br/>' + Reply.Describe__c + '<br/><br/>';
                        } else {
                            Reply.Describe__c.addError('Your response must include a minimum of 10 and maximum of 300 characters.');
                            return null;
                        }
                    } else {
                    
                        Response.Note__c += q.Title__c + '<br/>' + q.Content__c +'<br/> Yes <br/><br/>';
                    }
                    
                    Reply.Question__c = q.Id;
                    Reply.Reply__c = 'Yes';
                    Replies.add(Reply);
                    
                    if(q.Response_Status_Y__c != null){
                        Response.Status__c = q.Response_Status_Y__c;
                    }
                    Reply = null;
                    if(q.Next_Question_Y__c != null){
                        QuestionID = q.Next_Question_Y__c;
                    }
                    break;
                }
            }
        }

        Savepoints.add(new Savepoint(QuestionID, Response.clone(false,true)));

        return null;
    }
    
    public PageReference No(){
        if(QuestionID == 'Welcome'){
            QuestionID = 'User Data';
            TMN_User = new TMN_User__c();
        } else {
            for(Question__c q : Questions)
                if(QuestionID == q.Id){
                
                    if(Reply.Describe__c != null){
                        if(Reply.Describe__c.length() >= 10 && Reply.Describe__c.length() <= 300){
                            Response.Note__c += q.Title__c + '<br/>' + q.Content__c +'<br/> No <br/><br/>';
                            Response.Note__c += 'Describe:<br/>' + Reply.Describe__c + '<br/><br/>';
                        } else {
                            Reply.Describe__c.addError('Your response must include a minimum of 10 and maximum of 300 characters.');
                            return null;
                        }
                    } else {
                        Response.Note__c += q.Title__c + '<br/>' + q.Content__c +'<br/> No <br/><br/>';
                    }
                    
                    Reply.Question__c = q.Id;
                    Reply.Reply__c = 'No';
                    Replies.add(Reply);
                    
                    if(q.Response_Status_N__c != null){
                        Response.Status__c = q.Response_Status_N__c;
                    }
                    Reply = null;
                    if(q.Next_Question_N__c != null){
                        QuestionID = q.Next_Question_N__c;
                    }
                    break;
                }
        }

        Savepoints.add(new Savepoint(QuestionID, Response.clone(false,true)));
        return null;
    }
    
    public void Submit(){
    
        Response.Note__c += Question.Title__c + '<br/>' + Question.Content__c +'<br/> SUBMIT <br/><br/>';
        
        List<String> sObjectFields = new List<String>{};
        sObjectFields.addAll(Schema.getGlobalDescribe().get('TMN_User__c').getDescribe().fields.getMap().keySet());
        String Query = 'SELECT ' + sObjectFields.get(0);
        for (Integer i=1 ; i < sObjectFields.size() ; i++){
            Query += ', ' + sObjectFields.get(i);
        }

        Query += ' FROM TMN_User__c WHERE Email__c = \'' + String.escapeSingleQuotes(Response.Email__c) + '\' LIMIT 1';
        try{
            TMN_Users = Database.query(Query);
        } catch (QueryException e){}
        
        if(TMN_Users.size() == 1)
            TMN_User = TMN_Users.get(0);
        
        Response.TMN_User__c = TMN_User.Id;
        Response.Survey__c = Survey.Id;
        Response.Time_Stamp__c = datetime.now();
        if(Response.Status__c == null) 
            Response.Status__c = 'Completed without Exceptions';
        upsert Response;
        for(Reply__c r : Replies)
            r.Compliance_Response__c = Response.Id;
        upsert Replies;
        QuestionID = 'Final';
        
        ApexPages.currentPage().setCookies(new Cookie[]{
            new Cookie('submitted', '1', null, 6000000, false)
        });
    }
    
    public PageReference Print(){
        PageReference PrintResponse = Page.ComplianceSurveyPrintResponses;
        PrintResponse.getParameters().put('rid', Response.Id);
        PrintResponse.setRedirect(true);
        return Page.ComplianceSurveyPrintResponses;
    }
    
}