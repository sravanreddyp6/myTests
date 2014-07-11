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
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        
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