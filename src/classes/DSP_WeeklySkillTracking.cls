public without sharing class DSP_WeeklySkillTracking {

	public Date startdate { get; set; } 
    public Action_Plan_Worksheet__c result;
    public List<DSPObjectiveWrapper> objectivesMap;
    public boolean hasError = false;
    public ID APId { get; private set;}
    public List<SelectOption> prompts { get; private set;}
    public List<SelectOption> metlist { get; private set;}
    public ID wsID { get; set; }
    
    public DSP_WeeklySkillTracking( TxnQueueResponseController c)
    {
    
    	
    	prompts = new List<SelectOption> {
    		new SelectOption('','--None--'),
        	new SelectOption('I','I'),
        	new SelectOption('V', 'V'),
        	new SelectOption('M','M'),
        	new SelectOption('PP','PP'),
        	new SelectOption('FP','FP'),
        	new SelectOption('D','D'),
        	new SelectOption('L','L'),
        	new SelectOption('S','S'),
        	new SelectOption('H','H'),
        	new SelectOption('HL','HL')
        	};
        	
	    metlist = new List<SelectOption> { 
    		new SelectOption('','--None--'),
        	new SelectOption('Y','Y'),
        	new SelectOption('N', 'N')
        };   
        
        wsID = c.skillResponse.wsID;    
    }
    
    public DSP_WeeklySkillTracking( ID wsID) {
    	
        result = [select Name, Start_Date__c, Action_Plan__c, action_Plan__r.Status__c,        
                     Action_Plan__r.Service_Assignment__r.Admission__r.State__c, Action_Plan__r.Service_Assignment__c, 
                     Action_Plan__r.Service_Assignment__r.Admission__c, Action_Plan__r.Service_Assignment__r.Admission__r.Person_Being_Served__c 
                    from Action_Plan_Worksheet__c
                    where Id = :wsId];
                    
        if ( result != null ) {            
        	APId = result.action_plan__c;
        	startdate = result.start_date__c;
        	this.wsID = wsID;
        	getObjectivesMap();
        }
        
        
    }
    
    public List<Date> getDaysOfWeek() {
        List<Date> week = new List<Date>();
        week.Add(result.Start_Date__c);
        week.Add(result.Start_Date__c+1);
        week.Add(result.Start_Date__c + 2);
        week.Add(result.Start_Date__c + 3);
        week.Add(result.Start_Date__c + 4);
        week.Add(result.Start_Date__c + 5);
        week.Add(result.Start_Date__c + 6);
        return week;
    }
    
    
    public List<DSPObjectiveWrapper>  getObjectivesMap(){
        if (objectivesmap == null){
            objectivesMap = calcObjectivesMap();
        }
        return objectivesMap;
    }
    
    public boolean editable { get { return !result.Action_plan__r.Status__c.contains('Inactive');}}
    
    private List<DSPObjectiveWrapper>  calcObjectivesMap(){
        Date firstDay = result.Start_Date__c;
        List<Action_Plan_Objective__c> objectives = ReportableSkillObjectives(firstDay);
        List<DSPObjectiveWrapper> out = new List<DSPObjectiveWrapper>();
         
         for(Action_Plan_Objective__c objective:objectives){
             //Map<Date, Action_Skill_Result__c> dayResult = new Map<Date, Action_Skill_Result__c>();
             Map<Date, ASRWrapper> dayResult = new Map<Date, ASRWRapper>();
             
             for(Action_Skill_Result__c result: objective.Action_Skill_Results__r){
             	 ASRWrapper asr = new ASRWrapper( result );
                 dayResult.Put(result.Day__c, asr);
             }
             for(Date day : getDaysOfWeek()){
                 if ((!dayResult.ContainsKey(day))){
                     ASRWrapper blankResult = new ASRWrapper();
                     blankResult.oid = objective.Id;
                     
                     // this is a bit of a hack but need a simple way to tell the page to not render these guys
                     blankResult.Day = DateValidForObjectiveAndPlan(day, objective) ? day : Date.Parse('1/1/2000');
                     dayResult.Put(day, blankResult);
                 }
             }
             DSPObjectiveWrapper wrapper = new DSPObjectiveWrapper(objective);
             wrapper.ResultsMap = dayResult;
             out.Add(wrapper);
         }
         return out;
    }

    private List<Action_Plan_Objective__c> ReportableSkillObjectives(Date firstDay){
        return [ select Description__c, effective_Date__c, Target_end_date__c, 
                        (select action_plan_objective__c, Day__c, Attempts__c, Initials__c, Met_Objective__c, Status__c
                           from Action_Skill_Results__r
                          where Day__c >= :firstDay 
                            and Day__c < :firstDay + 7
                          order by Day__c)
                   from  Action_Plan_Objective__c
                  where Action_Plan_Goal__r.Action_Plan__c = :result.Action_Plan__c
                    and ((effective_date__c < :firstDay + 7) or (effective_date__c = null))
                    and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
                    and Type__c = 'Skill'
                    and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
                  order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
    }
    
    public boolean DateValidForObjectiveAndPlan(Date day,/* Action_Plan__c plan,*/ Action_Plan_Objective__c objective){
        return /*(plan.Effective_Date__c = null || day >= plan.Effective_Date__c ) && */
                ((objective.Effective_Date__c == null) || (day >= objective.Effective_Date__c)) &&
               /* (plan.Target_Date__c= null || day <= plan.Target_Date__c) &&  */
                ((objective.Target_End_Date__c == null) || (day <= objective.Target_End_Date__c));
    }
    
    public class DSPObjectiveWrapper {
    	public APOWrapper objective { get; set; }
    	public Map<Date, ASRWrapper> ResultsMap { get; set; }
    	
    	public DSPObjectiveWrapper ( Action_Plan_Objective__c obj ) {
    		objective = new APOWrapper(obj);
    	}
    	
    }
    
    public Class APOWrapper  {
    	
    	public ID id { get; set; }
    	public string Description { get; set; }
    	
    	public APOWrapper ( Action_Plan_Objective__c apo ) {
    		id = apo.id;
    		description = apo.description__c;
    	}
    	
    }
    
    Public class ASRWrapper {
    	
    	public ID oid { get; set; }
    	public ID id { get; set; }
    	public Decimal attempts { get; set;  }
    	public String status { get; set; }
    	public String met { get; set; }
    	public string initials { get; set; }
    	public date day { get; set; }
    	public ASRWrapper () {
    	}	
    	public ASRWrapper ( Action_Skill_Result__c asr ) {
    		oid = asr.action_plan_objective__c;
    		id = asr.id;
    		attempts = asr.attempts__c;
    		status = asr.status__c;
    		met = asr.met_objective__c;
    		initials = asr.initials__c;
    		day = asr.day__c;
    	}
    	
    }


}