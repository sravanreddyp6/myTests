@isTest
public class referralResults_Controller_Test{
    static testMethod void test() {
        Person_Being_Referred__c pbr = Referral_CreateTestData.createPersonBeingReferred(25, null);
        Referral__c ref = Referral_CreateTestData.createReferral('Generic', 'New', 'Test123', pbr);
        
        PageReference pageRef = Page.referralSearch;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('referralId', ref.id);
        referralResults_Controller controller = new referralResults_Controller();
        system.assert(controller.personFirstName == 'Doug');
        controller.searchRefs();
        system.assert(controller.refResults.size() == 1);
        
        ApexPages.currentPage().getParameters().put('referralNumber', '111');
        ApexPages.currentPage().getParameters().put('firstName', 'Not found');
        ApexPages.currentPage().getParameters().put('lastName', 'Not found');
        ApexPages.currentPage().getParameters().put('dob', '1/1/1900');
        ApexPages.currentPage().getParameters().put('age', '99');
        controller = new referralResults_Controller();
        controller.searchRefs();
        system.assert(controller.refResults.size() == 1);
        
        ApexPages.currentPage().getParameters().put('pbrId', pbr.Id);
        controller = new referralResults_Controller();
        controller.searchRefs();
        system.debug( 'RESULT:' + Controller.refResults.size());
        system.assert(Controller.refResults.size() == 1);
        
        
        TMN_Generic_Core_TestData testPBS = new TMN_Generic_Core_TestData();
        Referral__c ref2 = createPBSRef('Generic', 'New', 'Test123', testPBS.ContactID);
        
        referralResults_Controller controller2 = new referralResults_Controller();
        controller2.personFirstName = testPBS.theAccount.firstName;
        controller2.personFirstName = testPBS.theAccount.lastName;
        controller2.searchRefs();
        system.assert(controller2.refResults.size() == 1);
    }
    
    
    static Referral__c createPBSRef( string RT, string status, string name, ID pbs) {
        Service_location__c SL = new Service_location__c(name = '123', UniqueID__c =String.valueOf(Math.abs(Math.random())), FacilityID__c =123,Alias__c ='123',ProgramID__c ='123',Program__c='123', service_value__c='CA-MNTR-SL-Rancho-IDD');
        insert SL;
        Referral__c ref = new Referral__c(RecordTypeId=Utility.getRecordTypeForReferral(RT),
                                          Referral_Status__c= status,
                                          Referral_Name__c= name,
                                          Service_location__c = SL.id,                                          
                                          Person_Being_served__c =pbs);
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
                               Staffing_Ratio__c, Person_Being_Served__c, Waiver_Funding_Source__c, Restricted_Health_Conditions__c, 
                               Registered_Sex_Offender__c, Current_Medical_Conditions__c, Services_Requested__c, Health_and_Safety_Needs__c, 
                               Anticipated_Job_Accomodations__c, Secondary_Diagnosis__c, Level_of_Disability__c, Date_of_Injury__c, 
                               Cause_of_Injury__c, Estimated_Discharge_Date__c, Referring_Physician__c, Current_Location__c, Referral_Source_Type__c, 
                               Referral_Name__c, Agency_Name__c, Referral_Phone_Number__c, Referral_Date__c, Prior_Program_Information__c, 
                               State_Specific_ID_Name__c, State_Specific_ID__c, Living_Environment__c, Mobility__c, Case_Manager_Name__c, 
                               Case_Manager_Phone__c, Close_Reason__c, Hold_Date__c, Hold_Reason__c, Program_Street_1__c, Program_Street_2__c, 
                               Program_City__c, Program_State__c, Program_Zip_Code__c, Accessible_Vehicle_Needed__c, Name_PBR__c, Review_On__c, 
                               RecordCount__c, Days_To_Convert_Referral__c, OldPBR__c, Assigned_Users__c, Service_Location_City__c, 
                               Service_Location_State__c, Service_Location_Zip__c, Service_Location_Street__c, Service_Location_Program__c 
                               from referral__c where Id = :ref.Id];
        return testRef;
    }

    
}