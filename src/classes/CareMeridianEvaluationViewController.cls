public with sharing class CareMeridianEvaluationViewController {
    public Evaluation__c evaluation { get; set; }
    public String selectedTab { get; set; }
    public Service_Assignment__c SA {get; set;}
    public Related_Party__c[] relatedParties { set;
        get {
            if(string.isNotBlank(this.evaluation.Referral__r.Person_being_Served__c)){
    			return [ SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c, Status__c
               		 FROM Related_Party__c WHERE Person_being_Served__c = :this.evaluation.Referral__r.Person_Being_Served__c];
    		}if(string.isNotBlank(this.evaluation.Referral__r.Person_Being_Referred__c)){
    			return [ SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c, Comments__c, Status__c
                	FROM Related_Party__c WHERE Person_being_Referred__c = :this.evaluation.Referral__r.Person_Being_Referred__c];
    		}
    		return null;
        }
    }
    public String baseUrl {
        get {
            return System.URL.getSalesforceBaseURL().toExternalForm();
        }
    }
    public Related_Party__c currentRelatedParty { get; set; }
    public Id currentRelatedPartyId { get; set; }

    transient public list<String> sliderOptions;
    public List<String> getSliderOptions(){ return new String[] { '', 'Dependent', 'Max Assist', 'Moderate Assist', 'Minimum Assist', 'CGA', 'Supervised', 'Independent' }; }

    public Evaluation_Response__c[] annotations { set;
        get {
            return [
                SELECT ID, Annotation_Height__c, Annotation_Width__c,
                       Annotation_X__c, Annotation_Y__c, Annotation_Source__c,
                       Annotation_Shape__c, Annotation_Text__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                 AND RecordType.Name='Annotation'
            ];
        }
    }
    public CareMeridianEvaluationViewController(ApexPages.standardController stdController) {
    	if(!test.isRunningTest()){
    		stdController.addFields(new List<string>{'Referral__r.Person_Being_Referred__c', 'Referral__r.Person_Being_Served__c','Referral__r.Person_Being_Referred__r.Age_text__c', 
    												'Referral__r.Person_Being_Served__r.Age_text__c'});
    	}
        evaluation = (Evaluation__c) stdController.getRecord();
        currentRelatedParty = new Related_Party__c();
        selectedTab = ApexPages.currentPage().getParameters().get('tab');

           string file;
        file = 'Person Being Referred- '+ this.evaluation.Referral__r.Person_Being_Referred__r.Full_Name__c+'.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        // Assigns the person being referred Name to the PDF dynamically
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+file);
        //Grab the Service Assignment details to populate the breadcrumb when user opens Evaluation from Service Assignment Page. EC-41 Sravan:10/13/2014 1:15 PM.
        if(Apexpages.currentpage().getparameters().get('SA_Id') != null ){
            SA =[SELECT ID, Name, Admission__r.Name,Admission__c, Admission__r.Person_being_served__c, Admission__r.Person_being_served__r.Name FROM Service_Assignment__c WHERE Id =:ApexPages.currentPage().getParameters().get('SA_Id') ];
        }
         /*Person_Being_Referred__c pbr = [
            SELECT ID, Date_of_Birth__c,Age_year__c,Age_month__c,Age_days__c,Age__c,Age_text__c FROM Person_Being_Referred__c
            WHERE Id=:evaluation.Referral__r.Person_Being_Referred__c
        ];*/
       	if(string.isNOTBLANK(this.evaluation.Referral__r.Person_Being_Served__c)){
       		this.age = this.evaluation.Referral__r.Person_Being_Served__r.Age_text__c;
       	}else{
       		this.age = this.evaluation.Referral__r.Person_Being_Referred__r.Age_text__c;
       	}
          
    }
    
  public string age{set;get;}
    
    public void showAddRelatedParty() {
        this.currentRelatedParty = new Related_Party__c();
        if(string.isNOTBLANK(this.evaluation.Referral__r.Person_Being_Served__c)){
        	this.currentRelatedParty.Person_Being_Referred__c = this.evaluation.Referral__r.Person_Being_Served__c;
        }else{
        	this.currentRelatedParty.Person_Being_Referred__c = this.evaluation.Referral__r.Person_Being_Referred__c;
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
    
    public PageReference reDirect() {
        PageReference returnURL;
        if(evaluation.RecordTypeId == Utility.getEValuationRecordType('NursesAssessment')) 
            returnURL = new PageReference ('/apex/NursingEvaluationView?id='+evaluation.id);
        system.debug('UUUUUUUUUUUUUURRRRRRRRRRRRRRRRRRRRLLLLLLLLLLLLLLLLLLL'+returnURL);

        return returnURL;
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