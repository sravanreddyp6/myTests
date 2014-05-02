public with sharing class Assessment_FAD_NotificationsRunBatch implements schedulable {
    public void execute(SchedulableContext sc){
    
        String query = 'SELECT Id, Phase_1_Start_Date__c, Person_Being_Served__r.OwnerId FROM Service_Assignment__c Where Program__c =\'IFCS\' AND Service_Line__c like \'%FCT%\' AND Status__c = \'Active\'﻿';
        ID batchprocessid = Database.executeBatch(new Assessment_FAD_Notifications(query), 200);
    }
}