@isTest
private class fallAssessmentControllerTest {
	
	static testMethod void myUnitTest() {
		
		  TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		  Evaluation__c eval = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id
		  );
		  insert eval;
		  
		  
		  
		 List<Assessment_Domain__c> domains = new List<Assessment_Domain__c>();
		 Assessment_Domain__c fallDomain = new Assessment_Domain__c();
		 fallDomain.Name = 'Fall Risk Assessment Domain';
		 fallDomain.Assessment_Type2__c = 'Resident Assessment';
		 fallDomain.Sort_Order__c = 1;
		 domains.add(fallDomain);
		 
		 Assessment_Domain__c skinDomain = new Assessment_Domain__c();
		 skinDomain.Name = 'Skin Assessment Domain';
		 skinDomain.Assessment_Type2__c = 'Resident Assessment';
		 skinDomain.Sort_Order__c = 2;
		 domains.add(skinDomain);
		 
		 insert domains;
		 
		 List<Assessment_Domain__c> thisDomains = [SELECT Id FROM Assessment_Domain__c WHERE Assessment_Type2__c = 'Resident Assessment' order by Sort_Order__c asc ];
		 
		 List<Assessment_Question__c> questions = new List<Assessment_Question__c>();
		 Assessment_Question__c q1 = new Assessment_Question__c();
		 q1.Question_Title__c = 'Fall Test';
		 q1.Is_MultiSelect__c = True;
		 q1.Question_Domain__c = thisDomains[1].Id;
		 questions.add(q1);
		 
		 Assessment_Question__c q2 = new Assessment_Question__c();
		 q2.Question_Title__c = 'Skin Test';
		 q2.Question_Domain__c = thisDomains[0].id;
		 questions.add(q2);
		 
		 insert questions;
		 
		 
		 List<Assessment_Question__c> qs = [SELECT Id FROM Assessment_Question__c WHERE Id IN: questions];
		 
		 Test.startTest();
		 
		 Assessment__c asmt = new Assessment__c();
		 asmt.Evaluation__c = eval.Id;
		 asmt.Service_Assignment__c = myData.theSA.Id;
		 asmt.Admission__c = myData.theSA.Admission__c;
		 asmt.AccountPerson__c = myData.theSA.Person_Being_Served__r.AccountId; 
		 asmt.Type__c = 'Resident Assessment';
		 
		 insert asmt;
		 
		 PageReference pageRef = Page.NursingEvaluationEdit;
		 test.setCurrentpage(pageRef);
		 Apexpages.StandardController sc = new ApexPages.StandardController(eval);
		 fallAssessmentController controller = new fallAssessmentController(sc);
		 
		 system.assertEquals(2, controller.ListForMapCurrentResponses.size());
		 system.assertEquals(true,fallAssessmentController.validateError(eval.Id, 'Fall Risk Assessment Domain'));
		 
		 controller.getMapDomains();
		 controller.getMapAnswers();
		 controller.getMapQuestions();
		 controller.getMapskinDomains();
		 controller.getMapskinAnswers();
		 controller.getMapskinQuestions();
		 
		 controller.MyRating = 'test';
		 controller.MyScore = 2;
		 controller.MyColor = 'green';
		 controller.questionID = qs[1].Id;
		
		 controller.myUpsert();
		 system.assertEquals(false,fallAssessmentController.validateError(eval.Id, 'Fall Risk Assessment Domain'));
		 
		 controller.clearSelection();
		 system.assertEquals(true,fallAssessmentController.validateError(eval.Id, 'Fall Risk Assessment Domain'));
		 
		 controller.questionID = qs[0].Id;
		 controller.myUpsert2();
		 Test.StopTest();
		 
		 
		 
	}

}