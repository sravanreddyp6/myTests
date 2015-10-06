// Extension class to handle CMAUTH tickets - Sept 2015
public with sharing class AuthorizationExt {

public ID saID { get; set; }
public ID admID { get; set; }
public ID pbsID { get; set; }
public Authorization__c authorization { get; set; }

public Boolean canEditAuth { get; private set; }
public Boolean canCreateAuth { get; private set; }
public Boolean canFinalize { get; private set; }
public Boolean hasDraft { get; private set;}

public List<SelectOption> fsList { get; set; }

public List<Authorization__c> relatedAuthsList { get; set; }
    
public AuthorizationExt(ApexPages.StandardController controller) {

     // service assignment ID is passed in - get the other params needed for personal record connection
    saID = ApexPages.currentPage().getParameters().get('saID');
    
    
    ID authID = ApexPages.currentPage().getParameters().get('ID');
    system.debug( authID );
    
    List<Funding_Source__c> fsources;
    if ( saID != null ) {
        fsources =  [ select id, name, type_of_coverage__c, payer_name__c from funding_source__c where service_assignment__c = :saID and status__c != 'Inactive' order by type_of_coverage__c, payer_name__c];
        Service_Assignment__c sa = [ select id, admission__c, admission__r.person_being_served__c from service_assignment__c where id = :saID LIMIT 1];
        if ( sa != null ) {
            admID = sa.Admission__c;
            pbsID = sa.Admission__r.Person_Being_Served__c;
        }
    }
    else
        fsources = new LIst<Funding_Source__c>(); 
    
    fsList = new List<SelectOption>();
    
    for ( Funding_Source__c f: fsources ) {
    	
    	SelectOption option = new SelectOption( f.id, f.type_of_coverage__c + ' - ' + f.payer_name__c );
    	fsList.Add( option );
    }
   
    if (authID != null ) {
        authorization = (Authorization__c)controller.getRecord();
        authorization = [ select id, authorization_status__c, type__c, other_authorization_type__c, reason_for_new_authorization__c, service_being_funded_string__c, payer_authorization_id__c,
                            rate__c, received_date_time__c, rate_unit__c, rate_unit_other__c, payer_effective_date__c, payer_end_date__c, funding_source__c, funding_source__r.payer_name__c, contract_used__c, 
                            received_from__c, taken_by__c, level__c, justification__c, representing_received__c,  auth_given_method__c, comments__c, 
                            bed_hold_type__c, bed_hold_type_detail__c, bed_hold_additional_detail__c, bed_hold_classification__c, parent_auth__c, original_auth__c, isRootAuth__c
                            from authorization__c
                            where id = :controller.getRecord().Id ];
    
    	   if ( ApexPages.currentPage().getURL().contains('Edit') && authorization.authorization_status__c == 'Final') {
       		// cannot edit a Final	
       		redirectToView( authorization.id, saID);
       } 
       	
    
    }
    else
        authorization = new Authorization__c( recordtypeID= ApexPages.currentPage().getParameters().get('RecordType') );


    Schema.DescribeSObjectResult oSchema = Authorization__c.sObjectType.getDescribe();
    canCreateAuth = oSchema.isCreateable();
    canEditAuth = oSchema.isUpdateable();
    canFinalize = true; //udpate with perms later
    
    hasDraft = false;
    
    // get a list of auths with the same ultimate parent auth   
    relatedAuthsList = [ select id, payer_authorization_id__c, received_date_time__c, type__c, authorization_status__c, Reason_for_New_Authorization__c, service_being_funded_string__c, rate__c, rate_unit__c, level__c, payer_effective_date__c, payer_end_Date__c, contract_used__c from authorization__c where original_auth__c = :authorization.original_auth__c and isRootAuth__c = false order by payer_effective_Date__c desc ];    //for ( Authorization__c r : relatedAuthsList) {
    for (Authorization__c r : relatedAuthsList ) {
            
        if ( r.Authorization_Status__c == 'Draft') {
            hasDraft = true;
            break;
        }
    }
    
}
    
    public pageReference redirectToView( ID authId, ID servAssign ) {
            PageReference pr = new PageReference('/apex/AuthorizationView?id=' + authId + '&saID=' + servAssign);
            pr.setRedirect( true);
            return pr;
    }
    
      
    public pageReference editAuth() {
        PageReference pr = new PageReference('/apex/AuthorizationEdit?id=' + authorization.Id + '&saID=' + saID + '&retURL=' + ApexPages.CurrentPage().getURL());
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

		if ( authorization.type__c != 'Other')
			authorization.other_authorization_Type__c = '';
		else {
			if ( String.IsEmpty( authorization.other_authorization_type__c)) {
				 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a description for the type of authorization.'));
           		 return null;
			}
		}
			
		if ( authorization.rate_unit__c != 'Unit')
			authorization.rate_unit_other__c = '';
		else {
			if ( String.IsEmpty( authorization.rate_unit_other__c)) {
				 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a description for the rate unit.'));
           		 return null;
			}
		}
        try {
            authorization.Authorization_Status__c = 'Draft';
            
            if ( authorization.type__c == 'Single Charge' ) {
            	authorization.payer_effective_date__c = authorization.received_date_time__c.date();
            	authorization.payer_end_date__c = authorization.payer_effective_date__c;
            }
            
            upsert authorization;
            
            if ( authorization.original_auth__c == null )
                authorization.original_auth__c = authorization.id;
        
        	return redirectToView( authorization.Id, saID );        
        }
        catch (Exception e) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save this authorization.'));
            return null;
        }

    }
    
    public PageReference finalizeAuth(){
        try{
            
            List<String> fielderrs = new List<String>();
            
            // check for required fields before finalizing
           
            if ( string.isblank(authorization.type__c)) {
            	fielderrs.add( 'Type');
            } 
		
 			if ( string.isblank( authorization.reason_for_new_Authorization__c)) {
            	fielderrs.add('Reason for New Authorization');
            }
            

			// put this here so we can preserve field order of Type and Reason
 			if ( !string.isblank( authorization.type__c)) {
            	if ( authorization.type__c == 'Open Ended Stay' || authorization.type__c == 'Defined Stay') {
            		if (string.isblank(authorization.service_Being_Funded_string__c)) {
            			fielderrs.add('Item/Service');
            		}
            		if (string.isblank(authorization.rate__c)) {
            			fielderrs.add('Rate');
            		}
            		if (string.isblank(authorization.rate_unit__c)) {
            			fielderrs.add('Per');
            		}
            		if (string.isblank(authorization.payer_authorization_id__c)) {
            			fielderrs.add('Authorization Number');
            		}
            	} else if (authorization.type__c == 'Open Ended Charge' || authorization.type__c == 'Other') {
            		if (string.isblank(authorization.service_Being_Funded_string__c)) {
            			fielderrs.add('Item/Service');
            		}
            		if (string.isblank(authorization.rate__c)) {
            			fielderrs.add('Rate');
            		}
            		if (string.isblank(authorization.rate_unit__c)) {
            			fielderrs.add('Per');
            		}
            		
            	} else if (authorization.type__c == 'Single Charge') {
            		if (string.isblank(authorization.service_Being_Funded_string__c)) {
            			fielderrs.add('Item/Service');
            		}
            		if (string.isblank(authorization.payer_authorization_id__c)) {
            			fielderrs.add('Authorization Number');
            		}
            		
            	} else if ( authorization.type__c == 'Bed Hold') {
            		if (string.isblank(authorization.bed_hold_type__c)) {
            			fielderrs.add('Bed Hold Type');
            		}
            		
            	}
            	
            }
            
            if ( fielderrs.size() > 0 ) {
            	
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in these fields to finalize the authorization:'));
	            for ( String e : fielderrs) {
	            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e));
	            }
            	return null;
            
            }
            
            
            
            
            
            
            
            // set status to final and save, then redirect to view page
            authorization.Authorization_Status__c = 'Final';  
            authorization.Finalized_at__c = DateTime.Now();
            authorization.Finalized_by__c = UserInfo.getUserId();
            
            upsert authorization;
            
            return redirectToView( authorization.Id, saID);
            
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public PageReference cloneAuth() {
        try {
            Authorization__c newauth = new Authorization__c( person_being_served__c = pbsID, funding_source__c = authorization.funding_source__c, type__c = authorization.type__c,
            												authorization_status__c = 'Draft', payer_authorization_id__c = authorization.payer_authorization_id__c);
           
            if ( authorization.type__c == 'Bed Hold') {
            	newauth.bed_hold_type__c = authorization.bed_hold_type__c;
            	newauth.bed_hold_type_detail__c = authorization.bed_hold_type_detail__c;
            	newauth.bed_hold_classification__c = authorization.bed_hold_classification__c;
            } else {
            	newauth.service_being_funded_string__c = authorization.service_being_funded_string__c;	
            } 
            
            if (authorization.type__c == 'Other') {
            	newauth.other_authorization_type__c = authorization.other_authorization_type__c; 
            }
            
            system.debug(newauth);
            upsert newauth;
            PageReference pr = new PageReference('/apex/AuthorizationEdit?id=' + newauth.Id + '&saID=' + saID + '&retURL=' + ApexPages.CurrentPage().getURL());
            pr.setRedirect(true);
            return pr;
        } 
        catch (Exception e) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to copy this authorization.'));
            return null;
        }
    }
    
    public PageReference reviseAuth() {
        try {
            // revision is a clone of the original with Draft status
            Authorization__c newauth = authorization.clone(false, true);
            newauth.Authorization_Status__c = 'Draft';
            
            // link up original to revision
            newauth.Parent_Auth__c = authorization.Id;  //direct parent
            newauth.Original_Auth__c = ( authorization.original_auth__c == null ) ? authorization.ID : authorization.original_auth__c;
            newauth.person_being_served__c= pbsID;
            upsert newauth;
            PageReference pr = new PageReference('/apex/AuthorizationEdit?id=' + newauth.Id + '&saID=' + saID);
            pr.setRedirect( true);
            return pr;
        } 
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to revise this authorization.'));
            return null;
        }
    }
    
    public pageReference disregardAuth(){
        try{
            // get the auth without any other changes that may be present on the screen
            Authorization__c a = [SELECT Id, Authorization_Status__c FROM Authorization__c WHERE Id =:authorization.Id ]; // To make sure only Status field is in scope.
            a.Authorization_Status__c = 'Disregard';  
            update a;
            
            return redirectToView( a.Id, saID );
            
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
    
    public void changeAuthType() {
    	system.debug( 'BEFORE: ' + authorization.type__c + ', ' + authorization.other_authorization_type__c);
    	if ( authorization.type__c != 'Other')
    		authorization.other_authorization_type__c = '';
    	
    	system.debug( 'AFTER: ' + authorization.type__c + ', ' + authorization.other_authorization_type__c);
    	 
    }
            
        
}