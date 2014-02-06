trigger GetStartTimeOnly on Progress_Note__c (before update, before insert) {
    string a_p = '';
    integer curr_hour = 0;
    integer curr_min = 0;
    string min_str = '';
    Set<Id> pbsToFetch = new Set<Id>();
    Set<Id> recordTypesToFetch = new Set<Id>();
    //Set<id> TMNUsersToFetch = new Set<Id>();
    Set<Id> ownersToFetch = new Set<Id>();
    
    for (Progress_Note__c note: Trigger.new) {
        pbsToFetch.add(note.Person_Being_Served__c);
        recordTypesToFetch.add(note.RecordTypeId);
        ownersToFetch.add(note.CreatedById);
    }
    Map<Id, Contact> pbsMap = new Map<Id, Contact>([
        SELECT Id, Name FROM Contact WHERE Id IN :pbsToFetch
    ]);
    Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([
        SELECT Id, Name FROM RecordType WHERE Id IN :recordTypesToFetch
    ]);
    Map<Id, User> ownerMap = new Map<Id, User>([
        SELECT Id, FirstName, LastName FROM User WHERE Id IN :ownersToFetch
    ]);
    /*
    Map<Id, TMN_User__c> TMNUserMap = new Map<Id, TMN_User__c>();
    for (TMN_User__c t : [SELECT Salesforce_User_Account__c, First_Name__c, Last_Name__c FROM TMN_User__c WHERE Salesforce_User_Account__c in :TMNUsersToFetch]) {
        TMNUserMap.put( t.Salesforce_User_Account__c, t);
    }
    */
        
    for (Progress_Note__c n : Trigger.new)
    {
        curr_hour = n.Start_Time__c.hour();

        if (curr_hour < 12) {
            a_p = 'AM';
        }
        else {
            a_p = 'PM';
        }
        if (curr_hour == 0) {
            curr_hour = 12;
        }
        if (curr_hour > 12) {
            curr_hour = curr_hour - 12;
        }

        curr_min = n.Start_Time__c.minute();

        if (curr_min < 10 ) {
            min_str = '0';
        }
        else
            min_str = '';

        n.Start_Time_Only__c = string.valueOf(curr_hour) + ':' + min_str + string.valueOf(curr_min) + ' ' + a_p;
        curr_hour = n.End_Time__c.hour();

        if (curr_hour < 12) {
            a_p = 'AM';
        }
        else {
            a_p = 'PM';
        }
        if (curr_hour == 0) {
            curr_hour = 12;
        }
        if (curr_hour > 12) {
            curr_hour = curr_hour - 12;
        }
        curr_min = n.End_Time__c.minute();

        if (curr_min < 10) {
            min_str = '0';
        }
        else
            min_str = '';

       if ((Trigger.isUpdate && Trigger.oldMap.get(n.Id).End_Time__c != n.End_Time__c) || Trigger.isInsert) {
           n.End_Time_Only__c = string.valueOf(curr_hour) + ':' + min_str + string.valueOf(curr_min) + ' ' + a_p;
       }

       // also update the date of service
       Date st = n.Start_Time__c.date();
       integer curr_month = st.month();
       string month_str = '';
       string day_str = '';
       if ( curr_month < 10 )
           month_str = '0';
       integer day = st.day();
       if ( day < 10 )
           day_str = '0';

       if ((Trigger.isUpdate && Trigger.oldMap.get(n.Id).Start_Time__c != n.Start_Time__c) || Trigger.isInsert) {
           n.Date_of_Service_String__c = month_str + string.valueOf(curr_month) + day_str + string.valueOf(day ) + string.valueOf(st.year());
           // Also update Date_of_Service__c
           n.Date_of_Service__c = n.Start_Time__c.date();
       }
       
       if (Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(n.Id).Start_Time__c != n.Start_Time__c || Trigger.oldMap.get(n.Id).Type_of_Activity__c != n.Type_of_Activity__c)) &&
           n.Start_Time__c != null) {
         
               
           if ( recordTypeMap.get(n.RecordTypeId).Name == 'Shift Note' ) {
           	
           		n.Name = pbsMap.get(n.Person_Being_Served__c).Name + 
               				' - ' + n.Start_Time__c.format('MM/dd/yyyy hh:mm a') + ' - ' +
               				recordTypeMap.get(n.RecordTypeId).Name;
               
           		if ( Trigger.isUpdate ) {
                	n.Name += ' - ' + ownerMap.get(n.CreatedById).FirstName.Substring(0,1) + ownerMap.get(n.CreatedById).LastName;
           		} else  { // isInsert
                	n.Name += ' - ' + UserInfo.getFirstName().Substring(0,1) + UserInfo.getLastName();
           		}
           }  else {
           	  n.Name = pbsMap.get(n.Person_Being_Served__c).Name +
               ' - ' + n.Start_Time__c.format('MM/dd/yyyy') + ' - ' +
               recordTypeMap.get(n.RecordTypeId).Name;
	           if (n.Type_of_Activity__c != null && n.Type_of_Activity__c != '') {
    	           n.Name += ' - ' + n.Type_of_Activity__c;
        	   }
           }  
           
                
       }
    }
}