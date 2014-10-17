@isTest
private class ProgressNoteExtension_TEST {

    static testMethod void myUnitTest() {
    	TMN_Generic_Core_TestData myObj = new TMN_Generic_Core_TestData();
    	Progress_Note__c aPn = TMN_Generic_Core_TestData.createProgressNote(myObj.theSa, myObj.theAdm, myObj.theServiceCode, myObj.contactID, DateTime.newInstance(2014,9,1,10,0,0), DateTime.newInstance(2014,9,1,11,0,0));
    	
    	aPn.Topic_Behavior_Management__c = true;
    	aPn.Topic_Other__c = true;
    	aPn.Topic_If_Other__c = 'TEST';
    	
    	update aPn;
    	
    	PageReference pageRef = Page.Notes_ProgressNote_PDF_NC_TFC;
	    Test.setCurrentPage(pageRef);
	    
	    ApexPages.StandardController stdPnCtrl = new ApexPages.StandardController(aPn);
	    ProgressNoteExtension controller = new ProgressNoteExtension(stdPnCtrl);
	    
	    System.assert(controller.pnStartTime=='10:00 AM');
	    System.assert(controller.pnEndTime=='11:00 AM');
	    
	    String concatenatedTopics;
	    for(String t : controller.topicsDiscussed) {
	    	System.debug('t: ' + t);
	    	concatenatedTopics += t;
	    }
	    
	    System.debug(concatenatedTopics);
	    
	    System.assert(concatenatedTopics.contains('Behavior Management'));
	    System.assert(concatenatedTopics.contains('Other (TEST)'));

    }
}