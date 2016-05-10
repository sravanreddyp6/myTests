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
private class rpt_AuthUtilizationNR_Test {

    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        List<Authorization__c> auths = new List<Authorization__c>();
        PageReference pageRef = Page.AuthorizationNREdit;
        For(integer i=0; i < 5; i++){
            Funding_Source__c f = new Funding_Source__c(Service_Assignment__c = myData.theSA.Id, Type_of_Coverage__c='Primary');
            insert f;
            Authorization__c s = new Authorization__c(
                Person_Being_Served__c = myData.contactID,
                Funding_Source__c = f.id
            );
            auths.add(s);
        }
        insert auths;
        Funding_Source__c f = new Funding_Source__c(Service_Assignment__c = myData.theSA.Id, Type_of_Coverage__c='Primary');
        insert f;
        Authorization__c authoriza = new Authorization__c(
            Person_Being_Served__c = myData.contactID,
            Authorization_Status__c = 'Draft'
       );
            insert authoriza;
    
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('saID', null);  
        AuthorizationExt controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));
        Apexpages.currentPage().getParameters().put('saID', myData.theSA.Id);  
        controller = new AuthorizationExt(new ApexPages.StandardController(authoriza));    
    
    }
}