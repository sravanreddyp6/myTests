public with sharing class DhrReportSubmit {
	public Date submissionDate {get;set;}
	
	public PageReference SubmitDhr() {
		
		List<Mentor_Tracking_Report_Record__c> allActiveDhrReports = [ SELECT Submitted_At_Least_Once__c, Status__c FROM Mentor_Tracking_Report_Record__c WHERE Include_in_DHR_Report__c = 'Yes'];
		List<Mentor_Tracking_Report_Record__c> dhrReportsToUpdate = new List<Mentor_Tracking_Report_Record__c>();
		
		for(Mentor_Tracking_Report_Record__c m : allActiveDhrReports) {
			if(m.Submitted_At_Least_Once__c==false) {
				m.Submitted_At_Least_Once__c = true;
			}
			
			if(m.Status__c=='New') {
				m.Status__c = 'Current';
			}
			else if(m.Status__c=='Update') {
				m.Status__c = 'Current';
			}
			else if(m.Status__c=='Closed') {
				m.Submitted_Once_Closed__c = true;
			}
			
			m.Skip_Trigger__c = true;
			dhrReportsToUpdate.add(m);
		}
		update dhrReportsToUpdate;
		
		PageReference thePage = new PageReference('/apex/TmnContactListView');
		return thePage;
	}
	
	public PageReference Cancel() {
		PageReference thePage = new PageReference('/apex/TmnContactListView');
		return thePage;		
	}
	
}