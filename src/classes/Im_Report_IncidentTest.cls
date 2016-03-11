@isTest
private class Im_Report_IncidentTest {
    private static TMN_Generic_Core_TestData myData;
    
    static testMethod void myUnitTest() {
        User redwoodUser = TMN_Generic_Core_TestData.createUser('ESD General', 'joeSmith', 'joeSmith@tmn.com.joeSmith', 'joe', 'smith', 'Redwood');
        TMN_User__c redwoodtmnUser = [SELECT ID, Name FROM TMN_User__c WHERE Salesforce_User_Account__c =: redwoodUser.id];
        
        system.runas(redwoodUser){
            createData();
            myData.loadData('IA');
			Im_Incident__c incident = new Im_Incident__c(Reported_By__c = UserInfo.getUserId(), Status__c='Event-Draft', Date_Documented__c= system.now());
			incident.Service_Location__c = myData.theSA.Service_Location__c;
			incident.Supervisor__c = redwoodtmnUser.id;
			
			insert incident;
			
			Im_InvolvedParty__c invPrty = new Im_InvolvedParty__c(Im_Incident__c = incident.id, type__c = 'Other', Name = 'Test Inv Party');
			insert invPrty;        	
        }
			
			
			
    }
    
    private static void createData(){
        myData = new TMN_Generic_Core_TestData();
    }
}