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
private class DataCreateTest {

    static testMethod void CreateAccount() {
        DataCreate c = new DataCreate();
        
        map<string, object> fieldmap = new map<string, object>();
        fieldmap.put('lastname', 'Mouse');
        fieldmap.put('personbirthdate', date.newinstance(1954,5,7));
        Account pbs = (Account)c.CreateObject('Account', fieldmap);
        
        System.assertequals('Mouse', pbs.lastname);
        
        Account mickey = [select lastname, firstname, personbirthdate from Account];
        System.assertequals('Mouse', mickey.lastname);
        system.assertequals(date.newinstance(1954,5,7), mickey.personbirthdate);
        
    }

    static testMethod void CreateAdmission() {
        DataCreate c = new DataCreate();
        
        map<string, object> fieldmap = new map<string, object>();
        fieldmap.put('lastname', 'Mouse');
        fieldmap.put('personbirthdate', date.newinstance(1954,5,7));
        Contact pbs = (Contact)c.CreateObject('Contact', fieldmap, 'mickey');
        
        map<string, object> fieldmap1 = new map<string, object>();
        fieldmap1.put('state', 'CA');
        fieldmap1.put('person_being_served__c', 'mickey');
        Admission__c adm = (Admission__c)c.CreateObject('Admission__c', fieldmap1);
        System.assertequals(pbs.id, adm.person_being_served__c);
        
    }

    static testMethod void CreateServiceAssignment() {
        DataCreate c = new DataCreate();
        
        map<string, object> fieldmap = new map<string, object>();
        fieldmap.put('lastname', 'Mouse');
        fieldmap.put('personbirthdate', date.newinstance(1954,5,7));
        Contact pbs = (Contact)c.CreateObject('Contact', fieldmap, 'mickey');
        
        map<string, object> fieldmap1 = new map<string, object>();
        fieldmap1.put('state', 'CA');
        fieldmap1.put('person_being_served__c', 'mickey');
        Admission__c adm = (Admission__c)c.CreateObject('Admission__c', fieldmap1, 'today');
        
        map<string, object> fieldmap2 = new map<string, object>();
        fieldmap2.put('Admission__c', 'today');
        fieldmap2.put('person_being_served__c', 'mickey');
        fieldmap2.put('referral__c', 'ref');
        Service_Assignment__c sa = (Service_Assignment__c)c.CreateObject('Service_Assignment__c', fieldmap2);

        map<string, object> fieldmap3 = new map<string, object>();
        fieldmap3.put('Admission__c', 'today');
        fieldmap3.put('person_being_served__c', 'mickey');
        Referral__c ref = (Referral__c)c.CreateObject('Referral__c', fieldmap3, 'ref');
        System.assertequals(0, c.FixReferences());
        System.assertequals(ref.id, sa.referral__c);
        
        Service_Assignment__c dbsa = [select referral__c from Service_Assignment__c where id = :sa.id];
        system.assertequals(ref.id, dbsa.referral__c);
    }
    
    static testmethod void PseudonymsTest(){
        DataCreate c = new DataCreate();
        
        Contact a1 = new Contact();
        Contact a2 = new Contact();
        
        c.PutPseudonym('a1', a1);
        system.assertequals(1, c.GetPseudonyms().size());
        system.assertequals(a1, c.GetPseudonym('a1'));

        c.PutPseudonym('a2', a1);
        system.assertequals(2, c.GetPseudonyms().size());
        system.assertequals(a2, c.GetPseudonym('a2'));
        
        system.assert(c.GetPseudonyms().contains('a1'));
        system.assert(c.GetPseudonyms().contains('a2'));
    }
    
    static testmethod void RequirementsTest(){
        map<string, list<string>> req = DataCreate.Requirements('Action_Plan_Objective__c');
        
        for(string classname:req.keyset()){
            system.debug('Class: '+ classname + ':' + String.Join(req.get(classname), ', '));
        }
        system.assertequals(3, req.size());
        list<string> apo_req = req.get('Action_Plan_Objective__c');
        
        system.assertequals(1, apo_req.size());
    }
}