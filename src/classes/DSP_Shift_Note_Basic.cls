public without sharing class DSP_Shift_Note_Basic {
private map<String, String> requestParams;
public NoteWrapper noteWrapper {get;set;}
public TMN_Tree formTree {get; set;}
public string selectedKeys {get; set;}
public boolean editMode {get; set;}

public Boolean amItheOwner { get { return noteWrapper.OwnerID == UserInfo.getUserId();} set;}


public class NoteWrapper {
    public Id id {get;set;}
    public String name {get;set;}
    public boolean locked {get;set;}    
    public boolean Disregard_Note {get;set;}
    public boolean Late_Entry {get;set;}
    public datetime Start_Time {get;set;}
    public datetime End_Time {get;set;}
    public Integer Number_of_Required_Signatures {get;set;}
    public String Narrative {get;set;}
    public boolean Healthcare_Medical_Note {get;set;}
    
    public Id ownerId {get;set;}
    public String createdbyName {get;set;}
    public String lastmodifiedbyName{get;set;}
    public datetime CreatedDate {get;set;}
    public datetime LastModifiedDate {get;set;}
    public boolean No_Approval_Needed {get;set;}
    public String Approval_Status {get;set;}
    public Date Approval_Status_Date {get;set;}

    public Id Action_Plan {get;set;}
    public Id Service_Assignment {get;set;}
    public Id Admission {get;set;}
    public String RecordTypeid  {get;set;}
    public Id Person_Being_served {get;set;}
    public String Person_Being_Served_Name {get;set;}
    public String Signature_on_File {get;set;}
    public String Status {get;set;}
    
    public NoteWrapper(){}   
    public NoteWrapper(Progress_Note__c note){
        this.id = note.id;
        this.name = note.name;
        this.locked = note.locked__c;    
        this.Disregard_Note = note.Disregard_Note__c;
        this.Late_Entry = note.Late_Entry__c;
        this.Start_Time = note.Start_Time__c;
        this.End_Time = note.End_Time__c;
        this.Number_of_Required_Signatures = Integer.ValueOf(note.Number_of_Required_Signatures__c);
        this.Narrative = note.Narrative__c;
        this.Healthcare_Medical_Note = note.Healthcare_Medical_Note__c;
    
        this.ownerId = note.ownerId;
        //note.createdby == null ? UserInfo.getName() : note.createdby.Name;
        this.createdbyName = note.createdby.Name;
        this.lastmodifiedbyName = note.lastmodifiedby.Name;
        this.CreatedDate = note.CreatedDate;
        this.LastModifiedDate = note.LastModifiedDate;
        this.No_Approval_Needed = note.No_Approval_Needed__c;
        this.Approval_Status = note.Approval_Status__c;
        this.Approval_Status_Date = note.Approval_Status_Date__c;
        this.Status = note.Status__c;

        this.Action_Plan = note.Action_Plan__c;
        this.Service_Assignment = note.Service_Assignment__c;
        this.Admission = note.Admission__c;
        this.RecordTypeid = note.RecordTypeid;
        this.Person_Being_served = note.Person_Being_served__c;
        this.Person_Being_Served_Name = note.Person_Being_Served__r.Name;
        this.Signature_on_File = note.Signature_on_File__c;
    }
    
    public Progress_Note__c NoteSObject(){
        return new Progress_Note__c(
			        id = this.id,
			        locked__c = this.locked,    
			        Disregard_Note__c = this.Disregard_Note,
			        Late_Entry__c = this.Late_Entry,
			        Start_Time__c = this.Start_Time,
			        End_Time__c = this.End_Time,
			        Number_of_Required_Signatures__c = Decimal.valueOf(this.Number_of_Required_Signatures),
			        Narrative__c = this.Narrative,
			        Healthcare_Medical_Note__c = this.Healthcare_Medical_Note,
			        No_Approval_Needed__c = this.No_Approval_Needed,
//			        Approval_Status__c = this.Approval_Status,
//			        Approval_Status_Date__c = Date.parse(this.Approval_Status_Date),
			        Action_Plan__c = this.Action_Plan,
			        Service_Assignment__c = this.Service_Assignment,
			        Admission__c = this.Admission,
			        RecordTypeid = this.RecordTypeid,
			        Person_Being_served__c = this.Person_Being_served);
    }
    
}

//this is called when creatig a new shift note from DSP Home page.
	public DSP_Shift_Note_Basic(String inputs){
		if (inputs instanceof Id) this((Id) inputs);
		else {
		Progress_Note__c note = new Progress_Note__c();
        this.editMode = true;
        
		//pbsID:003g000000cScTLAA0,saID:a0Mg0000005xuhbEAA,admID:a0Dg0000005lXzmEAE,apID:a1Dg0000001pTXwEAM
        requestParams = (Map<String, String>) JSON.deserialize(inputs, map<String, String>.class);
        note.Action_Plan__c = requestParams.get('apID');
        note.Service_Assignment__c = requestParams.get('saID');
        note.Admission__c = requestParams.get('admID');
        note.RecordTypeid = [select id from recordtype where DeveloperName='Shift_Note' and SobjectType='Progress_Note__c' limit 1].id;
        note.Person_Being_served__c = requestParams.get('pbsID');        
        note.Number_of_Required_Signatures__c = 1.0; // only dsp user needs to eSign
        note.ownerId = UserInfo.getUserId();
        note.Approval_Status__c = '';
        note.Approval_Status_Date__c = null;
        this.noteWrapper = new NoteWrapper(note);
        populateFormTree();
		}
	}
		
    private void populateFormTree(){
        this.formTree = new TMN_Tree();
        List<string> okstatus = new list<string>();
        okstatus.add ('In Progress');
        okstatus.add ('Revised');
        okstatus.add ('New'); 
        okstatus.add ('N/A');
                
        // list of all objective with their parent goal and child actions in the sorted order  
        list<Action_Plan_Objective__c> allObjectives = [select action_plan_goal__r.id, action_plan_goal__r.description__c, 
                                    id, Description__c,
                                    (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) 
                               from action_plan_objective__c 
                              where action_plan_goal__r.action_plan__c = :this.noteWrapper.Action_Plan
                                and status__c in :okstatus 
                                order by action_plan_goal__r.Sort_Order__c, Sort_Order__c];
        
        //temprary set to determine if goal is already added to the tree
        set<id> tempSetGoals = new set<id>();
        for (Action_Plan_Objective__c obj : allObjectives) {

            if (!tempSetGoals.contains(obj.action_plan_goal__r.id)) { // the goal isnt added yet, add it to the temp set and to the tree 
                tempSetGoals.add(obj.action_plan_goal__r.id);

                TMN_Tree.node g_node = new TMN_Tree.node(obj.action_plan_goal__r.id, obj.action_plan_goal__r.description__c);
                g_node.isFolder = true;
                formTree.root.nodes.add(g_node);  // add the GOAL at the root node
            }
            
            TMN_Tree.node o_node = new TMN_Tree.node(obj.id, obj.Description__c);
            o_node.isExpand = false;
            integer g_key = formTree.root.getNode_Key(obj.action_plan_goal__r.id);
            formTree.root.nodes.get(g_key).nodes.add(o_node);  // add the objective  
            
            for(Action_Plan_Action__c action : obj.Action_Plan_Actions__r) {
                TMN_Tree.node a_node= new TMN_Tree.node(action.id, action.Description__c);
                a_node.hideCheckbox = true;
                a_node.extraClasses = 'actionTitle';
                integer g_key1 = formTree.root.getNode_Key(obj.action_plan_goal__r.id);
                integer o_key1 = formTree.root.nodes.get(g_key1).getNode_Key(obj.id);
                if(o_key1 != -1){
                    formTree.root.nodes.get(g_key1).nodes.get(o_key1).nodes.add(a_node);  //add the action
                }
            }            
        }
        
        list<String> selectedItems = new list<String>();
        for (ProgressNote_ActionPlanChildren_mjo__c item: [select Goal__c, Objective__c From ProgressNote_ActionPlanChildren_mjo__c Where Progress_Note__c =: this.noteWrapper.id ]) {
            if (item.Goal__c != null) selectedItems.add(item.Goal__c);
            else if (item.Objective__c != null) selectedItems.add(item.Objective__c);
        }
        formTree.inputSelectedKeys(selectedItems, true);
        this.selectedKeys = formTree.GetSelectedNodeStr;
    }
     
//this is called for view/edit for a known shift note
    public DSP_Shift_Note_Basic(Id pnId) {
        list<string> selectFields = new list<string>();
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Progress_Note__c').getDescribe().Fields.getMap();
            if (fMap != null) {
                for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
                }
            }
        selectFields.addAll(new List<String>{'LastModifiedBy.Name', 'CreatedBy.Name', 'Person_Being_Served__r.Name'});
        String strSQL =  'SELECT ' + String.join(selectFields, ',') + ' FROM Progress_Note__c WHERE Id = \'' + pnId + '\'';
        Progress_Note__c note = (Progress_Note__c) Database.query(strSQL)[0];
        this.noteWrapper = new NoteWrapper(note);
        editMode = false;
        

        this.formTree = new TMN_Tree();
        list<ProgressNote_ActionPlanChildren_mjo__c> allApmjos = [select Goal__r.id, Goal__r.description__c, Objective__r.id, Objective__r.Description__c, Objective__r.Action_Plan_Goal__c
											             from ProgressNote_ActionPlanChildren_mjo__c 
											             where Progress_Note__c =: this.noteWrapper.id
											             order by  Goal__c nulls last, Goal__r.Sort_Order__c, Objective__r.Sort_Order__c];
        //fill in the formTree with Goal and Objectives based on whats in the APmjo table
        set<id> tempSetGoals = new set<id>(); // used to identify if a goal is already added to the tree
        set<id> tempSetObjectives = new set<id>(); // used to retrieve all the actions for these 
        for (ProgressNote_ActionPlanChildren_mjo__c obj : allApmjos) {
            if (obj.Goal__r.id != null && !tempSetGoals.contains(obj.Goal__r.id)) {  // the list should have goals first   
                tempSetGoals.add(obj.Goal__r.id);
                formTree.root.nodes.add(new TMN_Tree.node(obj.Goal__r.id, obj.Goal__r.description__c));  // add the GOAL at the root node
            } else { // first time loop goes in here, all the goals would have added because of the sort order on the Apmjos
            	tempSetObjectives.add(obj.Objective__r.id); 
	            TMN_Tree.node o_node = new TMN_Tree.node(obj.Objective__r.id, obj.Objective__r.Description__c);
	            integer g_key = formTree.root.getNode_Key(obj.Objective__r.Action_Plan_Goal__c);
	            formTree.root.nodes.get(g_key).nodes.add(o_node);  // add the objective
            }  
        }
        
        //fill in the objectives actions here since they are not part of the APmjos.
        for (Action_Plan_Objective__c obj : [select action_plan_goal__r.id, id,
					                                (select description__c, id from Action_Plan_Actions__r order by Sort_Order__c) 
					                           from action_plan_objective__c 
                                               where id in : tempSetObjectives]){
	        for (Action_Plan_Action__c action : obj.Action_Plan_Actions__r) {
	            integer g_key1 = formTree.root.getNode_Key(obj.action_plan_goal__r.id);
	            integer o_key1 = formTree.root.nodes.get(g_key1).getNode_Key(obj.id);
	            if(o_key1 != -1){
	               formTree.root.nodes.get(g_key1).nodes.get(o_key1).nodes.add(new TMN_Tree.node(action.id, action.Description__c));  //add the action
	            }
	        }                                                          	
        }                                                  	
        this.selectedKeys = String.join(new list<Id>(tempSetGoals),',') + ',' + String.join(new list<Id>(tempSetObjectives),',');
    }
    
    public pagereference mySave(){
        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Update Shift Note';
        txn.requested_date_time__c = DateTime.Now();
            
        Map<String, String> inputs = new Map<String, String>{'payload.Note' => json.serialize(this.noteWrapper.noteSObject()), 
        	                                                  'payload.goalObjectAssociations' => json.serialize(this.selectedKeys.split(','))};
        txn.input_params__c = json.serialize(inputs);
        system.debug('form values: ' + inputs);
        try { 
            insert txn;
            PageReference pr =  Page.DSP_ShiftNote_Basic;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }    	
    }
    
    public pagereference myEdit(){
    	populateFormTree();
        editMode = true;
        return null;
    }
    
    public PageReference myFinal(){
        try{
/*            PageReference Note_Pdf_ref = Page.Notes_ShiftNote_Pdf;           
            Note_Pdf_ref.getParameters().put('id', this.noteWrapper.id);
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.parentId = this.noteWrapper.id;
            attachmentPDF.Name = this.noteWrapper.Person_Being_Served_Name + ' - ' + 'Shift_Note' +' - (' + date.today().month() + '-' + date.today().day() + '-' + date.today().year() + ').pdf';
            attachmentPDF.body = !Test.isRunningTest() ? Apexpages.currentPage().getContentAsPDF() : Blob.valueOf('dummy content'); // Modified by Sravan as we cannot invoke getCOntent() method from test class-Salesforce bug. 10/28/2014 1:00 PM
            insert attachmentPDF; */
            this.noteWrapper.No_approval_Needed = true; // just mark this, rest is taken care by the workflow rule on this object.
            return mySave();
        } catch(DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public pagereference myCancel(){
        /*PageReference pr = new PageReference( retURL);
        return pr; */
        return null;
    }   
    
    // updates the billable flag on the record then redirects to detail view of Progress Note
    public PageReference updateLocked () {
        Transaction_Queue__c txn  = new Transaction_Queue__c(requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Disregard Shift Note';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = this.noteWrapper.Id;
        try { 
            insert txn;
            PageReference pr =  Page.DSP_ShiftNote_Basic;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }       
    }
 
}