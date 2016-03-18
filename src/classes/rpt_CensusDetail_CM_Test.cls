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
private class rpt_CensusDetail_CM_Test {

    static testMethod void myUnitTest() {
        Alias__c b = new Alias__c();
        b.Name = '99999';
        b.Alias_unique__c = '99999';
        b.Alias_State__c = 'MA';
        b.Alias_Parent__c = 'test';
        b.Alias_Region__c = 'test';
        b.Alias_Service_Line__c = 'test';
        b.Alias_Operating_Group__c ='Care Meridian';
        
        insert b;
        
        Service_location__c s = new Service_Location__c();
        s.Alias_lookup__c = b.iD;
        s.Alias__c = '99999';
        s.Name = '99999';
        s.ProgramId__c = 'test';
        s.FacilityId__c = 999;
        s.Program__c = 'test Program';
        s.Service_value__c = 'test';
        s.source_System__c = 'AVATAR';
        s.UniqueID__c = '999||test Program';
        s.Physical_location__c = 'test';
        s.City__c = 'test';
        s.Status__c = 'Active';
        
        insert s; 
        rpt_CensusDetail_CM control = new rpt_CensusDetail_CM ();
        control.runRpt();
        control.signOff();
        
        boolean nothing = control.getHasResults();
        nothing = control.getShowParms ();
        string str = control.getHost();
        
    }
}