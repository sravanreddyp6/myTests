public class ServAssignFidelityChecklistExt  {

    public Service_Assignment__c theServAssign { get; set; }
    public List<ServiceAssignment_Contract_JO__c> servAssignContractXrefs { get; set; }
    public List<Contract_Document_JO__c> contractDocXrefs { get; set; }
    public List<ServiceAssignment_Document_JO__c> servAssignDocXrefs { get; set; }
    public List<Id> docIds { get; set; }
    public List<Document__c> docs { get; set; }
    public List<FidDocWrapper> listOfFidDocFilings { get; set; }
    public String baseUrl { get; set; }
    public Map<Decimal,Integer> numDocsPerPhaseOrLevel { get; set; }
    public Map<Decimal,Integer> numFiledDocsPerPhaseOrLevel { get; set; }
    public Integer thePhase { get; set; }
    public String phaseErrorString { get; set; }
    
    public ServAssignFidelityChecklistExt(ApexPages.StandardController controller) {
        this.theServAssign = (Service_Assignment__c)controller.getRecord();
        
        Service_Assignment__c tempSa = [ SELECT Phase__c FROM Service_Assignment__c WHERE Id = :theServAssign.Id LIMIT 1];
        
        if(tempSA.Phase__c!=null) {
                thePhase = tempSa.Phase__c.intValue();
        }
        
        findFidelityDocs();
        listOfFidDocFilings = new List<FidDocWrapper>();
        
        for(ServiceAssignment_Document_JO__c sadJ : servAssignDocXrefs) {
            listOfFidDocFilings.add(new FidDocWrapper(sadJ));
        }
        
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        if(thePhase==null) {
                phaseErrorString = 'You must assign a phase to the Service Assignment before you can check off Fidelity Documents.';
        }
        
    }


    class FidDocWrapper {
        public String docName { get; set; }
        public Integer phzOrLvl { get; set; }
        public String phzOrLvlString { get; set; }
        public Integer order { get; set; }
        public Integer numberOfPhases { get; set; }
        public Boolean selectedFidDoc { get; set; }
        public Boolean selectFidDocStatusBeforeSave { get; set; }
        public Boolean waivedFidDoc { get; set; }
        public Boolean waivedFidDocStatusBeforeSave { get; set; }       
        public String sAOwner { get; set; }
        public String sAOwnerName { get; set; }
        public String fileStatus { get; set; }
        public String fileStatusStyle { get; set; }
        public String fileStatusBeforeSave { get; set; }
        public ServiceAssignment_Document_JO__c sadjToUpdate { get; set; }
        public Datetime filedDateTime { get; set; }
        public String naComment { get; set; }
        public String naCommentBeforeSave { get; set; }
        
        public FidDocWrapper(ServiceAssignment_Document_JO__c sadJ) {         
            
            sAOwner = sadJ.Due_From_Employee__c;
            sAOwnerName = sadJ.Due_From_Employee_Name__c;
            docName = sadJ.Document_Name__c;
                        
            fileStatus = sadJ.File_Status__c;
            if(fileStatus=='Filed') {
                selectedFidDoc = true;
                selectFidDocStatusBeforeSave = true;
            }
            else {
                selectedFidDoc = false;
                selectFidDocStatusBeforeSave = false;
            }
 
             if(fileStatus=='Waived') {
                waivedFidDoc = true;
                waivedFidDocStatusBeforeSave = true;
            }
            else {
                waivedFidDoc = false;
                waivedFidDocStatusBeforeSave = false;
            }           
            
            fileStatusBeforeSave = sadJ.File_Status__c;
            
            naComment = sadJ.N_A_Reason__c;
            naCommentBeforeSave = sadJ.N_A_Reason__c;
            
            sadjToUpdate = sadJ;
            phzOrLvl = sadJ.Document__r.Phase_Or_Level__c.intValue();
            phzOrLvlString = string.valueof(phzOrLvl);
            order = sadJ.Document__r.Order__c.intValue();
            filedDateTime = sadj.Filed_Date_Time__c;       
            
        }
    }
    
    public void addError(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
    }
        
 
    public PageReference findFidelityDocs(){
        
        // A list of the "expected document" xrefs...
        servAssignDocXrefs = new List<ServiceAssignment_Document_JO__c>();
        
        // A list to hold documents...
        List<Document__c> someDocs = new List<Document__c>();
        
        Service_Assignment__c fetchedServAssign = [ SELECT Id, Name, Program__c, Admission__r.state__c, Service_Line__c FROM Service_Assignment__c WHERE Id = :theServAssign.Id LIMIT 1 ]; 
    
        // Select all cross-references between Contracts and this Service Assignment.
        servAssignDocXrefs = [ SELECT Id, Name, Document__c, Document_Name__c, File_Status__c, Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, 
                                        Relative_Due_Date_Event__c, Relative_Due_Date_Resolved__c, Due_From_Employee__c, Due_From_Employee_Name__c, 
                                        Document__r.Type__c, Document__r.Phase_or_Level__c, Document__r.Order__c, Filed_Date_Time__c, Filed_By__c,
                                        Filed_By__r.Name, N_A_Reason__c
                                FROM ServiceAssignment_Document_JO__c 
                                WHERE Service_Assignment__c = :fetchedServAssign.Id 
                                        AND Document__r.Type__c = 'Fidelity Document'
                                        AND Document__r.State__c = :fetchedServAssign.Admission__r.state__c
                                        AND Document__c IN (SELECT Document__c FROM Program_Document_Xref__c WHERE Program__c = :fetchedServAssign.Program__c)
                                       // AND Document__c IN (SELECT Document__c FROM Program_Document_Xref__c WHERE Service_Line__c = :fetchedServAssign.Service_Line__c)
                                ORDER BY Document__r.Phase_Or_Level__c, Document__r.Order__c ];
       
        docIds = new List<Id>();
        Set<Decimal> uniquePhasesOrLevels = new Set<Decimal>();
        
        for(ServiceAssignment_Document_JO__c sAdJo : servAssignDocXrefs) {
            docIds.add(sAdJo.Document__c);
            uniquePhasesOrLevels.add(sAdJo.Document__r.Phase_Or_Level__c);
        }
        
        numDocsPerPhaseOrLevel = new Map<Decimal,Integer>();
        numFiledDocsPerPhaseOrLevel = new Map<Decimal,Integer>();
        
        for(Decimal pORl : uniquePhasesOrLevels) {
            Integer lvlCounter = 0;
            Integer lvlFiledCounter = 0;
            for(ServiceAssignment_Document_JO__c sxs : servAssignDocXrefs){
                if(sxs.Document__r.Phase_or_Level__c==pORl){
                    lvlCounter++;
                }
                if(sxs.Document__r.Phase_or_Level__c==pORl && (sxs.File_Status__c=='Filed' || sxs.File_Status__c=='Waived')){
                    lvlFiledCounter++;
                }
            }
            numDocsPerPhaseOrLevel.put(pORl,lvlCounter);
            numFiledDocsPerPhaseOrLevel.put(pORl,lvlFiledCounter);
        }
        
        docs = [ SELECT Id, Name FROM Document__c WHERE Id = :docIds ];
        
        return null;
    }
    
    
    public PageReference saveFidDocSelections() {
      
      Savepoint sp = Database.setSavepoint();
      
      try {
          
        List<ServiceAssignment_Document_JO__c> sadjUpdateList = new List<ServiceAssignment_Document_JO__c>(); 
        
        for (FidDocWrapper f : listOfFidDocFilings) {

            if(f.selectedFidDoc==f.selectFidDocStatusBeforeSave && f.waivedFidDoc==f.waivedFidDocStatusBeforeSave){
                //DO NOTHING
            }
            else {
                if(f.selectedFidDoc==true && f.waivedFidDoc==true){
                    ApexPages.Message fileStatusMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'A fidelity document cannot be both filed and waived.  Please check the filing for this document: ' + f.docName);
                    ApexPages.addMessage(fileStatusMessage);
                }
                else if(f.selectedFidDoc==true){
                    f.sadjToUpdate.File_Status__c = 'Filed';    
                }
                else if(f.waivedFidDoc==true) {
                    f.sadjToUpdate.File_Status__c = 'Waived';
                }
                else {
                    f.sadjToUpdate.File_Status__c = 'Not Filed';
                }
                
                f.sadjToUpdate.N_A_Reason__c = f.naComment;
                f.sadjToUpdate.Filed_Date_Time__c = datetime.now();
                f.sadjToUpdate.Filed_By__c = UserInfo.getUserId();
                
                sadjUpdateList.add(f.sadjToUpdate);
            
                ApexPages.Message myMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Fidelity Document checkoff status change saved: ' + f.docName);
                ApexPages.addMessage(myMessage);
            }
        }
    
        update sadjUpdateList;
           
      }
      catch(DmlException e) {
          addError('Could not save changes: ' + e.getMessage());
          Database.rollback(sp);
      }
  
      findFidelityDocs();
  
      return null;
    }

    public PageReference refreshListOfDocFilings() {

                PageReference pageRef = new PageReference('/apex/ServAssignFidelityChecklist?id=' + theServAssign.Id);
                pageRef.setRedirect(true);
                return pageRef;
/*

        PageReference backToFidCheckPage = new PageReference('/apex/ServAssignFidelityChecklist?id=' + theServAssign.Id);
        return backToFidCheckPage;

        findFidelityDocs();
        listOfFidDocFilings = new List<FidDocWrapper>();
        
        for(ServiceAssignment_Document_JO__c sadJ : servAssignDocXrefs) {
            listOfFidDocFilings.add(new FidDocWrapper(sadJ));
        }
*/
    }

    @RemoteAction
    public static ServiceAssignment_Document_JO__c loadSadjo(string sadjoId) {
        ServiceAssignment_Document_JO__c naCommentSadjo = [SELECT Id, Name, N_A_Reason__c, File_Status__c FROM ServiceAssignment_Document_JO__c WHERE Id= :sadjoId];
        return naCommentSadjo;
    }

    @RemoteAction
    public static void saveSadjoRemote(string sadjoId, string sadjoNaReason, string sadjoFileStatus, Boolean checkStatus) {

      ServiceAssignment_Document_JO__c sadjoForRemoteSave;                                        
      Id sadjToSave;
      
        sadjoForRemoteSave = [SELECT ID, Name, N_A_Reason__c, Document__r.Phase_or_Level__c, Service_Assignment__r.Phase__c FROM ServiceAssignment_Document_JO__c WHERE Id=:sadjoId ];
      
                if(sadjoForRemoteSave.Service_Assignment__r.Phase__c > sadjoForRemoteSave.Document__r.Phase_or_Level__c) {
                        throw new fidException('FAIL!');
                }
                else {
                if(checkStatus==false) {
                        sadjoForRemoteSave.File_Status__c = null;
                        sadjoForRemoteSave.N_A_Reason__c = null;
                }
                else if(sadjoFileStatus=='Filed'){
                        sadjoForRemoteSave.File_Status__c = sadjoFileStatus;
                        sadjoForRemoteSave.N_A_Reason__c = null;                
                }
                else {
                        sadjoForRemoteSave.File_Status__c = sadjoFileStatus;
                        sadjoForRemoteSave.N_A_Reason__c = sadjoNaReason;
                }     
                sadjoForRemoteSave.Filed_by__c = UserInfo.getUserId();        
                sadjoForRemoteSave.Filed_Date_Time__c = Datetime.now();
                
                upsert sadjoForRemoteSave;      
                }
   }

        public class fidException extends Exception {}

}