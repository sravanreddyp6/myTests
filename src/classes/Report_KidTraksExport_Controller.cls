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
		public Integer invoiceNumber { get; set; }
		public String serviceType { get; set; }
		public String billableUnitId { get; set; }
		public String billingCode { get; set; }
		public DateTime startTime { get; set; }
		public DateTime startDate { get; set; }
		public DateTime endDate { get; set; }
		public Integer units { get; set; }
		public String uom { get; set; }
		public Integer rate { get; set; }
		public Integer amount { get; set; }
		public String placeOfService { get; set; }
		
		public KidTraksLineItem(DateTime startDate, DateTime endDate, String authNumber, User theUser) {
			emailAddress = theUser.Email; // Using report runner's email.  Acceptable?
			phoneNumber = theUser.Phone; // Using report runner's phone number.  Acceptable?
			vendorId = 'STO64986';
			vendorLocation = 'REMIT001';
			vendorAddressSeq = 1;
			invoiceType = 'Regular';
			billType = 'First Bill';
			serviceType = 'FamilyPreservation';
			billableUnitId = authNumber; // Where can I get this in Salesforce?
			billingCode = '10942.1161';  // Is this always the billing code?
			this.startDate = startDate; // Aggregate line IN progress notes on a given day for each IN clients
			this.endDate = endDate; // Aggregate line IN progress notes on a given day for each IN clients
			units = 1;
			uom = 'Day';
			rate = 88;
			amount = 88;
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
			if(thePn.Id>compareToPnw.thePn.Id && thePn.Start_Time__c.date() > compareToPnw.thePn.Start_Time__c.date()) {
				returnValue = 1;
			}
			if(thePn.Id<compareToPnw.thePn.Id && thePn.Start_Time__c.date() < compareToPnw.thePn.Start_Time__c.date()) {
				returnValue = -1;
			}
			
			return returnValue;
		}
		
	}
	
    
    public PageReference runReport(){
    	lineItems = new List<KidTraksLineItem>();

    	List<Progress_Note__c> progressNotesThisReport = [ SELECT Start_Time__c, End_Time__c, Person_Being_Served__c, Authorization__r.Payer_Authorization_ID__c FROM Progress_Note__c 
    															WHERE Status__c = 'Final' 
    																	AND Service_Code__r.Service_Code__c = '10942.11610' 
    																	AND Start_Time__c >= :reportStartDate 
    																	AND End_Time__c <= :reportEndDate
    																	AND Program_Detail__c = :reportProgram ];
    	
    	List<ProgressNoteWrapper_CullKidTraksLineItems> listWrappedPns = new List<ProgressNoteWrapper_CullKidTraksLineItems>();
    	
    	for(Progress_Note__c p : progressNotesThisReport) {
    		listWrappedPns.add(new ProgressNoteWrapper_CullKidTraksLineItems(p)); 
    	}
    	
    	listWrappedPns.sort();
    	
    	Date theLastNotesStartDate;
    	Id theLastNotesPbsId;
    	
    	for(ProgressNoteWrapper_CullKidTraksLineItems pWrapped : listWrappedPns) {
    		if((theLastNotesPbsId==pWrapped.thePn.Person_Being_Served__c && (theLastNotesStartDate==null || theLastNotesStartDate < pWrapped.thePn.Start_Time__c.date())) || theLastNotesPbsId!=pWrapped.thePn.Person_Being_Served__c) {
    			lineItems.add(new KidTraksLineItem(pWrapped.thePn.Start_Time__c, pWrapped.thePn.End_Time__c, pWrapped.thePn.Authorization__r.Payer_Authorization_ID__c, theUser));
    		}
    		theLastNotesStartDate = pWrapped.thePn.Start_Time__c.date();
    		theLastNotesPbsId = pWrapped.thePn.Person_Being_Served__c;
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