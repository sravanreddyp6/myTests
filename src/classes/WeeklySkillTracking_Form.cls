public with sharing class WeeklySkillTracking_Form {
      
    private ApexPages.StandardController controller;
    private Action_Plan_Worksheet__c result;
    private List<ObjectiveWrapper> objectivesMap;
    public boolean hasError = false;
    
    // Usual constructor
    public WeeklySkillTracking_Form(ApexPages.StandardController controller) {
        this.controller = controller;
        result = [select Name, Start_Date__c, Action_Plan__c, action_Plan__r.Status__c,        
                     Action_Plan__r.Service_Assignment__r.Admission__r.State__c, Action_Plan__r.Service_Assignment__c, 
                     Action_Plan__r.Service_Assignment__r.Admission__c, Action_Plan__r.Service_Assignment__r.Admission__r.Person_Being_Served__c 
                    from Action_Plan_Worksheet__c
                    where Id = :controller.getRecord().Id];
    }
    
    // test constructor
    public WeeklySkillTracking_Form(Action_Plan_Worksheet__c result) {
        this.controller = null;
        this.result = result;
    }

    public String getPersonName(){
        return [select Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Name
                    from Action_Plan_Worksheet__c
                    where Id = :result.Id].Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Name;
    }
    
    public String getPersonId(){
        return [select Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Id
                    from Action_Plan_Worksheet__c
                    where Id = :result.Id].Action_Plan__r.Service_Assignment__r.Person_Being_Served__r.Id;
    }
    
    public List<Date> getDaysOfWeek() {
        List<Date> week = new List<Date>();
        week.Add(result.Start_Date__c);
        week.Add(result.Start_Date__c+1);
        week.Add( result.Start_Date__c + 2);
        week.Add( result.Start_Date__c + 3);
        week.Add(result.Start_Date__c + 4);
        week.Add(result.Start_Date__c + 5);
        week.Add(result.Start_Date__c + 6);
        return week;
    }
    
    
    public List<ObjectiveWrapper>  getObjectivesMap(){
        if (objectivesmap == null){
            objectivesMap = calcObjectivesMap();
        }
        return objectivesMap;
    }
    
    public boolean editable { get { return !result.Action_plan__r.Status__c.contains('Inactive');}}
    
    private List<ObjectiveWrapper>  calcObjectivesMap(){
        Date firstDay = result.Start_Date__c;
        List<Action_Plan_Objective__c> objectives = ReportableSkillObjectives(firstDay);
        List<ObjectiveWrapper> out = new List<ObjectiveWrapper>();
         
         for(Action_Plan_Objective__c objective:objectives){
             Map<Date, Action_Skill_Result__c> dayResult = new Map<Date, Action_Skill_Result__c>();
             for(Action_Skill_Result__c result: objective.Action_Skill_Results__r){
                 dayResult.Put(result.Day__c, result);
             }
             for(Date day : getDaysOfWeek()){
                 if ((!dayResult.ContainsKey(day))){
                     Action_Skill_Result__c blankResult = new Action_Skill_Result__c();
                     blankResult.Action_Plan_Objective__c = objective.Id;
                     
                     // this is a bit of a hack but need a simple way to tell the page to not render these guys
                     blankResult.Day__c = DateValidForObjectiveAndPlan(day, objective) ? day : Date.Parse('1/1/2000');
                     dayResult.Put(day, blankResult);
                 }
             }
             ObjectiveWrapper wrapper = new ObjectiveWrapper(objective);
             wrapper.ResultsMap = dayResult;
             out.Add(wrapper);
         }
         return out;
    }

    private List<Action_Plan_Objective__c> ReportableSkillObjectives(Date firstDay){
        return [ select Description__c, effective_Date__c, Target_end_date__c, 
                        (select Day__c, Attempts__c, Initials__c, Met_Objective__c, Status__c
                           from Action_Skill_Results__r
                          where Day__c >= :firstDay 
                            and Day__c < :firstDay + 7
                          order by Day__c)
                   from  Action_Plan_Objective__c
                  where Action_Plan_Goal__r.Action_Plan__c = :result.Action_Plan__c
                    and ((effective_date__c < :firstDay + 7) or (effective_date__c = null))
                    and ((target_end_date__c >= :firstDay) or (target_end_date__c = null))
                    and Type__c = 'Skill'
                    and (Status__c = 'In Progress' or Status__c = 'Revised' or Status__c = 'New')
                  order by action_plan_goal__r.sort_order__c, action_plan_goal__c,  sort_order__c];
    }
    
    public boolean DateValidForObjectiveAndPlan(Date day,/* Action_Plan__c plan,*/ Action_Plan_Objective__c objective){
        return /*(plan.Effective_Date__c = null || day >= plan.Effective_Date__c ) && */
                ((objective.Effective_Date__c == null) || (day >= objective.Effective_Date__c)) &&
               /* (plan.Target_Date__c= null || day <= plan.Target_Date__c) &&  */
                ((objective.Target_End_Date__c == null) || (day <= objective.Target_End_Date__c));
    }

    public PageReference myNewNote(){
        mySave();
        
        if (ApexPages.hasMessages() ) {
        	return null;
        } 
        else {
        	PageReference page = new PageReference('/apex/Notes_ProgressNote_Create?plan=' + result.Action_plan__c + 
                                                '&service_assignment=' + result.Action_plan__r.Service_Assignment__c +
                                                '&admission=' + result.Action_Plan__r.Service_Assignment__r.Admission__c +
                                                '&person=' + result.Action_Plan__r.Service_Assignment__r.Admission__r.Person_Being_Served__c +
                                                '&state=' + result.Action_Plan__r.Service_Assignment__r.Admission__r.State__c +
                                                '&retURL=' +ApexPages.currentPage().getURL());

        
        
        	return page; 
        }        
    }
    
    public PageReference mySave()
    {
    
         List <Action_Skill_Result__c> toupdate = new List<Action_Skill_Result__c>();
         for(ObjectiveWrapper objectivewrp:getobjectivesmap()){
             for(Date day: objectivewrp.ResultsMap.keyset()){
                 Action_skill_result__c result = objectivewrp.ResultsMap.get(day);
                 if (result.Attempts__c != null ||
                     result.status__c != null ||
                     result.Met_Objective__c != null ||
                     result.Initials__c != null) {
                     // Enforce the Validation rules.  Deactivating the controls means the values not sent from client
                     // So have to do it here.
                        if (result.status__c == 'A' ||
                            result.status__c == 'H' ||
                            result.status__c == 'S' ||
                            result.status__c == 'HL' ) {
                            result.Met_Objective__c = null;
                            result.Attempts__c = null;
                        }
                        if (result.status__c == 'D' ) {
                            result.Met_Objective__c = 'N';
                        }
                        toupdate.Add( result );
                     
                 }
                 // else - usually it will but it exist but if it does try to delete it?
             }
         }
        try {
            upsert toupdate;
        } 
        catch (DmlException ex){
            system.debug(ex);
            ApexPages.AddMessages(ex);
            return null;
        }
        
        return null;
    }
    
    
    public PageReference returnToActionPlan(){
        return new PageReference('/' + result.Action_Plan__c);
    }
    
    public class ObjectiveWrapper{
        public Action_Plan_Objective__c Objective {get;set;}
        public Map<Date, Action_Skill_Result__c> ResultsMap {get;set;}
        
        public ObjectiveWrapper(Action_Plan_Objective__c obj){
            Objective = obj;
        }
    }
    
    public Attachment anotoXml {get;set;}
    public String pdfExistenceUrl {get;set;}
    
    public PageReference anotoGenerate(){
        string txt = anotoGenerateDocument().toXmlString();
        // send to the print processor
        pdfExistenceUrl = AnotoUtility.generatePdfByHandlerName('WeeklySkillTrackingForm', txt);
        
        // Allow preview of xml
        Blob txtBlob = Blob.valueOf(txt); //Convert it to a blob

        Attachment attach = new Attachment(); //Make an attachment
        attach.Name ='text.xml';  
        attach.Body = txtBlob;
        attach.ContentType= 'application/xml'; //Signal what the file's MIME type is
        attach.ParentID = result.id;
        insert attach;
        anotoXml = attach;
        System.Debug('Xml Generated '+ anotoXml.Id + ' name: ' + anotoXml.Name);
        return null;
    }
    
    public Dom.Document anotoGenerateDocument() {
        AnotoXmlGeneration anoto = new AnotoXmlGeneration();
        system.debug('recordid:' + result.id);
        anoto.RecordId = result.Id;
        
        Decimal headerheight = 28;
        Decimal top = headerheight;
        integer page = 1;
        boolean pageinitialized = false;
        
        string background = EncodingUtil.base64Encode([select body from document where name = 'Skill_Tracking_Day_Background'].Body);
        for(ObjectiveWrapper wrapper: getObjectivesMap()){
            if (!pageinitialized)   {
                AnotoXmlGeneration.OutputPage headerPage = new AnotoXmlGeneration.OutputPage('c:\\FormBackground\\SkillWorksheet_05Dec13_Background1_flat.pdf', page); // use background in app definition
                anoto.Pages.add(headerPage);
                
                AnotoXmlGeneration.Widget personw = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 'person' + page.format() + getPersonId() );
                personw.WriteEnabled = false;
                personw.Layout(page, 6.0, 35.2, 20.0, 100.0); 
                personw.DefaultValue = getPersonName();
                anoto.Widgets.Add(personw);
        
                AnotoXmlGeneration.Widget formdatew = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 'day' + page.format() + result.Id );
                formdatew.WriteEnabled = false;
                formdatew.Layout(page, 6.0, 214.2, 20.0, 60.0); 
                formdatew.DefaultValue = DateTime.newInstance(result.start_date__c, Time.newInstance(0,0,0,0)).format('MMM dd yyyy');
                anoto.Widgets.Add(formdatew);
                
                AnotoXmlGeneration.Widget hiddenw = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.hidepattern, 'hidden' + page.format() + result.Id );
                hiddenw.WriteEnabled = false;
                hiddenw.Layout(page, 0.0, 0.0, headerheight, 300.0); 
                anoto.Widgets.Add(hiddenw);
                
                pageinitialized = true;
            }
            Decimal left = 5.0;
            
            AnotoXmlGeneration.Widget objectivew = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, wrapper.Objective.Id );
                    objectivew.WriteEnabled = false;
                    objectivew.Layout(page, top, left, 10.0, 300.0); 
                    objectivew.DefaultValue = 'Objective: ' + wrapper.Objective.Description__c;
                    anoto.Widgets.Add(objectivew);
            for(Date day:getDaysOfWeek()){
                
                // this represents 1 day of output
                // boxes start on x coordinates: 7.5, 18.3, 28.2, 37.4
                // first row starts on y coordinate 55
                // box size should be about 11.3x7.1 (wxh)
                if (wrapper.ResultsMap.get(day).Day__c == day){
                    AnotoXmlGeneration.Widget datew = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 
                                                                                    new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,null).NodeName);
                    datew.WriteEnabled = false;
                    datew.Layout(page, top + 3.5, left, 10.0, 35.0); 
                    datew.FontSize = 6;
                    datew.DefaultValue = DateTime.newInstance(day, Time.newInstance(0,0,0,0)).format('MMM dd - E');
                    anoto.Widgets.Add(datew);

                    AnotoXmlGeneration.Widget bkg = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.image, 
                                                                                       new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Bkg').NodeName);
                    bkg.DefaultValue = background;
                    bkg.Layout(page, top - 1 , left, 23.0, 39.0); 
                    anoto.Widgets.Add(bkg);

                    AnotoXmlGeneration.Widget attempts = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 
                                                                                       new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Attempts').NodeName);
                    attempts.Layout(page, top + 15, left, 8.0, 9.5); 
                    attempts.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.numeric;
                    anoto.Widgets.Add(attempts);
                    AnotoXmlGeneration.Widget status = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.boxed, 
                                                                                     new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Status').NodeName); 
                    status.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.upper;
                    status.CharCount = 2;
                    status.Layout(page, top + 15, left + 9.5, 8.0, 9.5);
                    anoto.Widgets.Add(status);
                    AnotoXmlGeneration.Widget met = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.boxed, 
                                                                                  new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Met').NodeName);
                    met.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.upper;
                    met.CharCount = 1;
                    met.Layout(page, top + 15, left + 19.5, 8.0, 6.0); 
                    anoto.Widgets.Add(met);
                    AnotoXmlGeneration.Widget initials = new AnotoXmlGeneration.Widget(AnotoXmlGeneration.WidgetTypeEnum.textfield, 
                                                                                       new SkillTrackingInput.skillResultNodeName(wrapper.Objective.Id, day,'Initials').NodeName);
                    initials.Layout(page, top + 15, left + 26, 8.0, 12.0);
                    initials.RecognitionType = AnotoXmlGeneration.RecognitionTypeEnum.free;
                    anoto.Widgets.Add(initials);
                    if (wrapper.ResultsMap.ContainsKey(day)){
                        Action_Skill_Result__c result = wrapper.ResultsMap.get(day);
                        if (result.Attempts__c != null) {
                            attempts.DefaultValue = result.Attempts__c.format();
                        }
                        if (result.Status__c != null) {
                            status.DefaultValue = result.Status__c;
                        }
                        if (result.Met_Objective__c != null) {
                            met.DefaultValue = result.Met_Objective__c;
                        }
                        if (result.Initials__c != null) {
                            initials.DefaultValue = result.Initials__c;
                        }
                    }
                }
                // next set of boxes start on x coordinate: 46.9, then 84.3, then 123.5, then 161.6, then 198.6, then 234.9
                left += 39.0;
            }
            
            // next week starts on 78.3, same x coordinates
            top += 23;
            if (top > 200){
                page += 1;
                top = headerheight;
                pageinitialized = false;
            }
        }
        return anoto.GenerateDocument();
    }
}