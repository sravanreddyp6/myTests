@isTest
private class proj_redirect_test {

    static testMethod void myUnitTest() {

        project__c proj = new project__c();

    // START: NPROJ-20:  Added record type information to test to support change for this ticket.  Just did enough to get the test to pass with the previously-expected record type.
    // J. Gilliam, 10/16/14.
        RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = 'Neuro_Restorative' ];
        proj.RecordType = rt;
        // END: NPROJ-20:  Added record type information to test to support change for this ticket.
        
        
         PageReference pageRef = new PageReference('/apex/proj_redirect');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', rt.Id);
       
        ApexPages.StandardController sc = new ApexPages.standardController(proj);
  
        //Initializing the Controller
        proj_redirect myPageCon = new proj_redirect(sc);
        
        
        
        //proj_redirect sc = new proj_redirect(new ApexPages.Standardcontroller(proj));
        
        myPageCon.gotoProjPage();
        
    }
    
    static testMethod void myUnitTestTraining() {
        Test.Starttest();
        project__c Proj= new project__c();

        RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = 'Training' ];
        Proj.RecordType = rt;
        Proj.name = 'title';
        insert Proj;
        
         PageReference pageRef = new PageReference('/apex/proj_redirect');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', rt.Id);
       
        ApexPages.StandardController sc = new ApexPages.standardController(Proj);
  
        //Initializing the Controller
        proj_redirect myPageCon = new proj_redirect(sc);
        
        
        
        //proj_redirect sc = new proj_redirect(new ApexPages.Standardcontroller(proj));
        
        myPageCon.gotoProjPage();
        test.stoptest();
    }
static testMethod void myUnitTestT3() {
        Test.Starttest();
        project__c Proj= new project__c();

        //RecordType rt = [ SELECT Id FROM RecordType WHERE DeveloperName = 'Training' ];
        //Proj.RecordType = rt;
        //Proj.name = 'title';
        //insert Proj;
        
         PageReference pageRef = new PageReference('/apex/proj_redirect');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('RecordType', Null);
       
        ApexPages.StandardController sc = new ApexPages.standardController(Proj);
  
        //Initializing the Controller
        proj_redirect myPageCon = new proj_redirect(sc);
        
        
        
        //proj_redirect sc = new proj_redirect(new ApexPages.Standardcontroller(proj));
        
        myPageCon.gotoProjPage();
        test.stoptest();
    }


}