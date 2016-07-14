public with sharing class TmnProviderApplication {
	public Tmn_Provider_Application__c application { get; set; }
	private transient ApexPages.StandardController standardController;
	private static transient Map<String, RecordTypeInfo> recordTypeMap = Schema.SObjectType.Tmn_Provider_Application__c.getRecordTypeInfosByName();

	public String mode { get; set; }

	public Boolean isViewMode {
		get {
			return this.mode == 'view';
		}
	}

	public Boolean isEditMode {
		get {
			return this.mode == 'edit';
		}
	}

	private transient Boolean isLocked;

	public Boolean getIsLocked() {
		if (this.isLocked == null) {
			this.isLocked = this.application.Status__c != 'Pending Approval';
		}
		return this.isLocked;
	}

	public String getTitle() {
		if (isEditMode && this.application.Id == null) {
			return 'Create New Application';
		}
		return this.application.Name;
	}

	public List<PB_AssociatedDoc__c> associatedDocs { get; set; }

	public TMN_TreePktDocTable allDocsTree { get; set; }
	public String treeData {
		get {
			if (allDocsTree == null) {
				return '""';
			}
			return JSON.serialize(allDocsTree.root.children);
		}
	}

	// An in-memory DB to represent componenets managed by the fancy tree, with the key being the Packet-Doc Juntion ID
	public Map<Id, DocumentWrapper> treeModel;
	public PB_AssociatedDoc__c currrentAssocDoc { get; set; }
	public PB_Document__c currrentDoc { get; set; }
	public transient String assocDocRecurrs { get; set; }

	public Map<Id, List<PB_DocPacket_Document_JO__c>> pcktJos = new Map<Id, List<PB_DocPacket_Document_JO__c>>();

	//keys returned by the fancy tree comp are stored here
	public string selectedKeys { get; set; }


	public PageReference redirectNew() {
		// Redirect to the new Provider page if necessary
		Map<String, String> params = ApexPages.currentPage().getParameters();
		if (!params.containsKey('applicantId') && this.application.Id == null) {
			return Page.TmnProvider;
		}
		return null;
	}

	public TmnProviderApplication(ApexPages.StandardController standardController) {
		this.standardController = standardController;

		if (!Test.isRunningTest()) {
			standardController.addFields(new String[] {
				'Name', 'Provider__r.Brokerage__c'
			});
		}

		this.application = (Tmn_Provider_Application__c) standardController.getRecord();

		Map<String, String> params = ApexPages.currentPage().getParameters();

		if (this.application.Id != null) {
			this.mode = 'view';
			if (params.containsKey('mode')) {
				this.mode = params.get('mode');
			}
			this.associatedDocs = new List<PB_AssociatedDoc__c>();
			this.treeModel = new Map<Id, DocumentWrapper>();

			Map<Id, PB_DocPacket__c> pcktMap = new Map<Id, PB_DocPacket__c>([
				SELECT Id, Packet_Name__c FROM PB_DocPacket__c WHERE Recordtype.name = 'Tmn Provider Application'
			]);
			Map<Id, PB_Document__c> docMap = new Map<Id, PB_Document__c>([
				SELECT Id, Document_Name__c, Due__c, Due_Date__c, Effective_Date__c, Expiration_Date__c,
				       Recurring_Frequency__c, Recurring_Interval__c, Status__c, Type__c, Version__c,
				       (SELECT id, DocSigner__c FROM DocSignatures__r)
				  FROM PB_Document__c
				  WHERE Recordtype.Name = 'Tmn Provider Application'
			]);

			for (PB_DocPacket_Document_JO__c jo : [
					SELECT Id, DocPacket__r.Id, Document__r.id
					  FROM PB_DocPacket_Document_JO__c
					 WHERE DocPacket__r.Recordtype.Name = 'Tmn Provider Application'
					   AND Document__r.Recordtype.Name = 'Tmn Provider Application'
			]){
				treeModel.put(
					jo.id,
					new DocumentWrapper(
						docMap.get(jo.Document__r.id),
						pcktMap.get(jo.DocPacket__r.id),
						docMap.get(jo.Document__r.id).DocSignatures__r
					)
				);
			}
			refreshInMemoryMapAndAssocDocs();

			// An in-memory mapping to list of docPacketJo's with the packet ID
			List<PB_DocPacket__c> pckt_pcktDocJos = [
				SELECT Id, (SELECT Id, DocPacket__r.Id, Document__r.Id FROM DocPacketJOs__r)
				  FROM PB_DocPacket__c
				 WHERE Recordtype.name = 'Tmn Provider Application'
			];
			for (PB_DocPacket__c pckt: pckt_pcktDocJos) {
				pcktJos.put(pckt.id, pckt.DocPacketJOs__r);
			}

			//get all the doc recurrences for this application
			assocDocRecurrs = JSON.serialize([
				SELECT id, PB_AssociatedDoc__c, status__c, status_date__c, Comments__c
				  FROM PB_AssocDocRecurrence__c
				 WHERE PB_AssociatedDoc__r.sObject_type__c = 'Tmn_Provider_Application__c'
				   AND PB_AssociatedDoc__r.sObject_id__c = :this.application.id
				 ORDER BY status_date__c desc
			]);

			allDocsTree = new TMN_TreePktDocTable();

			this.dummyTask = new Task();
			this.currentTask = new Task(OwnerId = UserInfo.getUserId());
			this.tasks = new list<Task>();
			this.showTaskSteps = true;
			populateTasks();

		} else if (params.containsKey('applicantId')) {
			// This is a new Application
			this.mode = 'edit';
			this.application.RecordTypeId = recordTypeMap.get('OR').getRecordTypeId();
			this.application.Status__c = 'Pending Approval';
			this.application.Provider__c = params.get('applicantId');

			Tmn_Provider__c provider = [
				SELECT Id, Address_Street_1__c, Address_Street_2__c, City__c, State__c, Zip__c,
				       Phone_1__c, Phone_2__c, Fax__c, Primary_Email__c, First_Name__c, Middle_Name__c,
				       Last_Name__c, Gender__c, SPD_Number__c, eXPRS_Number__c, Brokerage__c, Name,
				       (SELECT Id FROM Tmn_Provider_Applications__r)
				  FROM Tmn_Provider__c
				 WHERE Id = :this.application.Provider__c
			];
			this.application.Address_Street_1__c = provider.Address_Street_1__c;
			this.application.Address_Street_2__c = provider.Address_Street_2__c;
			this.application.City__c = provider.City__c;
			this.application.State__c = provider.State__c;
			this.application.Zip__c = provider.Zip__c;
			this.application.Phone_1__c = provider.Phone_1__c;
			this.application.Phone_2__c = provider.Phone_2__c;
			this.application.Fax__c = provider.Fax__c;
			this.application.Primary_Email__c = provider.Primary_Email__c;

			if (provider.Tmn_Provider_Applications__r.size() == 0) {
				this.application.Enrollment_Type__c = 'New';
			} else {
				this.application.Enrollment_Type__c = 'Re-Enrollment';
			}

			this.application.Provider__r = provider;

		}
	}

	public PageReference save() {
		return this.save(true);
	}

	public PageReference approve() {
		String originalStatus = this.application.Status__c;
		this.application.Status__c = 'Approved';
		PageReference pageRef = this.save(true);
		if (pageRef == null) {
			this.application.Status__c = originalStatus;
		}
		return pageRef;
	}

	public PageReference disqualify() {
		if (!validateDisqualifiedApplication(this.application)) {
			return null;
		}
		String originalStatus = this.application.Status__c;
		this.application.Status__c = 'Disqualified';
		this.application.Disqualified__c = true;
		PageReference pageRef = this.save(false);
		if (pageRef == null) {
			this.application.Status__c = originalStatus;
		}
		return pageRef;
	}

	public PageReference disqualifyApprovedApplication() {
		if (!validateDisqualifiedApplication(this.application)) {
			return null;
		}
		this.application.Disqualified__c = true;
		PageReference pageRef = this.save(false);
		if (pageRef == null) {
			this.application.Disqualified__c = false;
		}
		return pageRef;
	}

	public PageReference save(Boolean validateNeeded) {
		if (validateNeeded && !validate(this.application)) {
			return null;
		}
		upsert this.application;
		PageReference page = ApexPages.currentPage();
		Map<String, String> params = page.getParameters();
		params.clear();
		params.put('mode', 'view');
		params.put('id', this.application.Id);
		page.setRedirect(true);
		return page;
	}

	private static Boolean validate(Tmn_Provider_Application__c application) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();
		if (application.Status__c == 'Approved') {
			if (application.Provider__r.SPD_Number__c == '' || application.Provider__r.SPD_Number__c == null) {
				application.Provider__r.SPD_Number__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (application.Provider__r.eXPRS_Number__c == '' || application.Provider__r.eXPRS_Number__c == null) {
				application.Provider__r.eXPRS_Number__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (application.Provider__r.Brokerage__c == null) {
				application.Provider__r.Brokerage__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (application.Application_Date__c == null) {
				application.Application_Date__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (application.Effective_Date__c == null) {
				application.Effective_Date__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
			if (application.Expiration_Date__c == null) {
				application.Expiration_Date__c.addError(errorGenerator.generate(fieldRequiredError));
				noError = false;
			}
		}
		return noError;
	}

	public static Boolean validateDisqualifiedApplication(Tmn_Provider_Application__c application) {
		Boolean noError = true;
		String fieldRequiredError = 'Field is required';
		Utility.ErrorGenerator errorGenerator = new Utility.ErrorGenerator();

		if (application.Reason_for_Disqualification__c == '' || application.Reason_for_Disqualification__c == null) {
			application.Reason_for_Disqualification__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		if (application.Disqualification_Date__c == null) {
			application.Disqualification_Date__c.addError(errorGenerator.generate(fieldRequiredError));
			noError = false;
		}
		return noError;
	}

	public Set<String> subjectLines = new Set<String>{
		'Schedule Interview',
		'Collect Initial Paperwork',
		'Complete CRIMS Check',
		'Schedule Interview with PSW',
		'Complete Initial Placement'
	};

	public Task dummyTask{ get; set; }  //dummy task to bind the Assigned to field

	public Task currentTask {
		get {
			if (currentTask == null) {
				currentTask = new Task();
				currentTask.Priority = 'Normal';
				currentTask.OwnerId = UserInfo.getUserId();
				currentTask.Status = 'Not Started';
				currentTask.RecordTypeId = taskRecordTypeId;
				currentTask.WhatID = this.application.Id;
			}
			return currentTask;
		}
		private set;
	}

	public List<Task> tasks { get; set; }
	public Boolean showTaskSteps { get; set; }

	Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Tmn Provider Application').getRecordTypeId();

	public void populateTasks() {
		this.tasks =  [
			SELECT Id, Subject, Description, ActivityDate, OwnerId, Owner.Name, Priority, Status,
			       whatId, WhoId
			  FROM Task
			 WHERE WhatId != null
			   AND WhatID =:this.application.Id
			 ORDER BY Number__c asc, CreatedDate desc
		];
		if(this.tasks.size() == 0){
			showTaskSteps = true;
		} else { //Check if the tasks available are regular tasks or steps based on subject line
			for(Task t: tasks){
				if(subjectLines.contains(t.Subject)){
					showTaskSteps = false;
					break;
				}
			}
		}
	}

	public pageReference createTasks(){
		if(String.isBlank(dummyTask.OwnerId)){
			dummyTask.OwnerId.addError('Field is required!');
			return null;
		}
		List<Task> tempSteps = new List<Task>();

		for(string s: subjectLines){ // With latest salesforce release we can now rely on the order of elements in a set
			Task t = new Task(
				RecordtypeId = taskRecordTypeId,
				Subject = s,
				OwnerId = dummyTask.OwnerId,
				Priority = 'Normal',
				Status = 'Not Started',
				WhatId  = this.application.id
			);
			tempSteps.add(t);
		}
		if(tempSteps.size() > 0){
			try{
				insert tempSteps;
				populateTasks();
				return null;
			}catch (exception e){
				Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
				return null;
			}
		}
		return null;
	}

	public void showAddTask() {
		this.currentTask = new Task();
		this.currentTask.Priority = 'Normal';
		this.currentTask.OwnerId = UserInfo.getUserId();
		this.currentTask.Status = 'Not Started';
		this.currentTask.RecordTypeId = taskRecordTypeId;
		this.currentTask.WhatID = this.application.Id;
	}

	public void saveTask(){
		try {
			upsert this.currentTask;
			populateTasks();
			showAddTask();
		} catch(exception e) {
			Apexpages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
	}

	public void closeTask(){
		showAddTask();
	}

	public void showEditTask(){
		String taskId = ApexPages.currentPage().getParameters().get('taskId');
		this.currentTask = [
			SELECT Id, Subject, Description, ActivityDate, OwnerId, Owner.Name, Priority, Status,
			       whatId, whoId
			  FROM Task
			 WHERE Id = :taskId
		];
	}

	public void showAddEditDoc(){
		allDocsTree = new TMN_TreePktDocTable();
		Map<String, TMN_TreePktDocTable.node> nodeKeyMap;
		List<PB_DocPacket__c> pkts = [
			SELECT Id, Packet_Name__c, Default_Admission_Packet__c,
			       (SELECT PB_DocPacket_Document_JO__c.id, DocPacket__r.id, Document__r.id,
			               Document__r.document_name__c, Document__r.Recurring_Interval__c,
			               Document__r.Recurring_Frequency__c
			          FROM DocPacketJOs__r
			         WHERE Document__r.Status__c = 'Active'
			         ORDER BY DocPacket__r.ID, Document__r.ID
			       ),
			       (SELECT DocPacket__r.id, Document__r.id, Due_Date__c, Effective_Date__c, Status__c, Status_Date__c
			          FROM AssociatedDocuments__r
			         WHERE sObject_id__c =: this.application.id
			           AND sObject_type__c = 'Tmn_Provider_Application__c'
			           AND IsAdded__c = true
			       )
			  FROM PB_DocPacket__c
			 WHERE Recordtype.Name = 'Tmn Provider Application'
			   AND Status__c = 'Active'
		];

		for (PB_DocPacket__c pkt: pkts) {
			TMN_TreePktDocTable.node pckt_node = new TMN_TreePktDocTable.node(pkt.id, pkt.Packet_Name__c);
			pckt_node.folder = true;
			pckt_node.unselectable = pkt.Default_Admission_Packet__c;
			allDocsTree.root.children.add(pckt_node);
			for (PB_DocPacket_Document_JO__c doc :  pkt.DocPacketJOs__r){
				TMN_TreePktDocTable.node doc_node = new TMN_TreePktDocTable.node(doc.id, doc.Document__r.document_name__c);   // each doc has the key of junction object ID.
				doc_node.recurrFreq = doc.Document__r.Recurring_Interval__c;
				allDocsTree.root.children.get(allDocsTree.root.getNode_Key(pkt.id)).children.add(doc_node);
			}
		}

		nodeKeyMap = TMN_TreePktDocTable.buildNodeKeyMapFor(allDocsTree.root.children);
		for (PB_DocPacket__c pkt : pkts) {
			for (PB_AssociatedDoc__c assoc : pkt.AssociatedDocuments__r) {
				for (PB_DocPacket_Document_JO__c jo :  pkt.DocPacketJOs__r) {
					if (assoc.DocPacket__r.id == jo.DocPacket__r.id && assoc.Document__r.id == jo.Document__r.id) {
						TMN_TreePktDocTable.node node = nodeKeyMap.get(jo.id);
						node.dueDate = assoc.Due_Date__c;
						node.assocStatus = assoc.Status__c;
						node.statusDate = assoc.Status_Date__c;
						node.unselectable = pkt.Default_Admission_Packet__c;
						node.Selected = true;
						break;
					}
				}
			}
		}
		selectedKeys = allDocsTree.GetSelectedNodeStr;
		currrentAssocDoc = null;
		currrentDoc = null;
	}

	public PageReference cancelSelection() {
		PageReference pg = new PageReference ('/' + this.application.id);
		pg.setRedirect(true);
		return pg;
	}

	public PageReference editTreeNode() {
		Id selectedID = Id.valueOf(Apexpages.currentPage().getParameters().get('selectedKey'));
		currrentAssocDoc = treeModel.get(selectedID).associatedDoc;
		currrentDoc = treeModel.get(selectedID).doc;
		treeModel.get(selectedID).isChanged = true;
		return null;
	}

	public PageReference updateDocSelection() {
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
		if(docWrap.associatedDoc != null) {
			docWrap.isChanged = true;
			docWrap.associatedDoc.isAdded__c = isSelected;
		} else {
			// the selected document is not present in the associated docs.... add it
			docWrap.isNew = true;
			PB_AssociatedDoc__c newDoc = new PB_AssociatedDoc__c (
				DocPacket__c = docWrap.packet.id,
				Document__c = docWrap.doc.id,
				IsAdded__c = true,
				sObject_Id__c = this.application.id,
				sObject_Type__c = 'Tmn_Provider_Application__c',
				Status__c = 'Pending',
				Status_Date__c = null
			);
			docWrap.associatedDoc = newDoc;
		}
	}

	public void saveDoc() {
		List<PB_AssociatedDoc__c> newAssocDocs = new List<PB_AssociatedDoc__c>();
		List<PB_AssociatedDoc__c> updatedAssocDocs = new List<PB_AssociatedDoc__c>();

		for (ID idKey : treeModel.keyset()) {
			DocumentWrapper docWrap = treeModel.get(idKey);
			if (docWrap.isChanged && docWrap.isAssocPresent && !docWrap.isNew){ // these are already in the association table, needs update only if changed.
				updatedAssocDocs.add(docWrap.associatedDoc);
			} else if (docWrap.isNew ){ // new additions
				newAssocDocs.add(docWrap.associatedDoc);
			}
		}
		update updatedAssocDocs;
		insert newAssocDocs;

		refreshInMemoryMapAndAssocDocs();
	}

	@TestVisible
	private List<PB_AssociatedDoc__c> getAllAssociatedDocs() {
		List<PB_AssociatedDoc__c> allAssocDocs = [
			SELECT Id, DocPacket__r.Id, Document__r.Id, DocPacket__r.Packet_Name__c,
			       Document__r.document_name__c, Document__r.Version__c, Document__r.Due__c,
			       Due_Date__c, Document__r.Type__c, Document__r.Recurring_Interval__c,
			       Document__r.Recurring_Frequency__c, isAdded__c, sObject_id__c, sObject_Type__c,
			       status__c, status_date__c, comments__c,
			       (SELECT isSigned__c, DocSignature__r.DocSigner__c, signed_date__c FROM AssocDocSignatures__r)
			  FROM PB_AssociatedDoc__c
			 WHERE sObject_id__c = :this.application.id
			   AND sObject_type__c = 'Tmn_Provider_Application__c'
			 ORDER BY DocPacket__r.Packet_Name__c, Document__r.document_name__c
		];
		return allAssocDocs;
	}

	private void refreshInMemoryMapAndAssocDocs(){
		List<PB_AssociatedDoc__c> allAssocDocs = getAllAssociatedDocs();
		this.associatedDocs.clear();
		for (PB_AssociatedDoc__c assocDoc : allAssocDocs){
			// these are the ones already added to this application
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

	public class DocumentWrapper {
		public PB_Document__c doc;
		public PB_DocPacket__c packet;
		public List<PB_DocSignature__c> docSigners;
		public PB_AssociatedDoc__c associatedDoc;
		public List<PB_AssocDocSignature__c> associatedDocSigners = new List<PB_AssocDocSignature__c>();

		public boolean isAssocPresent = false; // to indicate if the packet-Doc junction is already present in the association table
		public boolean isChanged = false;
		public boolean isNew = false;

		public DocumentWrapper(PB_Document__c doc, PB_DocPacket__c pckt, List<PB_DocSignature__c> docSigners){
			this.doc = doc;
			this.packet = pckt;
			this.docSigners = docSigners;
		}
	}
}