@isTest
private class rptCurrentPersonalAgentAssignmentsTest {
    
    private static rptCurrentPersonalAgentAssignments ctrl = new rptCurrentPersonalAgentAssignments();
    
    @testSetup
    static void setUp() {
        Service_Location__c servLoc = new Service_Location__c();
        servLoc.Alias__c = '029435';
        servLoc.FacilityId__c = 13.0;
        servLoc.UniqueID__c = '1234';
        servLoc.Program__c = 'Test Program 1';
        servLoc.Name = 'Service Location 1';
        servLoc.ProgramId__c = '029435000';
        servLoc.Location_Nickname__c = 'Loc 1';
        servLoc.State__c = 'OR';
        servLoc.Service_Type__c = 'CM - Case Management';
        insert servLoc;
        
        servLoc = new Service_Location__c();
        servLoc.Alias__c = '564423';
        servLoc.FacilityId__c = 13.0;
        servLoc.UniqueID__c = '5678';
        servLoc.Program__c = 'Test Program 2';
        servLoc.Name = 'Service Location 2';
        servLoc.ProgramId__c = '564423000';
        servLoc.Location_Nickname__c = 'Loc 2';
        servLoc.State__c = 'OR';
        servLoc.Service_Type__c = 'CM - Case Management';
        insert servLoc;
        
        servLoc = new Service_Location__c();
        servLoc.Alias__c = '789546';
        servLoc.FacilityId__c = 13.0;
        servLoc.UniqueID__c = '9012';
        servLoc.Program__c = 'Test Program 3';
        servLoc.Name = 'Service Location 3';
        servLoc.ProgramId__c = '789546000';
        servLoc.Location_Nickname__c = 'Loc 3';
        servLoc.State__c = 'OR';
        servLoc.Service_Type__c = 'CM - Case Management';
        insert servLoc;
    }
    static testMethod void BrokerageTest() {
        List<SelectOption> br = ctrl.getSelectedBroList();
        system.assertEquals(0, br.size());
        
        List<SelectOption> br2 = ctrl.getBrokerageList();
        system.assertEquals(3, br2.size());
        ctrl.runRpt();
        
        Service_Location__c[] locIds = [
            SELECT Id
            FROM Service_Location__c
            WHERE State__c = 'OR'
            AND Service_Type__c = 'CM - Case Management'
            ORDER BY ProgramId__c
        ];
        
        if ( ctrl.selectedBrokerage == null )
            ctrl.selectedBrokerage = new List<Id>();
        ctrl.selectedBrokerage.add( ctrl.brokerageList[0].getValue());
        ctrl.selectedBrokerage.add( ctrl.brokerageList[1].getValue());
        ctrl.selectedBrokerage.add( ctrl.brokerageList[2].getValue());
        ctrl.RemoveBrokerage();
        ctrl.runRpt();
        
        if ( ctrl.select2Brokerage == null )
            ctrl.select2Brokerage = new List<Id>();
        ctrl.select2Brokerage.add( ctrl.selectedBroList[0].getValue());
        ctrl.AddBrokerage();
        ctrl.Reset();
    }
    static testMethod void personalAgentTest() {
        TestUtils.CoreDataGenerator generator = new TestUtils.CoreDataGenerator();
        generator.aliasBuilder.setState('OR');
        generator.serviceLocationBuilder.setState('OR');
        generator.serviceLocationBuilder
            .setServiceType('CM - Case Management')
            .setProgramId('111111000')
            .setLocationNickname('Brokerage 1');
        TestUtils.CoreData coreData = generator.persistData();
        
        insert generator.serviceAssignmentBuilder.getInstance();
        
        TestUtils.UserBuilder userBuilder = new TestUtils.UserBuilder();
        User[] users = new User[]{
            userBuilder.setFirstName('No1').setLastName('User').setUserAlias('no1u').setEmail('no1@test.com').getInstance(),
                userBuilder.setFirstName('No2').setLastName('User').setUserAlias('no2u').setEmail('no2@test.com').getInstance()
                };
                    insert users;
        
        Alias__c alias = [SELECT Id, Name FROM Alias__c];
        TestUtils.TmnUserBuilder tmnUserBuilder = new TestUtils.TmnUserBuilder();
        Tmn_User__c[] personalAgents = new Tmn_User__c[]{
            tmnUserBuilder.setUserId(users[0].Id).setAlias(alias).getInstance(),
                tmnUserBuilder.setUserId(users[1].Id).setAlias(alias).getInstance()
                };
                    insert personalAgents;
        
        test.startTest();
        Service_Location__c[] locIds = [
            SELECT Id,Alias_lookup__c
            FROM Service_Location__c
            WHERE State__c = 'OR'
            AND Service_Type__c = 'CM - Case Management'
            ORDER BY ProgramId__c
        ];
        
        personalAgents[0].Job_Title__c = 'Case Manager';
        personalAgents[0].Alias_lookup__c = locIds[0].Alias_lookup__c;
        update personalAgents[0];        
        
        Service_Assignment__c[] serviceAssignments = [
            SELECT Id FROM Service_Assignment__c
        ];
        
        serviceAssignments[0].service_location__c = locIds[0].id;
        update serviceAssignments[0];
        
        Service_Assignment_Personal_Agent__c[] paAssociations = new Service_Assignment_Personal_Agent__c[] {
            new Service_Assignment_Personal_Agent__c(
                Service_Assignment__c = serviceAssignments[0].Id,
                Personal_Agent__c = personalAgents[0].Id,
                Status__c = 'Active'
            ),
                new Service_Assignment_Personal_Agent__c(
                    Service_Assignment__c = serviceAssignments[0].Id,
                    Personal_Agent__c = personalAgents[1].Id,
                    Status__c = 'Active'
                ),
                new Service_Assignment_Personal_Agent__c(
                    Service_Assignment__c = serviceAssignments[1].Id,
                    Personal_Agent__c = personalAgents[0].Id,
                    Status__c = 'Active'
                )
                };
                    insert paAssociations;        
        
        List<SelectOption> pa = ctrl.getSelectedPAList();
        system.assertEquals(0, pa.size());
        
        ctrl.UpdatePersonalAgents();
        List<SelectOption> pa2 = ctrl.getPAgentList();
        system.assertEquals(1, pa2.size());
        
        if ( ctrl.selectedPA == null )
            ctrl.selectedPA = new List<Id>();
        ctrl.selectedPA.add( ctrl.pAgentList[0].getValue());
        ctrl.RemovePAgent();
        
        if ( ctrl.select3PA == null )
            ctrl.select3PA = new List<Id>();
        ctrl.select3PA.add( ctrl.selectedPAList[0].getValue());
        ctrl.AddPAgent();
        
        ctrl.runRpt();
        ctrl.toDate = Date.today();
        ctrl.fromDate = null;
        ctrl.allCheck = true;
        ctrl.runRpt();
        
        list<rptCurrentPersonalAgentAssignments.rptRow> rptRows = ctrl.rptData;
        system.assertEquals(1, rptRows.size());
        System.assertEquals(0, ctrl.rptData[0].compareTo(ctrl.rptData[0]));
        
        //Testing with Case Management ISP End Date Range
        List<RecordType> rt = [ select id from Recordtype where sobjecttype = 'Case_Management_Plan__c' and developername = 'OR_Combined_ISP' ];
        system.assertEquals(1, rt.size());
        Case_Management_Plan__c testIsp;
        testIsp = new Case_Management_Plan__c( recordtypeid = rt[0].Id);
        testIsp.Name = 'Test plan 1';
        testIsp.Service_Assignment__c = serviceAssignments[0].id;
        testIsp.Status__c = 'Active Final';
        testIsp.PD_End__c = Date.today();
        insert testIsp;
        
        ctrl.toDate = Date.today();
        ctrl.fromDate = Date.today();
        ctrl.runRpt();
        System.assertEquals(0, ctrl.rptData[0].compareTo(ctrl.rptData[0]));
        test.stopTest();
    } 
    
}