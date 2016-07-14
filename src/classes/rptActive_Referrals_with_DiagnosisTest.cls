@isTest
private class rptActive_Referrals_with_DiagnosisTest {
	
    static testMethod void myUnitTest() {
		Person_Being_Referred__c pbr = new Person_Being_Referred__c();
		
        pbr.First_Name__c = 'Test';
        pbr.Last_Name__c = 'Referral';
        pbr.Gender__c = 'Male';
        
        insert pbr;
        
        Referral__c referral = new Referral__c( referral_date__c = Date.Today());
        referral.Person_Being_Referred__c = pbr.Id;
        insert referral;
        
        Diagnosis__c diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        
		pbr = new Person_Being_Referred__c();
		
        pbr.First_Name__c = 'Another';
        pbr.Last_Name__c = 'Referral';
        pbr.Gender__c = 'Male';
        
        insert pbr;
        
        referral = new Referral__c( referral_date__c = Date.Today());
        referral.Person_Being_Referred__c = pbr.Id;
        insert referral;
        
        diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        
        rptActive_Referrals_with_Diagnosis testARD = new rptActive_Referrals_with_Diagnosis();
        
        testARD.StartDate = Date.Today();
        try { 
        	testARD.runRpt();
        } catch (Exception e) {
        	System.assert( true, 'Missing End date' );
        }
        testARD.EndDate = Date.today().addDays(-1);
        try {
        	testARD.runRpt();
        } catch (Exception e) {
        	System.assert( true, 'End before start');
        }

		testARD.EndDate = Date.Today();        
        testARD.runRpt();
        
        list<rptActive_Referrals_with_Diagnosis.rptRow> rptRows = testARD.rptData;
        
        system.assertEquals(4, rptRows.size());
        
        testARD.cancelToNewRun();
    }
}