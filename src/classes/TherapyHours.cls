global with sharing class TherapyHours {
    public String getProgramslist(){
        String programslist = '<option value="' + + '">'+ '--Select--' +'</option>';
        List<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.program__c prgm
                                           FROM service_assignment__c
                                          where Status__c = 'Active'
                                          GROUP BY service_location__r.id, service_location__r.program__c, service_location__r.Alias__c 
                                          ORDER BY service_location__r.program__c];
        for (AggregateResult slPrgm : slPrgms) {
            programslist += '<option value="' + slPrgm.get('slID') + '">'+ String.valueOf(slPrgm.get('alias')) + '-' + String.valueOf(slPrgm.get('prgm')) +'</option>';
        }
        return programslist; 
    }
    public TherapyHours(){ }
    
    @RemoteAction
    global static void saveFields(String dataObj) {
            map<String, String> values = (Map<String, String>) JSON.deserialize(dataObj, map<String, String>.class);
            system.debug(values);    
            Therapy_Hour__c therapyHr = new Therapy_Hour__c();
            therapyHr.Service_Assignment__c = values.get('pbsList');
            therapyHr.Appointment_Type__c = values.get('entryType');
            therapyHr.Start_Time__c = DateTime.valueOf(values.get('startDateTime').replace('T',' ').substringBeforeLast(':') + ':00');
            therapyHr.End_Time__c = DateTime.valueOf(values.get('endDateTime').replace('T',' ').substringBeforeLast(':') + ':00');
            therapyHr.Narrative_Note__c = values.get('narrativeNotes');
            therapyHr.Status_Time__c = Datetime.now();
            
            system.debug('Total Number of minutes being submitted: ' + (therapyHr.End_Time__c.getTIme() - therapyHr.Start_Time__c.getTime())/60000 );
            
            insert therapyHr;
    }
}