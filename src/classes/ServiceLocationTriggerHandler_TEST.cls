@isTest
private class ServiceLocationTriggerHandler_TEST {

    static testMethod void testTriggerInsert() {
        
        // set up the service code first
        Service_code__c sc = new Service_Code__c ( Program_Code__c = '1001', program_value__c = 'DEF', start_date__c = Date.newInstance(2014, 01,01), service_code__c = 'ABC');
        insert sc;
        sc = [ select id, program_rollup__c, program_value__c from service_code__c where id = :sc.ID limit 1];
        
        String rollupbefore = sc.Program_rollup__c;
        String detailbefore = sc.program_value__c;

        Service_Location__c sl = new Service_Location__c( alias__c = '100', programid__c = '1001', program__c = 'ABC',  program_rollup__c = '1000', facilityid__c = 1, uniqueid__c = '1111');
        insert sl;
        sl = [ select id, programid__c, program_rollup__c, program__c from service_location__c where id = :sl.ID LIMIT 1];
        sc = [ select id, program_rollup__c, program_value__c from service_code__c where id = :sc.ID limit 1];
        
        String rollupafter = sc.Program_rollup__c;
        String detailafter = sc.program_value__c;
        
        System.Assert( rollupbefore != rollupafter );
        System.Assert( detailbefore != detailafter );

        system.debug( 'Rollup BEFORE:' + rollupbefore + ', AFTER:' + rollupafter);
        system.debug( 'Rollup BEFORE:' + rollupbefore + ', AFTER:' + rollupafter);
        system.AssertEquals( rollupafter, sl.program_rollup__c);
        system.AssertEquals( detailafter, sl.program__c);
        
    }
    
    
    
    static testMethod void testTriggerUpdate() {
    	
    	Service_Location__c sl = new Service_Location__c( alias__c = '100', programid__c = '1001', program__c = 'ABC', program_rollup__c = '1000', facilityid__c = 1, uniqueid__c = '1111');
    	insert sl;
        sl = [ select id, programid__c, program_rollup__c from service_location__c where id = :sl.ID LIMIT 1];
        
        Service_code__c sc = new Service_Code__c ( Program_Code__c = '1001', start_date__c = Date.newInstance(2014, 01,01), service_code__c = 'ABC', program_rollup__c = '1000');
        insert sc;
        sc = [ select id, program_rollup__c from service_code__c where id = :sc.ID limit 1];
        
        String rollupbefore = sc.Program_rollup__c;
        sl.program_rollup__c = '2000';
        update sl;
        
        sc = [ select id, program_rollup__c from service_code__c where id = :sc.ID limit 1];
        String rollupafter = sc.Program_rollup__c;
        
        System.Assert( rollupbefore != rollupafter );
        system.AssertEquals( rollupafter, sl.program_rollup__c);
        
    }
}