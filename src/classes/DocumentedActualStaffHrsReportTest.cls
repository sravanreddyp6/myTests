@isTest
private class DocumentedActualStaffHrsReportTest {

	static ID createServiceLocation( string alias, string pgmCode, string pgmVal, integer facility, string slState, string uid ) {
		
		Service_location__c newSL = new Service_location__c( alias__c = alias, programid__c = pgmCode, program__c = pgmVal, facilityid__c = facility, state__c = slState, uniqueid__c = uid);
		insert newSL;
		
		return newSL.Id;
		
	}
	
	static testMethod void testStateProgList() {
		
		ID newSLid1a = createServiceLocation( '123456', '123456001', 'New Service Location 1a', 1, 'AZ', '1-123456a' );
		ID newSLid1b = createServiceLocation( '123456', '123456002', 'New Service Location 1b', 1, 'AZ', '1-123456b' );
		ID newSLid2 = createServiceLocation( '223456', '223456001', 'New Service Location 2', 1, 'CA', '223456a' );
		
		DocumentedActualStaffHrsRpt dashRpt = new DocumentedActualStaffHrsRpt();
        
        List<SelectOption> states = dashRpt.states;
        System.AssertEquals(2, states.size());
		
		List<SelectOption> progs = dashRpt.programs;
		System.AssertEquals(3, progs.size());	
	
	
	}
	
	static testMethod void testStartEndDateVal() {
		
        DocumentedActualStaffHrsRpt dashRpt = new DocumentedActualStaffHrsRpt();
        dashRpt.fStartDate = Date.newInstance(2014, 4, 1);
        dashRpt.fEndDate = Date.newInstance(2013, 6, 1);
        
        PageReference rpt = dashRpt.runReport();
        System.AssertEquals( rpt, null);         
		
	}
    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();                        
        
        DocumentedActualStaffHrsRpt dashRpt = new DocumentedActualStaffHrsRpt();
        dashRpt.getListStaffHrsInfo();
        dashRpt.fStartDate = Date.newInstance(2013, 1, 1);
        dashRpt.fEndDate = Date.newInstance(2014, 6, 1);
        dashRpt.selStates = new List<string>{'AZ'};
        
        ID slId = createServiceLocation( '123456', '123456001', 'New Service Location 1a', 1, 'AZ', '1-123456a' );
        
        Service_code__c theServiceCode = new Service_Code__c(
            Service_Code__c = 'H2022',
            FacilityID__c = '1',
            Program_Code__c = '123456001',
            Program_Value__c = 'New Service Location 1a',
            Start_Date__c = date.newInstance(2000, 1, 1),
            state__c = 'AZ'
        );
        insert theServiceCode;
        theServiceCode= [select service_code__c, facilityid__c, program_code__c, program_value__c, start_date__c, state__c from service_code__c where id = :theServiceCode.Id LIMIT 1];

        myData.theSA.program_detail__c = 'New Service Location 1a';
        update myData.theSA;
        
        dashRpt.selPrograms = new List<string>{'New Service Location 1a'};
        
        // create a progress note
        Progress_note__c myPN = TMN_Generic_Core_TestData.createProgressNote(myData.theSA, myData.theAdm, theServiceCode, myData.theSA.Person_being_served__c);
       
        dashRpt.runReport();         
        
        DocumentedActualStaffHrsRpt.StaffHrsInfo staffHrsInfo =
        new DocumentedActualStaffHrsRpt.staffHrsInfo();
        System.assertEquals(null, staffHrsInfo.clinician);
        System.assertEquals(null, staffHrsInfo.pbs);
        System.assertEquals(null, staffHrsInfo.phase);
        System.assertEquals(null, staffHrsInfo.totalMinutes); 
        System.assertEquals(null, staffHrsInfo.hours);         
        
        DocumentedActualStaffHrsRpt.StaffHrsInfo staffHrsInfo2 =
            new DocumentedActualStaffHrsRpt.staffHrsInfo();
            
        staffHrsInfo2.clinician = 'Jack Jones';
        staffHrsInfo2.pbs = myData.theSA.Person_Being_Served__c;
        staffHrsInfo2.phase = String.valueOf(myData.theSA.Phase__c);
        staffHrsInfo2.totalMinutes = '120'; 
        staffHrsInfo2.hours = '2';    
        
        DocumentedActualStaffHrsRpt.StaffHrsInfo staffHrsInfo3 =
            new DocumentedActualStaffHrsRpt.staffHrsInfo();
            
        staffHrsInfo3.clinician = 'Jack Jones';
        staffHrsInfo3.pbs = myData.theSA.Person_Being_Served__c;
        staffHrsInfo3.phase = String.valueOf(myData.theSA.Phase__c);
        staffHrsInfo3.totalMinutes = '120'; 
        staffHrsInfo3.hours = '2';    
        
            
        System.assert(staffHrsInfo.compareTo(staffHrsInfo2) != 0);  
        System.assert(staffHrsInfo2.compareTo(staffHrsInfo) != 0);
        System.assert(staffHrsInfo3.compareTo(staffHrsInfo2) == 0);
                                    
    }
}