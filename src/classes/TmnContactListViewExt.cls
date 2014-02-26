public with sharing class TmnContactListViewExt {

	public TmnContactListViewExt(ApexPages.StandardSetController stdController) {
		
	}
	
	public PageReference dhrReportSubmit() {
		PageReference thePage = new PageReference('/apex/DhrReportSubmit');
		return thePage;
	}

}