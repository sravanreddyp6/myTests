public with sharing class T_VehiclesController {
private static final Id VEHICLE_REC_TYPE_ID=Utility.getEventRecordType('Vehicle');

public Id vehicleId {get; set;}
public list<T_Event__c> vehicleList {get; set;}
public T_Event__c currentVehicle {get; set;}
public String[] currVhclLocations { get{ if (this.currentVehicle != null && String.isNotEmpty(this.currentVehicle.Default_Address__c))
             return currentVehicle.Default_Address__c.split(','); else return null;} set{
             if (value!=null && this.currentVehicle != null ) this.currentVehicle.Default_Address__c = String.join(value, ',');
             }}

public T_VehiclesController(T_TransportationSetup parent){
    String operatinggroup = [select operating_group__c from tmn_user__c where Salesforce_User_Account__c=:UserInfo.getUserId() limit 1].operating_group__c;
    this.slMap = new map<Id, Service_Location__c>([select id, Alias__c, Location_Nickname__c from Service_Location__c where Met_Data_Requirements__c = true and Alias_lookup__r.Alias_Operating_Group__c = :operatinggroup]);
    refreshVehicleList();
}
public void editVehicle(){
    this.currentVehicle = [select Id, Name, RecordTypeId, CreatedDate, CreatedById, Service_Location__c, Status__c, Default_Address__c,
	                              Vehicle_Capacity__c, Vehicle_Year_Make_Model__c, VIN__c, Equipment__c, Vehicle_owner__c, Vehicle_Owner_Other__c,
	                              CreatedBy.Name,Service_Location__r.Name, Service_Location__r.Location_NickName__c
                            From  T_Event__c
                           where  Id =: vehicleId];
}
public void newVehicle(){
    this.currentVehicle = new T_Event__c(RecordTypeId=VEHICLE_REC_TYPE_ID, Status__c = 'Active', Vehicle_Owner__c='TMN');
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
private boolean validateVehicle(T_Event__c vehicle){
    if (String.IsEmpty(vehicle.Name)) {
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vehicle Registration Number: You must enter a value.'));
       return false;
    } else if (String.IsEmpty(vehicle.Vehicle_Year_Make_Model__c)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vehicle Year/Make/Model: You must enter a value.'));
       return false;
    } else if (!String.valueOf(vehicle.Vehicle_Capacity__c).isNumeric() || vehicle.Vehicle_Capacity__c < 1){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vehicle Capacity: You must enter a valid Numeric (greater than zero) value.'));
       return false;
    } else if (!vehicle.Vehicle_owner__c.equalsIgnoreCase('TMN') && String.IsEmpty(vehicle.Vehicle_Owner_Other__c)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Vehicle Owner Describe: You must enter a value if Vehicle Owner is not "TMN".'));
       return false;
    } else if (String.IsEmpty(vehicle.VIN__c)){
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'VIN: You must enter a value.'));
       return false;
    }
    return true;
}
private void refreshVehicleList(){
	String[] slIdtemp;
    this.vehicleList = new list<T_Event__c>();
    for(T_Event__c v : [select Id, Name, RecordTypeId, CreatedDate, CreatedById, Status__c, Default_Address__c,
                               Vehicle_Capacity__c, Vehicle_Year_Make_Model__c, VIN__c, Equipment__c, Vehicle_owner__c, Vehicle_Owner_Other__c,
                               CreatedBy.Name, Service_Location__r.Name, Service_Location__r.Location_NickName__c
                          From T_Event__c 
                         where RecordTypeId =: VEHICLE_REC_TYPE_ID
                         order by Service_Location__c, Name, CreatedDate]){
        this.vehicleList.add(v);
        
        //change the servicing location names on the fly here
        if (String.IsNotEmpty(v.Default_Address__c)){
        	slIdtemp = v.Default_Address__c.split(',');
        	v.Default_Address__c = '';
        	for(String sl : slIdtemp){
        	   	if (sl instanceof Id && slMap.containsKey(Id.valueOf(sl)))
                    v.Default_Address__c += slMap.get(Id.valueOf(sl)).Location_Nickname__c + ', ';
        	}
        }
    }
}
public static list<SelectOption> getVehicleStatusOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    lst.addAll(Utility.getPicklistValues(new T_Event__c(recordTypeId=VEHICLE_REC_TYPE_ID), 'Status__c'));
    return lst;
}
public static list<SelectOption> getVehicleOwnerOpts(){
    list<SelectOption> lst = new list<SelectOption>();
    lst.addAll(Utility.getPicklistValues(new T_Event__c(recordTypeId=VEHICLE_REC_TYPE_ID), 'Vehicle_owner__c'));
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