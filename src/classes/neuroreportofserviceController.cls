public with sharing class neuroreportofserviceController {
    public List<lineItem> lineitems {get;set;}
    public Funding_Source__c fSource {get; set;}
   // public string SOQL{get; set;}  
    private Apexpages.standardController controller;
    set<string> statuses = new Set<string>{'Active', 'Active Final'};
    public Boolean onlyNoshow {get; set;}
   
    public neuroreportofserviceController(Apexpages.StandardController controller){
        lineItems = new List<lineItem>();
        this.controller = controller;
       
      /*  if(!test.isRunningTest()){
        	controller.addFields(new List<String>{'Service_Assignment__r.Program_Detail__c'});
        }*/
        this.fSource = (Funding_Source__c)controller.getRecord();
        getStateList();
       	getProgramList();
       	selStates = new List<String>();
       	selPrograms = new List<String>();
        onlyNoshow = false;
    }
    
    
    public List<SelectOption> states { get;set; }
    public List<SelectOption> programs { get; set; }
    public List<String> selStates {get; set;}
    public List<String> selPrograms {get; set;}
    public string uiselStates { get; set;}
    public string uiselProgs { get; set; }
    private transient List<ServiceLocPrograms> proglistStates;
    public transient String prgmsWithStates;
    
    public String getPrgmsWithStates() {
    	return JSON.serialize(proglistStates);
    } 
    
    
    
    private List<SelectOption> getStateList() {
    	
    	states = new List<selectoption>();
    	List<AggregateResult> statelist = [ select state__c, count(id) from service_location__c where state__c <> '' group by state__c order by state__c ];
    	string statecode = '';
    	
    	// look up in custom settings table to get state name
    	
    	for (AggregateResult ag : statelist )
    	{
    	    statecode = (string)ag.get('state__c');
    		states.Add( new selectOption( statecode, statecode) ) ;
    	}
    
    	return states;
    }
    
     private List<SelectOption> getProgramList() {
    	
    	programs = new List<selectoption>();
    	proglistStates = new List<ServiceLocPrograms>();
    	List<Service_Location__c> proglist = [ select program__c, state__c from service_location__c where state__c <> '' order by program__c ];
    	
    	
    	for (Service_Location__c sl : proglist )
    	{
    	    proglistStates.add(new ServiceLocPrograms(sl.program__c, sl.state__c));
    		programs.Add( new selectOption( sl.Program__c, sl.program__c) ) ;
    	}
    	
    	
    	return programs;
    }
    
    public pageReference doSearch(){
    	
    	  
    	Datetime startdt = DateTime.newInstance( fSource.Effective_Date_of_Cost_therapy_Auth__c, Time.newInstance(0,0,0,0));
        Datetime enddt = DateTime.newInstance ( fSource.Term_Date_of_Cost_therapy_Auth__c, Time.newInstance(0, 0, 0, 0)); 
        Map<id, Decimal> otMap = new Map<id, Decimal>();
    	Map<id, Decimal> ptMap = new Map<id, Decimal>();
    	Map<id, Decimal> slpMap = new Map<id, Decimal>();
    	Map<id, Decimal> bitMap = new Map<id, Decimal>();
    	Map<id, Decimal> counsellingMap = new Map<id, Decimal>();
    	List<AggregateResult> pnAggr = new List<AggregateResult>();
    	Map<string, Funding_Source__c> fundingMap = new Map<string, Funding_Source__c>();
    	set<id> servAssigns = new set<id>();
    	
    	if(fSource.Effective_Date_of_Cost_therapy_Auth__c > fSource.Term_Date_of_Cost_therapy_Auth__c){
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Term Date should be greater than Effective Date'));
    		return null;
    	}
    	
    	selStates = uiselStates.split(',');
        selPrograms = uiselProgs.split(',');
        
    	string SOQL = '';
    	SOQL = 'SELECT Id, Name, OT_Auth_Units__c, PT_Auth_Units__c, BIT_Auth_Units__c,Counselling_Auth_Units__c,SLP_Auth_Units__c,Total_Authorized_Therapy_Units__c, Auth_Units_Grand_Total__c, Effective_Date_of_Cost_therapy_Auth__c, Term_Date_of_Cost_therapy_Auth__c, Service_Assignment__c,Service_Assignment__r.Person_being_Served__r.name, Case_Manager__c, Case_Manager__r.Name, Auth_Excess_Justification__c  FROM Funding_Source__c';
    	SOQL = SOQL +' WHERE Funding_Source_Status__c IN :statuses AND Recordtype.Name = \'NeuroRestorative\' AND Type_of_Coverage__c =\'Primary\'';
    	SOQL = SOQL+ ' AND ((Effective_Date_of_Cost_therapy_Auth__c <= '+ enddt.format('yyyy-MM-dd')+ ' AND Term_Date_of_Cost_therapy_Auth__c >= '+ enddt.format('yyyy-MM-dd') + '))'; 
    	//SOQL = SOQL+ ' AND (Effective_Date_of_Cost_therapy_Auth__c >= '+ startdt.format('yyyy-MM-dd')+' AND Effective_Date_of_Cost_therapy_Auth__c <= '+ enddt.format('yyyy-MM-dd')+')';
    	//SOQL = SOQL+ ' AND ((Effective_Date_of_Cost_therapy_Auth__c <= '+ startdt.format('yyyy-MM-dd')+ ' AND Term_Date_of_Cost_therapy_Auth__c >= '+ startdt.format('yyyy-MM-dd') + ' AND Term_Date_of_Cost_therapy_Auth__c <= '+ enddt.format('yyyy-MM-dd')+') OR (Effective_Date_of_Cost_therapy_Auth__c >= '+ startdt.format('yyyy-MM-dd')+' AND Term_Date_of_Cost_therapy_Auth__c <= '+enddt.format('yyyy-MM-dd')+') OR(Effective_Date_of_Cost_therapy_Auth__c <= '+ enddt.format('yyyy-MM-dd')+ ' AND Term_Date_of_Cost_therapy_Auth__c >= '+ enddt.format('yyyy-MM-dd') + ' AND Effective_Date_of_Cost_therapy_Auth__c >= '+ startdt.format('yyyy-MM-dd')+'))'; 
    	//SOQL = SOQL+ ' AND (Term_Date_of_Cost_therapy_Auth__c <= '+ enddt.format('yyyy-MM-dd')+' AND Term_Date_of_Cost_therapy_Auth__c >= '+startdt.format('yyyy-MM-dd')+')';
    //	SOQL = SOQL+ ' OR (Effective_Date_of_Cost_therapy_Auth__c >= '+ startdt.format('yyyy-MM-dd')+' AND Term_Date_of_Cost_therapy_Auth__c <= '+enddt.format('yyyy-MM-dd')+')';
    	
    	if(string.isNotBLANK(fSource.Case_Manager__c)){
    		string cm = string.valueOf(fSource.Case_Manager__c);
    		SOQL = SOQL+ ' AND Case_Manager__c = \''+fSource.Case_Manager__c+'\'';
    	}
    	
    	if(selPrograms.size() >  0 && selPrograms[0] != ''){
    		
    		SOQL = SOQL + ' AND Service_Assignment__r.Program_Detail__c IN: selPrograms';
    		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, SOQL));
    		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, selPrograms[0]));
    		
    	}
    	
    	lineItems = new List<lineItem>();
    	List<Funding_Source__c> temp = Database.Query(SOQL);
    	
    	for(Funding_Source__c fs: temp){
    		//if(fs.Auth_Excess_Justification__c != null){
    			fundingMap.put(fs.Id+'~'+fs.Service_Assignment__c, fs);
    			servAssigns.add(fs.Service_Assignment__c);	
    		//}
    	}
    	
    	if(onlyNoshow){
    		pnAggr = [SELECT Sum(Units__c) units,Service_Assignment__c sa, Therapy_Discipline__c td FROM Progress_Note__c WHERE (Date_of_Service__c >= :fSource.Effective_Date_of_Cost_therapy_Auth__c AND  Date_of_Service__c <= :fSource.Term_Date_of_Cost_therapy_Auth__c) AND Type_of_Contact__c = 'No-Show' AND Recordtype.Name = 'Therapy' AND Therapy_Discipline__c != null AND Disregard_Note__c = false AND Service_Assignment__c IN: servAssigns GROUP BY Service_Assignment__c, Therapy_Discipline__c];
    		
    	}else{
    		pnAggr = [SELECT Sum(Units__c) units,Service_Assignment__c sa, Therapy_Discipline__c td FROM Progress_Note__c WHERE (Date_of_Service__c >= :fSource.Effective_Date_of_Cost_therapy_Auth__c AND  Date_of_Service__c <= :fSource.Term_Date_of_Cost_therapy_Auth__c) AND Type_of_Contact__c != 'No-Show' AND Recordtype.Name = 'Therapy' AND Therapy_Discipline__c != null AND Disregard_Note__c = false AND Service_Assignment__c IN: servAssigns GROUP BY Service_Assignment__c, Therapy_Discipline__c];
    	}
    	
    	
    	for(AggregateResult ar: pnAggr){
    		if((String)ar.get('td') == 'OT'){
    			otMap.put((id)ar.get('sa'),(Decimal)ar.get('units'));
    		}
    		if((String)ar.get('td') == 'PT'){
    			ptMap.put((id)ar.get('sa'),(Decimal)ar.get('units'));
    		}
    		if((String)ar.get('td') == 'SLP'){
    			slpMap.put((id)ar.get('sa'),(Decimal)ar.get('units'));
    		}
    		if((String)ar.get('td') == 'BIT'){
    			bitMap.put((id)ar.get('sa'),(Decimal)ar.get('units'));
    		}
    		if((String)ar.get('td') == 'Counseling'){
    			counsellingMap.put((id)ar.get('sa'),(Decimal)ar.get('units'));
    		}
    		
    	}
    	
    	
    	for(Funding_Source__c fs: fundingMap.values()){
    		if(servAssigns.contains(fs.Service_Assignment__c)){
    			//servPNRollup spn = servPNMap.get(fs.Service_Assignment__c);
    			lineitems.add(new lineitem(fs,otMap.get(fs.Service_Assignment__c),ptMap.get(fs.Service_Assignment__c), slpMap.get(fs.Service_Assignment__c),bitMap.get(fs.Service_Assignment__c),counsellingMap.get(fs.Service_Assignment__c)));
    		}else{
    			lineitems.add(new lineitem(fs,0,0,0,0,0));
    		}
    	}
       	if(lineItems.size() == 0){
       		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Matching Funding Sources found for the selected filter criteria'));
    		return null;
       	}
       	
        return null;
    }
    
    public pageReference exporttoExcel(){
    	PageReference pg = new PageReference('/apex/neuroReportofServiceExcel');
    	pg.setRedirect(false); // Sravan - So that the view state is transferred to the excel download page
    	return pg;
    	
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
    
    
    //Wrapper class to link funding sources and the rollup values from progress notes. Each line item will be a row in the report - Sravan - 07/08/15
    
    public class lineItem {
        
        public Funding_Source__c fundingSource {get;set;}
        public Decimal otRollup {get;set;}
        public Decimal ptRollup {get;set;}
        public Decimal bitRollup {get; set;}
        public Decimal slpRollup {get; set;}
        public Decimal counsellingRollup {get; set;}
        
        
        public lineItem(Funding_Source__c f, Decimal ot, Decimal pt,Decimal slp, Decimal bit, Decimal counselling){
            this.fundingSource = f;
            this.ptRollup = integer.valueOf(pt);
            this.otRollup = integer.valueOf(ot);
            this.bitRollup = integer.valueOf(bit);
            this.slpRollup = integer.valueOf(slp);
            this.counsellingRollup = integer.valueOf(counselling);
            
        }
        
        
    }
    
    private class ServiceLocPrograms{
    	String program;
    	String state;
    	ServiceLocPrograms(String program, String state){
    		this.program = program;
    		this.state = state;
    	}
    }

}