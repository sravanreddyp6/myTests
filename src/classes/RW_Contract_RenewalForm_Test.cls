public with sharing class RW_Contract_RenewalForm_Test {
//ApexPages.StandardController sc = new ApexPages.StandardController(testPlan);
    static testMethod void myUnitTest() {
        Redwood_Contract__c MyContract = new Redwood_Contract__c (name='123');
        insert MyContract;
        
        PageReference pageRef = Page.RW_Contract_RenewalForm ;
        Test.setCurrentPageReference(pageRef);
         pageRef.getParameters().put('id', MyContract.id);
                 
        ApexPages.StandardController sc = new ApexPages.StandardController(MyContract);
        RW_Contract_RenewalForm renew = new RW_Contract_RenewalForm(sc);
        renew.ReNewContract();
    }

}