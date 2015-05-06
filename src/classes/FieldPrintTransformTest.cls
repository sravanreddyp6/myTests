@istest
public with sharing class FieldPrintTransformTest {
	
	static testmethod void simpleTests(){
		Evaluation__c eval = new Evaluation__c(Status__c='Draft');
		insert eval;
		
		Apexpages.StandardController sc = new ApexPages.StandardController(eval);
		FieldPrintTransform controller = new FieldPrintTransform(sc);
		system.assertnotEquals(controller.ctlMap.KeySet().size(), Null);
		
		
	}

}