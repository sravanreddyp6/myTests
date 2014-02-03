public class BehaviorTracking_Form{
    private ApexPages.StandardController Controller;
    private Action_Plan_Worksheet__c worksheet;
    private List<Action_Plan_Objective__c > privateobjectives;
    private Action_Plan_Objective__c currentObjective;
    public id currentObjectiveid {get;set;}
    public string objectiveIdChosen {get;set;}

    public BehaviorTracking_Form(ApexPages.StandardController controller){
        this.Controller = controller;
        AddFields(new List<string>{'Action_plan__r.Status__c'});
        worksheet = (Action_Plan_Worksheet__c)controller.getrecord();
        currentObjectiveid = ApexPages.CurrentPage().getParameters().get('objectiveid');
    }
    
    public void AddFields(List<string> newfields){
    	if (!test.isRunningTest()){
    		Controller.AddFields(newfields);
    	}
    }
    
    public String getPersonName(){
        return [select Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Name
                    from Action_Plan_Worksheet__c
                    where Id = :worksheet.Id].Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Name;
    }
    
    public String getPersonId(){
        return [select Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Id
                    from Action_Plan_Worksheet__c
                    where Id = :worksheet.Id].Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Id;
    }
    
    public boolean editable { get { return !worksheet.Action_plan__r.Status__c.contains('Inactive');}}
    
    private List<Table >  calcTables(){
        Date firstDay = worksheet.Start_Date__c;
        privateobjectives = ReportableBehaviorObjectives(firstDay);
        List<Table> out = new List<Table>();
         
        for(Action_Plan_Objective__c objective:privateobjectives){
            if (currentObjectiveId == objective.Id){
                currentObjective = objective;
                break;
            }
        }
        if (currentObjective == null){
            if (privateObjectives.size() == 0){
                return out;
            }
            currentObjective = privateObjectives[0];
        }
                
        out.Add(GenerateObjectiveTable(currentObjective, firstDay));
        return out;
    }

	private Table GenerateObjectiveTable(Action_Plan_Objective__c objective, Date firstDay){
		Table t1 = new Table(getHoursOfDay(), getDaysToDisplay());
        t1.ObjectiveDescription = objective.Description__c;
        t1.ObjectiveId = objective.Id;
        t1.IsTimeBased = IsTimeBased(objective);
        system.debug(logginglevel.warn, objective.Action_Behavior_Results__r.size());
        for(Action_Behavior_Result__c result: ResultsForObjective(objective, firstday)){
            t1.Put(result.Day_time__c.TimeGMT().hour(),result.Day_time__c.DateGMT(), result);
        }
        for( integer timeofday : t1.FirstKeys){
            for(Date day: getdaysofmonth()){
                if ((!t1.Active(timeofday, day)) && DateValidForObjectiveAndPlan(day, objective)){
                    Action_Behavior_Result__c blankResult = new Action_Behavior_Result__c();
                    blankResult.Action_Plan_Objective__c = objective.Id;
                    blankresult.Day_time__c = DateTime.newinstanceGMT(day, Time.newInstance(timeofday,0,0,0));
                    system.debug( blankresult.Day_time__c);
                    t1.Put(timeofday, day, blankResult);
                }
            }
        }
		return t1;
	}    
	
    public List<Date> getDaysToDisplay() {
        List<Date> month = new List<Date>();
        Date startDate = (worksheet.Start_Date__c - 1).toStartofWeek()+1; // we start on Monday
        Date endDate = StartDate.addDays(42);
        for(Date dateiter = StartDate; dateiter < endDate; dateiter = dateiter+1){
            month.Add(dateiter);
        }
        return month;
    }
    
    public List<Date> getDaysOfMonth() {
        List<Date> month = new List<Date>();
        Date endDate = worksheet.Start_Date__c.addmonths(1).toStartofMonth();
        system.debug(worksheet.Start_Date__c.addmonths(1));
        system.debug(worksheet.Start_Date__c.addmonths(1).toStartofMonth());
        for(Date dateiter = worksheet.Start_Date__c.toStartofMonth(); dateiter < endDate; dateiter = dateiter+1){
            month.Add(dateiter);
        }
        return month;
    }
    
    public List<integer> getHoursOfDay() {
        List<integer> hours = new List<integer>();
        for(integer ii = 0; ii < 24 ; ii++){
            hours.Add(ii);
        }
        return hours;
    }
    
//    public string ObjectiveIsTimeBased() {
//        return ObjectiveIsTimeBased(CurrentObjective) ? 'checked' : '';
//    }
    
//    public boolean getObjectiveIsTimeBased(){
//        return IsTimeBased(currentObjective);
//    }
    
    private boolean IsTimeBased(Action_Plan_Objective__c objective){
    	return objective.Type__c == 'Behavior - Duration';	
    }
    
    private List<Action_Plan_Objective__c> ReportableBehaviorObjectives(Date firstDay){
        return [ select Description__c, effective_Date__c, Target_end_date__c, Type__c
                   from  Action_Plan_Objective__c
                  where Action_Plan_Goal__r.Action_Plan__c = :worksheet.Action_Plan__c
                    and ((effective_date__c < :firstDay.addMonths(1)) or (effective_date__c = null))
                    and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
                    and (Type__c = 'Behavior - Count' or Type__c = 'Behavior - Duration')
                    and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
                 order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
    }

	private List<Action_Behavior_Result__c> ResultsForObjective(Action_Plan_Objective__c objective, Date firstDay){
    	return [select Day_time__c, Occurrences__c, Occurred__c
                           from Action_Behavior_Result__c
                          where Action_Plan_Objective__c = :objective.id
                          	and Day_time__c >= :firstDay 
                            and Day_time__c < :firstDay.addmonths(1)
                          order by Day_time__c]; 		
	}
	
    private Map<id, Action_Behavior_Result__c> ResultMap(Date firstDay){
        Map<id, Action_Behavior_Result__c> origData = new Map<id, Action_Behavior_Result__c>();
        for(Action_Plan_Objective__c objective: ReportableBehaviorObjectives(firstDay)){
        	if (objective.id == currentObjective.Id){
	             for(Action_Behavior_Result__c result: ResultsForObjective(objective, firstDay)){
	                 origData.Put(result.id, result);
	             }
        	}
        }
        return origData;
    }
    public boolean DateValidForObjectiveAndPlan(Date day,/* Action_Plan__c plan,*/ Action_Plan_Objective__c objective){
        return /*(plan.Effective_Date__c = null || day >= plan.Effective_Date__c ) && */
                ((objective.Effective_Date__c == null) || (day >= objective.Effective_Date__c)) &&
               /* (plan.Target_Date__c= null || day <= plan.Target_Date__c) &&  */
                ((objective.Target_End_Date__c == null) || (day <= objective.Target_End_Date__c));
    }

////////////////////
// Actions
////////////////////
    public PageReference saveandswitchObjective(){
        system.debug('switching to:' + objectiveidChosen);
        try {
            mySave();
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    e.getMessage()));
            return null;
        }
        return switchObjective();
    }
    
    public PageReference PrintOtherObjective(){
    	string printObjectiveId = objectiveIdChosen;
        for(Action_Plan_Objective__c objective:privateobjectives){
            if (printObjectiveId == objective.Id){
                anotoGenerate1(GenerateObjectiveTable(objective, worksheet.Start_Date__c));
                break;
            }
        }
    	return null;
    }
    
    public PageReference switchObjective(){
        currentObjectiveId = objectiveidChosen;
        privateTables = null;
        //return null;
        pdfExistenceUrl = null;
        PageReference page = new PageReference('/apex/BehaviorTracking?id=' + worksheet.id + '&objectiveid=' + currentObjectiveID);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference mySave(){
        List<Action_Behavior_Result__c> toUpDate = new List<Action_Behavior_Result__c>();
        Map<id, Action_Behavior_Result__c> origData = ResultMap(worksheet.Start_Date__c);
        for(Table table: Tables){
            for(integer hour:table.Firstkeys){
                for(Date day : table.AllSecondKeys){
                    Action_Behavior_Result__c cellObj = table.get(hour,day);
                    if (cellObj == null){
                        continue;
                    }
                    if (origData.containsKey(cellObj.Id)){
                        Action_Behavior_Result__c origObj = origData.get(cellObj.Id);
                        if (cellObj.Occurrences__c != origObj.Occurrences__c ||
                            cellObj.Occurred__c != origObj.Occurred__c){
                            toUpDate.Add(cellObj);
                        }
                    } else {
                        if (cellObj.Occurrences__c != null ||
                            cellObj.Occurred__c != false){
                            toUpDate.Add(cellobj);
                        }
                    }
                }
            }
        }
        upsert toUpdate;
        pdfExistenceUrl = null;
        return null;
    }
    
    // transient - 1/2 the size of viewstate
    private List<Table> privateTables;
    public List<Table> Tables {
    get {
        if (privateTables == null) {
            privateTables = calcTables();
        }
        return privateTables;
    }}
    
    public List<Action_Plan_Objective__c> Objectives {
    get {
        if (privateObjectives == null) {
            privateTables = calcTables();
        }
        return privateObjectives;
    }}
    
    public Attachment anotoXml {get;set;}
    public String pdfExistenceUrl {get;set;}
    
    public Dom.Document anotoGenerateDocument(Table objTable){
        AnotoXmlGeneration anoto = new AnotoXmlGeneration();
        system.debug('recordid:' + worksheet.id);
        anoto.RecordId = worksheet.Id;
        
        AnotoXmlGeneration.OutputPage headerPage = new AnotoXmlGeneration.OutputPage(null, 1); // use background in app definition
        anoto.Pages.add(headerPage);
        
        AnotoXmlGeneration.Widget personw = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 'person' + getPersonId() );
        personw.WriteEnabled = false;
        personw.Layout(1, 7.0, 35.9, 5.8, 58); 
        personw.DefaultValue = getPersonName();
        anoto.Widgets.Add(personw);

        AnotoXmlGeneration.Widget formdatew = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 'day' + worksheet.Id );
        formdatew.WriteEnabled = false;
        formdatew.Layout(1, 7.0, 180.2, 5.8, 34.8); 
        formdatew.DefaultValue = DateTime.newInstance(worksheet.start_date__c, Time.newInstance(0,0,0,0)).format('MMM yyyy');
        anoto.Widgets.Add(formdatew);

        integer page = 1;
        
            Decimal top = 38.1;

            AnotoXmlGeneration.Widget objectivedescw = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 'desc' + objTable.ObjectiveId );
            objectivedescw.WriteEnabled = false;
            objectivedescw.Layout(1, 14.5, 4.2, 14.5, 145); 
            objectivedescw.DefaultValue = objTable.ObjectiveDescription;
            anoto.Widgets.Add(objectivedescw);
            
            for(integer tablepart=1;tablepart<=2;tablepart++){
                List<Date> colIndexes = tablepart == 1 ? objTable.PartOneSecondKeys : objTable.PartTwoSecondKeys;
//                for(integer tofday:new List<integer>{objTable.FirstKeys[0]}){
                for(integer tofday:objTable.FirstKeys){

                    Decimal left = 18.4;
                    for(Date day:colIndexes){
                        if (objTable.Active(tofday, day)){
                            Action_Behavior_Result__c behavior_result = objTable.Get(tofday, day);
                            if (tofday == 0){
                               AnotoXmlGeneration.Widget datew = 
                                    new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield,
                                                                  new BehaviorTrackingInput.BehaviorResultNodeName(
                                                                      objTable.ObjectiveId, 
                                                                      DateTime.newInstanceGMT(day, Time.newInstance(tofday, 0, 0, 0)),'HeaderDate').NodeName);
                                datew.WriteEnabled = false;
                                datew.DefaultValue = DateTime.newinstance(day, Time.newinstance(0,0,0,0)).format('d');
                                datew.Layout(page, top - 10.0 , left + 2.9, 5.5, 15); 
                                datew.FontSize = 10;
                                anoto.Widgets.Add(datew);
                            }
                            if (objTable.IsTimeBased){
                                AnotoXmlGeneration.Widget timechkw = 
                                    new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.checkbox,
                                                                  new BehaviorTrackingInput.BehaviorResultNodeName(
                                                                      objTable.ObjectiveId, 
                                                                      DateTime.newInstanceGMT(day, Time.newInstance(tofday, 0, 0, 0)),'Occurred').NodeName);
                                if (behavior_result.Occurred__c != null){
                                    timechkw.DefaultValue = behavior_result.Occurred__c ? 'true' : 'false';
                                }
                                timechkw.Layout(page, top , left, 5.5, 9.2);
                                timechkw.ValueOffset(0.0, -1.0);
                                anoto.Widgets.Add(timechkw);
                            }
                            else {
                                AnotoXmlGeneration.Widget countw = 
                                    new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield,
                                                                  new BehaviorTrackingInput.BehaviorResultNodeName(
                                                                      objTable.ObjectiveId, 
                                                                      DateTime.newInstanceGMT(day, Time.newInstance(tofday, 0, 0, 0)),'Occurrences').NodeName);
                                if (behavior_result.Occurrences__c != null){
                                    countw.DefaultValue = behavior_result.Occurrences__c.format();
                                }
                                //countw.CharCount = 2;
                                countw.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.numeric;
                                countw.Layout(page, top , left, 5.5, 9.2); 
                                countw.ValueOffset(1.0,-1.0);
                                countw.FontSize = 10;
                                anoto.Widgets.Add(countw);
                            }
                        }

                        left += 9.37;
                    }             
                    top += 4.25;
            }  // times down page
            
            // Second half of the month needs a gap
            top += 13.8;
            } // Second part

        return anoto.GenerateDocument();
    }
    
    public PageReference anotoGenerate(){
        anotoGenerate1(Tables[0]);

        return null;
    }

	private void anotoGenerate1(Table objTable){
		string txt = anotoGenerateDocument(objTable).toXmlString();
        // send to the print processor
        try{
            pdfExistenceUrl = AnotoUtility.generatePdfByHandlerName('BehaviorTrackingForm', txt);
        } catch (AnotoUtility.PdfGenerationException excp){
            System.Debug(logginglevel.error,'Pdf exception:' + excp.getmessage());
        }    
        //CreateXmlAttachment(txt);		
	}    
    private void CreateXmlAttachment(string txt){
    	// Allow preview of xml
        Blob txtBlob = Blob.valueOf(txt); //Convert it to a blob

        Attachment attach = new Attachment(); //Make an attachment
        attach.Name ='text.xml';  
        attach.Body = txtBlob;
        attach.ContentType= 'application/xml'; //Signal what the file's MIME type is
        attach.ParentID = worksheet.id;
        insert attach;
        anotoXml = attach;
        System.Debug('Xml Generated '+ anotoXml.Id + ' name: ' + anotoXml.Name);
    	
    }

    public class Table {
        public List<integer> FirstKeys {get;set;}
        public List<Date> PartOneSecondKeys {get;set;}
        public List<Date> PartTwoSecondKeys {get;set;}
        public List<Date> AllSecondKeys {get;set;}
        private Map<integer, Row> myRows;
        public string ObjectiveDescription {get;set;}
        public string ObjectiveId {get;set;}
        public boolean IsTimeBased {get;set;}
        
        public Map<integer, Row> getRows(){
            return myRows;
        }
        
        public Table(List<integer> keys1, List<Date> keys2) {
            myRows = new Map<integer, Row>();
            FirstKeys = keys1;
            PartOneSecondKeys = new List<Date>();
            PartTwoSecondKeys = new List<Date>();
            AllSecondKeys = keys2;
            integer jj = 0;
            for(Date day: keys2){
                system.debug('Table Key:' + day);
                if (jj < 21){
                    PartOneSecondKeys.Add(day);
                } else {
                    PartTwoSecondKeys.Add(day);
                }
                jj++;
            }
            for(integer ii: keys1){
                Row newRow = new Row(ii, keys2);
                myRows.put(ii, newRow);
            }       
        }
        
        public void Put(integer tofd, Date day, Action_Behavior_Result__c value){
            myRows.get(tofd).put(day, value);
        }
        
        public Action_Behavior_Result__c Get(integer tofd, Date day){
            return myRows.get(tofd).get(day);
        }
        
        public boolean Active(integer tofd, Date day) {
            system.debug('Table Access:' + day);
            return myRows.get(tofd).getItems().get(day).Active;
        }
    }
    
    public class Row {
        private Map<Date, Action_Behavior_Wrapper> myItems {get;set;}
        private string myhour;
        
        public Map<Date, Action_Behavior_Wrapper> getItems(){
            return myItems;
        }
        
        public Row(integer hour, List<Date> alldays){
            myItems = new Map<Date, Action_Behavior_Wrapper>();
            myhour = DateTime.newInstanceGMT(Date.Today(), Time.newInstance(hour, 0,0,0)).formatGMT('ha');
            for(Date day: alldays){
                myItems.Put(day, new Action_Behavior_Wrapper(hour, day, null));
            }
        }
        
        public string getHeader(){
            return myhour;
        }
        public void Put(Date day, Action_Behavior_Result__c item){
            Action_Behavior_Wrapper wrap = myItems.get(day);
            wrap.DataObject = item;
        }

        public Action_Behavior_Result__c Get(Date day){
            Action_Behavior_Wrapper wrap = myItems.get(day);
            return wrap.DataObject;
        }

    }
    
    public class Action_Behavior_Wrapper {
        public Action_Behavior_Result__c myObject;
        public integer mytime;
        public Date myDate;
        public boolean Active {get{ return myObject <> null;}}

/*****
** Needed if the timezone ever springs forward causing 2am to become 3am
**        public boolean Active {get{ return myObject <> null && !missinghour;}}
**        private boolean missinghour;
******/        
        public Action_Behavior_Wrapper(integer tofd, Date day, Action_Behavior_Result__c obj){
            myobject = obj;
            mytime = tofd;
            myDate = day;
            //catch the missing hour when the day goes forward
            //missinghour = DateTime.NewInstanceGMT(day, Time.NewInstance(tofd, 0, 0, 0)).hourGMT() != tofd;
        }
        
        public Action_Behavior_Result__c DataObject{ 
            get { return myObject;}
            set { myObject = value;}
        }
        
        public string getDayOfWeek(){
            return DateTime.newInstanceGMT(myDate, Time.newInstance(0,0,0,0)).formatGMT('E');
        }
    }
}