@isTest
public class Assessment_RiskForm_Test{
    private static Assessment__c assess;
    
static testMethod void myUnitTest() {
    createData();
    
	ApexPages.StandardController sc = new ApexPages.StandardController(assess);  
    
    Assessment_RiskForm contrl = new Assessment_RiskForm(sc);
	PageReference pageRef = Page.Assessment_RiskForm;
    Test.setCurrentPage(pageRef);    
    
    contrl.getLevel_Required_ResidentialServices();
    contrl.getSOLevel_Required_ResidentialServices();
   // boolean canEdit = contrl.get
    boolean canRevise = contrl.getCanReviseAssess();
    contrl.getdisplayLevel_Required_DayServices();
    
    
}
    
    
    private static Action_Plan__c createData(){
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
        
        Id aContactId = [select PersonContactId from account where id =:accnt.id].PersonContactId;
        Id aAccountId = Accnt.Id;        
		Admission__c Adm = new Admission__c(
            Name = 'TEST ADM',
            Person_Being_Served__c = aContactId,
            Effective_Date__c = date.today(),
            Network_Offering__c = 'ARY'
        );
        insert Adm;     
        
        Service_Assignment__c SA = new Service_Assignment__c(
            admission__c = adm.id,
        	Person_Being_Served__c = aContactId
        );        
        insert SA;
        
        Assessment_Type__c testAssmtType = new Assessment_Type__c(
            Name = 'RISK'           
        );
        insert testAssmtType;
        
        Assessment_Domain__c testDomain = new Assessment_Domain__c(
            Name = 'TEST DOMAIN',
            Assessment_Type__c = testAssmtType.Id
        );
        insert testDomain;
        
        Assessment_Question__c testQuestion = new Assessment_Question__c(
            Question_Title__c = 'TEST QUESTION',
            Question_Description__c = 'A TEST QUESTION',
            Question_Domain__c = testDomain.Id
        );
        insert testQuestion;
        
        assess = new assessment__c(
            Assessment_Type__c = testAssmtType.id
        
        );
        
        
        return null;
    }    
    
}