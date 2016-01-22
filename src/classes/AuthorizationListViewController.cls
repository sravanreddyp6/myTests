public with sharing class AuthorizationListViewController {

    private String soql {get;set;}
    public transient List<Authorization__c> auths {get; set;}
    
    public String sortDir {
        get {if(sortDir == null) { sortDir = 'Desc nulls Last'; } return sortDir;}
        set;
    }
    
    public String sortField {
        get  { if (sortField == null) {sortField= 'payer_effective_date__c'; } return sortField;  }
        set;
    }
   
    public Id saId {get; private set;}
    public Service_Assignment__c SA {get; private set;}
	  
    public AuthorizationListViewController() {
        if( ApexPages.currentPage().getParameters().get('saId') != null) {
	        saId = ApexPages.currentPage().getParameters().get('saId');
	        SA = [SELECT Id, Name, Admission__c, admission__r.Person_Being_Served__c FROM Service_Assignment__c WHERE Id=:saId LIMIT 1];
	        soql = 'select id, funding_Source__c, payer_authorization_id__c, authorization_Status__c, type__c, service_being_Funded_string__c, rate__c, rate_unit__c, level__c, payer_effective_Date__c, payer_end_date__c, received_date_time__c, contract_used__c ' + 
				 'from Authorization__c' + 
				 ' where funding_source__r.Service_Assignment__c = :saID';
				// (authsIncDisregard ? ''  : 'and authorization_status__c != \'Disregard\'') +
	        runQuery();
	    }
    }
	  
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc nulls Last' : 'asc';
        runQuery();
    }
	  
	public void runQuery() {
	   try {
            auths = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' LIMIT 10000');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an error retrieving the authorization records.'));
	    }
	    
    }
    
}