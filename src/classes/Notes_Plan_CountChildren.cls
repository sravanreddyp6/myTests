public class Notes_Plan_CountChildren {
//construct
    public Notes_Plan_CountChildren (){
    
    }
//Do it to it
    public static void buildCount(List<Plan__c> thePlans){
        
    //build a list of IDs to filter children on
        Set<id> PlanIds = new Set<id>();        
            for(Plan__c thisPlan : thePlans)
                {PlanIds.add(thisPlan.id);}

// Lists of children objects that are related to one of the plans in the list the trigger sent
        List<Short_Term_Goal__c> masterListShortTermGoals = [Select id, Plan__c From Short_Term_Goal__c Where Plan__c in :PlanIds];
        List<Objective__c> masterListObjectives = [Select id, Short_Term_Goal__r.Plan__r.id From Objective__c Where Short_Term_Goal__r.Plan__r.id In :PlanIds];
        List<Intervention__c> masterListInterventions = [Select id, Objective__r.Short_Term_Goal__r.Plan__r.id From Intervention__c Where Objective__r.Short_Term_Goal__r.Plan__r.id In :PlanIds];
//create list of all related SAJO Junctions this will get parsed and used in the count loops 
        List<Plan_ServiceAssignment_MJO__c> SAJO = [Select id, recordtype.name, Short_Term_Goal__c, Intervention__c, Objective__c From Plan_ServiceAssignment_MJO__c Where Short_Term_Goal__r.Plan__r.id In :PlanIds];
//the parse will fill these lists
        List<Plan_ServiceAssignment_MJO__c> SaSTG = new List<Plan_ServiceAssignment_MJO__c>();
        List<Plan_ServiceAssignment_MJO__c> SaObj = new List<Plan_ServiceAssignment_MJO__c>();
        List<Plan_ServiceAssignment_MJO__c> SaInt = new List<Plan_ServiceAssignment_MJO__c>();
//Parse the list into the three types        
        for(Plan_ServiceAssignment_MJO__c thisSa: SAJO){
            if(thisSa.RecordType.Name == 'SA-Short-term Goal JO'){SaSTG.add(thisSa);}
            if(thisSa.RecordType.Name == 'SA-Objective JO'){SaObj.add(thisSa);}
            if(thisSa.RecordType.Name == 'SA Intervention JO'){SaInt.add(thisSa);}        
        }
        
//iterate over the plans and get the counts    
        for(Plan__c thisPlan:thePlans){
    try{ 
        //important must =0 because null+ 1 = null
            Integer countSTG = 0;
            Integer countObj = 0;
            Integer countInt = 0;
            Integer countActiveSTG = 0;
            Integer countActiveObj = 0;
            Integer countActiveInt = 0;
            boolean shouldActiveCount = false;
            
            for(Short_Term_Goal__c thisSTG : masterListShortTermGoals ){ 
                if(thisSTG.Plan__c == thisPlan.id ){
                    //prove that this STG has a Service Assignment
                    shouldActiveCount = false;
                    
                        for(Plan_ServiceAssignment_MJO__c thisSa: SaSTG){
                            if(thisSa.Short_Term_Goal__c == thisStg.id){shouldActiveCount=true;}                        
                        }                    
                    if(shouldActiveCount){countActiveSTG += 1;}
                    countSTG += 1;
                }            
            }
            
            for(Objective__c thisObj : masterListObjectives ){
                ID temp = thisObj.Short_Term_Goal__r.Plan__r.id;
                if(temp == thisPlan.id){
                    //prove that this Objective has a Service Assignment
                    shouldActiveCount = false; 
                        for(Plan_ServiceAssignment_MJO__c thisSa: SaObj ){
                            if(thisSa.Objective__c == thisObj.id){shouldActiveCount=true;}                        
                        }                                     
                    if(shouldActiveCount){countActiveObj += 1;}
                    countObj += 1;
                }            
            }
            
            for(Intervention__c thisInt : masterListInterventions ){
                ID temp = thisInt.Objective__r.Short_Term_Goal__r.Plan__r.id;
                if(temp == thisPlan.id){
                    //prove that this Intervention has a Service Assignment
                    shouldActiveCount = false; 
                        for(Plan_ServiceAssignment_MJO__c thisSa: SaInt ){
                            if(thisSa.Intervention__c == thisInt.id){shouldActiveCount=true;}                        
                        }                                    
                    if(shouldActiveCount){countActiveInt += 1;}
                    countInt += 1;
                }            
            }                        
            
         
//countSTG = masterListShortTermGoals.size();
           
            thisPlan.Total_Short_Term_Goals__c = countSTG;
            thisPlan.Total_Objectives__c = countObj;
            thisPlan.Total_Interventions__c = countInt;
            thisPlan.Total_Valid_Short_Term_Goals__c = countActiveSTG;
            thisPlan.Total_Valid_Objectives__c = countActiveObj;
            thisPlan.Total_Valid_Interventions__c = countActiveInt;
            }
    catch (DmlException e) {
        // Process exception here
        thisPlan.addError('a trigger error has occured');
    }               
            
        }
         
        
        
       // update thePlans; 
//        PlanIds = thePlans.getValues();
    }
    
}