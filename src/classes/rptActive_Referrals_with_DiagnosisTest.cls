@isTest
private class rptActive_Referrals_with_DiagnosisTest {
	
    static testMethod void myUnitTest() {
		Person_Being_Referred__c pbr = new Person_Being_Referred__c();
		
        pbr.First_Name__c = 'Doug';
        pbr.Last_Name__c = 'Surfleet';
        pbr.Gender__c = 'Male';
        
        insert pbr;
        
        Referral__c referral = new Referral__c();
        referral.Person_Being_Referred__c = pbr.Id;
        insert referral;
        
        Diagnosis__c diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        
		pbr = new Person_Being_Referred__c();
		
        pbr.First_Name__c = 'David';
        pbr.Last_Name__c = 'Ortiz';
        pbr.Gender__c = 'Male';
        
        insert pbr;
        
        referral = new Referral__c();
        referral.Person_Being_Referred__c = pbr.Id;
        insert referral;
        
        diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        diag = new Diagnosis__c(Status__c = 'Active', PBR__c = pbr.Id);
        insert diag;
        
        rptActive_Referrals_with_Diagnosis testARD = new rptActive_Referrals_with_Diagnosis();
        
        testARD.setStartDate(Date.parse('1/1/2000'));
        testARD.setEndDate(Date.today());
        
        testARD.runRpt();
        
        list<rptActive_Referrals_with_Diagnosis.rptRow> rptRows = testARD.getRptData();
        
        system.assertEquals(4, rptRows.size());
    }
}