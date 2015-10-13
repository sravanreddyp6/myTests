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
    
    private map<String, Integer> integerMonth = new map<String, Integer>();
    private static map<String, String> disciplineAbbreviations = new map<String, String>();
        
    public TherapistAPExtract(){
        List<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
                                           FROM service_assignment__c
                                          GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c 
                                          ORDER BY service_location__r.program__c];
        for (AggregateResult slPrgm : slPrgms) {
            programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
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
    }
    
    public pagereference AddPrograms(){
        for (Id p :selectedPrograms){
            for(Integer i=0; i < programslist.size(); i++){
                if (programslist.get(i).getValue() == p) {
                    select2list.add(new SelectOption(programslist.get(i).getValue(), programslist.get(i).getLabel()));
                    programslist.remove(i);
                    break;
                }
            }
        }
        UpdateProgramSelections();
        return null;
    }

    public pagereference RemovePrograms(){
        for (Id p :select2PrmIds){
            for(Integer i=0; i < select2list.size(); i++){
                if (select2list.get(i).getValue() == p) {
                    programslist.add(new SelectOption(select2list.get(i).getValue(), select2list.get(i).getLabel()));
                    select2list.remove(i);
                    break;
                }
            }
        }
        UpdateProgramSelections();
        return null;
    }

    public void UpdateProgramSelections(){
    	startdate = Date.newInstance(Integer.valueOf(startdtStr.substring(startdtStr.length() - 4)), integerMonth.get(startdtStr.substring(0, startdtStr.length() - 5) ), 1);
        enddate = startdate.addMonths(1);
        List<id> selectedPrmIds = new List<id>();
        for (selectOption so : select2list){
            selectedPrmIds.add(so.getValue());
        }
        PBSList.clear();
        for (AggregateResult TherapyHr : [SELECT Owner.Name ownerName, OwnerId FROM Therapy_Hour__c 
                                           WHERE Start_time__c >= : StartDate AND End_time__c <= : EndDate.addDays(1) AND Service_Assignment__r.Service_location__c IN :selectedPrmIds AND status__c = 'Approved'
                                           group BY Owner.Name, OwnerId order BY Owner.Name]){
               PBSList.add(new SelectOption((Id)TherapyHr.get('OwnerId'), (String)TherapyHr.get('ownerName')));
        }
    }
        
    public PageReference cancelToNewRun() {
        PageReference pageRef = new PageReference('/apex/TherapistsAPExtract');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void runReport() {
        disciplineAbbreviations.put('Physical Therapy','PT');
        disciplineAbbreviations.put('PT-Massage','PT-Massage');
        disciplineAbbreviations.put('Occupational Therapy','OT');
        disciplineAbbreviations.put('Speech Therapy','ST');
        disciplineAbbreviations.put('Social Services','SocServe');
        disciplineAbbreviations.put('Respiratory','Respiratory');
        disciplineAbbreviations.put('Dietitian','Dietary');
    	map<Id, TherapistAPLineItem> therapistAPLineItemsMap = new map<Id, TherapistAPLineItem>();
    	
        for (AggregateResult aggre : [SELECT OwnerId, Owner.name ownerName, sum(Number_of_Hours__c) approvedHrs FROM Therapy_Hour__c 
                                      WHERE OwnerId IN :selectedPBS AND Start_time__c >= : StartDate AND End_time__c < : EndDate.addDays(1) AND status__c = 'Approved' group by OwnerId, Owner.name]){
            therapistAPLineItemsMap.put((Id) aggre.get('OwnerId'), new TherapistAPLineItem((String)aggre.get('ownerName'), (Id) aggre.get('OwnerId'), (decimal) aggre.get('approvedHrs')) );
        }
        
        for (TMN_User__c tmn : [SELECT Salesforce_User_Account__c, Account_Number__c, Discipline__c, GL_Code__c, Rate__c, Vendor_Name__c, Alias_Lookup__r.Alias_Responsibility_Center_Code__c FROM TMN_User__c 
                                 WHERE Salesforce_User_Account__c IN : therapistAPLineItemsMap.keyset()]){
            therapistAPLineItemsMap.get(tmn.Salesforce_User_Account__c).setTmn(tmn);
        }
        therapistAPLineItems = therapistAPLineItemsMap.values();
        therapistAPLineItems.sort();
        
        monthTotalHrs = 0;
        monthTotalAmount = 0;
        for (TherapistAPLineItem item : therapistAPLineItems){
        	monthTotalHrs += item.approvedHrs;
        	monthTotalAmount += item.getAmount();
        }
    }

    public PageReference therapyHrsExtract() {
    	disciplineAbbreviations.put('Physical Therapy','PT');
        disciplineAbbreviations.put('PT-Massage','PT-Massage');
        disciplineAbbreviations.put('Occupational Therapy','OT');
        disciplineAbbreviations.put('Speech Therapy','ST');
        disciplineAbbreviations.put('Social Services','SocServe');
        disciplineAbbreviations.put('Respiratory','Respiratory');
        disciplineAbbreviations.put('Dietitian','Dietary');
        PageReference pdf = Page.TherapistsAPExtractPDF;
        String file = 'AP Report-' + startdtStr + '.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        pdf.getHeaders().put('content-disposition', 'attachment; filename="'+file+'"');
    	return pdf;
    }
    
    public class TherapistAPLineItem implements Comparable{
    	public String therapistName {get;set;}
    	public Id therapistId {get;set;}
    	public decimal approvedHrs {get;set;}
    	public String discipline {get;set;}
    	public String vendorNo {get;set;}
    	public String glCode {get;set;}
    	public String respCode {get;set;}
    	public decimal ratePerHr {get;set;}
        public decimal getAmount(){
            return (ratePerHr * approvedHrs).setScale(2);
        }    	
    	public String getDescription(){
    		return this.respCode.right(2) + '-' + this.therapistName + '-' +  TherapistAPExtract.disciplineAbbreviations.get(this.discipline);
    	}
        public String getDeptDesc(){
            return this.respCode.right(2) + '-' +  TherapistAPExtract.disciplineAbbreviations.get(this.discipline);
        }
        TherapistAPLineItem (String therapistName, Id therapistId, decimal approvedHrs) {
        	this.therapistName = therapistName;
            this.therapistId = therapistId;
            this.approvedHrs = approvedHrs;
        }
        public void setTmn(TMN_User__c tmn){
            this.discipline = tmn.Discipline__c;
            this.vendorNo = tmn.Account_Number__c;
            this.glCode = tmn.GL_Code__c;
            this.respCode = tmn.Alias_Lookup__r.Alias_Responsibility_Center_Code__c;
            this.ratePerHr = tmn.Rate__c;

        }
        public Integer compareTo(Object compareTo){
            TherapistAPLineItem compareToItem = (TherapistAPLineItem) compareTo;
            return (this.respCode+this.vendorNo).compareTo(compareToItem.respCode+compareToItem.vendorNo);
        }
    }
    
}