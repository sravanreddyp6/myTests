/**
 */
@isTest
private class rpt_AuthUtilizationNR_Test {
    @testSetup static void testData() {
        User testUser = TMN_Generic_Core_TestData.createUser('ESD General','tUser', 'tUser@tmn.com' + System.currentTimeMillis(), 'Therapy', 'Test', 'NeuroRestorative');
        system.debug('calling permsetassign from simpletests');
        System.runas(new User(Id = UserInfo.getUserId())){
            permsetAssign(new list<String>{'ESD_Notes_Common','ESD_Notes_Case_Handler_NR_Carbondale','ESD_Notes_Intaker','  ESD_Referrals_Common','ESD_Referrals_Intaker'}, testUser.id);
        }
    }
    static testMethod void myUnitTest() {
    User u = [Select id from User where FirstName = 'Therapy' Limit 1];
        system.runas( u ) {
        RecordType rt = [Select Id,name From RecordType where sobjecttype = 'progress_note__c' and name =: 'Therapy'];
        TMN_Generic_Core_TestData coredata = new TMN_Generic_Core_TestData();
        coredata.loadData( 'IL');
        ID newSLid1 = createServiceLocation( '123456', '123456001', 'New Service Location 1', 1, 'IL', '1-123456' );
        ID newSLid1a = createServiceLocation( '114165', '114165002', 'New Service Location 1a', 1, 'IL', '1-123456a' );
        coredata.theSA.service_location__c = newSLid1;
        test.startTest();
        update coredata.theSA;
        Progress_Note__c p = new Progress_Note__c(recordtypeid = rt.id,Purpose_Service_is_Billable__c=false,start_time__c = system.now().addhours(-1),end_time__c=system.now(),approval_user__c = u.id, Number_of_Required_Signatures__c=2, Service_Assignment__c =coredata.theSA.ID,Person_Being_Served__c=coredata.contactID);
        insert p;
        
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        List<Authorization__c> auths = new List<Authorization__c>();
        PageReference pageRef = Page.rpt_AuthUtilizationNR;
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
        rpt_AuthUtilizationNR controller = new rpt_AuthUtilizationNR ();
        controller.StartDate = date.today().adddays(-1);
        controller.enddate = date.today();
        pagereference pr =  controller.runRpt(); 
        
        rpt_AuthUtilizationNR controller1 = new rpt_AuthUtilizationNR ();
        controller1.StartDate = date.today().adddays(+1);
        controller1.enddate = date.today();
        pagereference pr1 =  controller1.runRpt(); 
        
        rpt_AuthUtilizationNR controller2 = new rpt_AuthUtilizationNR ();
        controller2.StartDate = date.today().adddays(+1);
        controller2.enddate = null;
        pagereference pr2 =  controller2.runRpt(); 
        
        test.stopTest();
        //controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));    
    }}
     static ID createServiceLocation( string alias, string pgmCode, string pgmVal, integer facility, string slState, string uid ) {
        Service_location__c newSL = new Service_location__c( alias__c = alias, programid__c = pgmCode, program__c = pgmVal, facilityid__c = facility, state__c = slState, uniqueid__c = uid);
        insert newSL;
        return newSL.Id;
       }
       
    static void permsetAssign(string[]permSets, Id assigntoId){
        system.debug('calling permsetassign');
        List<PermissionSet> theSets = [SELECT ID, Name FROM PermissionSet WHERE Name IN :permSets];
        List<PermissionSetAssignment> thepermAssigns = new List<PermissionSetAssignment>();
        for(PermissionSet ps : theSets){
            thepermAssigns.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = assigntoId));
        }
        insert thepermAssigns;
    }
    
}