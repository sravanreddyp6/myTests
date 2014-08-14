@isTest
public class shiftnote_summary_rpt_Test{
static testMethod void myUnitTest() {
/*
        String RecTypeId= [select Id from RecordType where (DeveloperName='Person_Being_Served') and (SobjectType='Account') Limit 1].Id;
        
        Account Accnt = new Account(
            RecordTypeID=RecTypeId,
            FirstName= 'Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt; 
    */
    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    
    shiftnote_summary_rpt cntl = new shiftnote_summary_rpt();
    cntl.getNote_plan_joins();
    cntl.getnotes();
    cntl.getPBSlsit();
    cntl.clearSelectedPbs();
    cntl.runReport();
    cntl.selectAllPbs();
    cntl.runReport();
    
}
}