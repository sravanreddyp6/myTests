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
        
        List<Service_Assignment__c> SAResults = [ SELECT Id, phase__c, admission__r.state__c
         			from Service_Assignment__c where 
        					Start_Date__c >= :fStartDate  AND  
                            Start_Date__c <= :fEndDate  
                         ];
                       
        // create a map of the service assignments
        Map<Id, Service_Assignment__c> SAMap = new Map<ID, Service_Assignment__c>();
        for ( Service_Assignment__c s : SAResults) {
        	SAMap.put(s.id, s);
        }
                                              
        PNResults = [ SELECT 
        				service_assignment__c,
        				Person_Being_Served__r.Name pbsname,
           			 	Owner.Name ownname,
                      	Staff_Name__r.Name staffname,
         				sum(Total_Time__c) sum                     
                       FROM Progress_Note__c 
                       WHERE 
                         service_assignment__c in :SAResults
                         and disregard_note__c = false
                         and Start_time__c >= :fStartDate  AND  
                            Start_time__c <= :fEndDate
                        group by
                        	service_assignment__c,
                        	Person_Being_Served__r.Name,
                        	owner.name,
           			 		staff_name__r.name];
                                           
            StaffHrsInfo dataRow;
            Decimal phase = 0.0;
            Boolean bPseudo = false;
            Service_Assignment__c pSA;                                                                   
            for(AggregateResult pn : PNResults) {     
            	 dataRow = new StaffHrsInfo();
            	        	          
           
            	pSA = SAMap.get( (ID)pn.get('service_assignment__c'));        	            	
            	bPseudo =  	pSA.Admission__r.State__c == 'IN' ||                            
            				pSA.Admission__r.State__c == 'MA' ||
            	     		pSA.Admission__r.State__c == 'MD' ||
            	     		pSA.Admission__r.State__c == 'OH';
            	     		                                
                // if pseudo notes then Staff Name
            	
            	dataRow.clinician = (bPseudo && pn.get('staffname') != null) ? (String)pn.get('staffname') : (String)pn.get('ownname');
                dataRow.pbs = (String)pn.get('pbsname');
                
                Decimal totalMinutes = (Decimal)pn.get('sum'); 
                dataRow.totalMinutes = String.valueOf(totalMinutes.setscale(0));   
                dataRow.hours = String.valueOf((totalMinutes/60).setscale(2));
                phase  = SAMap.get( (ID)pn.get('service_assignment__c')).phase__c;
                     
                if (phase == 1.0) {
                    dataRow.phase = 'J';                
                }
                if (phase == 2.0) {
                    dataRow.phase = 'R';
                }
                if (phase == 3.0) {
                    dataRow.phase = 'VC'; 
                }
                if (phase == 4.0) {
                    dataRow.phase = 'G'; 
                }
                System.debug(dataRow);          
                listStaffHrsInfo.add(dataRow); 
                
                                                                                                                  
            }              
            listStaffHrsInfo.sort();                                                                                                                                 
            allCount = listStaffHrsInfo.size();
        
            fStartDate = null;
            fEndDate= null;
            return null; 
    }
    
    // Inner Class to store the row data detail of the report 
    public class StaffHrsInfo  implements comparable {
        public String clinician {get; set;}
        public String pbs {get; set;}
        public String phase {get; set;}
        public String totalMinutes {get; set;} 
        public String hours{get; set;}
        
        public Integer compareTo(Object compareTo) 
    	{
	        StaffHrsInfo s = (StaffHrsInfo) compareTo;
	        if (clinician == s.clinician ) {
	        	if ( pbs == s.pbs ) return 0;
	        	if ( pbs > s.pbs ) return 1;
	        	return -1;
	        }
	        if (clinician > s.clinician ) return 1;
	        return -1;        
    	}
    
    }   

}