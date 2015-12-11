@isTest
public class neuroreportofserviceControllerTest {
	
	@testSetup static void methodName() {
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		List<Service_location__c> testLocations = new List<Service_location__c>();
		for(integer i=0; i<10; i++){
			Service_location__c sl = new service_location__c();
			sl.state__c = 'A'+i;
			sl.program__c = '12345'+i;
			sl.name = 'test location'+i;
			sl.Alias__c = 'Alias'+i;
			sl.FacilityID__c = 20;
			sl.ProgramID__c =  '1212'+i;
			sl.UniqueID__c = '100102'+i;
			testLocations.add(sl);
			
		}
		
		insert testLocations;
		
		List<Funding_Source__c> fslist = new list<Funding_Source__c>();
		Funding_Source__c fs1 = new Funding_Source__c();
		fs1.Funding_Source_Status__c = 'Active Final';
		fs1.Type_of_Coverage__c = 'Primary';
		fs1.Service_Assignment__c = testData.theSA.Id;
		fs1.Rate__c = '12345';
		fs1.Case_Manager__c = userinfo.getuserId();
		fs1.RecordtypeId = Utility.getRecordTypeForFundingSource('NeuroRestorative');
		fs1.Effective_Date_of_Cost_therapy_Auth__c = System.Today().addDays(-15);
		fs1.Term_Date_of_Cost_therapy_Auth__c = system.Today();
		
		fslist.add(fs1);
		
		Funding_Source__c fs2 = new Funding_Source__c();
		fs2.Funding_Source_Status__c = 'Active';
		fs2.Service_Assignment__c = testData.theSA.Id;
		fs2.Rate__c = '12345';
		fs2.RecordtypeId = Utility.getRecordTypeForFundingSource('NeuroRestorative');
		fs2.Type_of_Coverage__c = 'Secondary';
		fs2.Effective_Date_of_Cost_therapy_Auth__c = System.Today().addDays(-15);
		fs2.Term_Date_of_Cost_therapy_Auth__c = system.Today();
		
		fslist.add(fs2);
		
		insert fslist;
		
		List<progress_note__c> pnlist = new List<progress_note__c>();
		List<progress_note__c> pnlist2 = new List<Progress_note__c>();
		
		Id therapyId = Schema.SObjectType.Progress_Note__c.getRecordTypeInfosByName().get('Therapy').getRecordTypeId();
		Progress_Note__c PN1 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN1.Therapy_Discipline__c = 'PT';
		PN1.RecordtypeId = therapyId;
		PN1.Type_of_Contact__c = 'Phone';
		pnlist.add(PN1);
		update PN1;
		
		Progress_Note__c PN3 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN3.Therapy_Discipline__c = 'OT';
		PN3.RecordtypeId = therapyId;
		PN3.Type_of_Contact__c = 'Phone';
		pnlist.add(PN3);
		update PN3;

	}
	
	static testmethod void simpleTests(){
		/*TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		List<Service_location__c> testLocations = new List<Service_location__c>();
		for(integer i=0; i<10; i++){
			Service_location__c sl = new service_location__c();
			sl.state__c = 'A'+i;
			sl.program__c = '12345'+i;
			sl.name = 'test location'+i;
			sl.Alias__c = 'Alias'+i;
			sl.FacilityID__c = 20;
			sl.ProgramID__c =  '1212'+i;
			sl.UniqueID__c = '100102'+i;
			testLocations.add(sl);
			
		}
		
		insert testLocations;
		
		List<Funding_Source__c> fslist = new list<Funding_Source__c>();
		Funding_Source__c fs1 = new Funding_Source__c();
		fs1.Funding_Source_Status__c = 'Active Final';
		fs1.Type_of_Coverage__c = 'Primary';
		fs1.Service_Assignment__c = testData.theSA.Id;
		fs1.Rate__c = '12345';
		fs1.Case_Manager__c = userinfo.getuserId();
		fs1.RecordtypeId = Utility.getRecordTypeForFundingSource('NeuroRestorative');
		fs1.Effective_Date_of_Cost_therapy_Auth__c = System.Today().addDays(-15);
		fs1.Term_Date_of_Cost_therapy_Auth__c = system.Today();
		
		fslist.add(fs1);
		
		Funding_Source__c fs2 = new Funding_Source__c();
		fs2.Funding_Source_Status__c = 'Active';
		fs2.Service_Assignment__c = testData.theSA.Id;
		fs2.Rate__c = '12345';
		fs2.RecordtypeId = Utility.getRecordTypeForFundingSource('NeuroRestorative');
		fs2.Type_of_Coverage__c = 'Secondary';
		fs2.Effective_Date_of_Cost_therapy_Auth__c = System.Today().addDays(-15);
		fs2.Term_Date_of_Cost_therapy_Auth__c = system.Today();
		
		fslist.add(fs2);
		
		insert fslist;
		
		//List<progress_note__c> pnlist = new List<progress_note__c>();
		//List<progress_note__c> pnlist2 = new List<Progress_note__c>();
		
		Id therapyId = Schema.SObjectType.Progress_Note__c.getRecordTypeInfosByName().get('Therapy').getRecordTypeId();
		Progress_Note__c PN1 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN1.Therapy_Discipline__c = 'PT';
		PN1.RecordtypeId = therapyId;
		PN1.Type_of_Contact__c = 'Phone';
		//pnlist.add(PN1);
		update PN1;
		
		Progress_Note__c PN3 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN3.Therapy_Discipline__c = 'OT';
		PN3.RecordtypeId = therapyId;
		PN3.Type_of_Contact__c = 'Phone';
		//pnlist.add(PN3);
		update PN3;
		
		Progress_Note__c PN4 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN4.Therapy_Discipline__c = 'SLP';
		PN4.RecordtypeId = therapyId;
		PN4.Type_of_Contact__c = 'Phone';
		//pnlist.add(PN4);
		update PN4;
		
		//update pnlist;
		
		Progress_Note__c PN5 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN5.Therapy_Discipline__c = 'Counseling';
		PN5.Type_of_Contact__c = 'Phone';
		PN5.RecordtypeId = therapyId;
		//pnlist2.add(PN5);
		update PN5;
		
		Progress_Note__c PN6 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN6.Therapy_Discipline__c = 'BIT';
		PN6.RecordtypeId = therapyId;
		PN6.Type_of_Contact__c = 'Phone';
		//pnlist2.add(PN6);
		update PN6;
		
		Progress_Note__c PN2 = TMN_Generic_Core_TestData.createProgressNote(testData.theSA, testData.theAdm, testData.theServiceCode, testData.contactID, Datetime.now().addDays(-6),Datetime.now().addDays(-5));
		PN2.Therapy_Discipline__c = 'PT';
		PN2.RecordtypeId = therapyId;
		PN2.Type_of_Contact__c = 'No-Show';
		//pnlist2.add(PN2);
		update PN2;*/
		
		//update pnlist2;
		
		test.StartTest();
		Pagereference pf = Page.neuroReportofService;
		test.setCurrentpage(pf);
		Funding_Source__c fs = new Funding_Source__c();
		Apexpages.StandardController sc = new Apexpages.StandardController(fs);
		neuroreportofserviceController controller = new neuroreportofserviceController(sc);
		fs.Effective_Date_of_Cost_therapy_Auth__c = System.Today().addDays(-10);
		fs.Term_Date_of_Cost_therapy_Auth__c = System.Today().addDays(-2);
		fs.Case_manager__c = userinfo.getUserId();
		controller.uiselStates = '';
		controller.uiselProgs = '';
		controller.doSearch();
		system.assert(controller.lineitems.size() == 1,controller.lineitems.size());
		controller.exporttoExcel();
		controller.onlyNoshow = true;
		controller.doSearch();
		system.assert(controller.lineitems[0].ptRollup != 0, controller.lineitems[0].ptRollup);
		fs.Effective_Date_of_Cost_therapy_Auth__c = System.Today().addDays(10);
		fs.Term_Date_of_Cost_therapy_Auth__c = System.Today().addDays(12);
		controller.doSearch();
		system.assert(controller.lineitems.size() == 0,controller.lineitems.size());
		fs.Effective_Date_of_Cost_therapy_Auth__c = System.Today().addDays(12);
		fs.Term_Date_of_Cost_therapy_Auth__c = System.Today().addDays(10);
		controller.doSearch();
        controller.getPrgmsWithStates();
		test.StopTest();
		
		
		
	}

}