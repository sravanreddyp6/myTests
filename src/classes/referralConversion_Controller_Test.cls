/*
** This test class needs to:
** 
** - create a test referral on a person being referred
** - call conversion routine
** - verify a new PBS, Admission for PBS, and SErvice assignment for Admission for PBS are all created and have correct info.
** 
** - create a new referral on the new PBS
** - call conversion routine
** - verify only a new service assignment is created and that it is linked to the test PBS, and the admission
** 
** Use the test data methods available through Referral_CreateTestData class.
** 
*/
@isTest
private class referralConversion_Controller_Test {

    static testMethod void testConvert() {

        User u = Referral_CreateTestData.createTestUser( 'testuzz', 'convuser@tmn.int','Conversion', 'TestUser' );
        Test.startTest();
        System.RunAs(u)
        
        {
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(30, Date.valueOf('1983-01-01'));
        Referral__c theRef = Referral_CreateTestData.createReferral('California', 'Active', 'Conversion Test', 'CA', pbr);
        Referral_CreateTestData.createRelatedParty('Mom', 'Guardian', pbr);
        Referral_CreateTestData.createAgencyInvolved('Involved Agency','Case Worker', theRef);
                                                                          
        ApexPages.StandardController sc = new ApexPages.StandardController( theRef );
        referralConversion_Controller conv = new referralConversion_Controller( sc );

        System.AssertEquals( theRef.Id, conv.referralRecord.Id );
        PageReference pr;
        
        try {
            pr = conv.convertReferral();
        } catch (Exception e){
            
            System.Assert( e.getMessage().Contains('Unable to create new Person Being Served'));
        }
        
        // add a state
        pbr.State__c = 'California';
        pbr.City__c = 'San Francisco';
        pbr.Street_1__c = '10 Main St.';
        pbr.Street_2__c = 'Suite 201';
        pbr.Zip_Code__c = '90024';
        pbr.Ethnicity__c = 'Caucasian';
        pbr.Primary_Language__c = 'English';
        pbr.Non_Verbal__c = false;
        update pbr;

        sc = new ApexPages.StandardController( theRef );
        conv = new referralConversion_Controller( sc );

        pr = conv.convertReferral();
        
        if ( pr != null ) {
            
            
            // check that PBS was created
            System.assertNotEquals( null, conv.idPBS ); 
            System.assertNotEquals( null, conv.idAdm );
            System.assertNotEquals( null, conv.idSA );
            
            // now create a new referrals with the PBS
            Referral__c thePBSRef = createReferral2('California', 'Active', 'Conversion Test2', 'CA', conv.idPBS);
            String pbsfname = conv.person.FirstName;
            
            sc = new ApexPages.StandardController( thePBSRef );
            conv = new referralConversion_Controller( sc );
            System.assertEquals( conv.person.FirstName, pbsfname );
            
            System.AssertEquals( thePBSRef.Id, conv.referralRecord.Id );
            
            try {
                pr = conv.convertReferral();
            } 
            catch (Exception e){
                
            }
            }
      
        }
        Test.stopTest();
    }
 
 
 public static Referral__c createReferral2(String recordType, string Status, string ReferralName, string State, ID pbs) {
         Service_location__c SL = new Service_location__c(name = '234', UniqueID__c ='234', FacilityID__c =234,Alias__c ='234',ProgramID__c ='234',Program__c='234');
         insert SL;
        Referral__c ref = new Referral__c(RecordTypeId=Utility.getRecordTypeForReferral(recordType),
                                          Referral_Status__c=Status,
                                          Referral_Name__c=ReferralName,
                                          Service_location__c = SL.id,
                                          Person_Being_Served__c=pbs);
                                          
        System.Debug( 'Record type for referral is:' + Utility.getRecordTypeForReferral(recordType));
        insert ref;    
        Referral__c testRef = [SELECT Id, Name, RecordTypeId, RecordType.Name, Street_1__c, Street_2__c, City__c, State__c, Zip_Code__c, Phone__c, Email_Address__c, 
                               Fax__c, Legal_Guardian_Status__c, State_for_Preferred_Service__c, Reason_for_Referral__c, Axis_I__c, Axis_II__c, 
                               Axis_III__c, Axis_IV__c, Axis_V__c, Comments__c, Medicaid_ID__c, Medicare_ID__c, Financial_Resources__c, 
                               Referral_Status__c, Anticipated_Admission_Date__c, Program_Admission_Location__c, Close_Date__c, 
                               Service_Location__c, Refer_to_Provider__c, Unsupervised_Time__c, Live_with_Opposite_Sex__c, Nursing_Care_Needed__c, 
                               Level_of_Support_Required__c, Accessible_Housing_Needed__c, Physically_Aggressive_to_Staff__c, 
                               Physically_Aggressive_to_Self__c, Physically_Aggressive_to_Peers__c, Verbally_Aggressive__c, Property_Destruction__c, 
                               Law_Enforcement_Involvement__c, Elopement__c, Suicide_Threats__c, Suicide_Attempts__c, 
                               Self_Harm_or_Self_Injurous_Behaviors__c, Unwanted_Sexual_Behavior__c, Chemical_Use_Current__c, 
                               Chemical_Use_Recovery__c, Chemical_Dependency_Treatment__c, Area_of_State_Interested_In__c, Staffing_Needs__c, 
                               Staffing_Ratio__c, Person_Being_Referred__c, Waiver_Funding_Source__c, Restricted_Health_Conditions__c, 
                               Registered_Sex_Offender__c, Current_Medical_Conditions__c, Services_Requested__c, Health_and_Safety_Needs__c, 
                               Anticipated_Job_Accomodations__c, Secondary_Diagnosis__c, Level_of_Disability__c, Date_of_Injury__c, 
                               Cause_of_Injury__c, Estimated_Discharge_Date__c, Referring_Physician__c, Current_Location__c, Referral_Source_Type__c, 
                               Referral_Name__c, Agency_Name__c, Referral_Phone_Number__c, Referral_Date__c, Prior_Program_Information__c, 
                               State_Specific_ID_Name__c, State_Specific_ID__c, Living_Environment__c, Mobility__c, Case_Manager_Name__c, 
                               Case_Manager_Phone__c, Close_Reason__c, Hold_Date__c, Hold_Reason__c, Program_Street_1__c, Program_Street_2__c, 
                               Program_City__c, Program_State__c, Program_Zip_Code__c, Accessible_Vehicle_Needed__c, Name_PBR__c, Review_On__c, 
                               RecordCount__c, Days_To_Convert_Referral__c, OldPBR__c, Assigned_Users__c, Service_Location_City__c, 
                               Service_Location_State__c, Service_Location_Zip__c, Service_Location_Street__c, Service_Location_Program__c, person_being_served__c 
                               from referral__c where Id = :ref.Id];
        return testRef;
    }
       
}