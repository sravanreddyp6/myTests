public with sharing class Report_dischargeBacklogController {
    public List<Service_Assignment__c>servAssigns { get;set; }
    public Boolean displayResult{get ; set ;}
    
    
    public Report_dischargeBacklogController(){
        servAssigns = new List<Service_Assignment__c>();
        displayResult = false;
        
    }
    public pageReference runReport(){
        displayResult = True;
        servAssigns = [SELECT ID, Name,Admission__r.PerSon_Being_Served__r.Name,Alias__c,Status__c, Program_Detail__c,Start_Date__c, End_Date__c, SA_Closure_Status__c,(SELECT ID, Start_Time__c FROM Progress_Notes__r WHERE Start_Time__c <LAST_N_DAYS : 14 Order by Start_Time__c desc LIMIT 1),(SELECT Id,Status__c FROM Service_Assignment_Closures__r LIMIT 1  ) FROM Service_Assignment__c WHERE Status__c='Active' AND Model__c ='FCT' AND ID IN(SELECT Service_Assignment__c FROM Progress_note__c WHERE Start_Time__c <LAST_N_DAYS : 14)];
        return null;
    }
    public pageReference hideReport(){
        displayResult = False;
        servAssigns = new List<Service_Assignment__c>();
        PageReference pg = new PageReference('/apex/Home');
        return pg;
    }
    
    

}