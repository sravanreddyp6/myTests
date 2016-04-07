@isTest
public class restraintReductionControllerTest {
	
	static testmethod void simpleTests(){
		 TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		  
		  Evaluation__c eval = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id
		  );
		  insert eval;

		 Assessment_Domain__c restraintDomain = new Assessment_Domain__c();
		 restraintDomain.Name = 'Restraint Questions';
		 restraintDomain.Assessment_Type2__c = 'Restraint Reduction';
		 restraintDomain.Sort_Order__c = 1;
		 
		 insert restraintDomain;
		 
		 
		 List<Assessment_Question__c> questions = new List<Assessment_Question__c>();
		 Assessment_Question__c q1 = new Assessment_Question__c();
		 q1.Question_Title__c = 'Res Test';
		 q1.Is_MultiSelect__c = True;
		 q1.Question_Domain__c = restraintDomain.Id;
		 insert q1;
		 
		 Assessment_Question__c q2 = new Assessment_Question__c();
		 q2.Question_Title__c = 'Res test 2';
		 q2.Question_Domain__c = restraintDomain.id;
		 insert q2;
		 
		 string sectionId = Userinfo.getUserId()+'-'+DateTime.now().getTime();
		 Assessment__c asmt = new Assessment__c();
		 asmt.Name = sectionId;
		 asmt.Evaluation__c = eval.Id;
		 asmt.Service_Assignment__c = myData.theSA.Id;
		 asmt.Admission__c = myData.theSA.Admission__c;
		 asmt.AccountPerson__c = myData.theSA.Person_Being_Served__r.AccountId; 
		 asmt.Type__c = 'Restraint Reduction';
		 
		 insert asmt;
		 
		 Eval_Type__c evlTyp = new Eval_Type__c(Name = 'TEST', Category__c = 'TEST', External_Eval_Type_ID__c = 1);
         insert evlTyp;
		 
		 Eval__c ev = new Eval__c();
		 ev.Field_Name__c = 'IsValid';
		 ev.Field_type__c = 'Boolean';
		 ev.Category__c = 'Reduction Review';
		 ev.Sub_category__c = 'Reduction Review';
		 ev.htmlid__c = 'isValid';
		 ev.Eval_type__c = evlTyp.Id;
		 insert ev;
		 
		 Eval_Value__c value = new Eval_Value__c();
		 value.Eval__c = ev.Id;
		 value.Boolean__c = false;
		 value.What_Id__c = eval.Id;
		 value.What_ID_Object__c = 'Evaluation__c';
		 value.Eval_Section_Id__c = sectionId;
		 insert value;
		 
		
		 
		 restraintReductionController controller = new restraintReductionController();
		 controller.assId = asmt.Id;
		 controller.getThisRecordsDomains();
		 system.assert(controller.assessment != null);
		 system.assert(controller.questions != null);
		 system.assert(controller.questionsMap != null);
		 system.assert(controller.questionResponseMap != null);
		 system.assert(!controller.getViewMode());
		 controller.questionID = q1.Id;
		 controller.MyRating = 'test';
		 controller.MyScore = 2;
		 controller.MyColor = 'red';
		 
		 controller.myUpsert();
		 system.assert(!controller.getshowComplete());
		 controller.disregard();
		 controller.complete();
		 
	}

}