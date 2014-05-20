@isTest(SeeAllData=true)
private class ChatRetentionTest2 {

    static testMethod void myUnitTest() {
    	
			CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
     		insert cg;
            
                	     	
     	   String ProfileId = [select ProfileId from User where (Department='Operations Systems') LIMIT 1].ProfileId;
     
           User usr = new User(USERNAME='Steve.Test@thementornetwork.com',
                               LASTNAME = 'Test',
                               FIRSTNAME = 'Steve',
                               EMAIL = 'Steve.Test@thementornetwork.com',
                               ALIAS = 'stest',
                               COMMUNITYNICKNAME = 'steve.test',
                               TIMEZONESIDKEY = 'America/New_York',
                               LOCALESIDKEY = 'en_US', 
                               EMAILENCODINGKEY = 'ISO-8859-1',
                               PROFILEID = ProfileId,
                               LANGUAGELOCALEKEY = 'en_US',                                
                               ISACTIVE = true,
                               legal_custodian__c=true);
                               
           insert usr;
                               
           List<User> testUsr = [Select Id from  user u WHERE Id = :usr.Id];        
           System.Debug('What is in testUsr: ' + testUsr);        
           Id uUserid = testUsr[0].Id;
           
           FeedItem fi = new FeedItem(PARENTID = cg.Id,
                                      Body = 'Test Post by steve'
           
           );
           insert fi;          
           
           
           FeedItem fi1 = new FeedItem(PARENTID = cg.Id,
                                      Body = 'Test Post by steve2'
           
           );
           insert fi1;     
           
            string before = 'Testing base 64 encode';
 			Blob resBody =Blob.valueOf(before);     
 			FeedItem fi2 = new FeedItem(ParentID = cg.Id, ContentData = resBody, ContentFileName='test file post');
			insert fi2;          
          
           
            List<FeedItem> testFeedItem = [Select Id From FeedItem I WHERE Id = :fi.Id];        
           Id iItemid = testFeedItem[0].Id;
           
           
           FeedComment fc = new FeedComment(FEEDITEMID = iItemid,
                                            COMMENTBODY = 'Test comment by steve',
                                            COMMENTTYPE = 'TextComment'
           );
           insert fc;
           
           FeedComment fc2 = new FeedComment(FEEDITEMID = iItemid,
                                            COMMENTBODY = 'Test comment by steve no save',
                                            COMMENTTYPE = 'TextComment'
           );
          
           insert fc2;
    	
    		List<CollaborationGroupFeed> feeds = [ select body from CollaborationGroupFeed];
    		system.debug('FEED:' + feeds);
    		
    		ContentDocument cd = new ContentDocument();
    		
    	   FeedComment fc3 = new FeedComment(FEEDITEMID = iItemid,
                                            COMMENTTYPE = 'ContentComment',
                                            RelatedRecordId = cd.Id
           );
          
           //insert fc3;
    	
		  datetime ninetyDays;
	  	  ninetyDays = DateTime.now().AddDays(1);
	  	String ninetyString = ninetydays.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
	  	
	  	  system.debug('ninetyDays time is: ' + ninetyDays);
	  
        	String query = 'Select Type, CommentCount, ContentType, Body, Title, Id, CreatedById, ParentId, LastModifiedDate, CreatedDate from FeedItem where LastModifiedDate < '  + ninetyString;
        	system.debug( query);
            ID batchprocessid = Database.executeBatch(new ChatterRetention(query), 200);
        
    }
}