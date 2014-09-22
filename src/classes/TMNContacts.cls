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
    

    @RemoteAction
    global static TMN_Contact__c getTMNContactDetail(String id){
        TMN_Contact__c tmnContact;
        tmnContact = [
                      select 
                         Full_Name__c
						,Chessie_ID__c
						,Date_of_Birth__c
						,Gender__c
						,Age__c
						,Marital_Status__c
						,Race__c
						,Hispanic_Heritage__c
						,DHR_CPA_Race_1__c
						,DHR_CPA_Race_2__c
						,Street_1__c
						,Street_2__c
						,City__c
						,State__c
						,Zip_Code__c
						,Primary_Phone__c
						,Secondary_Phone__c
						,Email__c
						,How_did_you_hear_about_us__c
						,How_did_you_hear_Other_Describe__c
						,Referral_Type__c
						,Disregarded__c
						,Population_This_Home_Is_Associated_With__c
						,In_Progress__c
						,In_Progress_Date__c
						,Active__c
						,Active_Date__c
						,Suspended__c
						,Suspend_Date__c
						,Inactive__c
						,Inactive_Date__c
						,Denied__c
						,Denied_Date__c
						,Denied_Reason__c
						,Withdrawn__c
						,Withdrawn_Date__c
						,Withdrawn_Reason__c
						,Most_Recent_Recertification_Date__c
			//			,OwnerId
			//			,CreatedBy.Name
			//			,CreatedDate
			//			,LastModifiedBy.Name
			//			LastModifiedDate
						 from tmn_contact__c where id =: id
        ];        
        return tmnContact;
    }// end getTMNContactDetail
                
                
   @RemoteAction
    global static TMNContactPickLists getPickLists(String id){
        return new TMNContactPickLists(id);
    }// end getPickLists
    
} //end class