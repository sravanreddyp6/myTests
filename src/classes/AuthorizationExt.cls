// Extension class to handle CMAUTH tickets - Sept 2015
public with sharing class AuthorizationExt {

public ID saID { get; set; }
public ID admID { get; set; }
public ID pbsID { get; set; }
public Authorization__c authorization { get; set; }
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
    
    if (controller.getId() != null ) {
        authorization = (Authorization__c)controller.getRecord();
        authorization = [ select id, authorization_status__c, type__c, other_authorization_type__c, reason_for_new_authorization__c, service_being_funded_string__c, payer_authorization_id__c,
                            rate__c, received_date_time__c, rate_unit__c, rate_unit_other__c, payer_effective_date__c, payer_end_date__c, funding_source__c, funding_source__r.payer_name__c, contract_used__c, 
                            received_from__c, taken_by__c, level__c, justification__c, representing_received__c,  auth_given_method__c, comments__c, 
                            bed_hold_type__c, bed_hold_type_detail__c, bed_hold_additional_detail__c, bed_hold_classification__c, parent_auth__c, original_auth__c
                            from authorization__c
                            where id = :controller.getRecord().Id ];
    }
    else
        authorization = new Authorization__c();


    Schema.DescribeSObjectResult oSchema = Authorization__c.sObjectType.getDescribe();
    canCreateAuth = oSchema.isCreateable();
    canEditAuth = oSchema.isUpdateable();
    canFinalize = true; //udpate with perms later
    
    hasDraft = false;
    
    // get a list of auths with the same ultimate parent auth   
    relatedAuthsList = [ select id, received_date_time__c, type__c, authorization_status__c, Reason_for_New_Authorization__c, rate__c, rate_unit__c, level__c, payer_effective_date__c, payer_end_Date__c, contract_used__c from authorization__c where original_auth__c = :authorization.original_auth__c and isRootAuth__c = false order by payer_effective_Date__c desc ];    //for ( Authorization__c r : relatedAuthsList) {
    for (Authorization__c r : relatedAuthsList ) {
            
        if ( r.Authorization_Status__c == 'Draft') {
            hasDraft = true;
            break;
        }
    }
    
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
            
            if ( authorization.original_auth__c == null )
                authorization.original_auth__c = authorization.id;
                
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
            
            // TO DO: check for required fields before finalizing
            // set status to final and save, then redirect to view page
            authorization.Authorization_Status__c = 'Final';  
            authorization.Finalized_at__c = DateTime.Now();
            authorization.Finalized_by__c = UserInfo.getUserId();
            
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
            Authorization__c newauth = authorization.clone(false, true);
            
            // clear out revision history
            newauth.parent_auth__c = null;
            newauth.original_auth__c = null;
            newauth.person_being_served__c = pbsID;	// set the parent of master-detail
            newauth.authorization_status__c = 'Draft';
            system.debug(newauth);
            upsert newauth;
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
            Authorization__c newauth = authorization.clone(false, true);
            newauth.Authorization_Status__c = 'Draft';
            
            // link up original to revision
            newauth.Parent_Auth__c = authorization.Id;  //direct parent
            newauth.Original_Auth__c = ( authorization.original_auth__c == null ) ? authorization.ID : authorization.original_auth__c;
            newauth.person_being_served__c= pbsID;
            upsert newauth;
            PageReference pr = new PageReference('/apex/EditAuthorization?id=' + newauth.Id + '&saID=' + saID);
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