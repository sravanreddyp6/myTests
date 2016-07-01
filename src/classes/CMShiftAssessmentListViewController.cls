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
  
   public Id saId {get; private set;}
   //public string evalrecType{get; private set;}
   public Boolean isShift {get; set;}
   public Boolean isResidential {get; set;}
   public Boolean isRestraint {get; set;}
   public Boolean isCNA { get; set; }
   public Service_Assignment__c SA {get; private set;}
   public String sortColumn { get; set; }
   public String sortOrder { get; set; }
	
  
   public CMShiftAssessmentListViewController() {
  	if( ApexPages.currentPage().getParameters().get('saId') != null) {
		saId = ApexPages.currentPage().getParameters().get('saId');
		SA = [SELECT Id, Admission__c, admission__r.Person_Being_Served__c FROM Service_Assignment__c WHERE Id=:saId LIMIT 1];
		
		string evaltype = ApexPages.currentPage().getParameters().get('recType') ;
		isShift = ( evaltype == 'Nurses Shift Documentation');
		isResidential = (evaltype == 'Residential');
		isRestraint = (evaltype == 'Restraint Event');
		isCNA = (evaltype == 'CNA Workbook');
		
	  //	soql = 'SELECT ID, Name, LastModifiedDate, Is_Signed__c, Shift_Start_time__c, Shift_end_time__c, Status__c,Owner.Name,(SELECT Id, CreatedDate, Owner.Name, Owner.Id FROM Evaluation_Responses__r WHERE RecordType.Name = \'E-Signature\' ORDER BY CreatedDate DESC) FROM Evaluation__c  WHERE ServiceAssignment__c = :saId';
	  	if(isShift){
	  		soql = 'SELECT ID, Name, LastModifiedDate, Shift_Start_time__c, Shift_end_time__c, Status__c, Is_Signed__c, Head_to_toe_Status__c, Signed_At__c, Head_to_toe_Signed_At__c, Owner.Name FROM Evaluation__c  WHERE ServiceAssignment__c = :saId AND Recordtype.Name = \'CMShiftAssessment\'';
	  	}
	  	
	  	if(isResidential){
	  		soql = 'SELECT ID, Name, LastModifiedDate, Shift_Start_time__c, Shift_end_time__c, Status__c, Is_Signed__c, Head_to_toe_Status__c, Signed_At__c, Head_to_toe_Signed_At__c, Owner.Name FROM Evaluation__c  WHERE ServiceAssignment__c = :saId AND Recordtype.Name = \'NursesAssessment\'';
	  	}
	  	
	  	if(isRestraint){
	  		soql = 'SELECT ID, Name, LastModifiedDate, Shift_Start_time__c, Shift_end_time__c, Status__c, Is_Signed__c, Head_to_toe_Status__c, Signed_At__c, Head_to_toe_Signed_At__c, Owner.Name FROM Evaluation__c  WHERE ServiceAssignment__c = :saId AND Recordtype.Name = \'RestraintEvent\'';
	  	}
	  	if(isCNA){
	  		soql = 'SELECT ID, Name, LastModifiedDate, Shift_Start_time__c, Shift_end_time__c, Status__c, Is_Signed__c,  Signed_At__c, Owner.Name FROM Evaluation__c  WHERE ServiceAssignment__c = :saId AND Recordtype.DeveloperName = \'CNA_Workbook\'';
	  	}
	  	
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
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an Error is retrieving the Records. Please contact your Administrator'));
    }

  }
  
}