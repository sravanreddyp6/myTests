public with sharing class ReportListViewController {

	SystemSettings__c OS = SystemSettings__c.getOrgDefaults();

	public List<Report> refrportlst{get;set;}
	public List<Report> PBSrportlst{get;set;}
	public List<Report> contractrportlst{get;set;}
	public List<Report> credrportlst{get;set;}
	public List<Report> docrportlst{get;set;}
	public List<VF_Reports__c> VFReportlst{get;set;}
	public String objectName{get;set;}

	//report folders
	public String RefId;
	public String ESDbillingId;
	public String ESDActivityId;
	public String ESDSupyId;
	public String CntrctId;
	public String CredId;

	public final String OperatingGroup = [select operating_group__c from user where id=:UserInfo.getUserId() limit 1].operating_group__c;

	public boolean showNeuroFeatures{
		get {
			if (showNeuroFeatures == null) {
				showNeuroFeatures = OS.Referral_Neuro_Features_Enabled__c;
			}
			return showNeuroFeatures;
		}
		set;
	}


	//Constructor
	public ReportListViewController(){

	}

	public void getReportList() {
		reports();
	}


	public List<Report> reports() {
		String ESDAct='',ref,Care,ESDbill,ESDsup,Red;
		VF_Reports__c vf = VF_Reports__c.getInstance();
		VFReportlst = [SELECT Name,Id,Name__c,Description__c,link__c, groups__c from VF_Reports__c];
		// IADAY-14
		String userRole = [
			SELECT DeveloperName, Id FROM UserRole WHERE Id=:UserInfo.getUserRoleId()
		].DeveloperName;
		if (OperatingGroup != 'Redwood' || userRole != 'IA') {
			for (Integer i=0; i < VFReportLst.size(); i++) {
				if (VFReportLst[i].Name == 'TimeLogEntryReport') {
					VFReportLst.remove(i);
				}
			}
		}
		for(Folder tmp:[SELECT AccessType,Id,IsReadonly,Name,DeveloperName,Type FROM Folder WHERE Type = 'Report']){

			if(tmp.DeveloperName=='Referrals'){
				RefId = tmp.Id;

			}else if(tmp.DeveloperName=='CareMeridian_Contracts' && operatinggroup == 'Care Meridian'){
				CntrctId = tmp.Id;
			}
			else if(tmp.DeveloperName=='Redwood_Contracts' && operatinggroup == 'Redwood'){
				CntrctId = tmp.Id;
			}
			else if ( tmp.DeveloperName == 'Contract_Reports' && operatinggroup == 'Cambridge')
				CntrctId = tmp.Id;
			else if ( tmp.DeveloperName == 'Redwood_Contracts' && operatinggroup == 'Redwood')
				CntrctId = tmp.Id;
			else if(tmp.DeveloperName=='ESD_Activity'){
				ESDActivityId = tmp.Id;
				ESDAct = 'ESDAct';
			}
			else if(tmp.DeveloperName=='ESD_Billing'){
				ESDbillingId = tmp.Id;
			}
			else if(tmp.DeveloperName=='ESD_Supervisory'){
				ESDSupyId = tmp.Id;
			}
			else if ( tmp.DeveloperName == 'Credentialing')
				CredID = tmp.Id;
		}

		refrportlst = new List<Report>();
		system.debug('op grounp ' + OperatingGroup  );
		if(OperatingGroup != null){
			set<string> okRefRpts = getReportsToShow(OperatingGroup );
			system.debug('reports in scope - ' + okRefRpts);

			for(Report rpt: filterReportAccess(report(RefId, null))) {
				if (okRefRpts.contains(rpt.DeveloperName)) {
					refrportlst.add(rpt);
				}
			}
		}

		contractrportlst = new List<Report>();
		for(Report rpt: filterReportAccess(report(CntrctId, null))) {
			contractrportlst.add(rpt);
		}

		credrportlst = new List<Report>();
		for(Report rpt: filterReportAccess(report(CredId,null))) {
			credrportlst.add(rpt);
		}

		docrportlst = new List<Report>();
		for(Report rpt: filterReportAccess(report(ESDActivityId,'Docs'))) {
			docrportlst.add(rpt);
		}

		PBSrportlst = new List<Report>();
		for(Report rpt: filterReportAccess(report(ESDActivityId,ESDAct))) {
			System.debug('0');
			System.debug(rpt.DeveloperName);
			PBSrportlst.add(rpt);
		}

		for(Report rpt1: filterReportAccess(report(ESDbillingId,ESDbill))) {
			System.debug('1');
			System.debug(rpt1.DeveloperName);
			PBSrportlst.add(rpt1);
		}

		for(Report rpt2: filterReportAccess(report(ESDSupyId,ESDsup))) {
			System.debug('2');
			System.debug(rpt2.DeveloperName);
			PBSrportlst.add(rpt2);
		}

		return null;
	}
	// Given a list of reports, return a list of reports that the context user
	// has access to
	public List<Report> filterReportAccess(List<Report> reports) {
		System.debug('reports that need filter:' + reports);
		Map<Id, Report> reportMaps = new Map<Id, Report>();
		for (Report report: reports) {
			reportMaps.put(report.Id, report);
		}
		Map<Id, UserRecordAccess> accessMap = new Map<Id, UserRecordAccess>([
			SELECT RecordId, HasReadAccess
			  FROM UserRecordAccess
			 WHERE UserId = :UserInfo.getUserId()
			   AND RecordId IN :reportMaps.keySet()
		]);
		List<Report> accessibleReports = new List<Report>();
		for (Report report: reports) {
			if (accessMap.get(report.Id).HasReadAccess) {
				accessibleReports.add(reportMaps.get(report.Id));
			}
		}
		return accessibleReports;
	}

	public List<Report> report(Id ownId,String ReportText){
		String query = 'SELECT Name, Id,OwnerId, description, DeveloperName, SystemModstamp FROM report where OwnerId=:ownId';
		if(ReportText!=null && ReportText=='ESDAct'){
			query+=' and description like \'%#notes%\'' ;
		} else if (ReportText != null && ReportText=='Docs') {
			query+=' and (description like \'%Case Document%\' or description like \'%Fidelity Document%\')';
		}

		query+= ' order by name';

		List<Report> tempreport = database.query(query);
		return tempreport;
	}

	public set<string> getReportsToShow(string og){
		set<string> items = new set<string>();

		items.add('All_Active_Referrals_Report');
		items.add('All_Referrals');
		items.add('Closed_Referral_Tracking');
		items.add('Locations_Working_Ref_by_Ref_Number');
		items.add('Referral_Conversion_Time_Report');
		items.add('Referrals_By_Location_Working_Referral');
		items.add('Referrals_Requiring_Action');
		items.add('Referrals_with_Activities2');

		if(og == 'Cambridge'){
			items.add('Active_Referrals_With_Diagnosis');
			items.add('Active_Referrals_With_Diagnosis_Axis');
			items.add('Daily_Referrals');
			items.add('Red_Flagged_Referrals');
			items.add('Weekly_Referrals');
			items.add('Avatar_GA_Referrals');
			items.add('GA_Referrals_FIT_Program');

		}
		if(og == 'Redwood'){
			items.add('Active_Referrals_With_Diagnosis');
			items.add('Active_Referrals_With_Diagnosis_Axis');
			items.add('Daily_Referrals');
			items.add('Red_Flagged_Referrals');
			items.add('Weekly_Referrals');
			items.add('AdmissionSteps');
		}
		if(og == 'Care Meridian'){
			// EC-57 - added
			items.add('Referrals_with_Funding_and_Location');

			// EC-193
			if (Utility.currentUserHasPermissionSet('iServe_DON') || Utility.currentUserHasPermissionSet('iServe_Tier_III')) {
				items.add('Late_Entry_Report');
			}
		}
		if(og == 'NeuroRestorative'){
			items.add('Daily_Referrals');
			items.add('Weekly_Referrals');
			if(showNeuroFeatures){
				items.add('AdmissionSteps');
			}
		}
		return items;
	}


}