public with sharing class Report_KidTraksExport_Controller {

	public User theUser { get; set; }
	public List<KidTraksLineItem> lineItems { get; set; }
	public Date reportStartDate { get; set; }
	public Date reportEndDate { get; set; }
	public List<SelectOption> reportPrograms { get; set; }
	public String reportProgram { get; set; }
	public Boolean reportResultsDisplayed { get; set; }
	

	public class KidTraksLineItem {

		public String emailAddress { get; set; }
		public String phoneNumber { get; set; }
		public String vendorId { get; set; }
		public String vendorLocation { get; set; }
		public Integer vendorAddressSeq { get; set; }
		public String invoiceType { get; set; }
		public String billType { get; set; }
		public String invoiceNumber { get; set; }
		public String serviceType { get; set; }
		public String billableUnitId { get; set; }
		public String personId { get; set; }
		public String caseId { get; set; }
		public String billingCode { get; set; }
		public String serviceCode { get; set; }
		public String componentCode { get; set; }
		public DateTime startTime { get; set; }
		public DateTime startDate { get; set; }
		public DateTime endDate { get; set; }
		public Integer units { get; set; }
		public String uom { get; set; }
		public Integer rate { get; set; }
		public Integer amount { get; set; }
		public String placeOfService { get; set; }
		
		public KidTraksLineItem(DateTime startDate, DateTime endDate, User theUser, String PbsName, String avatarId, String otherId, Integer u) {
			emailAddress = theUser.Email; // Using report runner's email.
			phoneNumber = theUser.Phone; // Using report runner's phone number.
			vendorId = 'ST064986';
			vendorLocation = 'REMIT001';
			vendorAddressSeq = 1;
			invoiceType = 'Regular';
			billType = 'First Bill';
			invoiceNumber = '';
			serviceType = 'FamilyPreservation';
			billableUnitId = otherId;
			personId = PbsName;
			caseId = avatarId;
			billingCode = '10942.1161';
			serviceCode = '10942';
			componentCode = '11610';
			this.startDate = startDate; // Aggregate line IN progress notes on a given day for each IN clients
			this.endDate = endDate; // Aggregate line IN progress notes on a given day for each IN clients
			units = u;
			uom = 'Day';
			rate = 88;
			amount = u * 88;
			placeOfService = 'Home';
						
		}
	}
	
    
    public PageReference runReport(){
    	lineItems = new List<KidTraksLineItem>();

		Datetime reportStartDateTime = datetime.newInstance(reportStartDate, Time.newInstance(0,0,0,0));
		Datetime reportEndDateTime = datetime.newInstance(reportEndDate,Time.newInstance(23,59,59,59));
    	
    	//Create a list of Service Assignments that:
		//	a.	Started before the report’s end date, and either haven’t ended or ended after or on the report’s start date.
		//	b.	Are for the program selected for the report
		//	c.	Have at least one finalized Progress Note for the 10942.1161 code with a Start Time prior to the report’s end date   	
    	List<Service_Assignment__c> servAssignsToBecomeLineItems = [ SELECT Id, Person_Being_Served__c, Person_Being_Served__r.Name, Person_Being_Served__r.Avatar_ID__c,
    																	Person_Being_Served__r.Other_ID__c, End_Date__c
    																	FROM Service_Assignment__c
    																	WHERE Start_Date__c <= :reportEndDate
    																	AND Program_Detail__c = :reportProgram
    																	AND (
    																			End_Date__c = null
    																			OR End_Date__c >= :reportStartDate
    																		)
    																	AND Id IN  (
    																					SELECT Service_Assignment__c 
    																					FROM Progress_Note__c 
		    																			WHERE Status__c = 'Final' 
		    																			AND Service_Code__r.Service_Code__c = '10942.1161'
		    																			AND Program_Detail__c = :reportProgram
		    																			AND Start_Time__c <= :reportEndDateTime
		    																	 )
    																	];  	
    	System.debug('servAssignsToBecomeLineItems.size(): ' + servAssignsToBecomeLineItems.size());
    	
    	// If there are no Service Assignments that fit those criteria (in other words, if there are no line items expected for the report), exit!
    	if(servAssignsToBecomeLineItems.size()==0) return null;
    	
    	// Create a list of ALL finalized progress notes for code 10942.1161 for Service Assignments for this program that either haven't ended or ended after the report's start date.
    	List<Progress_Note__c> progressNotesTheseServAssigns = [ SELECT Start_Time__c, End_Time__c, Person_Being_Served__c, Person_Being_Served__r.Name, Person_Being_Served__r.Avatar_ID__c,
    																Person_Being_Served__r.Other_ID__c, Service_Assignment__c, Service_Assignment__r.Start_Date__c, Service_Assignment__r.End_Date__c 
    																FROM Progress_Note__c 
    																WHERE Status__c = 'Final' 
    																AND Service_Code__r.Service_Code__c = '10942.1161'
    																AND Program_Detail__c = :reportProgram
    																AND (
    																	Service_Assignment__r.End_Date__c > :reportStartDate
    																	OR Service_Assignment__r.End_Date__c = null
    																)
    																ORDER BY Start_Time__c ];    	

		// Create a list of progress notes from list progressNotesTheseServAssigns that represents the list of notes for the code and program
		// that fall within the report date range.
		List<Progress_Note__c> progressNotesThisReport = new List<Progress_Note__c>();
		for(Progress_Note__c p : progressNotesTheseServAssigns) {
			// IF THE NOTE STARTS WITHIN THE REPORT DATE RANGE
			if(p.Start_Time__c >= reportStartDateTime && p.Start_Time__c <= reportEndDateTime) {
				progressNotesThisReport.add(p);
			}
		}
		System.debug('progressNotesThisReport.size(): ' + progressNotesThisReport.size());

		// Create a set of IDs for the Service Assignments that have finalized notes for the code and program, which also either haven't ended or end after the report's start date.
		Set<Id> servAssignsThisNoteSet = new Set<Id>();
		for(Progress_Note__c p : progressNotesTheseServAssigns) {
			servAssignsThisNoteSet.add(p.Service_Assignment__c);
		}
		System.debug('servAssignsThisNoteSet.size()' + servAssignsThisNoteSet.size());
    	
    	// Create a list of progress notes for Service Assignments that have finalized notes for the code and program, which also either haven't ended or end after the report's start date,
    	// but only include notes from before the report start date.
    	List<Progress_Note__c> notesBeforeReportTheseServAssigns = [ SELECT Service_Assignment__c 
    																	FROM Progress_Note__c 
		    															WHERE Status__c = 'Final' 
		    															AND Service_Code__r.Service_Code__c = '10942.1161'
		    															AND Program_Detail__c = :reportProgram
		    															AND Service_Assignment__c = :servAssignsThisNoteSet 
		    															AND Start_Time__c < :reportStartDate ];  	
    	System.debug('notesBeforeReportTheseServAssigns.size()' + notesBeforeReportTheseServAssigns.size());
    	

    	Date lineItemStartDate;
    	Date lineItemEndDate;
    	Integer unitsFromDateSubtract;
    	
    	// Loop through our Service Assignments in scope, as defined above, that will each become a line item on the report.
    	for(Service_Assignment__c s : servAssignsToBecomeLineItems) {
    		
    		// START: Figure out if the Service Assignment has finalized notes for the code and program before the report's start date. 
    		Boolean thisServAssignHasNotesBeforeReportStartDate = false;
    		
    		for(Progress_Note__c p : notesBeforeReportTheseServAssigns) {
    			System.debug('p.Service_Assignment__c: ' + p.Service_Assignment__c);
    			System.debug('s.Id: ' + s.Id);
    			if(p.Service_Assignment__c==s.Id) {
    				thisServAssignHasNotesBeforeReportStartDate = true;
    				// If the Service Assignment DOES have finalized notes for the code and program before the report's start date, then
    				// we want to use the report's start date as the start date for our billing line item, per the requirements from the business (CTEAE-143; attached email).
    				lineItemStartDate = reportStartDate;
    			}
    		}
    		System.debug('thisServAssignHasNotesBeforeReportStartDate after loop through notesBeforeReportTheseServAssigns: ' + thisServAssignHasNotesBeforeReportStartDate);
    		// END: Figure out if the Service Assignment has finalized notes for the code and program before the report's start date. 
    		
    		// If the Service Assignment DOES NOT have finalized notes for the code and program before the report's start date...
			if(!thisServAssignHasNotesBeforeReportStartDate) {
				// Create a list of this person's progress notes that fall within the report date range.
				List<Progress_Note__c> thisPersonsProgressNotesThisReport = new List<Progress_Note__c>();
				//  We get that list by looping through the progressNotesThisReport, which is already ordered by note Start_Time__c from the original query for notes above.
				for(Progress_Note__c p2 : progressNotesThisReport) {
					// Check to make sure the notes getting added are only notes for the service assignment for this loop iteration.
					if(p2.Service_Assignment__c == s.Id) {
						thisPersonsProgressNotesThisReport.add(p2);
					}
				}
				System.debug('thisPersonsProgressNotesThisReport.size(): ' + thisPersonsProgressNotesThisReport.size());
				// Set the start date for the report line item to the first note in the list, which should be the earliest based on the query sorting.
				lineItemStartDate = thisPersonsProgressNotesThisReport[0].Start_Time__c.date();
			}
    			
    		    	
    		// START:  Figure out the line item end date.
			
			// If the Service Assignment's end date is before or on the report's end date, use the Service Assignment end date as the line item's end date.
			// This takes into account the case in which the Service Assignment End_Date__c value is null, as the if condition will evaluate to false in that case. 
    		if(s.End_Date__c <= reportEndDate) {
    			lineItemEndDate = s.End_Date__c - 1;
    		}
    		// Otherwise, use the report's end date as the line item end date.
    		else {
    			lineItemEndDate = reportEndDate;	
    		}
    		// END: Figure out the line item end date.
			
			// Calculate the number of units to be billed for the line item by getting the daysBetween value for the lineItemStartDate and lineItemEndDate, and adding 1.
			unitsFromDateSubtract = lineItemStartDate.daysBetween(lineItemEndDate) + 1;
	    	
	    	// Create a single line item for the Service Assignment.
	    	lineItems.add(new KidTraksLineItem(lineItemStartDate, lineItemEndDate, theUser, s.Person_Being_Served__r.Name, s.Person_Being_Served__r.Avatar_ID__c, s.Person_Being_Served__r.Other_ID__c, unitsFromDateSubtract));
	    	
    	}      
        return null;
    }
    
    public PageReference submitParams() {
    	reportResultsDisplayed = true;
    	runReport();
    	return null;
    }
    
    public Report_KidTraksExport_Controller(){
    	Id theUsersId = UserInfo.getUserId();
    	theUser = [ SELECT Email, Phone FROM User WHERE Id = :theUsersId ];
    	
    	List<Service_Location__c> programs = [ SELECT Id, Name, programid__c, Program__c FROM Service_Location__c WHERE State__c = 'IN'  ];
    	Set<String> uniquePrograms = new Set<String>();
    	
    	List<Service_code__c> codes = [select program_code__c from service_code__c where service_code__c = '10942.1161' and state__c = 'IN'];
    	Set<String> uniquecodes = new Set<String>();
    	for ( service_code__c sc : codes )
    		uniquecodes.add( sc.Program_Code__c);
    		
    	for(Service_Location__c slc : programs) {
    		if ( uniquecodes.contains(slc.ProgramID__c))
    			uniquePrograms.add(slc.Program__c);
    	}
    	
    	reportPrograms = new List<SelectOption>();
    	reportPrograms.add(new SelectOption('--None--','--None--'));
    	
    	List<String> programStrings = new List<String>();
    	programStrings.addAll(uniquePrograms);
    	
    	programStrings.sort();
    	
    	for(String program : programStrings) {
    		reportPrograms.add(new SelectOption(program, program));
    	}
    }
}