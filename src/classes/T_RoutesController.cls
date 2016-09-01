public with sharing class T_RoutesController {
private static final Id ADH_ROUTE_REC_TYPE_ID=Utility.getRouteRecordType('ADH');
public Id routeId {get; set;}
public list<T_Route> routeList {get; set;}
public T_Route currentRoute {get; set;}
private T_TransportationSetup cntrlr;
public T_RoutesController(T_TransportationSetup parent){
	this.cntrlr = parent;
    refreshRouteList();
}

public void editRoute(){
    T_Route__c r = [select name,Id,RecordTypeId,CreatedDate,CreatedById,CreatedBy.Name,Service_Location__r.Name,
                               Service_Location__c,Service_Location__r.Location_NickName__c,Type__c,Default_Start_Time__c,
                               Default_End_Time__c,Default_Address__c,Status__c, default_vehicle__r.name, default_vehicle__c,Default_Driver__c, Default_Driver__r.Name
                          From T_Route__c where Id =: routeId];
	this.currentRoute = new T_Route(r);
}

public void newRoute(){
    this.currentRoute = new T_Route();
}

public void saveRoute(){
	T_Route__c r = getRouteSobject(this.currentRoute);
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
	for(T_Route__c r : [select name,Id,RecordTypeId,CreatedDate,CreatedById,CreatedBy.Name,Service_Location__r.Name,
						       Service_Location__c,Service_Location__r.Location_NickName__c,Type__c,Default_Start_Time__c,
						       Default_End_Time__c,Default_Address__c,Status__c, default_vehicle__r.name, default_vehicle__c,Default_Driver__c, Default_Driver__r.Name 
						  From T_Route__c 
						 where RecordTypeId =: ADH_ROUTE_REC_TYPE_ID
						 order by Service_Location__c, Name, CreatedDate]){
		this.routeList.add(new T_Route(r));
	}
}
public static list<SelectOption> getRouteTypeOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    lst.add(new SelectOption('',''));
    lst.addAll(Utility.getPicklistValues(new T_Route__c(recordTypeId=ADH_ROUTE_REC_TYPE_ID), 'Type__c'));
    return lst;
}
public static list<SelectOption> getRouteStatusOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    lst.addAll(Utility.getPicklistValues(new T_Route__c(recordTypeId=ADH_ROUTE_REC_TYPE_ID), 'Status__c'));
    return lst;
}
public list<SelectOption> getDefaultVehicleOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    T_VehiclesController vehicles = new T_VehiclesController(this.cntrlr);
    lst.add(new selectOption('', '--Select Vehicle--'));
    for (T_Vehicle__c v : vehicles.vehicleList) {
        lst.add(new selectOption(v.Id, v.Name));    	
    }
    return lst;
}
public list<SelectOption> getDefaultDriverOpts(){
	String myAlias = [select operating_group__c, alias_lookup__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].alias_lookup__c;
    list<Id> driverPermUsers = new list<Id>(); 
	//Filter the TMN Users to only the drivers
    for(permissionsetAssignment psA : [SELECT Id, PermissionSetId, AssigneeId, Assignee.Name, SystemModstamp from permissionsetAssignment where PermissionSetId in (SELECT Id from permissionset where name = 'T_Transportation_Driver')]){
    	driverPermUsers.add(psA.AssigneeId);
    }
    list<SelectOption> lst = new list<SelectOption>();
    lst.add(new selectOption('', '--Select Vehicle--'));        
    for(TMN_User__c tmn : [SELECT Id, Name from TMN_User__c where Salesforce_User_Account__c in : driverPermUsers and alias_lookup__c =: myAlias]){
        lst.add(new selectOption(tmn.Id, tmn.Name));
    }
    return lst;
}

public static T_Route__c getRouteSobject(T_Route r){
	return ((r.routeId instanceof Id) ? 
	         new T_Route__c(id=r.routeId, Name=r.routeName, Type__c=r.routeType, Service_Location__c=r.serviceLocId,
	                        recordTypeId=ADH_ROUTE_REC_TYPE_ID, Default_Address__c=r.address, Default_Start_Time__c=r.startTime, Default_End_Time__c=r.endTime, status__c=r.status, default_vehicle__c=r.vehicleId, Default_Driver__c=r.driverId) :
             new T_Route__c(Name=r.routeName, Type__c=r.routeType, Service_Location__c=r.serviceLocId,
                            recordTypeId=ADH_ROUTE_REC_TYPE_ID, Default_Address__c=r.address, Default_Start_Time__c=r.startTime, Default_End_Time__c=r.endTime, status__c=r.status, default_vehicle__c=r.vehicleId, Default_Driver__c=r.driverId)
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
    public Id driverId {get; set;}
    public String driverName {get; set;}
    public String startTime {get; set;}
    public String endTime {get; set;}
    public String status {get;set;}
    public String createdBy {get;set;}
    public Id createdById {get;set;}
    public datetime createdDate {get; set;}
    public T_Route(){this.routeId=Null;}
    public T_Route(T_Route__c r){
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
        this.driverId = r.Default_Driver__c;
        this.driverName = (r.Default_Driver__c == null ? '' : r.Default_Driver__r.Name );        
    }
}
}