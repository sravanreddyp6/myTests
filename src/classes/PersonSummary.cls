public with sharing class PersonSummary {
    private Id pbsId;
    private Service_Assignment__c sa;
    public Service_Assignment__c getSa(){return sa;}
    private Contact contact;
    public Contact getContact(){return contact;}
    private list<RelatedPartyWrapper> serviceProviders = new list<RelatedPartyWrapper>();
    public list<RelatedPartyWrapper> getServiceProviders(){return serviceProviders;}
    private list<RelatedPartyWrapper> emergencyContacts = new list<RelatedPartyWrapper>();
    public list<RelatedPartyWrapper> getEmergencyContacts(){return emergencyContacts;}
    
    private static final set<String> SERVICE_PROVIDER_TYPES = new set<String>{'Physician - Primary','Physician - Alternate','Referring Provider','Medical','Mentor','Financial Worker','Case Manager'}; 
    private static final set<String> EMERGENCY_CONTACT_TYPES = new set<String>{'Guardian','Spouse','Parent','Family/Friends','Caregiver','Other'};
    private static final list<String> FUNDING_SOURCE_FIELDS = new list<String>{'Type_of_Coverage__c','Payer_Name__c','Policy_Type__c','TPA__c','TPA_Phone__c','Primary_Med_Ind_Phys_Group__c',
                                                                  'Primary_Med_Ind_Phys_Group_Phone__c','Network__c','Network_Phone__c','Verified_By__c','Payer_Verification_Date__c','Verified_With__c','Representing__c',
                                                                  'Funding_Source__c','Call_Reference_Number__c', 'Policy_Number__c','Group_Name__c','Group_Number__c','Policy_Holder__c','Relationship_To_Patient__c',
                                                                  'More_than_1_5_Yrs_of_Disability__c','Patient_Over_64_Years_of_Age__c','Comment__c'};
    public list<String> getFsFlds(){return FUNDING_SOURCE_FIELDS;}
    private static map<String, Integer> relPartyRank = new map<String, Integer>();
    private static map<String, String> fundingSrcFldLbls = new map<String, String>();
    public map<String, String> getFundingSrcFldLbls(){return fundingSrcFldLbls;}    
    private map<String, Object> fundingSrcFldVals = new map<String, Object>();
    public map<String, Object> getFundingSrcFldVals(){return fundingSrcFldVals;}
    public String fundingSrcFldValsKeys {get;set;}
    
    {   relPartyRank.put('Physician - Primary', 1);
        relPartyRank.put('Physician - Alternate', 2);
        relPartyRank.put('Referring Provider', 3);
        relPartyRank.put('Medical', 4);
        relPartyRank.put('Mentor', 5);
        relPartyRank.put('Financial Worker', 6);
        relPartyRank.put('Case Manager', 7);
        relPartyRank.put('Guardian', 8);
        relPartyRank.put('Spouse', 9);
        relPartyRank.put('Parent', 10);
        relPartyRank.put('Family/Friends', 11);
        relPartyRank.put('Caregiver', 12);
        relPartyRank.put('Other', 13); 

        fundingSrcFldLbls.put('Type_of_Coverage__c', '');
        fundingSrcFldLbls.put('Payer_Name__c', '');
        fundingSrcFldLbls.put('Policy_Type__c', 'Policy Type');
        fundingSrcFldLbls.put('Payer_Phone__c', 'Payer Phone');
        fundingSrcFldLbls.put('Claims_Submission_Company__c', 'Claims Submission');
        fundingSrcFldLbls.put('Claims_Submission_Street_1__c', 'Street 1');
        fundingSrcFldLbls.put('Claims_Submission_Street_2__c', 'Street 2');
        fundingSrcFldLbls.put('Claims_Submission_City__c', 'City');
        fundingSrcFldLbls.put('Claims_Submission_State__c', 'State');
        fundingSrcFldLbls.put('Claims_Submission_Zip__c', 'Zip');
        fundingSrcFldLbls.put('TPA__c', 'TPA');
        fundingSrcFldLbls.put('TPA_Phone__c', 'TPA Phone');
        fundingSrcFldLbls.put('Primary_Med_Ind_Phys_Group__c', 'Primary Med/Ind Phys Group');
        fundingSrcFldLbls.put('Primary_Med_Ind_Phys_Group_Phone__c', 'Primary Med/Ind Phys Group Phone');
        fundingSrcFldLbls.put('Network__c', 'Network');
        fundingSrcFldLbls.put('Network_Phone__c', 'Network Phone');
        fundingSrcFldLbls.put('Verified_By__c', 'Verify By');
        fundingSrcFldLbls.put('Payer_Verification_Date__c', 'Payer Verification Date');
        fundingSrcFldLbls.put('Verified_With__c', 'Verify With');
        fundingSrcFldLbls.put('Representing__c', 'Representing (Payer)'); 
        fundingSrcFldLbls.put('Funding_Source__c', 'Payer Type');
        fundingSrcFldLbls.put('Call_Reference_Number__c', ''); 
        fundingSrcFldLbls.put('Policy_Number__c', 'Policy ID #');
        fundingSrcFldLbls.put('Group_Name__c', 'Group Name');
        fundingSrcFldLbls.put('Group_Number__c', 'Group Number');
        fundingSrcFldLbls.put('Policy_Holder__c', 'Policy Holder');
        fundingSrcFldLbls.put('Relationship_To_Patient__c', 'Relationship to Patient');
        fundingSrcFldLbls.put('More_than_1_5_Yrs_of_Disability__c', 'Medicare Eligibility'); 
        fundingSrcFldLbls.put('Patient_Over_64_Years_of_Age__c', 'Medicare Eligibility');
        fundingSrcFldLbls.put('Comment__c', 'Additional Comment');
    }
    
    public boolean getIsRwStatePersonSummary(){
        if (PersonalRecordController.RW_STATES_FOR_PERSON_SUMMARY.contains(sa.Service_location__r.State__c.toUpperCase()) && sa.Service_location__r.Network_Offering__c.equalsIgnoreCase('IDD')) return true;
        else return false;
    }

    
    public PersonSummary(){
        try {
            this.pbsId = ApexPages.CurrentPage().getParameters().get('Id');
            if (this.pbsId == null || pbsId.getSObjectType().getDescribe().getName() != 'Contact')
                throw new InvalidPbsException('Person being served does not exists.');
            
            List<Service_Assignment__c> saList = [SELECT Id,Status__c FROM Service_Assignment__c WHERE Person_Being_Served__c = : pbsId
                                                 And Status__c = 'Active' order by SA_Start_DateTime__c desc NULLS LAST limit 1 ];

            if (saList.size() > 0) {
                sa = [  select  id,
                            person_being_served__r.LastName,
                            person_being_served__r.FirstName, 
                            person_being_served__r.Middle_Name__c,
                            Service_Location__r.Name,
                            Service_Location__r.Street__c,
                            Service_Location__r.City__c,
                            Service_Location__r.State__c,
                            Service_Location__r.Zip__c,
                            Service_Location__r.Setting__c,
                            Service_Location__r.Phone__c,
                            Service_Location__r.Network_Offering__c,
                            Service_Location__r.Location_Nickname__c,
                                                
                            person_being_served__r.PBS_Identifier__c,
                            person_being_served__r.Birthdate, 
                            person_being_served__r.Ethnicity_Picklist__c,
                            person_being_served__r.Primary_Language__c,
                            person_being_served__r.Non_Verbal__c,
                            person_being_served__r.Sign_Language__c,
                            person_being_served__r.Marital_Status__c,
                            person_being_served__r.Gender__c,
                            person_being_served__r.Age_Text__c, 
                            person_being_served__r.Age__c, 
                            (select Primary_Diagnosis__c from Diagnoses__r order by Effective_Date__c desc NULLS LAST limit 1),
                            person_being_served__r.MailingStreet,
                            person_being_served__r.MailingCity, 
                            person_being_served__r.MailingStateCode,
                            person_being_served__r.MailingPostalCode,
                            person_being_served__r.Flavor__c,
                            person_being_served__r.Phone,
                            person_being_served__r.HomePhone,
                            person_being_served__r.otherPhone,
                            Admission__r.Admission_Effective_DateTime__c,
                            Referral__r.Referral_Source_Type__c,
                            Referral__r.Agency_Name__c,
                            Referral__r.Reason_for_Referral__c,
                            
                            person_being_served__r.Code_Status__c,
                            person_being_served__r.Code_Status_Other__c,
                            person_being_served__r.Advanced_Directives__c,
                            person_being_served__r.Advanced_Directives_Attached__c,
                            
                            (select Type_of_Coverage__c, Payer_Name__c, Policy_Type__c, Payer_Phone__c, TPA__c, TPA_Phone__c, Primary_Med_Ind_Phys_Group__c, Primary_Med_Ind_Phys_Group_Phone__c,
                            Network__c, Network_Phone__c, Verified_By__c, Payer_Verification_Date__c, Verified_With__c, Representing__c, 
                            Funding_Source__c, Call_Reference_Number__c, Policy_Number__c, Group_Name__c, Group_Number__c, Policy_Holder__c, Relationship_To_Patient__c,
                            More_than_1_5_Yrs_of_Disability__c, Patient_Over_64_Years_of_Age__c, Comment__c, Claims_Submission_Company__c, Claims_Submission_Street_1__c, 
                            Claims_Submission_Street_2__c, Claims_Submission_City__c, Claims_Submission_State__c, Claims_Submission_Zip__c
                            from Funding_Sources__r order by lastModifiedDate desc NULLS LAST limit 1)
                    from    Service_Assignment__c
                    where   Person_Being_Served__c = : pbsId
                    And     Status__c = 'Active'
                    order   by SA_Start_DateTime__c desc NULLS LAST limit 1];                 
            } else {
                sa = [  select  id,
                            person_being_served__r.LastName,
                            person_being_served__r.FirstName, 
                            person_being_served__r.Middle_Name__c,
                            Service_Location__r.Name,
                            Service_Location__r.Street__c,
                            Service_Location__r.City__c,
                            Service_Location__r.State__c,
                            Service_Location__r.Zip__c,
                            Service_Location__r.Setting__c,
                            Service_Location__r.Phone__c,
                            Service_Location__r.Network_Offering__c,
                            Service_Location__r.Location_Nickname__c,
                                                
                            person_being_served__r.PBS_Identifier__c,
                            person_being_served__r.Birthdate, 
                            person_being_served__r.Ethnicity_Picklist__c,
                            person_being_served__r.Primary_Language__c,
                            person_being_served__r.Non_Verbal__c,
                            person_being_served__r.Sign_Language__c,
                            person_being_served__r.Marital_Status__c,
                            person_being_served__r.Gender__c,
                            person_being_served__r.Age_Text__c, 
                            person_being_served__r.Age__c, 
                            (select Primary_Diagnosis__c from Diagnoses__r order by Effective_Date__c desc NULLS LAST limit 1),
                            person_being_served__r.MailingStreet,
                            person_being_served__r.MailingCity, 
                            person_being_served__r.MailingStateCode,
                            person_being_served__r.MailingPostalCode,
                            person_being_served__r.Flavor__c,
                            person_being_served__r.Phone,
                            person_being_served__r.HomePhone,
                            person_being_served__r.otherPhone,
                            Admission__r.Admission_Effective_DateTime__c,
                            Referral__r.Referral_Source_Type__c,
                            Referral__r.Agency_Name__c,
                            Referral__r.Reason_for_Referral__c,
                            
                            person_being_served__r.Code_Status__c,
                            person_being_served__r.Code_Status_Other__c,
                            person_being_served__r.Advanced_Directives__c,
                            person_being_served__r.Advanced_Directives_Attached__c,
                            
                            (select Type_of_Coverage__c, Payer_Name__c, Policy_Type__c, Payer_Phone__c, TPA__c, TPA_Phone__c, Primary_Med_Ind_Phys_Group__c, Primary_Med_Ind_Phys_Group_Phone__c,
                            Network__c, Network_Phone__c, Verified_By__c, Payer_Verification_Date__c, Verified_With__c, Representing__c, 
                            Funding_Source__c, Call_Reference_Number__c, Policy_Number__c, Group_Name__c, Group_Number__c, Policy_Holder__c, Relationship_To_Patient__c,
                            More_than_1_5_Yrs_of_Disability__c, Patient_Over_64_Years_of_Age__c, Comment__c, Claims_Submission_Company__c, Claims_Submission_Street_1__c, 
                            Claims_Submission_Street_2__c, Claims_Submission_City__c, Claims_Submission_State__c, Claims_Submission_Zip__c
                            from Funding_Sources__r order by lastModifiedDate desc NULLS LAST limit 1)
                    from    Service_Assignment__c
                    where   Person_Being_Served__c = : pbsId
                    And     Status__c = 'Inactive'
                    order   by SA_Start_DateTime__c desc NULLS LAST limit 1]; 
            }

            contact = [select  id, (select Name, Phone__c, Address__c, Phone_2__c, Type__c, Comments__c, Phone_1_Type__c, Phone_2_Type__c 
                                      from Related_Party__r
                                     where (Type__c = : SERVICE_PROVIDER_TYPES OR Type__c = : EMERGENCY_CONTACT_TYPES)
                                       and Status__c = 'Active'
                                     order by lastModifiedDate desc NULLS LAST ),
                                   (select id, Allergy_Type__c, Allergy_Details__c, Life_Threatening__c 
                                      from Evaluation_Responses__r
                                     where RecordTypeId = : Utility.getEvaluationResponseRecordType('Allergy')
                                     order by lastModifiedDate desc NULLS LAST )
                        from    Contact
                       where    id = : pbsId]; 

            for(Related_Party__c rp : contact.Related_Party__r){
                if (SERVICE_PROVIDER_TYPES.contains(rp.Type__c))
                    serviceProviders.add(new RelatedPartyWrapper(rp.name, rp.Phone__c, rp.Address__c, rp.Phone_2__c, rp.Type__c, rp.Comments__c, rp.Phone_1_Type__c, rp.Phone_2_Type__c));
                else if (EMERGENCY_CONTACT_TYPES.contains(rp.Type__c))
                    emergencyContacts.add(new RelatedPartyWrapper(rp.name, rp.Phone__c, rp.Address__c, rp.Phone_2__c, rp.Type__c, rp.Comments__c, rp.Phone_1_Type__c, rp.Phone_2_Type__c));
            }
            serviceProviders.sort();
            emergencyContacts.sort();
            
            populateFundingSrcFields();
        } catch (Exception e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
        }
    }
    public String primaryDiagnosis {
        get {
            if (primaryDiagnosis != null) {
                return primaryDiagnosis;
            }
            ServiceAssignment_Diagnosis_JO__c[] d = [SELECT Diagnosis__r.Icd__c, Diagnosis__r.Icd__r.Name, Diagnosis__r.ICD__r.Icd_Description__c FROM ServiceAssignment_Diagnosis_JO__c WHERE Service_Assignment__r.Admission__r.Person_Being_Served__c = :pbsId And Service_Assignment__r.Status__c = 'Active' AND Ranking__c = 'Primary' order by CreatedDate desc];
          //  if (opGrp =='Redwood' || opGrp =='Cambridge' || opGrp == 'Care Meridian' || opGrp == 'NeuroRestorative' || this.con.flavor__c == 'CA FSS') { // No need to check this. Diagnosis is for every opGroup - Sravan
                if (d.size() > 0) {
                    list<String> diag = new list<String>();
                    set<id> icdCodes = new set<id>();
                    for(Integer i=0;i<=d.size()-1;i++){
                       if(icdCodes.size() > 0 && icdCodes.contains(d[i].Diagnosis__r.ICD__c)){
                            continue; // Prevent duplicate addition
                       }
                       icdCodes.add(d[i].Diagnosis__r.ICD__c);
                       diag.add(string.ValueOf(icdCodes.size())+') '+d[i].Diagnosis__r.Icd__r.Name+'-'+ (d[i].Diagnosis__r.ICD__r.Icd_Description__c.length() > 40 ? d[i].Diagnosis__r.ICD__r.Icd_Description__c.left(40)+'...' : d[i].Diagnosis__r.ICD__r.Icd_Description__c));
                    }
                   primaryDiagnosis = string.join(diag, ' ');
                } else {
                    primaryDiagnosis = '';
                }
            //} else {
                //primaryDiagnosis = '';
            //}
            return primaryDiagnosis;
        }
        set;
    }   
    private void populateFundingSrcFields(){
        if (sa.Funding_Sources__r.size() > 0)
            for(String fld : fundingSrcFldLbls.keySet()){
                if (sa.Funding_Sources__r[0].get(fld) != null) fundingSrcFldVals.put(fld, sa.Funding_Sources__r[0].get(fld));
            }
            
        for ( String key: fundingSrcFldVals.keySet()) {
               fundingSrcFldValsKeys += key + '||';
        }
    }
    
    class InvalidPbsException extends Exception{
    }

    public class RelatedPartyWrapper implements Comparable {
        public String name {get;set;}
        public String phone {get;set;}
        public String address {get;set;}
        public String phone2 {get;set;}
        public String relPartytype {get;set;}
        public String comments {get;set;}
        public Integer sortRank {get;set;}
        public String phone1Type {get;set;}
        public String phone2Type {get;set;}
         
        RelatedPartyWrapper(String name, String phone, String address, String phone2, String relPartytype, String comments, String phone1Type, String phone2Type) {
            this.name = name;
            this.phone = phone;
            this.address = address;
            this.phone2 = phone2;
            this.relPartytype = relPartytype;
            this.comments = comments;
            this.sortRank = relPartyRank.get(relPartytype);
            this.phone1Type = phone1Type;
            this.phone2Type = phone2Type;
        }
        
        public Integer compareTo(Object compareTo){
            RelatedPartyWrapper compareToRelParty = (RelatedPartyWrapper) compareTo;
            if ( sortRank == compareToRelParty.sortRank ) return 0;
            if ( sortRank > compareToRelParty.sortRank ) return 1;
            return -1;
        }
    }
}