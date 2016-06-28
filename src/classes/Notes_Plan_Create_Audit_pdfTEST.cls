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
private class Notes_Plan_Create_Audit_pdfTEST {

static testMethod void testMyController()
   {      
        Notes_Plan_Create_Audit_pdf controller = new Notes_Plan_Create_Audit_pdf ();
        
      Contact testContact = new Contact(
        LastName = 'TestLastName'
      );
      insert testContact;
      
      Admission__c testAdm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = testContact.Id,
            Effective_Date__c = date.today(),
            Admission_Effective_DateTime__c = DateTime.Now()
      );
      insert testAdm;
        
        
        
        Plan__c testPlan = new Plan__c(Status__c = 'Inactive', Long_Term_Goal_1__c = '12', Admission__c = testAdm.id);
        insert testPlan;
        controller.myID = testPlan.ID;
        controller.redirect();
        
      //  controller.getdocs();
        //controller.nothing();        
   }


}