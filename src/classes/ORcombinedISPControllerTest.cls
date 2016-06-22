@isTest
public class ORcombinedISPControllerTest {
	
	@testSetup
	static void setupData(){
		User caseManager = TMN_Generic_Core_TestData.createUser('ESD General', 'rwCMOR', 'rwCasemanager@mail.com', 'ORTEST', 'ORTEST', 'Redwood');
       //Assigning permission sets to the user.
        List<String> permsets = new List<String> {'ESD_Notes_Common','ESD_Referrals_Intaker_Light', 'ESD_Referrals_Common','ESD_Notes_Admission_Packet', 'iServe_Case_Management'};
        system.runas(new User(Id = Userinfo.getUserId())){ //Running the permissionset Assignment as a seperate user to avoid MIXED DML Operation error.
            TMN_Generic_Core_TestData.permsetAssign(permsets, caseManager.Id);
        }
        
       //caseManager = [SELECT ID FROM User WHERE alias = 'rwCMOR' LIMIT 1];
        system.runas(caseManager){
        	TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
			Apexpages.StandardController sc = new Apexpages.StandardController(testData.theSA);
			ServiceAssignmentExt ext = new ServiceAssignmentExt(sc);
			PageReference dummyPage = ext.addORISP(); //Covers ServiceAssignmentExt Class as well.
        }
	}
	
	
	static testmethod void simpleTests(){
		
		User caseManager = [SELECT ID FROM User WHERE alias = 'rwCMOR' LIMIT 1];
		system.runAs(caseManager){
			Service_Assignment__c SA = [SELECT Id, Person_being_Served__c, Admission__r.Person_being_Served__c, Admission__r.Person_being_Served__r.FirstName, Admission__r.Person_being_Served__r.LastName FROM Service_Assignment__c WHERE CreatedDate = TODAY LIMIT 1];
			Case_Management_Plan__c isp = [SELECT Id, name, Status__c, Service_Assignment__c, CDP_WA_Check_Apply_int_Employment__c, CDP_WA_Check_Apply_nonworking__c, CDP_NE_Check_Apply_Decision_Not_Explore__c, 
											KPR_Included_Services__c, KPR_Additional_Services__c, CreatedBy.Name, KPR_Residential_Secton_Not_Applicable__c,KPR_IsValid__c  FROM Case_Management_plan__c WHERE Service_Assignment__c = : SA.Id AND createdDate = TODAY LIMIT 1];
											
			system.assert(isp.Status__c == 'Inactive Draft'); //Validate the initially created record
			
			PageReference pg = Page.ORcombinedISP;
			test.setCurrentPage(pg);
			ApexPages.CurrentPage().getParameters().put('mode', 'EDIT');
			
			Apexpages.StandardController sc = new Apexpages.StandardController(isp);
			ORcombinedISPController controller = new ORcombinedISPController(sc);
			system.assertEquals(true,  controller.isEditMode);
			system.assertEquals(false, controller.isViewMode);
			system.assertEquals(false,  controller.canEdit);
			system.assertEquals(false, controller.canFinalize); // because of edit mode
			system.assertEquals(false, controller.canRevise);
			//initial creation validations
			system.assert(controller.isp.Status__c == 'Inactive Draft');
			system.assert(controller.isp.KPR_Residential_Secton_Not_Applicable__c);
			system.assert(controller.isp.KPR_IsValid__c );
			
			
			//Plan Dates
			controller.section = 'planDates';
			controller.isp.PD_Start__c = Date.Today();
			controller.isp.PD_End__c = Date.Today().addDays(1);
			controller.save();
			
			ApexPages.CurrentPage().getParameters().put('mode', 'EDIT');
			controller.section = 'relparty';
			controller.showAddRelParty();
			Related_Party__c relParty = ORcombinedISPController.saveRelatedParty(null, 'Test', 'Parent', '', '', '', '', '', '', '', '', SA.Admission__r.Person_being_Served__c);
			controller.saveRelparty();
			ORcombinedISPController.loadRelatedParty(relParty.Id);
	        Related_Party__c rp2 = ORcombinedISPController.saveRelatedParty(relParty.Id, 'Test ', 'Parent', '', '', '', '', '', '', '', '', SA.Admission__r.Person_being_Served__c);
	        system.assertEquals(relParty.Type__c,rp2.Type__c);
	        //string s = controller.relPartiesJSON();
	        controller.save();
	        
	        
	       // ApexPages.CurrentPage().getParameters().put('mode', 'EDIT');
			controller.section = 'legal';
			controller.pullhealthCareReps();
	        controller.addorRefreshLegal();
	        controller.save();
	  	
	        //system.assert(controller.isp.Leg_Parents__c.contains('Test'));
	        //ApexPages.CurrentPage().getParameters().put('mode', 'EDIT');
			controller.section = 'agreement';
	        controller.showAddContributor();
	        Evaluation_Response__c contributor = ORcombinedISPController.saveContributor(null, 'Name', 'title', false, false, 'No', controller.isp.Id);
	        controller.savecontributor();
	        ApexPages.CurrentPage().getParameters().put('contributorID', contributor.Id);
	        controller.showEditContributor();
	        controller.save();
	        
	        
	        //ApexPages.CurrentPage().getParameters().put('mode', 'EDIT');
			controller.section = 'cdp';
			controller.selectedintEmployment =  new List<string>{'test1','test2'};
			controller.selectednonworking 	 =  new List<string>{'test1','test2'};
			controller.selectednotToExplore  =  new List<string>{'test1','test2'};
			controller.save();
			
			controller.section = 'kpr';
			controller.selectedKPRServices =  new List<string>{'test1','test2'};
			controller.selectedKPRAdditional 	 =  new List<string>{'test1','test2'};
			controller.save();
			
			
			controller.section = 'kplan';
			controller.isp.K_Plan_Section_Not_Applicable__c =  false;
			controller.save();
			
			controller.section = 'waiver';
			controller.isp.Waiver_Section_Not_Applicable__c =  true;
			controller.save();
			
			controller.section = 'desiredOutcomes';
			controller.save();
			
	        controller.cancel();
			controller.finalize();
	        controller.revise();
        
		}
		
	}
    
}