global class Sch_rpt_Auth_Utilization {
     global void execute(SchedulableContext sc) {
        list<User> users = [ SELECT Id FROM User WHERE FirstName = 'Paul' AND LastName = 'Perisic' LIMIT 1];                               
        Sch_rpt_Auth_Utilization_Batch b2 = new Sch_rpt_Auth_Utilization_Batch(users);
        database.executebatch(b2);       
    }
}