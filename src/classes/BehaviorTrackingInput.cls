public class BehaviorTrackingInput implements AnotoFormHandler{
    public string handle(Id recordId, String fileType, Blob fileContent, RestRequest req, RestResponse response){
        try {
            if (filetype == 'xml') {
                process(fileContent.toString());
                response.statusCode = 200;
                return 'Successful';
            }
            response.statusCode = 501;
            return 'Not Supported';
        }
        catch (Exception excp){
            response.statusCode = 500;
            return 'FAILED';
        }
    }

    public boolean process(string xml){
        Dom.Document reader = new Dom.Document();
        reader.load(xml);
        BehaviorResultManager manager = new BehaviorResultManager();
        for(Dom.XmlNode child: reader.getRootElement().getChildElements()){
            if (child.getName() != 'field') {
                continue;
            }
            BehaviorResultNodeName nodename = new BehaviorResultNodeName(child.getAttributeValue('name', null));
            if (nodename.isValid){
                system.debug('Node:' + nodename.ObjectId + nodename.DayTime);
                string value = child.getText();
                if (nodeName.Property == 'Occurrences' && (value != null) && (value != '')){
                    Action_Behavior_Result__c result = manager.Get(nodename.ObjectId, nodename.daytime);
                    result.Occurrences__c = Integer.valueOf(value);
                    manager.UpdateObject(result);
                }
                if (nodeName.Property == 'Occurred' && (value != null) && (value != '') && (value != 'false')){
                    // let's not add all the false values
                    Action_Behavior_Result__c result = manager.Get(nodename.ObjectId, nodename.daytime);
                    result.Occurred__c = boolean.valueOf(value);
                    manager.UpdateObject(result);
                }
            }
        }
        manager.Finish();
        return true;
    }

    public class BehaviorResultManager {
        private Map<id, Map<DateTime, Action_Behavior_Result__c>> allObjects = new Map<id, Map<DateTime, Action_Behavior_Result__c>>();
        private Map<id, Map<DateTime, Action_Behavior_Result__c>> updateObjects = new Map<id, Map<DateTime, Action_Behavior_Result__c>>();

        public Action_Behavior_Result__c Get(Id objectId, DateTime daytime){
            if (allobjects == null){
                PrepopulateObjects(objectId, daytime);
            }
            Action_Behavior_Result__c result;
            result = getFromCache(allObjects, objectId, daytime);
            if (result == null){
                result = new Action_Behavior_Result__c();
                result.Action_Plan_Objective__c = objectid;
                result.Day_time__c = daytime;
                addToCache(allObjects, objectId, daytime, result);
            }
            return result;
        }

        private void addToCache(Map<id, Map<DateTime, Action_Behavior_Result__c>> cache, Id objectId, DateTime daytime, Action_Behavior_Result__c result){
            Map<DateTime, Action_Behavior_Result__c> map1 = allobjects.get(objectId);
            if (cache.containsKey(objectId)){
                map1 = cache.get(objectId);
            } else {
                map1 = new Map<DateTime, Action_Behavior_Result__c>();
                cache.put(objectId, map1);
            }
            map1.put(daytime,result);
        }

        private List<Action_Behavior_Result__c> CacheToList(Map<id, Map<DateTime, Action_Behavior_Result__c>> cache){
            List<Action_Behavior_Result__c> resultlist = new List<Action_Behavior_Result__c>();
            for(id id1:cache.keySet()){
                Map<DateTime, Action_Behavior_Result__c> map1 = cache.get(id1);
                for (DateTime daytime: map1.keySet()){
                    resultlist.add(map1.get(daytime));
                }
            }
            return resultlist;
        }

        private Action_Behavior_Result__c getFromCache(Map<id, Map<DateTime, Action_Behavior_Result__c>> cache, Id objectId, DateTime daytime){
            if (cache.containsKey(objectId)){
                Map<DateTime, Action_Behavior_Result__c> map1 = cache.get(objectId);
                if (map1.containsKey(daytime)){
                    return map1.get(daytime);
                }
            }
            return null;
        }

        public void UpdateObject(Action_Behavior_Result__c obj){
            Action_Behavior_Result__c result;
            AddToCache(updateObjects, obj.Action_plan_Objective__c, obj.Day_time__c, obj);
        }

        public void Finish(){
            Database.UpsertResult[] results = Database.upsert(CacheToList(updateObjects), false);
            for (Database.UpsertResult sr : results) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    // System.debug('Successfully inserted account. Result ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred for result record: ' + sr.getId());
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Result fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        // Assumes that a single file only holds records for a single Action_plan for a single
        // Mon-Sun week
        private void PrepopulateObjects(Id objectId, Datetime daytime){
            Date firstday = daytime.date().toStartOfMonth();
            Date lastdayplus = firstday.addMonths(1);
            System.debug('Input Week:' + firstday.format() + lastdayplus.format());
            Id planId = [select Action_plan_goal__r.Action_plan__c
                         from Action_Plan_Objective__c
                         where id = :objectId][0].Action_plan_goal__r.Action_plan__c;
            List<Action_Behavior_Result__c> objects = [select occurrences__c, day_time__c, Action_plan_Objective__c
                          from Action_Behavior_Result__c
                          where Action_Plan_Objective__r.Action_Plan_Goal__r.Action_Plan__c = :planId
                          and Day_time__c >= :firstday and Day_time__c < :lastdayplus];
            for(Action_Behavior_Result__c result:objects){
                addToCache(allObjects, result.Id, result.Day_time__c, result);
            }
        }
    }

    public class BehaviorResultNodeName {
        public boolean isValid {get; private set;}
        public Id ObjectId {get; private set;}
        public DateTime DayTime {get; private set;}
        public string Property {get; private set;}
        public string NodeName {get; private set;}

        public BehaviorResultNodeName(string nodeName){
            if (!nodeName.startsWith('behavior')){
                isValid = false;
                return;
            }
            string[] parts = nodeName.split('_');
            ObjectId = parts[1];
            string[] timeparts = parts[2].split('-');
            DayTime = DateTime.newInstanceGMT(integer.valueof(timeparts[0])
                                              , integer.valueof(timeparts[1])
                                              , integer.valueof(timeparts[2])
                                              , integer.valueof(timeparts[3])
                                              , 0, 0
                                             );
            if (parts.size() > 3){
                Property = parts[3];
            }
            isValid = true;
            this.NodeName = nodeName;
        }

        public BehaviorResultNodeName(Id objectId, DateTime day, string propertyName){
            this.ObjectId = objectId;
            this.DayTime = day;
            this.Property = propertyName;
            String daystring = day.formatGMT('yyyy-MM-dd-HH-mm-ss');
            NodeName = String.join(propertyName == null
                                   ? new List<string>{'behavior', objectId, daystring}
                                   : new List<string>{'behavior', objectId, daystring, propertyName}, '_');
            isValid = true;
        }
    }
}