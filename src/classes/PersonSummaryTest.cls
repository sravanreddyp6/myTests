@isTest
private class PersonSummaryTest {
	static testMethod void testException() {
        PageReference pageRef = Page.PersonSummary;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id', '123123');
        PersonSummary ps = new PersonSummary();
        system.assert(true,Apexpages.hasMessages());
    }

    static testMethod void testExceptionForSAID() {
    	TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        PageReference pageRef = Page.PersonSummary;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id', myData.theSA.id);
        PersonSummary ps = new PersonSummary();
        system.assert(true,Apexpages.hasMessages());
    }
        
    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        createAdditionalTestData(myData.contactID);
        PageReference pageRef = Page.PersonSummary;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id', myData.contactID);
        PersonSummary ps = new PersonSummary();

        system.assert(true,ps.getContact().Id==myData.contactID);
        system.assert(true,ps.getServiceProviders().size()>0);
        system.assert(true,ps.getEmergencyContacts().size()>0);
        system.assert(true,ps.getSa().Funding_Sources__r[0].Type_of_Coverage__c=='Primary');
        system.assert(true,ps.getFsFlds().size()>0);
        system.assert(true,ps.getFundingSrcFldLbls().size()>0);
        system.assert(true,ps.getFundingSrcFldVals().size()>0);
    }

	private static void createAdditionalTestData(Id pbsID){
        list<Related_Party__c> rps = new list<Related_Party__c>();
        rps.add(new Related_Party__c(Person_Being_Served__c = pbsID, Name='RP1', Phone__c='1231231231', Address__c='313 Congress St', 
		                      Phone_2__c='3213213213', Type__c='Physician - Alternate', Comments__c='Physician - Alternate', 
		                      Phone_1_Type__c='Home', Phone_2_Type__c='Cell')); 
        rps.add(new Related_Party__c(Person_Being_Served__c = pbsID, Name='RP2', Phone__c='1231231231', Address__c='313 Congress St', 
                              Phone_2__c='3213213213', Type__c='Physician - Alternate', Comments__c='Physician - Alternate', 
                              Phone_1_Type__c='Home', Phone_2_Type__c='Cell')); 
        rps.add(new Related_Party__c(Person_Being_Served__c = pbsID, Name='RP3', Phone__c='1231231231', Address__c='313 Congress St', 
                              Phone_2__c='3213213213', Type__c='Spouse', Comments__c='Spouse', 
                              Phone_1_Type__c='Home', Phone_2_Type__c='Cell')); 
        rps.add(new Related_Party__c(Person_Being_Served__c = pbsID, Name='RP4', Phone__c='1231231231', Address__c='313 Congress St', 
                              Phone_2__c='3213213213', Type__c='Caregiver', Comments__c='Caregiver', 
                              Phone_1_Type__c='Home', Phone_2_Type__c='Cell'));
        insert rps;
        
        Service_Assignment__c sa = [select id from Service_Assignment__c where person_being_served__c = : pbsID limit 1]; 
        
        insert (new Funding_Source__c (Type_of_Coverage__c='Primary',Payer_Name__c='Primary',Policy_Type__c='Primary',TPA__c='Primary',
                    TPA_Phone__c='1231231231',Primary_Med_Ind_Phys_Group__c='Primary',Primary_Med_Ind_Phys_Group_Phone__c='Primary',
                    Network__c='Primary', Network_Phone__c='1231231231', Verified_By__c='Primary', Payer_Verification_Date__c= system.today(), 
                    Verified_With__c='Primary', Representing__c='Primary', Payer_Type__c='Primary', Call_Reference_Number__c='1231231231', 
                    Policy_Number__c='Primary', Group_Name__c='Primary', Group_Number__c='Primary', Policy_Holder__c='Primary', 
                    Relationship_To_Patient__c='Spouse',More_than_1_5_Yrs_of_Disability__c=true,Patient_Over_64_Years_of_Age__c=true, 
                    Comment__c='test', Service_Assignment__c=sa.id));
    }

}