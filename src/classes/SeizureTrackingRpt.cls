public with sharing class SeizureTrackingRpt {
    public Date startdt {get;set;}
    public Date enddt {get;set;} 
    public transient Integer totalDays {get;set;}
    public transient list<String> dayCount {get;set;}

    //Create a list of all the times 30 mins apart for a day
    public transient List<String> timeSlots {get;set;}
    //create a map to hold the count of seizures for a given timeSlot.
    public transient map<string, Integer> seizCount {get;set;}
    //get the seizures between the two dates
    public transient list<Seizure__c> seizures{get;set;}
    
    
    //http://salesforce.stackexchange.com/questions/42331/how-to-calculate-the-time-between-two-datetimes
    public SeizureTrackingRpt(){
    	startdt=null;
    	enddt =null;
        dayCount = new List<String>();
        timeSlots = new List<String>();
        seizCount = new map<string, Integer>();
        seizures = new List<Seizure__c>();
    }

    private String getKey(Datetime dt){
        String mn='';
        if (dt.minute() >= 30) {
        	mn = '30';
        } else {
            mn = '00';
        }
        return dt.day()+'-'+String.valueOf(dt.hour())+':'+mn;
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
    
    public void runreport(){
//        startdt = Date.today().toStartOfMonth();
//        enddt = startdt.addMonths(1);
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
        for (Integer d=1; d<=totalDays; d++) {
            dayCount.add(String.valueOf(d));
            for (String t : timeSlots) {
                seizCount.put(d+'-'+t, 0);
            }
        }
        
        
        this.seizures = [Select id,
                                       Service_Assignment__c,
                                       Start_DateTime__c,
                                       StartDate__c,
                                       End_DateTime__c, 
                                       Observed_By__c, 
                                       Comments__c
                                   from Seizure__c 
                                  where Duplicate_Entry__c = false
                                    And StartDate__c >= : startdt
                                    And StartDate__c < : enddt
                                  order by Start_DateTime__c];

        String key;
        Integer val;              
        for (Seizure__c seizure : seizures){
            key = getKey(seizure.Start_DateTime__c);
            val = seizCount.get(key);
            seizCount.put(key, ++val);
        }
    }

}