public class DocumentController2 {

    public Document__c myDoc { get; set; }
    public List<TMN_Contract__c> contractsForThisDocumentsStates {get;set;}
    public List<Service_Code__c> servCodeList { get; set; }
    public List<SelectOption> programSelectOptions { get; set; }
//    public List<SelectOption> locationSelectOptions { get; set; }
//    public List<SelectOption> serviceLineSelectOptions { get; set; }
    public List<SelectOption> stateSelectOptions { get; set; }
    public List<Contract_Document_JO__c> contractDocXrefs { get; set; }
    public List<ContractWrapper> contracts { get; set; }
    public List<ContractWrapper> displayedContracts { get; set; }
    public List<Program_Document_Xref__c> programDocXrefs { get; set; }
    public List<ProgramWrapper> programs { get; set; }
    public List<ProgramWrapper> displayedPrograms { get; set; }
    public String baseUrl { get; set; }
    public String pageHeader { get; set; }
    public String currentState { get; set; }
    public String currentProgram { get; set; }
//    public String currentLocation { get; set; }
//    public String currentServiceLine { get; set; }
    public String listState { get; set; }
    public Set<String> setOfPrograms { get; set; }
    public String docType { get; set; }
    public List<SelectOption> docTypeSelectOptions { get; set; }


    public DocumentController2(ApexPages.StandardController controller) {
        
        System.debug('Page Parameters: ' + ApexPages.currentPage().getParameters());
        
        if(ApexPages.currentPage().getParameters().get('save_new')=='1'){
                pageHeader = 'Add a Document';
                myDoc = new Document__c();
        }
        else {
                pageHeader = 'Document Detail';
                myDoc = [SELECT Id, Name, State__c, Required_From_Date__c, Required_To_Date__c, Auto_Include__c,
                                Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c, Active__c, CreatedById,
                                CreatedDate, LastModifiedById, LastModifiedDate, Phase_or_Level__c, Order__c, Type__c FROM Document__c 
                                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];             
        }
        
        getContractsAndXrefs();
        contracts = new List<ContractWrapper>();
        displayedContracts = new List<ContractWrapper>();
        programs = new List<ProgramWrapper>();
        displayedPrograms = new List<ProgramWrapper>();
        List<TMN_Contract__c> contractRecords = [ SELECT Id, Name, State__c FROM TMN_Contract__c ];
        for (TMN_Contract__c contractRecord : contractRecords) {
            contracts.add(new ContractWrapper(contractRecord, contractDocXrefs));
            displayedContracts.add(new ContractWrapper(contractRecord,contractDocXrefs));
        }
        setOfPrograms = new Set<String>();
        /*
        Set<String> setOfLocations = new Set<String>();
        locationSelectOptions = new List<SelectOption>();
        locationSelectOptions.add(new SelectOption('--None--','--None--'));
        Set<String> setOfServiceLines = new Set<String>();
        serviceLineSelectOptions = new List<SelectOption>();
        serviceLineSelectOptions.add(new SelectOption('--None--','--None--'));
        for (Service_Code__c sc : servCodeList) {
            setOfPrograms.add(sc.Program__c);
            setOfLocations.add(sc.Location__c);
            setOfServiceLines.add(sc.Service_Line__c);
        }*/
        setofPrograms.add('IFCS');
        setofPrograms.add('MENTOR');
        setofPrograms.add('Family Vistas - IIH');
        
        for (String prog : setOfPrograms) {
            List<String> allStates = new List<String>();
            List<String> listOfStatesForThisProgram = new List<String>();
            for (Service_Code__c sc : servCodeList) {
                allStates.add(sc.State__c);
                if(sc.Program__c==prog) {
                    listOfStatesForThisProgram.add(sc.State__c);
                }
                
            }            
            Set<String> uniqueStates = new Set<String>();
            Set<String> setOfStatesForThisProgram = new Set<String>();
            setOfStatesForThisProgram.addAll(listOfStatesForThisProgram); 
            stateSelectOptions = new List<SelectOption>();
            stateSelectOptions.add(new SelectOption('--None--','--None--'));
            for(String s : allStates) {
                uniqueStates.add(s);
            }
            List<String> uniqueStatesList = new List<String>();
            uniqueStatesList.addAll(uniqueStates);
            uniqueStatesList.sort();
            for(String u : uniqueStatesList) {
                stateSelectOptions.add(new SelectOption(u,u));
            }
            /*
            for(String s : setOfStatesForThisProgram) {    
                programs.add(new ProgramWrapper(prog,s,programDocXrefs));
                displayedPrograms.add(new ProgramWrapper(prog,s,programDocXrefs));
            } 
            */
            // CTEAE-86- remove state/program association - all programs for all states
            programs.add( new ProgramWrapper ( prog, '', programDocXrefs));
            displayedPrograms.add(new ProgramWrapper(prog,'',programDocXrefs));
            
               
        }   
        
        programSelectOptions = new List<SelectOption>();
        programSelectOptions.add(new SelectOption('--None--','--None--'));
        for (String p : setOfPrograms){
            programSelectOptions.add(new SelectOption(p,p));
        }
        
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        currentState=myDoc.State__c;
        docType = myDoc.Type__c;
        docTypeSelectOptions = new List<SelectOption>();
        docTypeSelectOptions.add(new SelectOption('--None--','--None--'));
        docTypeSelectOptions.add(new SelectOption('Case Document','Case Document'));
        docTypeSelectOptions.add(new SelectOption('Fidelity Document','Fidelity Document'));
        
        if(docType=='Fidelity Document') {
            for(Program_Document_Xref__c p : programDocXrefs) {
                    currentProgram = p.Program__c;
        //            currentLocation = p.Location__c;
        //            currentServiceLine = p.Service_Line__c;
            }  
        }

/*        
        Set<String> locationsForThisProgram = new Set<String>();
        for(ProgramWrapper p : programs) {          
            for(Service_Code__c sc : servCodeList) {
                if(p.programName==sc.Program__c && currentState==sc.State__c && p.programName==currentProgram) {
                    locationsForThisProgram.add(sc.Location__c);
                }
            }
        }
        for(String l : locationsForThisProgram) {
                locationSelectOptions.add(new SelectOption(l,l));
        }        

        serviceLineSelectOptions.add(new SelectOption('--None--','--None--'));
        Set<String> serviceLinesForThisProgramLocationCombo = new Set<String>();
        for(ProgramWrapper p : programs) {
            for(Service_Code__c sc : servCodeList) {
                if(p.programName==sc.Program__c && currentState==sc.State__c && p.programName==currentProgram && sc.Location__c==currentLocation) {
                        serviceLinesForThisProgramLocationCombo.add(sc.Service_Line__c);
                }
            }
        }
        for(String sL : serviceLinesForThisProgramLocationCombo) {
                serviceLineSelectOptions.add(new SelectOption(sL,sL));
        }
  */      
        System.debug('CONSTRUCTOR END, currentState: ' + currentState);
        System.debug('CONSTRUCTOR END, currentProgram: ' + currentProgram);
       // System.debug('CONSTRUCTOR END, currentLocation: ' + currentLocation);
       // System.debug('CONSTRUCTOR END, currentServiceLine: ' + currentServiceLine);  
    }

    private void addError(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
    }
    
    
    class ContractWrapper {
        public TMN_Contract__c data { get; private set; }
        public Boolean selectedContract { get; set; }
        public Boolean checkedBeforeSave { get; set; }
        public Id xrefId { get; set; }
        public String contractState { get; set; }
        
        public ContractWrapper(TMN_Contract__c data, List<Contract_Document_JO__c> xrefList){
            this.data = data;
            
            selectedContract = false;
            for(Contract_Document_JO__c checkCdj : xrefList) {
                System.debug('THE TWO IDs: ' + checkCdj.Document__c + '; ' + data.Id);
                if(checkCdj.Contract__c == data.Id){
                    this.selectedContract = true;
                    this.xrefId = checkCdj.Id;
                }
            }
            
            contractState = data.State__c;
            
        }
    }
    
    class ProgramWrapper {
        public String programName { get; private set;}
        public Boolean selectedProgram { get; set; }
        public Boolean programCheckedBeforeSave { get; set; }
        public Id programXrefId { get; set; }
        public String programState { get; set; }
        //public String programLocation { get; set; }
        //public String programServiceLine { get; set; }
        
        public ProgramWrapper(string p, String s, List<Program_Document_Xref__c> xrefList){
             this.programName = p;
             this.programState = s;
                
             selectedProgram = false;
             for(Program_Document_Xref__c checkPdx : xrefList) {
                if(checkPdx.Program__c == programName){
                    this.selectedProgram = true;
                    this.programXrefId = checkPdx.Id;
          //          programLocation = checkPdx.Location__c;
          //          programServiceLine = checkPdx.Service_Line__c;
                }
            }               
                
        }
    }
    
    public PageReference getContractsAndXrefs(){ 
        
        try{
            contractsForThisDocumentsStates = [ SELECT Id, Name, State__c FROM TMN_Contract__c WHERE State__c = :myDoc.State__c ];
            contractDocXrefs = [ SELECT Id, Name, Contract__c, Document__c FROM Contract_Document_JO__c WHERE Document__c = :myDoc.Id ];
            servCodeList = [ SELECT Program__c, Location__c, Service_Line__c, State__c FROM Service_Code__c ];
            programDocXrefs = [ SELECT Id, Name, Program__c, Location__c, Service_Line__c, Document__c FROM Program_Document_Xref__c WHERE Document__c = :myDoc.Id ];
        }
        catch(QueryException e){
            addError('One or more queries for the setup of this page did not execute properly.  Please contact technical support.');        
        }
        return null;
    }

    public static void save() {}

    public pageReference saveDocInfo() {

      Savepoint sp = Database.setSavepoint();
        
        List<Contract_Document_JO__c> cdjsToDelete = new List<Contract_Document_JO__c>();
        List<Contract_Document_JO__c> newXrefs = new List<Contract_Document_JO__c>();
        List<Program_Document_Xref__c> pdxsToDelete = new List<Program_Document_Xref__c>();
        List<Program_Document_Xref__c> newPdxXrefs = new List<Program_Document_Xref__c>();
        
        myDoc.State__c = currentState;
        myDoc.Type__c = docType;
        myDoc.Name = myDoc.Name;
        myDoc.Active__c = myDoc.Active__c;

        if(docType=='Case Document') {
            myDoc.Phase_or_Level__c = null;
            myDoc.Order__c = null;
            myDoc.Program__c = null;
            myDoc.Service_Line__c = null;
        }
        else {
            myDoc.Relative_Due_Date_Units__c = null;
            myDoc.Relative_Due_Date_UOM__c = null;
            myDoc.Relative_Due_Date_Event__c = null;
            //myDoc.Program__c = currentProgram;
            //myDoc.Service_Line__c = currentServiceLine;
            myDoc.Auto_Include__c = true;
        }

        try {
        	upsert myDoc;
        }
		catch(DmlException e) {
			addError('ERROR in myDoc insert: ' + e.getMessage());
			Database.rollback(sp);		
			return null;
		}        
       
        if(docType=='Case Document') {
	        for (ContractWrapper c : displayedContracts) {
	            if(c.selectedContract==c.checkedBeforeSave){
	                //DO NOTHING
	            }
	            else if (c.selectedContract==false && c.xrefId!=null){
	                
	                Contract_Document_JO__c theCdjToDelete = [ SELECT Id, Name FROM Contract_Document_JO__c WHERE Id = :c.xrefId ];
	                
	                cdjsToDelete.add(theCdjToDelete);
	            }
	            else if (c.selectedContract==true && c.xrefId==null){
	                Contract_Document_JO__c newXref = new Contract_Document_JO__c(
	                    Document__c = myDoc.Id,
	                    Contract__c = c.data.Id
	                );
	                newXrefs.add(newXref);
	            }  
	        }
       	
       		try {
	        	delete cdjsToDelete;
	        	insert newXrefs;
       		}
       		catch(Exception e) {
          		addError('ERROR in Case Document cdjsToDelete delete and/or newXrefs insert: ' + e.getMessage());
          		Database.rollback(sp);        		
          		return null;
       		}
      }
                
        if(docType=='Fidelity Document') {
            if(currentProgram=='') {
                List<Program_Document_Xref__c> xrefProgramDocsForCaseDocsToDelete = new List<Program_Document_Xref__c>();
                xrefProgramDocsForCaseDocsToDelete = [ SELECT Id FROM Program_Document_Xref__c WHERE Document__c = :myDoc.Id AND Location__c != '' AND Service_Line__c != '' ];
                delete xrefProgramDocsForCaseDocsToDelete;
            }
            else {
                List<Program_Document_Xref__c> xrefProgramDocsForCaseDocsToDelete = new List<Program_Document_Xref__c>();
                xrefProgramDocsForCaseDocsToDelete = [ SELECT Id FROM Program_Document_Xref__c WHERE Document__c = :myDoc.Id AND Location__c = '' AND Service_Line__c = '' ];
                delete xrefProgramDocsForCaseDocsToDelete;
                Program_Document_Xref__c newPdxXref = new Program_Document_Xref__c(
                    Document__c = myDoc.Id,
                    Program__c = currentProgram //,
              //      Location__c = currentLocation,
              //      Service_Line__c = currentServiceLine
                );
                newPdxXrefs.add(newPdxXref);            
            }
        }        
        else {
                for (ProgramWrapper p : displayedPrograms) {
                    if(p.selectedProgram==p.programCheckedBeforeSave){
                        //DO NOTHING
                    }
                    else if (p.selectedProgram==false && p.programXrefId!=null && p.programState==currentState){                   
                        Program_Document_Xref__c thePdxToDelete = [ SELECT Id, Name FROM Program_Document_Xref__c WHERE Id = :p.programXrefId ];
                                        
                        pdxsToDelete.add(thePdxToDelete);
                    }
                    else if (p.selectedProgram==true && p.programXrefId==null){
                        Program_Document_Xref__c newPdxXref = new Program_Document_Xref__c(
                            Document__c = myDoc.Id,
                            Program__c = p.programName
                        );
                        newPdxXrefs.add(newPdxXref);
                    }  
                }
        }

      try { 
        delete pdxsToDelete;
        insert newPdxXrefs;
        PageReference backToDocListView = new PageReference('/apex/DocumentListView');
        return backToDocListView;        
      }
      catch(Exception e) {
          addError('Could not save changes: ' + e.getMessage());
          Database.rollback(sp);
          return null;
      }

    }
    
 
     public void updateProgramsAndContracts() {
        programSelectOptions = new List<SelectOption>();
        displayedPrograms.clear();
        programSelectOptions.add(new SelectOption('--None--','--None--'));
        for (ProgramWrapper p : programs){
        	// CTEAE-86 - make programs available to all states
            //if(p.programState==currentState) {
                programSelectOptions.add(new SelectOption(p.programName,p.programName));
                displayedPrograms.add(p);
            //}
        }
        System.Debug(displayedPrograms);
        displayedContracts.clear();
        for (ContractWrapper c : contracts){
            if(c.contractState==currentState) {
                displayedContracts.add(c);
            }
        }
                
        //updateLocations();
        //updateServiceLines();       
    }   
    /*
    public void updateLocations() {
        locationSelectOptions = new List<SelectOption>();
        locationSelectOptions.add(new SelectOption('--None--','--None--'));
        Set<String> locationsForThisProgram = new Set<String>();
        for(ProgramWrapper p : programs) {          
            for(Service_Code__c sc : servCodeList) {
                if(p.programName==sc.Program__c && currentState==sc.State__c && p.programName==currentProgram) {
                    locationsForThisProgram.add(sc.Location__c);
                }
            }
        }
        for(String l : locationsForThisProgram) {
                locationSelectOptions.add(new SelectOption(l,l));
        }
    }
 
 
     public void updateServiceLines() {
        serviceLineSelectOptions = new List<SelectOption>();
        serviceLineSelectOptions.add(new SelectOption('--None--','--None--'));
        Set<String> serviceLinesForThisProgramLocationCombo = new Set<String>();
        for(ProgramWrapper p : programs) {
            for(Service_Code__c sc : servCodeList) {
                if(p.programName==sc.Program__c && currentState==sc.State__c && p.programName==currentProgram && sc.Location__c==currentLocation) {
                        serviceLinesForThisProgramLocationCombo.add(sc.Service_Line__c);
                }
            }
        }
        for(String sL : serviceLinesForThisProgramLocationCombo) {
                serviceLineSelectOptions.add(new SelectOption(sL,sL));
        }
    }   
	*/
    public class docControllerException extends exception {}

}