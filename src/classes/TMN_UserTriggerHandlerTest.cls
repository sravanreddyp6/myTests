@isTest
private class TMN_UserTriggerHandlerTest {

    static testMethod void createNewHireRecord() {
        TMN_User__c tmnu =new TMN_User__c(First_Name__c= 'Firstname',
								            Last_Name__c='Testing',
								            Employee_Number__c = '12345453',
								            Recruiter_Email_Address__c = UserInfo.getUserEmail()
								            );
        insert tmnu;
        
        system.assertEquals(0, [select id from task].size());
        
        
        tmnu.Current_Person_Type__C = 'Pre-hire';
        tmnu.Recruiter_Name__c = UserInfo.getName();
        upsert tmnu;
        system.assertEquals(1, [select id from task].size());
    }
    
    static testMethod void createNewHireRecords() {
        list<TMN_User__c> tmnu = new list<TMN_User__c>();
        tmnu.add(new TMN_User__c ( First_Name__c= 'Firstname',
                                   Last_Name__c='Testing',
                                   Employee_Number__c = '12345453',
                                   Recruiter_Name__c = UserInfo.getName()
                                   ) );
        tmnu.add(new TMN_User__c ( First_Name__c= 'Firstname2',
                                   Last_Name__c='Testing2',
                                   Employee_Number__c = '12345763',
                                   Recruiter_Name__c = UserInfo.getName()
                                   ) );
        upsert tmnu;
        system.assertEquals(0, [select id from task].size());
        
        tmnu.clear();
        for (TMN_User__c u : [select id, Current_Person_Type__C from TMN_User__c]){
            u.Current_Person_Type__C = 'Pre-hire';
            tmnu.add(u);    
        }
        
        upsert tmnu;
        system.assertEquals(2, [select id from task].size());
    }
    
    
}