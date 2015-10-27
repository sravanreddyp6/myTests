public with sharing class DSPHomePageController {

	Public Transient List<Contact> PBSList {get; private set;}
	Public List<SelectOption> selPBSList { get; private set; }
	public boolean canSeePBS { get; set; }
	public string pbsID { get; set; }
	
	public String FrstName { get; set; }
	public String LstName { get; set; }

//Constructor
	public DSPHomePageController(){

		// make sure user is completely configured for system use
		checkTmnUserRecord();

		//PBS object
		Schema.DescribeSObjectResult oSchema = Account.sObjectType.getDescribe();
		canSeePBS = oSchema.isAccessible();

//		searchResultList = new List<HomePageSearchController.SearchResult>();
/*
		serviceAssignmentToSelectOptionMap = new Map<Id, List<SelectOption>>();
		List<AggregateResult> slPrgms = [
			SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
			  FROM service_assignment__c
			GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c,
			         service_location__r.programid__c
			HAVING COUNT(service_location__r.id) > 0
			ORDER BY service_location__r.programid__c, service_location__r.program__c
		];
*/	

		getPBSList();
	}
	
	
	public void getPBSList() {

			PBSList = [select id, name from contact where id in (select person_being_served__c from service_assignment__c where status__c = 'Active')];
			selPBSList = new List<SelectOption>();
			for ( Contact c : PBSList) {
				SelectOption s = new SelectOption(c.id, c.name);
				selPBSList.Add( s);
			}
	}
	
	
	// START: SHAUN-47: Additions for checking existence of TMN_User__c record for the User.
	public class TMN_User_Exception extends Exception {}

	public void checkTmnUserRecord() {
		String usersId = UserInfo.getUserId();
		List<TMN_User__c> tmnUserRecords = [ SELECT Id FROM TMN_User__c WHERE Salesforce_User_Account__c = :usersId LIMIT 1 ];

		Integer countTmnUserRecords = 0;
		for(TMN_User__c tmnu : tmnUserRecords) {
			countTmnUserRecords++;
		}

		if(countTmnUserRecords==0) {
			throw new TMN_User_Exception('ERROR: Your account must be reconfigured before you begin using the system. Please contact the Implementation Team at Implementation@thementornetwork.com or the IT Service Center at 888-774-4872.');
		}
	}
	// END: SHAUN-47: Additions for checking existence of TMN_User__c record for the User.
	
	public pageReference viewActionPlan() {
		
		// get the current PBS ID
		// submit a transaction queue request to get the action plan
		// redirect to the action plan page with the transaction queue id
		Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
		txn.request_type__c = 'Action Plan';
		txn.requested_date_time__c = DateTime.Now();
		txn.input_params__c = pbsID;
		
		try { 
			insert txn;
			PageReference pr =  Page.DSPActionPlan;
			pr.getParameters().put('txnID', txn.ID);
			pr.setRedirect(true);
			return pr;
		}
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
		
	}
	
    public pageReference viewPersonBeingServed() {
        // get the current PBS ID
        // submit a transaction queue request to get the Person being served
        // redirect to the PBS page with the transaction queue id
        Transaction_Queue__c txn  = new Transaction_Queue__c( requesting_user__c = UserInfo.getUserId());
        txn.request_type__c = 'Person Being Served';
        txn.requested_date_time__c = DateTime.Now();
        txn.input_params__c = pbsID;
        
        try { 
            insert txn;
            PageReference pr =  Page.DSPPersonBeingServedView;
            pr.getParameters().put('txnID', txn.ID);
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
   
    }
	
	
}