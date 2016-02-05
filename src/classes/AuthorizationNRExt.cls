public with sharing class AuthorizationNRExt {

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

public static map<string, list<string>> dependentPL1 { get; set; }
public static map<string, list<string>> dependentPL2 { get; set; }
public String mapdepPL1 {get{system.debug( dependentPL1); return JSON.serialize(dependentPL1);}}
public String mapdepPL2 {get{return JSON.serialize(dependentPL2);}}

public AuthorizationNRExt(ApexPages.StandardController controller) {
    controller.addFields(new List<String>{'Original_Auth__c','Authorization_Status__c','Requested_By__c','Request_Date__c','Request_Contact_Name__c','Request_Phone__c','Request_Fax__c','Received_From__c','Days_Authorized__c','Days_Authorized_from__c',
    'Parent_Auth__c'});
    authorization = (Authorization__c)controller.getRecord();
     // service assignment ID is passed in - get the other params needed for personal record connection
    saID = ApexPages.currentPage().getParameters().get('saID');
    
    
    ID authID = ApexPages.currentPage().getParameters().get('ID');
    system.debug( authID );
    
    List<Funding_Source__c> fsources;
    Service_Assignment__c sa = new Service_Assignment__c();
    if ( saID != null ) {
        fsources =  [ select id, name, type_of_coverage__c, payer_name__c, cm_contract_used_lookup__r.name from funding_source__c where service_assignment__c = :saID and status__c != 'Inactive' order by type_of_coverage__c, payer_name__c];
        sa = [ select id, admission__c, admission__r.person_being_served__c from service_assignment__c where id = :saID LIMIT 1];
        if ( sa != null ) {
            admID = sa.Admission__c;
            pbsID = sa.Admission__r.Person_Being_Served__c;
        }
    }
    else
    
        fsources = new List<Funding_Source__c>(); 
    

   
    if (authID != null ) {
           if ( ApexPages.currentPage().getURL().contains('Edit') && authorization.authorization_status__c == 'Final') {
            // cannot edit a Final  
            redirectToView( authorization.id, saID);
       } 
        
    
    }
    else
        authorization = new Authorization__c( recordtypeID= ApexPages.currentPage().getParameters().get('RecordType'), person_being_served__c = pbsID, authorization_status__c = 'Draft', admission__c = sa.admission__c );


    Schema.DescribeSObjectResult oSchema = Authorization__c.sObjectType.getDescribe();
    canCreateAuth = oSchema.isCreateable();
    canEditAuth = oSchema.isUpdateable();
    canFinalize = true; //udpate with perms later
    
    hasDraft = false;
    
    // get a list of auths with the same ultimate parent auth, or same direct parent  
    
    if ( authorization.original_auth__c != null )  
        relatedAuthsList = [ select id, payer_authorization_id__c, received_date_time__c, type__c, authorization_status__c, Reason_for_New_Authorization__c, service_being_funded_string__c, rate__c, rate_unit__c, level__c, payer_effective_date__c, payer_end_Date__c, contract_used__c 
                        from authorization__c 
                        where (original_auth__c = :authorization.original_auth__c or id = :authorization.original_auth__c or id = :authorization.parent_auth__c) and id != :authorization.id 
                        order by payer_effective_Date__c desc ];
    else // get children
        relatedAuthsList = [ select id, payer_authorization_id__c, received_date_time__c, type__c, authorization_status__c, Reason_for_New_Authorization__c, service_being_funded_string__c, rate__c, rate_unit__c, level__c, payer_effective_date__c, payer_end_Date__c, contract_used__c 
                        from authorization__c 
                        where (original_auth__c = :authorization.id or parent_auth__c = :authorization.id ) and id != :authorization.id 
                        order by payer_effective_Date__c desc ];
      
    for (Authorization__c r : relatedAuthsList ) {
            
        if ( r.Authorization_Status__c == 'Draft') {
            hasDraft = true;
            break;
        }
    }
    
}

     
       
    public pageReference redirectToView( ID authId, ID servAssign ) {
            PageReference pr = new PageReference('/apex/AuthorizationNRView?id=' + authId + '&saID=' + servAssign);
            pr.setRedirect( true);
            return pr;
    }
    
      
    public pageReference editAuth() {
        PageReference pr = new PageReference('/apex/AuthorizationNREdit?id=' + authorization.Id + '&saID=' + saID + '&retURL=' + ApexPages.CurrentPage().getURL());
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
    try{
            upsert authorization;
        
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
           
            if ( string.isblank(authorization.contract__c)) {
                fielderrs.add( 'Contract');
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
            Authorization__c newauth = new Authorization__c( 
                person_being_served__c = pbsID, 
                authorization_status__c = 'Draft', 
                recordtypeId = authorization.recordtypeId);
           
            
            system.debug(newauth);
            upsert newauth;
            PageReference pr = new PageReference('/apex/AuthorizationNREdit?id=' + newauth.Id + '&saID=' + saID + '&retURL=' + ApexPages.CurrentPage().getURL());
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
            PageReference pr = new PageReference('/apex/AuthorizationNREdit?id=' + newauth.Id + '&saID=' + saID);
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
    

            
        
}