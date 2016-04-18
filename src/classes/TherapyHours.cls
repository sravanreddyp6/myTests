global with sharing class TherapyHours {
    public String getProgramslist(){
        String programslist = '<option value="' + + '">'+ '--Select--' +'</option>';
        // get the comma separated service location Id, alias + nick Name for the dropdown
        List<AggregateResult> slPrgms = [SELECT service_location__r.id slID, service_location__r.Alias__c alias, service_location__r.Location_Nickname__c  nickName
                                         FROM service_assignment__c
                                         where Status__c = 'Active'
                                         GROUP BY service_location__r.id, service_location__r.Alias__c, service_location__r.Location_Nickname__c 
                                         ORDER BY service_location__r.Location_Nickname__c nulls last];
        
        Map<String, String> optionsTemp = new map<String, String>();
        String temp;
        for(AggregateResult slPrgm : slPrgms){
            temp = optionsTemp.put(String.valueOf(slPrgm.get('alias')) + '-' + (slPrgm.get('nickName') == null ? '' : String.valueOf(slPrgm.get('nickName')).substringBeforeLast(' -')), String.valueOf(slPrgm.get('slID')));
            if (!String.isBlank(temp)) {
                optionsTemp.put(String.valueOf(slPrgm.get('alias')) + '-' + (slPrgm.get('nickName') == null ? '' : String.valueOf(slPrgm.get('nickName')).substringBeforeLast(' -')), temp + ',' + String.valueOf(slPrgm.get('slID')));
            }
        }
        for (String key : optionsTemp.keySet()) {
            programslist += '<option value="' + optionsTemp.get(key) + '">'+ key +'</option>';
        }
        return programslist; 
    }
    public TherapyHours(){ }
    @RemoteAction
    global static void saveFields(String dataObj) {
        map<String, String> values = (Map<String, String>) JSON.deserialize(dataObj, map<String, String>.class);
        system.debug(values);
        String userId = UserInfo.getUserId();
        Therapy_Hour__c therapyHr = new Therapy_Hour__c();
        
        List<TMN_User__c> therapist = [SELECT Discipline__c from TMN_User__c where TMN_Identity_Id__c = :userId];
        String therDiscipline = (String) therapist.get(0).get('Discipline__c');
        system.debug('therapist discipline=' + therDiscipline);
        therapyHr.Therapist_Discipline__c = therDiscipline;
        
        therapyHr.Service_Assignment__c = values.get('pbsList');
        therapyHr.Appointment_Type__c = values.get('entryType');
        if (values.get('startDateTime').length() == 16) values.put('startDateTime', (string) values.get('startDateTime') + ':00'); 
        if (values.get('endDateTime').length() == 16) values.put('endDateTime', (string) values.get('endDateTime') + ':00');
        therapyHr.Start_Time__c = DateTime.valueOf(values.get('startDateTime').replace('T',' ').substringBeforeLast(':') + ':00');
        therapyHr.End_Time__c = DateTime.valueOf(values.get('endDateTime').replace('T',' ').substringBeforeLast(':') + ':00');
        therapyHr.Narrative_Note__c = values.get('narrativeNotes');
        therapyHr.Status_Time__c = Datetime.now();
        system.debug('Total Number of minutes being submitted: ' + (therapyHr.End_Time__c.getTIme() - therapyHr.Start_Time__c.getTime())/60000 );
        insert therapyHr;
    }
}