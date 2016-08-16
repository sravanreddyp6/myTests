public with sharing class T_VehiclesController {
private static final Id ADH_VEHICLE_REC_TYPE_ID=Utility.getVehicleRecordType('ADH');

public Id vehicleId {get; set;}
public list<T_Vehicle__c> vehicleList {get; set;}
public T_Vehicle__c currentVehicle {get; set;}
public String[] currVhclLocations { get{ if (this.currentVehicle != null && String.isNotEmpty(this.currentVehicle.Serving_Locations__c))
             return currentVehicle.Serving_Locations__c.split(','); else return null;} set{
             if (value!=null && this.currentVehicle != null ) this.currentVehicle.Serving_Locations__c = String.join(value, ',');
             }}

public T_VehiclesController(T_TransportationSetup parent){
    String operatinggroup = [select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].operating_group__c;
    this.slMap = new map<Id, Service_Location__c>([select id, Alias__c, Location_Nickname__c from Service_Location__c where Met_Data_Requirements__c = true and Alias_lookup__r.Alias_Operating_Group__c = :operatinggroup]);
    refreshVehicleList();
}
public void editVehicle(){
    this.currentVehicle = [select Id, Name, RecordTypeId, CreatedDate, CreatedById, Serving_Locations__c, Status__c,
	                              Vehicle_Capacity__c, Vehicle_Year_Make_Model__c, VIN__c, Equipment__c,
	                              CreatedBy.Name
                            From  T_Vehicle__c
                           where  Id =: vehicleId];
}
public void newVehicle(){
    this.currentVehicle = new T_Vehicle__c(RecordTypeId=ADH_VEHICLE_REC_TYPE_ID, Status__c = 'Active');
}
public void saveVehicle(){
    if (validateVehicle(this.currentVehicle)){
        try{
          upsert this.currentVehicle;
        }catch(Exception e){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        refreshVehicleList();
    }
}
private boolean validateVehicle(T_Vehicle__c vehicle){
    if (String.IsEmpty(vehicle.Name)) {
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vehicle Registration Number: You must enter a value.'));
       return false;
    } else if (String.IsEmpty(vehicle.Vehicle_Year_Make_Model__c)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vehicle Year/Make/Model: You must enter a value.'));
       return false;
    } else if (!String.valueOf(vehicle.Vehicle_Capacity__c).isNumeric() || vehicle.Vehicle_Capacity__c < 1){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vehicle Capacity: You must enter a valid Numeric (greater than zero) value.'));
       return false;
    } else if (String.IsEmpty(vehicle.VIN__c)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'VIN: You must enter a value.'));
       return false;
    }
    return true;
}
private void refreshVehicleList(){
	String[] slIdtemp;
    this.vehicleList = new list<T_Vehicle__c>();
    for(T_Vehicle__c v : [select Id, Name, RecordTypeId, CreatedDate, CreatedById, Serving_Locations__c, Status__c,
                                  Vehicle_Capacity__c, Vehicle_Year_Make_Model__c, VIN__c, Equipment__c,
                                  CreatedBy.Name
                          From T_Vehicle__c 
                         where RecordTypeId =: ADH_VEHICLE_REC_TYPE_ID
                         order by Name, CreatedDate]){
        this.vehicleList.add(v);
        
        //change the servicing location names on the fly here
        if (String.IsNotEmpty(v.Serving_Locations__c)){
        	slIdtemp = v.Serving_Locations__c.split(',');
        	v.Serving_Locations__c = '';
        	for(String sl : slIdtemp){
        	   	if (sl instanceof Id && slMap.containsKey(Id.valueOf(sl)))
                    v.Serving_Locations__c += slMap.get(Id.valueOf(sl)).Location_Nickname__c + ', ';
        	}
        }
    }
}
public static list<SelectOption> getVehicleStatusOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    lst.addAll(Utility.getPicklistValues(new T_Vehicle__c(recordTypeId=ADH_VEHICLE_REC_TYPE_ID), 'Status__c'));
    return lst;
}
private map<Id, Service_Location__c> slMap;
public list<SelectOption> getServiceLocationsForMyOpGrp(){
    list<SelectOption> lst = new list<SelectOption>();
	for(Service_Location__c sl : this.slMap.values()){
	       lst.add(new SelectOption(String.valueOf(sl.Id), sl.Alias__c + '-' + sl.Location_Nickname__c));
    }
    return lst;
}

}