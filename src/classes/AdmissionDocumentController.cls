public with sharing class AdmissionDocumentController {
    public Admission__c admission { get; set; }
	public List<PB_AssociatedDoc__c> associatedDocs = new List<PB_AssociatedDoc__c>();
	public List<PB_AssociatedDoc__c> getAssociatedDocs() { return this.associatedDocs;}
	

	public TMN_Tree allDocsTree {get; set;}
    //keys returned by the fancy tree comp are stored here
    public string selectedKeys {get; set;}
    
    public string selectedForEdit {get; set;}
    
    // An in-memory mapping for of the tree, with the key beig the Packet-Doc Juntion ID
    public Map<Id, DocumentWrapper> treeModel = new Map<Id, DocumentWrapper>();
    public PB_AssociatedDoc__c currrentAssocDoc {get; set;}
    
    // An in-memory mapping to list of docPacketJo's with the packet ID
    public Map<Id, List<PB_DocPacket_Document_JO__c>> pcktJos = new Map<Id, List<PB_DocPacket_Document_JO__c>>();
     
    
    public AdmissionDocumentController(ApexPages.StandardController stdController) {
        this.admission = (Admission__c) stdController.getRecord();
       	    
       	// get the list of all packets, docs and their junction. And the associated docs - to build an in-memory model for interaction with fancyTree component.
		Map<id, PB_DocPacket__c> pcktMap = new map<id, PB_DocPacket__c>([SELECT id, Packet_Name__c FROM PB_DocPacket__c]);
   		Map<id, PB_Document__c> docMap = new map<id, PB_Document__c>([SELECT id, Document_Name__c, Due_Days__c, Effective_Date__c, Expiration_Date__c, Recurring__c, 
   																			 Recurring_Frequency__c, Status__c, Type__c, Version__c, (SELECT id, DocSigner__c FROM DocSignatures__r)
   																		FROM PB_Document__c]);
       	List<PB_AssociatedDoc__c> allAssocDocs = getAllAssociatedDocs();
       	
   		for (PB_DocPacket_Document_JO__c jo : [SELECT id, DocPacket__r.id, Document__r.id FROM PB_DocPacket_Document_JO__c]){
   			treeModel.put(jo.id, new DocumentWrapper(docMap.get(jo.Document__r.id), pcktMap.get(jo.DocPacket__r.id), docMap.get(jo.Document__r.id).DocSignatures__r));
   		}

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
			    	break;
			    }
			}
		}

		
	    // An in-memory mapping to list of docPacketJo's with the packet ID		
		List<PB_DocPacket__c> pckt_pcktDocJos = [Select id, (SELECT id, DocPacket__r.id, Document__r.id FROM DocPacketJOs__r) from PB_DocPacket__c];		
		for (PB_DocPacket__c pckt: pckt_pcktDocJos) {
			pcktJos.put(pckt.id, pckt.DocPacketJOs__r);
		}
		
   		showAddEditAdmissionDoc();
    }
    
    private List<PB_AssociatedDoc__c> getAllAssociatedDocs(){
    	List<PB_AssociatedDoc__c> allAssocDocs = [SELECT id, DocPacket__r.id, Document__r.id, DocPacket__r.Packet_Name__c, Document__r.document_name__c, due_days__c, effective_date__c, filed_date__c, isAdded__c, 
       							 recurring__c, recurring_frequency__c, sObject_id__c, sObject_Type__c, status__c, status_date__c,
       							 (SELECT DocSignature__r.DocSigner__c, signed_date__c FROM AssocDocSignatures__r) 
      						FROM PB_AssociatedDoc__c WHERE sObject_id__c =: this.admission.id AND sObject_type__c = 'Admission' 
       						ORDER BY DocPacket__r.Packet_Name__c, Document__r.document_name__c];
       						
       	return allAssocDocs;
    }
    
   	private void refreshAssociatedDocs(){
 		this.associatedDocs.clear();
		for (PB_AssociatedDoc__c assocDoc : getAllAssociatedDocs()){
			if (assocDoc.isAdded__c == true){
				this.associatedDocs.add(assocDoc);
			}
 		}  
 	}
 	 
    public pageReference editTreeNode(){
    	Id selectedID = Id.valueOf(Apexpages.currentPage().getParameters().get('selectedKey'));    	
    	currrentAssocDoc = treeModel.get(selectedID).associatedDoc;
    	return null;
    }
    
  
    public pageReference updateDocSelection(){
    	Id selectedID = Id.valueOf(Apexpages.currentPage().getParameters().get('selectedKey'));
    	boolean isSelected = Boolean.valueOf(Apexpages.currentPage().getParameters().get('isSelected'));
    	    	
		// the associated record already exists
		if (selectedID.getSobjectType() == PB_DocPacket_Document_JO__c.sObjectType) {
	    	//get the Document wrapper
			updateDocSelections(treeModel.get(selectedID), isSelected);
		} else {
			// the selected node is a packet; get all the associated Docs, add ones not already present as new 
			List<PB_DocPacket_Document_JO__c> selectedTreeIds = pcktJos.get(selectedID);
			for (PB_DocPacket_Document_JO__c jo : selectedTreeIds){
				//get the Document wrapper
    			updateDocSelections(treeModel.get(jo.Id), isSelected);
			}
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
																		Due_Days__c = docWrap.doc.Due_Days__c,
																		Effective_Date__c = null,
																		Filed_Date__c = null,
																		IsAdded__c = true,
																		Recurring__c = docWrap.doc.Recurring__c,
																		Recurring_Frequency__c = docWrap.doc.Recurring_Frequency__c,
																		sObject_Id__c = this.admission.id,
																		sObject_Type__c = 'Admission',
																		Status__c = null,
																		Status_Date__c = null );
				docWrap.associatedDoc = newDoc;		
			}
	}


	public void saveAdmissionDoc() {
		List<PB_AssociatedDoc__c> newAssocDocs = new List<PB_AssociatedDoc__c>();
		List<PB_AssociatedDoc__c> updatedAssocDocs = new List<PB_AssociatedDoc__c>();


		for (ID idKey : treeModel.keyset()) {
			DocumentWrapper docWrap = treeModel.get(idKey);
			if (docWrap.isChanged && docWrap.isAssocPresent && !docWrap.isNew){			// these are already in the association table, needs update only if changed.
					updatedAssocDocs.add(docWrap.associatedDoc);
			}
			
			if (docWrap.isNew ){			// new additions
					newAssocDocs.add(docWrap.associatedDoc);
			}
			
		}
		
		
		
		update updatedAssocDocs;
		insert newAssocDocs;		
		refreshAssociatedDocs();
	}	
  
 	public void showAddEditAdmissionDoc(){
		allDocsTree = new TMN_Tree();
		List<String> addedDocs = new List<string>();
		
		for (PB_DOCPacket__c pkt : [SELECT  id, 
											Packet_Name__c, 
											(SELECT PB_DocPacket_Document_JO__c.id, DocPacket__r.id, Document__r.id, Document__r.document_name__c FROM DocPacketJOs__r ORDER BY DocPacket__r.ID, Document__r.ID),
											(SELECT DocPacket__r.id, Document__r.id FROM AssociatedDocuments__r WHERE sObject_id__c =: this.admission.id AND sObject_type__c = 'Admission' AND IsAdded__c = true)
									 from   PB_DOCPacket__c])
		{
			TMN_Tree.node pckt_node= new TMN_Tree.node(pkt.id, pkt.Packet_Name__c);
			pckt_node.refID = pkt.id;		//for the packet the key and the refID is same
			pckt_node.isfolder = true;
			allDocsTree.root.nodes.add(pckt_node);			
			for (PB_DocPacket_Document_JO__c doc :  pkt.DocPacketJOs__r){
				TMN_Tree.node doc_node= new TMN_Tree.node(doc.id, doc.Document__r.document_name__c);   // each doc has the key of junction object ID.
				doc_node.refID = pkt.id;   //for doc node, the refID has the key packetID.. the containing folder
				integer pkt_key = allDocsTree.root.getNode_Key(pkt.id);
							
				allDocsTree.root.nodes.get(pkt_key).nodes.add(doc_node);							
			}
						
			for	(PB_AssociatedDoc__c assoc : pkt.AssociatedDocuments__r){				
				for (PB_DocPacket_Document_JO__c doc :  pkt.DocPacketJOs__r){
					if (assoc.DocPacket__r.id == doc.DocPacket__r.id && assoc.Document__r.id == doc.Document__r.id){
						addedDocs.add(doc.id);
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
		public List<PB_AssocDocSignature__c> associatedDocSigners;
		
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