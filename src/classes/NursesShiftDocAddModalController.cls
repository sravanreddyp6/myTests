public with sharing class NursesShiftDocAddModalController {
	public Service_Assignment__c serviceAssignment { get; set; }
	public String evalType { get; set; }

	public Id serviceAssignmentId {
		get;
		set {
			if (value == null) {
				return;
			}
			serviceAssignment = [
				SELECT Id, Admission__r.Person_Being_Served__r.LastName, Admission__r.Person_Being_Served__r.FirstName
				  FROM Service_Assignment__c
				 WHERE Id=:value
			];
			serviceAssignmentId = value;
		}
	}

	public Evaluation__c shiftDoc {
		get{
			if (shiftDoc == null) {
				shiftDoc = new Evaluation__c();
			}
			return shiftDoc;
		}
		set;
	}

	public void showAddShiftDoc() {
		shiftDoc = new Evaluation__c();
		String pbsLastName = this.serviceAssignment.Admission__r.Person_Being_Served__r.LastName != null ? this.serviceAssignment.Admission__r.Person_Being_Served__r.LastName : '' ;
		string pbsFirstinitial = this.serviceAssignment.Admission__r.Person_Being_Served__r.FirstName != null ? this.serviceAssignment.Admission__r.Person_Being_Served__r.FirstName.substring(0, 1) : '';
		shiftDoc = new Evaluation__c();
		shiftDoc.Name = pbsFirstinitial+'. ' + pbsLastName;
		shiftDoc.RecordTypeID = Utility.getEvaluationRecordType(evalType);
		shiftDoc.ServiceAssignment__c = this.serviceAssignment.Id;
		shiftDoc.Status__c = 'Draft';
		if ( evalType == 'CMShiftAssessment')
			shiftDoc.Head_to_Toe_Status__c = 'Draft'; //Added by Sravan to differentiate Head to Toe Status from Shift Status
	}

	public pageReference saveShiftDoc() {
		String ownerfirstInitial = UserInfo.getFirstName() != null ? UserInfo.getFirstName().Substring(0,1) : '';

		String docType = evalType == 'CMShiftAssessment' ? 'NSD' : 'CNA';
		shiftDoc.Name = this.shiftDoc.Name + ' - ' + shiftDoc.Shift_Start_time__c.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString()) + ' - ' + docType + ' - ' + ownerfirstInitial + '. ' + UserInfo.getLastName();
		insert shiftDoc;
		return new PageReference('/apex/EvaluationView?id=' + shiftDoc.Id);
	}

	@RemoteAction
	public static boolean findDupeEval(string shiftStart, string shiftEnd, Id saId, string evalType) {
		DateTime st = Datetime.parse(shiftStart);
		DateTime en = Datetime.parse(shiftEnd);

		List<Evaluation__c> dupeEval = [
			SELECT Id, Name, Shift_Start_time__c, Shift_end_time__c
			FROM Evaluation__c
			WHERE ServiceAssignment__c = :saId
			  AND ((Shift_Start_time__c >= :st and Shift_Start_time__c <= :en)
			        OR (Shift_end_time__c >= :st and Shift_end_time__c <= :en)
			        OR (Shift_Start_time__c <= :st and Shift_end_time__c >= :en))
			  AND RecordType.Name = :evalType
			  AND Status__c !='Disregard' LIMIT 1
		];

		if(dupeEval.size() >0 ) {
			return true;
		}

		return false;
	}
}