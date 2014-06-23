/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DocumentedActualStaffHrsReportTest {

    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();        
        
        DocumentedActualStaffHrsRpt dashRpt = new DocumentedActualStaffHrsRpt();
        dashRpt.getListStaffHrsInfo();
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
            
        System.assert(staffHrsInfo.compareTo(staffHrsInfo2) != 0);  
        System.assert(staffHrsInfo2.compareTo(staffHrsInfo) != 0);                            
    }
}