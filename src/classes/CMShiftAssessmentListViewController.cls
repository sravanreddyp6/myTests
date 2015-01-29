public with sharing class CMShiftAssessmentListViewController {
	
	private String soql {get;set;}
	public List<Evaluation__c> evaluations {get; set;}
	
	public String sortDir {
		get {if(sortDir == null) { sortDir = 'Desc nulls Last'; } return sortDir;}
		set;
	}
	
	public String sortField {
    get  { if (sortField == null) {sortField = 'Shift_Start_time__c'; } return sortField;  }
    set;
   }
  
   public String debugSoql  {
    get { return soql + ' order by ' + sortField + ' ' + sortDir; }
    set;
   }
  
   public Id saId {get; private set;}
   public Service_Assignment__c SA {get; private set;}
   public String sortColumn { get; set; }
   public String sortOrder { get; set; }
	
  
   public CMShiftAssessmentListViewController() {
  	if( ApexPages.currentPage().getParameters().get('saId') != null) {
		saId = ApexPages.currentPage().getParameters().get('saId');
		SA = [SELECT Id, Admission__c, admission__r.Person_Being_Served__c FROM Service_Assignment__c WHERE Id=:saId LIMIT 1];
	  	soql = 'SELECT ID, Name, LastModifiedDate, Is_Signed__c, Shift_Start_time__c, Shift_end_time__c, Status__c,Owner.Name,(SELECT Id, CreatedDate, Owner.Name, Owner.Id FROM Evaluation_Responses__r WHERE RecordType.Name = \'E-Signature\' ORDER BY CreatedDate DESC) FROM Evaluation__c  WHERE ServiceAssignment__c = :saId';
	  	runQuery();
  	}
  }
  
  public void toggleSort() {
    sortDir = sortDir.equals('asc') ? 'desc nulls Last' : 'asc';
    runQuery();
  }
  
   public void runQuery() {
    try {
      evaluations = Database.query(soql + ' order by ' + sortField + ' ' + sortDir);
    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
    }

  }
  
}