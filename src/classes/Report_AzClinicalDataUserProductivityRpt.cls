public with sharing class Report_AzClinicalDataUserProductivityRpt {

    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    
    public List<DataForCDU> listDataForCDU = new List<DataForCDU>();
    public List<DataForCDU> getListDataForCDU(){return listDataForCDU;}
        
    List<Progress_Note__c> PNResults = new List<Progress_Note__c>();            
        
    public Report_AzClinicalDataUserProductivityRpt () {
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
        listDataForCDU.clear();         
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
        
        System.debug('SAs in SAResults: ' + SAResults.size());
                       
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
        				Person_Being_Served__r.Name,
        				person_being_served__c,
        				person_being_served__r.Owner.Name,
        				CreatedBy.Name,
        				Service_Code__r.Name,
        				Start_Time__c,
        				End_Time__c,
        				Purpose_Service_is_Billable__c,
           			 	Staff_Name__r.Name,
           			 	Total_Time__c      
                       FROM Progress_Note__c 
                       WHERE 
                         service_assignment__c in :SAResults
                         and disregard_note__c = false
                         and Start_time__c >= :startdt  AND  
                            Start_time__c <= :enddt ];
 
                                           
            DataForCDU dataForACdu;
            Service_Assignment__c pSA;                                                                   
            
            List<WrappedPn> tempPnList = new List<WrappedPn>();
			Set<Id> users = new Set<Id>();
            
            for(Progress_Note__c p : PNResults) {     
                WrappedPn aWrappedPn = new WrappedPn(p);            
                tempPnList.add(aWrappedPn);
                System.debug('Progress Note: ' + p.Id);
                users.add(p.CreatedBy.Id);                                                           
            }
            
            tempPnList.sort();
            
            
            for(Id u : users) {
        		List<WrappedPn> thisUsersWrappedPns = new List<WrappedPn>();
        		for(WrappedPn wp : tempPnList) {
	        		if(u==wp.thePn.CreatedBy.Id) {
	        			thisUsersWrappedPns.add(wp);
	        		}
        		}
            	DataForCDU myObj = new DataForCDU(thisUsersWrappedPns);
            	listDataForCDU.add(myObj);      		
            }
           
            allCount = listDataForCDU.size();
                                                                                                                                                                
            fStartDate = null;
            fEndDate= null;
            return null; 
    }
    
    // Inner Class to store the row data detail of the report 
    public class DataForCDU {
    	public List<WrappedPn> pns { get; set; }
    	public SummaryRow sumRow { get; set; }
        public String clinician {get; set;}
        public String pbs {get; set;}
        public ID saId { get; set;}
        public String totalMinutes {get; set;}
        public Decimal tempMinutes { get; set; }
        public Decimal tempBillableHours { get; set; }
        public Decimal tempNonBillableHours { get; set; } 
        public String hours{get; set;}

		public DataForCDU(List<WrappedPn> pnList) {
			// Create Summary Row
			pns = pnList;
			sumRow = new SummaryRow();
			tempMinutes = 0;
			tempBillableHours = 0;
			tempNonBillableHours = 0;
			
			Integer counter = 1;
			
			for(WrappedPn p : pns) {
				
				if(counter==1) {
					clinician = p.thePn.CreatedBy.Name;
					pbs = p.thePn.Person_Being_Served__r.Name;
					saId = p.thePn.Service_Assignment__c;
					totalMinutes = p.thePn.Total_Time__c.format();
					hours = (p.thePn.Total_Time__c / 60).format();
				}
				
				if(p.thePn.Purpose_Service_is_Billable__c) {
					tempBillableHours = tempBillableHours + (p.thePn.Total_Time__c / 60);
				}
				else {
					tempNonBillableHours = tempNonBillableHours + (p.thePn.Total_Time__c / 60);
				}
				
				tempMinutes = tempMinutes + p.thePn.Total_Time__c;
				
				Id thePreviousPn = p.thePn.Id;
				
				counter++;
		
			}
		
			sumRow.billableHours = tempBillableHours.format();
			sumRow.nonBillableHours = tempNonBillableHours.format();
			sumRow.totalMinutes = tempMinutes.format();
			sumRow.totalHours = (tempMinutes / 60).format();
		
		}        
    
    }   


	public class SummaryRow {
		public String billableHours { get; set; }
		public String nonBillableHours { get; set; }
		public String totalMinutes { get; set; }
		public String totalHours { get; set; }		
	}
	
	public class WrappedPn implements comparable {
		
		public Progress_Note__c thePn { get; set; }
		public String localStartTime { get; set; }
		public String localEndTime { get; set; }
		public String localDate { get; set; }
		
		public WrappedPn(Progress_Note__c p) {
			thePn = p;
			localStartTime = thePn.Start_Time__c.format('h:m a');
			localEndTime = thePn.End_Time__c.format('h:m a');	
			localDate = thePn.Start_Time__c.format('M/d/yyyy');
		}
		
        public Integer compareTo(Object compareTo) 
    	{
	        WrappedPn wpn = (WrappedPn) compareTo;
	        if (thePn.CreatedBy == wpn.thePn.CreatedBy ) {
	        	if ( thePn.Start_Time__c == wpn.thePn.Start_Time__c ) return 0;
	        	if ( thePn.Start_Time__c > wpn.thePn.Start_Time__c ) return 1;
	        	return -1;
	        }
	        if (thePn.CreatedByID > wpn.thePn.CreatedByID ) return 1;
	        return -1;        
    	}
		
	}

}