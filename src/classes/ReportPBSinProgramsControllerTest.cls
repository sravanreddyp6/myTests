@isTest
public class ReportPBSinProgramsControllerTest {
	
	@testSetup static void setTestData(){
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		
		Service_Location__c  sl = [SELECT Id, Population_Served__c, Physical_location__c, TMN_Scope__c, Network_offering__c FROM Service_location__c  WHERE Id=:testData.theSA.Service_location__c];
		sl.Population_Served__c = 'test';
		sl.Physical_location__c = 'test';
		sl.TMN_Scope__c = 'test';
		sl.Network_offering__c = 'test';
		sl.Service_type__c = 'test';
		
		update sl;
		
		Contact c = [SELECT Id, BirthDate, Gender__c, Age__c FROM Contact WHERE Id=: testData.contactID];
		c.Gender__c = 'Male';
		c.BirthDate = Date.Today().addYears(-20);
		
		update c;
		
		
	}

	static testmethod void simpleTests(){
		PageReference pg = Page.ReportPBSinPrograms;
		test.setCurrentpageReference(pg);
		ReportPBSinProgramsController controller = new ReportPBSinProgramsController();
		
		controller.fDate = null;
		controller.Run();
		Boolean error = false;
		for(ApexPages.Message message : ApexPages.getMessages()){
			if(message.getSummary().contains('From and To Dates are required')){
				error = true;
			}
		}
		system.assert(error);
		
		controller.fDate = Date.Today().addDays(-10);
		controller.tDate = Date.today().addDays(10);
		controller.maxAge = '25';
		controller.minAge = '0';
		controller.pbsGender = 'Male';
		controller.admState = 'AZ';
		controller.admStatus = 'Active';
		controller.saStatus = 'Active';
		controller.aliases = '370647';
		controller.sltmnscope = 'test';
		controller.slserviceType = 'test';
		controller.slNetworkOffering  = 'test';
		controller.populationServed = 'test';
		controller.physicalLocation = 'test';
		system.assert(controller.stateValues.size() > 0);
		system.assert(controller.serviceTypes.size() > 0);
		
		Test.StartTest();
			controller.run();
			system.assert(controller.servAssigns.size() == 0); //We are nullyfying the list at the end to clear the view State
			system.assert(controller.subServAssigns.size() == 1, controller.subServAssigns.size());
			system.assert(controller.pbsCount == 1);
			system.assert(controller.pbsCount == 1);
			system.assert(controller.SACount == 1);
			controller.exporttoExcel();
		Test.StopTest();
		
		
		
		
		
		
		
	}
}