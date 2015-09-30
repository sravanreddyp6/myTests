public with sharing class PB_networkselectionController {
	public list<selectOption> networkOfferings {get;set;}
	public string selectedNetwork {get;set;}
	
	public PB_networkselectionController(){
		networkOfferings = new List<selectOption>();
		networkOfferings.add(new selectoption('', '--None--'));
		for(Recordtype n: [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'PB_DocPacket__c' AND IsActive = true]){
			networkOfferings.add(new selectoption(n.Name,n.Name));
		}
		selectedNetwork = null;
	}
	
	public pagereference proceed(){
		if(selectedNetwork == null ){
			apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose a Network'));
			return null;
		}
		else{
			pageReference pg = new Pagereference('/apex/PB_DocPack_Admin_Form');
			pg.getParameters().put('network',selectedNetwork);
			return pg;
		}
	}
}