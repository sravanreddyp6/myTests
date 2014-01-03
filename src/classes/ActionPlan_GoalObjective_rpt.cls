public with sharing class ActionPlan_GoalObjective_rpt {

    public string pbsID {get; set;}
    public string saID {get; set;}
    public string selectPlan {get; set;}
    public date StartDate {get; set;}
    public datetime  startDateTime{get; set;}
    public datetime  endDateTime{get; set;}
    public date EndDate {get; set;}
    public string tz{get; set;}   
    public list<id> selectedGO {get; set;}
    public list<ProgressNote_ActionPlanChildren_mjo__c> note_plan_joins {get; set;}
    public Service_Assignment__c sa {get; set;}    
    public list<SelectOption> plans = new list<SelectOption>();
    public list<SelectOption> getPlans() {return plans;}
    public List<SelectOption> goals = new list<SelectOption> ();
    public List<SelectOption> getGoals(){
        goals.clear();
       for(Action_Plan_Goal__c g: [select id, name, description__c, Sort_Order__c,  
                    (select id, name, description__c, Effective_Date__c, target_end_date__c, status__c, type__c, Sort_Order__c
                     from Action_Plan_Objectives__r Order By Sort_Order__c) 
                        from Action_Plan_Goal__c where action_plan__c = :selectPlan Order By Sort_Order__c]){
       
           goals.add(new SelectOption(g.id,g.description__c));
               for(Action_Plan_Objective__c o : g.Action_Plan_Objectives__r){
                   goals.add(new SelectOption(o.id, ' - '+ o.description__c));
               
               }
           
       }
        return goals;
    
    }
    

public ActionPlan_GoalObjective_rpt(ApexPages.StandardController controller) {
       pbsID = apexpages.currentpage().getparameters().get('pbsid');
       saID = apexpages.currentpage().getparameters().get('said');
       sa= (Service_Assignment__c)controller.getRecord();
       
       for(Action_Plan__c p :[select name, id from Action_plan__c where Service_Assignment__c = :saID order by Createddate DESC]){
           plans.add(new SelectOption(p.id,p.name)); 
       
       }
       selectedGO = new list<id>();
       note_plan_joins = new list<ProgressNote_ActionPlanChildren_mjo__c>();
             

       
       tz = [Select TimeZoneSidKey from User where id =: USerInfo.getUserId()].TimeZoneSidKey ;
    //    TimeZone tz = UserInfo.getTimeZone();


       
       
    }

    public pagereference runReport(){
    
        
        
        //
        TimeZone zone = UserInfo.getTimeZone();
        
       startDateTime = StartDate;
       if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}
       
       
       endDateTime = endDate;
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       }

        
        note_plan_joins.clear();
        FOR(ProgressNote_ActionPlanChildren_mjo__c item: [select progress_Note__c, progress_Note__r.name, Goal__r.Description__c, progress_Note__r.id,
                            Objective__r.Description__c, Progress_Note__r.Start_time__c,
                            Progress_Note__r.End_time__c, Progress_Note__r.CreatedByid, Progress_Note__r.Action_Plan__c, Note_End_Date__c, Progress_Note__r.Service_Assignment__c,
                            Note_Start_Date__c
                                from ProgressNote_ActionPlanChildren_mjo__c 
                                    where  
                                        (
                                            (Progress_Note__r.Start_time__c > :startDateTime OR Progress_Note__r.End_time__c > :startDateTime ) 
                                                AND 
                                            (Progress_Note__r.Start_time__c < :endDateTime OR Progress_Note__r.End_time__c < :endDateTime)
                                        ) 
                                    
                                            AND Progress_Note__r.Service_Assignment__c = :SA.id  
                                        ORDER BY CreatedDate]){
                                  //  
                                  
                                 
        system.debug('start - '+item.Progress_Note__r.Start_time__c);
        system.debug('end- '+item.Progress_Note__r.End_time__c);
        system.debug('Filter- '+startDate + ' | ' + endDate);
        system.debug('Name - '+item.progress_Note__r.name);
        note_plan_joins.add(item);
    }
        return null;
    }

    
}