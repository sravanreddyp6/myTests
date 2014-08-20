public class SkillTrackingInput implements AnotoFormHandler{
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
        skillResultManager manager = new skillResultManager();
        for(Dom.XmlNode child: reader.getRootElement().getChildElements()){ 
            if (child.getName() != 'field') { 
                continue;
            }
            skillResultNodeName nodename = new skillResultNodeName(child.getAttributeValue('name', null));
            if (nodename.isValid){
                string value = child.getText();
                if (nodeName.Property == 'Attempts' && (value != null) && (value != '')){
                    Action_Skill_Result__c result = manager.Get(nodename.ObjectId, nodename.day);
                    result.Attempts__c = Integer.valueOf(value);
                    manager.UpdateObject(result);
            	}
                if (nodeName.Property == 'Met' && (value != null) && (value != '')){
                    Action_Skill_Result__c result = manager.Get(nodename.ObjectId, nodename.day);
                    result.Met_Objective__c = value;
                    manager.UpdateObject(result);
            	}
                if (nodeName.Property == 'Status' && (value != null) && (value != '')){
                    Action_Skill_Result__c result = manager.Get(nodename.ObjectId, nodename.day);
                    result.Status__c = value;
                    manager.UpdateObject(result);
            	}
                if (nodeName.Property == 'Initials' && (value != null) && (value != '')){
                    Action_Skill_Result__c result = manager.Get(nodename.ObjectId, nodename.day);
                    result.Initials__c = value;
                    manager.UpdateObject(result);
            	}
            }
        }
        manager.Finish();
        return true;
    }
    
    public class skillResultManager {
        private List<Action_Skill_Result__c> allObjects;
        private list<Action_Skill_Result__c> updateObjects = new list<Action_Skill_Result__c>();
        
        public Action_Skill_Result__c Get(Id objectId, Date day){
            if (allobjects == null){
                PrepopulateObjects(objectId, day);
            }
            Action_Skill_Result__c result;
            for(Action_Skill_Result__c iter:allobjects){
                if (iter.Action_plan_Objective__c == objectid && iter.day__c == day){
                    result = iter;
                }
            }
            if (result == null){
                result = new Action_Skill_Result__c();
                result.Action_Plan_Objective__c = objectid;
                result.Day__c = day;
                allobjects.add(result);
            }
            system.debug('All Object count:' + allobjects.size());
			return result;
        }
        
        public void UpdateObject(Action_Skill_Result__c obj){
            Action_Skill_Result__c result;
            for(Action_Skill_Result__c iter:updateObjects){
                if (iter.Action_plan_Objective__c == obj.Action_plan_Objective__c && iter.day__c == obj.day__c){
                    result = iter;
                }
            }
            if (result == null){
            	updateObjects.Add( obj);
            }
            System.debug('Update Object Count:' + updateObjects.size());
        }
        
        public void Finish(){
            Database.UpsertResult[] results = Database.upsert(updateObjects, false);
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
        private void PrepopulateObjects(Id objectId, Date day){
            Date firstday = (day-1).toStartOfWeek()+1;
            Date lastdayplus = firstday + 7;
            System.debug('Input Week:' + firstday.format() + lastdayplus.format());
            Id planId = [select Action_plan_goal__r.Action_plan__c 
                         from Action_Plan_Objective__c
                         where id = :objectId][0].Action_plan_goal__r.Action_plan__c;
            allobjects = [select attempts__c, Action_plan_Objective__c, met_objective__c, initials__c, status__c, day__c
                          from Action_Skill_Result__c
                          where Action_Plan_Objective__r.Action_Plan_Goal__r.Action_Plan__c = :planId
                          and Day__c >= :firstday and Day__c < :lastdayplus];
        }            
    }
        
    public class skillResultNodeName {
        public boolean isValid {get; private set;}
        public Id ObjectId {get; private set;}
        public Date Day {get; private set;}
        public string Property {get; private set;}
        public string NodeName {get; private set;}
        
        public SkillResultNodeName(string nodeName){
            if (!nodeName.startsWith('skill')){
                isValid = false;
                return;
            }
            string[] parts = nodeName.split('_');
            ObjectId = parts[1];
            Day = Date.valueOf(parts[2]);
            if (parts.size() > 3){
                Property = parts[3];
            }
            isValid = true;
            this.NodeName = nodeName;
        }
        
        public SkillResultNodeName(Id objectId, Date day, string propertyName){
            this.ObjectId = objectId;
            this.Day = day;
            this.Property = propertyName;
            String daystring = Datetime.newInstance(day, Time.newInstance(0,0,0,0) ).format('yyyy-MM-dd');
            NodeName = String.join(propertyName == null 
                                   ? new List<string>{'skill', objectId, daystring} 
                                   : new List<string>{'skill', objectId, daystring, propertyName}, '_');
            isValid = true;
        }
    }
}