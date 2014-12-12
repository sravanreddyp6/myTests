public class ReferralTrigger_Helper{
    static Map<String,State_Settings__c> stateCS = State_Settings__c.getAll();
    //static Integer cmCount = [select count() from Referral__c where recordtype.name ='caremeridian'];
    //static Integer neuroCount = [select count() from Referral__c where recordtype.name ='neurorestorative'];

    public static void updateName(List<referral__c> args) {
        Utility.InsertStateCustomSettings();
        stateCS = State_Settings__c.getAll();

        for(referral__c ref:args){
            if(ref.name == null || ref.name == 'null' || ref.name == ''){
                if(ref.recordTypeId == null){
                    if(stateCS.keySet().contains(ref.state_for_preferred_service__c)){
                        ref.name = stateCS.get(ref.state_for_preferred_service__c).acronym__c;
                    }
                }else{
                    if(ref.recordTypeId == Utility.getRecordTypeForReferral('CareMeridian')){
                        ref.name = 'CM';
                    }else if(ref.recordTypeId == Utility.getRecordTypeForReferral('NeuroRestorative')){
                        ref.name = 'NR';
                    }else{
                        if(stateCS.keySet().contains(ref.state_for_preferred_service__c)){
                            ref.name = stateCS.get(ref.state_for_preferred_service__c).acronym__c;
                        }
                    }
                }
            }
            if(ref.name != 'CM' && ref.name != 'NR' && ref.name != null && ref.name != 'null' && ref.name != ''){
                if(stateCS.keySet().contains(ref.state_for_preferred_service__c)){
                    stateCS.get(ref.state_for_preferred_service__c).auto_number__c += 1;
                }
                ref.name+='-'+ (String.valueOf((Integer) stateCS.get(ref.state_for_preferred_service__c).auto_number__c).leftPad(10).replace(' ','0'));//(String.valueOf(tmp.get(tmp.size()-1)+1).leftPad(10).replace(' ','0'));//(String.valueOf(count).leftPad(10).replace(' ','0'));
            }else if(ref.name == 'CM'){
                if(stateCS.keySet().contains('CareMeridian')){
                    stateCS.get('CareMeridian').auto_number__c += 1;
                }
                ref.name+='-'+(String.valueOf((Integer) stateCS.get('CareMeridian').auto_number__c).leftPad(10).replace(' ','0'));
            }else if(ref.name == 'NR'){
                if(stateCS.keySet().contains('NeuroRestorative')){
                    stateCS.get('NeuroRestorative').auto_number__c += 1;
                }
                ref.name+='-'+(String.valueOf((Integer) stateCS.get('NeuroRestorative').auto_number__c).leftPad(10).replace(' ','0'));
            }/*else if(ref.name == 'CM'){
                cmCount++;
                ref.name+='-'+(String.valueOf(cmCount).leftPad(10).replace(' ','0'));
            }else if(ref.name == 'NR'){
                NeuroCount++;
                ref.name+='-'+(String.valueOf(NeuroCount).leftPad(10).replace(' ','0'));
            }*/
        }
        try{
            update stateCS.values();
        }catch(dmlexception e){

        }
    }

    /**
     * Mark red flags for a referral if certain conditions are met.
     */
    public static void markHighRisk(Boolean isInsert, List<Referral__c> newRefs, Map<ID, Referral__c> newRefsMap, Map<ID, Referral__c> oldRefsMap) {
        // I use fieldsets to implement this method (Red_Flag_* fieldsets)
        Map<String, Schema.FieldSet> fieldsets = SObjectType.Referral__c.FieldSets.getMap();
        Set<String> allFieldSets = Schema.SObjectType.Referral__c.fieldSets.getMap().keySet();
        String[] statesWithRedFlag = new String[] {};
        for (String member: allFieldSets) {
            System.debug('Fieldset Member: ' + member);
            if (member.startsWithIgnoreCase('Red_Flag_')) {
                statesWithRedFlag.add(member.removeStartIgnoreCase('Red_Flag_'));
            }
        }
        System.debug('States With Red Flags: ' + statesWithRedFlag);
        RecordType[] allRecordTypes = [select Id, DeveloperName from RecordType where SobjectType='Referral__c'];
        Map<String, ID> recordTypeMap = new Map<String, ID>();
        for (RecordType rt: allRecordTypes) {
            recordTypeMap.put(rt.DeveloperName.toLowercase(), rt.ID);
        }
        System.debug('Record Type Map: ' + recordTypeMap);
        // This maps record type (state) ids to their high risk criteria
        Map<String, List<String>> highRiskMap = new Map<String, List<String>>();
        for (String stateWithRedFlag: statesWithRedFlag) {
            if (!recordTypeMap.containsKey(stateWithRedFlag)) System.debug('WHAT! ' + stateWithRedFlag);
            highRiskMap.put(recordTypeMap.get(stateWithRedFlag), new List<String>());
            Schema.FieldSetMember[] fields = fieldsets.get('Red_Flag_'+stateWithRedFlag.replace(' ', '_')).getFields();
            for (Schema.FieldSetMember field: fields) {
                highRiskMap.get(recordTypeMap.get(stateWithRedFlag)).add(field.getFieldPath());
            }
        }
        System.debug('High Risk Map: ' + highRiskMap);
        Set<String> fieldsToGet = new Set<String>();
        for (List<String> f: highRiskMap.values()) {
            fieldsToGet.addAll(f);
        }
        String fieldsToGetString = '';
        for (String field: fieldsToGet) {
            fieldsToGetString += field + ', ';
        }
        fieldsToGetString = fieldsToGetString.substring(0, fieldsToGetString.length()-2);
        Map<String, Schema.DisplayType> fieldTypeMap = new Map<String, Schema.DisplayType>();
        Map<String, Schema.sObjectField> allFields = SObjectType.Referral__c.fields.getMap();
        for (String field: fieldsToGet) {
            fieldTypeMap.put(field, allFields.get(field).getDescribe().getType());
        }
        Set<ID> newRefsIds;
        if (!isInsert) newRefsIds = newRefsMap.keySet();

        for (Referral__c ref: newRefs) {
            System.debug('Checking referral: ' + ref);
            if (!highRiskMap.containsKey(ref.RecordTypeID)) {
                System.debug('RecordTypeId not in highRiskMap');
                if (Trigger.isUpdate) {
                    // In case the record type is changed
                    newRefsMap.get(ref.ID).High_risk__c = false;
                    newRefsMap.get(ref.ID).Red_Flag_Description_Boolean__c = null;
                    newRefsMap.get(ref.ID).Red_Flag_Description_Other__c = null;
                }
                continue;
            }
            List<String> criteria = highRiskMap.get(ref.RecordTypeID);
            List<String> redFlagBooleans = new List<String>();
            List<String> redFlagOthers = new List<String>();
            System.debug('Found criteria: ' + criteria);
            for (String criterion: criteria) {
                System.debug('Criterion: ' + criterion);
                System.debug('Value for criterion: ' + ref.get(criterion));
                if (!isInsert) System.debug('Value for criterion in trigger: ' + newRefsMap.get(ref.ID).get(criterion));
                if (fieldTypeMap.get(criterion) == Schema.DisplayType.Boolean) {
                    if (isInsert && (Boolean)ref.get(criterion)) {
                        redFlagBooleans.add(Schema.SObjectType.Referral__c.fields.getMap().get(criterion).getDescribe().getLabel());
                    }
                    if (!isInsert && (Boolean) newRefsMap.get(ref.ID).get(criterion)) {
                        redFlagBooleans.add(Schema.SObjectType.Referral__c.fields.getMap().get(criterion).getDescribe().getLabel());
                    }
                } else {
                    if (!isInsert) {
                        if (newRefsMap.get(ref.ID).get(criterion)!=null) {
                            redFlagOthers.add(Schema.SObjectType.Referral__c.fields.getMap().get(criterion).getDescribe().getLabel() + ': ' + String.valueOf(newRefsMap.get(ref.ID).get(criterion)));
                            continue;
                        }
                        // Here we know that in Trigger.new, the criterion is
                        // null, but is it because it is changed to null, or is
                        // it because it has always been null? We check that
                        // as followed
                        if (oldRefsMap.get(ref.ID).get(criterion)!=null) {
                            continue;  // it has been changed to null, move on.
                        }
                    }
                    if (ref.get(criterion)!=null) {
                        redFlagOthers.add(Schema.SObjectType.Referral__c.fields.getMap().get(criterion).getDescribe().getLabel() + ': ' + String.valueOf(ref.get(criterion)));
                    }
                }
            }
            if (redFlagBooleans.size()!=0 || redFlagOthers.size()!=0) {
                if (!isInsert) {
                    newRefsMap.get(ref.ID).High_risk__c = true;
                    newRefsMap.get(ref.ID).Red_Flag_Description_Boolean__c = String.join(redFlagBooleans, ', ');
                    newRefsMap.get(ref.ID).Red_Flag_Description_Other__c = String.join(redFlagOthers, ', ');
                } else {
                    ref.High_risk__c = true;
                    ref.Red_Flag_Description_Boolean__c = String.join(redFlagBooleans, ', ');
                    ref.Red_Flag_Description_Other__c = String.join(redFlagOthers, ', ');
                }
            } else {
                if (!isInsert) {
                    newRefsMap.get(ref.ID).High_risk__c = false;
                    newRefsMap.get(ref.ID).Red_Flag_Description_Boolean__c = null;
                    newRefsMap.get(ref.ID).Red_Flag_Description_Other__c = null;
                } else {
                    ref.High_risk__c = false;
                    ref.Red_Flag_Description_Boolean__c = null;
                    ref.Red_Flag_Description_Other__c = null;
                }
            }
        }
    }
}