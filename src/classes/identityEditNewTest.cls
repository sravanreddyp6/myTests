@isTest
public with sharing class identityEditNewTest {

   private static TMN_User__c TMNUser { get;  set; }
   
   				static testmethod void identityEdit(){
   					List<TMN_User__c> newTmnUser = 	PDMControllerTest.tmnUsers();
			PageReference ref = Page.identity_create;
			test.setCurrentPage(ref);
				ref.getParameters().put('LN', 'TestLast1');
				ref.getParameters().put('TAU', 'adam.vernatter1@thementornetwork.com');
				ref.getParameters().put('FN', 'TestFirst1');
				
   					     String aliasName = 'adam.vernatter1@thementornetwork.com';
   						TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
   						Attachment attach = new Attachment();
		attach.ParentId = newTmnUser[0].id;
		attach.Name ='Test String';
		attach.body = blob.ValueOf('test data');
		insert attach;
   					ref.getParameters().put('ID', newTmnUser[0].id);
   					User testUser = [SELECT Id FROM User WHERE Id =:newTmnUser[0].Salesforce_User_Account__c];
   				Alias__c alias =	PDMControllerTest.getNewAlias('111111'); 
				system.runas(testUser){
   					
   						ApexPages.StandardController sc = new ApexPages.StandardController( newTMNUser[0]);
   						identityEditNew identity = new identityEditNew(sc);
   								//identity.id = newTmnUser[0].id;
   							identity.attchmentId = attach.id;
   						identity.aliasUser = newTmnUser[0];
   						identity.auAlias = alias;
   						identity.aliasName = aliasName;
   						identity.myManager = '';
   						identity.myOpGroup= '';
				}		
   				}
   				
   					static testmethod void identityNew(){
   						   					List<TMN_User__c> newTmnUser = 	PDMControllerTest.tmnUsers();
   							TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
   						Attachment attach = new Attachment();
		attach.ParentId = newTmnUser[0].id;
		attach.Name ='Test String';
		attach.body = blob.ValueOf('test data');
		insert attach;
		

			PageReference ref = Page.identity_create;
			test.setCurrentPage(ref);
				ref.getParameters().put('LN', 'TestLast1');
				ref.getParameters().put('TAU', 'adam.vernatter1@thementornetwork.com');
				ref.getParameters().put('FN', 'TestFirst1');
				ref.getParameters().put('retURL', '/apex/identity_nonemployees');
   					     String aliasName = 'adam.vernatter1@thementornetwork.com';
   					User testUser = [SELECT Id FROM User WHERE Id =:newTmnUser[0].Salesforce_User_Account__c];
   				Alias__c alias =	PDMControllerTest.getNewAlias('222222'); 
				system.runas(testUser){

   					
   						ApexPages.StandardController sc = new ApexPages.StandardController( newTMNUser[0]);
   						identityEditNew identity = new identityEditNew(sc);
   						identity.attDeatils = attach;
   						identity.attchmentId = attach.id;
   								//identity.id = newTmnUser[0].id;
   						identity.retURL = '/apex/identity_nonemployees';
   						identity.aliasUser = newTmnUser[0];
   						identity.auAlias = alias;
   						identity.aliasName = aliasName;
   						alias =	PDMControllerTest.getNewAlias('333333');
   						identity.TMNUser.Alias__c = alias.Alias_unique__c;
   						identity.updateAliasInfo();
   						identity.save();
   						identityEditNew.setJobStatus(newTmnUser);
   						identity.goEdit();
   						identity.goCancel();
   						identity.goBack();
   						identity.closePopup();
   						identity.displayPopup =true;
   						identity.showPopup();
   						//new  identity.ProxyAttachment(attach);
   						//identity.attachmentDeatils();
   						//identity.deleteattachment();
   						//identity.updateAttachment();
				}		
   				}
   				

}