trigger EmailForInactiveTMNUsers on TMN_User__c (before insert, before update) {

    /*
     * 
     * Shaun-76
     *------------
     * Any user whose Job Status is being "inactivated" should
     * automatically have their email address removed from the 
     * Email__c field.
     * 
     * The reason for this is after a user is inactivated that email
     * is eligible to be reused in AD, meaning it could be loaded into 
     * this table again. We don't allow duplicate emails in the TMN_User table
     * since we link the emails to the User table to assign a user id to the 
     * appropriate TMN_User table.
     *
     * I cannot think of an instance where we would "insert" an Inactive user. But
     * maybe when we have identity management in SF that will happen. Thus why 
     * before insert exists above...
     * 
     */

    for (TMN_User__c u : Trigger.new) {
    	//Sravan - Commented below block per EPIM-321
        /*if (u.job_status__c == 'Inactive'){
            u.email__c = '';
        }*/
        
        /*
         * Only do this on update
         */
         if (Trigger.isUpdate) {
	        /*
	         * If the user modified the last_day__c field then "termination_date_modified_salesforce__c" will be equal to true
	         * We will use this value to ensure when Kettle tries to update the last_day__c field it will be not be ablel to 
	         * if it was previously updated by the user.
	         */
       		 if (u.last_day__c <> Trigger.oldMap.get(u.id).last_day__c && UserInfo.getLastName() <> 'integration') {
            		u.Termination_Date_Modified_Salesforce__c = True;
        	 }
         
        
	        /*
	         * If the user modified the last_day__c field then "termination_date_modified_salesforce__c" will be equal to true
	         * If the INTEGRATION user tries to update the last day field and u.Termination_Date_Modified_Salesforce__c == true then 
	         * we will NOT allow the INTEGRATION user to make this update and update the table back to it's original value.
	         */
	        if (u.last_day__c <> Trigger.oldMap.get(u.id).last_day__c && UserInfo.getLastName() == 'integration' && u.Termination_Date_Modified_Salesforce__c == true) {
	            u.last_day__c = Trigger.oldMap.get(u.id).last_day__c;
	        }
        
         }//end if (Trigger.isUpdate) 

        
    }

}