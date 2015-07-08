public with sharing class neuroreportofserviceController {
    public transient List<lineItem> lineitems {get;set;}
    public Funding_Source__c fSource {get; set;}
    /*public Date startDate {get;set;}
    public Date EndDate {get; set;}
    public User caseManager {get; set;}*/
    public string SOQL{get; set;}
    private Apexpages.standardController controller;
    set<string> statuses = new Set<string>{'Active', 'Active Final'};
   
    public neuroreportofserviceController(Apexpages.StandardController controller){
        lineItems = new List<lineItem>();
        this.controller = controller;
        this.fSource = (Funding_Source__c)controller.getRecord();
        
    }
    
    public pageReference doSearch(){
    	/*if(fSource.Effective_Date_of_Cost_therapy_Auth__c == null){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter Effective Date'));
    		return null;
    	}
    	if(fSource.Term_Date_of_Cost_therapy_Auth__c == null){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter Term Date'));
    		return null;
    	}*/
    	Datetime startdt = DateTime.newInstance( fSource.Effective_Date_of_Cost_therapy_Auth__c, Time.newInstance(0,0,0,0));
        Datetime enddt = DateTime.newInstance ( fSource.Term_Date_of_Cost_therapy_Auth__c, Time.newInstance(0, 0, 0, 0));  
    	SOQL = '';
    	SOQL = 'SELECT Id, OT_Auth_Units__c, PT_Auth_Units__c, Service_Assignment__c, Case_Manager__c, Auth_Excess_Justification__c  FROM Funding_Source__c WHERE Funding_Source_Status__c IN :statuses AND Recordtype.Name = \'NeuroRestorative\'';
    	SOQL = SOQL+ ' AND Effective_Date_of_Cost_therapy_Auth__c >= '+ startdt.format('yyyy-MM-dd');
    	SOQL = SOQL+ ' AND Term_Date_of_Cost_therapy_Auth__c <= '+ enddt.format('yyyy-MM-dd');
    	
    	if(string.isNotBLANK(fSource.Case_Manager__c)){
    		string cm = string.valueOf(fSource.Case_Manager__c);
    		SOQL = SOQL+ ' AND Case_Manager__c = \''+fSource.Case_Manager__c+'\'';
    	}
    	lineItems = new List<lineItem>();
    	List<Funding_Source__c> temp = Database.Query(SOQL);
    	Map<string, Funding_Source__c> fundingMap = new Map<string, Funding_Source__c>();
    	set<id> servAssigns = new set<id>();
    	
    	for(Funding_Source__c fs: temp){
    		if(fs.Auth_Excess_Justification__c != null){
    			fundingMap.put(fs.Id+'~'+fs.Service_Assignment__c, fs);
    			servAssigns.add(fs.Service_Assignment__c);	
    		}
    	}
    	
    	Map<id, Decimal> otMap = new Map<id, Decimal>();
    	Map<id, Decimal> ptMap = new Map<id, Decimal>();
    	
    	
    	for(AggregateResult ar: [SELECT Sum(Units__c) units,Service_Assignment__c sa, Therapy_Discipline__c td FROM Progress_Note__c WHERE (Date_of_Service__c >= :fSource.Effective_Date_of_Cost_therapy_Auth__c AND  Date_of_Service__c <= :fSource.Term_Date_of_Cost_therapy_Auth__c) AND Type_of_Contact__c != 'No-Show' AND Recordtype.Name = 'Therapy' AND Therapy_Discipline__c != null AND Service_Assignment__c IN: servAssigns GROUP BY Service_Assignment__c, Therapy_Discipline__c]){
    		if((String)ar.get('td') == 'OT'){
    			otMap.put((id)ar.get('sa'),(Decimal)ar.get('units'));
    		}
    		if((String)ar.get('td') == 'PT'){
    			ptMap.put((id)ar.get('sa'),(Decimal)ar.get('units'));
    		}
    	}
    	
    	
    	for(Funding_Source__c fs: fundingMap.values()){
    		if(servAssigns.contains(fs.Service_Assignment__c)){
    			//servPNRollup spn = servPNMap.get(fs.Service_Assignment__c);
    			lineitems.add(new lineitem(fs,ptMap.get(fs.Service_Assignment__c),otMap.get(fs.Service_Assignment__c)));
    		}else{
    			lineitems.add(new lineitem(fs,0,0));
    		}
    	}
       
        return null;
    }
    
    
    
    
    
    
    
    
  /* public class servPNRollup{
   	public id SAId {get;set;}
   	public Decimal OT{get; set;}
   	public Decimal PT {get; set;}
   	
   	public servPNRollup (AggregateResult ar){
   		this.SAId = (Id)ar.get('sa');
   		if((string)ar.get('td') == 'OT'){
   			this.OT = (Decimal)ar.get('units');
   		}
   		if((string)ar.get('td') == 'PT'){
   			this.PT = (Decimal)ar.get('units');
   		}
   	
   	}
   	
   	public servPNRollup (id sa, Decimal pt, Decimal ot){
   		this.SAId = sa;
   		this.OT = ot;
   		this.PT = pt;
   	
   	}
   	
   }*/
    
    
    
    public class lineItem {
        
        public Funding_Source__c fundingSource {get;set;}
        public Decimal ptRollup {get;set;}
        public Decimal otRollup {get;set;}
        
        public lineItem(Funding_Source__c f, Decimal pt, Decimal ot){
            this.fundingSource = f;
            this.ptRollup = pt;
            this.otRollup = ot;
            
        }
        
        
    }

}