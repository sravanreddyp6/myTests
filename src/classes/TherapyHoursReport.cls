public with sharing class TherapyHoursReport {

    public date StartDate {get; set;}
    public date EndDate {get; set;}
    public List<id> selectedPBS {get; set;}
    public List<SelectOption> PBSList = new List<SelectOption>();
    public List<SelectOption> getPBSList(){ return PBSList ;}    
    public boolean hasRunOnce {get; set;}

    public list<SelectOption> programslist = new list<SelectOption>();
    public list<SelectOption> getProgramslist(){ return programslist; }
    public List<Id> selectedPrograms {get; set;}
    
    public list<SelectOption> select2list = new list<SelectOption>();
    public list<SelectOption> getSelect2list(){ return select2list; }   
    public List<id> select2PrmIds {get; set;}

    public list<Service_Assignment__c> therapyHrs {get; set;}

    public TherapyHoursReport(){
        List<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
                                           FROM service_assignment__c
                                          GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c 
                                          ORDER BY service_location__r.program__c];
        for (AggregateResult slPrgm : slPrgms) {
            programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
        }
        selectedPBS = new List<id>();
        hasRunOnce =false;
        therapyHrs = new list<Service_Assignment__c>();
    }
    
    public pagereference AddPrograms(){
        for (Id p :selectedPrograms){
            for(Integer i=0; i < programslist.size(); i++){
                if (programslist.get(i).getValue() == p) {
                    select2list.add(new SelectOption(programslist.get(i).getValue(), programslist.get(i).getLabel()));
                    programslist.remove(i);
                    break;
                }
            }
        }
        UpdateProgramSelections();
        return null;
    }

    public pagereference RemovePrograms(){
        for (Id p :select2PrmIds){
            for(Integer i=0; i < select2list.size(); i++){
                if (select2list.get(i).getValue() == p) {
                    programslist.add(new SelectOption(select2list.get(i).getValue(), select2list.get(i).getLabel()));
                    select2list.remove(i);
                    break;
                }
            }
        }
        UpdateProgramSelections();
        return null;
    }

    public void UpdateProgramSelections(){
        List<id> selectedPrmIds = new List<id>();
        for (selectOption so : select2list){
            selectedPrmIds.add(so.getValue());
        }
        PBSList.clear();
        for (Service_Assignment__c sa : [SELECT Id, Person_Being_Served__r.id, Person_Being_Served__r.Account.Lastname, Person_Being_Served__r.Account.Firstname,
                                                 (SELECT Id FROM Therapy_Hours__r WHERE StartTime_DatePart__c >= : StartDate AND StartTime_DatePart__c <= : EndDate order by Start_time__c asc)
                                            FROM  Service_Assignment__c WHERE service_location__r.id IN :selectedPrmIds
                                       ORDER  BY Person_Being_Served__r.Account.Lastname, Person_Being_Served__r.Account.Firstname, SA_Start_DateTime__c desc NULLS LAST] ) {
            if (sa.Therapy_Hours__r.size() > 0) 
               PBSList.add(new SelectOption(sa.Id, sa.Person_Being_Served__r.Account.Firstname + ' ' + sa.Person_Being_Served__r.Account.Lastname));
        }       
    }
        
    public PageReference cancelToNewRun() {
        PageReference pageRef = new PageReference('/apex/TherapyHoursReport');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void runReport() {
        List<id> selectedPrmIds = new List<id>();
        for (selectOption so : select2list){
            selectedPrmIds.add(so.getValue());
        }
        therapyHrs = [SELECT Id, Person_Being_Served__r.id, Person_Being_Served__r.Account.Lastname, Person_Being_Served__r.Account.Firstname,
                                                 (SELECT Id, Name, Appointment_Type__c, Therapist_Discipline__c, Approver_Note__c, End_Time__c, Narrative_Note__c, Start_Time__c, Status__c, Status_Time__c,
                                                            pbsLastName__c, pbsFirstName__c, Number_of_Hours__c, Owner.name, Approver_Name__c
                                                    FROM Therapy_Hours__r WHERE StartTime_DatePart__c >= : StartDate AND StartTime_DatePart__c <= : EndDate order by Start_time__c asc)
                                            FROM  Service_Assignment__c WHERE service_location__r.id IN : selectedPrmIds
                                       ORDER  BY Person_Being_Served__r.Account.Lastname, Person_Being_Served__r.Account.Firstname, SA_Start_DateTime__c desc NULLS LAST];
    }
}