/*
        10/11/2012 Maros Sitko udates on confirm external button
*/
public with sharing class V2SA_ConstructSTG {

            
        public Plan__c plan {get; set;}
        public list<InnerObjective> lstInnObjective {get; set;}
        
        public Boolean ObjectiveAdd {get; set;}
        public InnerObjective newObjective {get; set;}
        
        public list<SelectOption> lstOptServiceAssignments {get; set;}
        
        public Boolean readOnly {get; set;}
        
        /* values for page V2SA_ExternalPlaneCheck */
        public String errorMessage {get; set;}
        public Boolean error {get; set;}
        public Boolean ExternalPlanDone {get; set;}
        
        /*
        INNER CLASSES
        */
        
        // ============= Short Term Goals (API Name: Objective) ==============
        
        public class InnerObjective {
            public V2SA_ConstructSTG OuterCls;
            public Short_Term_Goal__c Objective {get; set;}
            public Objective__c newPlanObjective {get; set;}
            public list<InnerPlanObjective> lstInnPlanObjective {get; set;} 
            public Plan_ServiceAssignment_MJO__c newSARJO {get; set;} 
            public list<InnerSARJO> lstInnSARJO {get; set;} 
            
            public String newServiceAssignment {get; set;} //choosen SA from select option
            
            public list<SelectOption> MyLstOptServiceAssignments {get; set;}
            public list<SelectOption> MySelectedLstOptServiceAssignments {get; set;}
            
            public boolean ObjectiveEdit {get; set;}
            public boolean SARJOAdd {get; set;}
            public boolean PlanObjectiveAdd {get; set;}
            
            public InnerObjective(Short_Term_Goal__c thisObjective, V2SA_ConstructSTG OuterCls) {
                    this.OuterCls = OuterCls;
                Objective = thisObjective;
                
                newPlanObjective = new Objective__c();
                lstInnPlanObjective = new list<InnerPlanObjective>();
                
                this.MyLstOptServiceAssignments = OuterCls.lstOptServiceAssignments.clone();
                this.MySelectedLstOptServiceAssignments = new list<SelectOption>();
                
                newServiceAssignment = null;
                newSARJO = new Plan_ServiceAssignment_MJO__c();
                lstInnSARJO = new list<InnerSARJO>();
                
                ObjectiveEdit = false;
                PlanObjectiveAdd = false;
                SARJOAdd = false;
            } 
            
            public void EndEditObjective(){
                    update Objective;
                    ObjectiveEdit = false;
            }
            
            public void DeleteObjective(){
                    /*list<Intervention__c> lstInterventionToDelete = new list<Intervention__c>();
                    for(InnerIntervention objInnIntervention: lstInnIntervention){
                            lstInterventionToDelete.add(objInnIntervention.Intervention);
                    }
                    list<Objective_Service_Agreement__c> lstOSAToDelete = new list<Objective_Service_Agreement__c>();
                for(InnerOSA objInnOSA: lstInnOSA){
                    lstOSAToDelete.add(objInnOSA.OSA);
                }
                delete lstInterventionToDelete;
                delete lstOSAToDelete;
                */
                    delete objective; // All child data are deleted by cascade
                    
                for(integer i = 0; i<OuterCls.lstInnObjective.size(); i++){
                        if(OuterCls.lstInnObjective[i] == this){
                            OuterCls.lstInnObjective.remove(i);
                            //this = null;
                            break;
                        } 
                }
            }
            
            public void AddNewPlanObjective() {
                newPlanObjective.Short_Term_Goal__c = this.Objective.Id;
                    insert newPlanObjective;
                    
                    InnerPlanObjective newInnPlanObj = new InnerPlanObjective(newPlanObjective, this);
                    newInnPlanObj.cloneServiceAssigmentsOpptions();
                    if(lstInnPlanObjective.isEmpty()) { // if list is empty, we do not have index, so we simply add item, else we add item at the beginning
                            lstInnPlanObjective.add(newInnPlanObj);
                    } else {
                            lstInnPlanObjective.add(0, newInnPlanObj);
                    }
                    
                    PlanObjectiveAdd = false;
                    newPlanObjective = new Objective__c(); //clear form
                }
                
                public void AddNewPlanObjectiveCancel() {
                    PlanObjectiveAdd = false;
                    newPlanObjective = new Objective__c(); // clear form
                }
                
                /*
                not used, admission will be required so we do not need refresh select options for service assigment. if this 
                function will be needed, it need more testing, because in some cases it is no work correct
               public void RefreshAllServiceAssignments(){
                    OuterCls.plan = OuterCls.createPlan(OuterCls.plan.Id);
                    OuterCls.lstOptServiceAssignments = OuterCls.getAllServiceAssignments();
                    this.MyLstOptServiceAssignments = OuterCls.lstOptServiceAssignments.clone();
                    
                    this.MySelectedLstOptServiceAssignments.clear();
                    
                    list< Plan_ServiceAssignment_MJO__c> mapServiceAgreements = new list<Plan_ServiceAssignment_MJO__c>([SELECT Short_Term_Goal__c, Objective__c, Intervention__c, RecordType.Name, Service_Assignment__c, Service_Assignment__r.Name, Service_Assignment__r.Location_Region__c, Service_Assignment__r.Start_Date__c, Service_Assignment__r.Service_Line__c, Service_Assignment__r.Status__c FROM Plan_ServiceAssignment_MJO__c WHERE Short_Term_Goal__c = :this.Objective.Id]);
                    for(Plan_ServiceAssignment_MJO__c SARJO : mapServiceAgreements) {
                            this.MySelectedLstOptServiceAssignments.add(new SelectOption(SARJO.Service_Assignment__c, SARJO.Service_Assignment__r.Name));
                    }
                    
                    system.debug(this.MySelectedLstOptServiceAssignments);
                    system.debug(this.MyLstOptServiceAssignments);
                    for(Integer i = 0; i < this.MySelectedLstOptServiceAssignments.size(); i++) {
                            for(Integer j = 0; j < this.MyLstOptServiceAssignments.size(); j++) {
                                    if(this.MySelectedLstOptServiceAssignments[i].getValue() != null && this.MySelectedLstOptServiceAssignments[i].getValue() == this.MyLstOptServiceAssignments[j].getValue()) {
                                            this.MyLstOptServiceAssignments.remove(j);
                                break;
                                    }
                            }
                    }
                }
                
                */
                public void AddNewServiceAssignment(){
                    if(this.newServiceAssignment != null){
                    SARJOAdd = false;
                }
                    this.AddNewServiceAssignmentNext();
                }
                
                public void AddNewServiceAssignmentNext(){
                    //Handle Service Assignment hasn't been chosen
                if(this.newServiceAssignment == null){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Choose Service Assignment, please.'));
                    SARJOAdd = true;
                    return;
                }
                Plan__c tempPlan = OuterCls.createPlan(OuterCls.plan.Id);
                if(tempPlan.Admission__c == null){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Select Admission first, please.'));
                    SARJOAdd = false;
                    return;
                }
                
                this.newSARJO.Short_Term_Goal__c = this.objective.Id;
                RecordType RTSTG = [SELECT Id, Name FROM RecordType WHERE Name='SA-Short-term Goal JO' AND SobjectType = 'Plan_ServiceAssignment_MJO__c'][0];
                this.newSARJO.RecordTypeId = RTSTG.Id;
                this.newSARJO.Service_Assignment__c = this.newServiceAssignment;
                
                // now we need to show user information about servis Assignments, so we load this information form Database 
                // and add to list of new Assignments
                system.debug(this.newServiceAssignment);
                Service_Assignment__c Assignment = [SELECT Name, Location_Region__c, Start_Date__c, Service_Line__c, Status__c FROM Service_Assignment__c WHERE id = :this.newServiceAssignment][0];
                //this.mapServiceAssignmentNameByOSAHelperID.put(helperId, Assignment.Name); //Kajo 2012-09-13 Add new Service Assignment's Name to helper map  //
                //remove selected Service Assignment from picklict - Kajo 2012-09-12
                for(integer i = 0; i < this.MyLstOptServiceAssignments.size(); i++){
                    if (this.MyLstOptServiceAssignments[i].getValue() == this.newServiceAssignment)
                    {
                            this.MySelectedLstOptServiceAssignments.add(this.MyLstOptServiceAssignments[i]);
                        this.MyLstOptServiceAssignments.remove(i);
                        break;
                    }
                }
                
                insert newSARJO;
                lstInnSARJO.add(new InnerSARJO(newSARJO, Assignment.Name, this, RTSTG));
                
                newSARJO = new Plan_ServiceAssignment_MJO__c(); // clear form
                this.newServiceAssignment = null;
                
                // update children option lists of service assigments
                for(InnerPlanObjective innPlanObj : lstInnPlanObjective) {
                            innPlanObj.cloneServiceAssigmentsOpptions();
                            for(InnerIntervention innInter: innPlanObj.lstInnIntervention) {
                                    innInter.cloneServiceAssigmentsOpptions();
                            }
                    }
                }
                
                public void AddNewServiceAssignmentCancel() {
                    SARJOAdd = false;
                }
        }
        
        // ============= Objectives (API Name: PlanObjective) ==============
        
        public class InnerPlanObjective {
            public InnerObjective OuterCls;
            public Objective__c PlanObjective {get; set;}
            public Intervention__c newIntervention {get; set;}
            public list<InnerIntervention> lstInnIntervention {get; set;} 
            public Plan_ServiceAssignment_MJO__c newSARJO {get; set;} 
            public list<InnerSARJO> lstInnSARJO {get; set;} 
            
            public String newServiceAssignment {get; set;} //choosen SA from select option
            
            public list<SelectOption> MyLstOptServiceAssignments {get; set;}
            public list<SelectOption> MySelectedLstOptServiceAssignments {get; set;}
            
            public boolean PlanObjectiveEdit {get; set;}
            public boolean SARJOAdd {get; set;}
            public boolean InterventionAdd {get; set;}
            
            public InnerPlanObjective(Objective__c thisPlanObjective, InnerObjective OuterCls) {
                    this.OuterCls = OuterCls;
                PlanObjective = thisPlanObjective;
                
                newIntervention = new Intervention__c();
                lstInnIntervention = new list<InnerIntervention>();
                
                this.MyLstOptServiceAssignments = new list<SelectOption>();
                this.MySelectedLstOptServiceAssignments = new list<SelectOption>();
                
                newServiceAssignment = null;
                newSARJO = new Plan_ServiceAssignment_MJO__c();
                lstInnSARJO = new list<InnerSARJO>();
                
                PlanObjectiveEdit = false;
                InterventionAdd = false;
                SARJOAdd = false;
            } 
            
            public void EndEditPlanObjective(){
                    update PlanObjective;
                    PlanObjectiveEdit = false;
            }
            
            public void DeletePlanObjective(){
                    /*list<Intervention__c> lstInterventionToDelete = new list<Intervention__c>();
                    for(InnerIntervention objInnIntervention: lstInnIntervention){
                            lstInterventionToDelete.add(objInnIntervention.Intervention);
                    }
                    list<Objective_Service_Agreement__c> lstOSAToDelete = new list<Objective_Service_Agreement__c>();
                for(InnerOSA objInnOSA: lstInnOSA){
                    lstOSAToDelete.add(objInnOSA.OSA);
                }
                delete lstInterventionToDelete;
                delete lstOSAToDelete;
                */
                    delete PlanObjective; // All child data are deleted by cascade
                    
                for(integer i = 0; i<OuterCls.lstInnPlanObjective.size(); i++){
                        if(OuterCls.lstInnPlanObjective[i] == this){
                            OuterCls.lstInnPlanObjective.remove(i);
                            //this = null;
                            break;
                        } 
                }
            }
            
            public void AddNewIntervention() {
                newIntervention.Objective__c = this.PlanObjective.Id;
                    insert newIntervention;
                    
                    InnerIntervention newInter = new InnerIntervention(newIntervention, this);
                    newInter.cloneServiceAssigmentsOpptions();
                    if(lstInnIntervention.isEmpty()) { // if list is empty, we do not have index, so we simply add item, else we add item at the beginning
                            lstInnIntervention.add(newInter);
                    } else {
                            lstInnIntervention.add(0, newInter);
                    }
                    
                    InterventionAdd = false;
                    newIntervention = new Intervention__c(); //clear form
                }
                
                public void AddNewInterventionCancel() {
                    InterventionAdd = false;
                    newIntervention = new Intervention__c(); // clear form
                }
                
                public void AddNewServiceAssignment(){
                    if(this.newServiceAssignment != null){
                    SARJOAdd = false;
                }
                    this.AddNewServiceAssignmentNext();
                }
                
                public void AddNewServiceAssignmentNext(){
                    //Handle Service Assignment hasn't been chosen
                if(this.newServiceAssignment == null){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Choose Service Assignment, please.'));
                    SARJOAdd = true;
                    return;
                }
                this.newSARJO.Short_Term_Goal__c = this.OuterCls.Objective.Id;
                this.newSARJO.Objective__c = this.PlanObjective.Id;
                RecordType RTPlan = [SELECT Id, Name FROM RecordType WHERE Name='SA-Objective JO' AND SobjectType = 'Plan_ServiceAssignment_MJO__c'][0];
                this.newSARJO.RecordTypeId = RTPlan.Id;
                this.newSARJO.Service_Assignment__c = this.newServiceAssignment;
                
                // now we need to show user information about servis Assignments, so we load this information form Database 
                // and add to list of new Assignments
                system.debug(this.newServiceAssignment);
                Service_Assignment__c Assignment = [SELECT Name, Location_Region__c, Start_Date__c, Service_Line__c, Status__c FROM Service_Assignment__c WHERE id = :this.newServiceAssignment][0];
                //this.mapServiceAssignmentNameByOSAHelperID.put(helperId, Assignment.Name); //Kajo 2012-09-13 Add new Service Assignment's Name to helper map
                //remove selected Service Assignment from picklict - Kajo 2012-09-12
                for(integer i = 0; i < this.MyLstOptServiceAssignments.size(); i++){
                    if (this.MyLstOptServiceAssignments[i].getValue() == this.newServiceAssignment)
                    {
                            this.MySelectedLstOptServiceAssignments.add(this.MyLstOptServiceAssignments[i]);
                        this.MyLstOptServiceAssignments.remove(i);
                        break;
                    }
                }
                
                insert newSARJO;
                lstInnSARJO.add(new InnerSARJO(newSARJO, Assignment.Name, this, RTPlan));
                system.debug(lstInnSARJO);
                newSARJO = new Plan_ServiceAssignment_MJO__c(); // clear form
                this.newServiceAssignment = null;
                
                // update children option lists of service assigments
                    for(InnerIntervention innInter: lstInnIntervention) {
                            innInter.cloneServiceAssigmentsOpptions();
                    }
                }
                
                public void AddNewServiceAssignmentCancel() {
                    SARJOAdd = false;
                }
                
                public void cloneServiceAssigmentsOpptions() {
                    Boolean add;
                    this.MyLstOptServiceAssignments.clear();
                    this.MySelectedLstOptServiceAssignments.clear();
                    this.MyLstOptServiceAssignments.add(new SelectOption('',''));
                    if(this.OuterCls != null) {
                            //this.MyLstOptServiceAssignments.addAll(OuterCls.MySelectedLstOptServiceAssignments);
                            for(integer i = 0; i < OuterCls.MySelectedLstOptServiceAssignments.size(); i++ ){
                                    add = true;
                                    for(InnerSARJO thisSARJO : lstInnSARJO){
                                            system.debug(OuterCls.MySelectedLstOptServiceAssignments[i].getValue());
                                            system.debug(thisSARJO.SARJO.Service_Assignment__c);
                                            if(OuterCls.MySelectedLstOptServiceAssignments[i].getValue() == thisSARJO.SARJO.Service_Assignment__c){
                                                    add = false;
                                                    break;
                                            }
                                    }
                                    if(add){
                                            this.MyLstOptServiceAssignments.add(OuterCls.MySelectedLstOptServiceAssignments[i]);
                                    } else {
                                            this.MySelectedLstOptServiceAssignments.add(OuterCls.MySelectedLstOptServiceAssignments[i]);
                                    }
                            }
                    }
            }
                
        }
        
        // ============= Interventions =================
        
        public class InnerIntervention{
            InnerPlanObjective OuterCls;
            public Intervention__c Intervention {get; set;}
            public boolean Edit {get; set;}
            
            public list<InnerSARJO> lstInnSARJO {get; set;} 
            public boolean SARJOAdd {get; set;}
            public list<SelectOption> MyLstOptServiceAssignments {get; set;}
            public list<SelectOption> MySelectedLstOptServiceAssignments {get; set;}
            public Plan_ServiceAssignment_MJO__c newSARJO {get; set;} 
            public String newServiceAssignment {get; set;} //choosen SA from select option
            
            public InnerIntervention(Intervention__c thisIntervention, InnerPlanObjective OuterCls) {
                    this.OuterCls = OuterCls;
                    this.Intervention = thisIntervention;
                    Edit = false;
                    SARJOAdd = false;
                    
                    this.MyLstOptServiceAssignments = new list<SelectOption>();
                this.MySelectedLstOptServiceAssignments = new list<SelectOption>();
                
                newServiceAssignment = null;
                newSARJO = new Plan_ServiceAssignment_MJO__c();
                lstInnSARJO = new list<InnerSARJO>();
            }
            
            public void EndEditIntervention(){
                update Intervention;
                Edit = false;
            }
            
            public void deleteIntervention(){
                    delete Intervention;
                    for(integer i = 0; i<OuterCls.lstInnIntervention.size(); i++){
                    if(OuterCls.lstInnIntervention[i] == this){
                        OuterCls.lstInnIntervention.remove(i);
                        //this = null;
                        break;
                    } 
                }
            }
            
            public void AddNewServiceAssignment(){
                    if(this.newServiceAssignment != null){
                    SARJOAdd = false;
                }
                    this.AddNewServiceAssignmentNext();
                }
                
                public void AddNewServiceAssignmentNext(){
                    //Handle Service Assignment hasn't been chosen
                if(this.newServiceAssignment == null){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Choose Service Assignment, please.'));
                    SARJOAdd = true;
                    return;
                }
                this.newSARJO.Short_Term_Goal__c = this.OuterCls.OuterCls.Objective.Id;
                this.newSARJO.Objective__c = this.OuterCls.PlanObjective.Id;
                this.newSARJO.Intervention__c = this.Intervention.Id;
                RecordType RTInter = [SELECT Id, Name FROM RecordType WHERE Name='SA Intervention JO' AND SobjectType = 'Plan_ServiceAssignment_MJO__c'][0];
                this.newSARJO.RecordTypeId = RTInter.Id;
                this.newSARJO.Service_Assignment__c = this.newServiceAssignment;
                
                // now we need to show user information about servis Assignments, so we load this information form Database 
                // and add to list of new Assignments
                system.debug(this.newServiceAssignment);
                Service_Assignment__c Assignment = [SELECT Name, Location_Region__c, Start_Date__c, Service_Line__c, Status__c FROM Service_Assignment__c WHERE id = :this.newServiceAssignment][0];
                //this.mapServiceAssignmentNameByOSAHelperID.put(helperId, Assignment.Name); //Kajo 2012-09-13 Add new Service Assignment's Name to helper map
                //remove selected Service Assignment from picklict - Kajo 2012-09-12
                for(integer i = 0; i < this.MyLstOptServiceAssignments.size(); i++){
                    if (this.MyLstOptServiceAssignments[i].getValue() == this.newServiceAssignment)
                    {
                            this.MySelectedLstOptServiceAssignments.add(this.MyLstOptServiceAssignments[i]);
                        this.MyLstOptServiceAssignments.remove(i);
                        break;
                    }
                }
                
                insert newSARJO;
                
                lstInnSARJO.add(new InnerSARJO(newSARJO, Assignment.Name, this, RTInter));
                
                newSARJO = new Plan_ServiceAssignment_MJO__c(); // clear form
                this.newServiceAssignment = null;
                }
                
                public void AddNewServiceAssignmentCancel() {
                    SARJOAdd = false;
                }
                
                public void cloneServiceAssigmentsOpptions() {
                    Boolean add;
                    this.MyLstOptServiceAssignments.clear();
                    this.MySelectedLstOptServiceAssignments.clear();
                    this.MyLstOptServiceAssignments.add(new SelectOption('',''));
                    if(this.OuterCls != null) {
                            //this.MyLstOptServiceAssignments.addAll(OuterCls.MySelectedLstOptServiceAssignments);
                            for(integer i = 0; i < OuterCls.MySelectedLstOptServiceAssignments.size(); i++ ){
                                    add = true;
                                    for(InnerSARJO thisSARJO : lstInnSARJO){
                                            system.debug(OuterCls.MySelectedLstOptServiceAssignments[i].getValue());
                                            system.debug(thisSARJO.SARJO.Service_Assignment__c);
                                            if(OuterCls.MySelectedLstOptServiceAssignments[i].getValue() == thisSARJO.SARJO.Service_Assignment__c){
                                                    add = false;
                                                    break;
                                            }
                                    }
                                    if(add){
                                            this.MyLstOptServiceAssignments.add(OuterCls.MySelectedLstOptServiceAssignments[i]);
                                    } else {
                                            this.MySelectedLstOptServiceAssignments.add(OuterCls.MySelectedLstOptServiceAssignments[i]);
                                    }
                            }
                    }
            }
        }
        
        public class InnerSARJO{
            InnerObjective OuterObjective;
            InnerPlanObjective OuterPlanObjective;
            InnerIntervention OuterIntervention;
            RecordType RecordType;
            public Plan_ServiceAssignment_MJO__c SARJO {get; set;}
            public String SARJOName {get; set;}
            
            public InnerSARJO(Plan_ServiceAssignment_MJO__c thisSARJO, string thisName, InnerObjective OuterObjective, RecordType thisRecordType) {
                    this.OuterObjective = OuterObjective;
                this.SARJO = thisSARJO;
                this.SARJOName = thisName;
                this.RecordType = thisRecordType;
            }
            
            public InnerSARJO(Plan_ServiceAssignment_MJO__c thisSARJO, string thisName, InnerPlanObjective OuterPlanObjective, RecordType thisRecordType) {
                    this.OuterPlanObjective = OuterPlanObjective;
                this.SARJO = thisSARJO;
                this.SARJOName = thisName;
                this.RecordType = thisRecordType;
            }
            
            public InnerSARJO(Plan_ServiceAssignment_MJO__c thisSARJO, string thisName, InnerIntervention OuterIntervention, RecordType thisRecordType) {
                    this.OuterIntervention = OuterIntervention;
                this.SARJO = thisSARJO;
                this.SARJOName = thisName;
                this.RecordType = thisRecordType;
            }
            
            public InnerSARJO(Plan_ServiceAssignment_MJO__c thisSARJO, string thisName, RecordType thisRecordType) {
                this.SARJO = thisSARJO;
                this.SARJOName = thisName;
                this.RecordType = thisRecordType;
            }
            
            public void deleteSARJO(){
                    list<SelectOption> lstOptServiceAssignments = new list<SelectOption>();
                    list<InnerSARJO> lstThisInnerSARJO = new list<InnerSARJO>();
                    if(RecordType.Name == 'SA-Short-term Goal JO') {
                            lstOptServiceAssignments = OuterObjective.OuterCls.lstOptServiceAssignments;
                            lstThisInnerSARJO = OuterObjective.lstInnSARJO;
                    } else if(RecordType.Name == 'SA-Objective JO') {
                            lstOptServiceAssignments = OuterPlanObjective.MySelectedLstOptServiceAssignments;
                            lstThisInnerSARJO = OuterPlanObjective.lstInnSARJO;
                    } else if(RecordType.Name == 'SA Intervention JO') {
                            lstOptServiceAssignments = OuterIntervention.MySelectedLstOptServiceAssignments;
                            lstThisInnerSARJO = OuterIntervention.lstInnSARJO;
                    }
    
                    for(integer i = 0; i < lstOptServiceAssignments.size(); i++){
                        if(lstOptServiceAssignments[i].getValue() == string.valueof(SARJO.Service_Assignment__c)) {
                            if(RecordType.Name == 'SA-Short-term Goal JO') {
                                    OuterObjective.MyLstOptServiceAssignments.add(OuterObjective.OuterCls.lstOptServiceAssignments[i]);
                            } else if(RecordType.Name == 'SA-Objective JO') {
                                    OuterPlanObjective.MyLstOptServiceAssignments.add(lstOptServiceAssignments[i]);
                            } else if(RecordType.Name == 'SA Intervention JO') {
                                    OuterIntervention.MyLstOptServiceAssignments.add(lstOptServiceAssignments[i]);
                            }
                            break;
                        }
                    }
                    
                            if(RecordType.Name == 'SA-Short-term Goal JO') {
                            if(SARJO.Short_Term_Goal__c != null) {
                                    delete [SELECT id FROM Plan_ServiceAssignment_MJO__c WHERE Short_Term_Goal__c = :SARJO.Short_Term_Goal__c AND Service_Assignment__c = :SARJO.Service_Assignment__c];
                            } else {
                                    delete SARJO;
                            }/*
                            for(InnerPlanObjective innPlanObj : OuterObjective.lstInnPlanObjective) {
                                    innPlanObj.cloneServiceAssigmentsOpptions();
                                    for(InnerIntervention innInter: innPlanObj.lstInnIntervention) {
                                            innInter.cloneServiceAssigmentsOpptions();
                                    }
                            }*/
                            OuterObjective.OuterCls.createLstInnObjective();
                    } else if(RecordType.Name == 'SA-Objective JO') {
                            if(SARJO.Objective__c != null) {
                                    delete [SELECT id FROM Plan_ServiceAssignment_MJO__c WHERE Objective__c = :SARJO.Objective__c AND Service_Assignment__c = :SARJO.Service_Assignment__c];
                            } else {
                                    delete SARJO;
                            }
                            /*
                            for(InnerIntervention innInter: OuterPlanObjective.lstInnIntervention) {
                                    innInter.cloneServiceAssigmentsOpptions();
                            }*/
                            OuterPlanObjective.OuterCls.OuterCls.createLstInnObjective();
                    } else {
                            delete SARJO;   
                            }
                            for(integer i = 0; i < lstThisInnerSARJO.size(); i++){
                    if(lstThisInnerSARJO[i] == this){
                        lstThisInnerSARJO.remove(i);
                        //this = null;
                        break;
                    } 
                }
            }
        }
        /*
        public class InnerOSA{
            InnerObjective OuterCls;
            public Objective_Service_Agreement__c OSA {get; set;}
            public String OSAName {get; set;}
            
            public InnerOSA(Objective_Service_Agreement__c thisOSA, string thisName, InnerObjective OuterCls) {
                    this.OuterCls = OuterCls;
                this.OSA = thisOSA;
                this.OSAName = thisName;
            }
            
            public InnerOSA(Objective_Service_Agreement__c thisOSA, string thisName, InnerPlanObjective OuterCls) {
                    //this.OuterCls = OuterCls;
                this.OSA = thisOSA;
                this.OSAName = thisName;
            }
            
            public void deleteOSA(){
                    for(integer i = 0; i < OuterCls.OuterCls.lstOptServiceAssignments.size(); i++){
                        if(OuterCls.OuterCls.lstOptServiceAssignments[i].getValue() == string.valueof(OSA.Service_Agreement__c))
                        {
                            OuterCls.MyLstOptServiceAssignments.add(OuterCls.OuterCls.lstOptServiceAssignments[i]);
                            break;
                        }
                    }
            
                delete OSA;
                for(integer i = 0; i<OuterCls.lstInnOSA.size(); i++){
                    if(OuterCls.lstInnOSA[i] == this){
                        OuterCls.lstInnOSA.remove(i);
                        //this = null;
                        break;
                    } 
                }
            }
        }
        */
        
        /*
        CONSTRUCTORS
        */
        //when calling controller from class V2SA_PlanPDFGenerator not from Visualforce page        
        public V2SA_ConstructSTG(String inputPlanId) {
            String planId = inputPlanId;
            if(planId == null || planId == '') { return; }
            init(planId);
        }
        //when calling controller from Visualforce page     
        public V2SA_ConstructSTG() {
            String planId = ApexPages.currentPage().getParameters().get('id');
            if(planId == null || planId == '') { return; }
            init(planId);
        }
        
        public void init(string planId){
            plan = createPlan(planId);
            if(plan == null) { return; }
            readOnly = false;
            if(plan.Read_Only__c != null){
                    readOnly = plan.Read_Only__c;
            }
            // if is read only check if user is system admin and allow edit
            if(readOnly){
                    Id profileIid = userinfo.getProfileId(); system.debug(profileIid);
                    list<Profile> lstProfile = new list<Profile>([select Name from Profile where id = :profileIid]);
                    if(lstProfile.size() == 1 && lstProfile[0].Name == 'System Administrator'){
                            readOnly = false;
                    }
            }
            ObjectiveAdd = false;
            lstOptServiceAssignments = getAllServiceAssignments();
            createLstInnObjective();
            newObjective = new InnerObjective(new Short_Term_Goal__c(), this);
            
            error = false;
            ExternalPlanDone = false;
            if(plan.External_Plan__c == false && plan.Read_Only__c == false){
                    errorMessage = 'You must select the External Checkbox before Confirming External Plan. Please return and make necessary changes if required.';
                    error = true;
            }
        }
        
        private Plan__c createPlan(id planId) {
            list<Plan__c> lstPlan = [SELECT Name, Admission__c, Anticipated_Transition_Date__c, Date_Service_Started__c,  Individual_Name__c, Medications__c, 
                                            Plan_Description__c, Read_Only__c, External_Plan__c, Plan_Name__c,  Progress_Since_Last_Plan__c,  Status__c, Effective_Date__c FROM Plan__c WHERE id=:planId];
            if(lstPlan.size() == 0){
                return null;
            }
            
            Plan__c plan = lstPlan[0];
            return plan;
        }
        
        public void createLstInnObjective() {
            map<Id, Short_Term_Goal__c> mapObjectives = new map<Id,Short_Term_Goal__c>([SELECT Name, Plan__c, Start_Date__c, End_Date__c, Status__c,
                                                                                    Individual_Name__c, Short_Term_Goal_Description__c, Plan_Name__c,
                                                                                    Frequency_and_Duration__c, LastModifiedDate, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedById, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, CreatedById FROM Short_Term_Goal__c WHERE Plan__c =: plan.Id]);
            map<Id, Objective__c> mapPlanObjectives = new map<Id,Objective__c>([SELECT Name, Objective_Description__c, Objective_Name__c, Short_Term_Goal__c, Status__c, Frequency_and_Duration__c, Start_Date__c, End_Date__c, LastModifiedDate, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedById, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, CreatedById FROM Objective__c WHERE Short_Term_Goal__c IN :mapObjectives.keySet()]);                                                                        
            map<Id, Intervention__c> mapInterventions = new map<Id,Intervention__c>([SELECT Name, Intervention_Name__c, Intervention_Description__c, Objective__c,  LastModifiedDate, LastModifiedBy.FirstName, LastModifiedBy.LastName, LastModifiedById, CreatedDate, CreatedBy.FirstName, CreatedBy.LastName, CreatedById FROM Intervention__c WHERE Objective__c IN :mapPlanObjectives.keySet()]);
            map<Id, Plan_ServiceAssignment_MJO__c> mapServiceAgreements = new map<Id,Plan_ServiceAssignment_MJO__c>([SELECT Short_Term_Goal__c, Objective__c, Intervention__c, RecordType.Name, Service_Assignment__c, Service_Assignment__r.Name,  Service_Assignment__r.Location_Region__c, Service_Assignment__r.Start_Date__c, Service_Assignment__r.Service_Line__c, Service_Assignment__r.Status__c FROM Plan_ServiceAssignment_MJO__c WHERE Short_Term_Goal__c IN :mapObjectives.keySet()]);
            map<Id, Plan_ServiceAssignment_MJO__c> mapServiceAgreementsPlan = new map<Id,Plan_ServiceAssignment_MJO__c>([SELECT Short_Term_Goal__c, Objective__c, Intervention__c, RecordType.Name, Service_Assignment__c, Service_Assignment__r.Name,  Service_Assignment__r.Location_Region__c, Service_Assignment__r.Start_Date__c, Service_Assignment__r.Service_Line__c, Service_Assignment__r.Status__c FROM Plan_ServiceAssignment_MJO__c WHERE Objective__c IN :mapPlanObjectives.keySet()]);
            
            map<Id, list<InnerSARJO>> mapListInnerSARJOPlan = new map<Id, list<InnerSARJO>>();
            list<InnerSARJO> thisListInnerSARJO;
            for(Plan_ServiceAssignment_MJO__c SARJO : mapServiceAgreementsPlan.values()){
                    if(SARJO.RecordType.Name == 'SA-Objective JO'){
                            thisListInnerSARJO = mapListInnerSARJOPlan.get(SARJO.Objective__c);
                            if(thisListInnerSARJO == null){
                                    thisListInnerSARJO = new list<InnerSARJO>();
                                    mapListInnerSARJOPlan.put(SARJO.Objective__c, thisListInnerSARJO);
                                    thisListInnerSARJO = mapListInnerSARJOPlan.get(SARJO.Objective__c);
                            }
                            thisListInnerSARJO.add(new InnerSARJO(SARJO, SARJO.Service_Assignment__r.Name, SARJO.RecordType));
                    }
            }
            
            
            map<Id, Plan_ServiceAssignment_MJO__c> mapServiceAgreementsInter = new map<Id,Plan_ServiceAssignment_MJO__c>([SELECT Short_Term_Goal__c, Objective__c, Intervention__c, RecordType.Name, Service_Assignment__c, Service_Assignment__r.Name,  Service_Assignment__r.Location_Region__c, Service_Assignment__r.Start_Date__c, Service_Assignment__r.Service_Line__c, Service_Assignment__r.Status__c FROM Plan_ServiceAssignment_MJO__c WHERE Intervention__c IN :mapInterventions.keySet()]);
            
            map<Id, list<InnerSARJO>> mapListInnerSARJOInter = new map<Id, list<InnerSARJO>>();
            thisListInnerSARJO = null;
            for(Plan_ServiceAssignment_MJO__c SARJO : mapServiceAgreementsInter.values()){
                    if(SARJO.RecordType.Name == 'SA Intervention JO'){
                            thisListInnerSARJO = mapListInnerSARJOInter.get(SARJO.Intervention__c);
                            if(thisListInnerSARJO == null){
                                    thisListInnerSARJO = new list<InnerSARJO>();
                                    mapListInnerSARJOInter.put(SARJO.Intervention__c, thisListInnerSARJO);
                                    thisListInnerSARJO = mapListInnerSARJOInter.get(SARJO.Intervention__c);
                            }
                            thisListInnerSARJO.add(new InnerSARJO(SARJO, SARJO.Service_Assignment__r.Name, SARJO.RecordType));
                    }
            }
            
            
            map<string, InnerObjective> mapInnerObjectives = new map<string, InnerObjective>();
            map<string, InnerPlanObjective> mapInnerPlanObjectives = new map<string, InnerPlanObjective>();
            
            
            Objective__c thisPlanObjective = null;
            // add all objectives to map
            for(Objective__c PlanObjective : mapPlanObjectives.values()){
                mapInnerPlanObjectives.put(string.valueOf(PlanObjective.Id), new InnerPlanObjective(PlanObjective, null));        
            }
            system.debug(mapListInnerSARJOInter);
            // add all interventions to map of plan objectives
            InnerPlanObjective thisInnerPlanObjective = null;
            InnerIntervention thisInnerIntervention = null;
            for(Intervention__c intervention : mapInterventions.values()){
                    thisInnerPlanObjective = mapInnerPlanObjectives.get(intervention.Objective__c); 
                if(thisInnerPlanObjective != null) {
                    thisInnerIntervention = new InnerIntervention(intervention, thisInnerPlanObjective);
                    system.debug(intervention.Id);
                    thisListInnerSARJO = mapListInnerSARJOInter.get(intervention.Id);
                    if(thisListInnerSARJO != null) {
                            system.debug(intervention.Id);
                                    for(InnerSARJO innSARJO: thisListInnerSARJO) {
                                            innSARJO.OuterIntervention = thisInnerIntervention;
                                    }
                                    thisInnerIntervention.lstInnSARJO = thisListInnerSARJO;
                                    system.debug(thisInnerIntervention.lstInnSARJO);
                    }
                    thisInnerPlanObjective.lstInnIntervention.add(thisInnerIntervention);
                }   
            }
            
            Short_Term_Goal__c thisObjective = null;
            // add all objectives to map
            for(Short_Term_Goal__c objective : mapObjectives.values()){
                mapInnerObjectives.put(string.valueOf(objective.Id), new InnerObjective(objective, this));        
            }
            
            
            InnerObjective thisInnerObjective = null;
            for(InnerPlanObjective InnPlanObjective : mapInnerPlanObjectives.values()){
                thisInnerObjective = mapInnerObjectives.get(InnPlanObjective.PlanObjective.Short_Term_Goal__c); 
                    thisListInnerSARJO = mapListInnerSARJOPlan.get(InnPlanObjective.PlanObjective.Id);
                    if(thisListInnerSARJO != null) {
                            for(InnerSARJO innSARJO: thisListInnerSARJO) {
                                    innSARJO.OuterPlanObjective = InnPlanObjective;
                            }
                            InnPlanObjective.lstInnSARJO = thisListInnerSARJO;
                    }
                InnPlanObjective.OuterCls = thisInnerObjective;
                if(thisInnerObjective != null) {
                    thisInnerObjective.lstInnPlanObjective.add(InnPlanObjective);
                } 
            }
            /*
            // add all interventions to map of plan objectives
            InnerPlanObjective thisInnerPlanObjective = null;
            Objective__c thisPlanObjective = null;
            thisInnerObjective = null;
            
            for(Intervention__c intervention : mapInterventions.values()){
                    thisPlanObjective = mapPlanObjectives.get(intervention.Objective__c);
                    if(thisPlanObjective != null) {
                            thisInnerObjective = mapInnerObjectives.get(thisPlanObjective.Short_Term_Goal__c); 
                    }
                thisInnerPlanObjective = thisInnerObjective.lstInnPlanObjective mapInnerPlanObjectives.get(intervention.Objective__c); 
                if(thisInnerPlanObjective != null) {
                    thisInnerPlanObjective.lstInnIntervention.add(new InnerIntervention(intervention, thisInnerPlanObjective));
                } 
            }
            */
            
            for(Plan_ServiceAssignment_MJO__c SARJO : mapServiceAgreements.values()){
                    if(SARJO.RecordType.Name == 'SA-Short-term Goal JO'){
                            thisInnerObjective = mapInnerObjectives.get(SARJO.Short_Term_Goal__c);
                            if(thisInnerObjective != null) {
                                    //remove OSA.Id from Service Assignment's picklict
                                    for(integer i = 0; i < thisInnerObjective.MyLstOptServiceAssignments.size(); i++){
                                if (thisInnerObjective.MyLstOptServiceAssignments[i].getValue() == string.valueof(SARJO.Service_Assignment__c))
                                {
                                    thisInnerObjective.MySelectedLstOptServiceAssignments.add(thisInnerObjective.MyLstOptServiceAssignments[i]);
                                    thisInnerObjective.MyLstOptServiceAssignments.remove(i);
                                    break;
                                }
                            }
                            thisInnerObjective.lstInnSARJO.add(new InnerSARJO(SARJO, SARJO.Service_Assignment__r.Name, thisInnerObjective, SARJO.RecordType));
                            }       
                    }
            }
            
            for(InnerObjective innObj : mapInnerObjectives.values()) {
                    for(InnerPlanObjective innPlanObj : innObj.lstInnPlanObjective) {
                            innPlanObj.cloneServiceAssigmentsOpptions();
                            for(InnerIntervention innInter: innPlanObj.lstInnIntervention) {
                                    innInter.cloneServiceAssigmentsOpptions();
                            }
                    }
            }
            
            LstInnObjective = mapInnerObjectives.values();
        }
        
        public void AddNewObjective() {
            newObjective.Objective.Plan__c = plan.Id;
            insert newObjective.objective;
            if(LstInnObjective.isEmpty()) { // if list is empty, we do not have index, so we simply add item, else we add item at the beginning
                    LstInnObjective.add(newObjective);
            } else {
                    LstInnObjective.add(0, newObjective);
            }
            
            /*
            InnObjective temp = list
            for(Integer i = LstInnObjective.size(); i = 0; i--) {
            
            }*/
            
            newObjective = new InnerObjective(new Short_Term_Goal__c(), this); // clear form
            ObjectiveAdd = false; // hide form
        }
        
        public void AddNewObjectiveCancel() {
            newObjective = new InnerObjective(new Short_Term_Goal__c(), this); // clear form
            ObjectiveAdd = false; // hide form
        }
        
        public list<SelectOption> getAllServiceAssignments(){
            list<SelectOption> options = new list<SelectOption>();
            
            plan = createPlan(plan.Id);      
            list<Service_Assignment__c> lstAssignments = 
                [SELECT Id, Name FROM Service_Assignment__c 
                    WHERE Admission__c = :plan.Admission__c AND Status__c = 'Active' AND RecordType.Name = 'Standard Service Assignment'
                        ORDER BY Name LIMIT 49999];
                    //
            options.add(new SelectOption('',''));
            
            for(Service_Assignment__c Assignment : lstAssignments) {
                    options.add(new SelectOption(Assignment.Id, Assignment.Name));
            }
            
            return options;
        }
        
        public void Nothing(){
            
        }
        
        public PageReference CheckExternalPlan(){
            Boolean setToValue = true;
            if(plan.External_Plan__c != null){
                    setToValue = plan.External_Plan__c;
            }
            plan.External_Plan__c = setToValue;
            plan.Read_Only__c = setToValue;
            update plan;
            list<Short_Term_Goal__c> lstObjs = new list<Short_Term_Goal__c>();
            list<Objective__c> lstPlanObjs = new list<Objective__c>();
            list<Intervention__c> lstInters = new list<Intervention__c>();
            for(InnerObjective innObj :lstInnObjective){
                    innObj.Objective.Read_Only__c = setToValue;
                    lstObjs.add(innObj.Objective);
                    
                    for(InnerPlanObjective innPlanObj : innObj.lstInnPlanObjective){
                            innPlanObj.PlanObjective.Read_Only__c = setToValue;
                            lstPlanObjs.add(innPlanObj.PlanObjective);
                            
                            for(InnerIntervention innInt :innPlanObj.lstInnIntervention){
                                    innInt.Intervention.Read_Only__c = setToValue;
                                    lstInters.add(innInt.Intervention);
                            }
                    }
            }
            
            update lstObjs;
            update lstPlanObjs;
            update lstInters;
            
            ExternalPlanDone = true;
            
            PageReference PR = new PageReference('/'+plan.Id);
            PR.setRedirect(true);
            return PR;
        }
        
        public PageReference backExternal(){
            PageReference PR = new PageReference('/'+plan.Id);
            PR.setRedirect(true);
            return PR;
        }
}