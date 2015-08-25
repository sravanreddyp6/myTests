public with sharing class AdmissionValidation {

    private boolean m_isExecuting = false;

    public AdmissionValidation(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Admission__c[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
            Admission__c[] theseAdms = (Admission__c[])newObjects;
            
            string admIdsToLimitServAssignQuery;
        
       
       
        
       validateAdmissions(theseAdms);
        
    }

    public void OnAfterInsert(Admission__c[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnBeforeUpdate(Admission__c[] oldObjects, Admission__c[] updatedObjects, Map<Id,Admission__c> newObjMap){
        // BEFORE UPDATE LOGIC
            Admission__c[] theseAdms = (Admission__c[])updatedObjects;
            
            string admIdsToLimitServAssignQuery;
            
                        
            validateAdmissions(theseAdms);

        

    }

    public void OnAfterUpdate(Admission__c[] oldObjects, Admission__c[] updatedObjects, Map<Id,Admission__c> newObjMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Admission__c[] ObjectsToDelete, Map<Id,Admission__c> oldObjMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Admission__c[] deletedObjects, Map<Id,Admission__c> oldObjMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Admission__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }

    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
    
    public static void validateAdmissions(list<Admission__c> admits ){
        
            set<id> pbsInScope = new set<id>();
            for(Admission__c a: admits){
                pbsInScope.add(a.Person_Being_Served__c);
            }
            
            // SELECT ALL ADMISSIONS FOR THE PERSONS BEING SERVED
            List<Admission__c> allAdmissionsForPersons = new List<Admission__c>();
            allAdmissionsForPersons = [SELECT Id, name, Status__c, Admission_Effective_DateTime__c, Discharged_Date_Time__c, Effective_Date__c, Discharged_Date__c, Person_Being_Served__c, State__c FROM Admission__c WHERE Person_Being_Served__c = :pbsInScope];
            System.Debug('What is in allAdmissionsForPersons: ' + allAdmissionsForPersons);
            
            
            // SELECT ALL SERVICE ASSIGNMENTS FOR THE ADMISSIONS
            List<Service_Assignment__c> allSAs = new List<Service_Assignment__c>();
            allSAs = [SELECT Id, name, Start_Date__c, SA_Start_DateTime__c,  End_Date__c, Admission__c, Status__c FROM Service_Assignment__c WHERE Admission__c IN :admits];
            System.Debug('What is in allServAssigns?: ' + allSAs);
                        
            
        // START: PREVENT NEW ADMISSION IF OTHER ADMISSIONS FOR PERSON BEING SERVED LACK DISCHARGE DATE
        // Only prohibit the user to create an admission if a current admission does not have the "Discharged Date" complete and the 
        // admission is related to a Person Being Served that has a Mailing State of either "FL" or "NC" and a Network Offering=ARY.
        // 08/2013 - rule applies for all states and network offerings
        
            Boolean newAdmAllowed = true;
        
            for(Admission__c a: admits){
                    for(Admission__c anAdm2: allAdmissionsForPersons){                        
                        //make sure that there are no other active admits
                        if(a.id != anAdm2.id && anAdm2.Status__c == 'Active' && a.Status__c =='Active'){
                            newAdmAllowed = false;
                            a.addError('This Admission can not be set to Active until there are no other Active Admissions for this PBS (see ' + anAdm2.Name + ')');
                        }
                        
                    }// end loop over all admits               
            }// end loop over triger admits
            
            //adm.Admission_Effective_DateTime__c.date()
        
            for(Admission__c tAdmit: admits){
                        datetime curStart = tAdmit.Admission_Effective_DateTime__c;
                        datetime curEnd = tAdmit.Discharged_Date__c;    
                    //Start: Prevent Admission date overlapping             	
                    for(Admission__c allAdmit: allAdmissionsForPersons){
                        datetime prevStart = allAdmit.Admission_Effective_DateTime__c;
                        datetime prevEnd = allAdmit.Discharged_Date__c;
                        
                        if(tAdmit.id != allAdmit.id){
                            if( (curStart >= prevStart) && ( curStart <= prevEnd ) ){                                
                                tAdmit.addError( 'This Admission is within the date range of another Admission (see '+ allAdmit.Name + ').  Please correct the timing so Admissions do not overlap');
                            }
                            
                        }
                    }
                    //prevent start dates from being before SA start dates
                    for(Service_Assignment__c sa : allSAs){
                    	if(sa.Admission__c == tAdmit.id && sa.SA_Start_DateTime__c < curStart){
                    		tAdmit.addError('Admission Effective Date can not be before any Service Assignments Start Date (see ' + sa.name + ')');
                    	}
                    	
                    }
            }           
            
                    
        // START: FORCE SA CLOSURES BEFORE ADM DISCHARGE
            // This code prevents saving of an admission with status of 'Discharged' if there are
            // active Service Assignments associated with the admission.
        
            for(Admission__c thisAdm : admits){
            
                Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm = new Map<Id, Service_Assignment__c>();
            
                for(Service_Assignment__c sAs : allSAs){
                    if(sAs.Admission__c == thisAdm.Id){
                        mapOfAllServAssignsThisAdm.put(sAs.Id, sAs);
                    }
                }
            
                System.Debug('What is in :mapOfAllServAssignsThisAdm ' + mapOfAllServAssignsThisAdm);       
                
                Boolean weHaveAnActiveServAssignForThisAdm = false;
                
                for(Id servAssignsToCheck : mapOfAllServAssignsThisAdm.keySet()){
                    System.Debug('What is in servAssignsToCheck: ' + servAssignsToCheck);
                    if(mapOfAllServAssignsThisAdm.get(servAssignsToCheck).Status__c == 'Active'){
                        weHaveAnActiveServAssignForThisAdm = true;
                    }
                }
                
                
                if(thisAdm.Status__c == null || thisAdm.Status__c <> 'Discharged'){
                    // DO NOTHING
                }
                else if(thisAdm.Status__c == 'Discharged' && weHaveAnActiveServAssignForThisAdm == true){
                        thisAdm.addError('You have attempted to discharge an admission with one or more active service assignments associated. Please check the Status value(s) of the associated service assignment(s) and adjust as needed.');
                }
                
            }
        // END: FORCE SA CLOSURES BEFORE ADM DISCHARGE
        // START:  PREVENT SA CUTOFF
            // This method essentially checks to see if an Admission's discharge date being saved is before any end dates for Service Assignments
            // associated with the Admission.
            
            for(Admission__c thisAdm2 : admits){
            
                Map<Id, Service_Assignment__c> mapOfAllServAssignsThisAdm2 = new Map<Id, Service_Assignment__c>();
            
                for(Service_Assignment__c sAs2 : allSAs){
                    if(sAs2.Admission__c == thisAdm2.Id){
                        mapOfAllServAssignsThisAdm2.put(sAs2.Id, sAs2);
                    }
                }
            
                System.Debug('What is in :mapOfAllServAssignsThisAdm2 ' + mapOfAllServAssignsThisAdm2);
                
                Datetime highestServAssignEndDate;
                
                for(Id servAssignsToCheck2 : mapOfAllServAssignsThisAdm2.keySet()){
                    System.Debug('What is in servAssignsToCheck2: ' + servAssignsToCheck2);
                    System.Debug('What is in mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c: ' + mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
                    if(highestServAssignEndDate == NULL){
                        System.Debug('NULL CHECK EXECUTED!');
                        highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
                    }
                    else if(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c > highestServAssignEndDate){
                        System.Debug('DATE CHECK EXECUTED!');
                        highestServAssignEndDate = date.valueOf(mapOfAllServAssignsThisAdm2.get(servAssignsToCheck2).End_Date__c);
                    }
                    System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
                }
                
                System.Debug('What is in highestServAssignEndDate: ' + highestServAssignEndDate);
                
                if(thisAdm2.Discharged_Date__c == null){
                    // DO NOTHING
                }
                else{
                    if(thisAdm2.Discharged_Date__c < highestServAssignEndDate){
                        thisAdm2.addError('You have attempted to discharge an admission with a discharge date prior to the end date for a service assignment associated with the admission. Please check the end dates of the associated service assignments and adjust as needed.  The last service assignment end date for this admission is currently ' + highestServAssignEndDate);
                    }
                }
            }       
            
        // END: PREVENT SA CUTOFF                   
    }
}