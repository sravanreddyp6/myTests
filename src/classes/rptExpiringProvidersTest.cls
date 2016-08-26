@isTest
private class rptExpiringProvidersTest {
    private static rptExpiringProviders ctrl = new rptExpiringProviders();
    
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
        
        ctrl.fromDate = Date.today();
        ctrl.toDate = Date.today().addDays(-1);
        ctrl.runRpt();
    }
    static testMethod void approvedProvDates() {
    	List<SelectOption> types = ctrl.getTypeList();
    	system.assertEquals(0, types.size());
    	
    	List<SelectOption> seltypes = ctrl.selectTypeList;
    	system.assertEquals(4, seltypes.size());
    	
    	ctrl.UpdateTypeSelections();
    	
    	String[] provDates = ctrl.selected2Types;
		system.assertEquals(4, provDates.size());
		system.assertEquals(new String[] {'Car Insurance Expiration Date', 'CHC Expiration Date', 'Driver\'s License Expiration Date', 'PEAA/PEI Expiration Date'}, 
				provDates);
        
        ctrl.RemoveTypes();
        
        if ( ctrl.selectedTypes == null )
            ctrl.selectedTypes = new List<String>();
        ctrl.selectedTypes.add( ctrl.provtypelist[0].getValue());
        ctrl.selectedTypes.add( ctrl.provtypelist[1].getValue());
        ctrl.selectedTypes.add( ctrl.provtypelist[2].getValue());
        ctrl.selectedTypes.add( ctrl.provtypelist[3].getValue());
        ctrl.AddTypes();
        
        //All Tmn Providers without Date Range
		ctrl.allCheck = true;
        ctrl.runRpt();
        
        //All Tmn Providers with Date Range
        ctrl.allCheck = false;
        ctrl.fromDate= Date.today();
        ctrl.toDate = Date.today();
        ctrl.runRpt();
    }
    

}