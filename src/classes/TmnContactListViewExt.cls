public with sharing class TmnContactListViewExt {

	public boolean hasEsdCredOnlyMsrOrSysAdmin {get;set;}

	public TmnContactListViewExt(ApexPages.StandardSetController stdController) {
		
		hasEsdCredonlyMsrOrSysAdmin = false;
		List<PermissionSetAssignment> usersPermSets = [ SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() ];
		for(PermissionSetAssignment p : usersPermSets) {
			if(p.PermissionSet.Name=='ESD_Credentials_Only_MSR') {
				hasEsdCredOnlyMsrOrSysAdmin = true;
			}
		}
		User sysAdminProfile = [ SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() ];
		if(sysAdminProfile.Profile.Name=='System Administrator') {
			hasEsdCredOnlyMsrOrSysAdmin = true;
		}
		
	}
	
	public PageReference dhrReportSubmit() {
		PageReference thePage = new PageReference('/apex/DhrReportSubmit');
		return thePage;
	}

}