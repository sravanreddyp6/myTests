public with sharing class Assessment_Smoking_Form {
    public list<Eval__c> EvalQuestions {get; set;}
    public Evaluation__c theAssessment {get; set;}
    public string SAid {get{ 
        if(theAssessment.id != null )
            return theAssessment.ServiceAssignment__c;
         return ApexPages.currentPage().getParameters().get('saID');
         } set;}
    public string PBSid {get{
        return SA.Person_Being_Served__c;
    
    } set;}
    public string AdmId {get{ return SA.Admission__c;} set;}
    public Service_Assignment__c SA {get; set;}
    public List<SelectOption> getBasicOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));
        options.add(new SelectOption('1','Yes'));
        options.add(new SelectOption('0','No'));
        return options;
    }
    
    public map<string, QandA> mapEvalQ {get; set;}    
    public Assessment_Smoking_Form(ApexPages.StandardController controller) {
        theAssessment = (Evaluation__c)controller.getRecord();
        if(theAssessment.id ==null)
            theAssessment.Status__c = 'Inactive Draft';
            SA = [select ID, Person_Being_Served__c, Person_Being_Served__r.name, Admission__c, Admission__r.State__c, Name from service_assignment__c where id = :SAid];
            
		list<string> IgnoreQuestions = new list<string>();
		if(SA.Admission__r.State__c == 'MN'){
			IgnoreQuestions.add('smoker');
			IgnoreQuestions.add('wishtoSmoke');
			IgnoreQuestions.add('smokeSupervision');
			IgnoreQuestions.add('smokeAssistance');
			IgnoreQuestions.add('smokealongFamily');
			IgnoreQuestions.add('storeSmokeStaff');
			IgnoreQuestions.add('smokingApron');
			
			
		}
        EvalQuestions = [select id, name, visibility_rules__c, visibility_row_rules__c, 
            Field_Name__c, Field_Sequence__c, Field_Type__c, Field_Sub_Type__c,  
            Eval_Type__c, Composite__c, htmlid__c
                from Eval__c 
                    where Sub_Category__c = 'Smoking Assessment' 
                    AND Visible__c = true 
                    AND Field_Name__c != 'Blank Space' 
                    AND Field_Type__c !='Hidden'
                    AND htmlid__c NOT IN :IgnoreQuestions
                     Order By Field_Sequence__c];
            mapEvalQ = new map<string, QandA>();
            
            for(Eval__c item: EvalQuestions){
                mapEvalQ.put(item.htmlid__c, new QandA(item) );
            }
            if(theAssessment.id != null){
                for(Eval_Value__c item: [select id, name, Text_Under_250__c, Eval__r.htmlid__c from Eval_Value__c where What_ID__c = :theAssessment.id]){
                    mapEvalQ.get(item.Eval__r.htmlid__c).theValue = item;
                }
            }
                   //ServiceAssignment__c 
     
    }
    public PageReference mySave(){
    	Evaluation__c orgEval = theAssessment.clone();
        Savepoint sp = Database.setSavepoint();
        try{
            if(theAssessment.id == null){
                theAssessment.ServiceAssignment__c = SA.id;
                theAssessment.RecordTypeID = utility.getEValuationRecordType('Smoking Assessment');
                
            }
            theAssessment.RecordTypeID = utility.getEValuationRecordType('Smoking Assessment');
            theAssessment.Status__c = 'Inactive Draft';
            theAssessment.name = 'Smoking Assessment - ' + SA.Person_Being_Served__r.name + ' - Inactive Draft';
            upsert theAssessment;
            list<Eval_Value__c > answers = new list<Eval_Value__c >();
            list<string> errors = new list<string>();            
            /*
            boolean smoker = false;
            boolean smokeInFac = false;            
            for(string item: mapEvalQ.keySet() ){
                if( mapEvalQ.get(item).theEval.htmlid__c=='smoker' && mapEvalQ.get(item).theValue.Text_Under_250__c == '1' ){
                    smoker = true;
                }
                if( mapEvalQ.get(item).theEval.htmlid__c=='wishtoSmoke' && mapEvalQ.get(item).theValue.Text_Under_250__c == '1' ){
                    smokeInFac  = true;
                }                                
            }

            for(string item2: mapEvalQ.keySet() ){
                boolean addError = false;
                if(smoker && mapEvalQ.get(item2).theEval.htmlid__c !='smoker' ){
 
                    if(mapEvalQ.get(item2).theEval.htmlid__c == 'wishtoSmoke' && string.isBlank(mapEvalQ.get(item2).theValue.Text_Under_250__c) ){
                        addError = true;                                              
                    }
                        //#2 = yes
                        if(smokeInFac && mapEvalQ.get(item2).theEval.htmlid__c != 'wishtoSmoke' && string.isBlank(mapEvalQ.get(item2).theValue.Text_Under_250__c)){  
                            addError = true;                      
                        }
                        //#2 = no
                        if( !smokeInFac && mapEvalQ.get(item2).theEval.htmlid__c != 'wishtoSmoke' ){    
                            mapEvalQ.get(item2).theValue.Text_Under_250__c='';                       
                        }                   
                }

                if(addError){
                    errors.add(mapEvalQ.get(item2).theEval.Field_Name__c + ' is required');
                }
                

                answers.add( mapEvalQ.get(item2).theValue );                
            } 
            if(smoker ){
                 //   ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.FATAL, 'test');
                 //   ApexPages.addMessage(myMsg2);                      
                 }
            
            */
            
            for(string item2: mapEvalQ.keySet() ){
                boolean addError = false; 
                    if(string.isBlank(mapEvalQ.get(item2).theValue.Text_Under_250__c) ){
                        addError = true;                                              
                    }                 

                if(addError){
                    errors.add(mapEvalQ.get(item2).theEval.Field_Name__c + ' is required');
                }
                

                answers.add( mapEvalQ.get(item2).theValue );                
            } 
                        
			if(errors.size() > 0){
                for(string err: errors){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, err);
                    ApexPages.addMessage(myMsg);
                }
                    Database.rollback(sp);
                    theAssessment = orgEval.clone();
                    return null;                    
            }                        
                        
            for(Eval_Value__c a: answers){
                a.Eval_Section_Id__c = 'Smoking Assessment';
                a.Eval_Section_Type__c = 'Smoking Assessment';
                a.What_ID__c = theAssessment.id;
                a.What_ID_Object__c = 'Evaluation__c';

            }
            for(Eval_Value__c a: answers){
                //if()
            }    
            upsert answers;
        
        
        }
        catch(DmlException e){
            Database.rollback(sp);
           	theAssessment = orgEval.clone();   
            
        }

            PageReference pageRef = new PageReference('/apex/Assessment_Smoking_Form?id=' + theAssessment.id);
            pageRef.setRedirect(true);
            return pageRef;
    }
    public PageReference Disregard(){
        return null;
    }  
    public PageReference Revise(){
        Savepoint sp = Database.setSavepoint();
        try{
            Evaluation__c  newAssessment = theAssessment.Clone();
            newAssessment.Status__c = 'Inactive Draft';
			newAssessment.name = 'Smoking Assessment - ' + SA.Person_Being_Served__r.name + ' - Inactive Draft';
            insert newAssessment;
            
            list<Eval_Value__c > newAnswers = new list<Eval_Value__c >();
            for(string item: mapEvalQ.keySet() ){
                Eval_Value__C newA = mapEvalQ.get(item).theValue.Clone();
                newA.What_Id__c = newAssessment.id; 
                newA.Eval_Section_Id__c = 'Smoking Assessment';
                newA.Eval_Section_Type__c = 'Smoking Assessment';
                newA.What_ID_Object__c = 'Evaluation__c';
                newAnswers.add(newA);               
            }
            insert newAnswers;
            
            theAssessment.Status__c = 'Inactive Final';
            theAssessment.name = 'Smoking Assessment - ' + SA.Person_Being_Served__r.name + ' - Inactive Final';
            update theAssessment;
                    
            PageReference pageRef = new PageReference('/apex/Assessment_Smoking_Form?id=' + newAssessment.id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        catch(DmlException e){              
            Database.rollback(sp);
        }            
        
        return null;
    }     
    public PageReference Finalize(){
        Savepoint sp = Database.setSavepoint();
        try{
            if(theAssessment.id == null){
                theAssessment.ServiceAssignment__c = SA.id;
                
            }
            	theAssessment.name = 'Smoking Assessment - ' + SA.Person_Being_Served__r.name + ' - Active Final';
                theAssessment.Status__c = 'Active Final';
                upsert theAssessment; 
            }
        catch(DmlException e){              
            Database.rollback(sp);
        }               
        return null;
    }       
    public PageReference myCancel(){
            PageReference pageRef = new PageReference('/apex/ServiceAssignmentEditNew?id=' + SAid);
            pageRef.setRedirect(true);
            return pageRef;
    } 
    public class QandA{
        public Eval__c theEval {get; set;}
        public Eval_Value__c theValue {get; set;}
        public QandA(Eval__c Q){
            theEval = Q;
            theValue = new Eval_Value__c();
            theValue.Eval__c = q.id;

        }
    
    }
}