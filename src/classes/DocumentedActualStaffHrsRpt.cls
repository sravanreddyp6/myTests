public with sharing class DocumentedActualStaffHrsRpt {

    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    
    public List<StaffHrsInfo> listStaffHrsInfo = new List<StaffHrsInfo>();
    public List<StaffHrsInfo> getListStaffHrsInfo(){return listStaffHrsInfo;}
        
    List<AggregateResult> PNResults = new List<AggregateResult>();            
        
    public DocumentedActualStaffHrsRpt () {
       //fStartDate = system.today();
       allCount = 0;
    } 
    
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
        
        PNResults.clear();
        listStaffHrsInfo.clear();                                                                                     
                                        
        PNResults = [ SELECT 
           			 	Owner.FirstName ofn,
           			 	Owner.LastName oln,
                      	Staff_Name__r.Name,
         				Person_Being_Served__r.FirstName pbsfn,
         				Person_Being_Served__r.LastName pbsln,
         				//Service_Assignment__r.Phase__c,         				
                       	SUM(Total_Time__c) sum                      
                       FROM Progress_Note__c 
                       WHERE 
                         (
                            ((Service_Assignment__r.Start_Date__c >= :fStartDate OR 
                              Service_Assignment__r.End_Date__c >= :fStartDate) 
                           AND  
                            (Service_Assignment__r.Start_Date__c <= :fEndDate OR 
                             Service_Assignment__r.End_Date__c <= :fEndDate) )                         
                           OR
                            (Service_Assignment__r.Start_Date__c  <= :fEndDate AND 
                             Service_Assignment__r.End_Date__c = null ) 
                         )
                       GROUP BY Owner.FirstName, Owner.LastName, Staff_Name__r.Name,
                                Person_Being_Served__r.FirstName, Person_Being_Served__r.LastName 
                    ];    
                                           
            StaffHrsInfo dataRow;
                                                                                           
            for(AggregateResult pn : PNResults) {     
            	 dataRow = new StaffHrsInfo();
            	        	            	
            	// if pseudo notes then Staff Name
            	/*if ((pn.Service_Assignment__r.Admission__r.State__c == 'IN' ||
            	     Service_Assignment__r.Admission__r.State__c == 'MA' ||
            	     Service_Assignment__r.Admission__r.State__c == 'MD' ||
            	     Service_Assignment__r.Admission__r.State__c == 'OH') && 
            	     pn.get('Staff_Name__r.Name') != null)
            	      dataRow.clinician = (String)pn.get('Staff_Name__r.Name');            	                  	    
            	else               	              	               	         
            	      dataRow.clinician = (String)pn.get('Owner.FirstName') + ' ' + (String)pn.get('Owner.FirstName');
                  
                Integer phase = (Integer)pn.get('Service_Assignment__r.Phase__c');                                  
                     
                if (phase == 1) {
                    dataRow.phase = 'J';                
                }
                if (phase == 2) {
                    dataRow.phase = 'R';
                }
                if (phase == 3) {
                    dataRow.phase = 'VC'; 
                }
                if (phase == 4) {
                    dataRow.phase = 'G'; 
                } */
                                                
                dataRow.clinician = (String)pn.get('ofn') + ' ' + (String)pn.get('oln');
                dataRow.pbs = (String)pn.get('pbsfn') + ' ' + (String)pn.get('pbsln');
                
                Decimal totalMinutes = (Decimal)pn.get('sum'); 
                dataRow.totalMinutes = String.valueOf(totalMinutes);   
                dataRow.hours = String.valueOf((totalMinutes/60).setscale(2));
                
                System.debug(dataRow);          
                listStaffHrsInfo.add(dataRow);                                                                                                   
            }                                                                                                                                               
            allCount = listStaffHrsInfo.size();
        
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