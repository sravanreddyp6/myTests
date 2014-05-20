public with sharing class ChatterRetentionRunBatch implements schedulable {
    public void execute(SchedulableContext sc){
    	
   	  datetime ninetyDays;
	  if (Test.isrunningtest()==true)
	  {
	  	ninetyDays = DateTime.now().AddDays(1);
	  }
	  else
	  {
	    ninetyDays = DateTime.now().AddDays(-90);
	  }
	  
	  system.debug('ninetyDays time is: ' + ninetyDays);
	  
        String query = 'Select Type, CommentCount, ContentType, Body, Title, Id, CreatedById, ParentId, LastModifiedDate, CreatedDate from FeedItem where LastModifiedDate < ' + ninetyDays;
        
        ID batchprocessid = Database.executeBatch(new ChatterRetention(query), 200);
    }
}