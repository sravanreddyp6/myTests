/**
    Description: This is standard controller extension for VF page V2SA_ProgressNotesEmbed. This page is embeded in standard layout for Progress Note record 
    and enables to manage relationship between selected progress note and goals. On those goals are visible in particular Progress Note, for which there is
    association with Progress Note's Service Assignment. Also following condition must be met: "If the Goal the Short Term Goal Status ="Achieved" then is should 
    no longer appear as an option to select on new Progress Notes but stay as a selection of previous Progress Notes that it has been tied to." 
*/
//2012-09-27 18:00pm Marek Dzurilla: added condition which decides whether to display Goals and Objectives according to 'Status__c' field 
//2012-09-27 03:00pm Marek Dzurilla: added new functionality which displays error message when user tries to edit locked Progress Note's Short Term Goals, Objectives or Interventions
//2012-09-24 05:00pm Marek Dzurilla: Update Objective_Service_Agreement__c to Service_Assignment_Relationship_JO__c
//2012-09-24 10:00am Karel Slaby: Finished coding controller

public with sharing class V2SA_ProgressNotesEmbed {

        
        //lists of inner classes objects
        public list<innObjective> lstInnObjectives {get;set;}
        
        //public Progress_Note__c newProgressNote {get;set;}
        public Progress_Note__c currentNote {get;set;}
        public Boolean isSave {get;set;}
        public list<Short_Term_Goal__c> lstGoals {get;set;}
        public map<id, ProgressNote_ServiceAssignment_mJO__c> mapObjectiveJuntionByObjectiveId;
        public map<id, ProgressNote_ServiceAssignment_mJO__c> mapObjectiveJuntionByPoId;
        public map<id, ProgressNote_ServiceAssignment_mJO__c> mapObjectiveJuntionByInterventionId;
        map<id, list<Objective__c>> mapLstPlanObjectivesByGoalId {get;set;}
        public Boolean isEdit {get;set;}    
        public Boolean displayErrorMsg {get;set;}
        public Boolean checkBoxesDisabled {get;set;}
        list<ProgressNote_ServiceAssignment_mJO__c> lstJunctionsToDelete;
        list<ProgressNote_ServiceAssignment_mJO__c> lstJunctionsToInsert;
        
    
        public V2SA_ProgressNotesEmbed(String inputProgressNote){
            String progNoteID = inputProgressNote;
            if(progNoteID == null || progNoteID == '') { return; }
    
            displayErrorMsg = false;
            checkBoxesDisabled = false;
            mapLstPlanObjectivesByGoalId = new map<id, list<Objective__c>>(); 
            //this.newProgressNote = (Progress_Note__c)stdController.getRecord();
            isSave = false;
            isEdit = false; 
            currentNote = [select id, Approval_Status__c, Service_Assignment__c, CreatedDate, Plan__r.Name, Name from Progress_Note__c where id =: progNoteID][0];
            init();
        }
        
        public V2SA_ProgressNotesEmbed(ApexPages.StandardController controller) {
            String progNoteID; 
            if(ApexPages.currentPage().getParameters().get('id') != null){
                progNoteID = ApexPages.currentPage().getParameters().get('id');
            }
            if(progNoteID == null || progNoteID == '') { return; }
    
            displayErrorMsg = false;
            checkBoxesDisabled = false;
            mapLstPlanObjectivesByGoalId = new map<id, list<Objective__c>>(); 
            //this.newProgressNote = (Progress_Note__c)stdController.getRecord();
            isSave = false;
            isEdit = false; 
            currentNote = [select id, Approval_Status__c, Service_Assignment__c, CreatedDate, Plan__r.Name, Name from Progress_Note__c where id =: progNoteID][0];
            init();
        }
        
        public V2SA_ProgressNotesEmbed(){//ApexPages.StandardController stdController
            displayErrorMsg = false;
            checkBoxesDisabled = false;
            mapLstPlanObjectivesByGoalId = new map<id, list<Objective__c>>(); 
            //this.newProgressNote = (Progress_Note__c)stdController.getRecord();
            isSave = false;
            isEdit = false; 
            PageReference pageRef = ApexPages.currentPage();
            Map<String, String> mapRecordId = pageRef.getParameters();
            //checking if page was loaded with id parameter in url
            if(mapRecordId.get('id') != null){
                //select information about progress note which is currently displayed on page
                currentNote = [select id, Approval_Status__c, Service_Assignment__c, CreatedDate, Plan__r.Name, Name from Progress_Note__c where id =: mapRecordId.get('id')][0];
    
                //checking if current progress note was created maximum than 10 seconds ago. if true display javascript alert in visualforce page that newly created progress note should be submitted for approval
                DateTime dT = System.now();
                Date currentDate = date.newinstance(dT.year(), dT.month(), dT.day());
                Date noteDate = date.newinstance(currentNote.CreatedDate.year(), currentNote.CreatedDate.month(), currentNote.CreatedDate.day());
                if(currentDate == noteDate){
                    if(dT.hour() == currentNote.CreatedDate.hour() && dT.minute() == currentNote.CreatedDate.minute()){
                        //system.debug(dt.second() - currentNote.CreatedDate.second());
                        if((dt.second() - currentNote.CreatedDate.second()) <= 10){
                            isSave = true;
                        }
                    }
                }
            }
            else {
                //if page is loaded without ID of progress note, stop executing this controller 
                return; 
            }
            init();
        }
        
        //Inner Classes ---------------------------------------------------------------------------------------------------------
        public class innObjective{
            
            public Short_Term_Goal__c objective {get;set;}
            public Boolean belongsToNote {get;set;}
            public Boolean isEditable {get;set;}
            public Boolean belongsToNotePrev;
            public list<innPlanObjective> lstInnPO {get;set;}
            public V2SA_ProgressNotesEmbed OuterCls;
            
            public innObjective(Short_Term_Goal__c objective, Boolean belongsToNote, V2SA_ProgressNotesEmbed OuterCls){
                this.OuterCls = OuterCls;
                this.objective = objective;
                this.belongsToNote = belongsToNote;
                this.belongsToNotePrev = belongsToNote;
                this.isEditable = false;
                lstInnPO = new list<innPlanObjective>();
            }
        }
        
        
        public class innPlanObjective{
            
            public Objective__c planObjective {get;set;}
            public Boolean belongsToNote {get;set;}
            public Boolean isEditable {get;set;}
            Boolean belongsToNotePrev;
            public list<innIntervention> lstInnInt {get;set;}
            public innObjective OuterCls;
            
            public innPlanObjective(Objective__c planObjective, Boolean belongsToNote, innObjective OuterCls){
                this.OuterCls = OuterCls;
                this.planObjective = planObjective;
                this.belongsToNote = belongsToNote;
                this.belongsToNotePrev = belongsToNote;
                this.isEditable = false;
                lstInnInt = new list<innIntervention>();
            }
            
            public PageReference updateMe(){
                OuterCls.OuterCls.displayErrorMsg = false;
                if(OuterCls.OuterCls.currentNote.Approval_Status__c == 'Pending'){
                    OuterCls.OuterCls.displayErrorMsg = true;
                    return null;
                }
                
                OuterCls.OuterCls.lstJunctionsToDelete = new list<ProgressNote_ServiceAssignment_mJO__c>();
                OuterCls.OuterCls.lstJunctionsToInsert = new list<ProgressNote_ServiceAssignment_mJO__c>(); 
                
                OuterCls.OuterCls.updatePoJoLISTS(this);
                system.debug(OuterCls.OuterCls.lstJunctionsToDelete);
                delete OuterCls.OuterCls.lstJunctionsToDelete;
                insert OuterCls.OuterCls.lstJunctionsToInsert;  
                OuterCls.OuterCls.UpdateJunctions();
                return null;
            }
        }
        
        public class innIntervention{
            
            public Intervention__c intervention {get;set;}
            public Boolean belongsToNote {get;set;}
            public Boolean isEditable {get;set;}
            Boolean belongsToNotePrev;
            public innPlanObjective OuterCls;
            
            public innIntervention(Intervention__c intervention, Boolean belongsToNote, innPlanObjective OuterCls){
                this.OuterCls = OuterCls;
                this.intervention = intervention;
                this.belongsToNote = belongsToNote;
                this.belongsToNotePrev = belongsToNote;
                this.isEditable = false;
            }
            
            public PageReference updateMe(){
                OuterCls.OuterCls.OuterCls.displayErrorMsg = false;
                if(OuterCls.OuterCls.OuterCls.currentNote.Approval_Status__c == 'Pending'){
                    OuterCls.OuterCls.OuterCls.displayErrorMsg = true;
                    return null;
                }
                OuterCls.OuterCls.OuterCls.lstJunctionsToDelete = new list<ProgressNote_ServiceAssignment_mJO__c>();
                OuterCls.OuterCls.OuterCls.lstJunctionsToInsert = new list<ProgressNote_ServiceAssignment_mJO__c>(); 
                
                OuterCls.OuterCls.OuterCls.updateIntJOlists(this);
                
                delete OuterCls.OuterCls.OuterCls.lstJunctionsToDelete;
                insert OuterCls.OuterCls.OuterCls.lstJunctionsToInsert;
                OuterCls.OuterCls.OuterCls.UpdateJunctions();
                return null;    
            }   
        }
        //Inner Classes ---------------------------------------------------------------------------------------------------------
        
        public void init(){
            if(currentNote.Approval_Status__c == 'Pending'){
                displayErrorMsg = true;
                checkBoxesDisabled = true;
            }
            createInnerObjectives();
        }
        
        public void editObjectives(){
            isEdit = isEdit ? false : true;  
        }
        // create list of Inner class objects
        private void createInnerObjectives(){
            
            //select records from junction Object between goals and service assignments
            list<Plan_ServiceAssignment_MJO__c> lstObjectives_Assignments_Junction = [Select o.Service_Assignment__c, o.Short_Term_Goal__c From Plan_ServiceAssignment_MJO__c o where o.Service_Assignment__c =: currentNote.Service_Assignment__c and o.short_term_goal__c != ''];
            set<ID> setPlanSAGoalId = new set<ID>();
            for ( Plan_ServiceAssignment_MJO__c goalid: lstObjectives_Assignments_Junction )
            	setPlanSAGoalId.Add( goalid.short_term_goal__c );

			//system.debug( 'GOAL IDS');
            //system.debug( setPlanSAGoalId );
            
            // get distinct list of objective ids for this service assignment/plan
            list<Plan_ServiceAssignment_MJO__c> lstPlanSAObjectiveId = [Select o.short_term_goal__c, o.objective__c From Plan_ServiceAssignment_MJO__c o where o.Service_Assignment__c =: currentNote.Service_Assignment__c and o.short_term_goal__c in :setPlanSAGoalId and o.objective__c != ''];
            set<ID> setPlanSAObjectiveId = new set<ID>();
            for ( Plan_ServiceAssignment_MJO__c objid: lstPlanSAObjectiveId )
            	setPlanSAObjectiveId.Add( objid.objective__c );
            
            //system.debug( 'OBJECTIVE IDS');
            //system.debug( setplanSAobjectiveid);
            
            // get distinct list of intervention ids for this service assignment/plan
            list <Plan_ServiceAssignment_MJO__c> lstPlanSAInterventionId = [Select o.short_term_goal__c, o.objective__c, o.intervention__c From Plan_ServiceAssignment_MJO__c o where o.Service_Assignment__c =: currentNote.Service_Assignment__c and o.short_term_goal__c in :setPlanSAGoalId and o.objective__c in :setPlanSAObjectiveId and o.intervention__c != ''];
			set<ID> setPlanSAInterventionId = new set<ID>();
            for ( Plan_ServiceAssignment_MJO__c objid: lstPlanSAInterventionId )
            	setPlanSAInterventionId.Add( objid.intervention__c );
            	
            //system.debug('INTERVENTION IDS');
    		//system.debug( setPlanSAInterventionId);
    		        
			// create distinct list of goal ids from what is associated to service assignment
            set<Id> goalIDsFromJunctionObject = new set<id>();
            for(Plan_ServiceAssignment_MJO__c objectiveJunction:lstObjectives_Assignments_Junction){
                goalIDsFromJunctionObject.add(objectiveJunction.Short_Term_Goal__c);
            }
            //system.debug  (goalIDsfromjunctionobject);
            // select all goals that belongs to plan associated to current progress note 
            // deleted Short term goal__c from inner select PP, RJ, JG
            lstGoals = [Select o.id, o.Achieved_DateTime__c, o.Plan__c, o.Plan_Name__c, o.Short_Term_Goal_Description__c, o.Name, o.Status__c, o.Frequency_and_Duration__c, (Select Id, Name, Objective_Description__c, Objective_Name__c, 
                        Achieved_DateTime__c, Short_Term_Goal__c, Plan__c, Read_Only__c, Frequency_and_Duration__c, Status__c From Objectives__r where id in :setplanSAobjectiveid)  From Short_Term_Goal__c o where o.Plan__c =: currentNote.Plan__r.Id AND o.id IN :goalIDsFromJunctionObject];
            
            // put the objective ids for these STGs into a distinct list.  
            set<id> setPlanObjectiveId = new set<id>();
            
            for(Short_Term_Goal__c goal:lstGoals){
                mapLstPlanObjectivesByGoalId.put(goal.id, goal.Objectives__r);
                for(Objective__c objPO:goal.Objectives__r){
                	
                	if ( setPlanSAObjectiveId.contains(objPO.Id)) {
                    	setPlanObjectiveId.add(objPO.Id);
                	}
                }
            }   
            //system.debug( 'OBJECTIVES BASED ON GOALS');
            //system.debug( setPlanObjectiveId);
            
            
            list<Intervention__c> lstInterventions = [Select i.Objective__c, i.Name, i.Intervention_Name__c, i.Intervention_Description__c, i.Id From Intervention__c i where i.Objective__c IN :setPlanSAObjectiveId and i.id in :setPlanSAInterventionId];
            map<id, list<Intervention__c>> mapLstIntByPoId = new map<id, list<Intervention__c>>();
            for(Intervention__c objInt:lstInterventions){
            	
            	if ( setPlanSAInterventionId.contains(objInt.id) ) {
	                if(mapLstIntByPoId.get(objInt.Objective__c) == null){
	                    mapLstIntByPoId.put(objInt.Objective__c, new list<Intervention__c>());
	                }
	                mapLstIntByPoId.get(objInt.Objective__c).add(objInt);
            	}
            }
            
            //system.debug('INTERVENTIONS');
            //system.debug( maplstintbypoid);
            
            //list<innObjective> 
            lstInnObjectives = new list<innObjective>();
            
            UpdateJunctions();
            
            //checking if displayed goals on page are associated to progress note via junction object
            for(Short_Term_Goal__c objective:lstGoals){
                
                if(objective.Status__c == 'Achieved' && objective.Achieved_DateTime__c <= currentNote.CreatedDate){
                    continue;
                }
                innObjective newInnObjective;
                Boolean co = false;
                if(mapObjectiveJuntionByObjectiveId.get(objective.id) != null){
                    co = true;
                }
                newInnObjective = new innObjective(objective, co, this);
                
                for(Objective__c objPo:objective.Objectives__r){
                    if(objPo.Status__c == 'Achieved' && objPo.Achieved_DateTime__c <= currentNote.CreatedDate){
                        continue;
                    }   
                    co = true;
                    if(mapObjectiveJuntionByPoId.get(objPo.id) == null){
                        co = false; 
                    }
                    innPlanObjective newInnPlanObjective = new innPlanObjective(objPo, co, newInnObjective);
                    
                    if(mapLstIntByPoId.get(objPo.id) != null){
                        for(Intervention__c objInt:mapLstIntByPoId.get(objPo.id)){
                            co = true;
                            if(mapObjectiveJuntionByInterventionId.get(objInt.id) == null){
                                co = false; 
                            }
                            innIntervention newInnIntervention = new innIntervention(objInt, co, newInnPlanObjective);
                            newInnPlanObjective.lstInnInt.add(newInnIntervention);
                        }
                    }
                    
                    newInnObjective.lstInnPO.add(newInnPlanObjective);
                }
                
                lstInnObjectives.add(newInnObjective);
            }
        }
        
        public void UpdateJunctions(){
            list<ProgressNote_ServiceAssignment_mJO__c> lstObjectivesJunction = [Select p.id, p.Progress_Note__c, p.Short_Term_Goal__c, p.Objective__c, p.Intervention__c  From ProgressNote_ServiceAssignment_mJO__c 
                                                                         p where p.Progress_Note__c =: currentNote.id];
            mapObjectiveJuntionByObjectiveId = new map<id, ProgressNote_ServiceAssignment_mJO__c>();
            mapObjectiveJuntionByPoId = new map<id, ProgressNote_ServiceAssignment_mJO__c>();
            mapObjectiveJuntionByInterventionId = new map<id, ProgressNote_ServiceAssignment_mJO__c>();
            
            
            for(ProgressNote_ServiceAssignment_mJO__c junction:lstObjectivesJunction){
                if(junction.Short_Term_Goal__c != null){
                    mapObjectiveJuntionByObjectiveId.put(junction.Short_Term_Goal__c, junction);  
                }
                if(junction.Objective__c != null){
                    mapObjectiveJuntionByPoId.put(junction.Objective__c, junction);    
                }
                if(junction.Intervention__c != null){
                    mapObjectiveJuntionByInterventionId.put(junction.Intervention__c, junction);    
                }
            }
        }
        
        
        //when this function is called from page, all junction objects are deleted(if checkbox is unchecked and after page loaded was checked) and new junction objects are created(if checkbox is checked and after page loaded was unchecked) 
        public PageReference saveObjectives(){
            displayErrorMsg = false;
            if(currentNote.Approval_Status__c == 'Pending'){
                displayErrorMsg = true;
                return null;
            }
            lstJunctionsToDelete = new list<ProgressNote_ServiceAssignment_mJO__c>();
            lstJunctionsToInsert = new list<ProgressNote_ServiceAssignment_mJO__c>(); 
            for(innObjective innerObjective:lstInnObjectives){
                if(innerObjective.belongsToNotePrev == true && innerObjective.belongsToNote == false && mapObjectiveJuntionByObjectiveId.get(innerObjective.objective.id) != null){
                    innerObjective.belongsToNotePrev = false;
                    if(mapObjectiveJuntionByObjectiveId.get(innerObjective.objective.id)!=null){
                        lstJunctionsToDelete.add(mapObjectiveJuntionByObjectiveId.get(innerObjective.objective.id));
                    }
                }
                else if(innerObjective.belongsToNotePrev == false && innerObjective.belongsToNote == true && mapObjectiveJuntionByObjectiveId.get(innerObjective.objective.id) == null){
                    innerObjective.belongsToNotePrev = true;
                    ProgressNote_ServiceAssignment_mJO__c newJunction = new ProgressNote_ServiceAssignment_mJO__c();
                    newJunction.Short_Term_Goal__c = innerObjective.objective.id;
                    newJunction.Progress_Note__c = currentNote.id;
                    lstJunctionsToInsert.add(newJunction);
                }
                for(innPlanObjective objPO:innerObjective.lstInnPO){
                    updatePoJOlists(objPO); 
                }
            }
    
            delete lstJunctionsToDelete;
            insert lstJunctionsToInsert;
            UpdateJunctions();
            /*
            for(innObjective innObj:lstInnObjectives){
                if(innObj.objective.Short_Term_Goal_Description__c != mapDefaultObjectiveDescriptionById.get(innObj.objective.id)){
                    innObj.objective.Short_Term_Goal__c = 'Revised';
                }
            }
            update lstGoals;*/
            //update lstGoals;
            isEdit = false;
            init();
            return null;
        }
        
        public void updatePoJOlists(innPlanObjective myInnPlanObjective){
            if(myInnPlanObjective.belongsToNotePrev == true && myInnPlanObjective.belongsToNote == false && mapObjectiveJuntionByPoId.get(myInnPlanObjective.planObjective.id) != null || myInnPlanObjective.OuterCls.belongsToNote == false){
                myInnPlanObjective.belongsToNote = false;
                myInnPlanObjective.belongsToNotePrev = false;
                if(mapObjectiveJuntionByPoId.get(myInnPlanObjective.planObjective.id) != null){
                    lstJunctionsToDelete.add(mapObjectiveJuntionByPoId.get(myInnPlanObjective.planObjective.id));
                }
            }
            else if(myInnPlanObjective.belongsToNotePrev == false && myInnPlanObjective.belongsToNote == true && mapObjectiveJuntionByPoId.get(myInnPlanObjective.planObjective.id) == null){
                ProgressNote_ServiceAssignment_mJO__c newJunction = new ProgressNote_ServiceAssignment_mJO__c();
                //newJunction.Short_Term_Goal__c = myInnPlanObjective.OuterCls.objective.id;
                myInnPlanObjective.belongsToNotePrev = true;
                newJunction.Objective__c = myInnPlanObjective.planObjective.id;
                newJunction.Progress_Note__c = currentNote.id;
                lstJunctionsToInsert.add(newJunction);
            }       
            for(innIntervention objInt:myInnPlanObjective.lstInnInt){
                updateIntJOlists(objInt);   
            }   
        }
        
        public void updateIntJOlists(innIntervention myInnIntervention){
            if(myInnIntervention.belongsToNotePrev == true && myInnIntervention.belongsToNote == false && mapObjectiveJuntionByInterventionId.get(myInnIntervention.intervention.id) != null || myInnIntervention.OuterCls.belongsToNote == false){
                myInnIntervention.belongsToNote = false;
                myInnIntervention.belongsToNotePrev = false;
                if(mapObjectiveJuntionByInterventionId.get(myInnIntervention.intervention.id) != null){
                    lstJunctionsToDelete.add(mapObjectiveJuntionByInterventionId.get(myInnIntervention.intervention.id));
                }
            }
            else if(myInnIntervention.belongsToNotePrev == false && myInnIntervention.belongsToNote == true && mapObjectiveJuntionByInterventionId.get(myInnIntervention.intervention.id) == null){
                ProgressNote_ServiceAssignment_mJO__c newJunction = new ProgressNote_ServiceAssignment_mJO__c();
                //newJunction.Short_Term_Goal__c = myInnIntervention.OuterCls.OuterCls.objective.id;
                myInnIntervention.belongsToNotePrev = true;
                newJunction.Intervention__c = myInnIntervention.intervention.id;
                newJunction.Progress_Note__c = currentNote.id;
                lstJunctionsToInsert.add(newJunction);
            }       
        }
        
        public void nothing(){
            
        }

}