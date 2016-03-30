public with sharing class MyPreferences {
	public transient boolean isMilitaryTime;
	public integer timePrefSel {get;set;}
	public boolean getIsMilitaryTime() {
		return UserDefaults__c.getInstance(userinfo.getuserId()).Id == null;
	}	
	public MyPreferences(){
		this.timePrefSel = 12;
	}
	public PageReference SavePreferences(){
		system.debug('User selected: ' + String.valueOf(timePrefSel));
		UserDefaults__c myDefaults = UserDefaults__c.getInstance(userinfo.getuserId());
		if (timePrefSel == 12)
			myDefaults.MilitaryTime__c = false;
		else 
			myDefaults.MilitaryTime__c = true;
		upsert myDefaults;
		return null;
	}
	public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('12','Antemeridian Time (AM/PM 12hr clock)'));
        options.add(new SelectOption('24','Military Time (24hr clock)'));        
        return options;
    }

}