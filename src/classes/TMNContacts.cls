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
						 from tmn_contact__c
        ];        
        return tmnContact;
    }// end getTMNContactDetail


/*
            <apex:pageBlockSection title="Contact Information">
                <apex:outputField value="{!TMN_Contact__c.Street_1__c,Street_2__c}" />

                <apex:outputField value="{!TMN_Contact__c.City__c,State__c}" />

                <apex:pageBlockSectionItem />
                <apex:outputField value="{!TMN_Contact__c.Zip_Code__c}" />

                <apex:outputField value="{!TMN_Contact__c.Primary_Phone__c,Secondary_Phone__c}" />

                <apex:outputField value="{!TMN_Contact__c.Email__c}" />
            </apex:pageBlockSection>
            <apex:pageBlockSection title="Marketing Info" columns="2">
                <apex:outputField value="{!TMN_Contact__c.How_did_you_hear_about_us__c}" />
                <apex:outputField value="{!TMN_Contact__c.How_did_you_hear_Other_Describe__c}" />
                <apex:outputField value="{!TMN_Contact__c.Referral_Type__c}" />
            </apex:pageBlockSection>
            <apex:pageBlockSection title="Mentor Status" columns="2">
                <apex:outputField value="{!TMN_Contact__c.Disregarded__c}" />
                <apex:pageBlockSectionItem />
                <apex:outputField value="{!TMN_Contact__c.Population_This_Home_Is_Associated_With__c}" label="With which population is this home associated?" />
                <apex:pageBlockSectionItem />
                <apex:outputField value="{!TMN_Contact__c.In_Progress__c}" />
                <apex:outputField value="{!TMN_Contact__c.In_Progress_Date__c}" />
                <apex:outputField value="{!TMN_Contact__c.Active__c}" />
                <apex:outputField value="{!TMN_Contact__c.Active_Date__c}" />
                <apex:outputField value="{!TMN_Contact__c.Suspended__c}" />
                <apex:outputField value="{!TMN_Contact__c.Suspend_Date__c}" />
                <apex:outputField value="{!TMN_Contact__c.Inactive__c}" />
                <apex:outputField value="{!TMN_Contact__c.Inactive_Date__c}" />
                <apex:outputField value="{!TMN_Contact__c.Denied__c}" />
                <apex:outputField value="{!TMN_Contact__c.Denied_Date__c}" />
                <apex:pageBlockSectionItem />
                <apex:outputField value="{!TMN_Contact__c.Denied_Reason__c}" />
                <apex:outputField value="{!TMN_Contact__c.Withdrawn__c}" />
                <apex:outputField value="{!TMN_Contact__c.Withdrawn_Date__c}" />
                <apex:pageBlockSectionItem />
                <apex:outputField value="{!TMN_Contact__c.Withdrawn_Reason__c}" />
                <apex:outputField value="{!TMN_Contact__c.Most_Recent_Recertification_Date__c}" />
            </apex:pageBlockSection>
            <apex:pageBlockSection title="System Info">
                <apex:outputField value="{!TMN_Contact__c.OwnerId}" />
                <apex:outputText label="Created By" value="{!TMN_Contact__c.CreatedBy.Name}, {!TMN_Contact__c.CreatedDate}" />
                <apex:outputText label="Last Modified By" value="{!TMN_Contact__c.LastModifiedBy.Name}, {!TMN_Contact__c.LastModifiedDate}" />
*/                
                
} //end class