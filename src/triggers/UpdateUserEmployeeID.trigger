trigger UpdateUserEmployeeID on TMN_User__c (after update) {

    // update employee id on User table if updated on TMNUser
    Set<ID> UserID= new Set<ID>();
    Map<ID,String> userEmpNumber = New Map<ID,String>();
    TMN_User__c oldVal;
    
    for (TMN_User__c newVal : Trigger.new)
    {
    
        oldVal = Trigger.oldMap.get(newVal.Id);
        
       
        // if the employee number or salesforce account association have changed, update the emp number
        if (( oldVal.Employee_Number__c != newVal.Employee_Number__c) ||
            ( oldVal.SalesForce_User_Account__c != newVal.Salesforce_User_Account__c ))
        {
        	ID targetSF;
        	string targetEmpID = '';
        	
        	system.debug( newval.salesforce_user_account__c );
        	if ( newVal.Salesforce_User_Account__c == null ) {
        		// user unlinked account
        		targetSF = oldVal.Salesforce_User_Account__c;
        		targetEmpID = '';	
        	} else {
        		targetSF = newVal.Salesforce_User_Account__c;
        		targetEmpID = newVal.Employee_Number__c;
        	}
            userEmpNumber.put(targetSF, targetEmpID);
            UserID.add(targetSF);
        }     
    }
        
    List<User> currentUser = [select id, Username, EmployeeNumber from User where ID in :UserID];
    
    for (User u : currentUser)
    {
        u.EmployeeNumber = userEmpNumber.get(u.Id);
    }
    
    update currentUser;
}