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
private class CredentialRecordHandlerTEST {

    static testMethod void myUnitTest() {
        // When a "Health Inspection" record is inserted or update for a MENTOR, update the Date_Most_Recent_HHSI__c field for ALL household members
        // with the value of the received date field for that Mentor's record.
        
        List<Credential_Profile__c> credProfsToInsert = new List<Credential_Profile__c>();
        Credential_Profile__c HealthInspection_Profile = new Credential_Profile__c(
        	Name = 'Health Inspection',
        	Required_for_Mentor__c = true,
        	PBI__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Household'
        );
        credProfsToInsert.add(HealthInspection_Profile);
        
        Credential_Profile__c HealthInspectionD2M_Profile = new Credential_Profile__c(
        	Name = 'Health Inspection-Due to Move',
        	Optional_for_Mentor__c = true,
        	PBI__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Household'
        );
        credProfsToInsert.add(HealthInspectionD2M_Profile);        
  
        Credential_Profile__c MedExam_Profile = new Credential_Profile__c(
        	Name = 'Medical Exam',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_Under_18__c = true,
        	Needed_for_18_Over__c = true,
        	PBI__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self'
        );
        credProfsToInsert.add(MedExam_Profile);  

        Credential_Profile__c CPS_Clearance_Profile = new Credential_Profile__c(
        	Name = 'CPS Clearance',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	PBI__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_CPS_Full_Disclosure__c = true,
        	Applies_Documented_Date__c = true,
        	Applies_Outcome_of_Clearance__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors'
        );
        credProfsToInsert.add(CPS_Clearance_Profile);
  
        Credential_Profile__c CPS_FullDisc_Profile = new Credential_Profile__c(
        	Name = 'CPS Full Disclosure',
        	Optional_for_Mentor__c = true,
        	Optional_for_Co_Applicant__c = true,
        	Optional_for_Foster_Parent_Relative__c = true,
        	Optional_for_Foster_Parent_Child__c = true,
        	Optional_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Documented_Date__c = true,
        	Applies_Outcome_of_Clearance__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors'
        );
        credProfsToInsert.add(CPS_FullDisc_Profile);  

        Credential_Profile__c FBI_Crim_Hx_Profile = new Credential_Profile__c(
        	Name = 'FBI Criminal History',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	PBI__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Conviction_Past_5_Federal__c = true,
        	Applies_Type_of_Conviction_Federal__c = true,
        	Applies_Federal_Conviction__c = true,
        	Applies_FBI_Full_Disclosure__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors'
        );
        credProfsToInsert.add(FBI_Crim_Hx_Profile);

        Credential_Profile__c FBI_Full_Disc_Profile = new Credential_Profile__c(
        	Name = 'FBI Full Disclosure',
        	Optional_for_Mentor__c = true,
        	Optional_for_Co_Applicant__c = true,
        	Optional_for_Foster_Parent_Relative__c = true,
        	Optional_for_Foster_Parent_Child__c = true,
        	Optional_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Conviction_Past_5_Federal__c = true,
        	Applies_Type_of_Conviction_Federal__c = true,
        	Applies_Federal_Conviction__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors'
        );
        credProfsToInsert.add(FBI_Full_Disc_Profile);

        Credential_Profile__c State_Crim_Hx_Profile = new Credential_Profile__c(
        	Name = 'State Criminal History',
        	Required_for_Mentor__c = true,
        	Required_for_Co_Applicant__c = true,
        	Required_for_Foster_Parent_Relative__c = true,
        	Required_for_Foster_Parent_Child__c = true,
        	Required_for_Resident_Non_Relative__c = true,
        	Needed_for_18_Over__c = true,
        	PBI__c = true,
        	Applies_Requested_Date__c = true,
        	Applies_Received_Date__c = true,
        	Applies_Note__c = true,
        	Applies_Conviction_Past_5_State__c = true,
        	Applies_Type_of_Conviction_State__c = true,
        	Applies_State_Conviction__c = true,
        	Applies_Documented_Date__c = true,
        	DHR_Scope__c = 'Self Adult, Mentor Minors'
        );
        credProfsToInsert.add(State_Crim_Hx_Profile);  

  		insert credProfsToInsert;
        
        List<Mentor_Tracking_Metadata__c> mtmListForInsert = new List<Mentor_Tracking_Metadata__c>();
        Mentor_Tracking_Metadata__c mtmHealthInspection = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = HealthInspection_Profile.Id,
        	Field_to_Update__c = 'Date_Most_Recent_HHSI__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Similar_Credentials__c = '{~}Health Inspection-Due to Move{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c'
        );
        mtmListForInsert.add(mtmHealthInspection);
        
        Mentor_Tracking_Metadata__c mtmHealthInspection2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = HealthInspection_Profile.Id,
        	Field_to_Update__c = 'Doc_of_Home_Safety_Inspection_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Similar_Credentials__c = '{~}Health Inspection-Due to Move{~}',
        	Credential_Record_Date_Field__c = 'Received_Date__c'
        );
        mtmListForInsert.add(mtmHealthInspection2);        

        Mentor_Tracking_Metadata__c mtmHealthInspectionD2M = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = HealthInspectionD2M_Profile.Id,
        	Field_to_Update__c = 'Date_Most_Recent_HHSI__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Similar_Credentials__c = '{~}Health Inspection{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c'
        );
        mtmListForInsert.add(mtmHealthInspectionD2M);

        Mentor_Tracking_Metadata__c mtmHealthInspectionD2M2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = HealthInspectionD2M_Profile.Id,
        	Field_to_Update__c = 'Doc_of_Home_Safety_Inspection_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Similar_Credentials__c = '{~}Health Inspection{~}',
        	Credential_Record_Date_Field__c = 'Received_Date__c'
        );
        mtmListForInsert.add(mtmHealthInspectionD2M2);

        Mentor_Tracking_Metadata__c mtmMedExam = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = MedExam_Profile.Id,
        	Field_to_Update__c = 'Date_Most_Recent_Med_Eval__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Credential_Record_Date_Field__c = 'Documented_Date__c'
        );
        mtmListForInsert.add(mtmMedExam);

        Mentor_Tracking_Metadata__c mtmMedExam2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = MedExam_Profile.Id,
        	Field_to_Update__c = 'Doc_of_Med_Eval_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Credential_Record_Date_Field__c = 'Received_Date__c'
        );
        mtmListForInsert.add(mtmMedExam2);

        Mentor_Tracking_Metadata__c mtmCpsClearance = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_Clearance_Profile.Id,
        	Field_to_Update__c = 'Date_Current_CPS_Clearance_Request__c',
        	Credential_Record_Source_Field__c = 'Requested_Date__c',
        	Similar_Credentials__c = '{~}CPS Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Requested_Date__c',
        	Superceded_By__c = CPS_FullDisc_Profile.Id
        );
        mtmListForInsert.add(mtmCpsClearance);

        Mentor_Tracking_Metadata__c mtmCpsClearance2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_Clearance_Profile.Id,
        	Field_to_Update__c = 'Doc_of_Current_CPS_Clearance_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Similar_Credentials__c = '{~}CPS Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Received_Date__c',
        	Superceded_By__c = CPS_FullDisc_Profile.Id
        );
        mtmListForInsert.add(mtmCpsClearance2);

        Mentor_Tracking_Metadata__c mtmCpsClearance3 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_Clearance_Profile.Id,
        	Field_to_Update__c = 'Date_Current_CPS_Clearance_Results__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Similar_Credentials__c = '{~}CPS Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = CPS_FullDisc_Profile.Id
        );
        mtmListForInsert.add(mtmCpsClearance3);

        Mentor_Tracking_Metadata__c mtmCpsClearance4 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_Clearance_Profile.Id,
        	Field_to_Update__c = 'Outcome_of_Clearance__c',
        	Credential_Record_Source_Field__c = 'Outcome_of_Clearance__c',
        	Similar_Credentials__c = '{~}CPS Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = CPS_FullDisc_Profile.Id
        );
        mtmListForInsert.add(mtmCpsClearance4);

        Mentor_Tracking_Metadata__c mtmCpsFullDisclosure = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_FullDisc_Profile.Id,
        	Field_to_Update__c = 'Date_Current_CPS_Clearance_Request__c',
        	Credential_Record_Source_Field__c = 'Requested_Date__c',
        	Similar_Credentials__c = '{~}CPS Clearance{~}',
        	Credential_Record_Date_Field__c = 'Requested_Date__c',
        	Supercedes__c = CPS_Clearance_Profile.Id
        );
        mtmListForInsert.add(mtmCpsFullDisclosure);

        Mentor_Tracking_Metadata__c mtmCpsFullDisclosure2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_FullDisc_Profile.Id,
        	Field_to_Update__c = 'Doc_of_Current_CPS_Clearance_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Similar_Credentials__c = '{~}CPS Clearance{~}',
        	Credential_Record_Date_Field__c = 'Received_Date__c',
        	Superceded_By__c = CPS_Clearance_Profile.Id
        );
        mtmListForInsert.add(mtmCpsFullDisclosure2);

        Mentor_Tracking_Metadata__c mtmCpsFullDisclosure3 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_FullDisc_Profile.Id,
        	Field_to_Update__c = 'Date_Current_CPS_Clearance_Results__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Similar_Credentials__c = '{~}CPS Clearance{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = CPS_Clearance_Profile.Id
        );
        mtmListForInsert.add(mtmCpsFullDisclosure3);

        Mentor_Tracking_Metadata__c mtmCpsFullDisclosure4 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = CPS_FullDisc_Profile.Id,
        	Field_to_Update__c = 'Outcome_of_Clearance__c',
        	Credential_Record_Source_Field__c = 'Outcome_of_Clearance__c',
        	Similar_Credentials__c = '{~}CPS Clearance{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = CPS_Clearance_Profile.Id
        );
        mtmListForInsert.add(mtmCpsFullDisclosure4);

        Mentor_Tracking_Metadata__c mtmFbiClearance = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Date_Fed_Crim_Background_Check_Request__c',
        	Credential_Record_Source_Field__c = 'Requested_Date__c',
        	Similar_Credentials__c = '{~}FBI Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Requested_Date__c',
        	Superceded_By__c = FBI_Full_Disc_Profile.Id
        );
        mtmListForInsert.add(mtmFbiClearance);

        Mentor_Tracking_Metadata__c mtmFbiClearance2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Date_Fed_Crim_Background_Check_Results__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Similar_Credentials__c = '{~}FBI Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = FBI_Full_Disc_Profile.Id
        );
        mtmListForInsert.add(mtmFbiClearance2);

        Mentor_Tracking_Metadata__c mtmFbiClearance3 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Doc_of_Fed_Crim_Background_Check_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Similar_Credentials__c = '{~}FBI Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Received_Date__c',
        	Superceded_By__c = FBI_Full_Disc_Profile.Id
        );
        mtmListForInsert.add(mtmFbiClearance3);

        Mentor_Tracking_Metadata__c mtmFbiClearance4 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Federal_Conviction__c',
        	Credential_Record_Source_Field__c = 'Federal_Conviction__c',
        	Similar_Credentials__c = '{~}FBI Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = FBI_Full_Disc_Profile.Id
        );
        mtmListForInsert.add(mtmFbiClearance4);

        Mentor_Tracking_Metadata__c mtmFbiClearance5 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Type_of_Conviction_Federal__c',
        	Credential_Record_Source_Field__c = 'Type_of_Conviction_Federal__c',
        	Similar_Credentials__c = '{~}FBI Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = FBI_Full_Disc_Profile.Id
        );
        mtmListForInsert.add(mtmFbiClearance5);

        Mentor_Tracking_Metadata__c mtmFbiClearance6 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Conviction_Past_5_Years__c',
        	Credential_Record_Source_Field__c = 'Conviction_Past_5_Years__c',
        	Similar_Credentials__c = '{~}FBI Full Disclosure{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Superceded_By__c = FBI_Full_Disc_Profile.Id,
        	Parallel_Credentials__c = 'FBI Full Disclosure{~}State Criminal History{~}',
        	Parallel_Credentials_Operator__c = 'OR',
        	Parallel_Credentials_Type__c = 'Yes/No'
        );
        mtmListForInsert.add(mtmFbiClearance6);

        Mentor_Tracking_Metadata__c mtmFbiFullDisc = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Full_Disc_Profile.Id,
        	Field_to_Update__c = 'Date_Fed_Crim_Background_Check_Request__c',
        	Credential_Record_Source_Field__c = 'Requested_Date__c',
        	Similar_Credentials__c = '{~}FBI Criminal History{~}',
        	Credential_Record_Date_Field__c = 'Requested_Date__c',
        	Supercedes__c = FBI_Crim_Hx_Profile.Id
        );
        mtmListForInsert.add(mtmFbiFullDisc);

        Mentor_Tracking_Metadata__c mtmFbiFullDisc2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Full_Disc_Profile.Id,
        	Field_to_Update__c = 'Date_Fed_Crim_Background_Check_Results__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Similar_Credentials__c = '{~}FBI Criminal History{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Supercedes__c = FBI_Crim_Hx_Profile.Id
        );
        mtmListForInsert.add(mtmFbiFullDisc2);

        Mentor_Tracking_Metadata__c mtmFbiFullDisc3 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Full_Disc_Profile.Id,
        	Field_to_Update__c = 'Doc_of_Fed_Crim_Background_Check_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Similar_Credentials__c = '{~}FBI Criminal History{~}',
        	Credential_Record_Date_Field__c = 'Received_Date__c',
        	Supercedes__c = FBI_Crim_Hx_Profile.Id
        );
        mtmListForInsert.add(mtmFbiFullDisc3);

        Mentor_Tracking_Metadata__c mtmFbiFullDisc4 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Full_Disc_Profile.Id,
        	Field_to_Update__c = 'Federal_Conviction__c',
        	Credential_Record_Source_Field__c = 'Federal_Conviction__c',
        	Similar_Credentials__c = '{~}FBI Criminal History{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Supercedes__c = FBI_Crim_Hx_Profile.Id
        );
        mtmListForInsert.add(mtmFbiFullDisc4);

        Mentor_Tracking_Metadata__c mtmFbiFullDisc5 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Full_Disc_Profile.Id,
        	Field_to_Update__c = 'Type_of_Conviction_Federal__c',
        	Credential_Record_Source_Field__c = 'Type_of_Conviction_Federal__c',
        	Similar_Credentials__c = '{~}FBI Criminal History{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Supercedes__c = FBI_Crim_Hx_Profile.Id
        );
        mtmListForInsert.add(mtmFbiFullDisc5);

        Mentor_Tracking_Metadata__c mtmFbiFullDisc6 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = FBI_Full_Disc_Profile.Id,
        	Field_to_Update__c = 'Conviction_Past_5_Years__c',
        	Credential_Record_Source_Field__c = 'Conviction_Past_5_Years__c',
        	Similar_Credentials__c = '{~}FBI Criminal History{~}',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Supercedes__c = FBI_Crim_Hx_Profile.Id,
        	Parallel_Credentials__c = 'FBI Criminal History{~}State Criminal History{~}',
        	Parallel_Credentials_Operator__c = 'OR',
        	Parallel_Credentials_Type__c = 'Yes/No'
        );
        mtmListForInsert.add(mtmFbiFullDisc6);

        Mentor_Tracking_Metadata__c mtmStateCrimHx = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = State_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Date_State_Crim_Background_Check_Request__c',
        	Credential_Record_Source_Field__c = 'Requested_Date__c',
        	Credential_Record_Date_Field__c = 'Requested_Date__c'
        );
        mtmListForInsert.add(mtmStateCrimHx);

        Mentor_Tracking_Metadata__c mtmStateCrimHx2 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = State_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Date_State_Crim_Background_Check_Results__c',
        	Credential_Record_Source_Field__c = 'Documented_Date__c',
        	Credential_Record_Date_Field__c = 'Documented_Date__c'
        );
        mtmListForInsert.add(mtmStateCrimHx2);

        Mentor_Tracking_Metadata__c mtmStateCrimHx3 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = State_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Doc_of_State_Crim_Bckgrnd_Check_in_File__c',
        	Credential_Record_Source_Field__c = 'In_File__c',
        	Credential_Record_Date_Field__c = 'Received_Date__c'
        );
        mtmListForInsert.add(mtmStateCrimHx3);

        Mentor_Tracking_Metadata__c mtmStateCrimHx4 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = State_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'State_Conviction__c',
        	Credential_Record_Source_Field__c = 'State_Conviction__c',
        	Credential_Record_Date_Field__c = 'Documented_Date__c'
        );
        mtmListForInsert.add(mtmStateCrimHx4);

        Mentor_Tracking_Metadata__c mtmStateCrimHx5 = new Mentor_Tracking_Metadata__c(
        	Report__c = 'DHR CPA',
        	Credential_Profile__c = State_Crim_Hx_Profile.Id,
        	Field_to_Update__c = 'Conviction_Past_5_Years__c',
        	Credential_Record_Source_Field__c = 'Conviction_Past_5_Years__c',
        	Credential_Record_Date_Field__c = 'Documented_Date__c',
        	Parallel_Credentials__c = 'FBI Criminal History{~}FBI Full Disclosure{~}',
        	Parallel_Credentials_Operator__c = 'OR',
        	Parallel_Credentials_Type__c = 'Yes/No'
        );
        mtmListForInsert.add(mtmStateCrimHx5);
               
        insert mtmListForInsert;
        
        List<TMN_Contact__c> tmnContactListForInsert = new List<TMN_Contact__c>();
        TMN_Contact__c myTmnContact = new TMN_Contact__c(
        	First_Name__c = 'Test',
        	Last_Name__c = 'Mentor',
        	Chessie_Id__c = '12345',
        	Date_of_Birth__c = Date.newInstance(1977,5,4),
        	Marital_Status__c = 'Married',
        	Race__c = 'Multi-Racial',
        	Street_1__c = '123 Whatever St.',
        	Street_2__c = 'Apt. 1A',
        	City__c = 'Louisville',
        	State__c = 'KY',
        	Primary_Phone__c = '502-618-1548',
        	Secondary_Phone__c = '919-333-1425',
        	In_Progress__c = true,
        	In_Progress_Date__c = Date.newInstance(2014,2,1)
        );
        //tmnContactListForInsert.add(myTmnContact);
        insert myTmnContact;
        
        List<RecordType> allTmnContactRecordTypes = [ SELECT DeveloperName FROM RecordType WHERE SObjectType = 'TMN_Contact__c' ];
        for(RecordType rT : allTmnContactRecordTypes) {
        	System.debug('rT.DeveloperName: ' + rT.DeveloperName);
        }
        
        RecordType householdMemberRecordType = [ SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'TMN_Contact__c' AND DeveloperName = 'Household_Member' LIMIT 1 ];
        System.debug('householdMemberRecordType.DeveloperName: ' + householdMemberRecordType.DeveloperName);
        
        TMN_Contact__c myCoApplicant = new TMN_Contact__c(
        	RecordTypeId = householdMemberRecordType.Id,
        	Related_Party_Type__c = 'Co-Applicant',
        	Mentor__c = myTmnContact.Id,
        	First_Name__c = 'Test',
        	Last_Name__c = 'Co Applicant',
        	Chessie_Id__c = '12346',
        	Date_of_Birth__c = Date.newInstance(1978,12,16),
        	Marital_Status__c = 'Married',
        	Race__c = 'Multi-Racial',
        	Street_1__c = '123 Whatever St.',
        	Street_2__c = 'Apt. 1A',
        	City__c = 'Louisville',
        	State__c = 'KY',
        	Primary_Phone__c = '502-555-5555',
        	Secondary_Phone__c = '502-555-5556',
        	Email__c = 'test@test.com'      	
        );
		tmnContactListForInsert.add(myCoApplicant);        

        TMN_Contact__c myFosterParentChildUnder18 = new TMN_Contact__c(
        	RecordTypeId = householdMemberRecordType.Id,
        	Related_Party_Type__c = 'Foster Parent\'s Child',
        	Mentor__c = myTmnContact.Id,
        	First_Name__c = 'Test',
        	Last_Name__c = 'Co Applicant',
        	Chessie_Id__c = '12346',
        	Date_of_Birth__c = Date.newInstance(2008,12,16),
        	Marital_Status__c = 'Married',
        	Race__c = 'Multi-Racial',
        	Street_1__c = '123 Whatever St.',
        	Street_2__c = 'Apt. 1A',
        	City__c = 'Louisville',
        	State__c = 'KY',
        	Primary_Phone__c = '502-555-5555',
        	Secondary_Phone__c = '502-555-5556',
        	Email__c = 'test@test.com'      	
        );
		tmnContactListForInsert.add(myFosterParentChildUnder18);

        insert tmnContactListForInsert;
        
        Credential_Record__c myCredRec = [ SELECT Id, Name FROM Credential_Record__c WHERE Credential_Profile__r.Name = 'Health Inspection' AND TMN_Contact__c = :myTmnContact.Id ];
        
        List<Mentor_Tracking_Report_Record__c> allMentorTrackingReportRecords = [ SELECT Id, Name, TMN_Contact__r.RecordType.DeveloperName FROM Mentor_Tracking_Report_Record__c ];
        System.assert(allMentorTrackingReportRecords.size()==3, 'The number of Mentor_Tracking_Report_Record__c records is expected to be 3, but it is actually ' + allMentorTrackingReportRecords.size() + '.');
        List<Mentor_Tracking_Report_Record__c> nonMentorMtms = new List<Mentor_Tracking_Report_Record__c>();
        for(Mentor_Tracking_Report_Record__c mtm : allMentorTrackingReportRecords) {
        	if(mtm.TMN_Contact__r.RecordType.DeveloperName!='Mentor') {
        		nonMentorMtms.add(mtm);
        	}
        }
        System.assert(nonMentorMtms.size()==2, 'The number of non-mentor Mentor_Tracking_Report_Record__c records is expected to be 2, but it is actually ' + nonMentorMtms.size()==2 + '.');
        
        
        Mentor_Tracking_Report_Record__c myReptRec = new Mentor_Tracking_Report_Record__c();
        myReptRec = [ SELECT Id, Name, Date_Most_Recent_HHSI__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__c = :myTmnContact.Id ];
        
        System.assert(myReptRec.Date_Most_Recent_HHSI__c==null,'There is a value for Date_Most_Recent_HHSI__c, but should not be, on TMN_Contact__c insert,');
        
        myCredRec.Documented_Date__c = Date.newInstance(2014,2,1);
        update myCredRec;
        
        myReptRec = [ SELECT Id, Name, Date_Most_Recent_HHSI__c FROM Mentor_Tracking_Report_Record__c WHERE TMN_Contact__c = :myTmnContact.Id ];
        
        System.assert(myReptRec.Date_Most_Recent_HHSI__c==Date.newInstance(2014,2,1),'After test update, the value for Date_Most_Recent_HHSI__c on the Mentor\' record is expected to be 2-1-14, but it is not.');

		Credential_Record__c addedHealthInspectionD2M = new Credential_Record__c (
			Credential_Profile__c = HealthInspectionD2M_Profile.Id,
			TMN_Contact__c = myTmnContact.Id
		);
		insert addedHealthInspectionD2M;
		
		addedHealthInspectionD2M.Documented_Date__c = Date.newInstance(2014,3,1);
		update addedHealthInspectionD2M;


		Credential_Record__c addedFbiFullDisc = new Credential_Record__c (
			Credential_Profile__c = FBI_Full_Disc_Profile.Id,
			TMN_Contact__c = myTmnContact.Id
		);
		insert addedFbiFullDisc;

		List<Credential_Record__c> credRecsToUpdate = new List<Credential_Record__c>();
				
		Credential_Record__c updateToSelfAdultMentorMinorsCred = [ SELECT Id FROM Credential_Record__c WHERE TMN_Contact__c = :myTmnContact.Id AND Credential_Profile__r.Name = 'CPS Clearance' LIMIT 1 ];
		updateToSelfAdultMentorMinorsCred.Requested_Date__c = date.newInstance(2014, 3, 3);
		updateToSelfAdultMentorMinorsCred.Received_Date__c = date.newInstance(2014, 3, 4);
		updateToSelfAdultMentorMinorsCred.Documented_Date__c = date.newInstance(2014, 3, 5);
		credRecsToUpdate.add(updateToSelfAdultMentorMinorsCred);

		Credential_Record__c updateToNonMentorCred = [ SELECT Id FROM Credential_Record__c WHERE TMN_Contact__c = :myFosterParentChildUnder18.Id AND Credential_Profile__r.Name = 'Medical Exam' LIMIT 1 ];
		System.debug('updateToNonMentorCred: ' + updateToNonMentorCred);
		updateToNonMentorCred.Received_Date__c = date.newInstance(2014, 3, 6);
		updateToNonMentorCred.Documented_Date__c = date.newInstance(2014, 3, 7);
		credRecsToUpdate.add(updateToNonMentorCred);		

		Credential_Record__c updateToFbiCrimHx = [ SELECT Id FROM Credential_Record__c WHERE TMN_Contact__c = :myTmnContact.Id AND Credential_Profile__r.Name = 'FBI Criminal History' LIMIT 1 ];
		updateToFbiCrimHx.Requested_Date__c = date.newInstance(2014, 3, 8);
		updateToFbiCrimHx.Received_Date__c = date.newInstance(2014, 3, 9);
		updateToFbiCrimHx.Documented_Date__c = date.newInstance(2014, 3, 10);
		updateToFbiCrimHx.Federal_Conviction__c = 'Yes';
		updateToFbiCrimHx.Type_of_Conviction_Federal__c = 'Test Fed Conviction Type';
		updateToFbiCrimHx.Conviction_Past_5_Years_Federal__c = 'Yes';
		credRecsToUpdate.add(updateToFbiCrimHx);	

		Credential_Record__c updateToFbiFullDisc = [ SELECT Id FROM Credential_Record__c WHERE TMN_Contact__c = :myTmnContact.Id AND Credential_Profile__r.Name = 'FBI Full Disclosure' LIMIT 1 ];
		updateToFbiFullDisc.Requested_Date__c = date.newInstance(2014, 3, 11);
		updateToFbiFullDisc.Received_Date__c = date.newInstance(2014, 3, 12);
		updateToFbiFullDisc.Documented_Date__c = date.newInstance(2014, 3, 13);
		updateToFbiFullDisc.Federal_Conviction__c = 'Yes';
		updateToFbiFullDisc.Type_of_Conviction_Federal__c = 'Test Fed Conviction Type 2';
		updateToFbiFullDisc.Conviction_Past_5_Years_Federal__c = 'Yes';
		credRecsToUpdate.add(updateToFbiFullDisc);

		Credential_Record__c updateToStateCrimHx = [ SELECT Id FROM Credential_Record__c WHERE TMN_Contact__c = :myTmnContact.Id AND Credential_Profile__r.Name = 'State Criminal History' LIMIT 1 ];
		updateToStateCrimHx.Requested_Date__c = date.newInstance(2014, 3, 14);
		updateToStateCrimHx.Received_Date__c = date.newInstance(2014, 3, 15);
		updateToStateCrimHx.Documented_Date__c = date.newInstance(2014, 3, 16);
		updateToStateCrimHx.State_Conviction__c = 'Yes';
		updateToStateCrimHx.Conviction_Past_5_Years_State__c = 'Yes';
		credRecsToUpdate.add(updateToStateCrimHx);
		
		update credRecsToUpdate;

		updateToStateCrimHx.Requested_Date__c = date.newInstance(2014, 2, 14);
		updateToStateCrimHx.Received_Date__c = date.newInstance(2014, 2, 15);
		updateToStateCrimHx.Documented_Date__c = date.newInstance(2014, 2, 16);
		update updateToStateCrimHx;

		delete myCredRec;
		undelete myCredRec;
		
		CredentialRecordHandler myObj = new CredentialRecordHandler(true);
		Boolean myBoolean = myObj.IsTriggerContext;
        
    }
}