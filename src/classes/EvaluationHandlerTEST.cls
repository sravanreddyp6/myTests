/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EvaluationHandlerTEST {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Referral__c myRef = new Referral__c();
        insert myRef;

        Evaluation__c myEval = new Evaluation__c(
            Referral__c = myRef.Id
        );
        insert myEval;

        myEval.Primary_Diagnosis__c = 'TEST DX TEXT';
        myEval.Is_Being_Signed__c = true;
        update myEval;

        Evaluation__c eval1 = [ SELECT Is_Signed__c FROM Evaluation__c WHERE Id = :myEval.Id LIMIT 1 ];
        System.assert(eval1.Is_Signed__c==true);

        myEval.Is_Being_Signed__c = false;
        update myEval;

        Evaluation__c eval2 = [ SELECT Is_Signed__c FROM Evaluation__c WHERE Id = :myEval.Id LIMIT 1 ];
        System.assert(eval2.Is_Signed__c==false);

        delete myEval;

        undelete myEval;

        EvaluationHandler myEvalHandler = new EvaluationHandler(true);
        System.assert(myEvalHandler.IsTriggerContext==true);
    }

    static testmethod void testValidation() {
        Referral__c referral = new Referral__c();
        insert referral;

        Evaluation__c eval = new Evaluation__c(
            Referral__c = referral.Id,
            Employed__c = false,
            Employment_Status__c = 'FT',
            Advanced_Directives_Attached__c = true
        );
        insert eval;
        eval = [
            SELECT Id, Employment_Status__c, Advanced_Directives_Attached__c
            FROM Evaluation__c WHERE Id=:eval.Id
        ];
        System.assertEquals(null, eval.Employment_Status__c);
        System.assertEquals(false, eval.Advanced_Directives_Attached__c);
    }
}