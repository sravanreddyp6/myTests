global class ChatterRetention implements Database.Batchable<sObject>{
    global final String Query;

   global ChatterRetention(String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      FeedItem[] AllFeedItems = (FeedItem[])scope;
      datetime ninetyDays;
      if (Test.isrunningtest()==true)
      {
      	ninetyDays = DateTime.now() +1;
      }
      else
      {
        ninetyDays = DateTime.now() - 90;
      }
      List<FeedItem> AllFeedItemsList = [Select Type, CommentCount, Body, Title, Id, CreatedById, ParentId, LastModifiedDate, CreatedDate from FeedItem where LastModifiedDate < :ninetyDays];
      List<FeedComment> FeedCommentList = [Select Id, CreatedById, FeedItemID, CommentBody from FeedComment where FeedItemID in :AllFeedItemsList];
      //List<ChatterConversation> allChatterConvos = [Select Id from ChatterConversation];
      //List<ChatterMessage> allprivMessages = [Select Id, CreatedById, SentDate, Body from ChatterMessage where SentDate < :ninetyDays];
     
      
      system.debug('ninetyDays time is: ' + ninetyDays);
      system.debug('number of AllFeedItemList Items:' + AllFeedItemsList.size());
      //system.debug('List of private messages: ' + allprivMessages.size());
      
      set <string> userids = new set<string>();
      map<id, user> u = new map<id, user>();
      
      List<FeedItem> tempDeletedFeedsList = new List<FeedItem>();
      List<Id> finalDeletedFeedIds = new List<Id>();

    
    for(FeedItem feedi : AllFeedItemsList ) {
        userids.add(feedi.createdbyid);
    }
    for (FeedComment feedc : FeedCommentList ){
       userids.add(feedc.createdbyid);
    }
    for (User usr : [select id, legal_custodian__c from user where id in :userids]){
        u.put(usr.id, usr);
     }
      // START: Loop through all FeedItems passed into batch job.
      for(FeedItem afi : AllFeedItemsList){
        Date formattedCreatedDate = date.newinstance(afi.CreatedDate.year(), afi.CreatedDate.month(), afi.CreatedDate.day());
        String parentIdformatted = afi.ParentId;
        String workingId;
     
        if(parentIdformatted.startsWith('005')){
            workingId = parentIdFormatted;
        }
        if(parentIdformatted.startsWith('0F9')){
            workingId = parentIdformatted;
        }
        if(afi.Body == null){
            //if there is a feed item with a null body, skip it and do nothing
            system.debug('test doing nothing');
        }
        else if(!(afi.Body.toLowerCase().contains('#save')) && workingId != null && u.get(afi.CreatedById).legal_custodian__c == false){
            //For testing purposes: formattedCreatedDate == date.today()
            //add feeditem to a temp deleted list, to be parsed through for comments.
                if(afi.CommentCount == 0){
                finalDeletedFeedIds.add(afi.Id);
                }
                else{
                tempDeletedFeedsList.add(afi);
                }
            system.debug('TEMP TO BE DELETED: ' + afi.Body);
         }
      }
       //create comment list based on whats in feedItem temp list
       List<FeedComment> tempFeedCommentList = [Select Id, CreatedById, FeedItemId, CommentBody from FeedComment where FeedItemId in :tempDeletedFeedsList];
       List<Id> feedItemIdsToKeep = new List<Id>();
       
       //loop through feedComments in temp feed comment list
       for(FeedComment fc : tempFeedCommentList){
            //saved and skipped feedItemIds
           if(fc.CommentBody.toLowerCase().contains('#save') || u.get(fc.CreatedById).legal_custodian__c == true){
            system.debug('Comment Saved!: ' + fc.CommentBody);
            feedItemIdsToKeep.add(fc.FeedItemId);
           }
       }
       system.debug('Final Delete Check 1:' + finalDeletedFeedIds);

       //clone of original tempDeletedList
    List<Id> idsToRemove = new List<Id>();
    Map<Id,FeedItem> mapToRemove = new Map<Id,FeedItem>();
    
    for(FeedItem fiForMapLoop : tempDeletedFeedsList){
        mapToRemove.put(fiForMapLoop.Id,fiForMapLoop);
    }
    
       //create a counter of how many feedItemIds to remove from the original list.
    for(FeedItem afi2 : tempDeletedFeedsList){
        for(Id idToKeep : feedItemIdsToKeep){
            //check that the current feedComment Id is in the IdstoKeep List
            if(afi2.id == idToKeep){
                idsToRemove.add(afi2.id);
            }
            
        }
    }
    system.debug('size of feedItemIdsToKeep: ' + feedItemIdsToKeep.size());
    
    // DO SOME SORT OF REMOVAL
    for(Id prunedId : idsToRemove){
        mapToRemove.remove(prunedId);
    }

    for( ID feedItemIdFromMap : mapToRemove.keySet() ){ 
        finalDeletedFeedIds.add(feedItemIdFromMap);
    }

    List<Id> PMessageIdsToKeep = new List<Id>();
    List<Id> PMessageIdsToDel = new List<Id>();
    //ChatterMessages Purge loop
    /*For(ChatterMessage pm : allprivMessages){
        if(pm.Body.toLowerCase().contains('#save') || pm.CreatedBy.legal_custodian__c == true){
            PMessageIdsToKeep.add(pm.Id);
        }
        else{
            PMessageIdsToDel.add(pm.Id);
        }
    }
    system.debug('PMessages to Keep: ' + PMessageIdsToKeep);
    system.debug('Private Messages to Delete: ' + PMessageIdsToDel);
    */
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
        /*List<String> toAddresses = new List<String>();
        // Add email string to List
        toAddresses.add('ryan.johnson@thementornetwork.com');
        String subject = 'Batch class run complete';
        String body = 'Your batch is complete!';    
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Outbound Notification');
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setUseSignature(false);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
   }
}