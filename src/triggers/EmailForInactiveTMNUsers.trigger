trigger EmailForInactiveTMNUsers on TMN_User__c (before insert, before update) {

    /* 
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
        if (u.job_status__c == 'Inactive'){
            u.email__c = '';
        }
    }

}