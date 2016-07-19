public with sharing class TabContractExt {
	public string contracts {get;set;}
	
	public TabContractExt(Apexpages.standardSetController controller) {
		List <TMN_User__c> tmnU = [SELECT id,Operating_Group__c from TMN_User__c WHERE Salesforce_User_Account__c= :UserInfo.getUserId() LIMIT 1];
		contracts = 'TMN_Contract__c';//default value
		if(tmnU.size() > 0){
			if(tmnU[0].Operating_Group__c == 'Care Meridian' || tmnU[0].Operating_Group__c== 'NeuroRestorative'){
				contracts = 'CareMeridian_Contract__c';
			}
			else if(tmnU[0].Operating_Group__c == 'Cambridge'){
				contracts = 'TMN_Contract__c';
			}
			else if(tmnU[0].Operating_Group__c == 'Redwood'){
				contracts = 'Redwood_Contract__c';
			}
		}
	}
    
}