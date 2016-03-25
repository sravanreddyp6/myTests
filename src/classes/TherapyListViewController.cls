public with sharing class TherapyListViewController {
    private String soql {get;set;}
    public List<Therapy_Hour__c> therapyList {get; set;}
    
    public String sortDir {
        get {if(sortDir == null) { sortDir = 'Desc nulls Last'; } return sortDir;}
        set;
    }
    
    public String sortField {
        get  { if (sortField == null) {sortField = 'Start_Time__c'; } return sortField;  }
        set;
    }
   
    public Id saId {get; private set;}
    public Service_Assignment__c SA {get; private set;}
    public String sortColumn { get; set; }
    public String sortOrder { get; set; }
      
    public TherapyListViewController() {
        if( ApexPages.currentPage().getParameters().get('saId') != null) {
            saId = ApexPages.currentPage().getParameters().get('saId');
            SA = [SELECT Id, Name, Admission__c, admission__r.Person_Being_Served__c FROM Service_Assignment__c WHERE Id=:saId LIMIT 1];
            soql = 'select Id,Appointment_Type__c,End_Time__c,Narrative_Note__c,Number_of_Hours__c,Start_Time__c, Owner.Name from Therapy_Hour__c ' + 
                 ' where Service_Assignment__c = :saID and status__c = \'Approved\' ';
            runQuery();
        }
    }
      
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc nulls Last' : 'asc';
        runQuery();
    }
      
    public void runQuery() {
       try {
            therapyList = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an error retrieving the Therapy records.'));
        }
        
    }
    
}