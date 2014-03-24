public class ServiceAssignmentExt {

    public Service_Assignment__c theServAssign { get; set; }

// START:  Parent level properties with get/set methods.
    public Boolean editSA { get; set; }
    public Boolean newSA { get; set; }
    public Admission__c admission { get; set; }
    public Id admissionId { get; set; }
    public String recordType { get; set; }
    public Id recordTypeId { get; set; }
    public RecordType theRecordType { get; set; }

    public string worksheetStartDate{get;set;}
    public Referral__c referral { get; set; }
    public List<Action_Plan__c> plans = new List<Action_Plan__c>();
    public List<Action_Plan__c> getplans() {return plans;}
    public List<Progress_Note__c> notes;
    public List<Progress_Note__c> getNotes() {return notes;}
    public Boolean canCreatePlan { get; set; }
    public Boolean canCreateSummary { get; set; }
    public Boolean canEditSA { get; set; }
    public static Boolean showdiagModal { get; set; }
    public string diagEditId {get; set; }
    public Service_Location__c serviceLocation { get; set; }

    // Get/set info for contracts
    public List<TMN_Contract__c> contractsForThisServAssignsState { get; set; }
    public List<ContractWrapper> contractRows { get; set; }
    public List<ServiceAssignment_Contract_JO__c> servAssignContractXrefs {get;set;}
    public Boolean refreshPage { get; set; }

    // Get/set for Programs
    public String SelectedProgram {get; set;}
    public String SelectedServiceLine {get; set;}
    public List<SelectOption> MyPrograms = new List<SelectOption>();
    public List<SelectOption> getMyPrograms (){return MyPrograms;}

    //the get for locations is below
    public List<ServiceAssignment_ServiceCode_JO__c> CurrentCodes = new List<ServiceAssignment_ServiceCode_JO__c>();

    public ID currentID {get; set;}
    public string currentState{ get; set;}
    public Service_Assignment__c currentRecord { get; set;}
    public final Service_Assignment__c initialRecord;
    public Set<ID> SelectedCodeIDs = new Set<ID>();
    public Map<Id,Service_Code__c> SelectedCodes { get; set; }
    public Map<Id,Service_Code__c> AvailableCodes { get; set; }
    public String currentProgram { get; set; }
    public String currentLocation { get; set; }
    public String currentServiceLine { get; set; }
    //for adding new JOs
    public ID SelectedCodeID {get; set;}
    public ID SelectedCodeKey { get; set; }
    //for removing JOs
    public ID SelectedJoID {get; set;}
    public Set<Id> servCodeIdsForXrefsToDelete { get; set; }
    //boolean for filtering on assessment only service codes
    public boolean AssessmentOnly {get; set;}
    public String pageHeader { get; set; }
    private ID pbsOwner;

    // Program Xref / Event Properties
    public List<Program_Document_Xref__c> pdxs { get; set; }
    public List<SelectOption> phaseSelectOptions { get; set; }
    public Integer highestCompletedPhase { get; set; }
    public Decimal currentPhasePercentage { get; set; }
    public Integer numDocsReceived { get; set; }
    public Integer numDocsExpected { get; set; }
    public Integer phaseToSave { get; set; }

        // Fidelity Document Properties / Info
    public List<ServiceAssignment_Document_JO__c> sadjos { get; set; }
    public Boolean hasFidDocs { get; set; }
    public List<ProgramAssociationTableWrapper> programRows { get; set; }

        private void setcanEditSA() {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.theServAssign.Id ];

        if (acls.size() > 0) {
            canEditSA = acls[0].HasEditAccess;
        } else { canEditSA = false;}

//        Schema.DescribeSObjectResult oSchema = Service_Assignment__c.sObjectType.getDescribe();
//        canEditSA = oSchema.IsUpdateable();

    }

    private void setcanCreatePlan() {
        Schema.DescribeSObjectResult oSchema = Action_Plan__c.sObjectType.getDescribe();
        canCreatePlan = oSchema.IsCreateable();
    }
    private void setcanCreateSummary() {
        Schema.DescribeSObjectResult oSchema = Action_Summary__c.sObjectType.getDescribe();
        canCreateSummary = oSchema.IsCreateable();
    }

    public List<Action_Plan__c> getActivePlan(){
    
        return [Select id From Action_Plan__c where Action_Plan__c.Service_Assignment__c = :currentRecord.id AND Status__c = 'Active Final' Limit 1];
    }

    private Boolean pshowDiag, pshowLocation; 
    private static Boolean psetFlags = false;
    public Boolean showDiagnosis { get {
            if (! psetFlags ) {
                psetFlags = setShowFlags();
            }
            return pshowDiag;
    }}
    public Boolean showLocation { get {
            if (! psetFlags ) {
                psetFlags = setShowFlags();
            }
            return pshowLocation;
    }}
    
    private Boolean setShowFlags() {    
        if (! psetFlags) {
            
            pshowDiag = true;
            pshowLocation = false;
        
            System.Debug('getting showDiagnosis with SF account = ' + pbsOwner);
            TMN_User__c[] tmnUsers = [
                SELECT ID, Operating_Group__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:pbsOwner LIMIT 1
            ];
            if (tmnUsers.size() == 0) {
                pshowDiag = false;
                pshowLocation = false;
                psetFlags = false;
            } else {
                pshowDiag = tmnUsers[0].Operating_Group__c=='Redwood' || tmnUsers[0].Operating_Group__c=='Cambridge';
                pshowLocation =  tmnUsers[0].Operating_Group__c=='Redwood' ;
                psetFlags = true;
            }
            
        }
        return psetFlags;
        }
    
    public void showAddLocation() {
        // empty for action support
    }

    public list<Diagnosis__c> diagnoses{get; set;}

    public Diagnosis__c diag {
    get {
      if (diag == null)
        diag = new Diagnosis__c();
      return diag;
    }
    set;
  }

  public Boolean newDiagnosis{ get; set;}
  public void showAddDiagnosis() {
    newDiagnosis = true;
    showdiagModal = true;
    diag = new Diagnosis__c();
    System.Debug('showdiagModal='+ showdiagModal);
  }

  public void showEditDiagnosis() {
    showdiagModal = true;
    System.Debug('showdiagModal=' + showdiagModal);
  }

  public void saveDiagnosis() {
    Boolean foundDiag = false;
    Diagnosis__c dgnew = this.diag;
    System.debug('dgnew: ' + dgnew);
    // if this diagnosis contains an ID, look for it to update
    if ( diagnoses != null ) {
        for ( Diagnosis__c dg : diagnoses ) {
            if ( dg.Id != null && dg.Id == dgnew.Id ) {
                // update in place
                dg.Effective_Date__c = dgnew.Effective_Date__c;
                dg.Axis_I__c = dgnew.Axis_I__c;
                dg.Axis_II__c = dgnew.Axis_II__c;
                dg.Axis_III__c = dgnew.Axis_III__c;
                dg.Axis_IV__c = dgnew.Axis_IV__c;
                dg.Axis_V__c = dgnew.Axis_V__c;
                dg.Primary_Diagnosis__c = dgnew.Primary_Diagnosis__c;
                dg.Secondary_Diagnosis__c = dgnew.Secondary_Diagnosis__c;
                dg.Level_of_Disability__c = dgnew.Level_of_Disability__c;
                dg.Comments__c = dgnew.Comments__c;

                foundDiag = true;
                break;
            }
        }
    }
    if ( !foundDiag )
            this.diagnoses.add(dgnew);

    this.diag= new Diagnosis__c();
    newDiagnosis = false;
  }


  public void createDiagnoses() {
    if (diagnoses != null && this.theServAssign.Id != null) {
      for (Diagnosis__c dg : diagnoses ) {
        dg.Service_Assignment__c = this.theServAssign.Id;
      }
    System.Debug('DIAG LIST = ' + diagnoses);
      upsert diagnoses;
    }

  }

   public list<Funding_Source__c> fundingsource {get { return [select id, name, funding_source__c, payor__c, recordtype.name, service_being_funded__c, status__c from funding_source__C where service_Assignment__C = :theServAssign.id];} set;}

// END:  Parent level properties with get/set methods.


// START: CONSTRUCTOR
    public ServiceAssignmentExt(ApexPages.StandardController controller) {

        if(ApexPages.currentPage().getParameters().get('save_new')=='1'){
                pageHeader = 'Add a Service Assignment';
                newSA = true;
                editSA = true;
                theServAssign = new Service_Assignment__c();
                initialRecord = new Service_Assignment__c();
                admission = [ SELECT Id, Name, State__c, Person_Being_Served__c, person_being_served__r.ownerid FROM Admission__c WHERE Id = :ApexPages.currentPage().getParameters().get('admissionID') ];
                admissionId = admission.Id;
                theServAssign.Admission__c = admission.Id;
                theServAssign.Name = 'TBD - Autofilled';
                theServAssign.Person_Being_Served__c = admission.Person_Being_Served__c;
                theServAssign.Phase__c = 0;
                diagnoses = new List<Diagnosis__c>();
                recordType = ApexPages.currentPage().getParameters().get('recordType');
                theRecordType = new RecordType();
                theRecordType = [ SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = :recordType LIMIT 1 ];
                theServAssign.RecordTypeId = theRecordType.Id;
                //recordTypeId = theServAssign.RecordTypeId;
                initialRecord.Admission__c = admission.Id;
                initialRecord.Name = 'TBD - Autofilled';
                initialRecord.Person_Being_Served__c = admission.Person_Being_Served__c;
                initialRecord.RecordTypeId = theRecordType.Id;
                pbsOwner = admission.Person_Being_Served__r.OwnerId;

        }
        else {
                pageHeader = 'Service Assignment Detail';
                newSA = false;
                theServAssign = [SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                            End_Date__c, External_ID__c, Location_Region__c, Outcomes__c, Person_Being_Served__c, Phase__c, Phase_of_Treatment__c, Program__c,
                            Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                            Start_Date__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                            Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,
                            Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name, Person_Being_Served__r.OwnerId, referral__c, service_location__c
                                FROM Service_Assignment__c
                                WHERE Id = :controller.getid()];
                initialRecord = [SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                            End_Date__c, External_ID__c, Location_Region__c, Outcomes__c, Person_Being_Served__c, Phase__c, Phase_of_Treatment__c, Program__c,
                            Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                            Start_Date__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                            Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,
                            Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name, Person_Being_Served__r.OwnerId, referral__c, service_location__c
                                FROM Service_Assignment__c
                                WHERE Id = :controller.getid()];
                admission = [ SELECT Id, Name, State__c, Person_Being_Served__c FROM Admission__c WHERE Id = :theServAssign.Admission__c ];
                admissionId = admission.Id;
                recordType = theServAssign.RecordType.Name;
                recordTypeId = theServAssign.RecordTypeId;
                pbsOwner = theServAssign.Person_Being_Served__r.OwnerId;

        }

        System.debug('recordType BEFORE LoadData: ' + recordType);
        System.debug('AssessmentOnly BEFORE LoadData: ' + AssessmentOnly);


        LoadData(theServAssign);

        System.debug('recordType AFTER LoadData: ' + recordType);
        System.debug('AssessmentOnly AFTER LoadData: ' + AssessmentOnly);
        setcanEditSA();
        setcanCreatePlan();
        setcanCreateSummary();


        getContractsAndXrefs();
        contractRows = new List<ContractWrapper>();
        for(TMN_Contract__c contract: contractsForThisServAssignsState){
            contractRows.add(new ContractWrapper(contract, servAssignContractXrefs));
        }
        contractRows.sort();

        pdxs.sort();

        Set<Integer> uniquePhases = new Set<Integer>();
        for(Program_Document_Xref__c p : pdxs) {
            uniquePhases.add(p.Document__r.Phase_or_Level__c.intValue());
        }

        List<ServiceAssignment_Document_JO__c> sadjos = new List<ServiceAssignment_Document_JO__c>();
        sadjos = [ SELECT Id, Name, Document__r.Phase_or_Level__c, File_Status__c FROM ServiceAssignment_Document_JO__c
                    WHERE Service_Assignment__c = :theServAssign.Id AND Document__r.Type__c = 'Fidelity Document'];

        phaseSelectOptions = new List<SelectOption>();
        phaseSelectOptions.add(new SelectOption('','--None--'));
        Integer currentPhase = 0;
        if(theServAssign.Phase__c!=null) {
            currentPhase = theServAssign.Phase__c.intValue();
        }
        Integer phaseCounter = 1;
        highestCompletedPhase = 0;
        currentPhasePercentage = 0;
        numDocsReceived = 0;
        numDocsExpected = 0;
        Decimal docsRunningCount = 0;
        Decimal docsFiledRunningCount = 0;

        programRows = new List<ProgramAssociationTableWrapper>();
        if(uniquePhases.size()>0) {

            Boolean phaseCompleted = true;
            for(Integer p : uniquePhases) {
                Decimal thisPhaseDocCounter = 0;
                Decimal thisPhaseFiledDocCounter = 0;

                phaseSelectOptions.add(new SelectOption(string.valueof(p),string.valueof(p)));

                //if(phaseCompleted==true) {
                    for(ServiceAssignment_Document_JO__c s : sadjos) {
                        if(p==s.Document__r.Phase_or_Level__c.intValue()) {
                            if(s.File_Status__c=='Not Filed' || s.File_Status__c==null){
                                phaseCompleted = false;
                            }
                            else {
                                thisPhaseFiledDocCounter++;
                            }
                            thisPhaseDocCounter++;
                        }
                    }
                    if(phaseCompleted==true) {
                        highestCompletedPhase=phaseCounter;
                    }

                //}

                // START: OLD BLOCK FOR DOC COUNTS
                if(p==currentPhase && thisPhaseDocCounter!=0) {
                    currentPhasePercentage = (thisPhaseFiledDocCounter.divide(thisPhaseDocCounter,4)*100).setScale(2);
                    numDocsReceived = thisPhaseFiledDocCounter.intValue();
                    numDocsExpected = thisPhaseDocCounter.intValue();
                }
                // END: OLD BLOCK FOR DOC COUNTS

                Decimal thisPhasePercentage;

                if(thisPhaseDocCounter!=null && thisPhaseDocCounter!=0) {
                        thisPhasePercentage = (thisPhaseFiledDocCounter.divide(thisPhaseDocCounter,4)*100).setScale(2);
                }
                else {
                        thisPhasePercentage = 0;
                }

                programRows.add(new ProgramAssociationTableWrapper(p, thisPhaseDocCounter.intValue(), thisPhaseFiledDocCounter.intValue(), thisPhasePercentage));

                docsRunningCount += thisPhaseDocCounter.intValue();
                docsFiledRunningCount += thisPhaseFiledDocCounter.intValue();

                phaseCounter++;
            }
        }

        Decimal totalPhasePercentage;

        if(docsRunningCount!=null && docsRunningCount!=0) {
            totalPhasePercentage = (docsFiledRunningCount.divide(docsRunningCount,4)*100).setScale(2);
        }
        else {
            totalPhasePercentage = 0;
        }

        programRows.add(new ProgramAssociationTableWrapper(999,docsRunningCount.intValue(),docsFiledRunningCount.intValue(),totalPhasePercentage));
    }
// END: CONSTRUCTOR

// START:  Contract Grid Wrapper Class.  Each instance represents a row in the contract selection grid.
    class ContractWrapper implements Comparable {
        public TMN_Contract__c theContract { get; private set; }
        public Boolean selectedContract { get; set; }
        public Boolean checkedBeforeSave { get; set; }
        public Id xrefId { get; set; }

        public ContractWrapper(TMN_Contract__c aContract, List<ServiceAssignment_Contract_JO__c> xrefList){
            this.theContract = aContract;

            selectedContract = false;
            for(ServiceAssignment_Contract_JO__c checkSacj : xrefList) {
                System.debug('THE TWO IDs: ' + checkSacj.Contract__c + '; ' + theContract.Id);
                if(checkSacj.Contract__c == theContract.Id){
                    this.selectedContract = true;
                    this.xrefId = checkSacj.Id;
                }
            }
        }

        public Integer compareTo(Object compareTo) {
                ContractWrapper contract = (ContractWrapper) compareTo;
                if(theContract.Name==contract.theContract.Name) return 0;
                if(theContract.Name > contract.theContract.Name) return 1;
                return -1;
        }

    }
// END: Contract Grid Wrapper Class.


// START:  Program Association Table Wrapper Class.
        class ProgramAssociationTableWrapper {
                public String paProgramName { get; set; }
                public String paLocation { get; set; }
                public String paServiceLine { get; set; }
                public Integer paPhase { get; set; }
                public Integer paNumDocsReceived { get; set; }
                public Integer paNumDocsExpected { get; set; }
                public Integer paPhaseOfTreatment { get; set; }
                public Decimal paPhasePercentage { get; set; }

                public ProgramAssociationTableWrapper(Integer phase, Integer docsExpected, Integer docsFiled, Decimal phasePercentage) {
                        paPhase = phase;
                        paNumDocsExpected = docsExpected;
                        paNumDocsReceived = docsFiled;
                        paPhasePercentage = phasePercentage;
                }

        }
// END:  Program Association Table Wrapper Class.


// START:  Method for displaying error / message text in the message take on VF page.
    private void addError(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
    }
// END:  Method for displaying error / message text in the message take on VF page.

// START: Objective Worksheet Lists
// There is some duplication here but this is getting very close to release so I don't want to
// break anything
        public boolean showWorksheetBlocks {
                get {
                        return activePlan != null && isRedwood();
                }
        }

    private boolean isRedwood(){
        TMN_User__c[] tmnUsers = [
            SELECT ID, Operating_Group__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:pbsOwner LIMIT 1
        ];
        if (tmnUsers.size() == 0) {
            return false;
        }
        return tmnUsers[0].Operating_Group__c=='Redwood';
    }

    public boolean canCreateWorksheet {
                get {
                        return true;
                }
        }

    public Action_Plan__c activePlan;
    private List<Action_Plan_Worksheet__c> skillws;
    private List<Action_Plan_Worksheet__c> behaviorws;

    public List<Action_Plan_Worksheet__c> SkillWorksheets {
                get {
            return skillws;
                }
        }

//    public PageReference NewSkillWorksheet(){
//        return null;
//    }

        public List<Action_Plan_Worksheet__c> BehaviorWorksheets {
                get {
                        return behaviorws;
                }
        }

    public List<myDate> getuncheckedWeeks(){
        if (activePlan == null) { return null; }
        Date firstMonday = (activePlan.Effective_Date__c - 1).toStartOfWeek() +1;
        Date lastMonday = (activePlan.Target_Date__c != null ? activePlan.Target_Date__c : Date.Today() - 1).toStartOfWeek() +1;
        List<myDate> dates = new List<myDate>();
        Set<Date> existing = new Set<Date>();
        for(Action_Plan_Worksheet__c iter: skillws){
            existing.Add(iter.Start_Date__c);
        }
        for(Date monday=firstMonday;monday <= lastMonday; monday = monday + 7){
            if (!existing.Contains(monday)){
                dates.Add(new myDate(monday));
            }
        }
        return dates;
    }

    public List<myDate> getBehaviorMonthsAvailable(){
        if (activePlan == null) { return null; }
        Date first1day = activePlan.Effective_Date__c.toStartOfMonth();
        Date lastday = activePlan.Target_Date__c != null ? activePlan.Target_Date__c : Date.Today() ;
        List<myDate> dates = new List<myDate>();
        Set<Date> existing = new Set<Date>();
        for(Action_Plan_Worksheet__c iter: Behaviorws){
            existing.Add(iter.Start_Date__c);
        }
        for(Date monday=first1day;monday <= lastday; monday = monday.addmonths(1)){
            if (!existing.Contains(monday)){
                dates.Add(new myDate(monday));
            }
        }
        return dates;
    }

    public class myDate{
        private Date internaldate;

        public myDate(Date initdate){
            internaldate = initdate;
        }

        public string UserDate{
            get { return internaldate.format();}
        }
        public string ParsableDate{
            get { return internaldate.month() + '/' + internaldate.day() + '/' + internaldate.year();}
        }
    }

    public PageReference newSkillWorksheet(){
        if (activePlan == null) { return null; }
        // any preconditions??
        Action_Plan_Worksheet__c newWorksheet = new Action_Plan_Worksheet__c();
        newWorksheet.Action_Plan__c = activePlan.Id;
        newWorksheet.Start_Date__c = Date.Parse(worksheetStartDate);
        newWorksheet.RecordTypeid = [select id from recordtype where name = 'Weekly Skill Result' and SobjectType = 'Action_plan_worksheet__c' limit 1].id;
        insert newWorksheet;
        return new PageReference('/apex/WeeklySkillTracking?id=' + newworksheet.Id);
    }

    public PageReference newBehaviorWorksheet(){
        if (activePlan == null) { return null; }
        // any preconditions??
        Action_Plan_Worksheet__c newWorksheet = new Action_Plan_Worksheet__c();
        newWorksheet.Action_Plan__c = activePlan.Id;
        newWorksheet.Start_Date__c = Date.Parse(worksheetStartDate);
        newWorksheet.RecordTypeid = [select id from recordtype where name = 'Monthly Behavior Result' and SobjectType = 'Action_plan_worksheet__c' limit 1].id;
        insert newWorksheet;
        return new PageReference('/apex/BehaviorTracking?id=' + newworksheet.Id);
    }

// END: Objective Worksheet Lists

// START:  Contract / Service Assignment Cross-Reference Methods
    public PageReference getContractsAndXrefs() {
        try{
            System.debug('What is in theServAssign.Id: ' + theServAssign.Id);

            servAssignContractXrefs = [ SELECT Id, Name, Service_Assignment__c, Contract__c
                                                                        FROM ServiceAssignment_Contract_JO__c
                                                                        WHERE Service_Assignment__c = :theServAssign.Id ];

            List<Service_Assignment__c> listOfServAssignsToGetStateOfAdmission = [ SELECT Admission__r.State__c
                                                                                    FROM Service_Assignment__c WHERE Id = :theServAssign.Id LIMIT 1];
            String stateOfAdmission;

            for(Service_Assignment__c servAssignToGetStateofAdmission : listOfServAssignsToGetStateOfAdmission){
                stateOfAdmission = servAssignToGetStateofAdmission.Admission__r.State__c;
                System.debug('stateOfAdmission: ' + stateOfAdmission);
            }
            contractsForThisServAssignsState = [ SELECT Id, Name FROM TMN_Contract__c
                                                                                        WHERE State__c = :currentState
                                                                                        AND Status__c IN ('Active','Renewed','Approved') ];

            System.debug('contractsForThisServAssignsState: ' + contractsForThisServAssignsState);

            pdxs = [ SELECT Program__c, Document__r.Phase_or_Level__c, Document__r.Order__c  FROM Program_Document_Xref__c
                        WHERE
                            Document__r.Type__c = 'Fidelity Document'
                            AND Program__c = :theServAssign.Program__c
                            AND Service_Line__c = :theServAssign.Service_Line__c
                            ORDER BY Document__r.Phase_or_Level__c, Document__r.Order__c ];

            for(Program_Document_Xref__c p : pdxs) {
                    System.Debug('What is in pdxs: ' + p);
            }



        }
        catch(QueryException e){
            addError('A query for setting up this page did not execute successfully: ' + e.getMessage());
        }
        return null;
    }


    public void loadProgramDocXrefs() {

    }


    public void saveContractSelections() {

      Savepoint sp = Database.setSavepoint();

      try {

        List<ServiceAssignment_Contract_JO__c> theSacjsToDelete = new List<ServiceAssignment_Contract_JO__c>();
        List<ServiceAssignment_Contract_JO__c> newXrefs = new List<ServiceAssignment_Contract_JO__c>();

        for (ContractWrapper c : contractRows) {
            System.debug('IN THE WRAPPER: ' + c.selectedContract);
            if(c.selectedContract==c.checkedBeforeSave){
                //DO NOTHING
            }
            else if (c.selectedContract==false && c.xrefId!=null){

                ServiceAssignment_Contract_JO__c theSacjToDelete = [ SELECT Id, Name FROM ServiceAssignment_Contract_JO__c WHERE Id = :c.xrefId ];

                System.debug('theSacjToDelete = ' + theSacjToDelete);

                theSacjsToDelete.add(theSacjToDelete);
            }
            else if (c.selectedContract==true && c.xrefId==null){
                ServiceAssignment_Contract_JO__c newXref = new ServiceAssignment_Contract_JO__c(
                    Service_Assignment__c = theServAssign.Id,
                    Contract__c = c.theContract.Id
                );
                newXrefs.add(newXref);
            }

        }

        delete theSacjsToDelete;
        insert newXrefs;


        //List<Service_Assignment__c> saListForDocPop = new List<Service_Assignment__c>();
        //saListForDocPop = [ SELECT Id, Name, Person_Being_Served__c, Admission__c, End_Date__c, Projected_Treatment_End_Date__c, Start_Date__c, Location_Region__c, Program__c, Service_Line__c FROM Service_Assignment__c WHERE Id = :theServAssign.Id ];

       // DocumentMethods.docPop(saListForDocPop);



      }
      catch(DmlException e) {
          addError('Could not save changes: ' + e.getMessage());
          Database.rollback(sp);
      }
      //refreshPage = true;

      //PageReference saPage = new ApexPages.StandardController(theServAssign).view();

      //return null;
    }
// END:  Contract / Service Assignment Cross-Reference Methods


// START:  Original and Updated Service Assignment, Program, Location, Service Line, Service Code Methods
    public void LoadData(Service_Assignment__c localRecord){
       currentID = localRecord.Id;
       if(newSA==false) {
            currentRecord = [Select Program__c, RecordType.Name, Service_Line__c, Admission__r.State__c, Location_Region__c, service_location__c  From Service_Assignment__c Where Id = :currentID Limit 1];
            currentState = currentRecord.Admission__r.State__c;
       }
       else {
         currentRecord = theServAssign;
         Admission__c admForState = [ SELECT State__c FROM Admission__c WHERE Id = :admission.Id LIMIT 1 ];
         currentState = admForState.State__c;
       }

        if(recordType=='Assessment Only') {
                AssessmentOnly = true;
        }
        else {
                AssessmentOnly = false;
        }

       SelectedCodes = new Map<Id,Service_Code__c>();

        for(Service_Code__c local : [SELECT Id, Service_Value__c, Start_Date__c, End_Date__c FROM Service_Code__c WHERE
                                        Id IN (SELECT Service_Code__c FROM ServiceAssignment_ServiceCode_JO__c WHERE
                                                Service_Assignment__r.Id = :currentId) ORDER BY Service_Value__c]){

            SelectedCodeIDs.add(local.Id);
            SelectedCodes.put(local.Id,local);
        }

       currentProgram = currentRecord.Program__c;
       currentLocation = currentRecord.Location_Region__c;
       currentServiceLine = currentRecord.Service_Line__c;
       loadAvailableCodes();

       servCodeIdsForXrefsToDelete = new Set<Id>();

       Set<String> tmpProgs = new Set<String>();

           for(Service_Code__c local : [Select Program__c From Service_Code__c where state__c = :currentState ]){
               tmpProgs.Add(Local.Program__c);
           }

           SelectOption SOtmp = new SelectOption('', '--None--');
           MyPrograms.Add(SOtmp);

            for(String local : tmpProgs){
                SelectOption SO = new SelectOption(local, local);
                MyPrograms.Add(SO);
            }

                if ( theservassign.referral__c != null)
            referral = [ select id, name, referral_date__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate from referral__c where id= :theservassign.referral__c ];
        else
            referral = null;

         if (!newSA) {
        admission = [ SELECT Id, Name, State__c, Person_Being_Served__c FROM Admission__c WHERE Id = :theServAssign.Admission__c ];
        plans = [select name, id, createddate, status__c, effective_date__c, target_date__c from Action_Plan__c where Service_Assignment__c = :currentID Order by CreatedDate DESC];
        for(Action_Plan__c aplan: plans){
                if (aplan.Status__c == 'Active Final'){
                        activePlan = aplan;
                        break;
                }
        }
             if (null != activePlan){
                 skillws = [select Action_Plan__r.Name, Start_Date__c
                            from Action_Plan_Worksheet__c
                            where RecordType.Name = 'Weekly Skill Result'
                            and Action_Plan__c = :activePlan.id Order by Start_Date__c DESC];
                 behaviorws = [select Action_Plan__r.Name, Start_Date__c
                               from Action_Plan_Worksheet__c
                               where RecordType.Name = 'Monthly Behavior Result'
                               and Action_Plan__c = :activePlan.id Order by Start_Date__c DESC];
             }
        notes = [select name, id, Start_Time__c, End_time__c, createddate, createdby.name, action_plan__r.Name, Action_plan__c from Progress_Note__c where Service_Assignment__c = :currentID Order by CreatedDate DESC Limit 10];
        diagnoses = [select id, Service_Assignment__r.Name, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c, Effective_Date__c, Comments__c from Diagnosis__c where Service_Assignment__c = :currentID];
        }
        if ( currentrecord.Service_Location__c != null)
            serviceLocation = [ select ID, Name, Setting__c, Street__c, City__c, State__c, Zip__c, Phone__c, Program__c, ProgramID__c, FacilityID__c from Service_Location__c where ID = :currentrecord.Service_Location__c];


    }

    public void loadAvailableCodes () {
       List<Service_Code__c> listAvailableCodes = new List<Service_Code__c>();
       AvailableCodes = new Map<Id,Service_Code__c>();

        listAvailableCodes = [SELECT Id, Service_Code__c, Service_Value__c, Start_Date__c, End_Date__c, Program__c From Service_Code__c
            WHERE Program__c = :currentProgram
                AND
                isActive__c = 1
                AND
            Service_Line__c = :currentServiceLine
                AND
            Location__c= :currentLocation
                AND
            Assessment_Only__c = :AssessmentOnly
                AND
            id NOT IN :SelectedCodeIDs
                AND
            state__c = :currentState
            ORDER BY Service_Value__c];

       for(Service_Code__c sc : listAvailableCodes) {
        AvailableCodes.put(sc.Id,sc);
       }

    }

    public void changeToProgramLocationServiceLine() {
        for(Id s : SelectedCodes.keySet()) {
            servCodeIdsForXrefsToDelete.add(s);
        }
        SelectedCodes.clear();
        loadAvailableCodes();
    }

    public String theProgram { get; set; }

    public List<SelectOption> getMyLocations (){
        List<SelectOption> theLocations = new List<SelectOption>();
        Service_Assignment__c stateOfServAssign = theServAssign;
        Set<String> tmpLocs = new Set<String>();
        SelectOption SOtmp = new SelectOption('', '--None--');
        theLocations.Add(SOtmp);

                for(Service_Code__c local : [Select Location__c From Service_Code__c
                           Where Program__c = :currentProgram
                               AND
                           Assessment_Only__c = :AssessmentOnly
                           AND
                                state__c = :currentState]
                    ){

                       tmpLocs.Add(Local.Location__c);
                }


                for(String local : tmpLocs){
                        SelectOption SO = new SelectOption(local, local);
                        theLocations.Add(SO);
                }

                theLocations.sort();
                return theLocations;

    }


    public List<SelectOption> getMyServiceLines() {
        List<SelectOption> theServiceLines = new List<SelectOption>();
        Service_Assignment__c stateOfServAssign = theServAssign;
        SelectOption SOtmp = new SelectOption('', '--None--');
        theServiceLines.Add(SOtmp);
        Set<String> tmpLocs = new Set<String>();

        for(Service_Code__c local : [Select Location__c, Service_Line__c, Program__c From Service_Code__c
                                        Where Program__c = :currentProgram
                                            AND
                                        Location__c = :currentLocation
                                            AND
                                        Assessment_Only__c = :AssessmentOnly
                                        AND
                                                                state__c = :currentState            ]){
           tmpLocs.Add(local.Service_Line__c);
        }
        for(String local : tmpLocs){
            SelectOption SO = new SelectOption(local, local);
            theServiceLines.Add(SO);
        }

        theServiceLines.sort();
        return theServiceLines;

    }


    public List<ServiceAssignment_ServiceCode_JO__c> getCurrentCodes(){
            CurrentCodes.clear();
            for(ServiceAssignment_ServiceCode_JO__c local : [Select id, Code_Selection_txt__c, Service_Code__r.Start_Date__c, Service_Code__r.End_Date__c, Service_Code__r.id From ServiceAssignment_ServiceCode_JO__c Where Service_Assignment__r.Id = :currentId Order By Code_Selection_txt__c]){
                CurrentCodes.add(local);
                SelectedCodeIDs.add(local.Service_Code__r.id);
            }

        return CurrentCodes;
    }


// END:  Original and Updated Service Assignment, Program, Location, Service Line, Service Code Methods

// START: Methods added by J. Gilliam in August '13 update for page state and saving.
    public void RemoveCode() {
        // Add code to Available codes and remove from Selected codes
        SelectedCodes.remove(SelectedCodeKey);

        Service_Code__c thisCode = [ SELECT Id, Service_Code__c, Service_Value__c, Start_Date__c, End_Date__c, Program__c FROM Service_Code__c WHERE Id = :SelectedCodeID LIMIT 1];

        AvailableCodes.put(thisCode.Id,thisCode);
        servCodeIdsForXrefsToDelete.add(thisCode.Id);
    }

    public void AddCode() {
        // Add code to SelectedCodes and remove from Available codes
        AvailableCodes.remove(SelectedCodeID);

        Service_Code__c thisCode = [ SELECT Id, Service_Code__c, Service_Value__c, Start_Date__c, End_Date__c FROM Service_Code__c WHERE Id = :SelectedCodeID LIMIT 1];

        SelectedCodes.put(thisCode.Id,thisCode);

        Boolean pullIdFromDeletionList = false;
        for(Id i : servCodeIdsForXrefsToDelete) {
            if(thisCode.Id==i) {
                pullIdFromDeletionList = true;
            }
        }
        if(pullIdFromDeletionList==true){
            servCodeIdsForXrefsToDelete.remove(thisCode.Id);
        }

    }

    public void saveServiceCodeSelections() {

        List<ServiceAssignment_ServiceCode_JO__c> alreadySavedCodeXrefs = [ SELECT Service_Code__c FROM ServiceAssignment_ServiceCode_JO__c WHERE Service_Assignment__r.Id = :currentId ];
        List<ServiceAssignment_ServiceCode_JO__c> servCodeXrefsToSave = new List<ServiceAssignment_ServiceCode_JO__c>();
        List<ServiceAssignment_ServiceCode_JO__c> servCodeXrefsToDelete = new List<ServiceAssignment_ServiceCode_JO__c>();

        for(Service_Code__c sc : SelectedCodes.values()) {
            Boolean okToSave = true;
            for(ServiceAssignment_ServiceCode_JO__c alreadySaved : alreadySavedCodeXrefs) {
                if(sc.Id==alreadySaved.Id){
                    okToSave = false;
                }
            }
            if(okToSave == true) {
                ServiceAssignment_ServiceCode_JO__c servCodeXrefToSave = new ServiceAssignment_ServiceCode_JO__c(
                    Service_Code__c = sc.Id,
                    Service_Assignment__c = theServAssign.Id
                );
                servCodeXrefsToSave.add(servCodeXrefToSave);
            }
        }
        insert servCodeXrefsToSave;

        servCodeXrefsToDelete = [ SELECT Id FROM ServiceAssignment_ServiceCode_JO__c WHERE Service_Assignment__r.Id = :currentId AND Service_Code__c = :servCodeIdsForXrefsToDelete ];

        delete servCodeXrefsToDelete;

    }


    public void EditServAssign() {
           editSA = true;
    }

//    public PageReference CreateSummary() {
//        Action_Summary__c report = new Action_Summary__c();
//        report.Service_Assignment__c = theServAssign.id;
//        report.Start_Date__c = Date.today().toStartofMonth();
//        report.End_Date__c = report.Start_Date__c.Addmonths(1);
//        insert report;
//        return new PageReference('/apex/ActionSummaryReport?id=' + report.id);
//    }

//    public PageReference newActionSummary() {
//        return new PageReference('/apex/ActionSummaryCreate');
//    }

//    public List<Action_Summary__c> getSummaries(){
//        return [select status__c, name
//                  from Action_Summary__c
//                 where Service_Assignment__c = :currentrecord.id];
//    }


    public PageReference ResetPage() {

//      ServAssignController.reset();
//        theServAssign = (Service_Assignment__c)ServAssignController.getRecord();
        System.debug('theServAssign: ' + theServAssign);
        System.debug('initialRecord: ' + initialRecord);
        theServAssign = initialRecord;
        LoadData(theServAssign);
        getContractsAndXrefs();
        contractRows = new List<ContractWrapper>();
        for(TMN_Contract__c contract: contractsForThisServAssignsState){
            contractRows.add(new ContractWrapper(contract, servAssignContractXrefs));
        }
        return null;

    }


    public PageReference CancelServAssignEditNew() {
        PageReference backToServAssignPage;
        if(newSA==true) {
                backToServAssignPage = new PageReference('/apex/AdmissionView?id=' + admissionId);
                editSA = false;
        }
        else {
                backToServAssignPage = new PageReference('/apex/ServiceAssignmentEditNew?id=' + theServAssign.Id);
                editSA = false;
        }
        return backToServAssignPage;
    }


    public PageReference SaveServAssign() {

      Savepoint servAssignSaveSp = Database.setSavepoint();

        try {
            Service_Assignment__c s = theServAssign;
            s.Program__c = currentProgram;
            s.Location_Region__c = currentLocation;
            s.Service_Line__c = currentServiceLine;

            System.debug('What is phaseToSave: ' + phaseToSave);
            System.debug('What is s.Phase__c pre-save: ' + s.Phase__c);
            System.debug('s before insert: ' + s);
            if(s.Phase__c > (highestCompletedPhase + 1)) {
                addError('The Phase of Treatment cannot be advanced to the level you selected until all Fidelity Documents for that phase have been filed or waived.');
                List<Service_Assignment__c> phasePreSave = [ SELECT Phase__c FROM Service_Assignment__c WHERE Id = :theServAssign.Id ];
                for(Service_Assignment__c sA : phasePreSave) {
                    theServAssign.Phase__c = sA.Phase__c;
                }
                return null;
            }
            else {
                system.debug('What is s.RecordType.Name before the upsert?: ' + s.RecordType.Name);
                system.debug('What is s.RecordType before the upsert?: ' + s.RecordType);

                 if ( showLocation ){

                       // update program string from service location
                       // System.Debug('Service location is: ' + theservassign.service_location__c);
                        if ( theServAssign.Service_Location__c != null && String.valueOf(theServAssign.Service_Location__c) != '') {

                                Service_Location__c sl = [select id, alias__c, city__c, program__c, service_value__c from service_location__c where id = :theServAssign.Service_Location__c];
                                if (sl != null ) {
                                        s.Program_Detail__c = sl.program__c;
                                        s.Program__c = sl.Alias__c;
                                        s.Location_Region__c = ''; //sl.City__c;
                                        integer dashpos = sl.Service_Value__c.indexOf('-');
                                        
                                        if (dashpos > -1 ) 
                                            s.Service_Line__c = (sl.Service_Value__c).substring(dashpos+1);
                                        else
                                            s.Service_Line__c = sl.Service_Value__c;
                                }
                        }
                } else {
                        s.Program__c = currentProgram;
                        s.Location_Region__c = currentLocation;
                        s.Service_Line__c = currentServiceLine;
                }



                upsert s;

                if ( showDiagnosis )
                    createDiagnoses();
                
                if (!showLocation) {
                    saveServiceCodeSelections();
                    saveContractSelections();
                }

                editSA = false;
                theServAssign = [SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                            End_Date__c, External_ID__c, Location_Region__c, Outcomes__c, Person_Being_Served__c, Phase__c, Phase_of_Treatment__c, Program__c,
                            Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                            Start_Date__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                            Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,
                            Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name, Person_Being_Served__r.OwnerId, referral__c, service_location__c
                                FROM Service_Assignment__c
                                WHERE Id = :s.id];

                LoadData(theServAssign);

                if(theServAssign.RecordType.Name=='Assessment Only') {
                        AssessmentOnly = true;
                }
                else {
                        AssessmentOnly = false;
                }

                System.debug('What is in newSA: ' + newSA);

                if(s.RecordType.Name!='Assessment Only') {
                        if(newSA==false) {
                                DocumentMethods.docPop(theServAssign,'updateDoc');
                        }
                        DocumentMethods.docPop(theServAssign);
                }

                newSA = false;
                ApexPages.Message myMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Service Assignment Saved!');
                ApexPages.addMessage(myMessage);

                //return null;
                PageReference backToServAssignPage = new PageReference('/apex/ServiceAssignmentEditNew?id=' + theServAssign.Id);
                        backToServAssignPage.setRedirect(true);
                        return backToServAssignPage;
            }
        }
        catch(Exception e) {
                addError(e.getMessage());
                Database.rollback(servAssignSaveSp);
                return null;
        }

    }
// END: Methods added by J. Gilliam in August '13 update for page state and saving.
    public id getAck_Overview(){
        id theId;
        theID = [select id, developername from report where developername = 'Action_Plan_Acknowledgment_Overview_Repo' limit 1].id;

        return theId;


    }

    public pagereference NewPlan(){
        action_plan__c AP = new Action_plan__c();
        AP.Service_Assignment__c = this.currentRecord.Id;

        insert AP;

        PageReference ref =  new ApexPages.StandardController(AP).view() ;
        ref.getparameters().put('retURL','/apex/ServiceAssignmentEditNew?id='+this.currentRecord.Id);
        return ref;

    }


    @RemoteAction
    public static Diagnosis__c loadDiagnosis(string diagnosisId) {
            Diagnosis__c dg =
                [select Id, Effective_Date__c, Axis_I__c, Axis_II__c, Axis_III__c, Axis_IV__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Level_of_Disability__c, Comments__c, Service_Assignment__c
                 from Diagnosis__c where id = :diagnosisId];
            return dg;
     }

 @RemoteAction
    public static Service_Location__c loadServiceLocation(string locationId) {
        Service_Location__c loc = [ select ID, Name, Setting__c, Street__c, City__c, State__c, Zip__c, Phone__c, Program__c, ProgramID__c, FacilityID__c from Service_Location__c where ID = :locationId];
        return loc;
    }

    @RemoteAction
    public static boolean saveServiceLocation(string saID, string locID) {
        Service_Assignment__c sa = [ select id, service_location__c from Service_Assignment__c where id = :saID];
        sa.Service_Location__c = locID;
        upsert sa;
        return true;
   }

}