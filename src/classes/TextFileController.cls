public with sharing class TextFileController {
 
    public List<String> customObjs { get; set; }
    public List<String> standardObjs { get; set; }
    
    public TextFileController() {
	
    }
    
    public void fetch() {
		Map<String, Schema.SObjectType> objects = Schema.getGlobalDescribe();
		customObjs = new List<String>();
		standardObjs = new List<String>();
		
		Schema.DescribeSObjectResult objInfo = null;
		for (Schema.SObjectType obj : objects.values()) {
			objInfo = obj.getDescribe();
			if(objInfo.getName().contains('__c')) {
				customObjs.add(objInfo.getName());
			}
			else {
				standardObjs.add(objInfo.getName());
			}
		}
		
		//System.debug(objInfo.getName() + ' [' + objInfo.getLabel() + ']');
	
		customObjs.sort();
		standardObjs.sort();
    
    }    

}