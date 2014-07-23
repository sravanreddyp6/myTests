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
	
	public class ProgressNoteWrapper_CullKidTraksLineItems implements Comparable {
		
		public Progress_Note__c thePn;
		
		public ProgressNoteWrapper_CullKidTraksLineItems(Progress_Note__c p) { 
			thePn = p;	
		}
		
		public Integer compareTo(Object compareTo) {
			
			ProgressNoteWrapper_CullKidTraksLineItems compareToPnw = (ProgressNoteWrapper_CullKidTraksLineItems) compareTo; 
			
			Integer returnValue = 0;
			if(thePn.Person_Being_Served__c==compareToPnw.thePn.Person_Being_Served__c && thePn.Start_Time__c.date() > compareToPnw.thePn.Start_Time__c.date()) {
				returnValue = 1;
			}
			if(thePn.Person_Being_Served__c==compareToPnw.thePn.Person_Being_Served__c && thePn.Start_Time__c.date() < compareToPnw.thePn.Start_Time__c.date()) {
				returnValue = -1;
			}
			if(thePn.Person_Being_Served__c > compareToPnw.thePn.Person_Being_Served__c) {
				returnValue = 1;
			}
			if(thePn.Person_Being_Served__c < compareToPnw.thePn.Person_Being_Served__c) {
				returnValue = -1;
			}

			return returnValue;
		}
		
	}
	
    
    public PageReference runReport(){
    	lineItems = new List<KidTraksLineItem>();

		Datetime reportStartDateTime = datetime.newInstance(reportStartDate, Time.newInstance(0,0,0,0));
		Datetime reportEndDateTime = datetime.newInstance(reportEndDate,Time.newInstance(23,59,59,59));

		// In the query below, the WHERE condition "Service_Assignment__r.End_Date__c > :reportStartDate" requires that the Service Assignment End Date be AFTER the first day
		// in the report date range so that we never bill for a client whose service assignment ends on the first day of a report range.  This is in keeping with the requirements,
		// and also prevents us from getting the case in which a Service Assignment ends on the first day of the report, and the code below that figures out the value of
		// "theLastNotesStartDate" (a misleading variable name in that it's meaning evolved over time; study code below to see what I mean) would do things like give you 
		// 7/1/14 as the first day billed for a client, and 6/30/14 as the last day billed, resulting in 0 units and $0.  This filter will result in finalized notes for the 
		// first day of the report being excluded if the Service Assignment's End Date is also on the day of the report.  Based on the info from the business, there probably shouldn't
		// be finalized notes for this code on the same day as the Service Assignment End Date, or if there are, the business must think of such as non-billable given the requirements
		// they gave us. I'm noting this here, though, in case we ever have issues with the way the first day of the report and notes / Service Assignment End Dates on that day are
		// handled.  J. Gilliam, 7/18/14 
    	List<Progress_Note__c> progressNotesThisReport = [ SELECT Start_Time__c, End_Time__c, Person_Being_Served__c, Person_Being_Served__r.Name, Person_Being_Served__r.Avatar_ID__c,
    														Person_Being_Served__r.Other_ID__c, Service_Assignment__r.Start_Date__c, Service_Assignment__r.End_Date__c FROM Progress_Note__c 
    															WHERE Status__c = 'Final' 
    																	AND Service_Code__r.Service_Code__c = '10942.1161' 
    																	AND Start_Time__c >= :reportStartDateTime 
    																	AND End_Time__c <= :reportEndDateTime
    																	AND Program_Detail__c = :reportProgram
    																	AND (
    																		Service_Assignment__r.End_Date__c > :reportStartDate
    																		OR Service_Assignment__r.End_Date__c = null
    																	) ];    	
    	
    	List<ProgressNoteWrapper_CullKidTraksLineItems> listWrappedPns = new List<ProgressNoteWrapper_CullKidTraksLineItems>();
    	
    	for(Progress_Note__c p : progressNotesThisReport) {
    		listWrappedPns.add(new ProgressNoteWrapper_CullKidTraksLineItems(p)); 
    	}
    	
    	listWrappedPns.sort();
    	for(ProgressNoteWrapper_CullKidTraksLineItems p : listWrappedPns) {
    		System.debug('WRAPPED PN CHECK: ' + p);
    	}
    	

    	ProgressNoteWrapper_CullKidTraksLineItems thePreviousWrappedPn;
    	Date theFirstNotesStartDate;
    	// Commenting out the following line because it is not needed for flagging incrementation of the unitsCounter variable if we're just subtracting the
    	// dates of the first and last notes to get the unit count.  But, we may need to come back and count units / notes as we refine the algorithm for
    	// the "per diem continuous" concept (per diem billed daily whether or not a visit happens), so I'm leaving the line just in case.  J. Gilliam, 7-9-14, CTEAE-143
    		//Date thePreviousNotesStartDate;
    	Date thePreviousNotesStartDate;
    	Date theLastNotesStartDate;
    	Id thePreviousNotesPbsId;
    	// Commenting out the following line because it is not needed for if we're just subtracting the
    	// dates of the first and last notes to get the unit count.  But, we may need to come back and count units / notes as we refine the algorithm for
    	// the "per diem continuous" concept (per diem billed daily whether or not a visit happens), so I'm leaving the line just in case.  J. Gilliam, 7-9-14, CTEAE-143
    		//Integer unitsCounter = 0;
    	Integer unitsFromDateSubtract;
    	Integer loopCounter = 0;
    	
    	for(ProgressNoteWrapper_CullKidTraksLineItems pWrapped : listWrappedPns) {
    		Integer 	numberOfWrappedNotes = listWrappedPns.size();
    		loopCounter++;
    		
	    	// Commenting out the following section because it is not needed for if we're just subtracting the
	    	// dates of the first and last notes to get the unit count.  But, we may need to come back and count units / notes as we refine the algorithm for
	    	// the "per diem continuous" concept (per diem billed daily whether or not a visit happens), so I'm leaving the line just in case.  J. Gilliam, 7-9-14, CTEAE-143
	    		//if(thePreviousNotesPbsId==pWrapped.thePn.Person_Being_Served__c || thePreviousNotesPbsId==null) {
	    		//	if(pWrapped.thePn.Start_Time__c.date()!=thePreviousNotesStartDate) {
	    		//		unitsCounter++;
	    		//	}
	    		//}
	    		
	    	// IF THIS LOOP IS ON A DIFFERENT PBS, AND THERE WAS A PREVIOUS NOTE...	
    		if(thePreviousNotesPbsId!=pWrapped.thePn.Person_Being_Served__c && thePreviousNotesPbsId!=null) {
    			System.debug('MARKER 1');
    			System.debug('What is pWrapped.thePn.Service_Assignment__r.Start_Date__c at MARKER 1: ' + pWrapped.thePn.Service_Assignment__r.Start_Date__c);
    			System.debug('What is pWrapped.thePn.Service_Assignment__r.End_Date__c at MARKER 1: ' + pWrapped.thePn.Service_Assignment__r.End_Date__c);
    			if(theFirstNotesStartDate==null) {
    				if(pWrapped.thePn.Service_Assignment__r.Start_Date__c < reportStartDate) {
    					theFirstNotesStartDate = reportStartDate;
    				}
    				else {
    					theFirstNotesStartDate = pWrapped.thePn.Start_Time__c.date();
    				}
    			}

    			if(pWrapped.thePn.Service_Assignment__r.End_Date__c!=null) {
    				System.debug('DAYS BETWEEN CHECK: ' + pWrapped.thePn.Service_Assignment__r.End_Date__c.daysBetween(reportEndDate));
    			}
    			
    			if(thePreviousWrappedPn!=null) {
	    			if(thePreviousWrappedPn.thePn.Service_Assignment__r.End_Date__c==null) {
	    				theLastNotesStartDate = reportEndDate;		
	    			}
	    			else if (thePreviousWrappedPn.thePn.Service_Assignment__r.End_Date__c.daysBetween(reportEndDate) < 0) {
	    				theLastNotesStartDate = reportEndDate;
	    			}	
		    		else {
		    				theLastNotesStartDate = thePreviousWrappedPn.thePn.Service_Assignment__r.End_Date__c - 1;
		    		}
    			}
				else {
					theLastNotesStartDate = reportEndDate;
				}

    			
    			unitsFromDateSubtract = theFirstNotesStartDate.daysBetween(theLastNotesStartDate) + 1;
    			lineItems.add(new KidTraksLineItem(theFirstNotesStartDate, theLastNotesStartDate, theUser, thePreviousWrappedPn.thePn.Person_Being_Served__r.Name, thePreviousWrappedPn.thePn.Person_Being_Served__r.Avatar_ID__c, thePreviousWrappedPn.thePn.Person_Being_Served__r.Other_ID__c, unitsFromDateSubtract));
		    	// Commenting out the following line because it is not needed for if we're just subtracting the
		    	// dates of the first and last notes to get the unit count.  But, we may need to come back and count units / notes as we refine the algorithm for
		    	// the "per diem continuous" concept (per diem billed daily whether or not a visit happens), so I'm leaving the line just in case.  J. Gilliam, 7-9-14, CTEAE-143
    				//unitsCounter=0;
    		}
    		
    		// IF THIS IS THE LAST NOTE OF THE ENTIRE LOOP...
    		if(numberOfWrappedNotes==loopCounter) {
    			System.debug('MARKER 2');
    			System.debug('What is pWrapped.thePn.Service_Assignment__r.Start_Date__c at MARKER 2: ' + pWrapped.thePn.Service_Assignment__r.Start_Date__c);
    			System.debug('What is pWrapped.thePn.Service_Assignment__r.End_Date__c at MARKER 2: ' + pWrapped.thePn.Service_Assignment__r.End_Date__c);
    			if(pWrapped.thePn.Service_Assignment__r.End_Date__c!=null) {
    				System.debug('DAYS BETWEEN CHECK: ' + pWrapped.thePn.Service_Assignment__r.End_Date__c.daysBetween(reportEndDate));
    			}    			
    			if(pWrapped.thePn.Service_Assignment__r.End_Date__c==null) {
    				theLastNotesStartDate = reportEndDate;
    			}
    			else if(pWrapped.thePn.Service_Assignment__r.End_Date__c.daysBetween(reportEndDate) < 0) {
    				theLastNotesStartDate = reportEndDate;
    			}
    			else {
    				theLastNotesStartDate = pWrapped.thePn.Service_Assignment__r.End_Date__c - 1;
    			}    			
    			
    			unitsFromDateSubtract = theFirstNotesStartDate.daysBetween(theLastNotesStartDate) + 1;
    			lineItems.add(new KidTraksLineItem(theFirstNotesStartDate, theLastNotesStartDate, theUser, pWrapped.thePn.Person_Being_Served__r.Name, pWrapped.thePn.Person_Being_Served__r.Avatar_ID__c, pWrapped.thePn.Person_Being_Served__r.Other_ID__c, unitsFromDateSubtract));
		    	// Commenting out the following line because it is not needed for if we're just subtracting the
		    	// dates of the first and last notes to get the unit count.  But, we may need to come back and count units / notes as we refine the algorithm for
		    	// the "per diem continuous" concept (per diem billed daily whether or not a visit happens), so I'm leaving the line just in case.  J. Gilliam, 7-9-14, CTEAE-143
    				//unitsCounter=0;  // This probably doesn't matter, since this should be the last iteration of the containing loop.
    		}
    		
    		// IF THIS PERSON BEING SERVED IS DIFFERENT THAN THE ONE FOR THE LAST NOTE LOOPED OVER, OR IF THIS IS THE FIRST NOTE WE LOOP OVER...
    		if(thePreviousNotesPbsId!=pWrapped.thePn.Person_Being_Served__c || thePreviousNotesPbsId==null) {
    			System.debug('FIRST NOTE DATE CONDITION EXECUTING'); 			
				if(pWrapped.thePn.Service_Assignment__r.Start_Date__c < reportStartDate) {
					theFirstNotesStartDate = reportStartDate;
				}
				else {
					theFirstNotesStartDate = pWrapped.thePn.Start_Time__c.date();
				}    			
    		}
    		
			thePreviousNotesPbsId = pWrapped.thePn.Person_Being_Served__c;
	    	// Commenting out the following line because it is not needed for flagging incrementation of the unitsCounter variable if we're just subtracting the
	    	// dates of the first and last notes to get the unit count.  But, we may need to come back and count units / notes as we refine the algorithm for
	    	// the "per diem continuous" concept (per diem billed daily whether or not a visit happens), so I'm leaving the line just in case.  J. Gilliam, 7-9-14, CTEAE-143
				//thePreviousNotesStartDate = pWrapped.thePn.Start_Time__c.date();
			thePreviousNotesStartDate = pWrapped.thePn.Start_Time__c.date();
    		thePreviousWrappedPn = new ProgressNoteWrapper_CullKidTraksLineItems(pWrapped.thePn);

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