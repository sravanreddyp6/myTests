@isTest
public class nonemployeeAttestationControllerTest {
	
	@testSetup static void setupData(){
		 User managerSFDC = TMN_Generic_Core_TestData.createUser('System Administrator', 'manager', 'manager@tmn.com', 'Manager', 'LastName', 'NeuroRestorative'); 
		 TMN_User__c managerTMN  = [SELECT Id FROM TMN_user__c WHERE Salesforce_User_Account__c = :managerSFDC.Id];
		 managerTMN.Email__c = 'manager@tmn.com';
		 update managerTMN;
		 
		 List<TMN_user__c> tmnusers = new List<TMN_User__c>();
		 
		 TMN_User__c one = new TMN_user__c(Last_Name__c = 'One', First_name__c = 'One', Last_Day__c = Date.Today().addDays(1), Current_Person_type__c = 'Non-Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Email__c = 'one@mail.com'); // tRIGGER auto-populates manager Lookup - Covers one test scenario
		 tmnusers.add(one);
		 
 		 TMN_User__c seven = new TMN_user__c(Last_Name__c = 'seven', First_name__c = 'One', Last_Day__c = Date.Today().addDays(7), Current_Person_type__c = 'Non-Employee', 
 					Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Email__c = 'seven@mail.com');
 		 tmnusers.add(seven);
 		 
 		 TMN_User__c fourteen = new TMN_user__c(Last_Name__c = 'fourteen', First_name__c = 'One', Last_Day__c = Date.Today().addDays(14), Current_Person_type__c = 'Non-Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Email__c = 'fourteen@mail.com');
		 tmnusers.add(fourteen);
		 
		 TMN_User__c noneligible = new TMN_user__c(Last_Name__c = 'noneligible', First_name__c = 'One', Last_Day__c = Date.Today().addDays(14), Current_Person_type__c = 'Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Email__c ='noneligible@mail.com');
		 tmnusers.add(noneligible);
		 		
		 TMN_User__c justMiss  = new TMN_user__c(Last_Name__c = 'justMiss', First_name__c = 'One', Last_Day__c = Date.Today().addDays(20), Current_Person_type__c = 'Non-Employee', 
		 				Job_Status__c = 'Active', Job_title__c = 'test', Manager_Email__c = 'manager@tmn.com', Email__c = 'justmiss@mail.com');
		 tmnusers.add(justMiss);
		 
		 insert tmnusers;
		 
		 Site_URL__c s = new Site_URL__c(name = 'NonemployeeAttestationSite', prefix__c = 'testURL');
		 insert s;	
	}
	
	static testmethod void simpleTests(){
		nonemployeeAttestationController controller = new nonemployeeAttestationController();
		TMN_user__c manager = [SELECT Id, Last_Name__c, First_Name__c, Email__c FROM TMN_user__c WHERE Email__c = 'manager@tmn.com' LIMIT 1];
		controller.managerId = manager.Id;
		system.assert(controller.manager.Last_name__c  == manager.Last_name__c);
		system.assert(controller.nonemployees.size() == 3);
		system.assert(controller.getbaseUrl() == 'testURL');
	}

}