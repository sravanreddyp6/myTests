public with sharing class DhrReportSubmit {
        public Date submissionDate {get;set;}
        Public String comments {get;set;}
        Public List<Log_History__c> subhistory {get;set;}
        Public Boolean showtable {get;set;}
        public string baseUrl {
        get {
            String aBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            return aBaseUrl;
        }
        set;
    } 
         
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
                        m.MSR_Submission_Date__c = submissionDate;
                        m.MSR_Submission_Recorded_Datetime__c = datetime.now();
                        m.MSR_Submission_Recorded_By__c = UserInfo.getUserId();
                        dhrReportsToUpdate.add(m);         
                      
                }
                update dhrReportsToUpdate;
                
                Create_LogHistory clh = new Create_LogHistory();
                clh.CreateLogHistory('Page','MSR Report Submission',submissionDate,'',comments);
                
                PageReference thePage = new PageReference('/apex/TmnContactListView');
                return thePage;       

        }
        
        public PageReference Cancel() {
                PageReference thePage = new PageReference('/apex/TmnContactListView');
                return thePage;         
        }
        public PageReference showhistory(){
        showtable=True;
        subhistory= [SELECT Id, Action__c, Action_Date_Time__c,By_User__c,Object_Name__c,Category__c,Date_of_Submission__c, Comments__c FROM Log_History__c WHERE Object_Name__c = 'MSR Report Submission' order by Action_Date_Time__c Desc]; 
        Return null;
        }
        
        Public PageReference clearhistory(){
        showtable=False;
        subhistory= new List<Log_History__c>();
        Return null;       
        }
}