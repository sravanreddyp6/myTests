@isTest
private class Progress_Notes_List_View_ControllerTest{
    static testMethod void unitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        mydata.loadData('AZ');
        list<Progress_Note__c> pnlist= new list<Progress_Note__c>(); 
        for(integer i=0; i<100;i++){
            Progress_Note__c thePN = new Progress_Note__c(
                Admission__c = myData.theAdm.id,
                Person_Being_Served__c = mydata.contactID,
                Service_Assignment__c = mydata.theSA.Id,
                Start_Time__c = DateTime.parse('10/14/2014 11:46 AM'),
                End_Time__c= DateTime.parse('10/14/2014 11:55 AM'),
                Number_of_Required_Signatures__c=1);
            pnlist.add(thePN);
        }
        insert pnlist;
        ApexPages.currentPage().getParameters().put('saID', mydata.theSA.Id);
        ApexPages.currentPage().getParameters().put('saname', 'TestName');
        Progress_Notes_List_View_Controller pn = new Progress_Notes_List_View_Controller();
        ApexPages.StandardSetController stdcntrl= pn.ProgressNoteController;
        pn.firstPage();
        pn.lastPage();
        pn.editcardnotes();
        pn.getProgressNotes();
        pn.getPageNumber();
        pn.prev();
        pn.next();
        pn.getTotalPages();
        pn.getTotalSize();
        pn.getprogsize();
    }
    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        mydata.loadData('AZ');
        Progress_Note__c thePN = new Progress_Note__c(
            Admission__c = myData.theAdm.id,
            Person_Being_Served__c = mydata.contactID,
            Service_Assignment__c = mydata.theSA.Id,
            Start_Time__c = DateTime.parse('10/14/2014 11:46 AM'),
            End_Time__c= DateTime.parse('10/14/2014 11:55 AM'),
            Number_of_Required_Signatures__c=1);
        insert thePN;
        ApexPages.currentPage().getParameters().put('PBSID', mydata.contactID);
        ApexPages.currentPage().getParameters().put('pbsname', 'TestName');
        Progress_Notes_List_View_Controller pn = new Progress_Notes_List_View_Controller();
        ApexPages.StandardSetController stdcntrl= pn.ProgressNoteController;  
        pn.firstPage();
        pn.getTotalPages();
    }
    static testMethod void pnlogTest() {
        ApexPages.currentPage().getParameters().put('PBSID', '000000000000000000');
        ApexPages.currentPage().getParameters().put('saID', '000000000000000000');
        Progress_Notes_List_View_Controller pn = new Progress_Notes_List_View_Controller();
        ApexPages.StandardSetController stdcntrl= pn.ProgressNoteController;
        pn.firstPage();
        pn.getPageNumber();
        pn.getprogsize();
    }
    static testMethod void pnotesTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        mydata.loadData('AZ');
        Progress_Note__c p = new Progress_Note__c();
        ApexPages.currentPage().getParameters().put('PBSID', mydata.contactID);
        ApexPages.currentPage().getParameters().put('pbsname', 'TestName');
        Progress_Notes_List_View_Controller pn = new Progress_Notes_List_View_Controller();
        ApexPages.StandardSetController stdcntrl = pn.ProgressNoteController;
        pn.actualsize=0;
        pn.getPageNumber();
        pn.getProgSize();
        pn.lastPage();
        
    }
    static testMethod void testLog() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        mydata.loadData('AZ');
        Progress_Note__c p = new Progress_Note__c();
        ApexPages.currentPage().getParameters().put('saID', mydata.theSA.Id);
        ApexPages.currentPage().getParameters().put('saname', 'TestName');
        Progress_Notes_List_View_Controller pn = new Progress_Notes_List_View_Controller();
        ApexPages.StandardSetController stdcntr = pn.ProgressNoteController;
        pn.actualsize=0;
        
    }
    
}