trigger GetStartTimeOnly on Progress_Note__c (before update, before insert) {
    
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
    

    for (Progress_Note__c n : Trigger.new)
    {
    	

		// if start time is updated or it's an insert
       if ((Trigger.isUpdate && Trigger.oldMap.get(n.Id).Start_Time__c != n.Start_Time__c) || Trigger.isInsert) {
       	
           // Also update Date_of_Service__c (date)
           n.Date_of_Service__c = n.Start_Time__c.date();

       		// update date of service string
           n.Date_of_Service_String__c = getDateString( n.Start_Time__c.date() ); 
           
           // CTEAE-131 - only update the string value for the start time if the GMT time changes otherwise
        	n.Start_Time_Only__c = getTimeString( n.Start_time__c); 
           
       }
       
       // if end time is updated or it's an insert
       if ((Trigger.isUpdate && Trigger.oldMap.get(n.Id).End_Time__c != n.End_Time__c) || Trigger.isInsert) {
       	
       		// update end time string
           n.End_Time_Only__c = getTimeString( n.End_time__c); 
       }
       
       
       // if it's an insert, or the start time changes, or the type of activity changes, or the note is disregarded, update the name
       if (Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(n.Id).Start_Time__c != n.Start_Time__c || Trigger.oldMap.get(n.Id).Type_of_Activity__c != n.Type_of_Activity__c || Trigger.oldMap.get(n.Id).Disregard_Note__c != n.Disregard_Note__c)) &&
           n.Start_Time__c != null) {
         
               
           if ( recordTypeMap.get(n.RecordTypeId).Name == 'Shift Note' ) {
           	
           		n.Name = pbsMap.get(n.Person_Being_Served__c).Name + 
               				' - ' + n.Start_Time__c.format('MM/dd/yyyy hh:mm a') + ' - ' +
               				recordTypeMap.get(n.RecordTypeId).Name;
               
           		if ( Trigger.isUpdate ) {
           			if ( n.Disregard_Note__c ) 
           				n.Name += ' - DISREGARD';
           
					else
						n.name += (ownerMap.get(n.CreatedById).FirstName!='' && ownerMap.get(n.CreatedById).FirstName!=null) ? ' - ' + ownerMap.get(n.CreatedById).FirstName.Substring(0,1) + ownerMap.get(n.CreatedById).LastName : ' - ' + ownerMap.get(n.CreatedById).LastName;
           		} else  { // isInsert
           			
                	n.Name += (UserInfo.getFirstName()!='' && UserInfo.getFirstName()!=null) ? ' - ' + UserInfo.getFirstName().Substring(0,1) + UserInfo.getLastName() : ' - ' + UserInfo.getLastName(); 	
           		
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
    
    private string getTimeString( DateTime dtTime ) {
    	string a_p = '';
    	integer curr_hour = 0;
    	integer curr_min = 0;
    	string min_str = '';
		
		curr_hour = dtTime.hour(); 

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

        curr_min = dtTime.minute();

        if (curr_min < 10 ) {
            min_str = '0';
        }
        else
            min_str = '';

		return string.valueOf(curr_hour) + ':' + min_str + string.valueOf(curr_min) + ' ' + a_p;
		
    }
    
    private string getDateString( Date st ) {
    	
       
       integer curr_month = st.month();
       string month_str = '';
       string day_str = '';
       if ( curr_month < 10 )
           month_str = '0';
       integer day = st.day();
       if ( day < 10 )
           day_str = '0';

		return month_str + string.valueOf(curr_month) + day_str + string.valueOf(day ) + string.valueOf(st.year());
    }
}