public with sharing class SeizureTrackingRpt {
    public Date startdt {get;set;}
    public Date enddt {get;set;}
    public Seizure__c servAssignFromSeiz {get;set;}
    
    public transient Integer totalDays {get;set;}
    public transient list<String> dayCount {get;set;}

    //Create a list of all the times 30 mins apart for a day
    public transient List<String> timeSlots {get;set;}
    //create a map to hold the count of seizures for a given timeSlot.
    public transient map<string, Integer> seizCount {get;set;}
    //get the seizures between the two dates
    public transient list<SeizureWrapper> seizures = new List<SeizureWrapper>();
    public list<SeizureWrapper> getSeizures(){
    	return this.seizures;
    }
    
    
    public SeizureTrackingRpt(){
    	startdt=null;
    	enddt =null;
    	servAssignFromSeiz = new Seizure__c();
        dayCount = new List<String>();
        timeSlots = new List<String>();
        seizCount = new map<string, Integer>();
    }

    private String getKey(Datetime dt){
        return dt.day()+'-'+getKey(dt.time());
    }
    private String getKey(Time dt){
        String mn='';
        if (dt.minute() >= 30) {
            mn = '30';
        } else {
            mn = '00';
        }
        return String.valueOf(dt.hour())+':'+mn;
    }

    public PageReference runreport(){
//        startdt = Date.today().toStartOfMonth();
//        enddt = startdt.addMonths(1);
        if (startdt == null || enddt == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Start Date and End Date can not be empty.'));
			return null;
        }

        totalDays = startdt.daysBetween(enddt);
        dayCount = new List<String>();

        timeSlots = new List<String>();
        Time tempTime = Time.newInstance(7,0,0,0);
        Integer i=0;
        while (i < 24*60 ){
            timeSlots.add(getKey(tempTime.addMinutes(i)));
            i+=30;
        }

        seizCount = new map<string, Integer>();
        for (Integer d=0; d<=totalDays; d++) {
            dayCount.add(String.valueOf(startdt.addDays(d).day() ));
            for (String t : timeSlots) {
                seizCount.put(String.valueOf(startdt.addDays(d).day() )+'-'+t, 0);
            }
        }
        
        
        List<Seizure__c> seizs = [Select id,
                                Service_Assignment__r.Name,
                                Start_DateTime__c,
                                StartDate__c,
                                End_DateTime__c, 
                                Observed_By__r.Name, 
                                Comments__c
                           from Seizure__c  where Duplicate_Entry__c = false
                                    And StartDate__c >= : startdt
                                    And StartDate__c <= : enddt
                                    And Service_Assignment__c = : servAssignFromSeiz.Service_Assignment__c
                                  order by Start_DateTime__c];
                                  
        this.seizures = new List<SeizureWrapper>();
        String key;
        Integer val;              
        for (Seizure__c seizure : seizs){
            key = getKey(seizure.Start_DateTime__c);
            val = seizCount.get(key);
            seizCount.put(key, ++val);
            seizures.add(new SeizureWrapper(seizure));
        }
        
        return null;
    }
    
    static String getTimeZoneValue(Datetime dt) {
            return dt.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString());
    }

    static String getDuration(Datetime startDt, Datetime endDt) {
            Long milliseconds = endDt.getTime() - startDt.getTime();
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            return String.valueOf(minutes); // +':'+String.valueOf(Math.mod(seconds, 60));
    }
    
    public class SeizureWrapper {
    	public String sa {get;set;}
    	public String startDateTime {get;set;}
        public String duration {get;set;}
        public String endDateTime {get;set;}
        public String observedBy {get;set;}
        public String comments {get;set;}
        
        SeizureWrapper(Seizure__c seizure){
        	this.sa= seizure.Service_Assignment__r.name;
        	this.startDateTime = SeizureTrackingRpt.getTimeZoneValue(seizure.Start_DateTime__c);
            this.endDateTime = SeizureTrackingRpt.getTimeZoneValue(seizure.End_DateTime__c);
            this.observedBy = seizure.Observed_By__r.Name;
            this.comments = seizure.Comments__c;
            this.duration = SeizureTrackingRpt.getDuration(seizure.Start_DateTime__c, seizure.End_DateTime__c);
        }
    }
}