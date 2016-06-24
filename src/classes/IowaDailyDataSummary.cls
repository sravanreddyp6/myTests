public virtual with sharing class IowaDailyDataSummary {
    public date serviceDate {get; set;}
    public Id sAId {get; set;}

    public Service_Assignment__c pbsObj {get; set;}  

    public list<TimeLog> timelogs {get;set;}
    
    public list<Action_Plan_Objective__c> skillObjectiveList {get;set;}
    public list<Action_Plan_Objective__c> behaviorObjectiveList {get;set;}
    public map<Id, list<Action_Skill_Result__c>> objectiveToSkillResultMap {get;set;}
    public map<Id, list<Action_Behavior_Result__c>> objectiveToBehaviorResultMap {get;set;}
    public map<id, list<BehaviorResultWrapper>> objectiveToBehaviorResultWrapperMap {get;set;}

    public list<Progress_Note__c> notes {get;set;}
    public Boolean eSignComplete {get; set;}
    
    
    public without sharing class NoSharingRecord {
        public NoSharingRecord(){}
        public TMN_User__c getTmnAccess(){
            return [SELECT Id, Name, Professional_Title__c FROM TMN_User__c WHERE Salesforce_User_Account__c =: UserInfo.getUserId() limit 1];
        }
    }
    public String title {get {return (new NoSharingRecord()).getTmnAccess().Professional_Title__c ;} }
    
    public list<TimeStamp> timeStamps {get;set;}
    
    public IowaDailyDataSummary(){
    	eSignComplete = false;
    	
        timelogs = new list<Timelog>();
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
        
        skillObjectiveList = new list<Action_Plan_Objective__c>();
        behaviorObjectiveList = new list<Action_Plan_Objective__c>();
        objectiveToSkillResultMap = new map<Id, list<Action_Skill_Result__c>>();
        objectiveToBehaviorResultMap = new map<Id, list<Action_Behavior_Result__c>>();
        objectiveToBehaviorResultWrapperMap = new map<Id, list<BehaviorResultWrapper>>();
    
        this.sAId = ApexPages.CurrentPage().getParameters().get('saId');
        this.serviceDate = Date.parse(ApexPages.CurrentPage().getParameters().get('serviceDate'));
        
       
        TimeZone zone = UserInfo.getTimeZone();       
        datetime startDateTime = serviceDate;
        if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}
        datetime endDateTime = serviceDate;
        if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
        }
       
        pbsObj = [Select Name, Person_Being_Served__r.FirstName, Person_Being_Served__r.Middle_Name__c, Person_Being_Served__r.LastName, Person_Being_Served__r.Birthdate, Person_Being_Served__r.Medicaid_ID__c 
                    from Service_Assignment__c where id =: this.sAId];
        for (Evaluation_response__c log : [Select Start_Date_Time__c, End_Date_Time__c, CreatedById, tmn_user__r.Name, location__c, is_late_entry__c, service_type__c, Narrative_Note__c 
                    From Evaluation_response__c where Start_Date_time__c >=: startDateTime
                    AND End_date_time__c < : endDateTime
                    AND Service_Assignment__c =: this.sAId AND RecordType.DeveloperName = 'Time_Log' AND Disregard__c = false   
                    order BY start_Date_time__c, end_date_time__c] ) {
                    	if (log.Start_Date_Time__c.hour() >= 8 && log.End_Date_Time__c.hour() <= 16) timelogs.add(new Timelog(log));    
        }

        for (Action_Skill_Result__c skillResult: [SELECT Attempts__c, Status__c, Met_Objective__c, Initials__c, Day__c, Action_Plan_Objective__c,
                                                           Action_Plan_Objective__r.Former_Id__c, Action_Plan_Objective__r.Type__c, Action_Plan_Objective__r.Status__c, Action_Plan_Objective__r.Description__c,
                                                           Action_Plan_Objective__r.CreatedDate, Action_Plan_Objective__r.Effective_Date__c, Action_Plan_Objective__r.Target_End_Date__c
                                                      FROM Action_Skill_Result__c
                                                     WHERE Action_Plan_Objective__r.action_plan_goal__r.action_plan__r.Service_Assignment__c =: sAId 
                                                       AND Day__c =: serviceDate
                                                     order By Action_Plan_Objective__c, Day__c]) {
            if (!objectiveToSkillResultMap.containsKey(skillResult.Action_Plan_Objective__c)) {
                    skillObjectiveList.add(new Action_Plan_Objective__c(Id = skillResult.Action_Plan_Objective__c, Type__c = skillResult.Action_Plan_Objective__r.Type__c, 
                                               Status__c = skillResult.Action_Plan_Objective__r.Status__c, Description__c = skillResult.Action_Plan_Objective__r.Description__c));
                    objectiveToSkillResultMap.put(skillResult.Action_Plan_Objective__c, new List<Action_Skill_Result__c>());
            }
            objectiveToSkillResultMap.get(skillResult.Action_Plan_Objective__c).add(skillResult);
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

        notes = [select name, id, Start_Time__c, End_time__c, Narrative__c,  createddate, createdby.name, Late_Entry__c, Approval_Status__c 
                  from Progress_Note__c where Service_Assignment__c =: this.sAId
                   AND Start_Time__c >=:  startDateTime
                   AND End_time__c <= : endDateTime
                   AND Disregard_Note__c = false order by Start_Time__c, End_time__c];
    }
    
    public PageReference prepareForPDF(){
    	return null;
    }
    
    public virtual PageReference exportToPDF(){
        PageReference pdf = Page.IowaDailyDataSummaryPDF;
        String file = pbsObj.Person_Being_Served__r.FirstName + ' ' + pbsObj.Person_Being_Served__r.LastName + ' - ' + String.valueOf(serviceDate).replace('-','') +  '.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        pdf.getHeaders().put('content-disposition', 'attachment; filename="'+file+'"');
        return pdf;
    }
    
    public class BehaviorResultWrapper {
        public Action_Behavior_Result__c result {get;set;}
        public String timeLabel {get;set;}
        
        public BehaviorResultWrapper(String timeLabel, Action_Behavior_Result__c result){
            this.result = result;
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
}