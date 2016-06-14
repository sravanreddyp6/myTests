public with sharing class OhioDailyDataSummary extends IowaDailyDataSummary {
    public list<ServiceTrackingList.ServiceObj> serviceTrakingResults {get; set;}

    public OhioDailyDataSummary(){
        super();
        // Service tracking data for the RW OH, OH-13
        map<String, ServiceTrackingList.ServiceObj> serDetails = new map<String, ServiceTrackingList.ServiceObj>(); 
        for(Action_Objective_Result__c objectiveResult : [SELECT   Id, Name, RecordTypeId, createdById, CreatedDate, Action_Plan_Objective__c, 
                                                                   Service_Provided__c, Status__c, Reason__c, Initials__c, Service_Time__c, Service_Date_Part__c,
                                                                   Action_Plan_Objective__r.Action_Plan_Goal__r.Action_Plan__c, Action_Plan_Objective__r.Type__c, 
                                                                   Action_Plan_Objective__r.Status__c, Action_Plan_Objective__r.Description__c,
                                                                   Action_Plan_Objective__r.effective_Date__c, Action_Plan_Objective__r.Target_end_date__c
                                                              FROM Action_Objective_Result__c
                                                             WHERE RecordType.Name = 'Service_Objective'
                                                               AND Action_Plan_Objective__r.type__c IN ('Yes/No', 'Yes/No w/time')
                                                               AND Action_Plan_Objective__r.action_plan_goal__r.action_plan__r.Service_Assignment__c =: sAId
                                                               AND Service_Date_Part__c =: serviceDate
                                                             order BY Service_Date_Part__c nulls last, Service_Time__c nulls last]){
            if (! serDetails.containsKey(String.ValueOf(objectiveResult.Action_Plan_Objective__c))) 
               serDetails.put(String.ValueOf(objectiveResult.Action_Plan_Objective__c), 
                              new ServiceTrackingList.ServiceObj(new Action_Plan_Objective__c(  Id = objectiveResult.Action_Plan_Objective__c, 
                                                                                                Description__c = objectiveResult.Action_Plan_Objective__r.Description__c, 
                                                                                                Type__c = objectiveResult.Action_Plan_Objective__r.Type__c, 
                                                                                                Status__c = objectiveResult.Action_Plan_Objective__r.Status__c, 
                                                                                                effective_Date__c = objectiveResult.Action_Plan_Objective__r.effective_Date__c, 
                                                                                                Target_end_date__c = objectiveResult.Action_Plan_Objective__r.Target_end_date__c
                                                                                             ) 
                                                                )
                            );
               
            ServiceTrackingList.ServiceObj service = serDetails.get(String.ValueOf(objectiveResult.Action_Plan_Objective__c));
            service.trackingResults.add(new ServiceTracking.ObjResultWrapper(objectiveResult));
        }        
        for (ServiceTrackingList.ServiceObj ser : serDetails.values()){
            ser.trackingResults.sort();
        }
        this.serviceTrakingResults = new list<ServiceTrackingList.ServiceObj>();
        this.serviceTrakingResults.addAll(serDetails.values());        
    }
    
    public override PageReference exportToPDF(){
        PageReference pdf = Page.OhioDailyDataSummaryPDF;
        String file = pbsObj.Person_Being_Served__r.FirstName + ' ' + pbsObj.Person_Being_Served__r.LastName + ' - ' + String.valueOf(serviceDate).replace('-','') +  '.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        pdf.getHeaders().put('content-disposition', 'attachment; filename="'+file+'"');
        return pdf;
    }
}