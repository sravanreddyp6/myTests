public with sharing class testdeleteaccess {
public admission__c ad = new admission__c();
    public testdeleteaccess(ApexPages.StandardController controller) {
        ad =   (admission__c)controller.getRecord();
    }
    public pagereference mydelete(){
       // admission__c ad = new admission__c();
       // ad = [select id from admission__c where id =:'a0DZ000000KS6pgMAD'];
        delete ad;
    return null;
    }

}