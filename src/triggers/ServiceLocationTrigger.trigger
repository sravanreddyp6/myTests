trigger ServiceLocationTrigger on Service_Location__c (before insert, after insert, before update, after update) {
 	ServiceLocationTriggerHandler handler = new ServiceLocationTriggerHandler(true);

    if( Trigger.isInsert ) {
    	if ( Trigger.isBefore )
			handler.OnBeforeInsert( Trigger.new );
		else
        	handler.OnAfterInsert( Trigger.new );
    }
    
    if( Trigger.isUpdate) {
    		if (Trigger.isBefore)
        		handler.OnBeforeUpdate(trigger.oldmap, Trigger.new);
        	else
        		handler.OnAfterUpdate(Trigger.old, Trigger.new); 
    }
    
}