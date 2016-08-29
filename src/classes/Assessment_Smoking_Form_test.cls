@isTest
public with sharing class Assessment_Smoking_Form_test {
    public static testmethod void simpleTests() {
        TMN_Generic_Core_TestData testD = new TMN_Generic_Core_TestData ();
        testD.theAdm.State__c = 'MN';
        update testD.theAdm;
        Eval_Type__c evT = new Eval_type__c (Category__c = 'test');
        insert evT;
        Eval__c  ev = new eval__c (Eval_Type__c = evT.id, Field_Name__c = 'test', Sub_Category__c = 'Smoking Assessment', Visible__c = true, htmlid__c = 'test');
        insert ev;
        Evaluation__c E = new Evaluation__c(ServiceAssignment__c = testD.theSA.id );
        ApexPages.currentPage().getParameters().put('saID', testD.theSA.id );
        Assessment_Smoking_Form controller = new Assessment_Smoking_Form(
            new ApexPages.standardController(E)
        );
        
        controller.mySave();
        controller.Finalize();
        controller.Revise();
        controller.myCancel();
        List<SelectOption> l =  controller.getBasicOptions();
         
    }
}