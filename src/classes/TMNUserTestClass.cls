@isTest
private class TMNUserTestClass{
static testMethod void TMNUserInsertTest()
    {
        TMN_User__c tmnu =new TMN_User__c( First_Name__c = 'TMNFirst', Last_Name__c = 'TMNLast');
        insert tmnu;
        
        // Retrieve the new tmn user
        tmnu = [SELECT First_Name__c, Last_Name__c FROM TMN_User__c WHERE Id =:tmnu.Id];
        
        List<Account_Administration__c> acctadmin=[select id, name, first_name__c from Account_Administration__c where First_Name__c = :tmnu.First_Name__c and Name = :tmnu.Last_Name__c];
        
        System.assertEquals(1, acctadmin.size());
        
    }
    }