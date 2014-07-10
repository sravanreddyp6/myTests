global with sharing class TMNContacts {

    @RemoteAction
    global static String getClassName(){
        return 'TMNContacts';
    }
    
    @RemoteAction
    global static List<TMN_Contact__c> getTMNContacts(String filterType, String filter){
        /*
         * Filter can be
         * All, Role (Mentor, Sibling etc...) 
         * 
         * Filter Type can be
         * All, Role, Name
         */
         List<TMN_Contact__c> tmnContacts;
         if (filter == 'All') {
	        tmnContacts = [
	         
	                    select 
	                      name
	                     ,Household_Id__c
	                     ,Full_Name__c
	                     ,Role__c
	                     ,owner_full_name__c
	                     ,createdby.firstname 
	                     ,createdby.lastname
	                     ,createdDate
	                     ,lastModifiedBy.firstname
	                     ,lastModifiedby.lastname
	                     ,lastModifiedDate
	                    from TMN_Contact__c
	                    order by createdDate
	         
	         ];
         } else if (filter == 'Non Mentors') {
         	
	        tmnContacts = [
	         
	                    select 
	                      name
	                     ,Household_Id__c
	                     ,Full_Name__c
	                     ,Role__c
	                     ,owner_full_name__c
	                     ,createdby.firstname 
	                     ,createdby.lastname
	                     ,createdDate
	                     ,lastModifiedBy.firstname
	                     ,lastModifiedby.lastname
	                     ,lastModifiedDate
	                    from TMN_Contact__c
	                    where Household_Id__c =: filterType and role__c != 'Mentor'
	                    order by createdDate
	         
	         ];
         	
         	
         } else {
         	 tmnContacts = [
	                    select 
	                      name
	                     ,Household_Id__c
	                     ,Full_Name__c
	                     ,Role__c
	                     ,owner_full_name__c
	                     ,createdby.firstname 
	                     ,createdby.lastname
	                     ,createdDate
	                     ,lastModifiedBy.firstname
	                     ,lastModifiedby.lastname
	                     ,lastModifiedDate
	                    from TMN_Contact__c
	                    where role__c = 'Mentor'
	                    order by createdDate
	         ];
         	
         }
         
         return tmnContacts;
    }// end getTMNContacts method
    



} //end class