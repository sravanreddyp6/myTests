/* Class was written to support post-approval changes to a note through actions (not field edits).  
** Specifically, notes that are duplicates need to be marked as unbillable even if approved, but the users cannot edit a locked record.
** This class provides system admin level access to the record, thus bypassing locked status, to make the update.
** Permission is controlled through a permission set query against the current user.
*/
public without sharing class Notes_ProgressNote_AddlActions {
	
	public Progress_Note__c thePN {get; set; }
	public Boolean canDisregard { get { return isUserAllowed();} set;}
	public Notes_ProgressNote_AddlActions( ApexPages.StandardController controller ) {
		
		thePN = (Progress_Note__c) controller.getRecord();
		if (thePN.ID != null )
			thePN = [select id, Purpose_Service_is_Billable__c, disregard_note__c, status__c,approval_status__c, locked__c, ownerid from Progress_Note__c where id = :thePN.Id];
		
	}
	
	// updates the billable flag on the record then redirects to detail view of Progress Note
	public PageReference updateLocked () {
		
			Boolean resetLocked = thePN.Locked__c;
			
			// briefly unlock to get around validation rule
			if (resetLocked) {
				thePN.No_Approval_Needed__c  = false;
				thePN.Locked__c  = false;
				update thePN;
			}
			thePN = [select id, Purpose_Service_is_Billable__c, disregard_note__c, status__c,approval_status__c, ownerid, Person_Being_Served__c, Person_Being_Served__r.Account.Id from Progress_Note__c where id = :thePN.Id];
			
			thePN.Purpose_Service_is_Billable__c = false;
			thePN.Disregard_Note__c = true;
			if (resetLocked)
				thePN.No_Approval_Needed__c  = resetLocked;
			update thePN;
			thePN = [select id, Purpose_Service_is_Billable__c, disregard_note__c, status__c,approval_status__c, ownerid, Person_Being_Served__c, Person_Being_Served__r.Account.Id from Progress_Note__c where id = :thePN.Id];
			System.Debug('turned off billable: ' + thePN);

            // Create a task reminder that indicates who marked the Progress Note as one to "Disregard."
            // Get the integrate account user ID to make the owner of the task.
            
            User integrateUser = [ SELECT Id FROM User WHERE Username LIKE 'integration%' LIMIT 1];
            Id integrateUserId = integrateUser.Id;
            
            // CTEAE-73  fix datetime format on task info
            DateTime n = DateTime.now();
            Task t = new Task(Subject = 'Disregard', Status = 'Completed', Priority = 'Normal', OwnerId = integrateUserId, Description = 'Note disregarded by ' + UserInfo.getName() + ', ' + n.format('MM/dd/yyyy hh:mm a'), WhoId = thePN.Person_Being_Served__c, WhatId = thePN.Id, ActivityDate = n.date());
            insert t;

			return new PageReference('/' + thePN.Id);
	}
	
	// calculation of whether user is allowed to make this change
	private Boolean isUserAllowed() {
		
		List<PermissionSetAssignment> userperms = [ select id, permissionset.name, assigneeid from PermissionSetAssignment where assigneeid = :UserInfo.getUserId()]; 
		for ( PermissionSetAssignment p : userperms ) {
			
			// user can only update if in one of these three permission sets
			
			
			if (
				// Cambridge			
				p.PermissionSet.Name.Contains('ESD_Notes_Supervisor') || 
				p.PermissionSet.Name.Contains('ESD_Notes_Case_Handler')  ||
				// Redwood
				p.PermissionSet.Name.Contains('Level_3') ||
				( ( p.PermissionSet.Name.Contains('ESD_Notes_Clinical_Data_User') || 
					p.PermissionSet.Name.Contains('Level_2') ||
					p.PermissionSet.Name.Contains('Level_1') ) &&
					thePN.OwnerID == UserInfo.getUserId()) ) {
				System.Debug('User is allowed.');
				return true;	
				}
		}
		return false;
	}
}