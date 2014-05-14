public with sharing class NursingEvaluationViewController {
     public Evaluation__c evaluation { get; set; }
     public ApexPages.standardController stdController;
     public String selectedTab { get; set; }
     public Related_Party__c[] relatedParties { set;
        get {
            return [
                SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c,
                       Phone_2__c, Phone_2_Type__c, Comments__c
                FROM Related_Party__c WHERE Person_Being_Served__c = :this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__r.Id
            ];
        }
    }
     
    public String baseUrl {
        get {
            return System.URL.getSalesforceBaseURL().toExternalForm();
        }
    }
     
    public Related_Party__c currentRelatedParty { get; set; }
    public Id currentRelatedPartyId { get; set; }
    
    public NursingEvaluationViewController(ApexPages.StandardController stdcontroller) {
        this.stdController = stdController;
        //putting all fields in context
        Map<String, Schema.Sobjectfield> fieldMap = Schema.SobjectType.Evaluation__c.fields.getMap();
        evaluation = (Evaluation__c) stdController.getRecord();
        selectedTab = ApexPages.currentPage().getParameters().get('tab');
    }
    
    public void showAddRelatedParty() {
        this.currentRelatedParty = new Related_Party__c();
        this.currentRelatedParty.Person_Being_Served__c = this.evaluation.ServiceAssignment__r.Person_Being_Served__r.Id;
        this.currentRelatedParty.RecordTypeId = '012U0000000Dj0Y';//Need to make it Dynamic 
    }

    public void showEditRelatedParty() {
        this.currentRelatedParty = [
            SELECT ID, Name, Type__c, Address__c, Email__c, Phone__c, Phone_1_Type__c,
                   Phone_2__c, Phone_2_Type__c, Comments__c
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

}