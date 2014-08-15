public with sharing class ActionSummaryCreateForm extends ActionSummaryBase {

    public ActionSummaryCreateForm (ApexPages.StandardController controller) {
        super(controller);
        //ActionSummary.Name = DefaultName(ActionSummary);
        ActionSummary.Start_Date__c = DefaultStart(ActionSummary);
        ActionSummary.End_Date__c = DefaultEnd(ActionSummary);
    }

    public PageReference formNew(){
        Action_Summary__c newobj = (Action_Summary__c)controller.getrecord();
        newObj.End_Date__c = newobj.Start_Date__c.addMonths( Duration );
        newObj.Name = DefaultName(newObj);
        return basesave();
        //return new apexpages.StandardController(newobj).view();
        //return new PageReference('/' + newobj.id);
    }

    // The record is not saved and hence not linked to any other objects
    public override Date GetServiceAssignmentStartDate() {
        Service_Assignment__c sa = [select name, start_date__c
                                      from Service_Assignment__c
                                     where id = :ActionSummary.service_assignment__c];
        return sa.Start_date__c;
    }

    private string DefaultName(Action_Summary__c actionSummary){
        Service_Assignment__c sa = [select name, Person_being_served__r.Name
                                      from Service_Assignment__c
                                     where id = :ActionSummary.service_assignment__c];
        String name = String.format('{0} - {1}'
                        , new List<String>{
                            sa.Person_being_served__r.name
                            , Datetime.newInstance(actionSummary.Start_date__c, Time.newInstance(0,0,0,0)).format('MMMYYYY')
                            });
        if (actionSummary.Start_Date__c.AddMonths(1) < actionSummary.End_Date__c){
            name = name + ' - ' + Datetime.newInstance(actionSummary.End_date__c - 1, Time.newInstance(0,0,0,0)).format('MMMYYYY');
        }
        return name;
    }

    public String getPersonId(){
        return [select Person_Being_Served__r.Id
                from Service_Assignment__c
                where Id = :ActionSummary.service_assignment__c].Person_Being_Served__r.Id;
    }

    private Date DefaultStart(Action_Summary__c actionSummary){
        return Date.Today().toStartofMonth();
    }

    private Date DefaultEnd(Action_Summary__c actionSummary){
        return actionSummary.Start_Date__c.addMonths(1);
    }
}