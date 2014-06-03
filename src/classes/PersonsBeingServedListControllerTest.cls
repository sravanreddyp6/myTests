@isTest
public with sharing class PersonsBeingServedListControllerTest {
    static testmethod void simpleTest() {
        Integer expectedNumber = 21;
        Account[] accts = beforeRun(expectedNumber);  // the default page size is 20
        PageReference ref = new PageReference('/apex/PersonsBeingServedListView');
        Test.setCurrentPage(ref);
        PersonsBeingServedListController controller = new PersonsBeingServedListController();
//      System.assertEquals(expectedNumber, controller.accountIds.size());
        System.assertEquals(controller.filterId, controller.con.getFilterId());
        System.assertEquals(controller.listViewOptions, controller.con.getListViewOptions());
        System.assertNotEquals('', controller.getPBSRecTypeId());
        System.assertNotEquals('', controller.getAssessmentOnlyRecTypeId());
    }

    static testmethod void getPersonBeingServed() {
        Account acct = beforeRun(1)[0];
        System.assertEquals(Acct.PersonContactID, PersonsBeingServedListController.getPersonBeingServed(Acct.ID).ID);
    }
    static testmethod void getAdmission() {
        beforeRun(1);
        Admission__c adm = [SELECT ID FROM Admission__c LIMIT 1];
        System.assertEquals(adm.ID, PersonsBeingServedListController.getAdmission(adm.ID).ID);
    }
    static testmethod void getServiceAssignment() {
        beforeRun(1);
        Service_Assignment__c sa = [SELECT ID FROM Service_Assignment__c LIMIT 1];
        System.assertEquals(sa.ID, PersonsBeingServedListController.getServiceAssignment(sa.ID).ID);
    }
    static testmethod void getPlan() {
        beforeRun(1);
        Action_Plan__c plan = [SELECT ID FROM Action_Plan__c LIMIT 1];
        System.assertEquals(plan.ID, PersonsBeingServedListController.getPlan(plan.ID).ID);
    }

    static Account[] beforeRun(Integer numAccounts) {
        String RecTypeId = [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        Account[] accts = new Account[] {};
        for (Integer i=0; i<numAccounts; i++) {
            accts.add(new Account(
                LastName = 'Test Last Name ' + i,
                PersonMailingStateCode='NC',
                RecordTypeID = RecTypeId
            ));
        }
        insert accts;
        accts = [
            SELECT ID, PersonContactId FROM Account
        ];
        Admission__c admission = new Admission__c(
            Name='TestName',
            Person_Being_Served__c=accts[0].PersonContactId
        );
        insert admission;
        Service_Assignment__c sa = new Service_Assignment__c(
            Admission__c=admission.ID,
            Person_Being_Served__c=accts[0].PersonContactId
        );
        insert sa;
        Action_Plan__c plan = new Action_Plan__c(
            Service_Assignment__c=sa.ID
        );
        insert plan;
        return accts;
    }
}