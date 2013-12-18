public with sharing class ComplianceSurveyPreviewWizard {
    
    public PageReference InsertTestData() {
        InsertSurvey();
        InsertUser();
        return null;
    }
    
    public PageReference InsertSurvey() {
        Survey__c TestSurvey = new Survey__c(Name = '2014 Annual Compliance Survey');
        insert TestSurvey;
        
        Question__c Question10 = new Question__c(Title__c = '10', Type__c = 'Final Question', Survey__c = TestSurvey.Id,
        Content__c = 'By clicking “Submit” below I certify that I have completed this certification form honestly.');
        insert Question10;
        
        Question__c Question9 = new Question__c(Title__c = '9', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Are you aware of any potential violation of our Code of Conduct or any company policy which has not yet been reported or addressed?',
        Reminder__c = 'If you answer “yes” you will be required to report your concern on the next screen. If you prefer, you can exit this site, report your concern to your supervisor, another member of  management, or to the Compliance Hotline (800-297-8043, www.mentornetwork.ethicspoint.com) and then come back to this site to complete your certification.',
        Next_Question_Y__c = Question10.Id, Next_Question_N__c = Question10.Id,
        Response_Status_Y__c = 'Completed with Follow Up',
        Describe_Y__c = true, Describe_Description_Y__c = 'Please enter all concerns.');
        insert Question9;
        
        Question__c Question8 = new Question__c(Title__c = '8', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Did you attend training during the 2012 calendar year on the Code of Conduct?',
        Response_Status_N__c = 'Completed with Exceptions',
        Next_Question_Y__c = Question9.Id, Next_Question_N__c = Question9.Id);
        insert Question8;
        
        Question__c Question7 = new Question__c(Title__c = '7', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Have you read the Company’s Code of Conduct (which was revised in July 2012) understand it, and agree to abide by it?',
        Reminder__c = 'Note:  if you select "No" a new tab will open with the Code of Conduct so that you can read it.   When you are done, please close the tab and return to this survey so you can answer "yes."',
        Next_Question_Y__c = Question8.Id, Next_Question_N__c = null,
        Link__c = 'www.thementornetwork.com/documents/pdf/1336_TheMENTORNetwork_CodeofConduct_2012V1.0.pdf', Action__c = 'New Tab');
        insert Question7;
        
        Question__c Question6 = new Question__c(Title__c = '6', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Can you certify that all of the independent contractors you are responsible for who started in calendar year 2012 received a copy of the Company’s Code of Conduct as part of their contracting process? (Note: the Code for Independent Contractors did not change in 2012.)',
        Reminder__c = 'Reminder: you are responsible for maintaining records of Code acknowledgement for Independent Contractors; these records may be subject to auditing',
        Next_Question_Y__c = Question7.Id, Next_Question_N__c = Question7.Id,
        Response_Status_N__c = 'Completed with Exceptions',
        Describe_N__c = true, Describe_Description_N__c = 'Please note all exceptions and reasons.');
        insert Question6;
        
        Question__c Question5 = new Question__c(Title__c = '5', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Do you monitor contractual compliance for any independent contractors (including Mentors)?',
        Next_Question_Y__c = Question6.Id, Next_Question_N__c = Question7.Id);
        insert Question5;
        
        Question__c Question4 = new Question__c(Title__c = '4', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Can you certify that all of your direct reports who were employed in calendar year 2012 received training on the Company’s new Code of Conduct during 2012?',
        Reminder__c = 'Reminder: You are responsible for maintaining records of attendance at compliance training for your direct reports; these records may be subject to auditing',
        Next_Question_Y__c = Question5.Id, Next_Question_N__c = Question5.Id,
        Response_Status_N__c = 'Completed with Exceptions',
        Describe_N__c = true, Describe_Description_N__c = 'Please note all exceptions and reasons.');
        insert Question4;
        
        Question__c Question3 = new Question__c(Title__c = '3', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Can you certify that all of the employees you had management responsibility for during 2012, including DSPs and other hourly employees, received training on the Company’s new Code of Conduct during 2012?',
        Reminder__c = 'Reminder: The direct supervisors of every employee are responsible for maintaining records of training attendance; you should verify training attendance of DSPs and other hourly employees with their direct supervisors',
        Next_Question_Y__c = Question5.Id, Next_Question_N__c = Question4.Id,
        Response_Status_N__c = 'Completed with Exceptions',
        Describe_N__c = true, Describe_Description_N__c = 'Please note all exceptions and reasons.');
        insert Question3;
        
        Question__c Question2 = new Question__c(Title__c = '2', Type__c = 'Y/N', Survey__c = TestSurvey.Id,
        Content__c = 'Is your job title “Program Director?”',
        Next_Question_Y__c = Question3.Id, Next_Question_N__c = Question4.Id);
        insert Question2;
        
        Question__c Question1 = new Question__c(Title__c = '1', Type__c = 'First Question', Survey__c = TestSurvey.Id,
        Content__c = 'Do you supervise at least one employee?',
        Next_Question_Y__c = Question2.Id, Next_Question_N__c = Question5.Id);
        insert Question1;
        
        SurveyId = TestSurvey.Id__c;
        return null;
    }
    
    public PageReference InsertUser() {
        TMN_user__c TestUser = new TMN_user__c(
        Email__c = 'splatonov@cloudbudget.com', 
        Job_Title__c = 'Developer', 
        Employee_Number__c = '1',
        First_Name__c = 'Stanislav ',
        Last_Name__c = 'Platonov');
        insert TestUser;
        UserId = TestUser.Employee_Number__c;
        return null;
    }
    
    public String SurveyId{
        get{
            if(SurveyId == null && getSurveys().size() != 0)
                SurveyId = getSurveys().get(0).getValue();
            return SurveyId;
        }
        set;
    }
    
    public String UserId{
        get{
            if(UserId == null && getUsers().size() != 0)
                UserId = getUsers().get(0).getValue();
            return UserId;
        }
        set;
    }
    
    public List<SelectOption> getUsers(){
        List<SelectOption> Users = new List<SelectOption>();
        for(TMN_user__c u : [SELECT Employee_Number__c, First_Name__c, Last_Name__c FROM TMN_user__c WHERE Employee_Number__c != null and Email__c !=null LIMIT 5])
            if(u.Employee_Number__c != null)
                Users.add(new SelectOption(u.Employee_Number__c, u.Employee_Number__c + ' : ' + u.First_Name__c + ' ' + u.Last_Name__c));
        return Users;
    }
    
    public List<SelectOption> getSurveys(){
        List<SelectOption> Surveys = new List<SelectOption>();
        for(Survey__c s : [SELECT ID__c, Name FROM Survey__c])
            Surveys.add(new SelectOption(s.ID__c, s.ID__c + ' : ' + s.Name));
        return Surveys;
    }
}