@isTest
private class ComplianceSurveyTest{
    
    static testMethod void testQuestions() {
        Profile p = [SELECT Id FROM profile WHERE name = 'Standard User'];
        User u2 = new User(alias = 'newUser', email = 'newuser@testorg.com',
                       emailencodingkey = 'UTF-8', lastname = 'Testing',
                       languagelocalekey = 'en_US',
                       localesidkey = 'en_US', profileid = p.Id,
                       timezonesidkey = 'America/Los_Angeles',
                       username = 'newuser@testorg.com');
        
        ComplianceSurveyPreviewWizard PreviewClass= new ComplianceSurveyPreviewWizard();
        PreviewClass.InsertTestData();
        PreviewClass.getSurveys();
        PreviewClass.getUsers();
        
        
        ComplianceSurveyWizard WizardClass = new ComplianceSurveyWizard();
        WizardClass.TMN_User = [SELECT Id, Email__c, Job_Title__c, First_Name__c, Last_Name__c FROM TMN_user__c LIMIT 1];
        WizardClass.Survey = [SELECT Name, ID__c, Id FROM Survey__c LIMIT 1];
        WizardClass.getUserID();
        WizardClass.getResponseID();
        WizardClass.Response.TMN_User__c = WizardClass.TMN_User.Id;
        WizardClass.Response.First_Name__c = WizardClass.TMN_User.First_Name__c;
        WizardClass.Response.Last_Name__c = WizardClass.TMN_User.Last_Name__c;
        WizardClass.Response.Email__c = WizardClass.TMN_User.Email__c;
        WizardClass.Response.Job_Title__c = WizardClass.TMN_User.Job_Title__c;
        WizardClass.Yes();
        WizardClass.Yes();
        WizardClass.Yes();
        WizardClass.No();
        WizardClass.Submit();
        WizardClass.Print();
    }    
}