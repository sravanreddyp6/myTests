@isTest
private class AuthorizationExtTest {
    static testmethod void simpleTests(){
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		List<Authorization__c> auths = new List<Authorization__c>();
        PageReference pageRef = Page.AuthorizationEdit;
        For(integer i=0; i < 5; i++){
       		Funding_Source__c f = new Funding_Source__c(Service_Assignment__c = myData.theSA.Id, Type_of_Coverage__c='Primary');
			insert f;
			Authorization__c s = new Authorization__c(
      			Person_Being_Served__c = myData.contactID,
       			Funding_Source__c = f.id
       		);
        	auths.add(s);
        }
        insert auths;
        Funding_Source__c f = new Funding_Source__c(Service_Assignment__c = myData.theSA.Id, Type_of_Coverage__c='Primary');
		insert f;
        Authorization__c authoriza = new Authorization__c(
       		Person_Being_Served__c = myData.contactID,
       		Authorization_Status__c = 'Draft'
       );
            insert authoriza;
            
		Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('saID', null);  
        AuthorizationExt controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));
        Apexpages.currentPage().getParameters().put('saID', myData.theSA.Id);  
        controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));
        controller.redirectToView(myData.theSA.Id, myData.theSA.Id);
        controller.changeAuthType();
        controller.authorization.type__c='Single Charge';
        controller.authorization.rate_unit__c='Grams';
        controller.authorization.received_Date_time__c = DateTime.Now()+15;
        controller.saveAuth();
		controller.editAuth();
		controller.finalizeAuth();
        controller.cloneAuth();
		
		Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('saID', myData.theSA.Id);   
        controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));
        controller.changeAuthType();
		controller.authorization.type__c='Other';
		controller.authorization.other_authorization_type__c='';
		controller.authorization.rate_unit__c='Unit';
		controller.authorization.rate_unit_other__c='';
        controller.saveAuth();
        controller.finalizeAuth();
        controller.cloneAuth();
        
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('saID', myData.theSA.Id);   
        controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));
        controller.changeAuthType();
		controller.authorization.type__c='Open Ended Stay';
		controller.authorization.rate_unit__c='';
		controller.authorization.rate__c='';
		controller.authorization.level__c='';
		controller.authorization.justification__c='';
        controller.saveAuth();
        controller.finalizeAuth();	
        controller.cloneAuth();
        
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('saID', myData.theSA.Id);   
        controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));
        controller.changeAuthType();
		controller.authorization.type__c='Bed Hold';
		controller.authorization.bed_hold_type__c='';
		controller.authorization.bed_hold_classification__c='';
        controller.saveAuth();
        controller.finalizeAuth();
        controller.cloneAuth();

        
        pageRef = Page.AuthorizationView;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('saID', myData.theSA.Id);  
        controller = new AuthorizationExt(new ApexPages.StandardController(authoriza)); 
        controller.reviseAuth();
        controller.disregardAuth();
    }
}