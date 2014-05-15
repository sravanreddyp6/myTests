@isTest
private class Assessment_FAD_Form_Ex_Test {

    static testMethod void myUnitTest() {
    	
    	User theCurrentUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
    	List<PermissionSet> thePermSets = [ SELECT Id FROM PermissionSet WHERE Name IN ('ESD_Notes_Organizer', 'ESD_Notes_Supervisor') ];
    	
    	List<PermissionSetAssignment> thePermSetAssigns = new List<PermissionSetAssignment>();
    	List<PermissionSetAssignment> existingPermSetAssignsForUser = [ SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :theCurrentUser.Id ];
    	
    	
    	for(PermissionSet p : thePermSets) {
    		Boolean skipTheInsert = false;
    		for(PermissionSetAssignment pSA : existingPermSetAssignsForUser) {
    			if(p.Id==pSA.PermissionSetId) {
    				skipTheInsert = true;
    			}    			
    		}
    		if(skipTheInsert==false) {
    			thePermSetAssigns.add(new PermissionSetAssignment(PermissionSetId = p.Id, AssigneeId = theCurrentUser.Id));
    		}
    	}
    	insert thePermSetAssigns;
    	
        Assessment_Fad_TestData.createTestData();
        
        Assessment__c assess=  Assessment_Fad_TestData.createAssessment();
        Assessment_FAD_Form_Ex controller = new Assessment_FAD_Form_Ex(new ApexPages.StandardController(assess)); 
        
        controller.getCanSubmit();
        controller.myCG_is_same_as_other_assessment();
        controller.getRelParty();
        
        controller.myDisregard();    
        system.assertEquals(assess.Disregard__c,true);
    
        system.assertEquals(controller.getCanSubmit(),true);
        system.assertEquals(controller.getcanUnlock(),true);
        
        controller.myUnlock();
        system.assertEquals(assess.status__c, 'Open');
        
        controller.mapRes.get('PBS_Problem_Solving').Score__c = 1.23;
        controller.mySave();
        assessment_response__c testAR = new assessment_response__c();
        testAR = [select score__c from assessment_response__c where assessment__c = :assess.id AND Question__r.Dev_Name__c = 'PBS_Problem_Solving'];
        system.assertEquals(testAR.score__c, 1.23);        
        
        controller.myEdit();
        //the record is locked so edit mode should be alloweed
        system.assertEquals(controller.mode,'edit');

		controller.mapRes.get('PBS_Problem_Solving').Score__c = null;
		controller.mapRes.get('CG_Could_Not_complete').Yes_No__c = true;
		controller.mapRes.get('PBS_Could_Not_complete').Yes_No__c = true;
		controller.myLock();		
        //we're not answering any questions so the record should not lock		
		system.assertEquals(assess.status__c, 'Open');
		
		controller.mapRes.get('CG_Could_Not_complete').Yes_No__c = false;
		controller.mapRes.get('PBS_Could_Not_complete').Yes_No__c = false;
		controller.mapRes.get('PBS_Problem_Solving').Score__c = 1.23;
		controller.mapRes.get('PBS_Communication').Score__c = 1.2;
		controller.mapRes.get('PBS_Roles').Score__c = 1.2;
		controller.mapRes.get('PBS_Affective_Responses').Score__c = 1.2;
		controller.mapRes.get('PBS_Affective_Involvement').Score__c = 1.2;
		controller.mapRes.get('PBS_Behavior_Control').Score__c = 1.2;
		controller.mapRes.get('PBS_General_Functioning').Score__c = 1.2;
		controller.mapRes.get('CG_Problem_Solving').Score__c = 1.2;
		controller.mapRes.get('CG_Communication').Score__c = 1.2;
		controller.mapRes.get('CG_Roles').Score__c = 1.2;
		controller.mapRes.get('CG_Affective_Responses').Score__c = 1.2;
		controller.mapRes.get('CG_Affective_Involvement').Score__c = 1.2; 
		controller.mapRes.get('CG_Behavior_Control').Score__c = 1.2;
		controller.mapRes.get('CG_General_Functioning').Score__c = 1.2;
		controller.mapRes.get('CG_is_same_as_other_assessment').Rating__c = 'Yes';
			
        controller.myLock();
        //now we have answered questions the record should lock
        system.assertEquals(assess.status__c, 'Locked');        
        
        controller.myCancel();
        assessment__c[] allassess = [select id from assessment__c];
        system.assertEquals(allassess.size(),0);
    }

    

    
}