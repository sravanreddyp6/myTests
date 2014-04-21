/*
Created By     : Doug Surfleet (Appirio)
Updated Date   : April 24, 2013
Description    : Object to create test data for Referrals objects
*/
public without sharing class Referral_CreateTestData {

public static Id getAccountRecordType(){
    List<RecordType> RecTypes= [SELECT Id, Name from recordtype where SobjectType = 'Account' and IsPersonType = true and IsActive = true and Name = 'Person Being Served'];
    return RecTypes[0].id;
  }
  public static Account getAccount(){
    Date myDate = date.newinstance(1960, 2, 17);
    Account Accnt = new Account(
            RecordTypeID=getAccountRecordType(),
            FirstName= 'Test-' + EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,5).toUpperCase(),
            LastName='Test-' + EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,5).toUpperCase(),
            PersonMailingStreet= EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,5).toUpperCase() + '_test@yahoo.com',
            PersonBirthdate = myDate,
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonMailingStateCode='NC',
            PersonEmail=EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1,5).toUpperCase() + '_test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678'
        );
        insert Accnt;
        List<Account> testAcct = [Select Id, PersonContactId, RecordTypeID From Account a WHERE a.Id = :Accnt.Id];
        return testAcct[0];
  }
    public static Person_Being_Referred__c createPersonBeingReferred(double age, Date dob) {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        pbr.First_Name__c = 'Doug';
        pbr.Last_Name__c = 'Surfleet';
        if (age != null && age > 0) {
            pbr.Age__c = age;
        }
        if (dob != null) {
            pbr.Date_of_Birth__c = dob;
        }
        pbr.Gender__c = 'Male';
        insert pbr;
        Person_Being_Referred__c testPBR = [Select Id, First_Name__c, Last_Name__c, Age__c, Date_of_Birth__c From Person_Being_Referred__c a WHERE a.Id = :pbr.Id];
        return testPBR;
    }
    
    public static Related_Party__c createRelatedParty(String partyName, String partyType, Person_Being_Referred__c pbr) {
        Related_Party__c rp = new Related_Party__c(Name = partyName, Type__c = partyType, Address__c = '123 Test Rd',
                                                   Person_Being_Referred__c = pbr.Id);
        insert rp;
        Related_Party__c testRP = [Select Id, Name, Type__c, Address__c From Related_Party__c a WHERE a.Id = :rp.Id];
        return testRP;
    }
    
    public static Referral__c createReferral(String recordType, string Status, string ReferralName, Person_Being_Referred__c pbr) {
       return createReferral(recordType, Status, ReferralName, '', pbr); 
    }
    
    public static Referral__c createReferral(String recordType, string Status, string ReferralName, string State, Person_Being_Referred__c pbr) {
        Referral__c ref = new Referral__c(RecordTypeId=Utility.getRecordTypeForReferral(recordType),
                                          Referral_Status__c=Status,
                                          Referral_Name__c=ReferralName,
                                          Person_Being_Referred__c=pbr.Id);
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
                               Service_Location_State__c, Service_Location_Zip__c, Service_Location_Street__c, Service_Location_Program__c 
                               from referral__c where Id = :ref.Id];
        return testRef;
    }
    
    public static Referral_Location__c createReferralLocation(String name, String location, string Status, User userAssigned, Referral__c ref ) {
    	
    	String tmp = String.ValueOf(System.currentTimeMillis());
    	
    	Service_Location__c svcLoc = new Service_Location__c (
        		Zip__c = '90021', 
        		UniqueID__c = '1001' + tmp.Substring(tmp.length()-6, tmp.length()-1), 
    			Street__c = '10 Main St.', 
    			State__c = 'CA', 
    			Setting__c = 'Residential',
    			Service_Value__c = 'IDD', 
    			Program__c = 'Redwood Res', 
    			ProgramID__c = '1000', 
    			Phone__c = '213-555-5555',
				FacilityID__c = 10,
				City__c = 'Bakersfield',
				Alias__c = '10101' + tmp.Substring(tmp.length()-6, tmp.length()-1)
	        );
	   insert svcLoc;
	   system.debug('NEW ALIAS = ' +  svcLoc.Id);      
       Referral_Location__c loc = new Referral_Location__c(Name=name, Location__c=location, Status__c=status,Referral__c=ref.ID, user_assigned__c=userAssigned.Id, Service_Location__c=svcLoc.Id);
        insert loc;
       Referral_Location__c testLoc = [Select Id, Name, Status__c, Location__c, Service_Location__c, user_assigned__c From Referral_Location__c a WHERE a.Id = :loc.Id];
        return testLoc; 
    }
    
    public static Agency_Involved_With_Individual__c createAgencyInvolved(string name, 
                                                                          string agencyReason, Referral__c ref) {
        Agency_Involved_With_Individual__c ag = new Agency_Involved_With_Individual__c(Name=name,Reason_for_Involvement__c=agencyReason,
                                                              Referral__c=ref.Id);
        insert ag;
        Agency_Involved_With_Individual__c testAG = [SELECT Id, Name, Referral__c, Address__c, Phone__c, Reason_for_Involvement__c 
                                            from Agency_Involved_With_Individual__c where Id=:ag.Id]; 
        return testAG;                                                                  
    }
    
    public static Funding_Source__c createFundingSource(string recordType, string Source, string SourceId, string Status, 
                                                        string Service, string Comment, Referral__c ref) {
        Funding_Source__c fund = new Funding_Source__c(RecordTypeId=Utility.getRecordTypeForFundingSource(recordType),
                                                      Service_Being_Funded__c=Service, Funding_Source_Id__c=SourceId,
                                                      Status__c = Status,Comment__c=Comment, Referral__c=ref.Id,
                                                      Funding_Source__c=Source);                               
        insert fund;
        Funding_Source__c testFund = [SELECT Id, Name, RecordTypeId, Service_Being_Funded__c, 
                                      Comment__c, Referral__c, Service_Being_Funded_String__c, 
                                      Funding_Source__c, Status__c, Funding_Source_ID__c, Status_String__c 
                                      FROM Funding_Source__c Where Id=:fund.Id];
        return testFund;
    }
    
    public static Task createReferralTask(string taskSubject, string taskPriority, string taskStatus, 
                                          User taskOwner, Date taskDate, string taskComments, Referral__c ref) {
        Task tsk = New Task(WhatId=ref.id, OwnerId=taskOwner.Id, Status=taskStatus, Subject=taskSubject, 
                      Priority=taskPriority, ActivityDate=taskDate, 
                      Comments__c=taskComments, recordTypeID=Utility.getRecordTypeForTask('Referral Tasks'));
        insert tsk;
        Task testTask = [select Id, Subject, Priority, Status, WhatId, OwnerId, Owner.Name,ActivityDate, Comments__c
                         from Task where Id = :tsk.Id];
        return testTask;
    }
    
    public static Service_Location__c createServiceLocation(string alias) {
        Service_Location__c loc = new Service_Location__c(Alias__c = alias, UniqueID__c = alias, FacilityID__c=1,ProgramID__c=alias, Program__c=alias);
        insert loc;
        Service_Location__c testLoc = [SELECT Id, Name, CreatedDate, UniqueID__c, FacilityID__c, Alias__c, ProgramID__c, Program__c, Street__c, City__c, 
                                       State__c, Zip__c, Phone__c, Service_Value__c, Setting__c from service_location__c];
        return testLoc;
    }
    
    public static List<Service_Location__c> createServiceLocations(string alias,Integer n) {
        List<Service_Location__c> l = new List<Service_Location__c>();
        for(Integer k=0; k<n; k++){
            l.add(new Service_Location__c(Alias__c = alias+String.valueof(k), UniqueID__c = alias+String.valueof(k), FacilityID__c=1,ProgramID__c=alias+String.valueof(k), Program__c=alias+String.valueof(k)));
        }
        insert l;
        
        return [SELECT Id, Name, CreatedDate, UniqueID__c, FacilityID__c, Alias__c, ProgramID__c, Program__c, Street__c, City__c, 
                                       State__c, Zip__c, Phone__c, Service_Value__c, Setting__c from service_location__c where Id in :l];
    }
    
    public static User createTestUser(string userAlias, string userName) {
        return createTestUser(userAlias,userName, 'Test', 'Testing');
    }
    
    public static User createTestUser(string userAlias, string userName, string firstName, string lastName) {
       return createTestUser(userAlias,userName, firstName, lastName, 'Redwood');
    }

    public static User createTestUser(string userAlias, string userName, string firstName, string lastName, string OperatingGroup) {
         Profile prof = [select id, name from Profile where name ='System Administrator'];
        User testUser = new User(alias = userAlias,
                                email='dsurfleet@appirio.com',
                                emailencodingkey='UTF-8',
                                lastname=lastName,firstname=firstName, languagelocalekey='en_US',
                                localesidkey='en_US',
                                profileid = prof.Id,
                                timezonesidkey='America/Los_Angeles',
                                username=username + System.currentTimeMillis());/*,
                                operating_group__c=OperatingGroup);*/
        insert testUser;
        
        Tmn_User__c tmnUser= new Tmn_User__c(operating_group__c=OperatingGroup, Salesforce_User_Account__c=testUser.id);
        insert tmnUser;
        
        return testUser;
    }
}