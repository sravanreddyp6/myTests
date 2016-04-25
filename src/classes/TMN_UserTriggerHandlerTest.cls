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
        
        //Sravan - Create a Subordinate record to test the emanager lookup population
        TMN_User__c Emp =new TMN_User__c(First_Name__c= 'Subordinate',
								            Last_Name__c='Test',
								            Employee_Number__c = '12345464',
								            Recruiter_Email_Address__c = UserInfo.getUserEmail(),
								            Manager_Employee_Id__c = '12345453'
								            );
        insert Emp;
        
        TMN_User__c e = [SELECT Manager_lookup__c, Manager_Employee_Id__c FROM TMN_User__c WHERE Id=:Emp.Id LIMIT 1];
        system.assert(tmnu.Id == e.Manager_lookup__c);
        e.Manager_Employee_Id__c = null;
        update e;
        TMN_user__c f = [SELECT Id, Manager_lookup__c FROM TMN_user__c WHERE Id=:e.id LIMIT 1];
        system.assert(null == f.Manager_lookup__c);
        f.Manager_Employee_Id__c = '12345453';
        update f;
        system.assert(tmnu.id == [SELECT Id, Manager_lookup__c FROM TMN_User__c WHERE Id=:f.id LIMIT 1].Manager_lookup__c);
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