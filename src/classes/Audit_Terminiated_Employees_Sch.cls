global class Audit_Terminiated_Employees_Sch implements Schedulable {
	global void execute(SchedulableContext sc) {
		string devMsg='';
		datetime dayMonday = system.now().addDays(-7).addHours(-8);
		//datetime dayFriday = system.now().addDays(-3).addHours(-8);
		datetime dayNextMonday = system.now().addHours(-8);
			TMN_User__c[] Users = [select name, employee_number__c, job_status__c, manager_name__c, work_state__c,
				operating_group__c, hire_date__c,  lastModifiedDate
					from tmn_user__c
					where job_status__c = 'Inactive'
					and LastModifiedDate > :dayMonday and LastModifiedDate < :dayNextMonday ];
	   			
				system.debug('starting requires email');
				system.debug(Users);
				devMsg += Audit_Terminated_Employees_Batch.getNamefromList(Users);
			Users = Audit_Terminated_Employees_Batch.getsInactive(Users);

				system.debug('starting emails');
				system.debug(Users);
		Audit_Terminated_Employees_Batch b = new Audit_Terminated_Employees_Batch(Users, devMsg);
		database.executebatch(b);
	}
}