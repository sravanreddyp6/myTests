public with sharing class IFCS_PBS_Count_Rpt_Ex {

/* @lastModified by Sravan 10/15/2014 for Shaun-46.
   transient keyword is added to the collections in order reduce the view State
*/

    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    
    transient public List<Service_Assignment__c> Results = new List<Service_Assignment__c>();
  //public List<Service_Assignment__c> getResults(){return Results;} Not needed to get results as results are not displayed on the page.
 
    transient public List<Service_Assignment__c> filteredResults {get; set;}
  //public List<Service_Assignment__c> getfilteredResults (){return filteredResults ;}
        
    public IFCS_PBS_Count_Rpt_Ex () {
       // fStartDate = system.today();
       allCount = 0;
    } 
    
    transient set<id> uniquePBS = new Set<id>();
    transient public integer allCount{get; set;}
    
    transient public Map<string, integer > ParsedData {get; set; }
  //public Map<string, integer > getParsedData(){return ParsedData;}
    
    public PageReference runReport(){
    if(fEndDate < fStartDate){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date must be before the End Date');//Same old drama 
        ApexPages.addMessage(myMsg);            
        return null;
    }
       // ParsedData.clear();
       // results.clear();
       // uniquePBS.clear();
       // filteredResults.clear();
        uniquePBS = new Set<id>();
        ParsedData = new Map<string, integer>();
        results = new List<Service_Assignment__c>();
        filteredResults = new List<Service_Assignment__c>();
        
        Results = [Select  id, 
                        Admission__r.State__c,
                        Admission__r.Person_Being_Served__r.id,
                        Start_Date__c,
                        End_Date__c
                        From Service_Assignment__c
                        Where
                        
                         (
                            ((Start_Date__c >= :fStartDate OR End_Date__c >= :fStartDate) 
                              AND  
                            (Start_Date__c <= :fEndDate OR End_Date__c <= :fEndDate) )                         
                       OR
                           (Start_Date__c  <= :fEndDate AND End_Date__c = null ) 
                         )
                            ];
    
        for(Service_Assignment__c SA: Results){
          //  List<Service_Assignment__c> tmpSA = new List<Service_Assignment__c>();
            ParsedData.put(SA.Admission__r.State__c, 0);
        }
        allCount = 0;
        for(Service_Assignment__c SA: Results){
            integer i = ParsedData.get(SA.Admission__r.State__c);            
            i +=1;
            if(!uniquePBS.contains(sa.Admission__r.Person_Being_Served__r.id)){
                ParsedData.put(SA.Admission__r.State__c, i);
                Allcount +=1;
                filteredResults.add(SA);
            }
            uniquePBS.add(sa.Admission__r.Person_Being_Served__r.id);
        }
        fStartDate = null;
        fEndDate= null;
        return null;
    }
}