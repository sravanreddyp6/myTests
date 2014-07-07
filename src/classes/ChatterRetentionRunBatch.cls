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
	  
	  String ninetyString = ninetydays.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
	  system.debug('ninetyDays time is: ' + ninetyString);
	  
      String query = 'Select Type, CommentCount, ContentType, Body, Title, Id, CreatedById, ParentId, LastModifiedDate, CreatedDate from FeedItem where LastModifiedDate < '  + ninetyString;
	  
        
      ID batchprocessid = Database.executeBatch(new ChatterRetention(query), 200);
    }
}