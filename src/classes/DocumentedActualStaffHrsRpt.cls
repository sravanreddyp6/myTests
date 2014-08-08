public with sharing class DocumentedActualStaffHrsRpt {

    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    
    public List<StaffHrsInfo> listStaffHrsInfo = new List<StaffHrsInfo>();
    public List<StaffHrsInfo> getListStaffHrsInfo(){return listStaffHrsInfo;}
        
    List<AggregateResult> PNResults = new List<AggregateResult>();            
        
    public DocumentedActualStaffHrsRpt () {
       //fStartDate = system.today();
       allCount = 0;
       
       getStateList();
       getProgramList();
       selStates = new List<String>();
       selPrograms = new List<String>();
       
    } 
    
    private List<SelectOption> getStateList() {
    	
    	states = new List<selectoption>();
    	List<AggregateResult> statelist = [ select state__c, count(id) from service_location__c where state__c <> '' group by state__c order by state__c ];
    	string statecode = '';
    	
    	// look up in custom settings table to get state name
    	
    	for (AggregateResult ag : statelist )
    	{
    	    statecode = (string)ag.get('state__c');
    		states.Add( new selectOption( statecode, statecode) ) ;
    	}
    
    	return states;
    }
    
     private List<SelectOption> getProgramList() {
    	
    	programs = new List<selectoption>();
    	List<Service_Location__c> proglist = [ select program__c from service_location__c order by program__c ];
    	
    	
    	for (Service_Location__c sl : proglist )
    	{
    	    
    		programs.Add( new selectOption( sl.Program__c, sl.program__c) ) ;
    	}
    	
    	
    	return programs;
    }
    
    public integer allCount{get; set;}
    public List<SelectOption> states { get;set; }
    public List<SelectOption> programs { get; set; }
    public List<String> selStates {get; set;}
    public List<String> selPrograms {get; set;}
    public string uiselStates { get; set;}
    public string uiselProgs { get; set; }
    
    public PageReference runReport(){
        if(fEndDate < fStartDate){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date must be before the End Date'); 
            ApexPages.addMessage(myMsg);            
            return null;
        }
                       
        PNResults.clear();
        listStaffHrsInfo.clear();         
        selStates = uiselStates.split(',');
        selPrograms = uiselProgs.split(',');                                                                            
        system.debug('selstates: ' + selStates);
        system.debug('selprograms:' + selPrograms);
        List<Service_Assignment__c> SAResults = [ SELECT Id, phase__c, admission__r.state__c
         			from Service_Assignment__c where 
        					((Start_Date__c <= :fStartDate  AND (end_date__c >= :fStartDate or end_date__c = null)) OR   
                             start_date__c <= :fEndDate)  
                             and admission__r.state__c in :selStates
                             and program_detail__c in :selPrograms
                         ];
                       
        // create a map of the service assignments
        Map<Id, Service_Assignment__c> SAMap = new Map<ID, Service_Assignment__c>();
        for ( Service_Assignment__c s : SAResults) {
        	SAMap.put(s.id, s);
        }
                                      
                                      
        Datetime startdt = DateTime.newInstance( fStartDate, Time.newInstance(0,0,0,0));
        Datetime enddt = DateTime.newInstance ( fEndDate, Time.newInstance(23, 59, 59, 999));        
        system.debug( 'states:' + selStates + ', programs:' + selPrograms);
        System.debug( 'starting: ' + startdt + ' ending: ' + enddt );                          
        PNResults = [ SELECT 
        				service_assignment__c,
        				Person_Being_Served__r.Name pbsname,
        				person_being_served__c,
        				person_being_served__r.owner.name pbsowner,
           			 	Staff_Name__r.Name clinician,
           			 	service_assignment__r.model__c,
           			 	service_assignment__r.program_Detail__c,
           			 	service_assignment__r.admission__r.state__c,
         				sum(Total_Time__c) sum                     
                       FROM Progress_Note__c 
                       WHERE 
                         service_assignment__c in :SAResults
                         and disregard_note__c = false
                         and Start_time__c >= :startdt  AND  
                            Start_time__c <= :enddt
                         and service_assignment__r.admission__r.state__c in ('IN','MA','MD','OH') 
                       group by
                        	service_assignment__c,
                        	Person_Being_Served__r.Name,
                        	person_being_served__c,
                        	person_being_served__r.owner.name,
                        	staff_name__r.name,
	           			 	service_assignment__r.model__c,
           			 		service_assignment__r.program_Detail__c,
                        	service_assignment__r.admission__r.state__c];
 
        PNResults.AddAll( [ SELECT 
        				service_assignment__c,
        				Person_Being_Served__r.Name pbsname,
        				person_being_served__c,
        				person_being_served__r.owner.name pbsowner,
           			 	Owner.Name clinician,
           			 	service_assignment__r.model__c,
           			 	service_assignment__r.program_Detail__c,
           			 	service_assignment__r.admission__r.state__c,
         				sum(Total_Time__c) sum                     
                       FROM Progress_Note__c 
                       WHERE 
                         service_assignment__c in :SAResults
                         and disregard_note__c = false
                         and Start_time__c >= :startdt  AND  
                            Start_time__c <= :enddt
                         and service_assignment__r.admission__r.state__c not in ('IN','MA','MD','OH')  
                        group by
                        	service_assignment__c,
                        	Person_Being_Served__r.Name,
                        	person_being_served__c,
                        	person_being_served__r.owner.name,
                        	owner.name,
                        	service_assignment__r.model__c,
           			 		service_assignment__r.program_Detail__c,
                        	service_assignment__r.admission__r.state__c]);
 
                                           
            StaffHrsInfo dataRow;
            Decimal phase = 0.0;
            Service_Assignment__c pSA;                                                                   
            
            for(AggregateResult pn : PNResults) {     
            	 dataRow = new StaffHrsInfo();
            	        	          
           
            	pSA = SAMap.get( (ID)pn.get('service_assignment__c'));        	            	
            	
            	dataRow.saID = pSA.ID;     		                                
            	dataRow.clinician = (String)pn.get('clinician');
                dataRow.pbs = (String)pn.get('pbsname');
                dataRow.pbsOwner = (String)pn.get('pbsowner');
                
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
                
                
                dataRow.programDetail = (String)pn.get('program_detail__c');
                dataRow.model = (String)pn.get('model__c');
                dataRow.admissionState = (String)pn.get('state__c');
                
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
        public ID saId { get; set;}
        public String phase {get; set;}
        public String totalMinutes {get; set;} 
        public String hours{get; set;}
        public String admissionState{ get; set;}
        public String programDetail { get; set;}
        public String model {get; set;}
        public string pbsOwner { get; set;}
        
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