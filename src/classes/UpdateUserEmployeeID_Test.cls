@isTest
private class UpdateUserEmployeeID_Test {

    static testMethod void myUnitTest() {
            
                                 
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard Platform User']; 
      User newUser = new User(Alias = 'standt6', Email='standarduser6@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing6', FirstName='FirstName6', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser6@testorg.com');


        insert newUser;
                                 
        ID newUserId = newUser.Id;                             
            
        TMN_User__c tmnUser = new TMN_User__c(
            First_Name__c= 'Firstname',
            Last_Name__c='Testing',
            Employee_Number__c = '12345453'
            );    
            
        insert tmnUser;
            
        // now associate the user and check that the employenumber has changed
        tmnUser.Salesforce_User_Account__c = newUserId;
        update tmnUser;
        
        newUser = [ select ID, FirstName, LastName, EmployeeNumber from user where id = :newUser.Id ];
        
        System.AssertEquals( tmnUser.Employee_Number__c, newUser.EmployeeNumber );
        
        // update the employee ID and make sure it ripples
        tmnUser.Employee_Number__c = '12345678';
        update tmnUser;
        newUser = [ select ID, FirstName, LastName, EmployeeNumber from user where id = :newUser.Id ];
        
        System.AssertEquals( tmnUser.Employee_Number__c, newUser.EmployeeNumber );

        // now disassociate the SF account and make sure it blanks out the EmployeeNumber
        tmnUser.Salesforce_User_Account__c = null;
        update tmnUser;
        
        // verify the empID is blank on the SF user
        newUser = [ select ID, FirstName, LastName, EmployeeNumber from user where id = :newUser.Id ];
        
        System.AssertEquals( newUser.EmployeeNumber, null );
 
        
        }
        

        
        
 }