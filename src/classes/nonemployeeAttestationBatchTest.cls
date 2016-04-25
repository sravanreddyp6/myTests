@isTest
public class nonemployeeAttestationBatchTest {
	@testSetup static void setupData(){
		 User managerSFDC = TMN_Generic_Core_TestData.createUser('System Administrator', 'manager', 'manager@tmn.com', 'Manager', 'LastName', 'NeuroRestorative'); 
		 TMN_User__c managerTMN  = [SELECT Id FROM TMN_user__c WHERE Salesforce_User_Account__c = :managerSFDC.Id];
		 managerTMN.Email__c = 'manager@tmn.com';
		 managerTMN.Alias__c = '001130';
		 managerTMN.Employee_Number__c = '101010';
		 update managerTMN;
		 
		 List<TMN_user__c> tmnusers = new List<TMN_User__c>();
		 
		 TMN_User__c one = new TMN_user__c(Last_Name__c = 'One', First_name__c = 'One', Last_Day__c = Date.Today().addDays(1), Current_Person_type__c = 'Non-Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Manager_Employee_Id__c = '101010', Email__c = 'one@mail.com'); // tRIGGER auto-populates manager Lookup - Covers one test scenario
		 tmnusers.add(one);
		 
 		 TMN_User__c seven = new TMN_user__c(Last_Name__c = 'seven', First_name__c = 'One', Last_Day__c = Date.Today().addDays(7), Current_Person_type__c = 'Non-Employee', 
 					Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Manager_Employee_Id__c = '101010', Email__c = 'seven@mail.com');
 		 tmnusers.add(seven);
 		 
 		 TMN_User__c fourteen = new TMN_user__c(Last_Name__c = 'fourteen', First_name__c = 'One', Last_Day__c = Date.Today().addDays(14), Current_Person_type__c = 'Non-Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Manager_Employee_Id__c = '101010', Email__c = 'fourteen@mail.com');
		 tmnusers.add(fourteen);
		 
		 TMN_User__c noneligible = new TMN_user__c(Last_Name__c = 'noneligible', First_name__c = 'One', Last_Day__c = Date.Today().addDays(14), Current_Person_type__c = 'Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Manager_Employee_Id__c = '101010', Email__c ='noneligible@mail.com');
		 tmnusers.add(noneligible);
		 		
		 TMN_User__c justMiss  = new TMN_user__c(Last_Name__c = 'justMiss', First_name__c = 'One', Last_Day__c = Date.Today().addDays(20), Current_Person_type__c = 'Non-Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Manager_Employee_Id__c = '101010', Email__c = 'justmiss@mail.com');
		 tmnusers.add(justMiss);
		 
		 insert tmnusers;
		 
	}
	
	static testmethod void simpleTests(){
		Test.StartTest();
			nonemployeeAttestationBatch b = new nonemployeeAttestationBatch();
			Database.executebatch(b);
		Test.StopTest();
	}

}