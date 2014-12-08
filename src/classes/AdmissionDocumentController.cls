public with sharing class AdmissionDocumentController {
    public Admission__c admission { get; set; }
	public List<PB_AssociatedDoc__c> associatedDocs = new List<PB_AssociatedDoc__c>();
	public List<PB_AssociatedDoc__c> getAssociatedDocs() { return this.associatedDocs;}
	
	public TMN_TreePktDocTable allDocsTree {get; set;}
	public String treeData {get{ return JSON.serialize(allDocsTree.root.children);} }
    //keys returned by the fancy tree comp are stored here
    public string selectedKeys {get; set;}

    public transient String assocDocRecurrs {get;set;}    
    
    // An in-memory DB to represent componenets managed by the fancy tree, with the key being the Packet-Doc Juntion ID
    public Map<Id, DocumentWrapper> treeModel = new Map<Id, DocumentWrapper>();
    public PB_AssociatedDoc__c currrentAssocDoc {get; set;}
    public PB_Document__c currrentDoc {get; set;}
    
    // An in-memory mapping to list docPacketJo's with the packet ID
    public Map<Id, List<PB_DocPacket_Document_JO__c>> pcktJos = new Map<Id, List<PB_DocPacket_Document_JO__c>>();
     
    
    public AdmissionDocumentController(ApexPages.StandardController stdController) {
    	stdController.addFields(new String[] {'Name', 'Effective_Date__c'});                
        this.admission = (Admission__c) stdController.getRecord();
       	    
       	// get the list of all packets, docs and their junction. And the associated docs - to build an in-memory model for interaction with fancyTree component.
		Map<id, PB_DocPacket__c> pcktMap = new map<id, PB_DocPacket__c>([SELECT id, Packet_Name__c FROM PB_DocPacket__c]);
   		Map<id, PB_Document__c> docMap = new map<id, PB_Document__c>([SELECT id, Document_Name__c, Due__c, Due_Date__c, Effective_Date__c, Expiration_Date__c, Recurring_Frequency__c, 
   																			 Recurring_Interval__c, Status__c, Type__c, Version__c, (SELECT id, DocSigner__c FROM DocSignatures__r)
   																		FROM PB_Document__c]);

   		for (PB_DocPacket_Document_JO__c jo : [SELECT id, DocPacket__r.id, Document__r.id FROM PB_DocPacket_Document_JO__c]){
   			treeModel.put(jo.id, new DocumentWrapper(docMap.get(jo.Document__r.id), pcktMap.get(jo.DocPacket__r.id), docMap.get(jo.Document__r.id).DocSignatures__r));
   		}

       	refreshInMemoryMapAndAssocDocs();
		
	    // An in-memory mapping to list of docPacketJo's with the packet ID		
		List<PB_DocPacket__c> pckt_pcktDocJos = [Select id, (SELECT id, DocPacket__r.id, Document__r.id FROM DocPacketJOs__r) from PB_DocPacket__c];		
		for (PB_DocPacket__c pckt: pckt_pcktDocJos) {
			pcktJos.put(pckt.id, pckt.DocPacketJOs__r);
		}
		
		//get all the doc recurrences for this admission
		assocDocRecurrs = JSON.serialize([select id, PB_AssociatedDoc__c, status__c, status_date__c 
                                            from PB_AssocDocRecurrence__c where PB_AssociatedDoc__r.sObject_type__c = 'Admission' and PB_AssociatedDoc__r.sObject_id__c =: this.admission.id
                                           order by status_date__c desc]);
		
   		//showAddEditAdmissionDoc();
   		allDocsTree = new TMN_TreePktDocTable();
    }
    
    @TestVisible 
    private List<PB_AssociatedDoc__c> getAllAssociatedDocs(){
    	List<PB_AssociatedDoc__c> allAssocDocs = [SELECT  id, DocPacket__r.id, Document__r.id, DocPacket__r.Packet_Name__c, Document__r.document_name__c, Document__r.Version__c, Document__r.Due__c, 
    	                                                  due_date__c, Document__r.Type__c, Document__r.Recurring_Interval__c, isAdded__c, sObject_id__c, sObject_Type__c, status__c, status_date__c,
						       							  (SELECT isSigned__c, DocSignature__r.DocSigner__c, signed_date__c FROM AssocDocSignatures__r) 
      												FROM  PB_AssociatedDoc__c WHERE sObject_id__c =: this.admission.id AND sObject_type__c = 'Admission' 
       												ORDER BY DocPacket__r.Packet_Name__c, Document__r.document_name__c];       						
       	return allAssocDocs;
    }
    
  	private void refreshInMemoryMapAndAssocDocs(){
		List<PB_AssociatedDoc__c> allAssocDocs = getAllAssociatedDocs();
		this.associatedDocs.clear();
		for (PB_AssociatedDoc__c assocDoc : allAssocDocs){
				// these are the ones already added to this admission
				if (assocDoc.isAdded__c == true){
					this.associatedDocs.add(assocDoc);
				}
				
				for (ID idKey : treeModel.keyset()) {
				    DocumentWrapper docWrap = treeModel.get(idKey);
				    if (docWrap.doc.id == assocDoc.Document__r.id && docWrap.packet.id == assocDoc.DocPacket__r.id){
				    	docWrap.associatedDoc = assocDoc;
				    	docWrap.associatedDocSigners = assocDoc.AssocDocSignatures__r;
				    	docWrap.isAssocPresent = true;
				    	docWrap.isNew = false;
				    	break;
				    }
				}
		}       		
	} 	 
       	
    public pageReference editTreeNode(){
    	Id selectedID = Id.valueOf(Apexpages.currentPage().getParameters().get('selectedKey'));    	
    	currrentAssocDoc = treeModel.get(selectedID).associatedDoc;
    	currrentDoc = treeModel.get(selectedID).doc;
    	treeModel.get(selectedID).isChanged = true;
    	return null;
    }
    
  
    public pageReference updateDocSelection(){
    	Id selectedID = Id.valueOf(Apexpages.currentPage().getParameters().get('selectedKey'));
    	boolean isSelected = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isSelected'));
    	    	
		// the associated record already exists
		if (selectedID.getSobjectType() == PB_DocPacket_Document_JO__c.sObjectType) {
	    	//get the Document wrapper
			updateDocSelections(treeModel.get(selectedID), isSelected);
			editTreeNode();
		} else {
			// the selected node is a packet; get all the associated Docs, add ones not already present as new 
			List<PB_DocPacket_Document_JO__c> selectedTreeIds = pcktJos.get(selectedID);
			for (PB_DocPacket_Document_JO__c jo : selectedTreeIds){
				//get the Document wrapper
    			updateDocSelections(treeModel.get(jo.Id), isSelected);
			}
			currrentAssocDoc = null;
            currrentDoc = null;
		}
    	return null;
    }
  
	private void updateDocSelections(DocumentWrapper docWrap, boolean isSelected){
		if( docWrap.associatedDoc != null) {
				docWrap.isChanged = true;
				docWrap.associatedDoc.isAdded__c = isSelected;
			} else {
				// the selected document is not present in the associated docs.... add it 
				docWrap.isNew = true;
				PB_AssociatedDoc__c newDoc = new PB_AssociatedDoc__c (	DocPacket__c = docWrap.packet.id, 
																		Document__c = docWrap.doc.id,
																		Due_Date__c = getDueDate(this.admission.effective_date__c, docWrap.doc.Due__c), //due date = Calculated based on PBS Admission Date or Entered (If "Other" in Due)
																		IsAdded__c = true,
																		sObject_Id__c = this.admission.id,
																		sObject_Type__c = 'Admission',
																		Status__c = 'Pending',
																		Status_Date__c = null );
				docWrap.associatedDoc = newDoc;
				
				// Add the Signature 
				//for (PB_DocSignature__c sig :docWrap.docSigners) {
				//	docWrap.associatedDocSigners.add( new PB_AssocDocSignature__c(DocSignature__c = sig.id, Signed_Date__c = null));
				//}
			}
	}

    private Date getDueDate(Date admissionEffDt, String due){
    	system.debug('getDueDate inputs: ' + admissionEffDt + '  ' + due);
    	Date dueDate;
        if (due == 'Treatment Start Date')  dueDate = admissionEffDt; 
        else if (due == '72 Hours after Treatment Start') dueDate = admissionEffDt.addDays(3);
        else dueDate = null;
        
        return dueDate;
    }

	public void saveAdmissionDoc() {
		List<PB_AssociatedDoc__c> newAssocDocs = new List<PB_AssociatedDoc__c>();
		//List<PB_AssocDocSignature__c> newAssocSigns = new List<PB_AssocDocSignature__c>();
		List<PB_AssociatedDoc__c> updatedAssocDocs = new List<PB_AssociatedDoc__c>();


		for (ID idKey : treeModel.keyset()) {
			DocumentWrapper docWrap = treeModel.get(idKey);
			if (docWrap.isChanged && docWrap.isAssocPresent && !docWrap.isNew){			// these are already in the association table, needs update only if changed.
					updatedAssocDocs.add(docWrap.associatedDoc);
			}
			
			else if (docWrap.isNew ){			// new additions
					newAssocDocs.add(docWrap.associatedDoc);
			}			
		}
		
		update updatedAssocDocs;
		insert newAssocDocs;

		//for (ID idKey : treeModel.keyset()) {
		//	DocumentWrapper docWrap = treeModel.get(idKey);
		//	if (docWrap.isNew && docWrap.associatedDocSigners.size()>0 ){			// signatures for the newly added docs
		//		for (PB_AssocDocSignature__c assocSig :docWrap.associatedDocSigners) {
		//				assocSig.AssociatedDoc__c = docWrap.associatedDoc.id;
		//				newAssocSigns.add(assocSig);
		//		}
		//	}			
		//}
		//insert newAssocSigns;

		refreshInMemoryMapAndAssocDocs();
	}	
  
 	public void showAddEditAdmissionDoc(){
		allDocsTree = new TMN_TreePktDocTable();
		List<String> addedDocs = new List<string>();
		map<string, TMN_TreePktDocTable.node> nodeKeyMap;
        List<PB_DocPacket__c> pkts = [SELECT  id, 
                                            Packet_Name__c, 
                                            (SELECT PB_DocPacket_Document_JO__c.id, DocPacket__r.id, Document__r.id, Document__r.document_name__c, Document__r.Recurring_Interval__c FROM DocPacketJOs__r ORDER BY DocPacket__r.ID, Document__r.ID),
                                            (SELECT DocPacket__r.id, Document__r.id, Due_Date__c, Effective_Date__c, Status__c, Status_Date__c
                                               FROM AssociatedDocuments__r WHERE sObject_id__c =: this.admission.id AND sObject_type__c = 'Admission' AND IsAdded__c = true)
                                     from   PB_DOCPacket__c];
                                     
		for (PB_DocPacket__c pkt : pkts) {
			TMN_TreePktDocTable.node pckt_node= new TMN_TreePktDocTable.node(pkt.id, pkt.Packet_Name__c);
			pckt_node.folder = true;
			allDocsTree.root.children.add(pckt_node);			
			for (PB_DocPacket_Document_JO__c doc :  pkt.DocPacketJOs__r){
				TMN_TreePktDocTable.node doc_node = new TMN_TreePktDocTable.node(doc.id, doc.Document__r.document_name__c);   // each doc has the key of junction object ID.
				doc_node.recurrFreq = doc.Document__r.Recurring_Interval__c;
				allDocsTree.root.children.get(allDocsTree.root.getNode_Key(pkt.id)).children.add(doc_node);							
			}
		}
		
		nodeKeyMap = TMN_TreePktDocTable.buildNodeKeyMapFor(allDocsTree.root.children);
		for (PB_DocPacket__c pkt : pkts) {
        	for (PB_AssociatedDoc__c assoc : pkt.AssociatedDocuments__r){               
                for (PB_DocPacket_Document_JO__c jo :  pkt.DocPacketJOs__r){
                    if (assoc.DocPacket__r.id == jo.DocPacket__r.id && assoc.Document__r.id == jo.Document__r.id){
                        addedDocs.add(jo.id);
                        TMN_TreePktDocTable.node node = nodeKeyMap.get(jo.id);
                        node.dueDate = assoc.Due_Date__c;
                        node.assocStatus = assoc.Status__c;
                        node.statusDate = assoc.Status_Date__c;
                        break;
                    }
                }
            }
        }
		allDocsTree.inputSelectedKeys(addedDocs, true);
		selectedKeys = allDocsTree.GetSelectedNodeStr;
	}
		
	public class DocumentWrapper {
		public PB_Document__c doc;
		public PB_DocPacket__c packet;
		public List<PB_DocSignature__c> docSigners;
		public PB_AssociatedDoc__c associatedDoc;
		public List<PB_AssocDocSignature__c> associatedDocSigners = new List<PB_AssocDocSignature__c>();
		
		public boolean isAssocPresent = false;		 // to indiate if the packet-Doc junction is already present in the association table
		public boolean isChanged = false;
		public boolean isNew = false;
		
		
		public DocumentWrapper(PB_Document__c doc, PB_DocPacket__c pckt, List<PB_DocSignature__c> docSigners){
			this.doc = doc;
			this.packet = pckt;
			this.docSigners = docSigners;
		}
	}
  
}