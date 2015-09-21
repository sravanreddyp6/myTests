trigger TMN_User_Job_Status_Trigger on TMN_User__c (before insert,before update) {
	TMN_User__c[] jobstatus = Trigger.new;
    identityEditNew.setJobStatus(jobstatus);
}