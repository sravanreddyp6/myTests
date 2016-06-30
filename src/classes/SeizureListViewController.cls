public with sharing class SeizureListViewController {
    private String soql {get;set;}
    public List<Seizure__c> seizures {get; set;}
    
    public String sortDir {
        get {if(sortDir == null) { sortDir = 'Desc nulls Last'; } return sortDir;}
        set;
    }
    
    public String sortField {
        get  { if (sortField == null) {sortField = 'Start_DateTime__c'; } return sortField;  }
        set;
    }
   
    public Id saId {get; private set;}
    public Service_Assignment__c SA {get; private set;}
    public String sortColumn { get; set; }
    public String sortOrder { get; set; }
	  
    public SeizureListViewController() {
        if( ApexPages.currentPage().getParameters().get('saId') != null) {
	        saId = ApexPages.currentPage().getParameters().get('saId');
	        SA = [SELECT Id, Name, Admission__c, admission__r.Person_Being_Served__c FROM Service_Assignment__c WHERE Id=:saId LIMIT 1];
	        soql = 'select id, Name, Start_DateTime__c, End_DateTime__c, Observed_By__c, Comments__c, Duplicate_Entry__c from Seizure__c where Service_Assignment__c = :saId';
	        runQuery();
	    }
    }
	  
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc nulls Last' : 'asc';
        runQuery();
    }
	  
	public void runQuery() {
	   try {
            seizures = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an Error is retrieving the seizures Records'));
	    }
	    
    }
    
}