public with sharing class Report_AzClinicalDataUserProductivityRpt {

    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    
    public List<DataForCDU> listDataForCDU = new List<DataForCDU>();
    public List<DataForCDU> getListDataForCDU(){return listDataForCDU;}
        
    List<Progress_Note__c> PNResults = new List<Progress_Note__c>();            
        
    public Report_AzClinicalDataUserProductivityRpt () {
       //fStartDate = system.today();
       allCount = 0;
       
       getUserList();
       selUsers = new List<String>();
       
    } 
    
    public integer allCount{get; set;}
    public List<SelectOption> users { get; set; }
    public List<String> selUsers {get; set;}
    public string uiselUsers { get; set; }


    private List<SelectOption> getUserList() {
    	
    	users = new List<selectoption>();
    	//proglistStates = new List<ServiceLocPrograms>();
    	List<User> userList = [ select Id, FirstName, LastName from User ];
    	
    	for (User u : userList)
    	{
    		users.Add( new selectOption( u.Id, u.FirstName + ' ' + u.LastName) ) ;
    	}
    	
    	
    	return users;
    }
    
    
    public PageReference runReport(){
        if(fEndDate < fStartDate){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date must be before the End Date'); 
            ApexPages.addMessage(myMsg);            
            return null;
        }
                       
        PNResults.clear();
        listDataForCDU.clear();         
        selUsers = uiselUsers.split(',');                                                                           
        
        for(String s : selUsers) {
        	System.debug('selUsers entry: ' + s);
        }
        System.debug('uiselUsers: ' + uiselUsers);                              
                                      
        Datetime startdt = DateTime.newInstance( fStartDate, Time.newInstance(0,0,0,0));
        Datetime enddt = DateTime.newInstance ( fEndDate, Time.newInstance(23, 59, 59, 999));        
        System.debug( 'starting: ' + startdt + ' ending: ' + enddt );                          
        PNResults = [ SELECT 
        				Service_Assignment__c,
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
                         Disregard_Note__c = false
                         AND Start_time__c >= :startdt  
                         AND Start_time__c <= :enddt
                         AND CreatedBy.Id = :selUsers ];
 
                                           
            DataForCDU dataForACdu;                                                              
            
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
        public String clinicianUserId {get; set;}
        public String pbs {get; set;}
        public String pbsID {get; set;}
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
					clinicianUserId = p.thePn.CreatedBy.Id;
					pbs = p.thePn.Person_Being_Served__r.Name;
					pbsID = p.thePn.Person_Being_Served__c;
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
	
	public void doNothing() {
		
	}

}