public with sharing class AuthorizationTherapyCostNR {
    //comment added to create diff by AV
    Final String rateMissingMSG = 'You will not be able to save, There isn\'t an Authorization with the status of Final for this Service Assignment';
    public string saID { get; set; }

    public service_assignment__c theSA {get; set;}
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
        }
        else {
            theSA = [ select id, admission__c, person_being_served__c, Service_Location__r.Room_and_Board_Rate__c, Service_Location__r.PRN_DS_Per_Hour__c, Service_Location__r.Per_Productive_Unit__c from service_assignment__c where id = :saID LIMIT 1];
            authorization.recordtypeid = [select id from recordtype where SobjectType = 'Authorization__c' and developername = 'Costs_TherapyNR'].id;
            
            for(authorization__c a : [select id, rate__c from authorization__c where authorization_status__c = 'Active Final' and service_assignment__c = :saID and recordtype.developername = 'Funding_Source_Auth_NR']){
                authorization.rate__c = a.rate__c;
                authorization.Master_Authorization__c = a.id;
            }
            if (authorization.rate__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, rateMissingMSG));
                
            authorization.Person_Being_Served__c = theSA.person_being_served__c;
            authorization.service_assignment__c = theSA.id;
            
        }
       // else
        //    
        

    }


    public pageReference redirectToView( ID authId, ID servAssign ) {
            PageReference pr = new PageReference('/apex/AuthorizationTherapyCostNRView?id=' + authId + '&saID=' + servAssign);
            pr.setRedirect( true);
            return pr;
    }
    
    public pageReference saveAuth() {
        List<String> fielderrs = new List<String>();
        if ( string.isblank(authorization.Case_Manager__c) ) {
            fielderrs.add('Please choose a Case Manager');
            
        }   
        if ( authorization.Effective_Date_of_Cost_Therapy__c ==null ) {
            fielderrs.add('Please choose an Effective Date of Cost/Therapy');
            
        } 
        if ( authorization.Term_Date_of_Cost_Therapy__c == null ) {
            fielderrs.add('Please choose a Term Date of Cost/Therapy');
            
        } 
        if ( authorization.Rate__c == null || authorization.Rate__c == '') {
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