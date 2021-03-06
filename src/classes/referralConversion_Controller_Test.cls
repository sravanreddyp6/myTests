@isTest
private class referralConversion_Controller_Test {

    static testMethod void testConvert() {

        User u = Referral_CreateTestData.createTestUser( 'testuzz', 'convuser@tmn.int','Conversion', 'TestUser' );
        Test.startTest();
        System.RunAs(u)
        
        {
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(30, Date.valueOf('1983-01-01'));
        Referral__c theRef = Referral_CreateTestData.createReferral('NeuroRestorative', 'Active', 'Conversion Test', 'CA', pbr);
        Referral_CreateTestData.createRelatedParty('Mom', 'Guardian', pbr);
        Referral_CreateTestData.createAgencyInvolved('Involved Agency','Case Worker', theRef);
        Service_Code__c codes = new Service_Code__c(Start_Date__c=Date.NewInstance(2013, 10, 10), Program_Code__c = theRef.Service_Location__r.ProgramID__c); insert codes;
        Referral_Location__c rloc = Referral_CreateTestData.createReferralLocation('Test Alias', 'Test Location', 'New', u, theRef);
        Funding_Source__c newfs= Referral_CreateTestData.createFundingSource('NeuroRestorative', 'Primary', '123', 'Pending', 
                                                                                 'Service', 'Authorization comment', theRef);
        newfs.authorization_type__c = 'Inital';
        newfs.authorization_number__c = '11111111111';
        newfs.received_date_time__c = datetime.newinstance(2014, 9, 18);
        newfs.status__c = '';
        newfs.Funding_Source__c = 'Medicaid';
        update newfs;													                 
                                                                          
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
        pbr.Level_of_Education__c = 'Unknown';
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
           // System.AssertEquals( pbr.Level_of_Education__c, conv.person.Education ); 
            try {
                pr = conv.convertReferral();
            } 
            catch (Exception e){
                
            }
        
      	}
             ID clsRef = conv.closeReferral(conv.idPBS, theRef);
             Admission__c currAdm = new Admission__c(Person_Being_Served__c = conv.idPBS,
                Admission_Effective_DateTime__c = DateTime.now(),
                Network_Offering__c = 'ARY',
                Program__c = theRef.Service_Location_Program__c,
                Referral_Date__c = theRef.Referral_Date__c,
                State__c = theRef.Service_Location_State__c,
                Status__c = 'Active'); 
            insert currAdm;
            ID creSA = conv.createServiceAssignment(conv.idPBS, currAdm.Id, theRef);
           // referralConversion_Controller.personRecord pr1 = new referralConversion_Controller.personRecord(pbr);

        }
        
        Test.StopTest();
    }
    
    static testMethod void testConvertwithEval() {
    	
    	
      	User u2 = Referral_CreateTestData.createTestUser( 'testuzz', 'convuser@tmn.int','Conversion', 'TestUser2' );
		Test.StartTest();
		System.RunAs(u2)
		
		{
			Person_Being_Referred__c pbr2 = Referral_CreateTestData.createPersonBeingReferred(28, Date.valueOf('1985-01-01'));
			Referral__c evalRef = Referral_CreateTestData.createReferral('CareMeridian', 'Active', 'Conversion Test3', 'CA', pbr2);
			Referral_CreateTestData.createRelatedParty('Mom', 'Guardian', pbr2);
			pbr2.State__c = 'California';
			pbr2.City__c = 'San Francisco';
			pbr2.Street_1__c = '10 Main St.';
			pbr2.Street_2__c = 'Suite 201';
			pbr2.Zip_Code__c = '90024';
			pbr2.Ethnicity__c = 'Caucasian';
			pbr2.Primary_Language__c = 'English';
			pbr2.Non_Verbal__c = false;
			update pbr2;
            
			
			
			ApexPages.StandardController sc = new ApexPages.StandardController( evalRef );
			referralConversion_Controller conv = new referralConversion_Controller( sc );
			PageReference pr;
			
			Evaluation__c exEval = new Evaluation__c();
			exEval.Name = 'Test Eval';
			exEval.RecordTypeId = Utility.getEValuationRecordType('CareMeridian');
			exEval.Referral__c = evalRef.Id;
			insert exEval;
            
            List<RecordType> rt = [select id from RecordType where DeveloperName = 'Allergy' and sObjectType = 'Evaluation_Response__c' limit 1];
            Evaluation_Response__c eval = new Evaluation_Response__c( RecordTypeId = rt[0].Id, Evaluation__c = exEval.Id,
                                                                     Allergy_type__c = 'Food', Allergy_Details__c = 'Rice', Life_Threatening__c = false); 
            insert eval;
			pr = conv.convertReferral();

        }
    
    	Test.StopTest();
    }
 
 
 static testMethod void testConvertFundingSources() {
    	
    	
      	User u2 = Referral_CreateTestData.createTestUser( 'testuzz', 'convuser@tmn.int','Conversion', 'TestUser2' );
		Test.StartTest();
		System.RunAs(u2)
		
		{
			Person_Being_Referred__c pbr2 = Referral_CreateTestData.createPersonBeingReferred(28, Date.valueOf('1985-01-01'));
			Referral__c fsRef = Referral_CreateTestData.createReferral('CareMeridian', 'Active', 'Conversion Test3', 'CA', pbr2);
			Referral_CreateTestData.createRelatedParty('Mom', 'Guardian', pbr2);
			pbr2.State__c = 'California';
			pbr2.City__c = 'San Francisco';
			pbr2.Street_1__c = '10 Main St.';
			pbr2.Street_2__c = 'Suite 201';
			pbr2.Zip_Code__c = '90024';
			pbr2.Ethnicity__c = 'Caucasian';
			pbr2.Primary_Language__c = 'English';
			pbr2.Non_Verbal__c = false;
			update pbr2;
			
			Funding_Source__c newfs= Referral_CreateTestData.createFundingSource('CareMeridian', 'Primary', '123', 'Pending', 
                                                        'Service', 'Authorization comment', fsRef);
            newfs.authorization_type__c = 'Inital';
            newfs.authorization_number__c ='101010101';
            update newfs;
            
            newfs = Referral_CreateTestData.createFundingSource('CareMeridian', 'Primary', '123', 'Pending', 
                                                        'Service', 'Authorization comment', fsRef);
            newfs.authorization_type__c = 'Inital';
            newfs.authorization_number__c = '11111111111';
            newfs.received_date_time__c = datetime.newinstance(2014, 9, 18);
            newfs.status__c = '';
            update newfs;													
                                                        
			ApexPages.StandardController sc = new ApexPages.StandardController( fsRef );
			referralConversion_Controller conv = new referralConversion_Controller( sc );
			PageReference pr; 
			pr = conv.convertReferral();
			
			// check for the funding source being attached to SA and newly created auth
			// get the SA from the converted referral
			fsref = [select id, name from referral__c where id = :fsref.id];
			
			List<Funding_Source__c> funds = [ select id, name, service_assignment__c from funding_source__c where service_assignment__r.referral__c = :fsref.Id];
			//System.AssertEquals( funds.size(), 2);
			
			
			// both auths should also be converted
			List<Authorization__c> auths = [ select id, name from authorization__c where funding_source__r.service_assignment__r.referral__c = :fsref.Id ];
			//System.AssertEquals( auths.size(), 2);
			
            conv.getNumAuthPopulatedFields(newfs);
           /* newfs.authorization_type__c = 'Open Ended Stay';
            update newfs;
            conv.getNumAuthPopulatedFields(newfs);
			newfs.authorization_type__c = 'Open Ended Charge';
            update newfs;
            conv.getNumAuthPopulatedFields(newfs);
			newfs.authorization_type__c = 'Bed Hold';
            update newfs;
            conv.getNumAuthPopulatedFields(newfs); */
			
        }
    
    	Test.StopTest();
    }
    
    static testMethod void testConvertDiagnosis() {
    	
    	
      	User u2 = Referral_CreateTestData.createTestUser( 'testuzz', 'convuser@tmn.int','Conversion', 'TestUser2' );
		Test.StartTest();
		System.RunAs(u2)
		
		{
			Person_Being_Referred__c pbr2 = Referral_CreateTestData.createPersonBeingReferred(28, Date.valueOf('1985-01-01'));
            Contact pbs = new Contact(LastName='Last Test', FirstName= 'Test First', Birthdate = Date.Today());
            insert pbs;
			Referral__c diagRef = Referral_CreateTestData.createReferral('CareMeridian', 'Active', 'Conversion Test3', 'CA', pbr2);
			Referral_CreateTestData.createRelatedParty('Mom', 'Guardian', pbr2);
			pbr2.State__c = 'California';
			pbr2.City__c = 'San Francisco';
			pbr2.Street_1__c = '10 Main St.';
			pbr2.Street_2__c = 'Suite 201';
			pbr2.Zip_Code__c = '90024';
			pbr2.Ethnicity__c = 'Caucasian';
			pbr2.Primary_Language__c = 'English';
			pbr2.Non_Verbal__c = false;
			update pbr2;
			
            Diagnosis__c diag = new Diagnosis__c(Status__c = 'Active', PBR__c  = pbr2.Id); insert diag;
            ICD__c icd = new ICD__c(Code_Type__c = 'ICD-10', Icd_Description__c = 'testing'); insert icd;
                             
			ApexPages.StandardController sc = new ApexPages.StandardController( diagRef );
			referralConversion_Controller conv = new referralConversion_Controller( sc );
			PageReference pr; 
			pr = conv.convertReferral();
			
            Contact cont = conv.personBeingServedRecord;
            conv.getPBSRec();
            conv.getProgram();
            conv.getServiceLine();
            conv.getLocation();
            ID clsRef = conv.closeReferral(conv.idPBS, diagRef);
            referralConversion_Controller.personRecord pr1 = new referralConversion_Controller.personRecord(pbs);

        }
    
    	Test.StopTest();
    }			
 
 public static Referral__c createReferral2(String recordType, string Status, string ReferralName, string State, ID pbs) {
         Service_location__c SL = new Service_location__c(name = '234', UniqueID__c ='234', FacilityID__c =234,Alias__c ='234',ProgramID__c ='234',Program__c='234', Service_value__c = 'CA-MNTR-SL-Rancho-IDD');
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