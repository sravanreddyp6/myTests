public with sharing class TherapistAPExtract {
    public String startdtStr {get;set;}
    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public List<id> selectedPBS {get; set;}
    public List<SelectOption> PBSList = new List<SelectOption>();
    public List<SelectOption> getPBSList(){ return PBSList ;}    
    public boolean hasRunOnce {get; set;}
    public list<SelectOption> programslist = new list<SelectOption>();
    public list<SelectOption> getProgramslist(){ return programslist; }
    public List<Id> selectedPrograms {get; set;}
    public list<SelectOption> select2list = new list<SelectOption>();
    public list<SelectOption> getSelect2list(){ return select2list; }   
    public List<id> select2PrmIds {get; set;}
    public decimal monthTotalHrs {get; set;}
    public decimal monthTotalAmount {get; set;}
    public list<TherapistAPLineItem> therapistAPLineItems {get; set;} 
    public ReportConstants reportConstants {get; set;}    
    private map<String, Integer> integerMonth = new map<String, Integer>();

        
    public TherapistAPExtract(){

        PBSList.clear();
        
        for (AggregateResult TherapyHr : [SELECT Owner.Name ownerName, OwnerId FROM Therapy_Hour__c 
                                           WHERE status__c = 'Approved'
                                           group BY Owner.Name, OwnerId order BY Owner.Name]){
               PBSList.add(new SelectOption((Id)TherapyHr.get('OwnerId'), (String)TherapyHr.get('ownerName')));
        }
        
        selectedPBS = new List<id>();
        hasRunOnce =false;
        
        integerMonth.put('January',1);
        integerMonth.put('February',2);
        integerMonth.put('March',3);
        integerMonth.put('April',4);
        integerMonth.put('May',5);
        integerMonth.put('June',6);
        integerMonth.put('July',7);
        integerMonth.put('August',8);
        integerMonth.put('September',9);
        integerMonth.put('October',10);
        integerMonth.put('November',11);
        integerMonth.put('December',12);
        reportConstants = new ReportConstants();        
    }
    
    public PageReference cancelToNewRun() {
        PageReference pageRef = new PageReference('/apex/TherapistsAPExtract');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference runReport() {
    	if (String.IsBlank(startdtStr) || selectedPBS.size() == 0){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please select a month and at least one Therapist before running the report.'));
    		return null;
    	}
        startdate = Date.newInstance(Integer.valueOf(startdtStr.substring(startdtStr.length() - 4)), integerMonth.get(startdtStr.substring(0, startdtStr.length() - 5) ), 1);
        enddate = startdate.addMonths(1).addDays(-1);
        system.debug('startdate: ' + startdate.format() + '  enddate: ' + enddate.format());
    	list<TherapistAPLineItem> therapistAPLineItemsList = new list<TherapistAPLineItem>();
    	list<Id> ids = new list<Id>();
    	
    	// Initialize the AP line items
        for (AggregateResult aggre : [SELECT OwnerId, Owner.name ownerName, Service_Assignment__r.service_location__r.alias_lookup__r.name, sum(Number_of_Hours__c) approvedHrs
        								FROM Therapy_Hour__c 
                                      	WHERE OwnerId IN :selectedPBS AND StartTime_DatePart__c >= : StartDate AND StartTime_DatePart__c <= : EndDate AND status__c = 'Approved' 
                                      		group by Service_Assignment__r.service_location__r.alias_lookup__r.name, OwnerId, Owner.name
                                      		order by Service_Assignment__r.service_location__r.alias_lookup__r.name, OwnerId, Owner.name]){
            therapistAPLineItemsList.add(new TherapistAPLineItem((String)aggre.get('ownerName'), (Id) aggre.get('OwnerId'), (decimal) aggre.get('approvedHrs'), (String) aggre.get('name'), this.reportConstants) );
            ids.add((Id) aggre.get('OwnerId'));
            system.debug('Owner Id=' + (Id) aggre.get('OwnerId') + '; ownerName=' + (String)aggre.get('ownerName') + '; approved hours=' + (decimal) aggre.get('approvedHrs') + '; alias name=' + (String) aggre.get('name'));
        }
        
        // Get the user info for all the ids
        Map<Id, TMN_User__c> tmnInfo = new Map<Id, TMN_User__c>();
        for (TMN_User__c tmn : [SELECT Salesforce_User_Account__c, Account_Number__c, Discipline__c, GL_Code__c, Rate__c, Vendor_Name__c, Alias_Lookup__r.Name, 
                                       Alias_Lookup__r.Alias_Responsibility_Center_Code__c 
                                  FROM TMN_User__c 
                                 WHERE Salesforce_User_Account__c  IN : ids]){
            system.debug('alias=' + tmn.Alias_Lookup__r.Name + '; Salesforce_User_Account__c=' + tmn.Salesforce_User_Account__c);
            tmnInfo.add(tmn.Salesforce_User_Account__c, tmn);
        }
        
        // Add the user info to all of their line items
        for (therapistAPLineItem apLine : therapistAPLineItemsList){
        	apLine.setTmn(tmnInfo.get(apLine.Salesforce_User_Account__c));
            system.debug('tmn.Name=' + apLine.alias + '; rate=' + apLine.ratePerHr);
        }
        
        // Sort them so they appear in the right order
        therapistAPLineItems = therapistAPLineItemsMap.values();
        therapistAPLineItems.sort();
        
        monthTotalHrs = 0;
        monthTotalAmount = 0;
        for (TherapistAPLineItem item : therapistAPLineItems){
        	monthTotalHrs += item.approvedHrs;
        	monthTotalAmount += item.getAmount();
        }
        this.reportConstants.reportForMonth = enddate;
        return null;
    }

    public PageReference therapyHrsExtract() {
        PageReference pdf = Page.TherapistsAPExtractPDF;
        String file = 'AP Report-' + startdtStr + '.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        pdf.getHeaders().put('content-disposition', 'attachment; filename="'+file+'"');
    	return pdf;
    }
    
    public PageReference therapyHrsExtractToEXCEL() {
        PageReference pdf = Page.TherapistsAPExtractEXCEL;
        pdf.getHeaders().put('content-disposition', 'attachment;');
        return pdf;
    }
    
    public class TherapistAPLineItem implements Comparable{
    	public String therapistName {get;set;}
    	public Id therapistId {get;set;}
    	public decimal approvedHrs {get;set;}
    	public String discipline {get;set;}
    	public String vendorNo {get;set;}
    	public String glCode {get;set;}
    	public String alias {get;set;}
    	public decimal ratePerHr {get;set;}
        public decimal getAmount(){
        	system.debug('rate=' + ratePerHr + '; hours=' + approvedHrs);
            return (ratePerHr * approvedHrs).setScale(2);
        }    	
    	public String getDescription(){
    		return this.alias.right(2) + '-' + this.therapistName + '-' +  this.reportConst.disciplineAbbreviations.get(this.discipline);
    	}
        public String getDeptDesc(){
            return this.alias.right(2) + '-' +  this.reportConst.disciplineAbbreviations.get(this.discipline);
        }
        public ReportConstants reportConst {get;set;}
        public string vendorName {get;set;}

        public String getInvoiceNumber(){
            return 'I' + String.valueOf(this.reportConst.reportForMonth).replace('-','').right(4) + 
            String.valueOf(this.reportConst.reportForMonth).replace('-','').left(4) + '-' + 
            this.alias + '-' +  this.reportConst.disciplineAbbreviations.get(this.discipline);
        }
        public String getEnterCommentDescription(){
            return this.alias + '-' +  this.therapistName + '-' +  this.reportConst.disciplineAbbreviations.get(this.discipline);
        }
                       
        TherapistAPLineItem (String therapistName, Id therapistId, decimal approvedHrs, String alias, ReportConstants reportConst) {
        	this.therapistName = therapistName;
            this.therapistId = therapistId;
            this.approvedHrs = approvedHrs;
            this.alias = alias;
            this.reportConst = reportConst;
        }
        public void setTmn(TMN_User__c tmn){
            this.discipline = tmn.Discipline__c;
            this.vendorNo = tmn.Account_Number__c;
            this.glCode = tmn.GL_Code__c;
            //this.respCode = tmn.Alias_Lookup__r.Alias_Responsibility_Center_Code__c;
            this.ratePerHr = tmn.Rate__c;
            this.vendorName = tmn.Vendor_Name__c;
            //this.alias = tmn.Alias_Lookup__r.Name;
        }
        public Integer compareTo(Object compareTo){
            TherapistAPLineItem compareToItem = (TherapistAPLineItem) compareTo;
            return (this.alias+this.vendorNo).compareTo(compareToItem.alias+compareToItem.vendorNo);
        }
    }
    
    public class ReportConstants{
        public map<String, String> disciplineAbbreviations {get;set;}
        public String tableName {get{if (String.IsBlank(this.tableName)) {
                                       return '01C901';} 
                                     else return this.tableName;
                                } set;}
        public String locationCode {get{if (String.IsBlank(this.locationCode)) {
                                       return 'D903CAREMERIDIAN' + ' - ' + String.valueOf(this.reportForMonth).replace('-','');} 
                                     else return this.locationCode;
                                } set;}
        public String invoiceType {get;set;}
        public String payCode {get;set;}
        public String blankField {get;set;}
        public String employeeFlag {get;set;}
        public String invoiceDate {get{if (String.IsBlank(this.invoiceDate)) {
                                       return String.valueOf(this.reportForMonth);} 
                                     else return this.invoiceDate;
                                    } set;}
                                
        public string taxAmount {get;set;}
        public string freight {get;set;}
        public string glDate {get{if (String.IsBlank(this.glDate)) {
                                       return String.valueOf(this.reportForMonth);} 
                                     else return this.glDate;
                                } set;}
        public string expPeriod {get{if (String.IsBlank(this.expPeriod)) {
                                       return String.valueOf(this.reportForMonth);} 
                                     else return this.expPeriod;
                                } set;}
        public string siteNumber {get;set;}
        public string payGroup {get;set;}
        public string sourceCode {get;set;}
        public string alternateName {get;set;}
        public string payAlone {get;set;}
        public string fileName {get{if (String.IsBlank(this.fileName)) {
        	                           return 'D903CAREMERIDIAN' + ' - ' + String.valueOf(this.reportForMonth).replace('-','');} 
        	                        else return this.fileName;
        	                        } set;}
        public string worksheetName {get;set;}      	                        
        public date reportForMonth {get;set;}
        
        public ReportConstants(){
        	disciplineAbbreviations = new map<String, String>();
	        disciplineAbbreviations.put('Physical Therapy','PT');
	        disciplineAbbreviations.put('PT-Massage','PT-Massage');
	        disciplineAbbreviations.put('Occupational Therapy','OT');
	        disciplineAbbreviations.put('Speech Therapy','ST');
	        disciplineAbbreviations.put('Social Services','SocServe');
	        disciplineAbbreviations.put('Respiratory','Respiratory');
	        disciplineAbbreviations.put('Dietitian','Dietary');
            invoiceType = '';
            payCode = '1';
            blankField = '';
            employeeFlag = 'E';
            taxAmount = '';
            freight = '';
            siteNumber = '';
            payGroup = '';
            sourceCode = 'CAREMERIDIAN';
            alternateName = '';
            payAlone = '';
            worksheetName = 'D903CAREMERIDIAN';	                	
        }
    }
    
}