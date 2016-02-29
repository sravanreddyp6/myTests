@isTest
private class TMN_DecryptMedicaidIDTest {
    static testMethod void userTestCase() {
    TMN_Generic_Core_TestData myObj = new TMN_Generic_Core_TestData();    
    Progress_Note__c aPn = TMN_Generic_Core_TestData.createProgressNote(myObj.theSa, myObj.theAdm, myObj.theServiceCode, myObj.contactID, DateTime.newInstance(2014,9,1,10,0,0), DateTime.newInstance(2014,9,1,11,0,0));
  
    PageReference pageRef = Page.Notes_ProgressNote_Esign_NC_OPT;
    pageRef.getParameters().put('id',aPn.id); 
    Test.setCurrentPage(pageRef);    
    ApexPages.StandardController sc = new ApexPages.StandardController(aPn);  
    
    TMN_DecryptMedicaidID tm = new TMN_DecryptMedicaidID(sc);  
    tm.CreateEsign();    
        
	TMN_DecryptMedicaidID tmn = new TMN_DecryptMedicaidID(aPn.id);
    tmn.loadData(aPn.id);
    tmn.getNote(); 
    
    }
}