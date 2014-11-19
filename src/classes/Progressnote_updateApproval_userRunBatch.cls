public with sharing class Progressnote_updateApproval_userRunBatch implements schedulable {
	public void execute(SchedulableContext sc){
		
		string query ='SELECT ProcessInstance.TargetObjectID,Id,ProcessInstanceId,StepStatus FROM ProcessInstanceStep WHERE StepStatus =\'Reassigned\' AND processInstance.Status =\'Pending\'';
		Id BatchProcessId = Database.ExecuteBatch(new Progressnote_updateApproval_user(query),200);
	}

}