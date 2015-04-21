global class Plans_AttachmentCloneBatch implements Database.Batchable<sObject> {

   global final String Query;

   global Plans_AttachmentCloneBatch(String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        // get a list of plan ids
        //List<Plan__c> plans = [ select id from plan__c order by id];
        Plan__c[] plans = (Plan__c[])scope;
        
        // get the attachments with plans as parents
        List<Attachment> planatts = [ select id, parentid, body, name from attachment where parentid in :plans];
        
        // create a mapping of old (plans) to new (action plans) – a single plan__c may become more than one action_plan__c
        Map<ID, List<ID>> oldplannew = new Map<ID, List<ID>>();
        List<Action_Plan__c> aps = [ select id, original_planid__c from action_plan__c where original_planid__c in :plans order by original_planid__c ];
        //System.Debug( aps );
        
        for ( Plan__c plan : plans ) {
               for ( Action_Plan__c ap : aps ) {
               		if ( ap.Original_PlanID__c == plan.Id ) {
                      if (! oldplannew.ContainsKey( plan.Id ) )
                             oldplannew.put( plan.Id, new List<ID>{ap.Id} );
                      else
                             oldplannew.get( plan.Id).add( ap.Id);
               		}
               }
               
        }
        
        System.Debug( oldplannew);
        
        // For the plan attachments, make a copy of each and attach to the new action plan
        Attachment attnew;
        List<Attachment> atttoinsert = new List<Attachment>();
        for ( Attachment att : planatts ) {
               if(oldplannew.size() > 0) {
	               for ( ID newid : oldplannew.get( att.parentId)) {
	               		  
	                      attnew = att.clone();
	                      attnew.parentid = newid;
	                      atttoinsert.add( attnew );
	               }      
               }
        }
        
        system.debug( atttoinsert );
        insert atttoinsert;
   }
   
    global void finish(Database.BatchableContext BC){
        // DO NOTHING.
    }
}