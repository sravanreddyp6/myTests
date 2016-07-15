@isTest
private class SACEditView_Test {

    static testMethod void SACTest() {
    	
    	TMN_Generic_Core_TestData myTestData = new TMN_Generic_Core_TestData();
    	myTestData.LoadData('FL');
    	
    	PageReference ref = new PageReference('/apex/ServiceAssignmentClosureEditView');
    	Test.setCurrentPage(ref);
    	apexpages.currentpage().getparameters().put('ServAssignId', myTestData.theSA.Id);
    	apexpages.currentpage().getparameters().put('AdmId', myTestData.theAdm.Id);
    	apexpages.currentpage().getparameters().put('PBSId', myTestData.contactId);

		Service_Assignment_Closure__c sac = new  Service_Assignment_Closure__c();
		ServiceAssignmentClosureEditView sacEdit = new ServiceAssignmentClosureEditView(new ApexPages.StandardController(sac));
		System.AssertEquals( sacEdit.editMode, true);
		
		sacEdit.Cancel();
		System.AssertEquals( sacEdit.editMode, false);
		
		sacEdit.editSac();
		System.AssertEquals( sacEdit.editMode, true);
		
		// will fire some messages
		sacEdit.save();
				
		// will fire messages		
		sacEdit.submit();
		System.Assert (ApexPages.getMessages().size() > 0 ); 

		// open a new page with this existing SAC
		sacEdit = new ServiceAssignmentClosureEditView(new ApexPages.StandardController(sac));
		System.AssertEquals( sacEdit.editMode, false);
		
		sacEdit.editSac();
		System.AssertEquals( sacEdit.editMode, true);

        
    }
    
    
}