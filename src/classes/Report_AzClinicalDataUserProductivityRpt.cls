public with sharing class Report_AzClinicalDataUserProductivityRpt {

    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    
    public List<DataForCDU> listDataForCDU = new List<DataForCDU>();
    public List<DataForCDU> getListDataForCDU(){return listDataForCDU;}
    public string usrOpGrp;
    public boolean hasRunOnce {get; set;}    
    List<Progress_Note__c> PNResults = new List<Progress_Note__c>();            
        
    public Report_AzClinicalDataUserProductivityRpt () {
       //fStartDate = system.today();
       allCount = 0;
       
       getUserList();
       selUsers = new List<String>();
	   hasRunOnce =false;
    } 
    
    public integer allCount{get; set;}
    public List<SelectOption> users { get; set; }
    public List<String> selUsers {get; set;}
    public string uiselUsers { get; set; }
    
    private List<SelectOption> getUserList() {
    	
    	User currUser = [ select id, Operating_Group__c from User where id = :UserInfo.getUserId()];
        usrOpGrp = currUser.Operating_Group__c;
    	
    	users = new List<selectoption>();
    	if(usrOpGrp == 'Redwood'){
    		//proglistStates = new List<ServiceLocPrograms>();
    		UserRole userRole = [ SELECT Id, (SELECT Id, FirstName, LastName FROM Users) FROM UserRole WHERE DeveloperName = 'AZ_Phoenix_Clinical_Users' ];
    		System.debug('User Role: ' + userRole);
    		for(User u : userRole.Users) {
    			System.debug('User FirstName: ' + u.FirstName);
    		}
    		List<User> userList = userRole.Users;
    		for (User u : userList)
    		{
    			users.Add( new selectOption( u.Id, u.FirstName + ' ' + u.LastName) ) ;
    		}
    	}
    	if(usrOpGrp == 'NeuroRestorative'){
    	    list<id> assignedTo =  New List<Id>();
    		list<PermissionSetAssignment> permsets2 = [ SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE (PermissionSet.Name= 'ESD_Notes_Common' Or PermissionSet.Name= 'ESD_Notes_Clinical_Data_User') AND AssigneeId IN (SELECT Id FROM User WHERE Operating_group__c = 'NeuroRestorative' AND isactive=true)];
    	    set<id> Userset = new set<id>();
            Set<id> masterUserSet = New Set<id>();
            list<user> ulistmasters = new list<user>();
            for(PermissionSetAssignment u :permsets2){
                if(!Userset.contains(u.AssigneeId)){
                    Userset.add(u.AssigneeId);
                }
                else{
                    masteruserSet.add(u.AssigneeId);
                }
            }
    	    
    	    list<User> userList2 = [SELECT Id, FirstName, LastName FROM User where Id IN: masteruserSet]; 
            System.debug('---'+userlist2.size());
            users = new List<selectoption>();
            for (User u : userList2){
    		    system.debug('-----'+ u.firstname);
        		users.Add( new selectOption( u.Id, u.FirstName + ' ' + u.LastName) ) ;
        	}
        }
    	System.debug('----' + users);
    	return users;
    }


    public PageReference runReport(){
    	hasRunOnce =false;
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
            if (allCount>0)
            {
            	hasRunOnce = true;
            }                                                                                                                                                
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
        public String totalMinutes {get; set;}
        public Decimal tempMinutes { get; set; }
        public Decimal tempBillableMinutes { get; set; }
        public Decimal tempNonBillableMinutes { get; set; } 
        public String hours{get; set;}

		public DataForCDU(List<WrappedPn> pnList) {
			// Create Summary Row
			pns = pnList;
			sumRow = new SummaryRow();
			tempMinutes = 0;
			tempBillableMinutes = 0;
			tempNonBillableMinutes = 0;
			
			Integer counter = 1;
			
			for(WrappedPn p : pns) {
				
				if(counter==1) {
					clinician = p.thePn.CreatedBy.Name;
					clinicianUserId = p.thePn.CreatedBy.Id;
					totalMinutes = p.thePn.Total_Time__c.format();
					hours = (p.thePn.Total_Time__c / 60).format();
				}
				
				if(p.thePn.Purpose_Service_is_Billable__c) {
					tempBillableMinutes = tempBillableMinutes + p.thePn.Total_Time__c;
				}
				else {
					tempNonBillableMinutes = tempNonBillableMinutes + p.thePn.Total_Time__c;
				}
				
				tempMinutes = tempMinutes + p.thePn.Total_Time__c;
				
				Id thePreviousPn = p.thePn.Id;
				
				counter++;
		
			}
		
			sumRow.billableMinutes = tempBillableMinutes.format();
			sumRow.nonBillableMinutes = tempNonBillableMinutes.format();
			sumRow.totalMinutes = tempMinutes.format();
		
		}        
    
    }   


	public class SummaryRow {
		public String billableMinutes { get; set; }
		public String nonBillableMinutes { get; set; }
		public String totalMinutes { get; set; }		
	}
	
	public class WrappedPn implements comparable {
		
		public Progress_Note__c thePn { get; set; }
		public String localStartTime { get; set; }
		public String localEndTime { get; set; }
		public String localDate { get; set; }
        public String pbs {get; set;}
        public String pbsID {get; set;}		
		
		public WrappedPn(Progress_Note__c p) {
			thePn = p;
			pbs = thePn.Person_Being_Served__r.Name;
			pbsID = thePn.Person_Being_Served__c;			
			localStartTime = thePn.Start_Time__c.format('h:mm a');
			localEndTime = thePn.End_Time__c.format('h:mm a');	
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
	 public PageReference runPdf() {	
    	//Datetime pdfRunDateTime = System.now();
    	//pdfRunDateTimeString = pdfRunDateTime.format('MM/dd/yyyy, h:mm:ss a');
    	PageReference toPdfPage = new PageReference('/apex/Report_ClinicalDataUserProductivity_PDF');
    	toPdfPage.setRedirect(false);
    	return toPdfPage;
    }

}