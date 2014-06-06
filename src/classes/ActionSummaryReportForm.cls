public class ActionSummaryReportForm extends ActionSummaryBase {
    
    public boolean Editable { get { return (ActionSummary.Status__c != 'Final') && canEditSummary ;}}
    
    // constructor
    public ActionSummaryReportForm(ApexPages.StandardController controller) {
        super(controller);
        StartDateStr= ActionSummary.Start_Date__c.format();
        Duration = ActionSummary.Start_Date__c.monthsBetween(ActionSummary.End_Date__c) ;
    }
    
     public String getPersonId(){
        return [select Service_Assignment__r.Person_Being_Served__r.Id
                    from Action_Summary__c
                    where Id = :ActionSummary.Id].Service_Assignment__r.Person_Being_Served__r.Id;
    }
    
/////////////////////
// pick list values
/////////////////////

    public List<SelectOption> getRecommendationOptions(){
            Schema.sObjectType sobject_type = action_summary__c.getSObjectType();

            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();

            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
          
            List<Schema.PicklistEntry> pick_list_values = field_map.get('recommendation__c').getDescribe().getPickListValues();

            List<selectOption> options = new List<selectOption>();

           for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
          }
      return options;
      }
      
//////////////////
// Provide a cache for the plans object since it is requested frequently by the page
//////////////////
    private List<ActionPlanWrapper> plans = null; 
    public List<ActionPlanWrapper> getPlans(){
        if (plans == null){
            plans = calcPlans();
        }
        return plans;
    }
    
//////////////////
// The set of objective results structured by action plan and goal
/////////////////    
    public List<ActionPlanWrapper> calcPlans(){
        List<ActionPlanWrapper> plans = 
            new List<ActionPlanWrapper>();
        List<ActionPlanGoalWrapper> goals = null;
        List<objective_results_wrapper> objectives = null;
        action_plan__c lastplan = null;
        ActionPlanWrapper lastplanwrapper;
        action_plan_goal__c lastgoal = null;
        ActionPlanGoalWrapper lastgoalwrapper;
        for(objective_results_wrapper objective: getObjectiveResults()){
            if (lastplan == null || lastplan.id != objective.Plan_Objective.action_plan_goal__r.action_plan__c){
                lastplan = objective.Plan_Objective.action_plan_goal__r.action_plan__r;
                lastgoal = null;
                lastplanwrapper = new ActionPlanWrapper(lastplan);
                plans.add(lastplanwrapper );
            }
            if (lastgoal == null || lastgoal.id != objective.Plan_Objective.action_plan_goal__c){
                lastgoal = objective.Plan_Objective.action_plan_goal__r;
                lastgoalwrapper = new ActionPlanGoalWrapper(lastgoal);
                lastplanwrapper.ActionPlanGoals.add(lastgoalwrapper);
            }
            lastgoalwrapper.ActionPlanObjectives.Add(objective);
        }
        return plans;
    }

//////////////////
// The lists of other reports that fall within the reporting period.
// Available read only.
/////////////////
    public Map<id, List<Objective_Summary_Comment__c>> OtherReportsMap(){
        List<Objective_Summary_Comment__c> oslist = 
            [select comment__c, recommendation__c, 
                    action_plan_objective__c, action_plan_objective__r.id,
                    Action_summary__r.Start_Date__c, Action_summary__r.End_Date__c, Action_summary__r.Duration__c,
                    Met_objective_count__c, Not_met_count__c, trials_count__c, percent_met__c,
                    Occurrences__c
               from Objective_Summary_Comment__c
              where Action_Summary__r.Service_assignment__c = :ActionSummary.Service_assignment__c
                and Action_Summary__r.Start_Date__c >= :ActionSummary.Start_date__c 
                and Action_Summary__r.End_Date__c <= :ActionSummary.End_Date__c
                and Action_summary__c != :ActionSummary.Id
              order by action_summary__r.end_date__c, action_summary__r.duration__c
            ];
        Map<id, List<Objective_Summary_Comment__c>> osmap = 
            new Map<id, List<Objective_Summary_Comment__c>>();
        for(Objective_Summary_Comment__c osummary: oslist){
            if (osmap.containskey(osummary.action_plan_objective__c)){
                osmap.get(osummary.action_plan_objective__c).Add(osummary);
            } else {
                osmap.put(osummary.action_plan_objective__c, new List<Objective_Summary_Comment__c>{osummary});
            }        
        }
        return osmap;
    }
    
//////////////////
// The internal query
//////////////////
//    public List<Action_plan_objective__c> getObjectives(){
    // Only return the skill objectives until we handle behavior objectives.
//        return  null;
                
//    }
    
///////////////////
// create the 'view-model' objects for the page
///////////////////
    public List<objective_results_wrapper> getObjectiveResults() {
        List<objective_results_wrapper> result = new List<objective_results_wrapper>();
        Map<id, List<Objective_Summary_Comment__c>> OtherSummaryComments = OtherReportsMap();
        system.debug('other reports:' + OtherSummaryComments.size().format());
        for(Action_plan_objective__c objective: [select name, 
                        action_plan_goal__r.action_plan__r.name, action_plan_goal__r.action_plan__r.status__c, 
                        action_plan_goal__r.action_plan__r.effective_date__c, action_plan_goal__r.action_plan__r.target_date__c,     
                        action_plan_goal__r.name, Effective_Date__c, Target_End_Date__c, 
                        description__c, action_plan_goal__r.description__c, Type__c, Status__c,
                        (select met_objective__c , Day__c, attempts__c
                           from Action_skill_results__r
                          where Day__c <= :ActionSummary.End_Date__c
                            and Day__c >= :ActionSummary.Start_Date__c),
                        (select Day_time__c , Occurrences__c, Occurred__c 
                           from Action_Behavior_results__r
                          where Day_time__c <= :ActionSummary.End_Date__c
                            and Day_time__c >= :ActionSummary.Start_Date__c),
                        (select comment__c, recommendation__c, met_objective_count__c, not_met_count__c, occurrences__c
                           from Objective_Summary_Comments__r
                          where Action_Summary__c = :ActionSummary.Id)
                   from action_plan_objective__c
                  where Effective_Date__c <= :ActionSummary.End_Date__c 
                    and Target_End_Date__c >= :ActionSummary.Start_Date__c
                    and action_plan_goal__r.action_plan__r.Service_Assignment__c = :ActionSummary.Service_Assignment__c
                    and (action_plan_goal__r.action_plan__r.Status__c = 'Inactive Final'
                         or action_plan_goal__r.action_plan__r.Status__c = 'Active Final') 
                    and action_plan_goal__r.action_plan__r.Effective_Date__c < :ActionSummary.End_Date__c 
                    and action_plan_goal__r.action_plan__r.Target_Date__c >= :ActionSummary.Start_Date__c
                  order by action_plan_goal__r.action_plan__c,  action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c
                ]){
            objective_results_wrapper newresult = newResultsWrapper(objective, ActionSummary);
            if (OtherSummaryComments.ContainsKey(objective.id)){
                newresult.OtherSummaryComments = OtherSummaryComments.get(objective.id);
                system.debug(logginglevel.warn,'other reports for objective:' + OtherSummaryComments.get(objective.id).size().format());
            }
            result.Add(newresult );
        }
        System.debug('Objective Count: ' + result.size());
        return result;
    }
    
    private static objective_results_wrapper newResultsWrapper(Action_plan_objective__c objective, Action_Summary__c summary){
            if (objective.Type__c == 'Skill'){
                return new objective_skill_results_cls(objective, summary);
            }
            return new objective_behavior_results_wrapper(objective, summary);
        }
//////////////////////
// The 'view-model' class
//////////////////////
    public abstract class objective_results_wrapper {
        public Action_plan_objective__c Plan_Objective {get;set;}
        public Objective_Summary_Comment__c Objective_Comment {get;set;}
        public List<Objective_Summary_Comment__c> OtherSummaryComments {get;set;}
        public objective_skill_results_cls AsSkillResult {get {return (objective_skill_results_cls )this;}}
        public objective_behavior_results_wrapper AsBehaviorResult {get {return (objective_behavior_results_wrapper )this;}}
        
        public boolean OtherSummaryCommentsExist {get { return OtherSummaryComments != null && !(OtherSummaryComments.isEmpty()); }}
        
        public objective_results_wrapper(Action_plan_objective__c objective, Action_Summary__c summary){
            Plan_Objective = objective;
            if (!objective.Objective_Summary_Comments__r.isEmpty()){
                Objective_Comment = objective.Objective_Summary_Comments__r[0];
            } else {
                Objective_Comment = new Objective_Summary_Comment__c();
                Objective_Comment.Action_Plan_Objective__c = objective.Id;
                Objective_Comment.Action_summary__c = summary.Id;

            }
        }
        public virtual boolean getIsSkill(){
            return Plan_objective.Type__c == 'Skill';
        }
        public virtual boolean getIsOccurrenceBehavior(){
            return Plan_objective.Type__c == 'Behavior - Count';
        }
        public virtual boolean getIsTimeBehavior(){
            return Plan_objective.Type__c == 'Behavior - Duration';
        }
        
        public virtual void Finalize(){
        }
    }
    
    public class objective_skill_results_cls extends objective_results_wrapper{
        public integer MetCount {get;private set;}
        public integer NotMetCount {get;private set;}
        public integer TrialCount { get { return MetCount + NotMetCount;}}
        public integer PercentMet { get { return (MetCount * 100)/TrialCount;}}
        
        public objective_skill_results_cls(Action_plan_objective__c objective, Action_Summary__c summary){
            super(objective, summary);
            MetCount = 0;
            NotMetCount = 0;
            for(Action_skill_result__c result: objective.Action_skill_results__r){
                if (result.Met_Objective__c == 'y'){
                    MetCount++;
                }
                if (result.Met_Objective__c == 'n'){
                    NotMetCount++;
                }
            }
        }
        
        public override void Finalize(){
            Objective_Comment.Met_Objective_count__c = Metcount;
            Objective_Comment.Not_Met_count__c = NotMetCount;
        }            
    }
    
    public class objective_behavior_results_wrapper extends objective_results_wrapper{
        public objective_behavior_results_wrapper(Action_plan_objective__c objective, Action_Summary__c summary){
            super(objective, summary);
            Occurrences = 0;
            for(Action_behavior_result__c result: objective.Action_Behavior_results__r){
                system.debug(result.Occurrences__c);
                Occurrences += result.Occurrences__c == null ? 0 : result.Occurrences__c.intValue();
            }
        }
        
        public integer Occurrences {get;set;}
       
        public override void Finalize(){
            Objective_Comment.Occurrences__c = Occurrences;
        }
    }
    
    public class ActionPlanWrapper {
        public Action_Plan__c ActionPlan {get;set;}
        public List<ActionPlanGoalWrapper> ActionPlanGoals {get;set;}
        
        public string FormattedEffectiveDate {get { return DateTime.newInstance(ActionPlan.Effective_Date__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');}}
        public string FormattedTargetDate {get { return DateTime.newInstance(ActionPlan.Target_Date__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');}}
        
        public ActionPlanWrapper(Action_Plan__c plan){
            ActionPlan = plan;
            ActionPlanGoals = new List<ActionPlanGoalWrapper>();
        }
    }

    public class ActionPlanGoalWrapper {
        public Action_Plan_Goal__c ActionPlanGoal {get;set;}
        public List<objective_results_wrapper > ActionPlanObjectives {get;set;}
        
        public ActionPlanGoalWrapper(Action_Plan_Goal__c goal){
            ActionPlanGoal = goal;
            ActionPlanObjectives = new List<objective_results_wrapper >();
        }
    }
    
////////////////
// Actions
////////////////
    public PageReference SaveAll(){
        Action_Summary__c report = (Action_Summary__c)controller.getrecord();
        report.End_Date__c = report.Start_Date__c.addMonths( Duration );
        system.debug('duration:' + duration.format() + ':' + report.End_Date__c.format());
        
        List<Objective_Summary_Comment__c> toUpdate = new List<Objective_Summary_Comment__c>();
        for(ActionPlanWrapper plan: Plans){
            for(ActionPlanGoalWrapper goal: (plan.ActionPlanGoals)){
                for(objective_results_wrapper objectiveResults: (goal.ActionPlanObjectives)){
                    if (objectiveResults.Objective_Comment.Comment__c != null ||
                        objectiveResults.Objective_Comment.Recommendation__c != null) {
                        toUpdate.Add(objectiveResults.Objective_Comment);
                    }
                }
            }
        }
        upsert toUpdate;
        return basesave();
    }   
    
    public PageReference Finalize(){
        Action_Summary__c report = (Action_Summary__c)controller.getrecord();
        update report;
        List<Objective_Summary_Comment__c> toUpdate = new List<Objective_Summary_Comment__c>();
        for(ActionPlanWrapper plan: Plans){
            for(ActionPlanGoalWrapper goal: plan.ActionPlanGoals){
                for(objective_results_wrapper objectiveResults: goal.ActionPlanObjectives){
                    objectiveResults.Finalize();
                    toUpdate.Add(objectiveResults.Objective_Comment);
                }
            }
        }
        upsert toUpdate;
        return new PageReference('/apex/ActionSummaryApproval?id=' + report.id);
    }
}