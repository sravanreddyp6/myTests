public with sharing class IFCS_Active_MoreThanSixMonths_RPT_EX {
    public Date fStartDate{get{return fStartDate;} set;}
    public List<Service_Assignment__c> Results = new List<Service_Assignment__c>();
    public List<Service_Assignment__c> getResults(){
        
        
        return Results;
    
    }

    public IFCS_Active_MoreThanSixMonths_RPT_EX() {
       // fStartDate = system.today();
    }
    public PageReference runReport(){
        
        Date SixMonth = fStartDate.addDays(-180);
        Results = [Select  id, 
                        Admission__r.Person_Being_Served__r.FirstName, 
                        Admission__r.Person_Being_Served__r.LastName, 
                        Program__c,
                        Admission__r.Effective_Date__c,
                        Start_Date__c,
                        Location_Region__c
                        From Service_Assignment__c
                        Where Program__c='IFCS'
                         AND
                        Start_Date__c <= :SixMonth
                         AND
                        Status__c = 'Active'];
    
        return null;
    }


}