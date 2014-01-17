public with sharing class Shift_Note_Basic {
    Progress_Note__c note = new Progress_Note__c();
    string userid  =UserInfo.getUserId() ;
    public list<Action_Plan_Goal__c> allgoals = new list<Action_plan_Goal__c>();
    public list<Action_Plan_Goal__c> GETallgoals(){return allgoals;}
    public map<string, clsPlan_Goal> Goals = new map<string, clsPlan_Goal>();
    public map<string, clsPlan_Goal> getGoals() {return Goals;}
    
    public map<id, ProgressNote_ActionPlanChildren_mjo__c> childrenScope = new map<id, ProgressNote_ActionPlanChildren_mjo__c>();
    public map<id, ProgressNote_ActionPlanChildren_mjo__c> getchildrenScope() {return childrenScope ;}
    public boolean editMode {get; set;}
    public Action_Plan__c plan { get {return plan;} set;}
    public id planID {get; set;}
    
    public Shift_Note_Basic(ApexPages.StandardController controller) {
        
        if (!Test.isRunningTest()) {
            controller.AddFields (new List<String> {'Service_Assignment__c', 'Admission__c', 'Action_Plan__c'});
        }
        note = (Progress_Note__c )controller.getRecord();
        editMode = false;
        if(apexpages.currentpage().getparameters().get('edit')=='1' && !note.locked__c){
            editMode= true;
        }
        if(note.id ==null){
            planID = apexpages.currentpage().getparameters().get('planId');
            note.Action_Plan__c = planID;
            note.service_assignment__c = apexpages.currentpage().getparameters().get('saID');
            note.admission__c = apexpages.currentpage().getparameters().get('admID');
            editMode = true;
            note.RecordTypeid = [select id from recordtype where DeveloperName='Shift_Note' and SobjectType='Progress_Note__c' limit 1].id;
            //sa = 
            note.Person_Being_served__c = [select person_being_served__c from admission__c where id = :apexpages.currentpage().getparameters().get('admID')].person_being_served__c;    
            
        } 
        //plan = [ select id, name, service_assignment__r.person_being_served__c, service_assignment__r.admission__c from action_plan__c where id = :note.Action_Plan__c ];
       // 

        List<string> okstatus = new list<string>();
        okstatus.add ('In Progress');
        okstatus.add ('Revised');
        okstatus.add ('New');   
        
        if (note.action_plan__c != null){
            allgoals = [select id, description__c, 
                            (select id, Description__c from action_plan_objectives__r where status__c in :okstatus) 
                                    from Action_Plan_Goal__c 
                                        where Action_Plan__c = :note.Action_Plan__c];
          //  Goals = new map<string, clsPlan_Goal>();
            system.debug('id is - ' + note.Action_Plan__c);
            //set<id> childrenScope 
            
       
               
                for (ProgressNote_ActionPlanChildren_mjo__c item: 
                            [select id, name, Progress_Note__c, Goal__c, Objective__c 
                                    From ProgressNote_ActionPlanChildren_mjo__c 
                                        Where Progress_Note__c = :note.id  ]){
                    
                      childrenScope.put(item.Goal__c,item);                  
                      childrenScope.put(item.Objective__c, item);
                }        
            
                            
            for(Action_Plan_Goal__c g : allgoals){
                clsPlan_Goal tmpclsG =  new clsPlan_Goal(g);
                Goals.put(g.id, tmpclsG);
                Goals.get(g.id).inNote = childrenScope.containskey(g.id); 
            
                    for(Action_Plan_Objective__c o : g.Action_Plan_Objectives__r){
                        clsPlan_Obj tmpclsO = new clsPlan_Obj(o);
                        Goals.get(g.id).objs.put(o.id, tmpclsO);
                        Goals.get(g.id).objs.get(o.id).inNote = childrenScope.containskey(o.id);
                    }     
            }
        }
    }
    
    public class clsPlan_Goal{
        public boolean inNote {get; set;}
       // public map< string, clsPlan_Obj> objs {get; set;}
        public Action_Plan_Goal__c theGoal {get; set;}
        public map< string, clsPlan_Obj> objs = new map< string, clsPlan_Obj>();
        public map< string, clsPlan_Obj> getobjs (){ return objs;}
        public clsPlan_Goal(Action_Plan_Goal__c g){
         //   objs = new map< string, clsPlan_Obj>();
            theGoal = g;
            inNote = false;
        
        }
    }
    
    public class clsPlan_Obj{
        public boolean inNote {get; set;}
        public Action_Plan_Objective__c theObj {get; set;}
        public clsPlan_Obj(Action_Plan_Objective__c o){
            theObj = o;
            inNote = false;
        
        }
    
    }
         // 
    public pagereference mySave(){
        List<ProgressNote_ActionPlanChildren_mjo__c> deleteJo =  new List<ProgressNote_ActionPlanChildren_mjo__c>();
        List<ProgressNote_ActionPlanChildren_mjo__c> insertJo =  new List<ProgressNote_ActionPlanChildren_mjo__c>();
        childrenScope.clear();
            for (ProgressNote_ActionPlanChildren_mjo__c item: 
                        [select id, name, Progress_Note__c, Goal__c, Objective__c 
                                From ProgressNote_ActionPlanChildren_mjo__c 
                                    Where Progress_Note__c = :note.id ]){
                
                  childrenScope.put(item.Goal__c,item);                  
                  childrenScope.put(item.Objective__c, item);
            } 

        try{
            upsert note;
            for(clsPlan_Goal clsG: Goals.values()){
                //if the goal box is checked and it hasn't already been inserted
                if(clsG.inNote && !childrenScope.containskey(clsG.theGoal.id)){
                    ProgressNote_ActionPlanChildren_mjo__c tmpGoalJoin = new ProgressNote_ActionPlanChildren_mjo__c();
                    tmpGoalJoin.Progress_Note__c = note.id;
                    tmpGoalJoin.Goal__c = clsG.theGoal.id;
                    insertJO.add(tmpGoalJoin);
                }
                // if it has been inserted and then wasa unchecked in this seeson we must delete that jo record
                if(childrenScope.containskey(clsG.theGoal.id) && !clsG.inNote ){
                    deleteJO.add(childrenScope.get(clsG.theGoal.id)); 
                }
                
                    for(clsPlan_Obj clsO : clsG.objs.values()){
                        if(clsO.inNote && !childrenScope.containskey(clsO.theObj.id)){
                            ProgressNote_ActionPlanChildren_mjo__c tmpObjJoin = new ProgressNote_ActionPlanChildren_mjo__c();
                            tmpObjJoin.Progress_Note__c = note.id;
                            tmpObjJoin.Objective__c = clsO.theObj.id;
                            insertJO.add(tmpObjJoin);                        
                        } 
                        if(childrenScope.containskey(clsO.theObj.id) && !clsO.inNote ){
                            deleteJO.add(childrenScope.get(clsO.theObj.id)); 
                        }
                        
                        if(!clsG.inNote && childrenScope.containskey(clsO.theObj.id)) {
                            deleteJO.add(childrenScope.get(clsO.theObj.id));
                        }                          
                    
                    }
            
            }
            
            delete deleteJo;
            insert insertJo;
            
        
        }
        catch(DMLException e){
        /*
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                note.adderror(e);
                System.debug(e.getDmlMessage(i)); new ApexPages.Message(ApexPages.Severity.ERROR, 
            }
            */
            ApexPages.addMessages(e);
            return null;
        }
                
            PageReference ref =  new ApexPages.StandardController(note).view();
            return ref;      
       // return null;
    
    }
    
    public pagereference myEdit(){
        editMode = true;
        return null;
    }
    public PageReference myFinal(){
        PageReference pageRef = new PageReference('/apex/Notes_ProgressNote_Create_Flavor_PDF');
        PageReference pageRefFlavor = ApexPages.currentPage();
        pageRef .getParameters().put('id', note.id);
        if(note.Number_of_Required_Signatures__c == 0 && note.RecordType.Name == 'FL-FSS Progress Note' ){
            PageRefFlavor = new PageReference('/apex/Notes_ProgressNote_FL_FFS');
            pageRefFlavor .getParameters().put('id', note.id);
        }
        
        try{

            if(note.Number_of_Required_Signatures__c <1){
                note.no_approval_needed__c = false;
                note.addError('Number of Required Signatures must be at least one before you can Finalize this note');
               return null;
            
            }
            string tmpstr =[select Signature_on_File__c from progress_Note__c where id =:note.id].Signature_on_File__c;
            if(tmpstr !='Y'){
                note.no_approval_needed__c = false;
                note.addError('E-Signature is required before you can Finalize this note');
               return null;
            
            }
            
            PageReference Note_Pdf_ref = new PageReference('/');
            Note_Pdf_ref = new PageReference('/apex/Notes_ShiftNote_Pdf');
            Note_Pdf_ref.getParameters().put('id', note.id);
            Attachment attachmentPDF = new Attachment();
            attachmentPDF.parentId = note.id;
            attachmentPDF.Name = note.Person_Being_Served__r.Name + ' - ' + note.RecordType.Name +' - (' + date.today().month() + '-' + date.today().day() + '-' + date.today().year() + ').pdf';
            attachmentPDF.body = Note_Pdf_ref.getContent();
            insert attachmentPDF;
            /**/
            if(!note.No_approval_Needed__c){
                return new PageReference('/p/process/Submit?retURL=%2F'+note.id+'&id='+note.id);
            }
            update note;
            return new PageReference('/'+note.id);
            
        }
            catch(DMLException e){
                note.addError(e.getMessage());
                note.no_approval_needed__c = false;
            }      
        
        return null;
    }
}