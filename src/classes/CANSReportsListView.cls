public with sharing class CANSReportsListView {


	public List<ReportInfo> listReports{ get; set; }
	public CANSReportsListView (){
		
		listReports = new List<ReportInfo>();
		getReports();
    }



	public void getReports() {
		
		// get the list from the CANS report folder
		List<Report> fList = [ SELECT Name, Id, DeveloperName, ownerid FROM report where ownerid in (select id from folder where developername='CANS_Assessments') ];
		for (Report f: flist ) {
			listReports.Add( new ReportInfo( f.name, '/' + f.id));
		}
		
		List<VF_Reports__c> vfList = [ select name__c, link__c from vf_reports__c where description__c like '%#CANS%' ];
		for ( VF_Reports__c vf : vfList ) {
			listReports.Add( new ReportInfo( vf.name__c, vf.link__c));
		}		
		
		listReports.Sort();
		
	}

// get the list from the VF reports custom setting - anything tagged with #CANS

// alphabetize by report name 


	public class ReportInfo implements Comparable {
		public string strName { get; private set;}
		public string strLink { get; private set;}
		
		
		public ReportInfo( string nm, string lk) {
			strName = nm;
			strLink = lk;
			
		}
		
		public Integer compareTo(Object compareTo) {
    		
    		ReportInfo compareToRep = (ReportInfo)compareTo;
        	if (strName == compareToRep.strName) return 0;
        	if (strName > compareToRep.strName) return 1;
        	return -1; 
    		
		}
	}

}