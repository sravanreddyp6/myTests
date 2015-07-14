@isTest
private class AdmissionViewExtensionTest {
    static testmethod void simpleTest() {
    TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
    
        PageReference ref = new PageReference('/apex/AdmissionView?id='+myData.theAdm.ID);
        Test.setCurrentPage(ref); 
        AdmissionViewExtension controller = new AdmissionViewExtension(new ApexPages.StandardController(myData.theAdm));
        // The controller really doesn't do anything other than fetching the
        // record, so we just check to make sure the record is fetch correctly
        System.assertEquals(myData.theAdm.ID, controller.admission.ID);
        
        Assessment_Type__c newtype = new Assessment_Type__c( name='Risk');
        insert newtype;
        
        newtype = new Assessment_Type__c( name='risk');
        insert newtype;
        
        newtype = new Assessment_Type__c( name='CANS');
        insert newtype;
        
        // fetch assessments
        Assessment__c[] assess = controller.riskAssessments;
        System.assertEquals( 0, assess.size());

		boolean cansee = controller.showCANS;        
        assess = controller.CANSAssessments;
        System.assertEquals( 0, assess.size());
        
        ID cansID = controller.getCANsID();
        
        // create risk assessment
        if ( controller.createRiskAssess() != null )
        {
            assess = controller.riskAssessments;
            //System.assertEquals( 1, assess.size());
        }
        
        
        AdmissionViewExtension.IgnoreSharing noshare = new AdmissionViewExtension.IgnoreSharing();
        
        System.Assert(noshare.getallSA( controller.admission.ID).size() > 0 );
        
    }
}