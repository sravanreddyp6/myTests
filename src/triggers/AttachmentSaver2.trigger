trigger AttachmentSaver2 on Attachment (after delete) {
 // Get the current user's profile name
    Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
    
    Set<String> objPrefixes = new Set<String>();
    
    // ECDN-11 - 2014-05-09 - allow deletion of contract attachments
	Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
	for(Schema.SObjectType objectInstance : gd.values())
	{
		if( objectInstance.getDescribe().getName().Contains('Contract'))
			objPrefixes.Add( objectInstance.getDescribe().getKeyPrefix() );
	}

	System.Debug( 'LIST OF CONTRACT OBJECT PREFIXES: ' + objPrefixes);
    // If current user is not a System Administrator, do not allow Attachments to be deleted
    if (!'System Administrator'.equalsIgnoreCase(prof.Name) && !'System Administrator (Custom)'.equalsIgnoreCase(Prof.Name)) {
        for (Attachment a : Trigger.old) {

        	// ECDN-11 - 2014-05-09 - allow deletion of contract attachments
        	if ( ! (objPrefixes.Contains(String.ValueOf(a.parentId).substring(0, 3))) )
            	a.addError('Unable to delete attachments.');
        }   
    }
}