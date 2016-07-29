public with sharing class T_RoutesController {
private static final Id ROUTE_REC_TYPE_ID=Utility.getEventRecordType('Route');
public Id routeId {get; set;}
public list<T_Route> routeList {get; set;}
public T_Route currentRoute {get; set;}
private T_TransportationSetup cntrlr;
public T_RoutesController(T_TransportationSetup parent){
	this.cntrlr = parent;
    refreshRouteList();
}

public void editRoute(){
    T_Event__c r = [select name,Id,RecordTypeId,CreatedDate,CreatedById,CreatedBy.Name,Service_Location__r.Name,
                               Service_Location__c,Service_Location__r.Location_NickName__c,Type__c,Default_Start_Time__c,
                               Default_End_Time__c,Default_Address__c,Status__c, default_vehicle__r.name, default_vehicle__c
                          From T_Event__c where Id =: routeId];
	this.currentRoute = new T_Route(r);
}

public void newRoute(){
    this.currentRoute = new T_Route();
}

public void saveRoute(){
	T_Event__c r = getRouteSobject(this.currentRoute);
    if (validateRoute(this.currentRoute)){
    	try{
		  upsert r;
    	}catch(Exception e){
    		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    	}
	    refreshRouteList();
    }
}
private boolean validateRoute(T_Route route){
	if (String.IsEmpty(route.routeName)) {
	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Route Name: You must enter a value.'));
	   return false;
	} else if (String.IsEmpty(route.routeType)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Route Type: You must enter a value.'));
       return false;
    } else if (String.IsEmpty(route.serviceLocId)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Location Of Service: You must select a value.'));
       return false;
    } else if (String.IsEmpty(route.address)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Address: You must enter a value..'));
       return false;
    } else if (String.IsEmpty(route.startTime)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Default Start Time: You must enter a value.'));
       return false;
    } else if (String.IsEmpty(route.endTime)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Default End Time: You must enter a value.'));
       return false;
    }
    return true;
}

private void refreshRouteList(){
	this.routeList = new list<T_Route>();
	for(T_Event__c r : [select name,Id,RecordTypeId,CreatedDate,CreatedById,CreatedBy.Name,Service_Location__r.Name,
						       Service_Location__c,Service_Location__r.Location_NickName__c,Type__c,Default_Start_Time__c,
						       Default_End_Time__c,Default_Address__c,Status__c, default_vehicle__r.name, default_vehicle__c 
						  From T_Event__c 
						 where RecordTypeId =: ROUTE_REC_TYPE_ID
						 order by Service_Location__c, Name, CreatedDate]){
		this.routeList.add(new T_Route(r));
	}
}
public static list<SelectOption> getRouteTypeOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    lst.add(new SelectOption('',''));
    lst.addAll(Utility.getPicklistValues(new T_Event__c(recordTypeId=ROUTE_REC_TYPE_ID), 'Type__c'));
    return lst;
}
public static list<SelectOption> getRouteStatusOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    lst.addAll(Utility.getPicklistValues(new T_Event__c(recordTypeId=ROUTE_REC_TYPE_ID), 'Status__c'));
    return lst;
}
public list<SelectOption> getDefaultVehicleOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    T_VehiclesController vehicles = new T_VehiclesController(this.cntrlr);
    lst.add(new selectOption('', '--Select Vehicle--'));
    for (T_Event__c v : vehicles.vehicleList){
        lst.add(new selectOption(v.Id, v.Name));    	
    }
    return lst;
}

public static T_Event__c getRouteSobject(T_Route r){
	return ((r.routeId instanceof Id) ? 
	         new T_Event__c(id=r.routeId, Name=r.routeName, Type__c=r.routeType, Service_Location__c=r.serviceLocId,
	                        recordTypeId=ROUTE_REC_TYPE_ID, Default_Address__c=r.address, Default_Start_Time__c=r.startTime, Default_End_Time__c=r.endTime, status__c=r.status, default_vehicle__c=r.vehicleId) :
             new T_Event__c(Name=r.routeName, Type__c=r.routeType, Service_Location__c=r.serviceLocId,
                            recordTypeId=ROUTE_REC_TYPE_ID, Default_Address__c=r.address, Default_Start_Time__c=r.startTime, Default_End_Time__c=r.endTime, status__c=r.status, default_vehicle__c=r.vehicleId)
            );
}
private Datetime createDatetimeToken(String timeStr){
	if (String.IsEmpty(timeStr)) return null;
	else {
		String[] timeParts = timeStr.substringBefore(' ').split(':');
        if (timeStr.substringAfter(' ').equalsIgnoreCase('PM')) {
        	return DateTime.newInstance(Date.newInstance(1,1,2000),Time.newInstance(Integer.valueOf(timeParts[0])+12, Integer.valueOf(timeParts[1]),0,0));
        } else {
        	return DateTime.newInstance(Date.newInstance(1,1,2000),Time.newInstance(Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]),0,0));
        }
	}
}
public class T_Route {
	public String routeId {get;set;}
    public String routeName {get;set;}
    public String routeType {get;set;}
    public Id serviceLocId {get; set;}
    public String serviceLocNickName {get; set;}
    public String serviceLocName {get; set;}
    public String address {get; set;}
    public Id vehicleId {get; set;}
    public String vehicleName {get; set;}
    public String startTime {get; set;}
    public String endTime {get; set;}
    public String status {get;set;}
    public String createdBy {get;set;}
    public Id createdById {get;set;}
    public datetime createdDate {get; set;}
    public T_Route(){this.routeId=Null;}
    public T_Route(T_Event__c r){
    	this.routeId = r.id;
        this.routeName = r.Name;
        this.routeType = r.Type__c;
        this.serviceLocId = r.Service_Location__c;
        this.address = r.Default_Address__c;
        this.startTime = r.Default_Start_Time__c;
        this.endTime = r.Default_End_Time__c;
        this.serviceLocNickName = (r.Service_Location__c != null ? r.Service_Location__r.Location_Nickname__c : '');
        this.serviceLocName = (r.Service_Location__c != null ? r.Service_Location__r.Name : '');
        this.status = r.Status__c;
        this.createdBy = (r.createdBy == null ? UserInfo.getName() : r.createdBy.Name );
        this.createdById = (r.createdBy == null ? UserInfo.getUserId() : r.createdBy.Id );
        this.createdDate = (r.createdDate == null ? system.now() : r.createdDate );
        this.vehicleId = r.default_Vehicle__c;
        this.vehicleName = (r.default_Vehicle__c == null ? '' : r.default_Vehicle__r.Name );
    }
}
}