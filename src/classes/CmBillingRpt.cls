public with sharing class CmBillingRpt {
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

    public CmBillingRpt(){
        List<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
                                           FROM service_assignment__c
                                          GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c 
                                         HAVING COUNT(service_location__r.id) > 0
                                          ORDER BY service_location__r.program__c];
        for (AggregateResult slPrgm : slPrgms) {
            programslist.add(new SelectOption((Id)slPrgm.get('slID'), String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) ));
        }
        selectedPBS = new List<id>();
        hasRunOnce =false;
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
        for (Service_Assignment__c sa : [SELECT Person_Being_Served__r.id, Person_Being_Served__r.Account.Lastname, Person_Being_Served__r.Account.Firstname,
                                                                            (SELECT ID FROM Evaluations__r
                                                                              WHERE ((RecordType.Name = 'CMShiftAssessment' AND Head_to_toe_Status__c = 'Final') OR (RecordType.DeveloperName = 'CNA_Workbook' AND Status__c = 'Final') ) 
                                                                                AND Shift_Start_time__c >= : StartDate AND Shift_End_time__c <= : EndDate.addDays(1) ),
                                                                            (SELECT ID  FROM Action_Summaries__r 
                                                                              WHERE Status__c = 'Final' 
                                                                                AND Start_Date__c >= : StartDate  AND End_Date__c <= : EndDate )
                                                                        FROM  Service_Assignment__c WHERE service_location__r.id IN :selectedPrmIds
                                                                       ORDER  BY Person_Being_Served__r.Account.Lastname, Person_Being_Served__r.Account.Firstname, SA_Start_DateTime__c desc NULLS LAST] ) {
            if (sa.Evaluations__r.size() > 0 || sa.Action_Summaries__r.size() > 0) 
        	   PBSList.add(new SelectOption(sa.Person_Being_Served__r.id, 
        	                                sa.Person_Being_Served__r.Account.Lastname + ' ' + sa.Person_Being_Served__r.Account.Firstname));
        }       
    }
        
    public PageReference cancelToNewRun() {
        PageReference pageRef = new PageReference('/apex/CmBillingRpt');
        pageRef.setRedirect(true);
        return pageRef;
    }

}