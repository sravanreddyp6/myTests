public with sharing class TMNLocation {

public String location {set;get;}
public List<TMN_User__c> locationList {set;get;}
public  TMNLocation () {
location = Apexpages.currentPage().getParameters().get('location');
locationList = [Select Work_State__c,Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, Last_Name__c, Job_Title__c ,fax__c,phone_ext__c From TMN_User__c where Work_State__c  like  : '%' + location +  '%' order by Office_Phone__c];

}
	public  String searchLocation {set;get {
		Set<String> tmnList = new Set<String>();
		List<UserWrapper> locations = new List<UserWrapper>();
        for(TMN_User__c user:locationList) {
        	if(!tmnList.Contains(user.Work_State__c)){
        	 tmnList.add(user.Work_State__c);
        }
        }
        for(String user:tmnList){
        locations.add(new  UserWrapper(user));
        }
      return JSON.serialize(locations);
	}
	
	}
	
	
	   public class UserWrapper
    {
        String location;

        public UserWrapper(String location)
        {
            this.location = location;
        }
    }
    
    
}