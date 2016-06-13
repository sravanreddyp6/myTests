public without sharing class ServiceAssignmentExt {

    public Service_Assignment__c theServAssign { get; set; }
    public string locationSetting{get;set;}
    public string dischargePopup{get;set;}
    // START:  Parent level properties with get/set methods.
    public Boolean editSA { get; set; }
    public Boolean newSA { get; set; }
    public Boolean disregardSA { get; set; }
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
    public List<Progress_Note__c> caseManagementNotes { get; set; }
    public Boolean canCreatePlan { get; private set;  }
    public Boolean canEditPlan { get; private set; }
    public Boolean canCreateSummary { get; set; }
    public Boolean canEditSA { get; set; }

    public Boolean canViewAuths { get; private set; }
    public Boolean canEditAuths { get; private set; }
    public Boolean canCreateAuths { get; private set; }
    public List<Authorization__c> authList { get; set; }
    public ID authRecTypeId { get; set; }
    public Boolean authsIncDisregard { get; set; }

    public static Boolean showServAssignCloseModal { get; set; }
    public string showServAssignCloseEditId {get; set; }
    public string servAssignCloseEditId { get; set; }
    
   // public string choosenLocationId {get; set;}
    Public Service_Location__c serviceLocation {get; Set;}
    
   /* public Service_Location__c serviceLocation { get{
        if(!newSA && currentRecord.Service_location__c != null && serviceLocation == null){
            serviceLocation = [ select ID, Name, Service_Value__c, Setting__c, Street__c, City__c, State__c, Zip__c, Phone__c, Program__c, ProgramID__c, FacilityID__c, Sum_FS_Attributes__c , Per_Productive_Unit__c,Room_and_Board_Rate__c, PRN_DS_Per_Hour__c,
                    Location_Nickname__c,TMN_Scope__c,Population_Served__c, Physical_Location__c, Service_Type__c, Network_Offering__c  from Service_Location__c where ID = :currentrecord.Service_Location__c]; 
        }else if(newSA && choosenLocationId != null){
            serviceLocation = [ select ID, Name, Service_Value__c, Setting__c, Street__c, City__c, State__c, Zip__c, Phone__c, Program__c, ProgramID__c, FacilityID__c, Sum_FS_Attributes__c , Per_Productive_Unit__c,Room_and_Board_Rate__c, PRN_DS_Per_Hour__c,
                    Location_Nickname__c,TMN_Scope__c,Population_Served__c, Physical_Location__c, Service_Type__c, Network_Offering__c  from Service_Location__c where ID = :choosenLocationId]; 
            
        }
        return serviceLocation;
    } set; }*/

    //Dummy method to set the String value for Querying Service Location
    public void updateLocation(){
        System.debug('-----------' + locationSetting);
    }
    
    //for funding source coverage level
    public list<selectoption> fundingCoverageOptions {get; set;}
    public Boolean hasPrimaryActiveFS {get; set;}

    // Get/set info for contracts
    public List<TMN_Contract__c> contractsForThisServAssignsState { get; set; }
    public List<ServiceAssignment_Contract_JO__c> servAssignContractXrefs {get;set;}
    public List<SelectOption> contractsList { get; set; }
    public String associatedContractID { get; set; }
    public String associatedContractName { get; set; }
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
    public String currentModel { get; set; }
    public String currentProgram { get; set; }
    public string currentProgramID { get; set { if ((currentProgramID == null) ||  !currentProgramID.equals(value) ) { currentProgramID = value; loadAvailableCodesbyID(); }}}
    public String currentLocation { get; set; }
    public String currentServiceLine { get; set; }
    // Dummy obj so that we can bind inputField to dummy Date fields
    public Service_Assignment__c dummy {
        get {
            if (dummy == null) {
                dummy = new Service_Assignment__c();
            }
            return dummy;
        }
        set;
    }
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

    // to support program effective dates
    public Date effDate{ get; set;}
    public Date effEnd { get; set;}
    public void setEffectiveDate( ) {
        loadAvailableCodesbyID();
    }
    // Fidelity Document Properties / Info
    public List<ServiceAssignment_Document_JO__c> sadjos { get; set; }
    public Boolean hasFidDocs { get; set; }
    public List<ProgramAssociationTableWrapper> programRows { get; set; }
    public boolean RWL1 {get; set;}
    private Boolean isRWL1() {
        
        List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()];        
        for ( PermissionSetAssignment p : userperms ) {
            if ( p.PermissionSet.Name.Equals('ESD_Notes_RW_Level_1') ) {
                return true;    
            }
        }
        return false;
    } 
    

    private void setcanEditSA() {
        List<UserRecordAccess> acls = [SELECT RecordId, HasEditAccess
                                       FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.theServAssign.Id ];

        if (acls.size() > 0) {
            canEditSA = acls[0].HasEditAccess;
        } else { canEditSA = false;}

    }
    
    public PageReference redirect() {
		PageReference page;
			page = new PageReference('/apex/ServiceAssignmentView?id=' + theServAssign.Id);
			page.setRedirect(true);
		return page;
	}
	
    Public PageReference gotoAdmissionEditPage(){
        return new PageReference('/apex/AdmissionEdit?id=' + admissionId +'&Mode=Discharged&DischDate='+ effEnd );
    }

    public pagereference gototServAssignViewPage(){
        PageReference backToServAssignPage = new PageReference('/apex/ServiceAssignmentView?id=' + theServAssign.Id);
        backToServAssignPage.setRedirect(true);
        return backToServAssignPage;
    }

    public void checkFullyDischarge(){
        System.debug('------------------'+disregardSA);
        if(disregardSA == false){
            System.debug('--------theServAssign.status__c----------'+theServAssign.status__c + '*********'+ theServAssign.Is_this_transfer_to_another_ServAssign__c);
            if(theServAssign.status__c == 'Inactive' && theServAssign.Is_this_transfer_to_another_ServAssign__c == 'No'){
                dischargePopup = 'true';System.debug('------------------' + dischargePopup);
            }
            else{
                dischargePopup = 'false';
            }
        }

    }



    private void setcanCreatePlan() {
        Schema.DescribeSObjectResult oSchema = Action_Plan__c.sObjectType.getDescribe();
        canCreatePlan = oSchema.IsCreateable();
        canEditPlan = oSchema.IsUpdateable();
        if(currentRecord.Status__c=='Inactive') {
            canCreatePlan = false;
            canEditPlan = false;
        }

    }

    public List<SelectOption> getStatusValues()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Active','Active'));
        options.add(new SelectOption('Inactive','Inactive'));

        if(this.theServAssign.Id!= Null){
            List<Progress_note__c> ProgNotes = [select id, Name, Status__c,service_assignment__c, owner.name,recordtype.developername,disregard_note__c from Progress_Note__c where service_assignment__c= : this.theServAssign.Id ];//and (status__c =: 'Final' or recordtype.developername =: 'Shift_Note' or disregard_note__c =:True)];
            if(ProgNotes.size()>0){
                Boolean AddCIE = False;
                for(progress_note__C pn: ProgNotes){
                    if(pn.disregard_note__c == false){
                        If(pn.status__c == 'Final')
                        AddCIE = True  ;
                    }
                }
                if(AddCIE == false)
                options.add(new SelectOption('Created in Error','Created in Error'));
            }else{
                options.add(new SelectOption('Created in Error','Created in Error'));
            }
        }else{
                options.add(new SelectOption('Created in Error','Created in Error'));

        }


        return options;
    }
    private void setcanCreateSummary() {
        Schema.DescribeSObjectResult oSchema = Action_Summary__c.sObjectType.getDescribe();
        canCreateSummary = oSchema.IsCreateable();
    }
//Model picklist
    public list<Selectoption> modelValues{get{

        if(modelValues == null){
            modelValues = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Service_Assignment__c.Model__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            modelValues.add(new selectOption('--None--', '--None--'));
            for( Schema.PicklistEntry f : ple){
                if(this.theServAssign.Flavor__c == 'CA FSS' && f.getLabel() == 'Family Vistas Intensive In Home' ){
                    continue;
                }
                modelValues.add(new SelectOption(f.getValue(), f.getLabel()));

            }
        }

        return modelValues;

    }
    set;}
    
    //Sravan - End of Service Circumstances - Start
    public list<SelectOption> endOfServiceCsValues{get{
        if(endOfServiceCsValues == null){
            endOfServiceCsValues = new List<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Service_Assignment__c.End_of_Service_Circumstances__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            endOfServiceCsValues.add(new selectOption('', '--None--'));
            string operatingGroup = getOperatingGroup();
            string physicalLocation = null != ServiceLocation.Physical_location__c ? ServiceLocation.Physical_location__c: '';
            string populationServed = null != ServiceLocation.Population_Served__c ? ServiceLocation.Population_Served__c: '';
            for(Schema.PicklistEntry f : ple){
                string label = f.getLabel();
                if((operatingGroup == 'Cambridge' || operatingGroup == 'Redwood' || this.theServAssign.Flavor__c == 'Ludlow')){
                    if(populationServed == 'Child'){
                        if((physicalLocation == 'Host Home' || physicalLocation == 'Group Home' || physicalLocation == 'Facility')){
                            if(label == 'Did not comply with services/poor attendance' || label == 'Family refused services' || label == 'Hospitalization' || label=='No longer in need of services' || label== 'PBS/Family chose another service provider'
                                || label== 'PBS/Guardian chose another service provider' || label== 'Qualified staff not available' || label== 'Relocation' || label== 'Termination of funding' || label== 'Unable to locate to provide services'
                                || label == 'Transferred to comprehensive services' || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other' ){
                                    
                                continue;
                            }
                            
                        }else if(physicalLocation == 'Center Based' || physicalLocation == 'Community Based' || physicalLocation == 'Clinic' || physicalLocation == 'In-Home' || physicalLocation == 'School'){
                            if(label =='Aged out of care' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change' || label == 'Medical needs exceed ability to serve'|| label == 'Moved to a different level of care'
                                || label=='No longer in need of services' || label== 'No Mentor available' || label== 'PBS/Guardian chose another service provider' || label == 'Psychiatric hospitalization' || label == 'State/County moved PBS'
                                || label == 'Transferred to comprehensive services' || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other' ){
                                
                                continue;
                            }
                            
                        }else if(physicalLocation == 'Office - Non-Service'){
                            if(label =='Aged out of care' || label == 'Behavioral needs exceed ability to serve' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change' || label == 'Did not comply with services/poor attendance' || label=='Elopement' || label == 'Hospitalization'
                            	|| label == 'Incarceration' || label == 'No Mentor available'
                                || label == 'PBS/Family chose another service provider'  || label == 'Psychiatric hospitalization' || label == 'State/County moved PBS' || label == 'Medical needs exceed ability to serve'
                                || label == 'No longer in need of services' || label == 'Qualified staff not available' || label == 'Termination of funding' 
                                || label == 'Unable to locate to provide services' || label == 'Transferred to comprehensive services'
                                || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other'){
                                   
                                continue;
                                
                            }
                            
                        }
                        
                    }else if(populationServed == 'Adult' || populationServed == 'Senior'){
                        if(physicalLocation == 'Host Home'){
                            if(label =='Aged out of care' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change'  || label == 'Did not comply with services/poor attendance'|| label == 'Family refused services' || label == 'Hospitalization' 
                                || label== 'PBS/Family chose another service provider' || label== 'Qualified staff not available' || label== 'Relocation' || label== 'Termination of funding' || label== 'Unable to locate to provide services' 
                                || label == 'Transferred to comprehensive services' || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other'){
                                
                                continue;
                            }
                            
                        }else if(physicalLocation == 'Group Home' || physicalLocation == 'Facility'){
                            if(label =='Aged out of care' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change'  || label == 'Did not comply with services/poor attendance'|| label == 'Family refused services' || label == 'Hospitalization'
                                || label== 'No Mentor available' || label== 'PBS/Family chose another service provider' || label == 'Psychiatric hospitalization' 
                                || label== 'Qualified staff not available' || label== 'Relocation' || label== 'Termination of funding' || label== 'Unable to locate to provide services'
                                || label == 'Transferred to comprehensive services' || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other'){
                                    
                                continue;
                                
                            }
                            
                        }else if(physicalLocation == 'Center Based' || physicalLocation == 'Community Based' || physicalLocation == 'Clinic' || physicalLocation == 'In-Home' || physicalLocation == 'School'){
                            if(label =='Aged out of care' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change'  || label=='Elopement' || label == 'No Mentor available'
                                || label== 'PBS/Family chose another service provider'  || label == 'Psychiatric hospitalization' || label == 'State/County moved PBS' || label == 'Medical needs exceed ability to serve'
                                || label == 'Moved to a different level of care' || label=='No longer in need of services' || label == 'Transferred to comprehensive services'
                                || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other'){
                                    
                                continue;
                                
                            }
                            
                        }else if(physicalLocation == 'Office - Non-Service'){
                            if(label =='Aged out of care' || label == 'Behavioral needs exceed ability to serve' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change' || label == 'Did not comply with services/poor attendance' || label=='Elopement' || label == 'Hospitalization'
                            	|| label == 'No Mentor available' || label == 'PBS/Family chose another service provider'  || label == 'Psychiatric hospitalization' 
                                || label == 'State/County moved PBS' || label == 'Medical needs exceed ability to serve' 
                                || label == 'No longer in need of services' || label == 'Qualified staff not available' || label == 'Termination of funding'
                                || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other'){
                                   
                                continue;
                                
                            }
                            
                        }
                            
                    }   
                }else if(operatingGroup == 'NeuroRestorative'){ // Start - Neuro
                    if(label =='Aged out of care' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change' || label == 'Did not comply with services/poor attendance' || label=='Elopement'
                        || label == 'Family refused services' || label == 'Hospitalization' || label== 'No Mentor available' || label== 'PBS/Family chose another service provider' || label == 'Psychiatric hospitalization' || label == 'State/County moved PBS' || label== 'Qualified staff not available' || label == 'Relocation'
                        || label== 'Unable to locate to provide services' || label == 'Transferred to comprehensive services' 
                        || label== 'PBS has not showed up for 6 months'  || label == 'PBS has expressed that they are not interested in the program' || label == 'Other'){
                            
                        continue;
                        
                    }
                    
                } // End Neuro
                else if(operatingGroup == 'Adult Day Health'){ 
                    if(label =='Aged out of care' || label == 'Court decision-custody returned to bio family' || label == 'Court ordered placement change' || label == 'Did not comply with services/poor attendance' || label=='Elopement'
                        || label == 'Incarceration' || label == 'Family refused services' || label == 'Hospitalization' || label== 'No Mentor available' || label == 'Psychiatric hospitalization' || label == 'State/County moved PBS' || label== 'Qualified staff not available'
                        || label== 'Unable to locate to provide services' || label == 'Transferred to comprehensive services'){
                            
                        continue;
                        
                    }
                    
                } 
                
                endOfServiceCsValues.add(new selectOption(f.getValue(), f.getLabel()));
            }
        }
        
        return endOfServiceCsValues;
        
    }   
    set;} // End of - End of Service Circumstances

    public Boolean episodeReq { get { return (admission.state__c == 'NC');} set; }
    public Boolean modelReq { get { return (pOpGroup == 'Cambridge'|| this.theServAssign.Flavor__c == 'CA FSS');} set; }

    public List<Action_Plan__c> getActivePlan(){

        return [Select id From Action_Plan__c where Action_Plan__c.Service_Assignment__c = :currentRecord.id AND Status__c = 'Active Final' Limit 1];
    }

    public List<Assessment__c> getAssessments_Fad(){

        return [select id, Name, Assessment_Date__c, Phase__c, Status__c, Disregard__c from Assessment__c where Type__c = 'FAD Summary' AND Service_Assignment__c = :theServAssign.Id Order By Assessment_Date__c DESC];
    }

    public List<Assessment__c> getAssessments_RestraintReduction (){

        return [select id, Name, Assessment_Date__c, Score__c, Status__c, Disregard__c from Assessment__c where Type__c = 'Restraint Reduction' AND Service_Assignment__c = :theServAssign.Id Order By Assessment_Date__c DESC];
    }

    public List<Service_Assignment_Closure__c> getServAssignCloses() {
        return [ SELECT id, Name, IFCS_Record_Number__c, Status__c FROM Service_Assignment_Closure__c WHERE Service_Assignment__c = :theServAssign.Id ];
    }
    
    public list<Evaluation__c > getSmokingAssessments(){     
        return [select id, name, Status__c, createdDate, lastmodifiedDate from Evaluation__c where ServiceAssignment__c = :theServAssign.id AND RecordType.id= :utility.getEValuationRecordType('Smoking Assessment') Order By createdDate DESC];
    }

    private Boolean pshowDiag, pshowLocation, pshowCodes, pshowServAssignClose, pshowNurseAssessment;
    private string popGroup;
    private static Boolean psetFlags = false;
    public Boolean showCodes { get {
        if (! psetFlags ) {
            psetFlags = setShowFlags();
        }
        return pshowCodes;
    }}
    public Boolean showLocation { get {
        if (! psetFlags ) {
            psetFlags = setShowFlags();
        }
        system.debug('myshowLocation ' + showLocation);
        return pshowLocation;
    }}

    // START: CTEAE-125 and 125; Show Service Assignment Closure on page only if Model of Service Assignment == 'FCT'
    public Boolean showServAssignClose { get {
        if (! psetFlags ) {
            psetFlags = setShowFlags();
        }
        return pshowServAssignClose;
    }}
    // END: CTEAE-125 and 125; Show Service Assignment Closure on page only if Model of Service Assignment == 'FCT'

    public Boolean showNurseAssessment{get {
        if(!psetFlags){
            psetFlags = setShowFlags();
        }
        return pshowNurseAssessment;
    }}

    private Boolean setShowFlags() {
        if (! psetFlags) {

           // pshowDiag = true;

            // START: CTEAE-125 and 125; Show Service Assignment Closure on page only if Model of Service Assignment == 'FCT'
            if(theServAssign.Model__c=='FCT') pshowServAssignClose = true;
            // END: CTEAE-125 and 125; Show Service Assignment Closure on page only if Model of Service Assignment == 'FCT'

            pshowLocation = false;
            pOpGroup = '';

            System.Debug('getting showDiagnosis with SF account = ' + pbsOwner);
            TMN_User__c[] tmnUsers = [
                                      SELECT ID, Operating_Group__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:pbsOwner LIMIT 1
                                      ];
            if (tmnUsers.size() == 0) {
               // pshowDiag = false;
                pshowLocation = false;
                psetFlags = false;
                pshowNurseAssessment = false;
            } else {
                pOpGroup = tmnUsers[0].Operating_Group__c;
                // added NeuroRestorative to show diagnosis for EB-434
              //  pshowDiag = pOpGroup =='Redwood' || pOpGroup =='Cambridge' || pOpGroup == 'Care Meridian' || pOpGroup == 'NeuroRestorative' || this.theServAssign.Flavor__c == 'CA FSS';
                pshowLocation =  ( (pOpGroup =='Redwood' ||this.theServAssign.Flavor__c == 'Ludlow')   && this.theServAssign.Flavor__c != 'CA FSS'); // CTEAE-86 && admission.State__c != 'AZ');
                pshowCodes = ( ( pOpGroup == 'Redwood'  && admission.State__c == 'AZ' && this.theServAssign.Flavor__c != 'Ludlow')
                        || ( pOpGroup != 'Care Meridian'  && pOpGroup != 'Redwood') || this.theServAssign.Flavor__c == 'CA FSS');
                pshowNurseAssessment = (pOpGroup == 'Care Meridian' && this.theServAssign.Flavor__c != 'Ludlow');
                psetFlags = true;
            }

        }
        return psetFlags;
    }
    public void showAddLocation() {
        // empty for action support
    }

    public list<ServiceAssignment_Diagnosis_JO__c> sadiagJOList {get; set;}
    public ServiceAssignment_Diagnosis_JO__c sadiagJO {
        get{
            if(sadiagJO == null)
            sadiagJO = new ServiceAssignment_Diagnosis_JO__c();
            return sadiagJO;
        }
        set;
    }

    public List<SelectOption> pbsDiagnosisList{get{
        if(pbsDiagnosisList ==  null){
            pbsDiagnosisList = new list<SelectOption>();
            pbsDiagnosisList.add(new selectoption('--None--', '--None--'));
            set<string> dedupe = new set<string>();
            for(Diagnosis__c d: [SELECT Id, ICD__c, ICD__r.Name, ICD__r.Icd_Description__c, Effective_Date__c FROM Diagnosis__c WHERE PBS__c = :theServAssign.Person_Being_Served__c AND Status__c = 'Active' order by Effective_Date__c desc]){
                if(dedupe.size() > 0 && dedupe.contains(d.ICD__c)){
                    continue;
                }
                dedupe.add(d.ICD__c);
                pbsDiagnosisList.add(new selectoption(d.Id,d.ICD__r.Name+' - '+(d.ICD__r.Icd_Description__c.length() > 50 ? d.ICD__r.Icd_Description__c.left(50)+'...' : d.ICD__r.Icd_Description__c)));
            }

        }

        return pbsDiagnosisList;
    }
    set;}

    public string selectedDiagnosis {get; set;}

    private void populatesadiagJO(){
    try {
        this.sadiagJOList = [select Id, Service_Assignment__c, Diagnosis__c, Diagnosis__r.ICD__r.Icd_Description__c, Diagnosis__r.ICD__r.Name, ABI_Diagnosis__c, Billable__c, Date_of_Injury__c, Glasgow_Coma_Score_at_Injury__c, Glasgow_Coma_Scale_Severity__c, Injury_Type__c, Injury_type_other__c, Ranking__c
                 from ServiceAssignment_Diagnosis_JO__c
                 where Service_Assignment__c = : this.theServAssign.Id];
      }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
        'An error occurred retrieving Diagnosis information. ' + e.getMessage()));
    }
  }

  public void showAddsadiagJo() {
        populatesadiagJO();
        this.sadiagJO = new ServiceAssignment_Diagnosis_JO__c();
        this.selectedDiagnosis = '--None--';
  }
  public void showEditsadiagJo() {
        string sadiagJOId = ApexPages.CurrentPage().getParameters().get('sadiagJOId');
        this.sadiagJO = [select Id, Service_Assignment__c, Diagnosis__c, ABI_Diagnosis__c, Billable__c, Date_of_Injury__c, Glasgow_Coma_Score_at_Injury__c, Glasgow_Coma_Scale_Severity__c, Injury_Type__c, Injury_Type_Other__c,Ranking__c
                 from ServiceAssignment_Diagnosis_JO__c where id = :sadiagJOId];
        this.selectedDiagnosis = sadiagJO.Diagnosis__c;
  }

  public void savesadiagJo() {
        populatesadiagJO();
        this.sadiagJO = new ServiceAssignment_Diagnosis_JO__c();
        this.selectedDiagnosis = '--None--';
  }

    public list<Funding_Source__c> referralFundingsources {get { return [select id, CreatedDate, name, funding_source__c,Type_of_Coverage__c, Payer_Name__c, recordtype.name, service_being_funded__c, Effective_Date__c,Termination_Date__c,Status__c,Comment__c from funding_source__C where service_Assignment__C = null and Referral__c = :referral.id];} set;}

    public Funding_Source__c fundingSource {
        get{
            if (fundingSource == null && canEditFundingSource) {
                fundingSource = new Funding_Source__c();
                fundingSource.RecordTypeId = Utility.getRecordTypeForFundingSource(getfundingsourceRecordType());
                fundingSource.Service_Assignment__c = this.theServAssign.Id;
            } 
            return fundingSource;
        }
        set; }
    public List<Funding_Source__c> fundingSources { get; set; }

    /*public String fundingSourceRecordType{
        get{
            return 'CareMeridian';
        }
        set;
    }*/

    // END:  Parent level properties with get/set methods.


        public String age {set;get{ return Utility.getAge(theServAssign.Person_Being_Served__r.Age_year__c,theServAssign.Person_Being_Served__r.Age_month__c,theServAssign.Person_Being_Served__r.Age_days__c); }}

    public String getSaStrStartDateTime(){
        String strstartDt = '';
        if (theServAssign.SA_Start_DateTime__c != null)
            strstartDt = theServAssign.SA_Start_DateTime__c.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString() );
        return strstartDt;
    }

    public void setSaStrStartDateTime(String val){
        if (val != null && val != '')
            theServAssign.SA_Start_DateTime__c = getDateTimeFromString(val +':00');
    }

    public list<Therapy_Hour__c> getTherapyList(){
        return [select Id,Appointment_Type__c,End_Time__c,Narrative_Note__c,Number_of_Hours__c,Start_Time__c, Owner.Name, Therapist_Discipline__c
                  from Therapy_Hour__c where Service_Assignment__c = :theServAssign.Id and status__c = 'Approved' order by Start_Time__c desc limit 6];
    }

    // START: CONSTRUCTOR
    public ServiceAssignmentExt(ApexPages.StandardController controller) {
        dischargePopup= 'here';System.debug('----------');
        if( ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().get('save_new')=='1'){
            pageHeader = 'Add a Service Assignment';
            newSA = true;
            //editSA = true;
            theServAssign = new Service_Assignment__c();
            initialRecord = new Service_Assignment__c();
            admission = [ SELECT Id, Name, State__c, Person_Being_Served__c,person_being_served__r.LastName, person_being_served__r.ownerid, person_being_served__r.Flavor__c, Network_Offering__c FROM Admission__c WHERE Id = :ApexPages.currentPage().getParameters().get('admissionID') ];
            admissionId = admission.Id;
            theServAssign.Admission__c = admission.Id;
            theServAssign.Name = 'TBD - Autofilled';
            theServAssign.Program_Detail__c = 'TBD - Autofilled';
            theServAssign.Person_Being_Served__c = admission.Person_Being_Served__c;
            theServAssign.Phase__c = 0;
            theServAssign.Flavor__c = admission.person_being_served__r.Flavor__c;
            recordType = ApexPages.currentPage().getParameters().get('recordType');
            theRecordType = new RecordType();
            theRecordType = [ SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = :recordType LIMIT 1 ];
            theServAssign.RecordTypeId = theRecordType.Id;
            theServAssign.Status__c = 'Active';
            theServAssign.Model__c = 'MENTOR';
            theServAssign.Is_this_transfer_to_another_ServAssign__c='No';
            theServAssign.Service_Ended_via_Business_Divested__c='No';
            //recordTypeId = theServAssign.RecordTypeId;
            initialRecord.Admission__c = admission.Id;
            initialRecord.Name = 'TBD - Autofilled';
            initialRecord.Program_Detail__c = 'TBD - Autofilled';
            initialRecord.Person_Being_Served__c = admission.Person_Being_Served__c;
            initialRecord.RecordTypeId = theRecordType.Id;
            pbsOwner = admission.Person_Being_Served__r.OwnerId;
            
            //choosenLocationId = null;
            //serviceLocation = new Service_location__c();
            
            if (effDate == null) {
                effDate = initialRecord.Start_date__c;
            }
            if (effEnd == null )
                effEnd = initialRecord.End_date__c;
            list<Service_Assignment__c> otherSAforThisAdmission = [SELECT Id, Name, Admission__c FROM Service_Assignment__c WHERE Admission__c = : admissionId and Status__c = 'Active'];
            if(otherSAforThisAdmission.size()>0){
                disregardSA = true;
            }
            else{
                disregardSA = false;
            }
            if(disregardSA == false){
                System.debug('--------theServAssign.status__c----------'+theServAssign.status__c + '*********'+ theServAssign.Is_this_transfer_to_another_ServAssign__c);
                if(theServAssign.status__c == 'Inactive' && theServAssign.Is_this_transfer_to_another_ServAssign__c == 'No'){
                    dischargePopup = 'true';System.debug('------------------' + dischargePopup);
                }
                else{
                    dischargePopup = 'false';
                }
            }
        }
        else {
            pageHeader = 'Service Assignment Detail';
            newSA = false;

            theServAssign = [SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                             End_Date__c, Episode__c, External_ID__c, Location_Region__c, Model__c, Outcomes__c, Person_Being_Served__c,Admission__r.Person_Being_Served__r.LastName,Admission__r.Person_Being_Served__r.FirstName, Phase__c, Phase_of_Treatment__c, Program__c,
                             Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                             Start_Date__c, SA_Start_DateTime__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                             Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,Service_Location__r.Name, Service_Location__r.Alias_lookup__c,
                             Person_Being_Served__r.Name, Person_Being_Served__r.Age__c,Person_Being_Served__r.Age_month__c,Person_Being_Served__r.Age_year__c,Person_Being_Served__r.Age_days__c, Person_Being_Served__r.SSN__c, Person_Being_Served__r.Birthdate,
                             Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name, Person_Being_Served__r.OwnerId, Person_Being_Served__r.AccountId, referral__c, service_location__c, Medical_Record_Number__c, clinician__c,Flavor__c,
                             service_location__r.programid__c, service_location__r.service_value__c,service_location__r.setting__c,
                             Service_Began_via_Acquisition_Company__c, Service_Ended_via_Business_Divested__c, Was_Child_Service_or_Permanency_Goal_met__c, Was_dissatisfaction_reason_for_service_e__c, Who_was_dissatisfied__c,  Primary_Reason_for_Dissatisfaction__c, End_of_Service_Circumstances__c, Educational_Involvement_at_End_of_Servic__c, Highest_Level_of_Education_at_End_of_Ser__c, Total_no_of_Internal_moves_during_Servic__c,
                             Child_Service_Goal__c,Child_Permanency_Goal__c,Educational_Involvement_at_Start__c,Highest_Level_of_Education_at_Start__c,Number_of_Out_of_Home_Placements_Pre_Ser__c,Rancho_Score__c, Was_this_transfer_frm_another_ServAssig__c, Is_this_transfer_to_another_ServAssign__c, Specify_Error__c, Emergency_Placement__c 
                             FROM Service_Assignment__c
                             WHERE Id = :controller.getid()];
            initialRecord = [SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                             End_Date__c, Episode__c, External_ID__c, Location_Region__c, Model__c, Outcomes__c, Person_Being_Served__c,Admission__r.Person_Being_Served__r.LastName,Admission__r.Person_Being_Served__r.FirstName, Phase__c, Phase_of_Treatment__c, Program__c,
                             Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                             Start_Date__c, SA_Start_DateTime__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                             Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,
                             Person_Being_Served__r.Name,Person_Being_Served__r.Age__c,Person_Being_Served__r.Age_month__c,Person_Being_Served__r.Age_year__c,Person_Being_Served__r.Age_days__c, Person_Being_Served__r.SSN__c, Person_Being_Served__r.Birthdate,
                             Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name, Person_Being_Served__r.OwnerId, Person_Being_Served__r.AccountId, referral__c, service_location__c, Medical_Record_Number__c, clinician__c,Flavor__c,
                             service_location__r.programid__c, service_location__r.service_value__c,
                             Service_Began_via_Acquisition_Company__c, Service_Ended_via_Business_Divested__c, Was_Child_Service_or_Permanency_Goal_met__c, Was_dissatisfaction_reason_for_service_e__c, Who_was_dissatisfied__c,  Primary_Reason_for_Dissatisfaction__c, End_of_Service_Circumstances__c, Educational_Involvement_at_End_of_Servic__c, Highest_Level_of_Education_at_End_of_Ser__c, Total_no_of_Internal_moves_during_Servic__c,
                             Child_Service_Goal__c,Child_Permanency_Goal__c,Educational_Involvement_at_Start__c,Highest_Level_of_Education_at_Start__c,Number_of_Out_of_Home_Placements_Pre_Ser__c,Rancho_Score__c, Was_this_transfer_frm_another_ServAssig__c, Is_this_transfer_to_another_ServAssign__c, Specify_Error__c
                             FROM Service_Assignment__c
                             WHERE Id = :controller.getid()];
            admission = [ SELECT Id, Name, State__c, Person_Being_Served__c, Person_Being_Served__r.LastName, Network_Offering__c FROM Admission__c WHERE Id = :theServAssign.Admission__c ];
            admissionId = admission.Id;
            recordType = theServAssign.RecordType.Name;
            recordTypeId = theServAssign.RecordTypeId;
            pbsOwner = theServAssign.Person_Being_Served__r.OwnerId;
            effDate = theServAssign.Start_date__c;
            effEnd = theServAssign.End_date__c;
            locationSetting = theServAssign.service_location__r.setting__c;
            list<Service_Assignment__c> otherSAforThisAdmission = [SELECT Id, Name, Admission__c FROM Service_Assignment__c WHERE Admission__c = : theServAssign.Admission__c and Id !=: controller.getid() and Status__c ='Active' ];
            if(otherSAforThisAdmission.size()>0){
                disregardSA = true;
            }
            else{
                disregardSA = false;
            }
            if(disregardSA == false){
                System.debug('--------theServAssign.status__c----------'+theServAssign.status__c + '*********'+ theServAssign.Is_this_transfer_to_another_ServAssign__c);
                if(theServAssign.status__c == 'Inactive' && theServAssign.Is_this_transfer_to_another_ServAssign__c == 'No'){
                    dischargePopup = 'true';System.debug('------------------' + dischargePopup);
                }
                else{
                    dischargePopup = 'false';
                }
            }
            if( ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().get('edit_link')=='1'){
                //editSA = true;
                EditServAssign(); //Added by Sravan for EC-29 09/05/2014 12:05 PM.
            }
        }

        System.debug('recordType BEFORE LoadData: ' + recordType);
        System.debug('AssessmentOnly BEFORE LoadData: ' + AssessmentOnly);
        System.debug('Start date:' + effDate + ', End date:' + effEnd);


        // CMAUTH
        authsIncDisregard = false;
        setAuthPerms();
        LoadData(theServAssign);

        System.debug('recordType AFTER LoadData: ' + recordType);
        System.debug('AssessmentOnly AFTER LoadData: ' + AssessmentOnly);
        setcanEditSA();
        setcanCreatePlan();
        setcanCreateSummary();

        populateAuths();

        getContractsAndXrefs();
        contractsList = new List<SelectOption>();
        contractsList.add(new SelectOption('','--None--'));
        for(TMN_Contract__c contract: contractsForThisServAssignsState){
            contractsList.add(new SelectOption(contract.id,contract.Name));
        }

        pdxs.sort();

        Set<Integer> uniquePhases = new Set<Integer>();
        for(Program_Document_Xref__c p : pdxs) {
            uniquePhases.add(p.Document__r.Phase_or_Level__c.intValue());
        }

        List<ServiceAssignment_Document_JO__c> sadjos = new List<ServiceAssignment_Document_JO__c>();
        sadjos = [ SELECT Id, Name, Document__r.Phase_or_Level__c, File_Status__c FROM ServiceAssignment_Document_JO__c
                   WHERE Service_Assignment__c = :theServAssign.Id AND Document__r.Type__c = 'Fidelity Document'];

        fundingCoverageOptions = new List<SelectOption>();
        fundingCoverageOptions.add(new SelectOption('','--None--'));
        fundingCoverageOptions.add(new selectOption('Secondary','Secondary'));
        fundingCoverageOptions.add(new selectoption('Tertiary','Tertiary'));
        fundingCoverageOptions.add(new selectoption('Other','Other'));
        hasPrimaryActiveFS = false;

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

        populateSeizures();

        setShiftDocPermissions();
        canAddDiagnosis = Diagnosis__c.sObjectType.getDescribe().isCreateable();
        sadiagJOList = new List<ServiceAssignment_Diagnosis_JO__c>();
       // hasPrimaryDiagJo = false;
       // primaryDiagJoId = null;
        if(!newSA){
            populatesadiagJO();
        }
        
        RWL1 = isRWL1();
        if(this.theServAssign.Flavor__c == 'Oregon'){
        	paList = new List<Service_Assignment_Personal_Agent__c>();
            populatePaList(); //Run this query only for Oregon flavor
        }
    }
    // END: CONSTRUCTOR


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
            return activePlan != null && (isRedwood() || this.theServAssign.Flavor__c == 'Ludlow' );
        }
    }

    private boolean isRedwood(){
        TMN_User__c[] tmnUsers = [ SELECT ID, Operating_Group__c FROM TMN_User__c WHERE Salesforce_User_Account__c=:pbsOwner LIMIT 1 ];
        if (tmnUsers.size() == 0) {
            return false;
        }
        return tmnUsers[0].Operating_Group__c=='Redwood' && this.theServAssign.Flavor__c != 'CA FSS';
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

            if (servAssignContractXrefs.size() > 0){
                associatedContractID = servAssignContractXrefs[0].Contract__c;
                associatedContractName = [SELECT Name FROM TMN_Contract__c WHERE id = :associatedContractID LIMIT 1].Name;
            }

            List<Service_Assignment__c> listOfServAssignsToGetStateOfAdmission = [ SELECT Admission__r.State__c
                                                                                   FROM Service_Assignment__c WHERE Id = :theServAssign.Id LIMIT 1];
            String stateOfAdmission;

            for(Service_Assignment__c servAssignToGetStateofAdmission : listOfServAssignsToGetStateOfAdmission){
                stateOfAdmission = servAssignToGetStateofAdmission.Admission__r.State__c;
                System.debug('stateOfAdmission: ' + stateOfAdmission);
            }
            contractsForThisServAssignsState = [ SELECT Id, Name FROM TMN_Contract__c
                                                 WHERE State__c = :currentState
                                                 AND Status__c IN ('Active','Renewed','Approved') ORDER BY Name ];

            System.debug('contractsForThisServAssignsState: ' + contractsForThisServAssignsState);

            pdxs = [ SELECT Program__c, Document__r.Phase_or_Level__c, Document__r.Order__c  FROM Program_Document_Xref__c
                     WHERE
                     Document__r.Type__c = 'Fidelity Document'
                     AND Program__c = :theServAssign.Program__c
                     //AND Service_Line__c = :theServAssign.Service_Line__c
                     //AND Document__r.State__c = :currentState
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
            List<ServiceAssignment_Contract_JO__c> newXrefs = new List<ServiceAssignment_Contract_JO__c>();

            if ((servAssignContractXrefs.size() > 0 && servAssignContractXrefs[0].Contract__c != associatedContractID && associatedContractID != null) ||  // Contract changed
                    (servAssignContractXrefs.size() == 0 && associatedContractID != null)) {      // New addition
                ServiceAssignment_Contract_JO__c newXref = new ServiceAssignment_Contract_JO__c(Service_Assignment__c = theServAssign.Id,
                        Contract__c = associatedContractID );
                newXrefs.add(newXref);
                delete servAssignContractXrefs;
                insert newXrefs;
            } else if (associatedContractID == null || associatedContractID ==''){
                delete servAssignContractXrefs;
            }

        }
        catch(DmlException e) {
            addError('Could not save changes: ' + e.getMessage());
            Database.rollback(sp);
        }
    }
    // END:  Contract / Service Assignment Cross-Reference Methods


    // START:  Original and Updated Service Assignment, Program, Location, Service Line, Service Code Methods
    public void LoadData(Service_Assignment__c localRecord){
        system.debug('loading data');
        currentID = localRecord.Id;
        if(newSA==false) {
            system.debug('this isnt a new reocrd');
            currentRecord = [Select start_date__c, SA_Start_DateTime__c, end_date__c, Model__c, Program_code__c, Program__c, RecordType.Name, Service_Line__c, Admission__r.State__c, Location_Region__c, service_location__c, Service_Location__r.Service_Value__c, Status__c, clinician__c  From Service_Assignment__c Where Id = :currentID Limit 1];
            currentState = currentRecord.Admission__r.State__c;
        }
        else {
            system.debug('it is a new record');
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

        for(Service_Code__c local : [SELECT Id, program_code__c, Service_Value__c, Start_Date__c, End_Date__c FROM Service_Code__c WHERE
                                     Id IN (SELECT Service_Code__c FROM ServiceAssignment_ServiceCode_JO__c WHERE
                                             Service_Assignment__r.Id = :currentId) ORDER BY Service_Value__c]){

            SelectedCodeIDs.add(local.Id);
            SelectedCodes.put(local.Id,local);
        }

        currentModel = currentRecord.Model__c;
        currentProgram = currentRecord.Program__c;
        currentLocation = currentRecord.Location_Region__c;
        currentServiceLine = currentRecord.Service_Line__c;
        effDate = currentRecord.Start_date__c;
        effEnd = currentRecord.End_date__c;
        currentProgramID = currentRecord.Program_Code__c;
        //       loadAvailableCodesbyID(); - this is called by setting currentProgramID

        servCodeIdsForXrefsToDelete = new Set<Id>();
        // loadProgramList();

        if ( theservassign.referral__c != null)
            referral = [ select id, name, referral_date__c,Has_Evaluation__c, createdbyid, createddate, lastmodifiedbyid, lastmodifieddate,(Select Id, Name FROM Evaluations__r LIMIT 1) from referral__c where id= :theservassign.referral__c ];
        else
            referral = null;

        populateFundingSources();
        if (!newSA) {
            admission = [ SELECT Id, Name, State__c, Person_Being_Served__c, Person_being_served__r.LastName, Network_Offering__c FROM Admission__c WHERE Id = :theServAssign.Admission__c ];
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
            notes = [select name, id, Start_Time__c, End_time__c, createddate, clinician__c,
                        createdby.name, action_plan__r.Name, Action_plan__c, Locked__c, Status__c, Disregard_Note__c
                    from Progress_Note__c
                    where Service_Assignment__c = :currentID
                        and RecordType.Name <> 'Case Management Note' Order by CreatedDate DESC Limit 10];
            caseManagementNotes = [
                select name, id, createddate, CreatedBy.Name, CreatedBy.Id, status__c
                  from Progress_Note__c
                 where Service_Assignment__c = :currentID
                   and RecordType.Name = 'Case Management Note'
                order by CreatedDate DESC Limit 10
            ];
            //diagnoses = [select id, Service_Assignment__r.Name, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c, Effective_Date__c, Comments__c from Diagnosis__c where Service_Assignment__c = :currentID order by createddate desc];
        }
        if ( currentrecord.Service_Location__c != null) {
            serviceLocation = [ select ID, Name, Service_Value__c, Setting__c, Street__c, City__c, State__c, Zip__c, Phone__c, Program__c, ProgramID__c, FacilityID__c, Sum_FS_Attributes__c , Per_Productive_Unit__c,Room_and_Board_Rate__c, PRN_DS_Per_Hour__c,
                    Location_Nickname__c,TMN_Scope__c,Population_Served__c, Physical_Location__c, Service_Type__c, Network_Offering__c  from Service_Location__c where ID = :currentrecord.Service_Location__c];
            currentProgramId = serviceLocation.programID__c;
        }

        //Setting the default value
        if(theServAssign.Highest_Level_of_Education_at_Start__c != null){
            theServAssign.Highest_Level_of_Education_at_End_of_Ser__c = theServAssign.Highest_Level_of_Education_at_Start__c;//Setting the default value

        }
    }

    public void loadProgramList() {
        Set<String> tmpProgs = new Set<String>();
        // 03/28/14 - make sure only pulling programs that are valid as of SA start date
        if (effDate != null ) {
            system.debug( 'Effective date is: ' + effDate);
            for(Service_Code__c local : [Select Program__c From Service_Code__c where state__c = :currentState and (end_date__c > :effdate or end_date__c = null ) ]){
                tmpProgs.Add(Local.Program__c);
            }
        }

        MyPrograms.clear();
        SelectOption SOtmp = new SelectOption('', '--None--');
        MyPrograms.Add(SOtmp);

        for(String local : tmpProgs){
            SelectOption SO = new SelectOption(local, local);
            MyPrograms.Add(SO);
        }


    }

    public void loadAvailableCodesbyID() {

        Date SAStart = effDate;
        Date SAEnd = effEnd;
        if ( SAEnd == null && SAStart != null)
            SAEnd = Date.newInstance( SAStart.Year() + 10, 1, 1);

        List<Service_Code__c> listAvailableCodes = new List<Service_Code__c>();
        AvailableCodes = new Map<Id,Service_Code__c>();

        if ( effDate == null )
            return;

        system.debug( 'loading codes by: ' + currentprogramID + ', effdate: ' + SAStart  + ', effend: ' + SAEnd + ', asmt:' + AssessmentOnly +', state: ' + currentState );
        listAvailableCodes = [
                              SELECT Id, Service_Code__c, Service_Value__c, Start_Date__c, End_Date__c, Program__c From Service_Code__c
                              WHERE Program_code__c = :currentProgramID
                              AND ( end_date__c > :SAStart or end_date__c = null )
                              AND start_date__c <= :SAEnd
                              AND Assessment_Only__c = :AssessmentOnly
                              AND id NOT IN :SelectedCodeIDs
                              AND state__c = :currentState
                              ORDER BY start_date__c desc, Service_Value__c];

        for(Service_Code__c sc : listAvailableCodes) {
            AvailableCodes.put(sc.Id,sc);
        }
    }

    public void loadAvailableCodes () {
        List<Service_Code__c> listAvailableCodes = new List<Service_Code__c>();
        AvailableCodes = new Map<Id,Service_Code__c>();

        listAvailableCodes = [
                              SELECT Id, Service_Code__c, Service_Value__c, Start_Date__c, End_Date__c, Program__c From Service_Code__c
                              WHERE Program__c = :currentProgram
                              AND start_date__c <= :effDate and ( end_date__c > :effDate or end_date__c = null )
                              AND Service_Line__c = :currentServiceLine
                              AND Location__c= :currentLocation
                              AND Assessment_Only__c = :AssessmentOnly
                              AND id NOT IN :SelectedCodeIDs
                              AND state__c = :currentState
                              ORDER BY Service_Value__c];

        for(Service_Code__c sc : listAvailableCodes) {
            AvailableCodes.put(sc.Id,sc);
        }

    }

    // CTEAE-86 change for NC
    public void changeToModel() {

        currentModel = theServAssign.Model__c;

        // set program based on value in model table
        if ( currentModel == 'FCT')
            currentProgram = 'IFCS';
        else if ( currentModel == 'Family Vistas Intensive In Home')
            currentProgram = 'Family Vistas - IIH';
        else
            currentProgram = currentModel;

        System.Debug('model is: ' + currentModel);
        theServAssign.Program__c = currentProgram;
    }

    public void setServiceLocation( ) {
        //theServAssign.service_location__c = newalias;
        system.debug( 'inside setservicelocation');
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

        system.debug('inside get locations ' + currentProgram + ',' + currentSTate + ',' + effDate );
        for(Service_Code__c local : [
                                     SELECT Location__c FROM Service_Code__c
                                     WHERE Program__c = :currentProgram
                                     AND Assessment_Only__c = :AssessmentOnly
                                     AND state__c = :currentState
                                     AND start_date__c <= :effDate and ( end_date__c > :effDate or end_date__c = null)]){
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

        system.debug('inside get service lines ' + currentProgram + ',' + currentLocation + ',' + currentSTate + ',' + effDate );

        for(Service_Code__c local : [
                                     SELECT Location__c, Service_Line__c, Program__c FROM Service_Code__c
                                     WHERE Program__c = :currentProgram
                                     AND Location__c = :currentLocation
                                     AND Assessment_Only__c = :AssessmentOnly
                                     AND state__c = :currentState
                                     AND start_date__c <= :effDate and (end_date__c > :effDate or end_date__c = null)
                                     ]){
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

        List<ServiceAssignment_ServiceCode_JO__c> alreadySavedCodeXrefs = [ SELECT Service_Code__c FROM ServiceAssignment_ServiceCode_JO__c WHERE Service_Assignment__c = :currentId ];
        List<ServiceAssignment_ServiceCode_JO__c> servCodeXrefsToSave = new List<ServiceAssignment_ServiceCode_JO__c>();
        List<ServiceAssignment_ServiceCode_JO__c> servCodeXrefsToDelete = new List<ServiceAssignment_ServiceCode_JO__c>();
        System.Debug( alreadySavedCodeXrefs);

        Boolean okToSave;
        for(Service_Code__c sc : SelectedCodes.values()) {
            okToSave = true;

            // CTEAE-75 - correct issue with compare to already saved service code id, not JO id
            for(ServiceAssignment_ServiceCode_JO__c alreadySaved : alreadySavedCodeXrefs) {
                if(sc.Id==alreadySaved.Service_Code__c){
                    okToSave = false;
                    break;
                }
            }

            if(okToSave) {
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


    public PageReference EditServAssign() {
        setcanEditSA();
        //editSA = canEditSA;
        PageReference ServAssignEditP = new PageReference('/apex/ServiceAssignmentEdit?id=' + theServAssign.Id);
        ServAssignEditP.setRedirect(true);
        return ServAssignEditP;
    }


   /* public PageReference ResetPage() {
        System.debug('theServAssign: ' + theServAssign);
        System.debug('initialRecord: ' + initialRecord);
        theServAssign = initialRecord.clone(true);
        LoadData(theServAssign);
        getContractsAndXrefs();
        contractsList = new List<SelectOption>();
        contractsList.add(new SelectOption('','--None--'));
        for(TMN_Contract__c contract: contractsForThisServAssignsState){
            contractsList.add(new SelectOption(contract.id,contract.Name));
        }
        return null;

    } */


    public PageReference CancelServAssignEditNew() {
        PageReference backToServAssignPage;
        if(newSA==true) {
            backToServAssignPage = new PageReference('/apex/AdmissionView?id=' + admissionId);
            //editSA = false;
        }
        else {
            backToServAssignPage = new PageReference('/apex/ServiceAssignmentView?id=' + theServAssign.Id);
            //editSA = false;
        }
        backToServAssignPage.setRedirect(true); //added by Sravan to flush out the view State 09/04/2014 4:38 PM.
        return backToServAssignPage;
    }
    public PageReference SaveServAssign() {

        List<string> errors = new list<string>();
        string opGroup = getOperatingGroup();

        if(theServAssign.Status__c == null){
            errors.add('Service Assignment Status: You must select a value.');
        }
        if(theServAssign.Status__c != 'Inactive'){
            theServAssign.Highest_Level_of_Education_at_End_of_Ser__c = null;
        }
        if(theServAssign.Status__c == 'Created in Error' && theServAssign.Specify_Error__c == null){
            errors.add('Specify Error: You must select a value.');
        }
        if (theServAssign.Service_Location__c == null || String.valueOf(theServAssign.Service_Location__c) == ''){
            errors.add('Location of Service: You must select a value.');
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Location of Service: You must select a value.'));
            return null; // Without Service Location Value We cannot validate most of the fields
        }
        if(string.isNOTBLANK(theServAssign.Service_Location__c) && newSA){ // For new Service Locations
            this.serviceLocation = [select ID, Name, Service_Value__c, Setting__c, Street__c, City__c, State__c, Zip__c, Phone__c, Program__c, ProgramID__c, FacilityID__c, Sum_FS_Attributes__c , Per_Productive_Unit__c,Room_and_Board_Rate__c, PRN_DS_Per_Hour__c,
                    Location_Nickname__c,TMN_Scope__c,Population_Served__c, Physical_Location__c, Service_Type__c, Network_Offering__c  from Service_Location__c where ID=:theServAssign.Service_Location__c];
        }
        
        if(modelreq && (theServAssign.Model__c == '--None--' || theServAssign.Model__c == null)){
            errors.add('Model: You must select a value.');
        }
        if(theServAssign.SA_Start_DateTime__c == null) {
            errors.add('Start date: You must enter a value.');
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Start date: You must enter a value.'));
            //return null;
        }
        if(theServAssign.Service_Began_via_Acquisition_Company__c == null){
            errors.add('Service Began via Acquisition Company (as of 2016)? : You must enter a value.');
        }
        if(theServAssign.Was_this_transfer_frm_another_ServAssig__c == null){
            errors.add('Was this a transfer from another Service Assignment? : You must enter a value.');
        }
        if((serviceLocation.Network_offering__c == 'ARY' && (opGroup == 'Cambridge' || opGroup == 'Redwood' || this.theServAssign.Flavor__c == 'Ludlow') && (theServAssign.Child_Service_Goal__c == null && theServAssign.Child_Permanency_Goal__c == null) && serviceLocation.TMN_Scope__c == 'Residential')){
            errors.add('Please enter a value for Child Service Goal or Child Permanency Goal');
            //locationsetting = '';
        }
        if((serviceLocation.Network_offering__c == 'ARY' && (opGroup == 'Cambridge' || opGroup == 'Redwood' || this.theServAssign.Flavor__c == 'Ludlow') && (theServAssign.Child_Service_Goal__c == null) && serviceLocation.TMN_Scope__c == 'Non-Residential')){
            errors.add('Please enter a value for Child Service Goal at Start of Service');
            //locationsetting = '';
        }

        if(((opGroup == 'Cambridge' || opGroup == 'Redwood' || opGroup == 'Care Meridian') && serviceLocation.Network_offering__c == 'ARY' && theServAssign.Educational_Involvement_at_Start__c == null)){
            errors.add('Educational Involvement at Start of Service: You must enter a value');
        }

        if(serviceLocation.Network_offering__c == 'ARY' && theServAssign.Highest_Level_of_Education_at_Start__c == null){
            errors.add('Highest level of education at Start of Service: You must enter a value');
        }
        
        if((opGroup == 'Cambridge' && serviceLocation.Network_offering__c == 'ARY' && (serviceLocation.Physical_Location__c == 'Host Home' || serviceLocation.Service_Type__c == 'FCT - Family Centered Treatment') && theServAssign.Number_of_Out_of_Home_Placements_Pre_Ser__c == null)){
            errors.add('Number of Out-of-Home Placements Pre-Service: You must enter a value');
        }
        
        if(theServAssign.Status__c == 'Inactive'){
            if(theServAssign.End_Date__c == null){
                errors.add('End Date : You must enter a value.');
            }
            if(theServAssign.End_Date__c > Date.Today()){
                errors.add('End Date cannot be in the future.');
            }
            if(theServAssign.Service_Ended_via_Business_Divested__c == null){
                errors.add('Service Ended via Business Divested? : You must enter a value.');
            }
            if(theServAssign.Is_this_transfer_to_another_ServAssign__c == null){
                errors.add('Is this a transfer to another Service Assignment? : You must enter a value.');
            }
            if((serviceLocation.Network_offering__c == 'ARY' && (opGroup == 'Cambridge' || opGroup == 'Redwood' || this.theServAssign.Flavor__c == 'Ludlow') && theServAssign.Was_Child_Service_or_Permanency_Goal_met__c == null)){
                errors.add('Was Child Service or Permanency Goal met? : You must enter a value.');
            }
            if((serviceLocation.Network_offering__c == 'ARY' && (opGroup == 'Cambridge' || opGroup == 'Redwood' || opGroup == 'NeuroRestorative' || opGroup == 'Adult Day Health' || this.theServAssign.Flavor__c == 'Ludlow') && theservAssign.Educational_Involvement_at_End_of_Servic__c == null)){
                errors.add('Educational Involvement at End of Service : You must enter a value.');
            }
            if((serviceLocation.Network_offering__c == 'ARY' && (opGroup == 'Cambridge' || opGroup == 'Redwood' || opGroup == 'NeuroRestorative' || this.theServAssign.Flavor__c == 'Ludlow') && theservAssign.Highest_Level_of_Education_at_End_of_Ser__c == null)){
                errors.add('Highest Level of Education at End of Service : You must enter a value.');
            }
            if(opGroup == 'Cambridge' && serviceLocation.Physical_Location__c == 'Host Home' && theservAssign.Total_no_of_Internal_moves_during_Servic__c == null){
                errors.add('Total Number of Internal Moves During Service : You must enter a value.');
            }
            if(theServAssign.Was_dissatisfaction_reason_for_service_e__c == null && (opGroup == 'NeuroRestorative' || opGroup == 'Adult Day Health' || opGroup == 'Cambridge' || opGroup == 'Redwood' || opGroup == 'Care Meridian')){
                errors.add('Was dissatisfaction reason for service ending? : You must enter a value.');
            }
            if(theServAssign.Was_dissatisfaction_reason_for_service_e__c == 'Yes' && theServAssign.Who_was_dissatisfied__c == null){
                errors.add('Who was dissatisfied? : You must enter a value.');
            }
            if(theServAssign.Was_dissatisfaction_reason_for_service_e__c == 'Yes' && theServAssign.Primary_Reason_for_Dissatisfaction__c == null){
                errors.add('Primary Reason for Dissatisfaction : You must enter a value.');
            }
            if(((theServAssign.End_of_Service_Circumstances__c == '' || theServAssign.End_of_Service_Circumstances__c == null) && (opGroup == 'Cambridge' || opGroup == 'Redwood' || opGroup == 'NeuroRestorative' || opGroup == 'Adult Day Health' || this.theServAssign.Flavor__c == 'Ludlow') && ServiceLocation.Network_Offering__c != 'ARY')){
                errors.add('End of Service Circumstances : You must enter a value.');
            }
            if(((theServAssign.End_of_Service_Circumstances__c == '' || theServAssign.End_of_Service_Circumstances__c == null) && (opGroup == 'Cambridge' || opGroup == 'Redwood' || opGroup == 'NeuroRestorative' || this.theServAssign.Flavor__c == 'Ludlow') && ServiceLocation.Network_Offering__c == 'ARY' && theServAssign.Was_Child_Service_or_Permanency_Goal_met__c  == 'No')){
                errors.add('End of Service Circumstances : You must enter a value.');
            }
            if(theServAssign.Is_this_transfer_to_another_ServAssign__c == null){
                errors.add('Service Ended via Business Divested? : You must enter a value.');
            }

            /* PRI- 301
            if(theServAssign.End_of_Service_Status__c == null && opGroup == 'NeuroRestorative'){
                errors.add('End of Service Status : You must enter a value.');
            }
            if(theServAssign.End_of_Service_Status__c =='Other' && theServAssign.Specify_Other__c == null){
                errors.add('Specify Other : You must enter a value.');
            }*/
        }

        if(errors.size() > 0){
            for(string e: errors){
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e));
            }
            return null;
        }

        Savepoint servAssignSaveSp = Database.setSavepoint();

        try {
            Service_Assignment__c s = theServAssign;

            // START: CTEAE-125 & 126:  Service Assignment Closures; prevent closure of FCT Service Assignments if a locked Service Assignment Closure is not presen
            if(s.Model__c == 'FCT') {

                Boolean servAssignCloseFail = false;
                List<Service_Assignment_Closure__c> servAssignCloses = [ SELECT Name, Status__c FROM Service_Assignment_Closure__c WHERE Service_Assignment__c = :s.Id ];

                // If no Service Assignment Closures exist for an FCT Service Assignment, we should not be able to set the Service Assignment to Inactive.
                if(servAssignCloses.size()==0) {
                    servAssignCloseFail = true;
                }

                for(Service_Assignment_Closure__c sac : servAssignCloses) {
                    // Assumption as of release of Service Assignment Closure feature is that only one will exist.  If a Service Assignment Closure with any status
                    // other than 'Locked' is found in this loop, we should set the boolean to true.
                    if(sac.Status__c!='Locked') {
                        servAssignCloseFail = true;
                    }
                }

                if(s.Status__c == 'Inactive' && servAssignCloseFail) {
                    addError('An FCT Service Assignment cannot be made inactive until a Service Assignment Closure has been completed and approved for the Service Assignment.');
                    return null;
                }
            }
            // END: CTEAE-125 & 126:  Service Assignment Closures; prevent closure of FCT Service Assignments if a locked Service Assignment Closure is not present.

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

                // CTEAE-86 - revision to naming
                s.Model__c = currentModel;
                s.Program__c = currentProgram;

                if ( theServAssign.Service_Location__c != null && String.valueOf(theServAssign.Service_Location__c) != '') {

                    Service_Location__c sl = [select id, alias__c, city__c, program__c, service_value__c from service_location__c where id = :theServAssign.Service_Location__c];
                    if (sl != null ) {
                        s.Program_Detail__c = sl.program__c;
                        if ( currentModel == null )
                            s.Program__c = sl.Alias__c;

                        s.Location_Region__c = ''; //sl.City__c;
                        integer dashpos = sl.Service_Value__c.indexOf('-');

                        if (dashpos > -1 )
                            s.Service_Line__c = (sl.Service_Value__c).substring(dashpos+1);
                        else
                            s.Service_Line__c = sl.Service_Value__c;
                    }
                }

                upsert s;

              /*  if ( showDiagnosis )
                    createDiagnoses();*/
                if (!showLocation) {
                    saveContractSelections();
                }

                if (showCodes || !showLocation) {
                    saveServiceCodeSelections();
                }

                //editSA = false;
                theServAssign = [
                                 SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                                 End_Date__c, External_ID__c, Location_Region__c, Model__c, Outcomes__c, Person_Being_Served__c, Phase__c, Phase_of_Treatment__c, Program__c,
                                 Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                                 Start_Date__c, SA_Start_DateTime__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                                 Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,
                                 Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name, Person_Being_Served__r.OwnerId, referral__c, clinician__c,
                                 service_location__c, service_location__r.service_value__c,
                                 Medical_Record_Number__c,
                                 Service_Began_via_Acquisition_Company__c, Service_Ended_via_Business_Divested__c, Was_Child_Service_or_Permanency_Goal_met__c, Was_dissatisfaction_reason_for_service_e__c,Who_was_dissatisfied__c,Primary_Reason_for_Dissatisfaction__c,End_of_Service_Circumstances__c, Educational_Involvement_at_End_of_Servic__c, Highest_Level_of_Education_at_End_of_Ser__c, Total_no_of_Internal_moves_during_Servic__c,
                                 Child_Service_Goal__c,Child_Permanency_Goal__c,Educational_Involvement_at_Start__c,Highest_Level_of_Education_at_Start__c,Number_of_Out_of_Home_Placements_Pre_Ser__c,Rancho_Score__c, Was_this_transfer_frm_another_ServAssig__c, Is_this_transfer_to_another_ServAssign__c, Specify_Error__c
                                 FROM Service_Assignment__c
                                 WHERE Id = :s.id
                                 ];

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
                // ApexPages.Message myMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Service Assignment Saved!');
                // ApexPages.addMessage(myMessage);

                //return null;
                PageReference backToServAssignPage = new PageReference('/apex/ServiceAssignmentView?id=' + theServAssign.Id + '&Mode=Saved');
                backToServAssignPage.setRedirect(true);
                return backToServAssignPage;
            }
        }
        catch(Exception e){
            ApexPages.addMessages(e);
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
        ref.getparameters().put('retURL','/apex/ServiceAssignmentView?id='+this.currentRecord.Id);
        return ref;

    }

    public PageReference addServAssignClose() {
        PageReference ref = new PageReference('/apex/ServiceAssignmentClosureEditView?ServAssignId=' + theServAssign.Id + '&AdmId=' + admissionId + '&PbsId=' + theServAssign.Person_Being_Served__r.Id);
        return ref;
    }



    public Boolean canAddShiftDoc { get; private set; }
    public Boolean canAddCNA { get; private set; }
    public Boolean canAddDiagnosis { get; private set; }

    private void setShiftDocPermissions() {
        canAddShiftDoc = false;
        canAddCNA = false;
        PermissionSetAssignment[] assignments = [
                                                 SELECT Id, PermissionSet.Name
                                                 FROM PermissionSetAssignment
                                                 WHERE AssigneeId = :UserInfo.getUserId()
                                                 ];
        Set<String> permissionSets = new Set<String>();
        for (PermissionSetAssignment assignment: assignments) {
            permissionSets.add(assignment.PermissionSet.Name);
        }

        if (permissionSets.Contains('iServe_Tier_III') || permissionSets.Contains('iServe_Tier_II')) {
            canAddShiftDoc = true;
            canAddCNA = true;
        }

        if (permissionSets.Contains('iServe_Tier_I')) {
            canAddCNA = true;
        }
    }

    public List<Evaluation__c> residentAssessments{
        get{
            if(residentAssessments == null) {
                residentAssessments = [
                                       SELECT ID, Name, LastModifiedDate, Is_Signed__c,Signed_At__c,
                                       Status__c,Owner.Name
                                       FROM Evaluation__c
                                       WHERE ServiceAssignment__c = :theServAssign.Id
                                       AND Recordtype.Name = 'NursesAssessment'
                                       ORDER BY CreatedDate DESC NULLS LAST LIMIT 5
                                       ];
            }
            return residentAssessments;
        }
        set;
    }

    public Boolean getshowResAsmt(){
        List<Evaluation__c> nonDisregard = [SELECT Id from Evaluation__c WHERE Status__c != 'Disregard' AND ServiceAssignment__c = :theServAssign.Id AND RecordType.Name = 'NursesAssessment' LIMIT 1];
        if(nonDisregard.size() > 0){
            return false;
        }
        else{
            return true;
        }
    }
    public List<Evaluation__c> shiftAssessments{
        get{
            if(shiftAssessments == null) {
                shiftAssessments = [
                                    SELECT ID, Name, LastModifiedDate, Is_Signed__c,Signed_At__c, Head_to_Toe_Signed_At__c,
                                    Shift_Start_time__c, Shift_end_time__c, Status__c, Head_to_Toe_Status__c, Owner.Name
                                    FROM Evaluation__c
                                    WHERE ServiceAssignment__c = :theServAssign.Id
                                    AND RecordType.Name = 'CMShiftAssessment'
                                    ORDER BY Shift_Start_Time__c DESC NULLS LAST LIMIT 5
                                    ];
            }
            return shiftAssessments;
        }
        set;
    }
    public List<Evaluation__c> cnaWorkbooks{
        get{
            if(cnaWorkbooks == null) {
                cnaWorkbooks = [
                                SELECT ID, Name, LastModifiedDate, Is_Signed__c,Signed_At__c,
                                Shift_Start_time__c, Shift_end_time__c, Status__c, Owner.Name
                                FROM Evaluation__c
                                WHERE ServiceAssignment__c = :theServAssign.Id
                                AND RecordType.DeveloperName = 'CNA_Workbook'
                                ORDER BY Shift_Start_Time__c DESC LIMIT 5
                                ];
            }
            return cnaWorkbooks;
        }
        set;
    }

    public List<Evaluation__c> restraintEvents{
        get{
            if(restraintEvents == null) {
                restraintEvents = [
                                   SELECT ID, Name, LastModifiedDate, Is_Signed__c,Signed_At__c,
                                   Shift_Start_time__c, Shift_end_time__c, Status__c, Owner.Name
                                   FROM Evaluation__c
                                   WHERE ServiceAssignment__c = :theServAssign.Id
                                   AND RecordType.Name = 'RestraintEvent'
                                   ORDER BY CreatedDate DESC NULLS LAST LIMIT 5
                                   ];
            }
            return restraintEvents;
        }
        set;
    }

    public String getOperatingGroup() {
        return pOpGroup;
    }


    public pageReference addResAsmt(){
        string pbsLastName = this.theServAssign.Admission__r.Person_Being_Served__r.LastName != null ? this.theServAssign.Admission__r.Person_Being_Served__r.LastName : '' ;
        string pbsFirstinitial = this.theServAssign.Admission__r.Person_Being_Served__r.FirstName != null ? this.theServAssign.Admission__r.Person_Being_Served__r.FirstName.substring(0, 1) : '';
        string ownerfirstInitial = userinfo.getFirstName() != null ? userinfo.getFirstName().Substring(0,1) : '';
        string resAsmtName = pbsFirstinitial+'. '+pbsLastName+' - '+DateTime.Now().format('MM/dd/yy') +' - '+'Res.Asmt'+' - '+ownerfirstInitial+'. '+userinfo.getLastName();
        Assessment__c fallAsmt = new Assessment__c(Name=pbsLastName+' Resident Assessment',Type__c ='Resident Assessment',Service_Assignment__c = theServAssign.Id,Admission__c = theServAssign.Admission__c, AccountPerson__c = theServAssign.Person_Being_Served__r.AccountId);


        Savepoint sp = Database.setSavepoint();

        Evaluation__c resAsmt = new Evaluation__c(
                ServiceAssignment__c = theServAssign.Id,
                Name = resAsmtName,
                Status__c = 'Draft',
                RecordtypeId = Utility.getEvaluationRecordType('NursesAssessment')

                );

        try{

            insert resAsmt;
            //Assign Evaluation__c Id to Assessment__c record
            fallAsmt.Evaluation__c = resAsmt.Id;
            insert fallAsmt; // This will invoke the trigger on Assessment__c trigger to execute and create domain results and responses.
        }

        catch(DMLException e) {
            Database.rollback(sp); //Making sure to roll back the Evaluation creation in case of any failure.
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is an error in creating Resident Assessment. Please Contact your Administrator');
            ApexPages.addMessage(myMsg);
            return null;

        }


        //  return new pageReference ('/apex/EvalDynamic?evalId='+resAsmt.Id+'&opGrp=Care Meridian&evalType=Residential');


        if(referral != null && referral.Has_Evaluation__c) { //Prevent null pointer exception
            Id evalOnReferralId = referral.Evaluations__r[0].Id; //Grab the Id of the Existing evaluation record on referral
            //FieldSet copyresponseFields = SObjectType.Evaluation_Response__c.FieldSets.CloneevalResponses; //Calling the Field set
            string query = 'SELECT ';
            FieldSet copyFields = SObjectType.Evaluation__c.FieldSets.NursingAssessment; // Calling the Field set where the about to be cloned fieldvalue paths are stored
            FieldSet behavior = SObjectType.Evaluation__c.FieldSets.Behavior;
            FieldSet respondsTo = SObjectType.Evaluation__c.FieldSets.RespondsTo;
            //FieldSet glasses = SObjectType.Evaluation__c.FieldSets.Glasses;

            set<String> getEvals = new set<String>(); //Collection to store the API names of the Fields which will be used in Query (API_Name_Flag__c)
            for(Schema.FieldSetMember f: copyFields.getFields()) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Name FROM Evaluation__c WHERE Id=:evalOnReferralId';
            sObject existingEval = Database.Query(query);

            for(Schema.FieldSetMember f: copyFields.getFields()){
                if(string.isNOTBLANK(string.Valueof(existingEval.get(f.getFieldPath()))) && !string.Valueof(existingEval.get(f.getFieldPath())).equalsIgnoreCase('false')){
                    getEvals.add(f.getFieldPath());

                }
            }

            string behaviorString = '';
            string respondstoString = '';

            for(Schema.FieldSetMember f: behavior.getFields()){
                if(existingEval.get(f.getFieldPath()) == true){ //Skip those not checked
                    behaviorString += f.getLabel();
                    behaviorString += '; ';
                }

            }

            for(Schema.FieldSetMember f: respondsTo.getFields()){
                if(existingEval.get(f.getFieldPath()) == true){ //Skip those not checked
                    respondstoString += f.getLabel();
                    respondstoString += '; ';
                }
            }

            if(string.isNotBlank(behaviorString) && behaviorString != ''){
                getEvals.add('Behavior'); //Make Sure Behavior ApI_Flag_Name__c is also included
            }

            if(string.isNotBlank(respondstoString) && respondstoString != ''){
                getEvals.add('RespondsTo');//Make Sure RespondsTo ApI_Flag_Name__c is also included
            }


            set<string> responseRectypes = new set<string>{'Pressure Ulcer Detail','Wound Detail'};
            FieldSet copyresponseFields = SObjectType.Evaluation_Response__c.FieldSets.CloneevalResponses;
            list<Evaluation_Response__c> clonedResponses = new List<Evaluation_Response__c>();
            set<string> checkResponses = new set<string>();

            String respQuery ='SELECT ';
            for(Schema.FieldSetMember f : copyresponseFields.getFields()) {
                respQuery +=f.getFieldPath() + ', ';
            }

            respQuery += 'Name, RecordType.Name FROM Evaluation_Response__c WHERE Evaluation__c =:evalOnReferralId AND RecordType.Name IN:responseRectypes';
            list<Evaluation_Response__c> evalResponses = database.query(respQuery);

            if(evalResponses!=null){
                for(Evaluation_Response__c erp : evalResponses){
                    Evaluation_Response__c newRecord = erp.clone(false);
                    newRecord.Evaluation__c = resAsmt.Id;
                    checkResponses.add(erp.RecordType.Name); // to check whether to create Eval value record or not
                    clonedResponses.add(newRecord);
                }
            }

            if(checkResponses.contains('Wound Detail')){
                getEvals.add('Wound Detail');//Make sure to include Pressure Ulcer and Wound Detail Sections.
            }

            if(checkResponses.contains('Pressure Ulcer Detail')){
                getEvals.add('Pressure Ulcer Detail');
            }


            //Start Eval_Value__c Creation

            List<Eval__c> evalList = [SELECT Id, Category__c,Field_Name__c, category_sequence__c, sub_category__c, API_Name_Flag__c, sub_category_sequence__c, Field_Type__c, Field_Sub_Type__c, length__c FROM Eval__c WHERE API_Name_Flag__c IN: getEvals AND Eval_Type__r.Name = 'Residential'];
            //Logic to generate Unique Section Id based on the Combination of Category and SubCategory
            set<string> cats = new set<string>();
            set<string> subCats = new set<string>();
            set<string> catSubcat = new set<string>();
            Map<string, string> uniqueTimeMap = new Map<string, string>();


            for(Eval__c ee: evalList){
                cats.add(ee.category__c);
                subCats.add(ee.Sub_Category__c);
                catSubcat.add(ee.Category__c+'~'+ee.sub_category__c);
            }

            integer i = 1;
            for(String s: catSubcat){
                uniqueTimeMap.put(s,Userinfo.getUserId()+'-'+DateTime.now().addSeconds(i).getTime());
                i++;
            }

            system.debug('Cat sub cat++++++'+catSubcat);

            //Create Corresponding Eval Value Records
            List<Eval_Value__c> values = new List<Eval_value__c>();
            Eval_Value__c value;

            for(Eval__c eval: evalList) {

                string catSubcatCheck = eval.Category__c+'~'+eval.Sub_Category__c;
                string fieldName = eval.API_Name_Flag__c;

                if(eval.Sub_Category__c != 'Pressure Ulcer Detail' && eval.Sub_Category__c != 'Wound Detail' && fieldName != 'Behavior' && fieldName != 'RespondsTo'){
                    value = new Eval_Value__c();
                    value.Eval__c = eval.Id;
                    value.Eval_Section_Type__c = 'Residential';
                    value.what_id__c = resAsmt.Id;
                    value.what_id_object__c = 'Evaluation__c';

                    if(uniqueTimeMap.keySet().contains(catSubCatCheck)){
                        value.eval_Section_Id__c = uniqueTimeMap.get(catSubCatCheck);
                    }

                    if ( eval.Field_Type__c == 'Boolean'){

                        if (eval.Field_Sub_Type__c == 'Checkbox' || eval.Field_Sub_Type__c == 'Radio') {
                            if ( (Boolean)existingEval.get(fieldName) == true)
                                value.Boolean__c = true;
                            else
                                value.Boolean__c = false;
                        }
                        else if (eval.Field_Sub_Type__c == 'Dropdown'){
                            value.Text_Under_250__c = existingEval.get(fieldName)== true ? '1':'0';
                        }
                    }

                    else if (eval.Field_Type__c == 'Int'){
                        value.Number_No_Decimal__c = (Integer)existingEval.get(fieldName);
                    }
                    else if (eval.Field_Type__c == 'Date'){
                        value.Date_Time__c = Datetime.newInstance( (Date)existingEval.get(fieldName), Time.newInstance(0,0,0,0));
                    }
                    else if (eval.Field_Type__c == 'Datetime' ){
                        value.Date_Time__c = (Datetime)existingEval.get(fieldName);
                    }

                    else if (eval.Field_Type__c == 'String' || eval.Field_Type__c == 'ID' || eval.Field_Type__c == 'Multiselect'
                            || eval.Field_Type__c == 'Dropdown' || eval.Field_Type__c == 'Double' ||
                            eval.Field_Type__c == 'Currency'){

                        if ( eval.length__c > 250 )
                            value.Text_Over_250__c = String.ValueOf(existingEval.get(fieldName));

                        else
                            value.Text_Under_250__c = String.valueOf(existingEval.get(fieldName));

                    }

                    if(eval.Field_Name__C == 'Behavior'){
                        value.Text_Under_250__c = behaviorString;
                    }

                    if(eval.Field_name__c == 'Responds To'){
                        value.Text_Under_250__c = respondstoString;

                    }

                    values.add(value);
                }
                if(fieldName == 'Behavior' && string.isNotBlank(behaviorString) && behaviorString != ''){
                    value = new Eval_Value__c();
                    value.Eval__c = eval.Id;
                    value.Eval_Section_Type__c = 'Residential';
                    value.what_id__c = resAsmt.Id;
                    value.what_id_object__c = 'Evaluation__c';
                    value.eval_Section_Id__c = uniqueTimeMap.get(catSubCatCheck);
                    value.Text_Under_250__c = behaviorString;
                    values.add(value);
                }
                if(fieldName == 'RespondsTo' && string.isNotBlank(respondstoString) && respondstoString != ''){
                    value = new Eval_Value__c();
                    value.Eval__c = eval.Id;
                    value.Eval_Section_Type__c = 'Residential';
                    value.what_id__c = resAsmt.Id;
                    value.what_id_object__c = 'Evaluation__c';
                    value.eval_Section_Id__c = uniqueTimeMap.get(catSubCatCheck);
                    value.Text_Under_250__c = respondstoString;
                    values.add(value);
                }


            }

            List<Eval__c> isValidEvals = [SELECT Id, Field_Name__c, Category__c, Sub_Category__c FROM  Eval__c WHERE Field_name__c = 'IsValid' AND Category__c IN: cats AND Sub_Category__c IN: subCats AND Eval_Type__r.Name = 'Residential'];
            system.debug('The size of isValids +++++' +isValidEvals.size()+isValidEvals);
            for(Eval__c val: isValidEvals){

                String keyCheck = val.Category__c+'~'+val.Sub_category__c;
                if(uniqueTimeMap.keySet().contains(keyCheck)){
                    system.debug('I am in here for++++'+val.Sub_Category__c+val.Id);
                    Eval_Value__c isVal = new Eval_value__c();
                    isVal.Eval__c = val.Id;
                    isVal.Eval_Section_Type__c = 'Residential';
                    isVal.what_id__c = resAsmt.Id;
                    isVal.what_id_object__c = 'Evaluation__c';
                    isVal.eval_Section_Id__c = uniqueTimeMap.get(keyCheck);
                    isval.Boolean__c = false;

                    values.add(isVal);
                }
            }

            try{

                if(clonedResponses.size() > 0){
                    insert clonedResponses;
                }
                if(values.size() > 0 ){
                    insert values;
                }

            }
            catch (DMLException e){

                Database.rollback(sp); //Making sure to roll back the Evaluation creation in case of any failure.
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is an error in creating Resident Assessment. Please Contact your Administrator');
                ApexPages.addMessage(myMsg);
                return null;
            }

        }
        // return to Eval Dynamic Page
        return new pageReference ('/apex/EvalDynamic?evalId='+resAsmt.Id+'&opGrp=Care Meridian&evalType=Residential');
    }



    public PageReference addrestraintEvent(){
        string pbsLastName = this.theServAssign.Admission__r.Person_Being_Served__r.LastName != null ? this.theServAssign.Admission__r.Person_Being_Served__r.LastName : '' ;
        string pbsFirstinitial = this.theServAssign.Admission__r.Person_Being_Served__r.FirstName != null ? this.theServAssign.Admission__r.Person_Being_Served__r.FirstName.substring(0, 1) : '';
        string ownerfirstInitial = userinfo.getFirstName() != null ? userinfo.getFirstName().Substring(0,1) : '';
        string resEventName = pbsFirstinitial+'. '+pbsLastName+' - '+DateTime.Now().format('MM/dd/yy') +' - '+'Res.Event'+' - '+ownerfirstInitial+'. '+userinfo.getLastName();

        Savepoint sp = Database.setSavepoint();
        Evaluation__c restraintEvent = new Evaluation__c(
                ServiceAssignment__c = theServAssign.Id,
                Name = resEventName,
                Status__c = 'Not Restrained',
                RecordtypeId = Utility.getEvaluationRecordType('RestraintEvent')
                );
        try{

            insert restraintEvent;
            return new pageReference ('/apex/EvalDynamic?evalId='+restraintEvent.Id+'&opGrp=Care Meridian&evalType=Restraint Event');
        }
        catch(DMLException e) {
            Database.rollback(sp); //Making sure to roll back the Evaluation creation in case of any failure.
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'There is an error in creating Restraint Event. Please Contact your Administrator');
            ApexPages.addMessage(myMsg);
            return null;
        }
        return null;
    }

    public PageReference createFadAssess(){
        list<Assessment__c> oldAssess = new list<Assessment__c>();
        oldAssess = [select id from assessment__c where type__c ='FAD Summary' AND Service_Assignment__c = :theServAssign.id Order By CreatedDate Desc limit 1];

        Assessment__c assess = new Assessment__c ();
        assess.type__c = 'FAD Summary';
        assess.Admission__c = admission.id;
        assess.Service_Assignment__c = theServAssign.Id;
        assess.Status__c = 'Open';
        if(referral != null && referral.referral_date__c != null){
            assess.referral_date__c = referral.referral_date__c;
        }
        insert assess;

        if(oldAssess.size() > 0){
            map<string, Assessment_Response__c> oldARs = new map<string, Assessment_Response__c>();
            set<string> QuestionsToCopy = new set<string>();
            QuestionsToCopy.add('PC_Name');
            QuestionsToCopy.add('PC_Address');
            QuestionsToCopy.add('PC_Phone_1');
            QuestionsToCopy.add('PC_Phone_2');
            QuestionsToCopy.add('PC_Relationship_to_PBS');
            QuestionsToCopy.add('PC_Phone_1_Type');
            QuestionsToCopy.add('PC_Phone_2_Type');
            QuestionsToCopy.add('PC_Email');
            QuestionsToCopy.add('SC_No_SC');
            QuestionsToCopy.add('SC_Name');
            QuestionsToCopy.add('SC_Address');
            QuestionsToCopy.add('SC_Phone_1');
            QuestionsToCopy.add('SC_Phone_2');
            QuestionsToCopy.add('SC_Relationship_to_PBS');
            QuestionsToCopy.add('SC_Email');
            QuestionsToCopy.add('SC_Phone_1_Type');
            QuestionsToCopy.add('SC_Phone_2_Type');
            QuestionsToCopy.add('PC_Relationship_to_PBS_Other');
            QuestionsToCopy.add('Caregiver_Who_Completed_Assessment');
            QuestionsToCopy.add('SC_Relationship_to_PBS_Other');
            for(Assessment_Response__c item :[select id, name, Question__r.dev_name__c, score__c, rating__c, yes_no__c, response__c from Assessment_Response__c where assessment__c = :oldAssess[0].id AND Question__r.Dev_Name__c in :QuestionsToCopy]){
                oldARs.put(item.Question__r.dev_name__c,item);
            }
            list<Assessment_Response__c> newRes= [select id, name, Question__r.dev_name__c, score__c, rating__c, yes_no__c, response__c from Assessment_Response__c where assessment__c = :assess.id AND Question__r.Dev_Name__c in :QuestionsToCopy];
            for(Assessment_Response__c item: newRes){
                item.score__c = oldARs.get(item.Question__r.dev_name__c).score__c;
                item.rating__c = oldARs.get(item.Question__r.dev_name__c).rating__c;
                item.yes_no__c = oldARs.get(item.Question__r.dev_name__c).yes_no__c;
                item.response__c = oldARs.get(item.Question__r.dev_name__c).response__c ;

            }
            system.debug('here');
            list<Related_Party__c> oldRPs = new list<Related_Party__c>();
            oldRPS = [select name, Assessment__c, Age__c, Gender__c, Relationship_to_Person_Being_Served__c, Relationship_to_Person_Being_Served_Othe__c, Received_FCT_services_before__c from Related_Party__c where Assessment__c = :oldAssess[0].id];
            list<Related_Party__c> newRPs = new list<Related_Party__c>();

            for(Related_Party__c item: oldRPs){
                Related_Party__c tmp = new Related_Party__c();
                tmp = item.clone();
                tmp.Assessment__c = assess.id;
                newRPs.add(tmp);

            }

            update newRes;
            insert newRPs;

        }

        PageReference ref =  new PageReference('/apex/Assessment_FAD_Form?id='+assess.id + '&edit=1&isnew=1');

        return ref;
    }

    public boolean canCreateNote { get {
        Schema.DescribeSObjectResult oSchema = Progress_Note__c.sObjectType.getDescribe();
        return oSchema.isCreateable();
    }}
    public Boolean canCreateCaseManagementNote {
        get {
            return canCreateNote && Schema.SObjectType.Progress_Note__c.fields.getMap().get('Case_Management_Note__c').getDescribe().isUpdateable();
        }
    }
    public boolean canCreateFundingSource { get {
        Schema.DescribeSObjectResult oSchema = Funding_Source__c.sObjectType.getDescribe();
        return oSchema.isCreateable();

    } }

    public boolean canEditFundingSource { get {
        Schema.DescribeSObjectResult oSchema = Funding_Source__c.sObjectType.getDescribe();
        return oSchema.isUpdateable();

    } }
    public boolean canViewFundingSource { get {
        Schema.DescribeSObjectResult oSchema = Funding_Source__c.sObjectType.getDescribe();
        return oSchema.isAccessible();

    } }

    //Incidents creation

    public pageReference createIncident(){
        PageReference pr = new pageReference('/apex/Incident_Form_createEdit');
        pr.getParameters().put('RecordTypeId',Utility.getIncidentRecordType('PBS'));
        pr.getParameters().put('SAid',this.theServAssign.Id);

        return pr;

    }

    public List<Incident__c> incidents{get{
        if(incidents == null){
            incidents = [SELECT Id, Name, Recordtype.name, Status__c FROM Incident__c WHERE Service_Assignment__c =: this.theServAssign.Id];
        }
            return incidents;
    }

        set;
    }

    public void showAddFundingSource() {
        fundingSource = new Funding_Source__c();
        fundingSource.RecordTypeId = Utility.getRecordTypeForFundingSource(getfundingsourceRecordType()); //Dynamically decide which recordtype funding source to create - Sravan for EB-435
        fundingSource.Service_Assignment__c = this.theServAssign.Id;
        if(getfundingsourceRecordType() == 'NeuroRestorative' || getfundingsourceRecordType() == 'Adult Day Health'){
            hasPrimaryActiveFS = false;
            for(Funding_Source__c fs: this.fundingsources){
                if(fs.Type_of_Coverage__c == 'Primary' && (fs.Funding_Source_Status__c == 'Active' || fs.Funding_Source_Status__c =='Active Final')){
                    hasPrimaryActiveFS = true;
                /*  fundingCoverageOptions.add(new selectOption('Secondary','Secondary'));
                    fundingCoverageOptions.add(new selectoption('Tertiary','Tertiary'));
                    fundingCoverageOptions.add(new selectoption('Other','Other'));*/
                }
            }

        }
    }

    public void showEditFundingSource() {
        String query = 'SELECT ';
        Set<String> fields = Schema.SObjectType.Funding_Source__c.fields.getMap().keySet();
        for (String field: fields) {
            query += field + ', ';
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Funding_Source__c WHERE Id=\'' + fundingSource.Id + '\' ORDER BY Type_of_Coverage__c LIMIT 1';
        this.fundingSource = Database.query(query);
        //set<Selectoption> dupeFilter = new Set<selectoption>();
        if(getfundingsourceRecordType() == 'NeuroRestorative' || getfundingsourceRecordType() == 'Adult Day Health'){
            hasPrimaryActiveFS = false;
            for(Funding_Source__c fs: this.fundingsources){
                if(this.fundingSource.Id != fs.Id && fs.Type_of_Coverage__c == 'Primary' && (fs.Funding_Source_Status__c == 'Active' || fs.Funding_Source_Status__c =='Active Final')){
                    hasPrimaryActiveFS = true;
                }
            }

        }

    }

    public void saveFundingSource() {
        System.debug('Before upsert, fundingSource: ' + this.fundingSource);
        // When we use Id fields in conjunction with Visualforce's assignTo, it
        // becomes a blank string - which will trigger a system error (because it's
        // not a valid ID)
        if (String.valueOf(this.fundingSource.Id) == '') {
            this.fundingSource.Id = null;
        }

        try {
            this.fundingSource.Funding_Source_Status__c = 'Active';
            upsert this.fundingSource;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please enter zip code in the format: XXXXX or XXXXX-XXXX'));
        }

        populateFundingSources();
        this.fundingSource = new Funding_Source__c();
        this.fundingSource.RecordTypeId = Utility.getRecordTypeForFundingSource(getfundingsourceRecordType()); //Dynamically decide which recordtype funding source to create - Sravan for EB-435
        this.fundingSource.Service_Assignment__c = this.theServAssign.Id;
    }

    public void finalizeFundingSource(){
        try{

            this.fundingSource.Funding_Source_Status__c = 'Active Final';  //Need to Change When Approval is implemented - Sravan EB-435
            upsert this.fundingSource;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        populateFundingSources();
    }

    public void inactivateFundingSource(){
        try{
            Funding_source__c fs = [SELECT Id, Funding_Source_Status__c FROM Funding_Source__c WHERE Id =:this.fundingSource.Id ]; // To make sure only Funding Status field is in scope.
            fs.Funding_Source_Status__c = 'Inactive';
            update fs;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        populateFundingSources();
    }
    //This method id needed to exactly determine the name of the recordtype since Recordtype names in Funding sources are different from the Operating group names  - Sravan 06/09/2015.
    public string getfundingsourceRecordType(){
        string opGroup = getOperatingGroup();
        if(opGroup == 'Care Meridian'){
            return 'CareMeridian';
        }
        else if(opGroup == 'NeuroRestorative'){
            return 'NeuroRestorative';
        }
        else if(this.theServAssign.Flavor__c == 'Adult Day Health'){
            return 'Adult Day Health';
        }
        else{
            return null; //For now since Service Assignment level funding sources are supported only for CM and NR operating groups.
        }
    }

    @testvisible private void populateFundingSources() {
        this.fundingSources =
                [select id, Payor__c, Funding_Source__c, Funding_Source_ID__c, Status__c, Service_Being_Funded__c, Comment__c, CreatedDate,
                 type_of_coverage__c, payer_name__c, Case_Manager__c, effective_date__c, termination_date__c, recordtype.name, Funding_Source_Status__c
                 from Funding_Source__c
                 where Service_Assignment__c = :this.theServAssign.Id
                 order by Type_of_Coverage__c
                 limit 150];
    }

    // CMAUTH work  - Sept 2015
    public void setauthPerms () {
        Schema.DescribeSObjectResult oSchema = Authorization__c.sObjectType.getDescribe();
        canCreateAuths = oSchema.isCreateable();
        canEditAuths = oSchema.isUpdateable();
        canViewAuths = oSchema.isAccessible();
        string opGroup = getOperatingGroup();

            authRecTypeID = [ select id from RecordType where sobjecttype = 'Authorization__c' and DeveloperName like '%CM%' LIMIT 1].ID;
        

    }

    public void populateAuths() {
        //system.debug( 'SHOW DISREGARD = ' + authsIncDisregard + ', ' + theServAssign.Id);
        ID saID = theServAssign.Id;
        String query = '' + 'select id, funding_Source__c, payer_authorization_id__c, authorization_Status__c, type__c, service_being_Funded_string__c, rate__c, rate_unit__c, level__c, payer_effective_Date__c, payer_end_date__c, received_date_time__c, contract_used__c ' +
                 'from Authorization__c' +
                 ' where funding_source__r.Service_Assignment__c = :saID ' +
                 (authsIncDisregard ? ''  : 'and authorization_status__c != \'Disregard\'') +
                 ' and recordtype.developername != \'Costs_TherapyNR\'   ' +
                 ' order by payer_effective_date__c desc limit 10';
        this.authList = Database.query(query);
    }
    
    public list<authorization__c> getNRCostTherapyAuths(){
        ID saID = theServAssign.Id;
        return [select id, name, Case_Manager__c, Days_Authorized_from__c, Days_Authorized_To__c, Approval_Status__c, Authorization_Status__c, Total_Weekly_Auth_Therapy_Units__c, Auth_Units_Grand_Total__c, Requested_By__c, CreatedDate from authorization__c where recordtype.developername = 'Costs_TherapyNR' and service_assignment__c = :saID order by CreatedDate desc ];
    }


    // END CMAUTH work

    public class MyException extends Exception {}
    
    @RemoteAction
    public static Service_Location__c loadServiceLocation(string locationId) {
        Service_Location__c loc = [ select ID, Name, Setting__c, Street__c, City__c, State__c, Zip__c, Phone__c, Program__c, ProgramID__c, FacilityID__c, Service_Value__c, Network_offering__c, TMN_Scope__c, Service_Type__c, Physical_location__c from Service_Location__c where ID = :locationId];
        return loc;
    }

    @RemoteAction
    public static boolean saveServiceLocation(string saID, string locID) {
        Service_Assignment__c sa = [ select id, service_location__c from Service_Assignment__c where id = :saID];
        sa.Service_Location__c = locID;
        upsert sa;
        return true;
    }


    // EC-87: Seizure Tracking - Start
    public Seizure__c seizure {get;set;}
    public List<Seizure__c> seizures {get;set;}
    public string seizureStart_DateTime {get;set;}
    public string seizureEnd_DateTime {get;set;}

    public void populateSeizures() {
        this.seizures = [select id, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c,
                            Duplicate_Entry__c, Post_seizure_phase__c, Pre_seizure_phase__c, Seizure_Description__c, 
                            Medication_Administered_pre_seizure__c, Medication_Administered_post_seizure__c, Medication_Detail__c
                         from Seizure__c
                         where Service_Assignment__c = : this.theServAssign.Id
                         //And Duplicate_Entry__c = false
                         order by Start_DateTime__c desc limit 6];

        this.seizure = new Seizure__c();
        seizure.Service_Assignment__c = this.theServAssign.Id;
        this.seizure.Observed_By__c = UserInfo.getUserId();
    }
    public void saveSeizure() {
        if (String.valueOf(this.seizure.Id) == '') {
            this.seizure.Id = null;
        }
        this.seizure.Start_DateTime__c = getDateTimeFromString(seizureStart_DateTime);
        this.seizure.End_DateTime__c = getDateTimeFromString(seizureEnd_DateTime);
        upsert this.seizure;
        populateSeizures();
    }
    public void showEditSeizure() {
        string seizureId = ApexPages.CurrentPage().getParameters().get('seizureId');
        this.seizure = [select id, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c,
                            Duplicate_Entry__c, Post_seizure_phase__c, Pre_seizure_phase__c, Seizure_Description__c, 
                            Medication_Administered_pre_seizure__c, Medication_Administered_post_seizure__c, Medication_Detail__c
                        from Seizure__c
                        where id = : seizureId];
    }
    public PageReference newSeizure(){
        this.seizure = new Seizure__c();
        this.seizure.Service_Assignment__c = this.theServAssign.Id;
        this.seizure.Observed_By__c = UserInfo.getUserId();     
        
        return null;
    }

    public static Datetime getDateTimeFromString(String dateTimeStr) {
        //yyyy-MM-dd HH:mm:ss - this is the correct datetime format to return
        string stringDate='';
        try {
            stringDate = dateTimeStr.substring(6,10) + '-' +dateTimeStr.substring(0,2) + '-' + dateTimeStr.substring(3,5) + ' ' + dateTimeStr.substring(11);
            return Datetime.valueOf(stringDate);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid date'));
        }

        return null;
        //return Datetime.valueOfGMT(stringDate);
    }

    @RemoteAction
    public static boolean findDuplicateSeizure(string seizureStart, string seizureEnd, Id saId, Id seizureId) {
        //DateTime st = Datetime.parse(seizureStart);
        //DateTime en = Datetime.parse(seizureEnd);
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
    // EC-87: Seizure Tracking - End
    
    //<---------------------------------------------------EIFB-11 Add Personal Agent Start - Sravan ------------------------------------------------ >
    
    public Service_Assignment_Personal_Agent__c pa {get{
        if(pa == null){
            pa = new Service_Assignment_Personal_Agent__c();
            pa.Status__c = 'Active';
            pa.Service_Assignment__c = this.theServAssign.Id;
        }
        return pa;
    }
        private set;
    }
    
    public List<Service_Assignment_Personal_Agent__c> paList {get; set;}
    public void populatepaList(){
        this.pa = new Service_Assignment_Personal_Agent__c();
        this.caseManagerName = null;
        this.paList = [SELECT Id, From_Date__c, To_Date__c, Personal_Agent__c, Personal_Agent__r.Name, Service_Assignment__c, Status__c FROM Service_Assignment_Personal_Agent__c 
                        WHERE Service_Assignment__c = :this.theServAssign.Id order by Status__c asc, From_Date__c desc];
    }
    
    public void showAddpa(){
        this.pa = new Service_Assignment_Personal_Agent__c();
        this.pa.Status__c = 'Active';
        this.pa.Service_Assignment__c = this.theServAssign.Id;
        this.caseManagerName = null;
    }
    
    public void savePa(){
        try{
        	if(string.isBlank(this.pa.Id)){
        		insert this.pa;
        	}else{
        		update this.pa;
        	}
            //upsert this.pa;
            populatepaList();
            showAddpa();
            this.caseManagers = new List<TMN_User__c>(); //Clearing the View State
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
    }
    
    public void showEditpa(){
        string paId = ApexPages.CurrentPage().getParameters().get('paId');
        this.pa = [SELECT Id, From_Date__c, To_Date__c, Personal_Agent__c, Personal_Agent__r.Name, Service_Assignment__c, Status__c FROM Service_Assignment_Personal_Agent__c 
                        WHERE Id=:paId];
        this.caseManagerName = this.pa.Personal_Agent__r.Name;
    }
    
    public void cancelPa(){
        showAddpa();
        this.caseManagers = new List<TMN_User__c>();
    }
    
    public List<TMN_User__c> caseManagers{get;set;}
    public string caseManagerName {get; set;}
    
    public void showaddCaseManager(){
        this.caseManagers = new List<TMN_User__c>();
        set<id> activePASet = new set<id>();
        for(Service_Assignment_Personal_Agent__c pa: this.paList){
        	if(pa.Status__c == 'Active'){
        		activePASet.add(pa.Personal_Agent__c);
        	}
        }
        if(String.isNOTBLANK(this.theServAssign.Service_location__r.Alias_lookup__c)){ // So the Query does not pull all records - Sravan
            this.caseManagers = [SELECT Id, Name FROM TMN_User__c WHERE (Job_Title__c = 'Case Manager' OR Professional_Title__c = 'Case Manager')AND Job_Status__c = 'Active' AND Alias_lookup__c = :this.theServAssign.Service_location__r.Alias_lookup__c AND ID NOT IN:activePASet order by Name Asc];
        }else{
            this.caseManagers = [SELECT Id, Name FROM TMN_User__c WHERE (Job_Title__c = 'Case Manager' OR Professional_Title__c = 'Case Manager')AND Job_Status__c = 'Active' AND Alias__c = :this.theServAssign.Service_location__r.Name AND ID NOT IN:activePASet order by Name Asc];
        }
        
    }
    
    public void closecaseManager(){
        this.caseManagers = new List<TMN_User__c>(); //Clearing the View State
    }
    //<--------------------------------------------------EIFB-11 Add Personal Agent End ------------------------------------------------------------------- >


    //<-------------------------------Sravan - OR Combined ISP - Start------------------------------------------------------------------------------------- >
    
    
    public pageReference addORISP(){
        Case_Management_Plan__c isp = new Case_Management_Plan__c();
        isp.RecordtypeId = Schema.SObjectType.Case_Management_Plan__c.getRecordTypeInfosByName().get('OR Combined ISP').getRecordTypeId();
        isp.Service_Assignment__c = this.theServAssign.Id;
        isp.Status__c = 'Inactive Draft';
        isp.CDP_Education_Level_Completed__c = this.theServAssign.Highest_Level_of_Education_at_Start__c; //Setting the initial Value
        
        //Populate the Legal Relationships Section
        Case_Management_Plan__c cm = ORcombinedISPController.pullRelatedParties(this.theServAssign.Admission__r.Person_being_Served__c, null, true);
        isp.Leg_Parents__c = cm.Leg_Parents__c;
		isp.Leg_Guardians__c = cm.Leg_Guardians__c;
		isp.Leg_Designated_Representative_Planning__c = cm.Leg_Designated_Representative_Planning__c;
		isp.Leg_Designated_Representative_Employer__c = cm.Leg_Designated_Representative_Employer__c;
		isp.Leg_Representative_Payee__c = cm.Leg_Representative_Payee__c;
		isp.Leg_Conservators__c  = cm.Leg_Conservators__c;
		
		Savepoint sp = Database.setSavepoint();

		try{
        	insert isp;
        	addContibutorNames(isp.id);
		}catch(exception e){
			Database.Rollback(sp);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to create OR ISP record due to '+e.getMessage() + ' at '+e.getStackTraceString()));
			return null;
			
		}
       
        return new PageReference('/apex/ORcombinedISP?id='+isp.id+'&mode=EDIT');
    
    }
    
    public List<Case_Management_Plan__c> orisps{
        get{
            if(orisps == null) {
                orisps = [
                                SELECT ID, Name, LastModifiedDate,Status__c, Owner.Name, CreatedDate
                                FROM Case_Management_Plan__c
                                WHERE Service_Assignment__c = :theServAssign.Id
                                AND RecordType.DeveloperName = 'OR_Combined_ISP' order by createdDate desc
                                ];
            }
            return orisps;
        }
        set;
    }
    

    public void addContibutorNames(id ispId){
    	List<Evaluation_Response__c> contributors = new list<Evaluation_Response__c>();
    	Id ContributorRectypeId = Schema.SObjectType.Evaluation_Response__c.getRecordTypeInfosByName().get('Contributors & Signatures').getRecordTypeId();
    	Evaluation_Response__c typeA = new Evaluation_Response__c(ISP_Contributor_Name__c = theServAssign.Admission__r.Person_being_Served__r.FirstName + ' '+theServAssign.Admission__r.Person_being_Served__r.lastName, 
    																ISP_Title_Relationship_Person__c='Self/Person Receiving Services', ISP_Contributor_Risk_Identification_Tool__c= false,
    																ISP_Signature_Required__c = true, Case_management_Plan__c = ispId, RecordtypeId = ContributorRectypeId, ISP_Type_of_Contributor__c = 'TypeA');
   		contributors.add(typeA);
   	
   		//type B
   		populatePaList();
	   	for(Service_Assignment_Personal_Agent__c pa: this.paList){
		   	Evaluation_Response__c typeB = new Evaluation_Response__c(ISP_Contributor_Name__c = pa.Personal_Agent__r.Name, ISP_Title_Relationship_Person__c='Personal Agent',
		   																					ISP_Contributor_Risk_Identification_Tool__c= false, ISP_Signature_Required__c = true, Case_management_Plan__c = ispId,RecordtypeId = ContributorRectypeId, ISP_Type_of_Contributor__c = 'TypeB');
		   	contributors.add(typeB);
		}
 
   		//type C
   		for(Related_party__c rp: [SELECT Name FROM Related_Party__c WHERE Person_being_Served__c = :theServAssign.Admission__r.Person_being_Served__c AND Type__c = 'Guardian' AND Status__c = 'Active']){
   			Evaluation_Response__c typeC = new Evaluation_Response__c(ISP_Contributor_Name__c = rp.Name, ISP_Title_Relationship_Person__c='Legal Guardian',
   																					ISP_Contributor_Risk_Identification_Tool__c= false, ISP_Signature_Required__c = true, Case_management_Plan__c = ispId, RecordtypeId = ContributorRectypeId, ISP_Type_of_Contributor__c = 'TypeC');
   			contributors.add(typeC);
   		}
   		
   		if(!contributors.isEmpty()){
   			insert contributors;
   		}
   		
    }
    
    //<-------------------------Sravan - OR Combined ISP - End---------------------------------------------------------------------------------------------------------- >

    //Sravan - Diagnosis-SA Junction
    @RemoteAction
    public static boolean savesadiagJORemote(string diagSAJOId, string diagId, string saID, boolean ABI, boolean Billable, string injuryDate, string glasgowInjury, string glasgowSeverity, string injType, string injTypeOther, string rank) {
        ServiceAssignment_Diagnosis_JO__c dg;
        ID newID;
        if (diagSAJOId == '') {

            dg = new ServiceAssignment_Diagnosis_JO__c ( Service_Assignment__c = saID, Diagnosis__c = diagId, ABI_Diagnosis__c = ABI, Billable__c = Billable, Glasgow_Coma_Score_at_Injury__c = glasgowInjury, Glasgow_Coma_Scale_Severity__c = glasgowSeverity, Injury_Type__c = injType, Injury_Type_Other__c = injTypeOther,  Ranking__c = rank);
        }
        else {

            dg = [select Id, Service_Assignment__c, Diagnosis__c, ABI_Diagnosis__c, Billable__c, Date_of_Injury__c, Glasgow_Coma_Score_at_Injury__c, Glasgow_Coma_Scale_Severity__c, Injury_Type__c, Injury_Type_Other__c, Ranking__c
                 from ServiceAssignment_Diagnosis_JO__c where id = :diagSAJOId];
           // dg.Service_Assignment__c = saID; - not needed as we are not allowing the reparenting option
            dg.Diagnosis__c = diagId;
            dg.ABI_Diagnosis__c = ABI;
            dg.Billable__c = Billable;
            dg.Glasgow_Coma_Score_at_Injury__c = glasgowInjury;
            dg.Glasgow_Coma_Scale_Severity__c = glasgowSeverity;
            dg.Injury_Type__c = injType;
            dg.Injury_Type_Other__c = injTypeOther;
            dg.Ranking__c = rank;
           // dg.Status__c = status;
            system.debug('updating ' + dg.Id + ', ' + dg);
        }

        dg.Date_of_Injury__c = (!String.isEmpty(injuryDate)) ? Date.parse(injuryDate) : (Date) null;

        upsert dg;
        return true;
    }

    @RemoteAction
    public static string checkErrors(string SAId, string diagSAJOId, string diagnosisId){
        List<ServiceAssignment_Diagnosis_JO__c> primary;
        List<ServiceAssignment_Diagnosis_JO__c> dupeDiagnosis;

        if(diagSAJOId != null){
            dupeDiagnosis = [SELECT Id FROM ServiceAssignment_Diagnosis_JO__c WHERE ID != :diagSAJOId AND Service_Assignment__c = :SAId AND Diagnosis__c = :diagnosisId LIMIT 1];
            primary  = [SELECT Id FROM ServiceAssignment_Diagnosis_JO__c WHERE ID != :diagSAJOId AND Service_Assignment__c = :SAId AND Ranking__c = 'Primary' LIMIT 1];
        }else{
            dupeDiagnosis = [SELECT Id FROM ServiceAssignment_Diagnosis_JO__c WHERE Service_Assignment__c = :SAId AND Diagnosis__c = :diagnosisId LIMIT 1];
            primary  = [SELECT Id FROM ServiceAssignment_Diagnosis_JO__c WHERE Service_Assignment__c = :SAId AND Ranking__c = 'Primary' LIMIT 1];
        }

        if(dupeDiagnosis.size() > 0){
            return 'dupe diagnosis';
        }

        if(primary.size() > 0){
            return 'primary error';
        }

        return 'no error';

    }
    
    @RemoteAction
    public static Boolean checkPAoverlap(string SAId, string saPAId, string PAId, string fromDate, string toDate){
    	Date fromDt = Date.parse(fromDate);
    	List<Service_Assignment_Personal_Agent__c> overlapEntry;
    	if(string.isBlank(toDate)){//for new PA check whether the From Date is between existing PA From and To Date
    		overlapEntry = [SELECT Id FROM Service_Assignment_Personal_Agent__c WHERE Service_Assignment__c = :SAId AND Personal_Agent__c = :PAId AND From_Date__c <= :fromDt AND To_Date__c >= :fromDt AND Id != :saPAId LIMIT 1];
    	}else{
    		Date toDt = Date.Parse(toDate);
    		overlapEntry = [SELECT Id FROM Service_Assignment_Personal_Agent__c WHERE Service_Assignment__c = :SAId AND Personal_Agent__c = :PAId AND ((From_Date__c <= :fromDt AND To_Date__c >= :toDt) OR (From_Date__c >= :fromDt AND To_Date__c <= :toDt)
    						OR (From_Date__c <= :fromDt AND To_Date__c >= :fromDt ) OR (From_Date__c <= :toDt AND To_Date__c >= :toDt)) AND Id != :saPAId LIMIT 1];
    	}
    	if(overlapEntry.size() > 0){
    		return true;
    	}else{
    		return false;
    	}
    	
    }
    
    public decimal itemsCompleted;
    public decimal getItemsCompleted(){
       List<Progress_Meter__c> compItems = [select Items_Complete__c from Progress_Meter__c where WhatId__c = :theServAssign.id LIMIT 1];
       if(compItems != null && compItems.size() > 0) {
            itemsCompleted = compItems[0].Items_Complete__c;
       } else {     
           itemsCompleted = 0;
       }
       return itemsCompleted;
     }    

}