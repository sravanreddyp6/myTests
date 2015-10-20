@isTest
private class AuthorizationExtTest {
    static testmethod void simpleTests(){
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
		List<Authorization__c> auths = new List<Authorization__c>();
        
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
       		Authorization_Status__c = 'Draft',
       		type__c='Other',
       		other_authorization_type__c='Test',
       		Funding_Source__c = f.id
       );
            insert authoriza;
       
       
        PageReference pageRef = Page.AuthorizationEdit;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('saID', myData.theSA.Id); 
        AuthorizationExt controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));
       	controller.changeAuthType();
       	
       	
       	
		controller.editAuth();			      
		
		controller.authorization.type__c='Test';
		controller.authorization.other_authorization_type__c='Test';
		controller.authorization.received_Date_time__c=date.newinstance(2020, 06, 17);
		
		controller.saveAuth();
		controller.finalizeAuth();
		controller.cloneAuth();
		controller.reviseAuth();
		controller.disregardAuth();   
		controller.redirectToView(myData.theSA.Id, myData.theSA.Id);
		      
		      


    }
}