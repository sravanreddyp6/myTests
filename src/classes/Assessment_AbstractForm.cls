public abstract class Assessment_AbstractForm {
    public string glbListSeperator {get{return ';';} set;}
    public string glbItemSeperator {get{return '__';} set;}
    protected list<string> selectFields = new list<string>();
    protected list<string> selectFieldsAssessResp = new list<string>();	
    protected Assessment__c assessment { get; set; }
    
    protected List<id> DomainsInScopeIDs = new List<id>();
    protected List<id> QuestionsInScopeIDs = new List<id>();
    public transient Map<id, Map<string,Object>> mapCurrentResps;
    public abstract Map<id, Map<string,Object>> getMapCurrentResps();
    
    transient public List<AssessmentDomainWrapper> DomainsInScope;
    public List<AssessmentDomainWrapper> getDomainsInScope(){
        if (this.DomainsInScope == null) return DomainsInScope = buildDomainsInScopeWrapper();
         else return this.DomainsInScope;
    }
    private List<AssessmentDomainWrapper> buildDomainsInScopeWrapper(){
        List<AssessmentDomainWrapper> DomainsInScopeWrapperTemp = new List<AssessmentDomainWrapper>();
        for(Assessment_Domain__c domain : [Select ID,  Name, Description__c, Assessment_Type__c, Header__c,  External_Id__c,
                                                 (Select Name, ID, Question_Description__c, Question_Title__c, Question_Number__c , External_Id__c
                                                    From Question__r 
                                                    Where ID in :QuestionsInScopeIDs
                                                    Order By Question_Number__c) 
                                           From Assessment_Domain__c Where id in :DomainsInScopeIDs Order By Sort_Order__c] ){
                    DomainsInScopeWrapperTemp.add(new AssessmentDomainWrapper(domain));
        }
        return DomainsInScopeWrapperTemp;
    }
    public class AssessmentDomainWrapper {
        public String id {get;set;}
        public String name {get;set;}
        public String description {get;set;}
        public String assessmentType {get;set;}
        public String header {get;set;}
        public String externalId {get;set;}
        public list<QuestionWrapper> QuestionWrappers {get;set;}
        public AssessmentDomainWrapper(Assessment_Domain__c domain){
            this.QuestionWrappers = new list<QuestionWrapper>();
            for (Assessment_Question__c q : domain.Question__r) {
                this.QuestionWrappers.add(new QuestionWrapper(q));
            }
            this.id = domain.ID;
            this.name = domain.Name;
            this.description = domain.Description__c;
            this.assessmentType = domain.Assessment_Type__c;
            this.header = domain.Header__c;
            this.externalId = domain.External_Id__c;
        }
    }
    public class QuestionWrapper {
        public String name {get;set;}
        public String id {get;set;}
        public String questionDescription {get;set;} 
        public String questionTitle {get;set;}
        public decimal questionNumber {get;set;}
        public String externalId {get;set;}
        public QuestionWrapper(Assessment_Question__c q){
                this.Name = q.name;
                this.id = q.ID;
                this.questionDescription = q.Question_Description__c;
                this.questionTitle = q.Question_Title__c;
                this.questionNumber = q.Question_Number__c;
                this.externalId = q.External_Id__c;
        }
    }  

    public Boolean showConfirmationButton {get; private set;}
    public List<AckWrapper> ackwrapList {get; private set;}
        
    public class AckWrapper {
        public String AckBy { get; set; }
        public Datetime AckDate { get; set; }
        public String AckInit { get; set; }
        
        public AckWrapper( string b, datetime d, string i ) {
            this.AckBy = b;
            this.AckDate = d;
            this.AckInit = i;
        }
    }

    public transient Map<String, Object> assessmentWrapper;
    public Map<String, Object> getAssessmentWrapper() {
        if (this.assessmentWrapper == null){
            Map<String, Object> m = new Map<String, Object>();
            for(String s : selectFields){
                m.put(s,'');
            }
            updateMapWithRelationshipKeys(m, JSON.serialize(this.assessment), '');
            return m;
        } else return this.assessmentWrapper;
    }
        	
	protected Assessment_AbstractForm(Id assessmentId){
	    // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Assessment__c').getDescribe().Fields.getMap();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
            }
        }
        selectFields.addAll(new List<String>{ 'Admission__r.Name', 'Admission__r.State__c', 'LastModifiedBy.Name', 'CreatedBy.Name', 'Approved_By__r.Name', 'Admission__r.Person_Being_Served__r.Name'});
        String strSQL =  'SELECT ' + String.join(selectFields, ',') + ' FROM Assessment__c WHERE Id = \'' + assessmentId + '\'';
        this.assessment = (Assessment__c) Database.query(strSQL)[0];


        fMap = Schema.getGlobalDescribe().get('Assessment_Response__c').getDescribe().Fields.getMap();
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFieldsAssessResp.add(fd.getName());
            }
        }
        selectFieldsAssessResp.addAll(new List<String>{'Question__r.External_Id__c', 'Question__r.Question_Domain__c', 'Question__r.Question_Title__c'});
        
     
        // get existing acknowledgments on the assessment 
        ackwrapList = new List<AckWrapper>();
        showConfirmationButton =  true;
        for ( Acknowledgment__c a : [ select user__c, user__r.name, CreatedDate from acknowledgment__c where Assessment__c = :assessment.id order by CreatedDate desc LIMIT 1000]) {
             AckWrapper aw = new AckWrapper( a.user__r.name, a.CreatedDate, '');
             ackwrapList.add( aw );
             if ( a.user__c == userinfo.getUserId())
                showConfirmationButton = false;
        }
    }

    protected void updateMapWithRelationshipKeys(Map<String, Object> m, String jsonString, String relationshipKey){
            Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> newMap = new Map<String, Object>(); 
            for(String k : temp.keySet()){
                if(k.endsWithIgnoreCase('__r') || k == 'LastModifiedBy' || k == 'CreatedBy') updateMapWithRelationshipKeys(m, JSON.serialize(temp.get(k)), k);
                else {
                    if (String.IsBlank(relationshipKey) ) newMap.put(k, temp.get(k));
                    else newMap.put(relationshipKey + '.' + k,  temp.get(k));
                }
            }
            m.putAll(newMap);
            m.remove(String.IsBlank(relationshipKey) ? 'attributes' : relationshipKey + '.attributes'); // this is to remove this key, SF adds this when serializing the sObject.
    }
    
}