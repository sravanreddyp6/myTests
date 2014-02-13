public class ServAssignExpectedDocsExt {
    public Service_Assignment__c theServAssign { get; set; }
    public List<ServiceAssignment_Contract_JO__c> servAssignContractXrefs { get; set; }
    public List<Contract_Document_JO__c> contractDocXrefs { get; set; }
    public List<ServiceAssignment_Document_JO__c> servAssignDocXrefs { get; set; }
    public List<Id> docIds { get; set; }
    public List<Document__c> docs { get; set; }
    public List<DocFilingWrapper> listOfDocFilings { get; set; }
    public Integer countOfDocFilings { get; set; }
    public String baseUrl { get; set; }
    public String personName { get; set; }
    public String sortBy { get; set; }
    public List<SelectOption> sortByOptions { get; set; }
    public Boolean refreshTable { get; set; }    
    public Id sadjToSave { get; set; }
    public Id sadjToDelete { get; set; } 
    public ServiceAssignment_Document_JO__c naCommentSadjo { get; set; }
    
    public ServAssignExpectedDocsExt(ApexPages.StandardController controller) {
        this.theServAssign = (Service_Assignment__c)controller.getRecord();
               
        findExpectedDocs();
        listOfDocFilings = new List<DocFilingWrapper>();
        countOfDocFilings = 0;
        
        for(ServiceAssignment_Document_JO__c sadJ : servAssignDocXrefs) {
            listOfDocFilings.add(new DocFilingWrapper(sadJ));
            countOfDocFilings++;
        }
        
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        sortByOptions = new List<SelectOption>();
        sortByOptions.add(new SelectOption('Relative_Due_Date_Resolved__c', 'Due Date Resolved'));
        sortByOptions.add(new SelectOption('File_Status__c','File Status'));
        sortByOptions.add(new SelectOption('Document__c', 'Document Name'));
        sortByOptions.add(new SelectOption('Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c', 'Due Date'));
        sortByOptions.add(new SelectOption('Due_From_Employee__c', 'Due From'));
        
    }
    
    public class DocFilingWrapper {
        public String docName { get; set; }
        public List<SelectOption> fileStatusOptions { get; set; }
        public List<String> htmlFileStatusOptions { get; set; }
        public Integer rDDUnits { get; set; }
        public String rDDUom { get; set; }
        public String rDDEvent { get; set; }
        public Datetime rDDResolved { get; set; }
        public String dueDateConcat { get; set; }
        public Date fixedDueDate { get; set; }
        public String sAOwner { get; set; }
        public String sAOwnerName { get; set; }
        public String fileStatus { get; set; }
        public String fileStatusStyle { get; set; }
        public String fileStatusBeforeSave { get; set; }
        public ServiceAssignment_Document_JO__c sadjToUpdate { get; set; }
        public Boolean autoInclude { get; set; }
        
        public docFilingWrapper(ServiceAssignment_Document_JO__c sadJ) {         
            System.debug('sadJ Relative_Due_Date_Resolved__c: ' + sadJ.Relative_Due_Date_Resolved__c);
            
            fixedDueDate = sadj.Fixed_Due_Date__c;
            
            
            if(fixedDueDate!=null) {
                dueDateConcat = String.valueOf(fixedDueDate.month()) + '/' + String.valueOf(fixedDueDate.day()) + '/' + String.valueOf(fixedDueDate.year());
                rDDResolved = fixedDueDate;
            }
            else {
                rDDResolved = sadJ.Relative_Due_Date_Resolved__c;
                rDDUnits = sadJ.Relative_Due_Date_Units__c.intValue();  
                rDDUom = sadJ.Relative_Due_Date_UOM__c;
                rDDEvent = sadJ.Relative_Due_Date_Event__c;
                dueDateConcat = rDDUnits + ' ' + rDDUom + ' from ' + rDDEvent;
            }
            sAOwner = sadJ.Due_From_Employee__c;
            sAOwnerName = sadJ.Due_From_Employee_Name__c;
            docName = sadJ.Document_Name__c;
                        
            fileStatus = sadJ.File_Status__c;
            
            Date today = date.today();
            
            Date rDDResolvedAsDate;
            if(rDDResolved!=null){
                rDDResolvedAsDate = rDDResolved.date();
            }
            else {
                rDDResolvedAsDate = sadj.Fixed_Due_Date__c;
            }
            
            System.debug('How many days between today and the resolved due date?: ' + string.valueof(today.daysBetween(rDDResolvedAsDate)));
            
            if((sadJ.File_Status__c=='Not Filed') && (today.daysBetween(rDDResolvedAsDate)<0)) {
                fileStatusStyle = 'PastDue';
            }
            else if ((sadJ.File_Status__c=='Not Filed') && (today.daysBetween(rDDResolvedAsDate)<7) && (today.daysBetween(rDDResolvedAsDate)>=0)) {
                fileStatusStyle = 'ComingDue';
            }
            else if (sadj.File_Status__c!='' && sadj.File_Status__c!=null) {      
                fileStatusStyle = sadJ.File_Status__c.deleteWhitespace();
                fileStatusStyle = fileStatusStyle.remove('/');
            }
            else {
                fileStatusStyle = 'ERROR';
            }

            fileStatusBeforeSave = sadJ.File_Status__c;
            
            fileStatusOptions = new List<SelectOption>();
            fileStatusOptions.add(new SelectOption('Not Filed','Not Filed'));
            fileStatusOptions.add(new SelectOption('Filed','Filed'));
            fileStatusOptions.add(new SelectOption('Waived','Waived'));
            fileStatusOptions.add(new SelectOption('N/A','N/A'));
            fileStatusOptions.add(new SelectOption('N/A - Non-FCT','N/A - Non-FCT'));
            fileStatusOptions.add(new SelectOption('N/A - Document In Initial File','N/A - Document In Initial File'));
            fileStatusOptions.add(new SelectOption('N/A - File Transferred','N/A - File Transferred'));
            fileStatusOptions.add(new SelectOption('Filed - Not Contract Compliant','Filed - Not Contract Compliant'));
            fileStatusOptions.add(new SelectOption('Not Filed - Unrecoverable','Not Filed - Unrecoverable'));
            
            htmlFileStatusOptions = new List<String>();
            htmlFileStatusOptions.add('Not Filed');
            htmlFileStatusOptions.add('Filed');
            
            autoInclude = sadJ.Document__r.Auto_Include__c;
            
            sadjToUpdate = sadJ;
            
        }
        
    }


    private void addError(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
    }
        
 
    public PageReference findExpectedDocs(){
        if (sortBy==null) {
            sortBy = 'Relative_Due_Date_Resolved__c';
        }
        
        // A list of the "expected document" xrefs...
        servAssignDocXrefs = new List<ServiceAssignment_Document_JO__c>();
        
        // A list to hold documents...
        List<Document__c> someDocs = new List<Document__c>();
    
        // Select all cross-references between Contracts and this Service Assignment.
        String queryString = 'SELECT Id, Name, Document__c, Document_Name__c, File_Status__c, Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c, Relative_Due_Date_Resolved__c, Fixed_Due_Date__c, Due_From_Employee__c, Due_From_Employee_Name__c, Document__r.Auto_Include__c FROM ServiceAssignment_Document_JO__c WHERE Service_Assignment__c = \'' + theServAssign.Id + '\' AND Document__r.Type__c = \'Case Document\' ORDER BY ' + sortBy;
        servAssignDocXrefs = Database.query(queryString);
        
        docIds = new List<Id>();
        
        for(ServiceAssignment_Document_JO__c sAdJo : servAssignDocXrefs) {
            docIds.add(sAdJo.Document__c);
        }
        
        docs = [ SELECT Id, Name FROM Document__c WHERE Id = :docIds ];
        
        return null;
    }
    
    
    public PageReference saveFilings() {
      
      Savepoint sp = Database.setSavepoint();
      
      try { 
        List<ServiceAssignment_Document_JO__c> sadjUpdateList = new List<ServiceAssignment_Document_JO__c>(); 
        for (DocFilingWrapper dfw : listOfDocFilings) {
                if(sadjToSave==dfw.sadjToUpdate.Id) {
                    dfw.sadjToUpdate.File_Status__c = dfw.fileStatus;
                    sadjUpdateList.add(dfw.sadjToUpdate);
                }       
        }
        
        update sadjUpdateList;
        
        refreshListOfDocFilings();
        
      }
      catch(DmlException e) {
          addError('Could not save changes: ' + e.getMessage());
          Database.rollback(sp);
      }
      
      return null;

    }

    
    public void refreshListOfDocFilings() {
        findExpectedDocs();
        listOfDocFilings = new List<DocFilingWrapper>();
        
        for(ServiceAssignment_Document_JO__c sadJ : servAssignDocXrefs) {
            listOfDocFilings.add(new DocFilingWrapper(sadJ));
        }
    }
        
    
    public PageReference RemoveDoc() {
        
                Savepoint sp = Database.setSavepoint(); 
        
              try { 
                List<ServiceAssignment_Document_JO__c> sadjUpdateList = new List<ServiceAssignment_Document_JO__c>(); 
                for (DocFilingWrapper dfw : listOfDocFilings) {
                        if(sadjToDelete==dfw.sadjToUpdate.Id) {
                            sadjUpdateList.add(dfw.sadjToUpdate);
                        }       
                }
                
                delete sadjUpdateList;
                
                findExpectedDocs();
                listOfDocFilings = new List<DocFilingWrapper>();
                countOfDocFilings = 0;
                
                for(ServiceAssignment_Document_JO__c sadJ : servAssignDocXrefs) {
                    listOfDocFilings.add(new DocFilingWrapper(sadJ));
                        countOfDocFilings++;
                }
              }
              catch(DmlException e) {
                  addError('Could not save changes: ' + e.getMessage());
                  Database.rollback(sp);
              }
              
              return null;
        
    }
    

    @RemoteAction
    public static ServiceAssignment_Document_JO__c loadSadjo(string sadjoId) {
        ServiceAssignment_Document_JO__c naCommentSadjo = [SELECT Id, Name, N_A_Reason__c, File_Status__c FROM ServiceAssignment_Document_JO__c WHERE Id= :sadjoId];
        return naCommentSadjo;
    }

    @RemoteAction
    public static void saveSadjoRemote(string sadjoId, string sadjoNaReason, string sadjoFileStatus) {

      ServiceAssignment_Document_JO__c sadjoForRemoteSave;                                        
      Id sadjToSave;
      
        sadjoForRemoteSave = [SELECT ID, Name, N_A_Reason__c FROM ServiceAssignment_Document_JO__c WHERE Id=:sadjoId ];
        sadjoForRemoteSave.N_A_Reason__c = sadjoNaReason;
        sadjoForRemoteSave.File_Status__c = sadjoFileStatus;
        sadjoForRemoteSave.Filed_by__c = UserInfo.getUserId();        
        sadjoForRemoteSave.Filed_Date_Time__c = Datetime.now();
        sadjToSave = sadjoForRemoteSave.Id;
        
      upsert sadjoForRemoteSave;      

   }


}