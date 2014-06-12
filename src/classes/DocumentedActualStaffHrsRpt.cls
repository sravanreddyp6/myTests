public with sharing class DocumentedActualStaffHrsRpt {

    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    
    public List<Service_Assignment__c> Results = new List<Service_Assignment__c>();
    public List<Service_Assignment__c> getResults(){return Results;}
    
    public List<Progress_Note__c> PNResults = new List<Progress_Note__c>();
    public List<Progress_Note__c> getPNResults(){return PNResults;}
 
    public List<Service_Assignment__c> filteredResults = new List<Service_Assignment__c>();
    public List<Service_Assignment__c> getfilteredResults (){return filteredResults ;}
    
    public List<StaffHrsInfo> listStaffHrsInfo = new List<StaffHrsInfo>();
    public List<StaffHrsInfo> getListStaffHrsInfo(){return listStaffHrsInfo;}
        
    public DocumentedActualStaffHrsRpt () {
       // fStartDate = system.today();
       allCount = 0;
    } 
    
    set<id> uniquePBS = new Set<id>();
    public integer allCount{get; set;}
    
    public Map<string, integer > ParsedData = new Map<string, integer >();    
    public Map<string, integer > getParsedData(){return ParsedData;}
    
    public PageReference runReport(){
        if(fEndDate < fStartDate){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date must be before the End Date');//Same old drama 
            ApexPages.addMessage(myMsg);            
            return null;
        }
        
        ParsedData.clear();
        results.clear();
        uniquePBS.clear();
        filteredResults.clear();
        
        Results = [Select  id,     
                        Admission__r.Person_Being_Served__r.FirstName, 
                        Admission__r.Person_Being_Served__r.LastName,
                        Phase__c,                        
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

        integer index = 0;					                            
        for(Service_Assignment__c SA: Results){                            
            StaffHrsInfo dataRow = new StaffHrsInfo();
                                    
            PNResults = [Select  id,     
                        First_Name__c, 
                        Last_Name__c,
                        Start_Time__c,
                        End_Time__c
                        From Progress_Note__c Where Service_Assignment__c = :SA.id
                   ]; 
                        
            for(Progress_Note__c pn: PNResults){ 
                dataRow.clinician =  pn.First_Name__c+' '+pn.Last_Name__c;
                long totalMinutes = ((pn.End_Time__c.getTime() - pn.Start_Time__c.getTime())/1000)/60;
            
                dataRow.totalMinutes = String.valueOf(totalMinutes);
                dataRow.hours = String.valueOf(totalMinutes/60);            
                dataRow.pbs = SA.Admission__r.Person_Being_Served__r.FirstName+' '+SA.Admission__r.Person_Being_Served__r.LastName;                                 
                     
                if (SA.Phase__c == 1) {
                    dataRow.phase = 'J';                
                }
                if (SA.Phase__c == 2) {
                    dataRow.phase = 'R';
                }
                if (SA.Phase__c == 3) {
                    dataRow.phase = 'VC'; 
                }
                if (SA.Phase__c == 4) {
                    dataRow.phase = 'G'; 
                }
                                  
                listStaffHrsInfo.add(dataRow);
            }                                                                                                                                       
        }
        allCount = 0;
        
        for(Service_Assignment__c SA: Results){
            //integer i = ParsedData.get(SA.Admission__r.State__c);            
            //i +=1;
            if(!uniquePBS.contains(sa.Admission__r.Person_Being_Served__r.id)){
                //ParsedData.put(SA.Admission__r.State__c, i);
                Allcount +=1;
                filteredResults.add(SA);
            }
            uniquePBS.add(sa.Admission__r.Person_Being_Served__r.id);
        }
        fStartDate = null;
        fEndDate= null;
        return null; 
    }
    
    // Inner Class to store the row data detail of the report 
    public class StaffHrsInfo {
        public String clinician {get; set;}
        public String pbs {get; set;}
        public String phase {get; set;}
        public String totalMinutes {get; set;} 
        public String hours{get; set;}
    }   

}