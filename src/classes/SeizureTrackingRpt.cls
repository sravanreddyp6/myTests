public with sharing class SeizureTrackingRpt {
	public String startdtStr {get;set;}
    public Date startdt {get;set;}
    private Date enddt {get;set;}
    public Boolean seizureResExcel { get; set; }

    //public Seizure__c servAssignFromSeiz {get;set;}
    public String servAssign {get;set;}
    public Service_Assignment__c SA {get; private set;}
    
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
    
    private map<String, Integer> integerMonth = new map<String, Integer>();
    
    public SeizureTrackingRpt(){
    	startdtStr = '';
    	startdt=null;
    	enddt =null;
    	//servAssignFromSeiz = new Seizure__c();
        dayCount = new List<String>();
        timeSlots = new List<String>();
        seizCount = new map<string, Integer>();
        servAssign = ApexPages.currentPage().getParameters().get('saId');
        
        if( servAssign != null && servAssign != '') {
            SA = [SELECT Id, Name, Admission__c, admission__r.Person_Being_Served__c, admission__r.Person_Being_Served__r.name FROM Service_Assignment__c WHERE Id=:servAssign limit 1];
        }
        
        integerMonth.put('January',1);
        integerMonth.put('February',2);
        integerMonth.put('March',3);
        integerMonth.put('April',4);
        integerMonth.put('May',5);
        integerMonth.put('June',6);
        integerMonth.put('July',7);
        integerMonth.put('August',8);
        integerMonth.put('September',9);
        integerMonth.put('October',10);
        integerMonth.put('November',11);
        integerMonth.put('December',12);
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
        seizureResExcel = true;
    	
        try {
            startdt = Date.newInstance(Integer.valueOf(startdtStr.substring(startdtStr.length() - 4)), integerMonth.get(startdtStr.substring(0, startdtStr.length() - 5) ), 1);
            enddt = startdt.addMonths(1);
        }  catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid month/year.'));
            return null;
        }

        
        if (servAssign == null || servAssign == '') {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Service Assigment is required.'));
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
        for (Integer d=0; d<totalDays; d++) {
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
                                    // And Service_Assignment__c = : servAssignFromSeiz.Service_Assignment__c
                                    And Service_Assignment__c = : servAssign
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
    
    public pageReference export(){
        runreport();
        PageReference pg = new PageReference('/apex/SeizureTrackingRptExcel');
        pg.getHeaders().put('content-disposition', 'attachment;');
        pg.setRedirect(false);
        return pg;
    }
    
    static String getTimeZoneValue(Datetime dt) {
            return dt.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString());
    }

    static String getDuration(Datetime startDt, Datetime endDt) {
            Long milliseconds = endDt.getTime() - startDt.getTime();
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            return String.valueOf(minutes) +':'+ String.valueOf(Math.mod(seconds, 60));
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