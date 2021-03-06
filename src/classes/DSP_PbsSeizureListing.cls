public without sharing class DSP_PbsSeizureListing {
    
    public SeizureWrapper seizure {get;set;}
    
    public boolean isRwMN;
    public boolean getIsRwMN() {
        if (this.isRwMN == null)
            this.isRwMN = [SELECT operating_group__c From User WHERE ID=:UserInfo.getUserId() limit 1].operating_group__c == 'Redwood' && 
            [Select state__c from Admission__c where Status__c = 'Active' and Person_Being_Served__c =: PBSid limit 1].state__c == 'MN' ;
        return this.isRwMN;
    }
    
    private list<Seizure__c> seizures;
    public list<SeizureWrapper> getSeizuresWrapper() {
        list<SeizureWrapper> sWrapper = new list<SeizureWrapper>();
        for(Seizure__c s : this.seizures){
            sWrapper.add(new SeizureWrapper(s));
        }
        return sWrapper;
    }
    
    public Id PBSid {get;set;}
    public list<Service_Assignment__c> activeServAssign {get;set;} 
    public list<SelectOption> getSaOptions(){
        list<SelectOption> options = new list<SelectOption>();
        for (Service_Assignment__c sa : activeServAssign){
            options.add(new SelectOption(String.ValueOf(sa.id), sa.Name));
        }
        return options;
    } 
    public DSP_PbsSeizureListing(Id PBSid) {
        this.PBSid = PBSid;
        populateSeizures();
    }
    
    public DSP_PbsSeizureListing(TxnQueueResponseController controller) {
        if (controller.thisTxn.input_params__c instanceof Id) this((Id) controller.thisTxn.input_params__c);
        else {
            try { Seizure__c inputs = (Seizure__c) json.deserialize(controller.thisTxn.input_params__c, Seizure__c.class);
                 this.PBSid = [select Admission__r.Person_Being_Served__c from Service_Assignment__c where id = : inputs.Service_Assignment__c limit 1].Admission__r.Person_Being_Served__c;
                 populateSeizures();
                } catch (exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
        }
    }
    
    public class SeizureWrapper {
        public Id  id {get;set;}
        public String serviceAssignmentName {get;set;}
        public String serviceAssignmentId {get;set;}	
        public String comments {get;set;}
        public boolean duplicateEntry {get;set;}
        public datetime endDateTime {get;set;}
        public String observedByNameC {get;set;}
        public date startDate {get;set;}
        public datetime startDateTime {get;set;}
        public string seizureStart_DateTime {get;set;}
        public string seizureEnd_DateTime {get;set;}
        public Id ownerId {get;set;}
        public String seizureDescription {get;set;}
        public String preSeizurePhase {get;set;}
        public String postSeizurePhase {get;set;}
        
        public SeizureWrapper(){}	
        public SeizureWrapper(Seizure__c seizure){
            this.id = seizure.id;
            this.serviceAssignmentName = seizure.Service_Assignment__r.Name;
            this.serviceAssignmentId = seizure.Service_Assignment__c;
            this.comments = seizure.Comments__c;
            this.duplicateEntry = seizure.Duplicate_Entry__c == null ? false : seizure.Duplicate_Entry__c;
            this.endDateTime = seizure.End_DateTime__c;
            this.observedByNameC = seizure.Observed_By__r.Name;
            this.startDate = seizure.StartDate__c;
            this.startDateTime = seizure.Start_DateTime__c;
            this.ownerId = seizure.CreatedById;
            this.seizureDescription = seizure.Seizure_Description__c;
            this.preSeizurePhase = seizure.Pre_seizure_phase__c;
            this.postSeizurePhase = seizure.Post_seizure_phase__c;
        }
        public Seizure__c SeizureSObject(){
            return new Seizure__c(Id=this.id, 
                                  Service_Assignment__c = (Id) this.serviceAssignmentId, 
                                  Comments__c = this.comments,
                                  Start_DateTime__c = getDateTimeFromString(this.seizureStart_DateTime), 
                                  End_DateTime__c = getDateTimeFromString(this.seizureEnd_DateTime), 
                                  Observed_By__c = UserInfo.getUserId(), 
                                  Duplicate_Entry__c = this.duplicateEntry == null ? false : this.duplicateEntry,
                                  Seizure_Description__c = this.seizureDescription,
                                  Pre_seizure_phase__c = this.preSeizurePhase,
                                  Post_seizure_phase__c = this.postSeizurePhase
                                 );
        }
        
    }
    
    public void populateSeizures() {
        this.seizures = [select id,Observed_By__r.Name, Service_Assignment__r.Name, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c, Duplicate_Entry__c, StartDate__c, Service_Assignment__c, CreatedById,
                         Seizure_Description__c, Pre_seizure_phase__c, Post_seizure_phase__c
                         from Seizure__c where Service_Assignment__r.Admission__r.Person_Being_Served__c = : this.PBSid and Start_DateTime__c >= : datetime.now().addMonths(-1) order by Start_DateTime__c desc];
        
        activeServAssign = [select id, Name from Service_Assignment__c where Status__c = 'Active' And Admission__r.Person_Being_Served__c = : this.PBSid order by Name];
        /*  if (servAssigns.size() != 1) activeServAssign.add(new SelectOption('', '--Select--'));
for (Service_Assignment__c sa: servAssigns){
activeServAssign.add(new SelectOption(sa.id, sa.name));
} */
        
        this.seizure = new SeizureWrapper();
        this.seizure.observedByNameC = UserInfo.getName();
        if (activeServAssign.size() == 1) this.seizure.serviceAssignmentId = String.ValueOf(activeServAssign[0].id);
        else this.seizure.serviceAssignmentId = '';
    }
    
    public PageReference saveSeizure() {
        if (String.valueOf(this.seizure.Id) == '') {
            this.seizure.Id = null;
        }
        system.debug('form values: ' + this.seizure.SeizureSObject());        
        //        upsert this.seizure.SeizureSObject();
        //        populateSeizures();                
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Upsert Seizure';
        txn.requested_date_time__c = DateTime.Now();        
        txn.input_params__c = json.serialize(this.seizure.SeizureSObject());        
        try { 
            insert txn;
            PageReference pr =  Page.DSP_pbsSeizureListing;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public void showEditSeizure() {
        string seizureId = ApexPages.CurrentPage().getParameters().get('seizureId');
        this.seizure = new SeizureWrapper([select id,Observed_By__r.Name, Service_Assignment__r.Name, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c, Duplicate_Entry__c, StartDate__c, CreatedById, Seizure_Description__c, Pre_seizure_phase__c, Post_seizure_phase__c from Seizure__c where id = : seizureId]);
    }
    
    public static Datetime getDateTimeFromString(String dateTimeStr) {
        string stringDate='';
        try {
            stringDate = dateTimeStr.substring(6,10) + '-' +dateTimeStr.substring(0,2) + '-' + dateTimeStr.substring(3,5) + ' ' + dateTimeStr.substring(11);
            return Datetime.valueOf(stringDate);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid date'));
        }
        return null;
    }
    
    @RemoteAction
    public static boolean findDuplicateSeizure(string seizureStart, string seizureEnd, Id saId, Id seizureId) {
        DateTime st = getDateTimeFromString(seizureStart);
        DateTime en = getDateTimeFromString(seizureEnd);
        boolean dupefound = false;
        List<Seizure__c> duplicateSeizure = [SELECT Id FROM Seizure__c WHERE Service_Assignment__c = :saId
                                             AND ( ( Start_DateTime__c <= : st And End_DateTime__c > : st )  // one start at the same time OR after but the before the end of an existing one
                                                  Or ( Start_DateTime__c >= : st And End_DateTime__c <= : en ) )  // the one being entered is not marking an existing one as the duplicate
                                             AND Duplicate_Entry__c = false
                                             AND Id != : seizureId  // exclude the one itself from consideration when editing a record.
                                             limit 1];
        
        if(duplicateSeizure.size() > 0) {
            dupeFound = true;
        }
        return dupeFound;
    }
    
}