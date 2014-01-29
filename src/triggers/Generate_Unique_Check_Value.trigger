trigger Generate_Unique_Check_Value on Action_Summary__c (before insert, before update) {
    for(Action_Summary__c summary: Trigger.new){
        summary.Unique_check__c = (string)summary.Service_Assignment__c + summary.Start_date__c + summary.End_date__c;
    }
}