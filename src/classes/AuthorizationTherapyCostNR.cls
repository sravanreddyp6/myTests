public with sharing class AuthorizationTherapyCostNR {
    Final String rateMissingMSG = 'You will not be able to save, There isn\'t an Authorization with the status of Final for this Service Assignment';
    public string saID { get; set; }

    public service_assignment__c theSA {get; set;}
    public List<SelectOption> fsList { get; set; }
    public Authorization__c authorization { get; set; }
    public AuthorizationTherapyCostNR(ApexPages.StandardController controller) {

         // service assignment ID is passed in - get the other params needed for personal record connection
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
            authorization.recordtypeid = [select id from recordtype where SobjectType = 'Authorization__c' and developername = 'Costs_TherapyNR'].id;
            
            for(authorization__c a : [select id, rate__c from authorization__c where authorization_status__c = 'Final' and service_assignment__c = :saID and recordtype.developername = 'Funding_Source_Auth_NR']){
                authorization.rate__c = a.rate__c;
            }
            if (authorization.rate__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, rateMissingMSG));
                
            authorization.Person_Being_Served__c = theSA.person_being_served__c;
            authorization.service_assignment__c = theSA.id;
            
        }
       // else
        //    
        
        fsList = new List<SelectOption>();
        for ( Funding_Source__c f: fsources ) {
            
            SelectOption option = new SelectOption( f.id, f.type_of_coverage__c + ' - ' + f.CM_Contract_Used_Lookup__r.Name );
            fsList.Add( option );
        }

    }


    public pageReference redirectToView( ID authId, ID servAssign ) {
            PageReference pr = new PageReference('/apex/AuthorizationTherapyCostNRView?id=' + authId + '&saID=' + servAssign);
            pr.setRedirect( true);
            return pr;
    }
    
    public pageReference saveAuth() {
        List<String> fielderrs = new List<String>();
        if ( authorization.funding_source__c == null ) {
            fielderrs.add('Please choose a funding source.');
            
        } 
        if ( string.isblank(authorization.Case_Manager__c) ) {
            fielderrs.add('Please choose a Case Manager');
            
        }   
        if ( authorization.Effective_Date_of_Cost_Therapy__c ==null ) {
            fielderrs.add('Please choose an Effective Date of Cost/Therapy');
            
        } 
        if ( authorization.Term_Date_of_Cost_Therapy__c == null ) {
            fielderrs.add('Please choose a Term Date of Cost/Therapy');
            
        } 
        if ( authorization.Rate__c == null ) {
            fielderrs.add('Rate is blank');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, rateMissingMSG));
            
        }        
        if ( string.isblank(authorization.Staffing_Ratio_1_1__c) ) {
            fielderrs.add('Please choose a Staffing Ratio');
            
        } 
        if ( string.isblank(authorization.Number_of_Hrs_Expected__c) ) {
            fielderrs.add('Please choose Number of Hrs. Expected');
            
        }                                       
        if ( fielderrs.size() > 0 ) {
        
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in these fields to finalize the authorization:'));
            for ( String e : fielderrs) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e));
            }
            return null;
        }         
        upsert authorization;
        
        return redirectToView( authorization.Id, saID );             
        
    }
    public pageReference cancelAuth() {
    		if(authorization.Id != null){
            	PageReference pr = new PageReference('/apex/AuthorizationTherapyCostNRView?id=' + authorization.Id);
            	pr.setRedirect( true);
            	return pr;
    		}
    		    PageReference pr = new PageReference('/apex/ServiceAssignmentEditNew?id=' + theSA.Id);
            	pr.setRedirect( true);
            	return pr;
    		
    }
    public pageReference editAuth() {
            PageReference pr = new PageReference('/apex/AuthorizationTherapyCostNREdit?id=' + authorization.Id);
            pr.setRedirect( true);
            return pr;
    }    

}