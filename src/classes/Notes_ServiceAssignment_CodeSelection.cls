public with sharing class Notes_ServiceAssignment_CodeSelection {

    public String SelectedProgram {get; set;}
    public String SelectedServiceLine {get; set;} 
       
    public List<SelectOption> MyPrograms = new List<SelectOption>();
    public List<SelectOption> getMyPrograms (){return MyPrograms;}
    
    //the get for locations is below
    public List<ServiceAssignment_ServiceCode_JO__c> CurrentCodes = new List<ServiceAssignment_ServiceCode_JO__c>();    
    
    public ID currentID {get; set;}
    public string currentState{ get; set;}
    public Service_Assignment__c currentRecord {get; set;}
    public Set<ID> SelectedCodeIDs = new Set<ID>();
    //for adding new JOs  
    public ID SelectedCodeID {get; set;}
    //for removing JOs
    public ID SelectedJoID {get; set;}
    //boolean for filtering on assessment only service codes
    public boolean AssessmentOnly {get; set;}
    
    public Notes_ServiceAssignment_CodeSelection(ApexPages.StandardController controller) {
         
        LoadData((Service_Assignment__c)Controller.getRecord());
    }
    
    public void LoadData(Service_Assignment__c localRecord){
       currentID = localRecord.Id;
       currentRecord = [Select Program__c, RecordType.Name, Service_Line__c, Admission__r.State__c From Service_Assignment__c Where Id = :currentID Limit 1];
       currentState = currentRecord.Admission__r.State__c;
       AssessmentOnly = False;
       IF(currentRecord.RecordType.Name == 'Assessment Only')
           {AssessmentOnly = True;}
        
            
        for(ServiceAssignment_ServiceCode_JO__c local : [Select id, Code_Selection_txt__c, Service_Code__r.id From ServiceAssignment_ServiceCode_JO__c Where Service_Assignment__r.Id = :currentId Order By Code_Selection_txt__c]){
           // MyServiceCodes.add(local)
           
            SelectedCodeIDs.add(local.Service_Code__r.id);
        }   
              
       Set<String> tmpProgs = new Set<String>(); 
       
           for(Service_Code__c local : [Select Program__c From Service_Code__c where state__c = :currentState ]){
               tmpProgs.Add(Local.Program__c);           
           }

           SelectOption SOtmp = new SelectOption('', '--None--');
           MyPrograms.Add(SOtmp);
            
            for(String local : tmpProgs){                                   
                SelectOption SO = new SelectOption(local, local);
                MyPrograms.Add(SO);
            }
            
    }
    //these are for selection
    public List<Service_Code__c> MyServiceCodes = new List<Service_Code__c>();
    public List<Service_Code__c> getMyServiceCodes  (){        
        currentRecord = [Select Program__c, Service_Line__c, Location_Region__c From Service_Assignment__c Where Id = :currentID  Limit 1];
        return [Select Id, Service_Code__c, Service_Value__c, Start_Date__c, End_Date__c From Service_Code__c 
            Where Program__c = :currentRecord.Program__c
            	AND
        	isActive__c = 1 
                AND 
            Service_Line__c = :currentRecord.Service_Line__c 
                AND
            Location__c= :currentRecord.Location_Region__c 
                AND
            Assessment_Only__c = :AssessmentOnly
                AND                  
            id NOT IN :SelectedCodeIDs
            	AND
            state__c = :currentState
                         
                Order By Service_Value__c];    
    }    
    
    public List<SelectOption> MyLocations = new List<SelectOption>();
    public List<SelectOption> getMyLocations (){
        MyLocations.clear();
        Set<String> tmpLocs = new Set<String>();     
        SelectOption SOtmp = new SelectOption('', '--None--');
        MyLocations.Add(SOtmp);
           for(Service_Code__c local : [Select Location__c From Service_Code__c 
                   Where Program__c = :currentRecord.Program__c
                       AND
                   Assessment_Only__c = :AssessmentOnly
                   AND
            		state__c = :currentState]
            ){
               
                       tmpLocs.Add(Local.Location__c);           
           }            
            
            for(String local : tmpLocs){                                   
                SelectOption SO = new SelectOption(local, local);
                MyLocations.Add(SO);
            }        
        
        return MyLocations;
    }

    
    public List<SelectOption> MyServiceLines = new List<SelectOption>();
    public List<SelectOption> getMyServiceLines() {
        MyServiceLines.clear();
        SelectOption SOtmp = new SelectOption('', '--None--');
        MyServiceLines.Add(SOtmp); 
        Set<String> tmpLocs = new Set<String>();
        
        for(Service_Code__c local : [Select Location__c, Service_Line__c From Service_Code__c 
                                        Where Program__c = :currentRecord.Program__c 
                                            AND 
                                        Location__c = :currentRecord.Location_Region__c
                                            AND
                                        Assessment_Only__c = :AssessmentOnly 
                                        AND
            							state__c = :currentState            ]){
           tmpLocs.Add(local.Service_Line__c);           
        }
        for(String local : tmpLocs){
            SelectOption SO = new SelectOption(local, local);
            MyServiceLines .Add(SO);
        }
            
        return MyServiceLines;
    }  
       
    
    
    public List<ServiceAssignment_ServiceCode_JO__c> getCurrentCodes(){
            CurrentCodes.clear();
            for(ServiceAssignment_ServiceCode_JO__c local : [Select id, Code_Selection_txt__c, Service_Code__r.Start_Date__c, Service_Code__r.End_Date__c, Service_Code__r.id From ServiceAssignment_ServiceCode_JO__c Where Service_Assignment__r.Id = :currentId Order By Code_Selection_txt__c]){
               // MyServiceCodes.add(local);
                CurrentCodes.add(local);
                SelectedCodeIDs.add(local.Service_Code__r.id);
            }        
        
        return CurrentCodes;
    }
    public PageReference DeleteCodeJO(){
        ServiceAssignment_ServiceCode_JO__c CodeJO = new ServiceAssignment_ServiceCode_JO__c();
        CodeJO = [Select ID, Service_Code__r.id From ServiceAssignment_ServiceCode_JO__c Where Id = :SelectedJoID Limit 1];   
        SelectedCodeIDs.remove(CodeJO.Service_Code__r.id);     
        Delete CodeJO;
        return null;
    }
    public PageReference CreateCodeJO(){
        ServiceAssignment_ServiceCode_JO__c CodeJO = new ServiceAssignment_ServiceCode_JO__c();
        CodeJO.Service_Assignment__c = currentID;
        CodeJO.Service_Code__c = SelectedCodeID;
        SelectedCodeIDs.add(SelectedCodeID);
        insert CodeJO;
        return null;
    } 
   
}