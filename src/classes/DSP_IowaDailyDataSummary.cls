/*******************************************************************************
TODO:
Make objectiveToSkillResultMap, objectiveToBehaviorResultMap and objectiveToBehaviorResultWrapperMap
to work for one app.




***********************************************************************************/



public without sharing class DSP_IowaDailyDataSummary {
	
	public date serviceDate {get; set;}
    public Id sAId {get; set;}

    public pbsObjWrapper pbsWrap {get; set;} //for one app

    public list<TimeLog> timelogs {get;set;}
    
    public list<Action_Plan_Objective__c> skillObjectiveList {get;set;}
    public list<skillObjectiveWrapper> skillObjectiveWrapList {get;set;}
    public list<Action_Plan_Objective__c> behaviorObjectiveList {get;set;}
    public list<behaviorObjectiveWrapper> behaviorObjectiveWrapList {get;set;}
   //Skill Result Wrapper
   // public map<Id, list<Action_Skill_Result__c>> objectiveToSkillResultMap {get;set;}
    public map<id,list<ActionSkillResult>> objectiveToSkillResultWrapperMap {get; set;}
    
    public map<Id, list<Action_Behavior_Result__c>> objectiveToBehaviorResultMap {get;set;}
    public map<id, list<BehaviorResultWrapper>> objectiveToBehaviorResultWrapperMap {get;set;}

    public list<pNote> wrapperNotes{get;set;} //for one App
    
    public Boolean eSignComplete {get; set;}
    
    
    public without sharing class NoSharingRecord {
        public NoSharingRecord(){}
        public TMN_User__c getTmnAccess(){
            return [SELECT Id, Name, Professional_Title__c FROM TMN_User__c WHERE Salesforce_User_Account__c =: UserInfo.getUserId() limit 1];
        }
    }
    public String title {get {return (new NoSharingRecord()).getTmnAccess().Professional_Title__c ;} }
    
    public list<TimeStamp> timeStamps {get;set;}
    
    public DSP_IowaDailyDataSummary(){
    	eSignComplete = false;
        timelogs = new list<Timelog>();
       	wrapperNotes = new list<pNote>();
       	
        timeStamps = new list<TimeStamp>();
        timeStamps.add(new TimeStamp(Time.newInstance(8, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(9, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(10, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(11, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(12, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(13, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(14, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(15, 0, 0, 0)));
        timeStamps.add(new TimeStamp(Time.newInstance(16, 0, 0, 0)));
        
        //skillObjectiveList = new list<Action_Plan_Objective__c>();
        skillObjectiveWrapList = new List<skillObjectiveWrapper>();
        behaviorObjectiveList = new list<Action_Plan_Objective__c>();
        behaviorObjectiveWrapList = new List<behaviorObjectiveWrapper>();
        
       // objectiveToSkillResultMap = new map<Id, list<Action_Skill_Result__c>>();
        objectiveToSkillResultWrapperMap = new map<id, list<ActionskillResult>>();
        
        objectiveToBehaviorResultMap = new map<Id, list<Action_Behavior_Result__c>>();
        objectiveToBehaviorResultWrapperMap = new map<Id, list<BehaviorResultWrapper>>();
    
        this.sAId = ApexPages.CurrentPage().getParameters().get('saId');
        this.serviceDate = ApexPages.CurrentPage().getParameters().get('serviceDate')==null ? null : Date.parse(ApexPages.CurrentPage().getParameters().get('serviceDate'));
        
       
        TimeZone zone = UserInfo.getTimeZone();       
        datetime startDateTime = serviceDate;
        if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}
        datetime endDateTime = serviceDate;
        if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
        }
       
                    
        pbsWrap = new pbsObjWrapper([Select Name, Person_Being_Served__r.FirstName, Person_Being_Served__r.Middle_Name__c, Person_Being_Served__r.LastName, Person_Being_Served__r.Birthdate, Person_Being_Served__r.Medicaid_ID__c 
                    from Service_Assignment__c where id =: this.sAId]); //one app
        
        for (Evaluation_response__c log : [Select Start_Date_Time__c, End_Date_Time__c, CreatedById, tmn_user__r.Name, location__c, is_late_entry__c, service_type__c, Narrative_Note__c 
                    From Evaluation_response__c where Start_Date_time__c >=: startDateTime
                    AND End_date_time__c < : endDateTime
                    AND Service_Assignment__c =: this.sAId AND RecordType.DeveloperName = 'Time_Log' AND Disregard__c = false   
                    order BY start_Date_time__c, end_date_time__c] ) {
                    	if (log.Start_Date_Time__c.hour() >= 8 && log.End_Date_Time__c.hour() <= 16){
                    		 timelogs.add(new Timelog(log)); 
                    		 //timelogWraps.add(new timelogWrap(log)); 
                    	}  
        }

        for (Action_Skill_Result__c skillResult: [SELECT Attempts__c, Status__c, Met_Objective__c, Initials__c, Day__c, Action_Plan_Objective__c,
                                                           Action_Plan_Objective__r.Former_Id__c, Action_Plan_Objective__r.Type__c, Action_Plan_Objective__r.Status__c, Action_Plan_Objective__r.Description__c,
                                                           Action_Plan_Objective__r.CreatedDate, Action_Plan_Objective__r.Effective_Date__c, Action_Plan_Objective__r.Target_End_Date__c
                                                      FROM Action_Skill_Result__c
                                                     WHERE Action_Plan_Objective__r.action_plan_goal__r.action_plan__r.Service_Assignment__c =: sAId 
                                                       AND Day__c =: serviceDate
                                                     order By Action_Plan_Objective__c, Day__c]) {
           /* if (!objectiveToSkillResultMap.containsKey(skillResult.Action_Plan_Objective__c)) {
                    skillObjectiveList.add(new Action_Plan_Objective__c(Id = skillResult.Action_Plan_Objective__c, Type__c = skillResult.Action_Plan_Objective__r.Type__c, 
                                               Status__c = skillResult.Action_Plan_Objective__r.Status__c, Description__c = skillResult.Action_Plan_Objective__r.Description__c));
                   
                    skillObjectiveWrapList.add(new skillObjectiveWrapper( JSON.serialize(new Action_Plan_Objective__c(Id = skillResult.Action_Plan_Objective__c, Type__c = skillResult.Action_Plan_Objective__r.Type__c, 
                                               Status__c = skillResult.Action_Plan_Objective__r.Status__c, Description__c = skillResult.Action_Plan_Objective__r.Description__c))));
                                  
                    objectiveToSkillResultMap.put(skillResult.Action_Plan_Objective__c, new List<Action_Skill_Result__c>());
            }
            
            objectiveToSkillResultMap.get(skillResult.Action_Plan_Objective__c).add(skillResult);*/
            
            if (!objectiveToSkillResultWrapperMap.containsKey(skillResult.Action_Plan_Objective__c)) {
                   /* skillObjectiveList.add(new Action_Plan_Objective__c(Id = skillResult.Action_Plan_Objective__c, Type__c = skillResult.Action_Plan_Objective__r.Type__c, 
                                               Status__c = skillResult.Action_Plan_Objective__r.Status__c, Description__c = skillResult.Action_Plan_Objective__r.Description__c));*/
                   
                    skillObjectiveWrapList.add(new skillObjectiveWrapper( JSON.serialize(new Action_Plan_Objective__c(Id = skillResult.Action_Plan_Objective__c, Type__c = skillResult.Action_Plan_Objective__r.Type__c, 
                                               Status__c = skillResult.Action_Plan_Objective__r.Status__c, Description__c = skillResult.Action_Plan_Objective__r.Description__c))));
                                  
                    objectiveToSkillResultWrapperMap.put(skillResult.Action_Plan_Objective__c, new List<ActionSkillResult>());
            }
            
            objectiveToSkillResultWrapperMap.get(skillResult.Action_Plan_Objective__c).add(new ActionSkillResult(skillResult));
        }
        for (Action_Behavior_Result__c behaviorResult: [SELECT Day_time__c, Occurrences__c, Occurred__c, Action_Plan_Objective__c,
                                                               Action_Plan_Objective__r.Former_Id__c, Action_Plan_Objective__r.Type__c, Action_Plan_Objective__r.Status__c, Action_Plan_Objective__r.Description__c,
                                                               Action_Plan_Objective__r.CreatedDate, Action_Plan_Objective__r.Effective_Date__c, Action_Plan_Objective__r.Target_End_Date__c
                                                          FROM Action_Behavior_Result__c
                                                         WHERE Day_time__c <= : Datetime.newInstanceGMT(serviceDate, Time.newInstance(16, 0, 0, 0))
                                                           AND Day_time__c >= : Datetime.newInstanceGMT(serviceDate, Time.newInstance(8, 0, 0, 0))
                                                           AND Action_Plan_Objective__r.action_plan_goal__r.action_plan__r.Service_Assignment__c =: sAId
                                                         order By Action_Plan_Objective__c, Day_time__c]) {
            if (!objectiveToBehaviorResultMap.containsKey(behaviorResult.Action_Plan_Objective__c)) {
                    behaviorObjectiveList.add(new Action_Plan_Objective__c(Id = behaviorResult.Action_Plan_Objective__c, Type__c = behaviorResult.Action_Plan_Objective__r.Type__c, 
                                               Status__c = behaviorResult.Action_Plan_Objective__r.Status__c, Description__c = behaviorResult.Action_Plan_Objective__r.Description__c));
                    
                    
                    behaviorObjectiveWrapList.add(new behaviorObjectiveWrapper(JSON.serialize(new Action_Plan_Objective__c(Id = behaviorResult.Action_Plan_Objective__c, Type__c = behaviorResult.Action_Plan_Objective__r.Type__c, 
                                               Status__c = behaviorResult.Action_Plan_Objective__r.Status__c, Description__c = behaviorResult.Action_Plan_Objective__r.Description__c))));
                                               
                    objectiveToBehaviorResultMap.put(behaviorResult.Action_Plan_Objective__c, new List<Action_Behavior_Result__c>());
            }
            objectiveToBehaviorResultMap.get(behaviorResult.Action_Plan_Objective__c).add(behaviorResult);
        }
        for (Action_Plan_Objective__c key : behaviorObjectiveList){
            objectiveToBehaviorResultWrapperMap.put(key.id, new list<BehaviorResultWrapper>());
            for(TimeStamp t : timeStamps) {
                boolean timeTokenAdded = false;
                for(Action_Behavior_Result__c res : objectiveToBehaviorResultMap.get(key.id)){
                    if (res.Day_time__c.addSeconds(zone.getOffset(res.Day_time__c)/1000*-1).time() ==  t.token ){
                        objectiveToBehaviorResultWrapperMap.get(key.id).add(new BehaviorResultWrapper(t.getLabel(),res));
                        timeTokenAdded = true;
                        break;
                    }
                }        
                if (!timeTokenAdded) objectiveToBehaviorResultWrapperMap.get(key.id).add(new BehaviorResultWrapper(t.getLabel(),new Action_Behavior_Result__c()));
            }
        }
           
      	for(Progress_Note__c note: [select name, id, Start_Time__c, End_time__c, Narrative__c,  createddate, createdby.name, Late_Entry__c, Approval_Status__c 
                  from Progress_Note__c where Service_Assignment__c =: this.sAId
                   AND Start_Time__c >=:  startDateTime
                   AND End_time__c <= : endDateTime
                   AND Disregard_Note__c = false order by Start_Time__c, End_time__c]){
                   	
      		wrapperNotes.add(new pNote(JSON.serialize(note))); //one app
      	}
    }
    
    
  /*  public class BehaviorResultWrapper {
        public Action_Behavior_Result__c result {get;set;}
        public String timeLabel {get;set;}
        
        public BehaviorResultWrapper(String timeLabel, Action_Behavior_Result__c result){
            this.result = result;
            this.timeLabel = timeLabel;
        }
    } */
   
    public class BehaviorResultWrapper {
       // public Action_Behavior_Result__c result {get;set;}
       	public boolean occurred {get;set;}
       	public decimal occurrences {get; set;}
        public String timeLabel {get;set;}
        
        public BehaviorResultWrapper(String timeLabel, Action_Behavior_Result__c result){
            //this.result = result;
            this.occurred = result.Occurred__c;
            this.occurrences = result.Occurrences__c;
            this.timeLabel = timeLabel;
        }
    } 
   
    public class TimeStamp {
        public Time token {get;set;}
        public String getLabel(){
            return convertToAmPmNoon(DateTime.newInstance(Date.today(), this.token));
        }
        
        public TimeStamp(Time token){
            this.token = token;
        }       
    } 
    

    public static string convertToAmPmNoon(DateTime dt){
            String[] parts = dt.format().split(' ');
            return (parts.size() == 3) ? (parts[1] + ' ' + parts[2]) : parts[1];
    }
            
    public class TimeLog{
        public Evaluation_response__c timeLog {get; set;}
        public String getStartTime(){
            return convertToAmPmNoon(this.timeLog.Start_Date_Time__c);
        }
        public String getEndTime(){
            return convertToAmPmNoon(this.timeLog.End_Date_Time__c);
        }
        public TimeLog(Evaluation_response__c log){
            this.timeLog = log;
        }
    }
    
    //-------------------------------------------------------for One App Version ---------------------------
 /*   public class timelogWrap{
    	public string 	startTime 		{get;set;}
    	public string 	endTime 		{get;set;}
    	public string 	location 		{get;set;}
    	public string 	accompaniedBy 	{get;set;}
    	public string 	serviceType 	{get;set;}
    	public string 	narrativeNote 	{get;set;}
    	public boolean 	lateEntry		{get;set;}
    	
    	public timelogWrap(Evaluation_response__c e){
		this.startTime 		 	 = 		convertToAmPmNoon(e.Start_Date_Time__c);
    		this.endTime   		 = 		convertToAmPmNoon(e.End_Date_Time__c);
    		this.location  		 = 		e.location__c;
    		this.accompaniedBy 	 = 		e.tmn_user__r.Name;
    		this.serviceType 	 = 		e.service_type__c;
    		this.narrativeNote	 = 		e.Narrative_Note__c;
    		this.lateEntry		 = 		e.is_late_entry__c;
    	}
    }*/
    
    public class pbsObjWrapper{ 
    	public string saName 		{get;set;}
    	public string pbsFName		{get;set;}
    	public string pbsMName 		{get;set;}
    	public string pbsLName 		{get;set;}
    	public Date   pbsBdate 	  	{get;set;}
    	public string pbsMedicaid 	{get;set;}
    	
    	public pbsObjWrapper(Service_Assignment__c sa){
    		this.saName 		= 	sa.Name;
    		this.pbsFName 		= 	sa.Person_Being_Served__r.FirstName;
    		this.pbsMName 		= 	sa.Person_Being_Served__r.Middle_Name__c;
    		this.pbsLName 		= 	sa.Person_Being_Served__r.LastName;
    		this.pbsBdate 		= 	sa.Person_Being_Served__r.Birthdate;
    		this.pbsMedicaid 	= 	sa.Person_Being_Served__r.Medicaid_ID__c;
    	}
    	
    }
    
    public class pNote{
    	public Map<string, object> getPnMap(){
    		return DSP_IowaDailyDataSummary.updateMapWithRelationshipKeys(new Map<string,object>(), this.pnString, '');
    	}
    	public string pnString;
    	public pNote(string pnString){
    		this.pnString = pnString;
    	}
    }
    
    public class skillObjectiveWrapper{
		public Map<string,object> getskillMap(){
			return DSP_IowaDailyDataSummary.updateMapWithRelationshipKeys(new Map<string,object>(), this.skillString, '');
		}
		public string skillString;
    	public skillObjectiveWrapper(string skillString){
    		this.skillString = skillString;
    	}
    }
    
    public class behaviorObjectiveWrapper{
		public Map<string,object> getbehaviorMap(){
			return DSP_IowaDailyDataSummary.updateMapWithRelationshipKeys(new Map<string,object>(), this.behaviorString, '');
		}
		public string behaviorString;
    	public behaviorObjectiveWrapper(string behaviorString){
    		this.behaviorString = behaviorString;
    	}
    }
    
    public class ActionSkillResult{
    	public decimal attempts {get;set;}
    	public string status {get; set;}
    	public string metObjective {get;set;}
    	public string initials {get;set;}
    	
    	public ActionSkillResult(Action_Skill_Result__c askr){
    		this.attempts = askr.Attempts__c;
    		this.status = askr.Status__c;
    		this.metObjective = askr.Met_Objective__c;
    		this.initials = askr.Initials__c;
    		
    	}
    }
    
    //Process Salesforce records to remove the Attributes and hence field level security is avoided
    static Map<string,Object> updateMapWithRelationshipKeys(Map<string,object> m, String jsonString, String relationshipKey){
        Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Map<String, Object> newMap = new Map<String, Object>(); 
        for(String k : temp.keySet()){
            if(k.endsWithIgnoreCase('__r') || k == 'LastModifiedBy' || k == 'CreatedBy'){
                updateMapWithRelationshipKeys(m,JSON.serialize(temp.get(k)), k);
            } 
            else {
                if (String.IsBlank(relationshipKey) ) {
                    newMap.put(k, temp.get(k));
                }
                else {    
                    newMap.put(relationshipKey + '.' + k,  temp.get(k));
                }
            }
        }
        m.putAll(newMap);
        m.remove(String.IsBlank(relationshipKey) ? 'attributes' : relationshipKey + '.attributes'); // this is to remove this key, SF adds this when serializing the sObject.
    	return m;
    }
 //------------------------------------------------end One App version------------------------------
    
}