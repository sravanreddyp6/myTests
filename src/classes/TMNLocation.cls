public with sharing class TMNLocation {

public String location {set;get;}
public String identityPage {set;get;}
public String state {set;get;} 
public List<TMN_User__c> locationList {set;get;}
public list<AggregateResult> userAggregateResult {set;get;}
public  TMNLocation () {
location = Apexpages.currentPage().getParameters().get('location');
identityPage = Apexpages.currentPage().getParameters().get('identityPage');
state = Apexpages.currentPage().getParameters().get('state'); 
    if(identityPage!=null) {
        userAggregateResult = [select location_name__c, office_location__c, office_location_2__c, work_city__c , work_state__c, office_location_picklist__c, zip_code__c from tmn_user__c where current_person_type__c <> 'Non-Employee' and location_name__c <> '' and location_name__c like : '%'+location +'%' group by location_name__c, office_location__c, office_location_2__c, work_city__c , work_state__c, office_location_picklist__c, zip_code__c];
    }else  {
    	String  query = 'Select Work_State__c,Office_Phone__c,Mentor_Cell_Phone__c, Operating_Group__c, Name, Manager_Name__c, Last_Name__c,'; 
               query= query+ ' Job_Title__c ,fax__c,phone_ext__c, Work_State_Code__c,Work_City__c,Zip_Code__c, Office_Location__c,Office_Location_2__c,';
                 query= query+ ' Location_Id__c From TMN_User__c where Work_City__c  like \'%'  +  location + '%\'' + PDMController.getExcludeJobTitle() ;
    					if(state!=null) {
    					 query= query+ ' and Work_State_Code__c=\''+state+'\'';
    					}
    					query= query+ ' order by Work_City__c,Work_State_Code__c';
    					locationList = database.query(query);
    }
}
	public  String searchLocation {set;get {
		Set<String> tmnList = new Set<String>();
		List<UserWrapper> locations = new List<UserWrapper>();
        for(TMN_User__c user:locationList) {
        	if(!tmnList.Contains(user.Work_City__c)){
        	 tmnList.add(user.Work_City__c);
        }
        }
        for(String user:tmnList){
        locations.add(new  UserWrapper(user));
        }
      return JSON.serialize(locations);
	}
	
	}
	
	public  String tmlLocations {set;get {
		List<LocationWrapper> locations = new List<LocationWrapper>();
        for(AggregateResult user:userAggregateResult) {
        	 locations.add( new LocationWrapper(string.valueof(user.get('location_name__c')),string.valueof(user.get('Work_City__c')),string.valueof(user.get('work_state__c')),string.valueof(user.get('Zip_Code__c')),string.valueof(user.get('Office_Location__c')),string.valueof(user.get('Office_Location_2__c'))));
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
    
    
        public class LocationWrapper
    {
     	String location;
        String city;
        String state;
        String zipcode;
        String address1;
        String address2;
       

        public LocationWrapper(String location,String city,String state,String zipcode,String address1,String address2)
        {
            this.location = location;
            this.city = city;
            this.state = state;
            this.zipcode = zipcode;
            this.address1 = address1;
            this.address2 = address2;
           
        }
    }
    
    
}