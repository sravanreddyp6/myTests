@isTest
private class UserTriggeredActionsTest {

static testMethod void myUnitTest() {

     {
       
         String ProfileId = [select ProfileId from User where (Department='Operations Systems') LIMIT 1].ProfileId;
     
           User usr = new User(USERNAME='Steve.Test@thementornetwork.com',
                               LASTNAME = 'Test',
                               FIRSTNAME = 'Steve',
                               EMAIL = 'Steve.Test@thementornetwork.com',
                               ALIAS = 'stest',
                               COMMUNITYNICKNAME = 'steve.test',
                               TIMEZONESIDKEY = 'America/New_York',
                               LOCALESIDKEY = 'en_US', 
                               EMAILENCODINGKEY = 'ISO-8859-1',
                               PROFILEID = ProfileId,
                               LANGUAGELOCALEKEY = 'en_US',                                
                               ISACTIVE = true,
                               legal_custodian__c=false);
                               
           insert usr;
                               
           List<User> testUsr = [Select Id, legal_Custodian__c from  user u WHERE Id = :usr.Id];        
           System.Debug('What is in testUsr: ' + testUsr);        
           Id uUserid = testUsr[0].Id;
           
           
           usr.legal_custodian__C = true;
           update usr;
           
        
           
 
           
           
           
           
           
           
 
         
        
        
        }
}
}