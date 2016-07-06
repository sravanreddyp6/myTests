public class CMShiftAssessmentNotificationRunBatch implements schedulable {
	public void execute(SchedulableContext sc){
		String dateTimeFormat = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
	
        String query = 'SELECT Id,Name,Owner.Id,ServiceAssignment__r.Admission__r.Person_Being_Served__c,Shift_End_time__c, Status__c FROM Evaluation__c WHERE RecordType.Name = \'CMShiftAssessment\' AND Status__c = \'Draft\' AND Shift_end_time__c <='+dateTimeFormat;
        ID batchprocessid = Database.executeBatch(new CMShiftAssessmentNotifications(query), 50);
    }

}