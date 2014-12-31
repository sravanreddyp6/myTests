@isTest
Public class Create_LogHistory_Test{

    static testMethod void myUnitTest(){ 
    
        Date dt= Date.Today();
           
            
        Create_LogHistory cl = new Create_LogHistory();
        cl.CreateLogHistory('test','test',dt,'x567record','test');
        
        Log_History__c lg = new Log_History__c();
        lg.Comments__c = 'Test Comments';
        lg.Action__c = 'Test Action';
        lg.Date_of_Submission__c = dt;
        lg.Record_Id__c = '12345Test';
        
        insert lg;
        
        Log_History__c l = [SELECT ID, Name, Comments__c, Action__c, Date_of_Submission__c , Record_Id__c FROM Log_History__c WHERE id=:lg.id LIMIT 1];
        system.assertEquals(l.Comments__c,'Test Comments');
        system.assertEquals(l.Date_of_Submission__c,system.today());
        
    }
      
}