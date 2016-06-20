public with sharing class OneApp_PersonCard {
    
    public String reqInfo { get; set { populateCard(value);}}
    @testVisible private string reqType;
    @testVisible private string inputID;
    
    @testVisible void populateCard (String req) {
        if ( !String.IsEmpty( req )) {
            String[] strs = req.split(',');
            if ( strs.size() == 2 ) {
                reqType = strs[0];
                inputID = strs[1];
            } else 
                return;
        } else 
            return;
        
        // need both to be set to continue
        if ( reqType == '' || inputID == '')
            return;
        
        // get the txn info
        if ( reqType == 'Action Plan' || reqType == 'Acknowledge Plan' || reqType == 'SkillList' || reqType == 'BehaviorList' || reqType == 'ServiceList' || reqtype==  'Behavior' || reqtype == 'Skill' || reqtype == 'Service' || reqtype == 'Edit Service' || reqtype == 'Update Service' || reqtype == 'ServiceTrackingList' || reqtype == 'Update Skill' || reqtype == 'Update Behavior') {
            // id is the Action Plan ID
            Action_Plan__c ap = [ select service_assignment__r.person_being_served__c from action_Plan__c where id = :inputID];
            if ( ap != null)
                contactID = ap.service_assignment__r.person_being_served__c;
        }
        else if ( reqType == 'Seizures' || reqType == 'Upsert Seizure' || reqType == 'Person Being Served' || reqType == 'Risk' || reqType == 'ISSA' || reqType == 'Acknowledge Assessment' || reqType == 'Shift Note') {
            this.contactID = inputID;        	
        }
        // else return out!
    }
    public OneApp_PersonCard ( ) {
    }
    
    public String photoUrl { get; set; }
    public blob photo { get; set; }
    public Contact con { get; set; }
    public transient List<EvalResponseWrapper> allergies { get; set; }
    
    public List<Service_Assignment__c> servAssigns { get; set; }
    public Integer guardianCount { get; set;}
    public boolean hasPhoto { get; set; }
    public String contactId { get;
                             set {
                                 if (value == contactId) {
                                     return;
                                 }
                                 this.contactId = value;
                                 System.debug('Contact ID: ' + value);
                                 this.con = [
                                     SELECT Id, FirstName, LastName, Phone, Ethnicity_Picklist__c,Age_year__c,Age_month__c,Age_days__c,
                                     Birthdate, Guardian1_Name__c, Guardian_Phone_Number__c,
                                     Gender__c, Age__c, Family_Member_Other__c, PBS_Identifier__c, Primary_Language__c, Advanced_Directives__c, Code_Status__c, Flavor__c
                                     FROM Contact WHERE id=:value
                                 ];
                                 
                                 getAllergyList( value);
                                 guardianCount  = [select count() from related_party__c where person_being_served__c =:value and type__c = 'Guardian'];
                                 
                                 List<Attachment> headShot = [
                                     SELECT id, parentId, Name, Description FROM Attachment
                                     WHERE Name LIKE 'HeadShot-Current%' and parentID=:value LIMIT 1
                                 ];
                                 if(headShot.size()>0){
                                     this.photoUrl='/servlet/servlet.FileDownload?file=' + headShot[0].id;
                                     this.hasPhoto = true;
                                 } else
                                     this.hasPhoto = false;
                                 
                                 servAssigns = [Select Id, Name from Service_Assignment__c where Person_Being_Served__c = :value and Status__c = 'Active'];
                                 
                                 Related_Party__c[] party = [select id, Name, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c from Related_Party__c where Person_Being_Served__c = :value And Type__c =: 'Physician - Primary' limit 1];
                                 if (party.size() > 0 ) {
                                     primaryPhysician = party[0].Name;
                                     if (party[0].Phone_1_Type__c == 'Work'){
                                         primaryPhysicianPhone = party[0].Phone__c;
                                     }
                                     else if(party[0].Phone_2_Type__c == 'Work'){
                                         primaryPhysicianPhone = party[0].Phone_2__c;
                                     }
                                     
                                 } else {
                                     primaryPhysician = '';
                                     primaryPhysicianPhone = '';
                                 }
                                 
                                 // get all primary diagnoses	
                                 ServiceAssignment_Diagnosis_JO__c[] d = [SELECT Diagnosis__r.ICD__r.Icd_Description__c FROM ServiceAssignment_Diagnosis_JO__c WHERE Service_Assignment__r.Admission__r.Person_Being_Served__c=:value And Service_Assignment__r.Status__c = 'Active' AND Ranking__c = 'Primary' order by CreatedDate desc];
                                 if (opGrp =='Redwood' || opGrp =='Cambridge' || opGrp == 'Care Meridian' || opGrp == 'NeuroRestorative' || this.con.flavor__c == 'CA FSS') {
                                     if (d.size() > 0) {
                                         List<String> diag = new List<String>();
                                         for(Integer i=0;i<=d.size()-1;i++){
                                             primaryDiagnosis = d[i].Diagnosis__r.ICD__r.Icd_Description__c;
                                             diag.add(primaryDiagnosis);
                                             primaryDiagnosis = string.join(diag, ',');
                                         }
                                     } else {
                                         primaryDiagnosis = '';
                                     }
                                 } else {
                                     primaryDiagnosis = '';
                                 }
                                 
                                 age = Utility.getAge(this.con.Age_year__c,this.con.Age_month__c,this.con.Age_days__c);
                             }
                            }
    
    public String age { get; set; }
    
    public class evalResponseWrapper {
        public string eType { get; set; }
        public string details { get; set; }
        public evalResponseWrapper( string t, string d) {
            eType = t;
            details = d;
        }
    }
    
    public void getAllergyList(ID pbsID) {
        List<Evaluation_Response__c > evaluationResponses = [
            SELECT Id, Allergy_Details__c, Allergy_Type__c
            FROM Evaluation_Response__c
            WHERE Person_Being_Served__c = :pbsID
            AND Life_Threatening__c = true
        ];
        
        this.allergies = new List<EvalResponseWrapper>();
        for ( Evaluation_Response__c e : evaluationResponses ) {
            allergies.add( new EvalResponseWrapper( e.allergy_type__c, e.allergy_details__c));
        }
    }
    
    public String opGrp {
        get {
            opGrp = (opGrp == null ? [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1].Operating_Group__c : opGrp);
            return opGrp;
        }
        set;
    }
    
    public String primaryDiagnosis {
        get {
            if (primaryDiagnosis != null) {
                return primaryDiagnosis;
            } else 
                primaryDiagnosis = '';
            return primaryDiagnosis;
        }
        set;
    }
    
    public String primaryPhysician{ get; set; }
    public String primaryPhysicianPhone { get; set; }
    
    public String isolationStatus{
        get{
            if (isolationStatus != null) {
                return isolationStatus;
            }
            Evaluation_Response__c[] isolation = [
                SELECT Isolation_Status__c
                FROM Evaluation_Response__c
                WHERE Service_Assignment__r.Status__c = 'Active'
                AND Isolation_Status__c = 'Isolated'
                AND Service_Assignment__r.Admission__r.Person_Being_Served__c=:con.Id
            ];
            if(isolation.size() > 0){
                isolationStatus = 'Isolated';
            } else {
                isolationStatus = 'Not Isolated';
            }
            return isolationStatus;
        }
        set;
    }
    
    public String isolationType{
        get{
            if (isolationType != null) {
                return isolationType;
            }
            set<String> isolation = new set<String>();
            List<evaluation_response__c> isolations = [
                select isolation_type__c,other__c  from evaluation_response__c
                where service_assignment__r.status__c = 'active'
                and isolation_status__c = 'isolated'
                and service_assignment__r.admission__r.person_being_served__c=:con.id
                and isolation_event_end_date__c = null
                order by isolation_event_start_date__c desc
            ];
            for(evaluation_response__c evlres : isolations){
                for (string s : evlres.isolation_type__c.split(';') ){
                    if (s == 'other') s = evlres.other__c;
                    isolation.add(s);
                }
            }
            isolationType = string.join(new list<string>(isolation), ', ');
            return isolationType;
        }
        set;
    }
    
}