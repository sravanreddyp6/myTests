public with sharing class AdmissionViewExtension {
        public String[] availableAssessmentTypes { get {
           return new String[] {'Risk', 'CANS', 'ISSA'};
        }}
    public Admission__c admission { get; set; }
    public Assessment__c[] riskAssessments { get; set; }
    public Assessment__c[] cansAssessments { get; set; }
    public Assessment__c[] issaAssessments { get; set; }
    public Map<String, Boolean> assessmentTypes { get; set; } 
    public boolean isEditor { get; set;} 
    public boolean canCreateAsmt{ get; set;}
    public boolean canCreateSvc{ get; set;}
    public boolean canCreateAdm{ get; set;}
    public boolean canCreatePlan{ get; set;}
    private void setisEditor() {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.admission.Id ];

        if (acls.size() > 0) {
            isEditor = acls[0].HasEditAccess;
        } else { isEditor = false;}
        
        
    }
    
    private void setcanCreateAsmt() {
        Schema.DescribeSObjectResult oSchema = Assessment__c.sObjectType.getDescribe();
        canCreateAsmt = oSchema.IsCreateable();
    }
    
    private void setcanCreateAdm() {
        Schema.DescribeSObjectResult oSchema  = Admission__c.sObjectType.getDescribe();
        canCreateAdm = oSchema.IsCreateable();
    }
    
    private void setcanCreateSvc() {
        Schema.DescribeSObjectResult oSchema = Service_Assignment__c.sObjectType.getDescribe();
        canCreateSvc = oSchema.IsCreateable();
    }
    
    private void setcanCreatePlan() {
        Schema.DescribeSObjectResult oSchema = Plan__c.sObjectType.getDescribe();
        canCreatePlan = oSchema.IsCreateable();
    }

    public AdmissionViewExtension(ApexPages.StandardController stdController) {
        // Fetch the record with necessary fields
        this.admission = [
                SELECT ID, Name, CreatedBy.Name, CreatedDate, LastModifiedBy.Name,
                           LastModifiedDate, Effective_Date__c, Status__c,
                           Discharged_Date__c,Person_Being_Served__c, Person_Being_Served__r.AccountID, person_being_served__r.Name,Person_Being_Served__r.OwnerId, person_being_served__r.LastName,
                           Network_Offering__c, Discharged_Status__c, Reason_for_Discharge__c, State__c,
                           Referred_Out_Date__c, Referred_Out_Agency_Name__c,
                           Referred_Out_Reason__c,
                           (SELECT Name, Authorization_Status__c, Payer_Authorization_Date__c, Payer_Effective_Date__c, Payer_End_Date__c, Payer_Authorization_ID__c, Payer_Name__c, Number_Of_Authorized_Units__c, Remaining_Units__c FROM Authorized_Services__r),
                           (SELECT Name, Assessment_Date__c, Score__c, Owner.FirstName, Owner.LastName, Status__c FROM Assessments__r),
                           (SELECT Name, Person_Being_Served__r.Name, Status__c, Start_Date__c, End_Date__c FROM Service_Agreements__r ORDER BY Status__c, Start_Date__c),
                           (SELECT Name, Status__c, Effective_Date__c, Plan_Expiration_Date__c, Long_term_Goal_1__c FROM Plans__r),
                           (SELECT Name, Plan__r.Name, First_Name__c, Last_Name__c, Start_Time__c, End_Time__c, Type_of_Contact__c, Purpose_Nature_of_Service__c FROM Progress_Notes__r)
                FROM Admission__c WHERE ID=:ApexPages.currentPage().getParameters().get('id')
        ];
        // We decide to show/hide the New Assessment button based on Role and
        // Permission instead of hardcoding them.
        Assessment_Type__c[] types = [
            SELECT Name FROM Assessment_Type__c
        ];
        assessmentTypes = new Map<String, Boolean>();
        for (String t: availableAssessmentTypes) {
            assessmentTypes.put(t, false);
        }

        for (Assessment_Type__c t: types) {
                assessmentTypes.put(t.Name, true);
        }
        this.riskAssessments = fetchAssessments('Risk', this.admission.ID);
        this.cansAssessments = fetchAssessments('CANS', this.admission.ID);
        this.issaAssessments = fetchAssessments('ISSA', this.admission.ID);
        
        setcanCreateAsmt();
        setcanCreateAdm();
        setcanCreateSvc();
        setcanCreatePlan();
        setIsEditor();
    }

    private Assessment__c[] fetchAssessments(String name, String admissionId) {
        if(name=='ISSA') {
	        return [
	           SELECT Name, Assessment_Date__c, Finalized_Date__c, Score__c,
	                  Owner.FirstName, Owner.LastName, Owner.Name, Status__c
	           FROM Assessment__c
	           WHERE Type__c=:name AND Admission__c=:admissionId Order By CreatedDate DESC 
	        ];        	
        }
        else {
	        return [
	           SELECT Name, Assessment_Date__c, Finalized_Date__c, Score__c,
	                  Owner.FirstName, Owner.LastName, Owner.Name, Status__c
	           FROM Assessment__c
	           WHERE Assessment_Type__r.Name=:name AND Admission__c=:admissionId Order By CreatedDate DESC 
	        ];
        }
    }
    public PageReference createRiskAssess(){
        Assessment__c assess = new Assessment__c ();
        Assessment_Type__c Type = [Select id, name from Assessment_Type__c where Name like 'risk' limit 1];
        assess.Assessment_Type__c = Type.id;
        assess.Admission__c = admission.id;
        assess.Status__c = 'Inactive Draft';
        insert assess;
        PageReference ref =  new PageReference('/'+assess.id + '?new=1');
            
        return ref;
    }
    public PageReference createIssaAssess(){
        Assessment__c assess = new Assessment__c ();
        assess.Type__c = 'ISSA';
        assess.Admission__c = admission.id;
        assess.Status__c = 'Inactive Draft';
        insert assess;
        PageReference ref =  new PageReference('/'+assess.id + '?new=1');
            
        return ref;
    }
    public id getCANsID(){
        Assessment_Type__c Type = [Select id, name from Assessment_Type__c where Name like 'CANS' limit 1];
        return type.id;
    
    }
    
    public id getRisk_Overview(){
        id theId;
        theID = [select id, developername from report where developername = 'Risk_Assessment_Acknowledgment_Overview' limit 1].id;
        
        return theId;
    
    
    }    
    
    
}