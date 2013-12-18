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
    
// END:  Parent level properties with get/set methods.


// START: CONSTRUCTOR        
    public ServiceAssignmentExt(ApexPages.StandardController controller) {
        
        if(ApexPages.currentPage().getParameters().get('save_new')=='1'){
                pageHeader = 'Add a Service Assignment';
                newSA = true;
                editSA = true;
                theServAssign = new Service_Assignment__c();
                initialRecord = new Service_Assignment__c();
                admission = [ SELECT Id, Name, State__c, Person_Being_Served__c FROM Admission__c WHERE Id = :ApexPages.currentPage().getParameters().get('admissionID') ];
                admissionId = admission.Id;
                theServAssign.Admission__c = admission.Id;
                theServAssign.Name = 'TBD - Autofilled';
                theServAssign.Person_Being_Served__c = admission.Person_Being_Served__c;
                theServAssign.Phase__c = 0;
                recordType = ApexPages.currentPage().getParameters().get('recordType');
                theRecordType = new RecordType();
                theRecordType = [ SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = :recordType LIMIT 1 ];
                theServAssign.RecordTypeId = theRecordType.Id;                  
                //recordTypeId = theServAssign.RecordTypeId;
                initialRecord.Admission__c = admission.Id;
                initialRecord.Name = 'TBD - Autofilled';
                initialRecord.Person_Being_Served__c = admission.Person_Being_Served__c;
                initialRecord.RecordTypeId = theRecordType.Id;                
        }
        else {
                pageHeader = 'Service Assignment Detail';
                newSA = false;
                theServAssign = [SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                            End_Date__c, External_ID__c, Location_Region__c, Outcomes__c, Person_Being_Served__c, Phase__c, Phase_of_Treatment__c, Program__c,
                            Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                            Start_Date__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                            Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,
                            Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name
                                FROM Service_Assignment__c 
                                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];             
                initialRecord = [SELECT Id, Name, Admission__c, Avatar_Upload_ID__c, Billing_System__c, Day_of_last_Note__c,
                            End_Date__c, External_ID__c, Location_Region__c, Outcomes__c, Person_Being_Served__c, Phase__c, Phase_of_Treatment__c, Program__c,
                            Program_Code__c, Program_Detail__c, Projected_Treatment_End_Date__c, SA_Hidden__c, Service_Assignment_Number__c, Service_Line__c,
                            Start_Date__c, Status__c, Admission__r.Person_Being_Served__c, Admission__r.State__c, Phase_1_Start_Date__c, Phase_2_Start_Date__c,
                            Phase_3_Start_Date__c, Phase_4_Start_Date__c, Phase_1_End_Date__c, Phase_2_End_Date__c,
                            Phase_3_End_Date__c, Phase_4_End_Date__c, RecordTypeId, RecordType.Name
                                FROM Service_Assignment__c 
                                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
                admission = [ SELECT Id, Name, State__c, Person_Being_Served__c FROM Admission__c WHERE Id = :theServAssign.Admission__c ];
                admissionId = admission.Id;
                recordType = theServAssign.RecordType.Name;
                recordTypeId = theServAssign.RecordTypeId;
        }
    
        System.debug('recordType BEFORE LoadData: ' + recordType);
        System.debug('AssessmentOnly BEFORE LoadData: ' + AssessmentOnly);
    
        
        LoadData(theServAssign);
        
        System.debug('recordType AFTER LoadData: ' + recordType);
        System.debug('AssessmentOnly AFTER LoadData: ' + AssessmentOnly);       
        
        
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
            currentRecord = [Select Program__c, RecordType.Name, Service_Line__c, Admission__r.State__c, Location_Region__c From Service_Assignment__c Where Id = :currentID Limit 1];
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
                upsert s;
                
                saveContractSelections();
                saveServiceCodeSelections();
                editSA = false;
                theServAssign = s;
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

}