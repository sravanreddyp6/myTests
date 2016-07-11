public without sharing class TherapistLicExpiring {
    private String soql {get;set;}
    public list<TMN_User__c> therapistList {get;set;}
    public String sortDir {
        get {if(sortDir == null) { sortDir = 'Asc nulls last'; } return sortDir;}
        set;
    }
    public String sortField {
        get  { if (sortField == null) {sortField = 'First_Name__c'; } return sortField;  }
        set;
    }
    public String sortColumn { get; set; }
    public String sortOrder { get; set; }
    public TherapistLicExpiring() {
    	sortField = 'First_Name__c';
        soql = 'SELECT Id, Name, First_Name__c, Last_Name__c, Discipline__c, License_Expires__c, Insurance_Expires__c, CPR_Expires__c, Office_Phone__c, phone_ext__c, Mentor_Cell_Phone__c, Personal_Email__c, Salesforce_User_Account__c, job_Status__c ' +
                   'FROM TMN_User__c Where Discipline__c != \'\' and operating_group__c = \'Care Meridian\' and Salesforce_User_Account__r.IsActive = true ' +
                   'and (License_Expires__c <= NEXT_N_DAYS:30 OR License_Expires__c = null OR Insurance_Expires__c <= NEXT_N_DAYS:30 OR Insurance_Expires__c = null OR CPR_Expires__c <= NEXT_N_DAYS:30 OR CPR_Expires__c = null)'; 
        runQuery();
    }
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc nulls Last' : 'asc';
        runQuery();
    }
    public void runQuery() {
       try {
            therapistList = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an error retrieving the Therapist records.'));
        }
        
    }
}