global class EndofServiceProvisioningBatch implements Database.Batchable<sObject>, Schedulable{
    private final static date todaydate = system.today();
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'SELECT Service_Assignment__c, Service_Assignment__r.Name,Service_Assignment__r.Status__c,Service_Assignment__r.Person_Being_Served__r.ownerid,Service_Assignment__r.Person_Being_Served__r.Name,Service_Assignment__r.Person_Being_Served__c,status__c,Service_Assignment__r.service_location__r.service_type__c,TMN_Provider__c,TMN_Provider__r.Name,TMN_Provider__r.Status__c,End_Date__c, Start_Date__c from Service_Assignment_Provider_JO__c WHERE Service_Assignment__r.service_location__r.service_type__c =\'CM - Case Management\' AND Service_Assignment__r.Status__c = \'Active\' AND Disregard__c = False AND TMN_Provider__r.Status__c = \'Approved\' AND ((End_Date__c =: todaydate AND Status__c = \'Active\') OR ( Start_Date__c =: todaydate AND Status__c = \'Pending\'))';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Assignment_Provider_JO__c> scope){
        System.debug('List --->' + scope);
        id tpaId = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' and name = 'Tmn Provider Application'][0].id;
        list<id> providerIds = New List<Id>();
        Map<Id, Id[]> saToUsersNotified = new Map<Id, Id[]>();
        List<id> ServiceAssignmentIds = New list<id>(); 
        list<task> listNotificationTask = New List<Task>();
        Map<id,string> SrvcAssgnIdtoPersonalAgentName = New Map<Id,string>();
        for(Service_Assignment_Provider_JO__c srvcProvJO:scope){
            providerIds.add(srvcProvJO.TMN_Provider__c);
            ServiceAssignmentIds.add(srvcProvJO.Service_Assignment__c);
            saToUsersNotified.put(srvcProvJO.Service_Assignment__c, new Id[]{});
        }
        list<Service_Assignment_Provider_JO__c> juncObjeRecordsToUpdate = new List<Service_Assignment_Provider_JO__c>();
        list<Service_Assignment_Personal_Agent__c> pagentList = [SELECT Id,Service_Assignment__c,Personal_Agent__r.Salesforce_User_Account__c,Personal_Agent__r.Last_name__c,Status__c FROM Service_Assignment_Personal_Agent__c WHERE Service_Assignment__c IN: ServiceAssignmentIds AND Status__c =: 'Active' ];
        for (Service_Assignment_Personal_Agent__c paAssociation: pagentList) {
            saToUsersNotified.get(paAssociation.Service_Assignment__c).add(paAssociation.Personal_Agent__r.Salesforce_User_Account__c);
        }
        
        Map<String,id> srvcAssignmentToActiveTaskIdMap = New Map<String,Id>();
        list<task> serviceProvisioningTasklist = [select id,whatid,Description from task where whatid In:ServiceAssignmentIds And Subject = 'End of Service Provisioning Notification' And status != 'Completed' ];
        if(serviceProvisioningTasklist.size()>0){
            for(task t:serviceProvisioningTasklist ){
                srvcAssignmentToActiveTaskIdMap.put(t.whatid + t.Description,t.id);
            }
        }
        for(Service_Assignment_Provider_JO__c srvcProvJO:scope){
            if(srvcProvJO.status__c == 'Pending' ){
                srvcProvJO.Status__c = 'Active';
                juncObjeRecordsToUpdate.add(srvcProvJO);
            }
            else if(srvcProvJO.status__c == 'Active' && srvcProvJO.TMN_Provider__r.status__c == 'Approved'){
                srvcProvJO.Status__c = 'Expired'; 
                if(srvcAssignmentToActiveTaskIdMap != Null && srvcAssignmentToActiveTaskIdMap.containsKey(srvcProvJO.Service_Assignment__c + 'Document: Service Assignment between provider ' + srvcProvJO.TMN_Provider__r.Name + ' and Person Being Served ' + srvcProvJO.Service_Assignment__r.Person_Being_Served__r.Name + 'for Service Assignment: ' + srvcProvJO.Service_Assignment__r.Name + ' has reached its end date. Please perform the applicable service provisoning renewal activities for this Person Being Served.')){
                }else{
                    // If no Active Personal Agents was found, notify the PBS Owner
                    for (Id saId: saToUsersNotified.keySet()) {
                        if (saToUsersNotified.get(saId).size() == 0) {
                            saToUsersNotified.get(saId).add(srvcProvJO.Service_Assignment__r.Person_Being_Served__r.ownerid);
                        }
                    }
                    Id saId = srvcProvJO.Service_Assignment__c;
                    for (Id userId: saToUsersNotified.get(saId)) {
                        
                            Task NotificationTask = New Task();
                            NotificationTask.Subject = 'End of Service Provisioning Notification';
                            NotificationTask.Description = 'Service Assignment between provider ' + srvcProvJO.TMN_Provider__r.Name + ' and Person Being Served ' + srvcProvJO.Service_Assignment__r.Person_Being_Served__r.Name + 'for Service Assignment: ' + srvcProvJO.Service_Assignment__r.Name + ' has reached its end date. Please perform the applicable service provisoning renewal activities for this Person Being Served.' ;
                            NotificationTask.Priority = 'Normal';
                            notificationTask.recordtypeid = tpaId; 
                            NotificationTask.Status = 'In Progress'; 
                            NotificationTask.WhoId = srvcProvJO.Service_Assignment__r.Person_Being_Served__c;    
                            NotificationTask.whatid = srvcProvJO.Service_Assignment__c;
                            if(userId != Null)
                                NotificationTask.ownerId = userId;
                            else
                                NotificationTask.ownerId = srvcProvJO.Service_Assignment__r.Person_Being_Served__r.ownerid; 
                            listNotificationTask.add(NotificationTask);
                    }
                }
                juncObjeRecordsToUpdate.add(srvcProvJO);
            }
        }
        if(listNotificationTask.size()>0){
            Database.insert(listNotificationTask,false);
        }
        if(juncObjeRecordsToUpdate.size()>0){
            update juncObjeRecordsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC){
    }
    
    //Scheduling the batch
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EndofServiceProvisioningBatch(), 30);
    }




}