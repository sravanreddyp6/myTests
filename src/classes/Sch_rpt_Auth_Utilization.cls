global class Sch_rpt_Auth_Utilization implements Schedulable{
     global void execute(SchedulableContext sc) {
        set<string> uids = new set<string>();
        List<Authorization_Report_Email_Users__c> settings = Authorization_Report_Email_Users__c.getall().values();
        for(Authorization_Report_Email_Users__c item: settings){
            uids.add(item.UserID__c);
        }
        list<User> users = [ SELECT Id FROM User WHERE id in :uids];                               
        Sch_rpt_Auth_Utilization_Batch b2 = new Sch_rpt_Auth_Utilization_Batch(users);
        database.executebatch(b2);       
    }
}