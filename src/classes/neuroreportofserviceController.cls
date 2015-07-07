public with sharing class neuroreportofserviceController {
    public List<lineItem> lineitems {get;set;}
    public Funding_Source__c fSource {get; set;}
    /*public Date startDate {get;set;}
    public Date EndDate {get; set;}
    public User caseManager {get; set;}*/
    public string SOQL;
    
    public neuroreportofserviceController(){
        lineItems = new List<lineItem>();
        //fSource.Effective_Date_of_Cost_therapy_Auth__c = null;
        //fSource.Term_Date_of_Cost_therapy_Auth__c = null;
        SOQL = 'SELECT Id, OT_Auth_Units__c, PT_Auth_Units__c, Case_Manager__c FROM Funding_Source__c WHERE Recordtype.Name';
    }
    
    public pageReference doSearch(){
        
        return null;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    public class lineItem {
        
        public Funding_Source__c fundingSource {get;set;}
        public integer ptRollup {get;set;}
        public integer otRollup {get;set;}
        
        public lineItem(Funding_Source__c f, integer pt, integer ot){
            this.fundingSource = f;
            this.ptRollup = pt;
            this.otRollup = ot;
            
        }
        
        
    }

}