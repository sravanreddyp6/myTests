public with sharing class CareMeridianEvaluationEditController {
    public Evaluation__c evaluation { get; set; }
    public String selectedTab { get; set; }
    public String nextTab { get; set; }
    transient public list<String> relatedParties;
    public Related_Party__c[] getRelatedParties() {
        return [ SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c, Status__c
                FROM Related_Party__c WHERE (Person_Being_Referred__c=:evaluation.Referral__r.Person_Being_Referred__c OR Person_being_Served__c = :this.Pbs.Id)];
    }
    
    public String baseUrl {
        get {
            return System.URL.getSalesforceBaseURL().toExternalForm();
        }
    }
    public Related_Party__c currentRelatedParty { get; set; }
    public Id currentRelatedPartyId { get; set; }
    public Person_Being_Referred__c pbr { get; set; }  // Here to save DOB
    public Contact pbs {get; set;} //Make this Page work for PBS as well 
    transient public list<String> sliderOptions;
    public List<String> getSliderOptions(){ return new String[] { '', 'Dependent', 'Max Assist', 'Moderate Assist', 'Minimum Assist', 'CGA', 'Supervised', 'Independent' }; }
    transient public Evaluation_Response__c[] annotations;
    public Evaluation_Response__c[] getAnnotations() {
        return [SELECT ID, Annotation_Height__c, Annotation_Width__c, Annotation_X__c, Annotation_Y__c, Annotation_Source__c, Annotation_Shape__c, Annotation_Text__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id AND RecordType.Name='Annotation'];
    }
    
    public CareMeridianEvaluationEditController(ApexPages.standardController stdController) {
    	if(!test.isRunningTest()){
    		stdController.addFields(new List<String>{'Referral__r.Person_Being_Served__c'});
    	}
        evaluation = (Evaluation__c) stdController.getRecord();
        currentRelatedParty = new Related_Party__c();
        pbs = new Contact();
        pbr = new Person_Being_Referred__c();
        if(string.isNotBlank(this.evaluation.Referral__r.Person_Being_Referred__c)){
	        pbr = [
	            SELECT ID, Date_of_Birth__c,Age_year__c,Age_month__c,Age_days__c,Age__c FROM Person_Being_Referred__c
	            WHERE Id=:evaluation.Referral__r.Person_Being_Referred__c
	        ];
        }
        if(string.isNotBlank(this.evaluation.Referral__r.Person_being_Served__c)){
        	pbs =  [
	            SELECT ID, BirthDate, Age_year__c,Age_month__c,Age_days__c,Age__c FROM Contact
	            WHERE Id=:evaluation.Referral__r.Person_Being_Served__c
	        ];
        }
        if (ApexPages.currentPage().getParameters().get('tab') != null) {
            selectedTab = ApexPages.currentPage().getParameters().get('tab');
        }
        //this.age = pbr.Age_text__c;
    }
    
    transient public string age;
    public String getAge(){ 
    	if(string.ISNOTBLANK(this.pbs.Id)){
    		return Utility.getAge(String.valueOf(this.pbs.Age_year__c),this.pbs.Age_month__c,this.pbs.Age_days__c);
    	}else{
    		return Utility.getAge(String.valueOf(this.pbr.Age_year__c),this.pbr.Age_month__c,this.pbr.Age_days__c);
    	}
    }
    
    public void showAddRelatedParty() {
        this.currentRelatedParty = new Related_Party__c();
        if(string.isNotBlank(this.pbr.Id)){
        	 this.currentRelatedParty.Person_Being_Referred__c = this.evaluation.Referral__r.Person_Being_Referred__c;
        }
       	if(string.isNOTBLANK(this.pbs.Id)){
       		this.currentRelatedParty.Person_Being_Served__c  = this.pbs.Id;
       	}
        this.currentRelatedParty.RecordTypeId = Utility.getRelatedPartyRecordTypeFromReferral(new Referral__c(Id=this.evaluation.Referral__c));
        this.currentRelatedParty.Status__c = 'Active';
    }
    
    public void showEditRelatedParty() {
        this.currentRelatedParty = [
            SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c,
            Phone_2__c, Phone_2_Type__c, Comments__c, Status__c
            FROM Related_Party__c WHERE ID=:currentRelatedPartyId
        ];
    }
    
    public void saveRelatedParty() {
        try {
            System.debug('currentRelatedParty: ' + currentRelatedParty);
            upsert currentRelatedParty;
        } catch (DMLException ex) {
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }
    
    @RemoteAction
    public static Evaluation_Response__c addOrModifyAnnotation(ID annotationId, String source, Decimal x, Decimal y, Decimal Width, Decimal Height, String Shape, String Text, String evaluationId) {
        Evaluation_Response__c annotation;
        if (annotationId!=null) {
            annotation = [
                SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId
            ];
        } else {
            annotation = new Evaluation_Response__c();
            annotation.Evaluation__c = evaluationId;
            annotation.RecordTypeId = Utility.getEvaluationResponseRecordType('Annotation');
        }
        annotation.Annotation_Height__c = Height;
        annotation.Annotation_Width__c = Width;
        annotation.Annotation_X__c = x;
        annotation.Annotation_Y__c = y;
        annotation.Annotation_Source__c = Source;
        annotation.Annotation_Shape__c = Shape;
        annotation.Annotation_Text__c = Text;
        System.debug('Annotation to upsert: ' + annotation);
        upsert annotation;
        return annotation;
    }
    
    @RemoteAction
    public static void deleteAnnotation(ID annotationId) {
        delete [
            SELECT ID FROM Evaluation_Response__c WHERE ID=:annotationId
        ];
    }
    
    public PageReference save() {
        return this.save(false);
    }
    
    private PageReference submit() {
        return this.save(true);
    }
    
    public PageReference changeTab() {
        System.debug('nextTab: ' + nextTab);
        // When the user changes tab, we need to save his/her progress on the
        // previous tab as well. Therefore, if any validation error happens here,
        // we'll need to keep the user on the previous tab to fix their input
        // first.
        if (this.save(false) != null) {
            System.debug('Save successful!');
            selectedTab = nextTab;
        }
        return null;
    }
    
    private void updateAge () {
        Date birthday = pbr.Date_of_Birth__c;
        Date today = Date.today();
        Integer years =  today.year() - birthday.year();
        Integer currMonth = Today.month();
        Integer birthMonth = birthday.month();
        Integer months = currMonth - birthMonth;
        Integer days = 0;       
        if (months < 0)
        {
            years--;
            months = 12 - birthMonth + currMonth;
        } else if (months == 0 && Today.day() < birthDay.day())
        {
            years--;
            months = 11;
        }
        
        if(Today.day() < birthDay.day()){
            months--;
        }
        
        if (Today.day() > birthDay.day())
            days = Today.day() - birthDay.day();
        else if (Today.day() < birthDay.day())
        {
            days = Date.daysInMonth(Today.year(), Today.month() -1) - birthDay.day() + Today.day();
        } else
        {
            days = 0;
            if (months == 12)
            {
                years++;
                months = 0;
            }
        }
        
        this.pbr.Age_year__c = years;
        this.pbr.Age_month__c = String.valueOf(months);
        this.pbr.Age_days__c = String.valueOf(days);
        this.pbr.Age__c = years;
        update this.pbr;
    }
    /**
* This method needs to know about whether the request is ready for submission,
* and also the currently selected tab, because we need to group validation
* on both the online form and the paper form in one place.
*/
    private PageReference save(Boolean submitted) {
        // All the validation goes here, partitioned by page. We can't do
        // object-level validation, because if there are 2 errors on 2 pages,
        // the user won't be able to save at all.
        if (submitted || selectedTab == 'detailsTab' || selectedTab == null) {
        }
        update this.evaluation;
        if(pbr.Date_of_Birth__c!=null){
            updateAge();
        }
        Referral__c ref =[SELECT Id, Date_of_Injury__c FROM Referral__c WHERE Id=:evaluation.Referral__c];
        if(ref.Date_of_Injury__c != evaluation.Date_of_Injury_Onset__c ){
            ref.Date_of_Injury__c = evaluation.Date_of_Injury_Onset__c;
            update ref;
        }
        //return stdController.view();
        return new PageReference('/apex/CareMeridianEvaluationView?id=' + evaluation.Id + '&tab=' + selectedTab);
    }
    
    public String bodyMapUrl { get {
        Attachment[] attachments = [
            SELECT Id FROM Attachment
            WHERE ParentId=:evaluation.Referral__c
            AND Name='BodyMarkup.png'
        ];
        if (attachments.size() > 0) {
            return '/servlet/servlet.FileDownload?file=' + attachments[0].Id;
        }
        return null;
    } }
    
}