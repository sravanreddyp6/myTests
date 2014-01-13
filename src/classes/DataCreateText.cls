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
private class DataCreateText {

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

    static testMethod void CreateAcknowledgement() {
        DataCreate c = new DataCreate();
        
        map<string, object> fieldmap1 = new map<string, object>();
        fieldmap1.put('date_acknowledged__c', date.newinstance(2011,5,7));
        fieldmap1.put('user__c', 'mickey');
        Acknowledgment__c adm = (Acknowledgment__c)c.CreateObject('Acknowledgment__c', fieldmap1);
        //System.assertequals(pbs.id, adm.person_being_served__c);

		
        //map<string, object> fieldmap2 = new map<string, object>();
        //fieldmap2.put('name', 'mice');
        //Profile profile = (Profile)c.CreateObject('Profile', fieldmap2, 'mice');
        
        map<string, object> fieldmap = new map<string, object>();
        fieldmap.put('username', 'Mickey@mouse.com');
        fieldmap.put('lastname', 'mouse');
        fieldmap.put('email', 'Mickey@mouse.com');
        fieldmap.put('alias', 'Mickey');
        fieldmap.put('timezonesidkey', 'america/New_York');
        fieldmap.put('localesidkey', 'en_US');
        fieldmap.put('EmailEncodingkey', 'ISO-8859-1');
        fieldmap.put('languagelocalekey', 'en_us');
        fieldmap.put('profileid', 'mice');
        User pbs = (User)c.CreateObject('User', fieldmap, 'mickey');
        
    }
}