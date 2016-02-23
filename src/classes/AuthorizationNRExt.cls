public with sharing class AuthorizationNRExt {

public string saID { get; set; }
public ID admID { get; set; }
public ID pbsID { get; set; }

public Authorization__c authorization { get; set; }
public service_assignment__c theSA {get; set;}
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
        saID = ApexPages.currentPage().getParameters().get('saID'); 
        ID authID = ApexPages.currentPage().getParameters().get('ID');
        List<Funding_Source__c> fsources;
        fsources = new List<Funding_Source__c>(); 
        if (authorization.id != null){
            theSA = [select id, admission__c, person_being_served__c, Service_Location__r.Room_and_Board_Rate__c, Service_Location__r.PRN_DS_Per_Hour__c, Service_Location__r.Per_Productive_Unit__c from service_assignment__c where id = :authorization.service_assignment__c LIMIT 1];
            fsources =  [ select id, name, type_of_coverage__c, payer_name__c, cm_contract_used_lookup__r.name from funding_source__c where service_assignment__c = :theSA.id and status__c != 'Inactive' order by type_of_coverage__c, payer_name__c];
            
            
        }
        else {
            fsources =  [ select id, name, type_of_coverage__c, payer_name__c, cm_contract_used_lookup__r.name from funding_source__c where service_assignment__c = :saID and status__c != 'Inactive' order by type_of_coverage__c, payer_name__c];
            theSA = [ select id, admission__c, person_being_served__c, Service_Location__r.Room_and_Board_Rate__c, Service_Location__r.PRN_DS_Per_Hour__c, Service_Location__r.Per_Productive_Unit__c from service_assignment__c where id = :saID LIMIT 1];
            authorization.recordtypeid = [select id from recordtype where SobjectType = 'Authorization__c' and developername = 'Funding_Source_Auth_NR'].id;
            authorization.Admission__c = theSA.Admission__c;    
            authorization.Person_Being_Served__c = theSA.person_being_served__c;
            authorization.service_assignment__c = theSA.id;
            authorization.Authorization_Status__c = 'Draft';
            
        }
       // else
        //    
        
        fsList = new List<SelectOption>();
        for ( Funding_Source__c f: fsources ) {
            
            SelectOption option = new SelectOption( f.id, f.type_of_coverage__c );
            fsList.Add( option );
        }
    

   
    if (authID != null ) {
           if ( ApexPages.currentPage().getURL().contains('Edit') && authorization.authorization_status__c == 'Final') {
            // cannot edit a Final  
            redirectToView( authorization.id, saID);
       } 
        
    
    }

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
            PageReference pr = new PageReference('/apex/AuthorizationNRView?id=' + authId );
            pr.setRedirect( true);
            return pr;
    }
    
      
    public pageReference editAuth() {
        PageReference pr = new PageReference('/apex/AuthorizationNREdit?id=' + authorization.Id);
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
         List<String> fielderrs = new List<String>(); 
            if ( string.isBlank(authorization.Rate__c) ) {
                fielderrs.add('Please choose enter a Rate');
                
            }         
         if( !authorization.Open_Ended_Contract_Life_Span_Contract__c){ 
            if ( string.isBlank(string.valueof(authorization.Days_Authorized_from__c)) ) {
                fielderrs.add('Please choose an Authorization From Date');
                
            } 
            if ( string.isBlank(string.valueof(authorization.Days_Authorized_To__c )) ) {
                fielderrs.add('Please choose an Authorization To Date');
                
            } 
        }
                                      
        if ( fielderrs.size() > 0 ) {
        
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in these fields to finalize the authorization:'));
            for ( String e : fielderrs) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e));
            }    
            
            return null;
            //       
        }
      
        upsert authorization;
        return redirectToView( authorization.Id, theSA.id ); 
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to save this authorization.'));
            return null;
        }
        return null;

    }
    
    public PageReference finalizeAuth(){
        try{
            
            List<String> fielderrs = new List<String>();
            
            // check for required fields before finalizing
           /*
            if ( string.isblank(authorization.contract__c)) {
                fielderrs.add( 'Contract');
            }
            */ 
        
 
            if ( fielderrs.size() > 0 ) {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in these fields to finalize the authorization:'));
                for ( String e : fielderrs) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e));
                }
                return null;
            
            }
            for(authorization__c a :[select id, name from authorization__c where Authorization_Status__c = 'Active Final' AND service_assignment__c = :theSA.id]){
                //only one record should return
                a.Authorization_Status__c = 'Inactive Final';
                update a;
            }            
            // set status to final and save, then redirect to view page
            authorization.Authorization_Status__c = 'Active Final';  
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
    
    
    public PageReference reviseAuth() {
        try {
            // revision is a clone of the original with Draft status
            Authorization__c newauth = authorization.clone(false, true);
            newauth.Authorization_Status__c = 'Draft';
            
            // link up original to revision
            newauth.Parent_Auth__c = authorization.Id;  //direct parent
            newauth.Original_Auth__c = ( authorization.original_auth__c == null ) ? authorization.ID : authorization.original_auth__c;
            newauth.person_being_served__c= theSA.Person_Being_Served__c;
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