public with sharing class CMShiftAssessmentEsign implements AuthenticatedAction {
	public PageReference handle(Id recordId, Id userId) {
		string recId = string.valueOf(recordId);
		Evaluation__c assessment = [SELECT Id, OwnerId, Status__c,Head_to_toe_Status__c,Is_Being_Signed__c, Is_Signed__c,Shift_Start_time__c, Shift_End_time__c, Recordtype.Name, ServiceAssignment__c FROM Evaluation__c WHERE id=: recordId];
		list<Service_Assignment__c> servAssign = [SELECT ID, (SELECT Id FROM Evaluations__r Where Status__c != 'Disregard' AND Recordtype.Name ='NursesAssessment' order by createdDate asc) FROM Service_Assignment__c WHERE Id=: assessment.ServiceAssignment__c LIMIT 1];
		List<Assessment__c> asmtsforRestraints = new List<Assessment__c>();
		if(assessment.Recordtype.name == 'CMShiftAssessment' && assessment.Head_to_toe_Status__c == 'Draft'){
			assessment.Head_to_Toe_Status__c = 'Final';  // When finalize head to toe button is clicked
			assessment.Head_to_Toe_Signed_At__c = System.Now();
			if (assessment.OwnerId != UserInfo.getUserId()) {  // EC-163
				assessment.Status__c = 'End of Shift';
				assessment.Signed_At__c = System.now();
				assessment.Signed_By__c = UserInfo.getUserId();
			}
		} else if(assessment.Recordtype.name == 'CMShiftAssessment' && assessment.Head_to_toe_Status__c == 'Final'){
			assessment.Status__c = 'Completed'; // When Done button is clicked.
			assessment.Signed_At__c = system.Now();
		} else if(assessment.Recordtype.Name == 'NursesAssessment' && assessment.Id == servAssign[0].Evaluations__r[0].Id){
			assessment.Status__c = 'Final Admission';
			assessment.Signed_At__c = system.Now();
		} else if(assessment.Recordtype.Name == 'NursesAssessment' && assessment.Id != servAssign[0].Evaluations__r[0].Id){
			assessment.Status__c = 'Final Revision';
			assessment.Signed_At__c = system.Now();
		} else if(assessment.RecordType.name == 'RestraintEvent' && assessment.Status__c == 'Not Restrained') {
			List<Eval_value__c> restraintAction = [SELECT Id, Text_Under_250__c,Eval__r.Field_Name__c, Date_Time__c FROM Eval_Value__c WHERE What_Id__c = :recId AND What_Id_Object__c = 'Evaluation__c' AND (Eval__r.Field_Name__c = 'Restraint Action' OR Eval__r.Field_Name__c ='Start Date/Time')];
			if(restraintAction.size() > 0){
				for(Eval_Value__c value: restraintAction){
					if(value.Eval__r.Field_Name__c == 'Restraint Action'){
						assessment.Status__c = value.Text_Under_250__c;
					}
					if(value.Eval__r.Field_Name__c == 'Start Date/Time' && value.Date_Time__c != null){
						assessment.Shift_Start_time__c = value.Date_Time__c;
					}
				}
				assessment.Signed_At__c = system.Now();
			}

		} else if(assessment.RecordType.name == 'RestraintEvent' && (assessment.Status__c == 'Applied Alternative to Restraint' || assessment.Status__c == 'Applied Restraint')){
			assessment.Status__c = 'Restraint Event Ended';
		//	assessment.Shift_End_time__c = system.now();
			List<Assessment__c> asmts = [SELECT Id, Status__c FROM Assessment__c WHERE Evaluation__c = :assessment.Id];
			if(asmts.size() > 0){
				for(Assessment__c a: asmts){
					if(a.Status__c == 'Open'){
						a.Status__c = 'Completed';
						asmtsforRestraints.add(a);
					}
				}
			}
		} else if (assessment.RecordType.Name == 'CNA Workbook') {
			// This only happens when a DON ends a shift
			assessment.Signed_At__c = System.now();
			assessment.Signed_By__c = UserInfo.getUserId();
			assessment.Status__c = 'Final';
		}
		update assessment;
		if(asmtsforRestraints.size() > 0){
			update asmtsforRestraints; // Change the Status of the assessments to complete when the Restraint Event Ends.
		}

		return null;
	}
}