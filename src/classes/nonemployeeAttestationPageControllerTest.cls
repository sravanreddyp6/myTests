// comment added to create diff by AV
@isTest
public class nonemployeeAttestationPageControllerTest {
	
	@testSetup static void setupData(){
		 User managerSFDC = TMN_Generic_Core_TestData.createUser('System Administrator', 'manager', 'manager@tmn.com', 'Manager', 'LastName', 'NeuroRestorative'); 
		 TMN_User__c managerTMN  = [SELECT Id FROM TMN_user__c WHERE Salesforce_User_Account__c = :managerSFDC.Id];
		 managerTMN.Email__c = 'manager@tmn.com';
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
		PageReference pg = Page.nonemployeeAttestation;
		TMN_User__c manager = [SELECT Id, Email__c, Last_Name__c FROM TMN_User__c WHERE Email__c = 'manager@tmn.com' LIMIT 1];
		TMN_user__c one = [SELECT iD, Last_Day__c FROM TMN_User__c WHERE Manager_lookup__c = :manager.Id AND Last_Name__c = 'One' LIMIT 1];
		TMN_user__c seven = [SELECT iD, Last_Day__c FROM TMN_User__c WHERE Manager_lookup__c = :manager.Id AND Last_Name__c = 'seven' LIMIT 1];
		TMN_user__c fourteen = [SELECT iD, Last_Day__c FROM TMN_User__c WHERE Manager_lookup__c = :manager.Id AND Last_Name__c = 'fourteen' LIMIT 1];
		//TMN_user__c one = [SELECT iD, Last_Day__c FROM TMN_User__c WHERE Manager_lookup__c = :manager.Id AND Last_Name__c = 'One' LIMIT 1];
		
		pg.getparameters().put('managerId', manager.Id);
		test.setCurrentpage(pg);
		nonemployeeAttestationPageController controller = new nonemployeeAttestationPageController();
		controller.managerId = manager.Id;
		system.assert(controller.nonemployeesinitial.size() == 3, controller.nonemployeesinitial.size());
		system.assert(controller.manager.Last_name__c == manager.Last_name__c);
		

		controller.setparams();
		controller.flag = 'thirty';
		controller.employeeId = one.Id;
		controller.updateTMNUser();
		system.assert([SELECT Id, Last_day__c FROM TMN_User__c WHERE Last_name__c = 'One' AND Manager_lookup__c = :manager.Id LIMIT 1].Last_Day__c == one.Last_Day__c.addDays(30));
		
		controller.setparams();
		controller.flag = 'sixty';
		controller.employeeId = seven.Id;
		controller.updateTMNUser();
		system.assert([SELECT Id, Last_day__c FROM TMN_User__c WHERE Last_name__c = 'seven' AND Manager_lookup__c = :manager.Id LIMIT 1].Last_Day__c == seven.Last_Day__c.addDays(60));
		
		controller.setparams();
		controller.flag = 'ninety';
		controller.employeeId = fourteen.Id;
		controller.updateTMNUser();
		system.assert([SELECT Id, Last_day__c FROM TMN_User__c WHERE Last_name__c = 'fourteen' AND Manager_lookup__c = :manager.Id LIMIT 1].Last_Day__c == fourteen.Last_Day__c.addDays(90));
		
		one.Last_Day__c = Date.today().addDays(12);
		
		controller.setparams();
		controller.flag = 'now';
		controller.employeeId = one.Id;
		controller.updateTMNUser();
		system.assert([SELECT Id, Last_day__c FROM TMN_User__c WHERE Last_name__c = 'One' AND Manager_lookup__c = :manager.Id LIMIT 1].Last_Day__c == Date.today());
		
		controller.setparams();
		controller.openModalDialog();
		controller.flag = 'other';
		controller.employeeId = one.Id;
		pg.getparameters().put('dateChoosenString', string.ValueOf(Date.today().addDays(20)));
		//controller.dateChoosenString = string.ValueOf(Date.today().addDays(20));
		controller.updateTMNUser();
		system.assert([SELECT Id, Last_day__c FROM TMN_User__c WHERE Last_name__c = 'One' AND Manager_lookup__c = :manager.Id LIMIT 1].Last_Day__c == Date.today().addDays(20));
		
		
		
	}
	

}