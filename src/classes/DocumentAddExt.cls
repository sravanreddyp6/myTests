public class DocumentAddExt {
    public ServiceAssignment_Document_JO__c theServAssignDocJo { get; set; }
    public Id theServAssignId { get; set; }
    public final Service_Assignment__c theServAssign { get; private set; }
    public Set<Id> setOfIdsForDocsUserCanAdd { get; set; }
    public Set<Id> setOfDocIdsForRelatedContracts { get; set; }
    public Set<Id> setOfDocIdsForRelatedPrograms { get; set; }
    public Set<Id> intersectionSetOfDocIds { get; set; }
    public List<Document__c> listOfDocsUserCanAdd { get; set; }
    public Map<Id,Document__c> mapOfDocsUserCanAdd { get; set; }
    public List<SelectOption> selectOptionsForDocAdd { get; set; }
    public Document__c selectedDoc { get; set; }
    public Id currentSelectedDocId { get; set; }
    public Boolean docIsSelected { get; set; }
    public Integer units { get; set; }
    public String rddUnits { get; set; }
    public String rddUom { get; set; }
    public String rddEvent { get; set; }
    public Date fixedDueDate { get; set; }
    public List<SelectOption> selectOptionsRddUom { get; set; }
    public List<SelectOption> selectOptionsRddEvent { get; set; }
    public Boolean dateType { get; set; }
    ApexPages.StandardController sadjoController;
    
    public DocumentAddExt(ApexPages.StandardController controller) {
        sadjoController = controller;
        theServAssignDocJo = (ServiceAssignment_Document_JO__c)sadjoController.getRecord();
        
        
        theServAssignId = ApexPages.currentPage().getParameters().get('ServAssignIdParam');
        theServAssign = [ SELECT Id, Name, Admission__c, Admission__r.State__c, Program__c, Admission__r.Person_Being_Served__c, Admission__r.Name,
                            Admission__r.Effective_Date__c, Person_Being_Served__c, Start_Date__c, End_Date__c, Projected_Treatment_End_Date__c, 
                            Location_Region__c
                             FROM Service_Assignment__c WHERE Id = :theServAssignId ];
                             
        
        // Populate a list of documents that are not auto-include documents that the user can add to the Service Assignment.        
        List<Id> listOfContractIds = new List<Id>();
        List<ServiceAssignment_Contract_JO__c> servAssignContractXrefs = new List<ServiceAssignment_Contract_JO__c>();
        servAssignContractXrefs = [ SELECT Id, Name, Contract__c FROM ServiceAssignment_Contract_JO__c WHERE Service_Assignment__c = :theServAssignId ];

        for(ServiceAssignment_Contract_JO__c sAJC : servAssignContractXrefs) {
            listOfContractIds.add(sAJC.Contract__c);
        }

        List<Contract_Document_JO__c> contractDocXrefs = [ SELECT Id, Name, Document__c, Contract__c FROM Contract_Document_JO__c WHERE Contract__c = :listOfContractIds AND Document__r.Type__c = 'Case Document' AND Document__r.Auto_Include__c = false AND (Document__r.State__c = :theServAssign.Admission__r.State__c OR Document__r.State__c = NULL) ];
        List<Program_Document_Xref__c> programDocXrefs = [ SELECT Id, Name, Document__c FROM Program_Document_Xref__c WHERE Program__c = :theServAssign.Program__c AND Document__r.Type__c = 'Case Document' AND Document__r.Auto_Include__c = false AND (Document__r.State__c = :theServAssign.Admission__r.State__c OR Document__r.State__c = NULL) ];
    
        // Populate a set of Document IDs expected for this Service Assignment by looping through the lists of Contract / Doc Xrefs and Program / Doc Xrefs created above.
        setOfIdsForDocsUserCanAdd = new Set<Id>();
        setOfDocIdsForRelatedContracts = new Set<Id>();
        setOfDocIdsForRelatedPrograms = new Set<Id>();
        intersectionSetOfDocIds = new Set<Id>();
        for(Contract_Document_JO__c cdj : contractDocXrefs) {
            setOfDocIdsForRelatedContracts.add(cdj.Document__c);
        }
        for(Program_Document_Xref__c pdx : programDocXrefs) {
            setOfDocIdsForRelatedPrograms.add(pdx.Document__c);
        }
        
        intersectionSetOfDocIds = setOfDocIdsForRelatedContracts.clone();
        intersectionSetOfDocIds.retainAll(setOfDocIdsForRelatedPrograms);
        
        setOfIdsForDocsUserCanAdd = intersectionSetOfDocIds;
        
        // Get the documents that match up with that set of IDs.
        listOfDocsUserCanAdd = [SELECT Id, Name, Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c, Type__c FROM Document__c WHERE Id = :setOfIdsForDocsUserCanAdd ];
        mapOfDocsUserCanAdd = new Map<Id,Document__c>();
        for(Document__c loduca : listOfDocsUserCanAdd) {
            mapOfDocsUserCanAdd.put(loduca.Id,loduca);
        }
        
        List<ServiceAssignment_Document_JO__c> listOfPreExistingServAssignDocXrefs = [ SELECT Document__c, File_Status__c, Relative_Due_Date_Resolved__c FROM ServiceAssignment_Document_JO__c WHERE Service_Assignment__c = :theServAssign.Id ];
        
        Set<Id> docsToRemoveFromListOfDocsUserCanAdd = new Set<Id>();
        for(Document__c d : listOfDocsUserCanAdd) {
            for(ServiceAssignment_Document_JO__c sadj : listOfPreExistingServAssignDocXrefs) {                      
                if(sadj.Document__c == d.Id) {                                                          
                    docsToRemoveFromListOfDocsUserCanAdd.add(d.Id);
                }
            }
        }   
        
        for(Id i : docsToRemoveFromListOfDocsUserCanAdd) {
            mapOfDocsUserCanAdd.remove(i);  
        }
        
        selectOptionsForDocAdd = new List<SelectOption>();
        selectOptionsForDocAdd.add(new SelectOption('--None--','--None--'));
        for(Id md : mapOfDocsUserCanAdd.keySet()) {
            selectOptionsForDocAdd.add(new SelectOption(md,mapOfDocsUserCanAdd.get(md).Name));
        }
        
        Schema.DescribeFieldResult fieldInfo = Schema.SObjectType.Document__c.fields.Relative_Due_Date_UOM__c;
        List<Schema.PicklistEntry> picklistValues = fieldInfo.getPicklistValues();
        selectOptionsRddUom = new List<SelectOption>();
        selectOptionsRddUom.add(new SelectOption('--None--','--None--')); 
        for (Schema.PicklistEntry picklistValue : picklistValues) {
            selectOptionsRddUom.add(new SelectOption(picklistValue.getLabel(),picklistValue.getLabel()));
        }      

        Schema.DescribeFieldResult fieldInfo2 = Schema.SObjectType.Document__c.fields.Relative_Due_Date_Event__c;
        List<Schema.PicklistEntry> picklistValues2 = fieldInfo2.getPicklistValues();
        selectOptionsRddEvent = new List<SelectOption>();
        selectOptionsRddEvent.add(new SelectOption('--None--','--None--')); 
        for (Schema.PicklistEntry picklistValue2 : picklistValues2) {
            selectOptionsRddEvent.add(new SelectOption(picklistValue2.getLabel(),picklistValue2.getLabel()));
        }

      
    }
    
    
    private void addError(String msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
    }
    
    
    public void defaultDueDateInfo() {
        
        System.debug('Value of currentSelectedDocId: ' + selectedDoc);
        
        Document__c dD = [ SELECT Id, Name, Relative_Due_Date_Units__c, 
                        Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c
                        FROM Document__c WHERE Id = :currentSelectedDocId ];
        
        
        rddUnits = String.valueOf(dD.Relative_Due_Date_Units__c);
        rddUom = dD.Relative_Due_Date_UOM__c;
        rddEvent = dD.Relative_Due_Date_Event__c;
        
        docIsSelected = true;
        
    }


    public PageReference resetToDefaults() {
        
        PageReference refreshPageRef = new PageReference('/apex/AddDoc?id=' + theServAssignDocJo.Id);
        defaultDueDateInfo();
        return refreshPageRef;
        
    }

    public PageReference saveDocXref() {
        /*
        System.debug('Document__c value at save: ' + theServAssignDocJo.Document__c);
        System.debug('Relative_Due_Date_Units__c value at save: ' + theServAssignDocJo.Relative_Due_Date_Units__c); 
        
        theServAssignDocJo.Service_Assignment__c = theServAssign.Id;
        
        insert theServAssignDocJo;
        */
        
        System.Debug('THE SAVE FUNCTION IS RUNNING!');
        System.Debug('What is in currentSelectedDocId? ' + currentSelectedDocId);

        
        theServAssignDocJo.Document__c = currentSelectedDocId;
//        theServAssignDocJo.Fixed_Due_Date__c = fixedDueDate;
//        theServAssignDocJo.Relative_Due_Date_Units__c = rddUnits;
        
        if(theServAssignDocJo.Relative_Due_Date_Event__c!=NULL && theServAssignDocJo.Fixed_Due_Date__c!=NULL){
                addError('You cannot have both a Relative Due Date and a Fixed Due Date.  Please make corrections to the data entry and try again.');
        }
        
        if(rddUnits!=null && rddUnits!='') {
                theServAssignDocJo.Relative_Due_Date_Units__c = Decimal.valueOf(rddUnits);
        }
        else {
                theServAssignDocJo.Relative_Due_Date_Units__c = null;
        }
        theServAssignDocJo.Relative_Due_Date_UOM__c = rddUom;
        theServAssignDocJo.Relative_Due_Date_Event__c = rddEvent;
        
        System.debug('saveDocXref; theServAssign: ' + theServAssign);
        System.debug('saveDocXref; theServAssignDocJo: ' + theServAssignDocJo);
        System.debug('saveDocXref; theServAssignDocJo.Fixed_Due_Date__c' + theServAssignDocJo.Fixed_Due_Date__c);
        
        DocumentMethods.docPop(theServAssign, theServAssignDocJo, theServAssignDocJo.Fixed_Due_Date__c, true, false, false, false);
        
        PageReference pageRef = new PageReference('/apex/ServAssignExpectedDocs?id='+theServAssign.Id);
        return pageRef;
        
    }
    
    public void ClearRelativeDueDateFields() {
          rddUnits = null;
          rddUom = '--None--';
          rddEvent = '--None--';     
    }
    
    public void ClearFixedDueDateField() {
          theServAssignDocJo.Fixed_Due_Date__c = null;
    }
    
    public PageReference CancelAddDoc() {
        PageReference cancelPageRef = new PageReference(sadjoController.cancel().getUrl());
        return cancelPageRef;
    }
}