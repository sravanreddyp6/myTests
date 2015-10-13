@isTest
public with sharing class IdentityHomeControllerTest {
	
	
	
				
				static testmethod void IdentityHomeController(){
				List<TMN_User__c> newTmnUser = 	PDMControllerTest.tmnUsers();
	   					User testUser = [SELECT Id FROM User WHERE Id =:newTmnUser[0].Salesforce_User_Account__c];
   				Alias__c alias =	PDMControllerTest.getNewAlias('111111'); 
				system.runas(testUser){
				String tmnEmail = 'shaun.wood@thementornetwork.com';
				
				IdentityHomeController IdentityHome = new IdentityHomeController();
				
				IdentityHome.stdEditPage();
				List<TMN_User__c> myEmployees = IdentityHome.getMyEmployees();
				List<TMN_User__c> myWorkforce = IdentityHome.getmyWorkforce();
				    List<TMN_User__c> searchResult = IdentityHome.searchResult ;
    				List<TMN_User__c> searchDelegateResult = IdentityHome.searchDelegateResult ;
   					List<TMN_User__c> searchNonEmpResult = IdentityHome.searchNonEmpResult ;
   					List<TMN_User__c>tmnUserList = IdentityHome.tmnUserList ;
					TMN_User__c theTMNUser= IdentityHome.theTMNUser;
				    Boolean displayPopup = IdentityHome.displayPopup;
				List<SelectOption> DelValues= IdentityHome.getDelValues();
				
				String TmnAliasUsr= IdentityHome.getTmnAliasUsr();
				
				Boolean IsDelegate = IdentityHome.getIsDelegate();
				
				 Boolean HasAccess = IdentityHome.getHasAccess();
				 
				 Boolean NoAccess= IdentityHome.getNoAccess();
				 Boolean HasSubs = IdentityHome.getHasSubs();
				 
				 Boolean btnDisable = IdentityHome.getbtnDisable();
				 IdentityHome.selectedId =  newTmnUser[2].id;
				 IdentityHome.addDel();
				 List<Attachment> attachments = IdentityHome.attachments;
				   String tmnSearchStr = IdentityHome.tmnSearchStr;
				IdentityHome.generatedKey1 = newTmnUser[2].Last_Name__c;
       			IdentityHome.generatedKey2 = newTmnUser[2].First_Name__c;
       			IdentityHome.srchLNameDel = newTmnUser[2].Last_Name__c;
       			IdentityHome.srchFNameDel = newTmnUser[2].First_Name__c;
       			IdentityHome.srchLNameNonEmp = newTmnUser[2].Last_Name__c;
       			IdentityHome.srchFNameNonEmp = newTmnUser[2].First_Name__c;
       			
       			
				 //IdentityHome.removeDel();
				 IdentityHome.doQueryDel();
				 IdentityHome.delSearch();
				 IdentityHome.doQuery();
				 //IdentityHome.clearDelSrch();
				 
				 
				 IdentityHome.nonEmpSearch();
				 
				 IdentityHome.doQuery();
				 
				 //IdentityHome.tmnSearch();
				 
				 IdentityHome.newTmnUser();
				 
				IdentityHome.closePopup();
				IdentityHome.showPopup();
				IdentityHome.displayInfo=false;
				IdentityHome.showInfo();
				
				IdentityHome.closeInfo();
				
				IdentityHome.FirstPageNE();
				
				IdentityHome.previousNE();
				IdentityHome.nextNE();
				IdentityHome.LastPageNE();
				IdentityHome.FirstPageDel();
				//IdentityHome.previousDel();
				//IdentityHome.nextDel();
				//IdentityHome.LastPageDel();
				//IdentityHome.getprevDel();
				//IdentityHome.getnxtDel();
				
				IdentityHome.getprevNE();
				
				IdentityHome.getnxtNE();
				IdentityHome.viewTmnUser();
				}
			}
}