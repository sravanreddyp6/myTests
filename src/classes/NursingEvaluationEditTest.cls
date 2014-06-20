@isTest
private class NursingEvaluationEditTest {
	static testmethod void editTest(){
		Contact c = new Contact();
		c.LastName = 'test last name';
		c.Birthdate = Date.today();
		insert c;
		
		Admission__c adm = new Admission__c();
		adm.Person_Being_Served__c = c.id;
		insert adm;
		
		Service_Assignment__c sa = new Service_Assignment__c();
		sa.Admission__c = adm.id;
		insert sa;
		
		Evaluation__c evaluation = new Evaluation__c();
		evaluation.RecordTypeId = Utility.getEValuationRecordType('NursesAssessment');
		evaluation.ServiceAssignment__c = sa.id;
		insert evaluation;
		
		Related_Party__c rp = new Related_Party__c();
		rp.Name = 'Relatedparty Test';
		rp.Type__c = 'Guardian';
		rp.Person_Being_Served__c = c.id;
		insert rp;
		
		evaluation =[SELECT Id, ServiceAssignment__c, RecordType.Name,ServiceAssignment__r.Admission__r.Person_Being_Served__c FROM Evaluation__c Where id=:evaluation.Id ];
		
		NursingEvaluationEditController controller = new NursingEvaluationEditController(new ApexPages.StandardController(evaluation));
		
		System.assertNotEquals(0,controller.sliderOptions.size());
		System.assertEquals(0, controller.annotations.size());
        System.assertNotEquals(null, controller.relatedParties);
        controller.showAddRelatedParty();
        System.assertEquals(null, controller.currentRelatedParty.Id);
        controller.currentRelatedPartyId = rp.Id;
        controller.showEditRelatedParty();
        System.assertEquals(rp.Id, controller.currentRelatedParty.Id);
        controller.currentRelatedParty.Name = 'New Name';
        controller.saveRelatedParty();
		NursingEvaluationEditController.addOrModifyAnnotation(null,'neuroTab',1,1,1,1,'','',evaluation.Id);
		Evaluation_Response__c[] neuroAnnotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='NeuroAnnotation' AND Evaluation__c=:evaluation.Id
        ];
		System.assertEquals(1,neuroAnnotations.size());
		NursingEvaluationEditController.addorModifyAnnotation(null,'',1,1,1,1,'','',evaluation.Id);
		Evaluation_Response__c[] annotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='Annotation' AND Evaluation__c=:evaluation.Id
        ];
		System.assertEquals(1,annotations.size());
		NursingEvaluationEditController.addorModifyAnnotation(neuroAnnotations[0].Id,'neuroTab',2,2,2,2,'','',evaluation.Id);
		NursingEvaluationEditController.deleteAnnotation(neuroAnnotations[0].id);
		neuroAnnotations = [
            SELECT ID FROM Evaluation_Response__c
            WHERE RecordType.Name='NeuroAnnotation' AND Evaluation__c=:evaluation.Id
        ];
		system.assertEquals(0,neuroAnnotations.size());
		controller.nextTab = 'diagnosticTab';
		controller.changeTab();
		controller.save();
		
	}

}