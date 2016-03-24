with sharing global class TmnAccess {
	class SelOption {
	     String id;
	     String text;
	     SelOption(String id, String text){
	     	this.id = id;
	     	this.text = text;
	     }
	}
	
	@ReadOnly webService static String getTmnUsers(){
		TMN_User__c tmnUser = [SELECT id, name, Accountable_Approval_Manager__c,work_state__c, Work_State_Code__c from TMN_User__c where Salesforce_User_Account__c =: UserInfo.getUserId() limit 1];
		list<SelOption> retVal = new list<SelOption>();
		for (TMN_User__c t : [select Id, Name from TMN_User__c where Work_State_Code__c =: tmnUser.Work_State_Code__c]){
			retVal.add(new SelOption(t.Id, t.name));
		} 
        return JSON.serialize(retVal);
    }
}