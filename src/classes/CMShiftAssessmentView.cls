public with sharing class CMShiftAssessmentView {
    public Evaluation__c evaluation { get; set; }
    public ApexPages.standardController stdController;
    public String selectedTab { get; set; }

    public List<selectOption>copingValues;
    public List<string>selectedCoping { get; set; }
    public List<selectOption>neuroOrientValues;
    public List<string>selectedNeuroOrient{ get; set; }
    public List<selectOption>moodValues;
    public List<string>selectedMoods { get; set; }
    public List<SelectOption>breatheSounds;
    public List<string>selectedSounds { get ; set; }
    public List<SelectOption>DysreflexiaValues;
    public List<string>selectedDysreflexia { get ; set; }
    public transient Map<String, Component.Apex.OutputPanel> ctlMap { get; set; }
    
    public Evaluation_Response__c[] annotations { set;
        get {
            return [
                SELECT ID, Annotation_Height__c, Annotation_Width__c,
                       Annotation_X__c, Annotation_Y__c, Annotation_Source__c,
                       Annotation_Shape__c, Annotation_Text__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                 AND RecordType.Name='Annotation'
            ];
        }
    }
    
    public Evaluation_Response__c[] signatures { set;
    	get{
    		return [
    			SELECT Id, Name, CreatedDate, Owner.Name, Owner.Id 
    						FROM Evaluation_Response__c WHERE RecordType.Name = 'E-Signature' AND Evaluation__c = :this.evaluation.Id
    						order BY CreatedDate Desc
    		];
    	}
 		
    }
    
    public String baseUrl {
        get {
            return System.URL.getSalesforceBaseURL().toExternalForm();
        }
    }

    public Evaluation_Response__c[] pains {
        get {
            if (pains == null) {
                pains = [
                    SELECT ID, Initial_Pain_Level__c, Narrative_Note__c,
                           Follow_up_Pain_Level__c, Follow_up_Effectiveness__c,
                           Time_Observed__c
                    FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                    AND RecordType.Name='Pain'
                ];
            }
            return pains;
        }
        set;
    }
    public List<String> painSliderOptions {
        get {
            if (painSliderOptions == null) {
                painSliderOptions = new String[] {
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'
                };
            }
            return painSliderOptions;
        }
        set;
    }

    public string getprimaryPhysician(){
        List<Related_Party__c> rp = [SELECT Id, Name FROM Related_Party__c WHERE Person_Being_served__c=:this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__c AND Type__c='Physician - Primary' order by LastModifiedDate desc LIMIT 1];
        if(rp.size()>0) return rp[0].Name;
        else return null;
    }

    public Evaluation_Response__c[] vitals { set;
        get {
            return [
                SELECT ID,Name,Date__c,Heart_Rate__c,Blood_Pressure__c,R__c,O2_Saturation__c,Temperature__c,O2_Intervention_Needed__c,O2_Narrative_Note__c,
                       HR_Intervention_Needed__c, HR_Narrative_Note__c
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                AND RecordType.Name='Vitals Details Shift Assessment'
            ];
        }
    }
    
    public Evaluation_Response__c[] pUlcers { set;
        get {
            return [
                SELECT ID,Decubity_Stage__c,Location__c, Decubity_Measurement__c,Treatment__c,Date__c 
                FROM Evaluation_Response__c WHERE Evaluation__c=:evaluation.Id
                AND RecordType.Name='Pressure Ulcer Detail'
            ];
        }
    }
    
    public Evaluation_Response__c currentpUlcerDetail {get ; set;}
    public Id currentpUlcerDetailId {get; set; }

    public CMShiftAssessmentView(Apexpages.StandardController stdcontroller){
	  	this.stdController = stdcontroller;
    	Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Evaluation__c.fields.getMap();
    	
        if (!Test.isRunningTest()) {
            List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects(new List<String>{ 'Evaluation__c' });
            Schema.DescribeSObjectResult info = describelist[0];
            Map<string,Schema.SObjectField> fmap = info.fields.getmap();
            stdcontroller.addFields(new List<String>(fmap.keySet()));
        }
      
        evaluation = (Evaluation__c) stdController.getRecord();
        selectedTab = ApexPages.currentPage().getParameters().get('tab');
        copingValues = new List<selectOption>();
        selectedCoping = new List<String>();
        neuroOrientValues = new List<selectOption>();
        selectedNeuroOrient = new List<string>();
        moodValues = new List<selectOption>();
        selectedMoods = new List<String>();
        breatheSounds = new List<SelectOption>();
        selectedSounds = new List<String>();
        DysreflexiaValues = new List<SelectOption>();
        selectedDysreflexia = new List<String>();

		currentVitalsDetail = new Evaluation_Response__c();
        currentpUlcerDetail = new Evaluation_Response__c();
        
        if(!String.isBlank(this.evaluation.Resident_Demonstrating_Issues__c))
            selectedCoping = this.evaluation.Resident_Demonstrating_Issues__c.split(';');

        if(!String.isBlank(this.evaluation.Orientation__c))
            selectedNeuroOrient = this.evaluation.Orientation__c.split(';');

        if(!String.isBlank(this.evaluation.Mood__c))
            selectedMoods = this.evaluation.Mood__c.split(';');

        if(!String.isBlank(this.evaluation.Breathe_sounds__c))
            selectedSounds = this.evaluation.Breathe_Sounds__c.split(';');

        if(!String.isBlank(this.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c))
            selectedDysreflexia = this.evaluation.Autonomic_Dysreflexia_Areas_Assessed__c.split(';');
            
        ctlMap = CreateFieldControls( stdController.getRecord().getSObjectType().getDescribe().getName(), stdController );
        
        // Naming the PDF in case this controller is used for the PDF page
        String file;
        file = this.evaluation.Name+'.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        // Assigns the Shift Assessment Name to the PDF dynamically. Doesn't work with Chrome when Adboe Reader plugin is enabled. Sravan:01/05/2015 4:15 PM
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename="'+file+'"');
    
    }

    public Evaluation_Response__c currentVitalsDetail {get; set; }
    public Id currentVitalsDetailId { get; set; }

    public pageReference finalizeEval() {
        this.evaluation.Status__c = 'Final';
        update this.evaluation;
        
        //Close out the task created for this Assessment
        List<Task> checkNotification = [SELECT ID, WhatId, Status FROM Task WHERE WhatId=:this.evaluation.Id AND Status != 'Completed' LIMIT 1];
        if(checkNotification.size() > 0) {
        	Task t = checkNotification[0];
        	t.Status = 'Completed';
        	update t;
        }
        pageReference backtoView = new pageReference('/apex/CMShiftAssessmentView?id='+this.evaluation.Id);
        backtoview.setRedirect(true);
        return backtoView;
    }

    public pageReference disregardEval() {
        this.evaluation.status__c = 'Disregard';
        update this.evaluation;
        //Close out the task created for this Assessment
        List<Task> checkNotification = [SELECT ID, WhatId, Status FROM Task WHERE WhatId=:this.evaluation.Id AND Status != 'Completed' LIMIT 1];
        if(checkNotification.size() > 0) {
        	Task t = checkNotification[0];
        	t.Status = 'Completed';
        	update t;
        }
        pageReference backtoView = new pageReference('/apex/CMShiftAssessmentView?id='+this.evaluation.Id);
        backtoview.setRedirect(true);
        return backtoView;
    }

    public void showAddVitalsDetail()  {
        this.currentVitalsDetail = new Evaluation_Response__c();
        this.currentVitalsDetail.Evaluation__c = this.evaluation.Id;
        this.currentVitalsDetail.RecordTypeId = Utility.getEvaluationResponseRecordType('Vitals Details Shift Assessment');

    }

    public void showEditVitalsDetail() {
        this.currentVitalsDetail = [
            SELECT ID, Name, Date__c, Temperature__c, R__c, O2_Saturation__c, Blood_Pressure__c,
                   Heart_Rate__c, HR_Intervention_Needed__c, HR_Narrative_Note__c, O2_Intervention_Needed__c, O2_Narrative_Note__c
            FROM Evaluation_Response__c WHERE ID=:currentVitalsDetailId
        ];
    }

    public void saveVitalsDetail() {
        try {
            upsert currentVitalsDetail;
        } catch (DMLException ex) {
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }
	
	 public void showAddpUlcerDetail()  {
        this.currentpUlcerDetail = new Evaluation_Response__c();
        this.currentpUlcerDetail.Evaluation__c = this.evaluation.Id;
        this.currentpUlcerDetail.RecordTypeId = Utility.getEvaluationResponseRecordType('Pressure Ulcer Detail');

    }

    public void showEditpUlcerDetail() {
        this.currentpUlcerDetail = [
            SELECT ID,Decubity_Stage__c,Location__c, Decubity_Measurement__c,Treatment__c,Date__c
            FROM Evaluation_Response__c WHERE ID=:currentpUlcerDetailId
        ];
    }

    public void savepUlcerDetail() {
        try {
            upsert currentpUlcerDetail;
        } catch (DMLException ex) {
            // SF will automatically create a PageMessage Error here, so we don't
            // have to do anything
        }
    }
    
  public pageReference updateshiftTime() {

      try{
      	  String pbsLastName = this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__r.LastName != null ? this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__r.LastName : '' ;
    	  string pbsFirstinitial = this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__r.FirstName != null ? this.evaluation.ServiceAssignment__r.Admission__r.Person_Being_Served__r.FirstName.Substring(0,1) : '';
    	  string ownerfirstInitial = this.evaluation.Owner.FirstName != null ? this.evaluation.Owner.FirstName.Substring(0,1) : ''; 
    	  this.evaluation.Name = pbsFirstinitial+'. '+pbsLastName+' - '+evaluation.Shift_Start_time__c.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString())+' - NSD - '+ownerfirstInitial+'. '+this.evaluation.Owner.LastName;
      	 
      	  update this.evaluation;
      	  
      	  PageReference pr = new PageReference('/apex/CMShiftAssessmentView?id='+this.evaluation.Id);
      	  pr.setRedirect(true);
      	  return pr;
      }
      catch (DMLException e) {
         throw new MyException('Shift time Cannot be updated',e); 
      }

    return null;
  }
  
 public List<selectoption> getcopingValues(){
    List<Selectoption> copingValue = Utility.getPicklistValues(evaluation, 'Resident_Demonstrating_Issues__c');
    return copingValue;
	}

    public List<selectoption> getneuroOrientValues(){
        List<Selectoption> orientValue = Utility.getPicklistValues(evaluation, 'Orientation__c');
        return orientValue;
    }

    public List<selectoption> getmoodValues(){
        List<Selectoption> moodValue = Utility.getPicklistValues(evaluation, 'Mood__c');
        return moodValue;
    }

    public List<SelectOption> getbreatheSounds(){
        List<Selectoption> breatheSound = Utility.getPicklistValues(evaluation, 'Breathe_Sounds__c');
        return breatheSound;

    }

    public List<SelectOption> getDysreflexiaValues(){
        List<Selectoption> DysreflexiaValue = Utility.getPicklistValues(evaluation, 'Autonomic_Dysreflexia_Areas_Assessed__c');
        return DysreflexiaValue;

    }
    
    public Map<String, Component.Apex.OutputPanel> CreateFieldControls ( string classname, ApexPages.StandardController controller ) {
        System.Debug('loading map for:' + classname);
        Map<String, Component.Apex.OutputPanel> cmap = new Map<String, Component.Apex.OutputPanel>();

        List<Schema.DescribeSObjectResult> describelist = Schema.describeSObjects( new List<String>{classname});
        if (describelist.size() == 0){
            return null;
        }

        // need to get value for all fields - they are not in scope from VF page being dynamic
        Schema.DescribeSObjectResult info = describelist[0];
        Map<string,Schema.SObjectField> fmap = info.fields.getmap();

        Schema.DescribeFieldResult fielddescribe;
        ID theID = controller.getID();
        String query = 'SELECT ' +  String.Join(New List<String>(fmap.keyset()), ', ') + ' FROM ' + className + ' Where ID = :theID';
        system.debug( query );
        SObject fullobj  = Database.query(query);

        for(string fieldname:fmap.keyset()){
            Component.Apex.OutputPanel op = new Component.Apex.OutputPanel();

            fielddescribe = fmap.get(fieldname).getdescribe();

            try {
                Component.Apex.OutputLabel outLbl = new Component.Apex.OutputLabel( value=fielddescribe.getLabel(), styleClass='label');
                op.childComponents.Add( outLbl);
                Component.Apex.OutputField outFld = new Component.Apex.OutputField();
                outFld.expressions.value = '{!' + classname + '.' + fieldname +'}';
                op.childComponents.Add( outFld);
                cmap.put( fieldname, op);
            }
            catch( Exception e) {
                System.Debug( e );
            }
        }
        return cmap;
    }
    
    public class MyException extends Exception {}
    
   @RemoteAction
   public static boolean finddupeEval(string shiftStart, string shiftEnd, Id saId, Id currentEvalId) {
   		system.debug('I am remoting');
   		system.debug(shiftStart);
   		system.debug('CurrentEvalID   '+currentEvalId);
   		DateTime st = Datetime.parse(shiftStart);
   		DateTime en = Datetime.parse(shiftEnd);
   		boolean dupefound = false;
   		List<Evaluation__c> dupeEval = [SELECT Id, Name, Shift_Start_time__c, Shift_end_time__c FROM Evaluation__c WHERE ServiceAssignment__c = :saId AND (
        					(Shift_Start_time__c >= :st and Shift_Start_time__c <= :en)
        				or 	(Shift_end_time__c >= :st and Shift_end_time__c <= :en)
        				or  ( Shift_Start_time__c <= :st and Shift_end_time__c >= :en )) AND RecordType.Name = 'CMShiftAssessment' AND Status__c !='Disregard' AND Id != :currentEvalId LIMIT 1];
        				
   		system.debug('dupe++++'+dupeEval);
   		if(dupeEval.size() >0 ) {
   			dupeFound = true;
   		}
   	
   		return dupeFound;
   }


}