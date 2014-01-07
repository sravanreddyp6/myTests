@isTest
private class CMContract_Form_Test {

    static testMethod void myUnitTest() {
        
        CareMeridian_Contract__c c = new CareMeridian_Contract__c ();
        c.name = 'test';
        c.Status__c = 'Active';
        insert c;
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CMContract_Form mycontract = new CMContract_Form(sc);
        PageReference pageRef = Page.CMContract_Form;
        Test.setCurrentPage(pageRef);
        
        mycontract.myEdit();
      //  mycontract.getcmRL();
        mycontract.myAddRL();
        
      //  mycontract.cmRL[0].Details__c = 'test';
        
        mycontract.save();
        
        
        System.currentPageReference().getParameters().put('oldid', c.id);
        Test.setCurrentPage(pageRef);
        mycontract = new CMContract_Form(sc);
        mycontract.removeCRL();
        mycontract.save();
        
        mycontract.getOldContract();
        mycontract.getmyContract();
        mycontract.getMapRateLevel();
        
        
    
    
    }
    
}