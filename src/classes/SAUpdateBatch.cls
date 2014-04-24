global class SAUpdateBatch implements Database.Batchable<sObject> {

   global final String Query;
	//List<Service_Assignment__c> sa = [select ID, service_location__c, location_region__c, program__c, program_detail__c, service_line__c from service_assignment__c where admission__r.state__c = 'AZ' and status__c = 'Active'];

   global SAUpdateBatch (String q){
             Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   		
   		Service_Location__c sl = [select id, alias__c, city__c, program__c, service_value__c from service_location__c where programid__c = '122874001'];
		integer dashpos = sl.Service_Value__c.indexOf('-');
      
      
      // START: Loop through all SAs passed into batch job.
      for(Sobject s : scope){
        
        // Polymorph sObject to Assessment__c
        Service_Assignment__c sa = (Service_Assignment__c)s;
        sa.service_location__c = sl.id;
    	sa.Program_Detail__c = sl.program__c;
    	if (sa.Model__c == null )
			sa.Program__c = sl.Alias__c;
			
		sa.Location_Region__c = ''; //sl.City__c;
    	sa.Service_Line__c = (sl.Service_Value__c).substring(dashpos+1);
    
    	update s;
		}
        
        
      }
 
   
   

   global void finish(Database.BatchableContext BC){
  	}
    
    
}