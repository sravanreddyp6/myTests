// Extension class to handle CMAUTH tickets - Sept 2015
public with sharing class AuthorizationExt {

public ID saID { get; set; }
public ID admID { get; set; }
public ID pbsID { get; set; }
public Final Authorization__c authorization { get; set; }
public List<Funding_Source__c> fsList { get; set; }

public Boolean canEditAuth { get; private set; }
public Boolean canCreateAuth { get; private set; }
public Boolean canFinalize { get; private set; }
public Boolean hasDraft { get; private set;}

public List<Authorization__c> relatedAuthsList { get; set; }
	
public AuthorizationExt(ApexPages.StandardController controller) {

	 // service assignment ID is passed in - get the other params needed for personal record connection
	saID = ApexPages.currentPage().getParameters().get('saID');
	
	if ( saID != null ) {
		fsList =  [ select id, name from funding_source__c where service_assignment__c = :saID and status__c != 'Inactive'];
		Service_Assignment__c sa = [ select id, admission__c, admission__r.person_being_served__c from service_assignment__c where id = :saID LIMIT 1];
		if ( sa != null ) {
			admID = sa.Admission__c;
			pbsID = sa.Admission__r.Person_Being_Served__c;
		}
	}
	else
		fsList = new LIst<Funding_Source__c>();	
	
	if (controller.getId() != null )
		authorization = (Authorization__c)controller.getRecord();
		//authorization = [ select id, name, payer_authorization_id__c ];
	else
	 	authorization = new Authorization__c();


	Schema.DescribeSObjectResult oSchema = Authorization__c.sObjectType.getDescribe();
	canCreateAuth = oSchema.isCreateable();
	canEditAuth = oSchema.isUpdateable();
	canFinalize = true;	//udpate with perms later
	
	hasDraft = false;
	//relatedAuthsList = [ select id, received_date_time__c, type__c, Reason_for_New_Authorization__c, rate__c, rate_unit__c, level__c, payer_effective_date__c, payer_end_Date__c, contract_used__c from authorization__c where payer_authorization_id__c = :authorization.payer_authorization_id__c order by payer_effective_Date__c desc ];
	//for ( Authorization__c r : relatedAuthsList) {
	//	if ( r.Authorization_Status__c == 'Inactive Draft0') {
	//		hasDraft = true;
	//		break;
	//	}
	//}
	
}
	
public pageReference editAuth() {
	PageReference pr = new PageReference('/apex/AuthorizationView?id=' + authorization.Id + '&saID=' + saID);
	pr.setRedirect( true);
	return pr;
	
}
	public pageReference saveAuth() {
		System.debug('Before upsert, auth: ' + authorization );
		// When we use Id fields in conjunction with Visualforce's assignTo, it
		// becomes a blank string - which will trigger a system error (because it's
		// not a valid ID)
		if (String.valueOf(authorization.Id) == '') {
			authorization.Id = null;
		}

		try {
			authorization.Authorization_Status__c = 'Inactive Draft';
			upsert authorization;
			PageReference pr = new PageReference('/apex/AuthorizationView?id=' + authorization.Id + '&saID=' + saID);
			pr.setRedirect( true);
			return pr;
			
		}
		catch (Exception e) {
			return null;
		}

	}
	
	public PageReference finalizeAuth(){
		try{
			authorization.Authorization_Status__c = 'Active Final';  
			upsert authorization;
			PageReference pr = new PageReference('/apex/AuthorizationView?id=' + authorization.Id + '&saID=' + saID);
			pr.setRedirect( true);
			return pr;
		}
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
	}
	
	public PageReference cloneAuth() {
		try {
			Authorization__c newauth = authorization.clone();
			PageReference pr = new PageReference('/apex/AuthorizationView?id=' + newauth.Id + '&saID=' + saID);
			pr.setRedirect(true);
			return pr;
		} 
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to clone this authorization.'));
			return null;
		}
	}
	
	public PageReference reviseAuth() {
		try {
			// revision is a clone of the original with Draft status
			Authorization__c newauth = authorization.clone();
			newauth.Authorization_Status__c = 'Inactive Draft';
			
			// link up original to revision
			//newauth.Original_Authorization__c = authorization.Id;
			update newauth;
			PageReference pr = new PageReference('/apex/EditAuthorization?id=' + newauth.Id + '&saID=' + saID);
			pr.setRedirect( true);
			return pr;
		} 
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to clone this authorization.'));
			return null;
		}
	}
	
	public pageReference disregardAuth(){
		try{
			Authorization__c a = [SELECT Id, Authorization_Status__c FROM Authorization__c WHERE Id =:authorization.Id ]; // To make sure only Status field is in scope.
			a.Authorization_Status__c = 'Disregard';  
			update a;
			PageReference pr = new PageReference('/apex/AuthorizationView?id=' + a.Id + '&saID=' + saID);
			pr.setRedirect(true);
			return pr;
		}
		catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
	}
			
		
}