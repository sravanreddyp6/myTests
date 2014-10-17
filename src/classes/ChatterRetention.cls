global class ChatterRetention implements Database.Batchable<sObject>{
    global final String Query;

   global ChatterRetention(String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
	  FeedItem[] AllFeedItemsList = (FeedItem[])scope;

	  
	  set <string> userids = new set<string>();
	  map<id, user> u = new map<id, user>();
	  
	  List<FeedItem> tempDeletedFeedsList = new List<FeedItem>();
	  List<Id> finalDeletedFeedIds = new List<Id>();

		// determine list of legal hold users
		for(FeedItem feedi : AllFeedItemsList ) {
		    userids.add(feedi.createdbyid);
		}

		for (User usr : [select id, legal_custodian__c from user where id in :userids]){
		    u.put(usr.id, usr);
		 }
		 
		 
 	// list that we'll use to revert the delete for feed items whose comments contain #save
       List<Id> feedItemIdsToKeep = new List<Id>();
    
    // list of items whose comments need to be pruned
       List<Id> feedItemIdsPruneComments = new List<Id>();
    
       
	//  Look at feed items and consider for deletion	     
      for ( FeedItem afi : AllFeedItemsList ){
      	
        String parentIdformatted = afi.ParentId;
        String workingId;
     
     	// only consider posts to user feeds or groups - do not touch other things such as record feeds
        if(parentIdformatted.startsWith('005') || parentIdformatted.startsWith('0F9')){
            workingId = parentIdformatted;
        } else 
        	continue;
        
    	
    	if ( afi.Type == 'ContentPost' ) {
    		// item stays!
    		feedItemIdsPruneComments.add( afi.Id);
    		System.Debug('content post stays');
    		continue;
    		 		
    	}
    		
    	// basis for purging = no #save and no user on legal hold	
        if( afi.body == null ||
        	(afi.Body != null && !afi.Body.toLowerCase().contains('#save')) ||
        	 !(u.get(afi.CreatedById).legal_custodian__c) ) {
        	
            if(afi.CommentCount == 0) {
	           
	           // put directly into list to delete
	           finalDeletedFeedIds.add(afi.Id);
                
            }  else {
            	
            	// add feeditem to a temp deleted list, to be parsed through for comments.
				tempDeletedFeedsList.add(afi);
                system.debug('TEMP TO BE DELETED: ' + afi.Body);
         
            }
        
      }
      }
      
       //create comment list based on whats in feedItem temp to delete list
       List<FeedComment> tempFeedCommentList = [Select Id, CreatedById, FeedItemId, CommentBody, CommentType from FeedComment where FeedItemId in :tempDeletedFeedsList];
       
       // add the creators of the feed comments to the user list
       for(FeedComment feedc : tempFeedCommentList ) {
		    userids.add(feedc.createdbyid);
		}
		
		
		// add them to the map too - empty it first
		u.clear();
       for (User usr : [select id, legal_custodian__c from user where id in :userids]){
		    u.put(usr.id, usr);
		 }
		 
       //loop through feedComments in temp feed comment list
       for(FeedComment fc : tempFeedCommentList){

           //save the feed item if the comment has a file,  contains #save, or if the user is on legal hold
            if( fc.CommentType == 'ContentComment' ||
            	(fc.CommentBody != null && fc.CommentBody.toLowerCase().contains('#save')) ||
	        	 (u.get(fc.CreatedById).legal_custodian__c) ) {
	        	 	
	            system.debug('Comment Saved!: ' + fc.CommentBody);
    	        feedItemIdsToKeep.add(fc.FeedItemId);
           } 
       }
       
       
       system.debug('Final Delete Check 1:' + finalDeletedFeedIds);

    // put list temporary list of items into a map for uniqueness
    Map<Id,FeedItem> mapToRemove = new Map<Id,FeedItem>();
    for(FeedItem fiForMapLoop : tempDeletedFeedsList){
        mapToRemove.put(fiForMapLoop.Id,fiForMapLoop);
    }
    
    // take out the items we want to keep from the "to remove" list
    for(Id idToKeep : feedItemIdsToKeep){
        mapToRemove.remove(idToKeep);
    }

	// now add anything we're not keeping back to the list of deletions
    for( ID feedItemIdFromMap : mapToRemove.keySet() ){ 
        finalDeletedFeedIds.add(feedItemIdFromMap);
    }

    try {
    	//construct and delete one final list 
    	List<FeedItem> finalDelete = [Select Id, Body from FeedItem where id in :finalDeletedFeedIds];
    	system.debug('Final Delete Check 2: ' + finalDelete);
    	delete finalDelete;
    

    }
    
   catch(dmlException e) {
    	system.debug(e);
    }
    
   }
   
   	
      global void finish(Database.BatchableContext BC){
        List<String> toAddresses = new List<String>();
        // Add email string to List
        toAddresses.add('notifications@thementornetwork.com');
        String subject = 'Chatter 90 day purge complete';
        String body = 'Your batch is complete!';    
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Batch Run');
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setUseSignature(false);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}