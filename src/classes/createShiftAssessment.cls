public with sharing class createShiftAssessment {
	
	public string shiftStartTime {get; set;}
	public string shiftEndTime {get; set;}
	public Evaluation__c eval {get; private set;}
	
	public createShiftAssessment () {
		eval = new Evaluation__c();
		
		
	}
	public pageReference proceed() {
		Evaluation__c shiftAsmt = new Evaluation__c ();
		shiftAsmt.RecordtypeId = Utility.getEValuationRecordType('CMShiftAssessment');
		shiftAsmt.Name = 'ShiftAssessment' + DateTime.Now().format('MMddyy');
		shiftAsmt.Status__c = 'Draft';
		shiftAsmt.Shift_Start_time__c = eval.Shift_Start_time__c;
		shiftAsmt.Shift_End_time__c = eval.Shift_End_time__c;
		
		insert shiftAsmt;
		
		
		return new PageReference ('/apex/CMShiftAssessmentEdit?id='+shiftAsmt.id);
	}

}