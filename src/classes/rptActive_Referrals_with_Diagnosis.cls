public with sharing class rptActive_Referrals_with_Diagnosis {
   // public list <Diagnosis__c> Diags {get; set;}
    public list<rptRow> rptData {get; set;}
    public rptActive_Referrals_with_Diagnosis(){
        //Diags = new list<Diagnosis__c> ();
        rptData = new list<rptRow>();
        runRpt();
    }
    public pageReference runRpt(){
        rptData = new list<rptRow>();
    /*
        list<Person_Being_Referred__c >  activePBRs = [select id, Full_Name__c, 
                                                        Referral__r.name, Age__c, Gender__c, Referral__r.Mobility__c, Referral__r.Assigned_Users__c,  
                                                        Referral__r.Update_Notes__c, Referral__r.Comments__c, 
                                                        Referral__r.Referral_Date__c, Referral__r.Referral_Name__c, Referral__r.Referral_Phone_Number__c, 
                                                        Referral__r.Referral_Status__c
                                                        
                                                        FROM Person_Being_Referred__c  
                                                        WHERE Referral__r.Referral_Status__c != 'Closed'];
        
        */
        /*
        Diags = [select id, Effective_Date__c,
                    ICD__r.Name, ICD__r.Icd_Description__c,    
                    PBR__r.Full_Name__c, 
                    PBR__r.Referral__r.name, PBR__r.Age__c, PBR__r.Gender__c, PBR__r.Referral__r.Mobility__c, PBR__r.Referral__r.Assigned_Users__c,  
                    PBR__r.Referral__r.Update_Notes__c, PBR__r.Referral__r.Comments__c, 
                    PBR__r.Referral__r.Referral_Date__c, PBR__r.Referral__r.Referral_Name__c, PBR__r.Referral__r.Referral_Phone_Number__c, 
                    PBR__r.Referral__r.Referral_Status__c                     
                        From Diagnosis__c
                        WHERE PBR__r.Referral__r.Referral_Status__c != 'Closed'];
                        
        */  
        
        list<referral__c> refs = [select id, Name, Mobility__c, Assigned_Users__c, 
                                    Update_Notes__c, Comments__c, Referral_Date__c, Referral_Name__c, 
                                    Referral_Phone_Number__c, Referral_Status__c,
                                        Person_Being_Referred__r.Full_Name__c, Person_Being_Referred__r.Age__c, Person_Being_Referred__r.Gender__c,
                                        Person_Being_Referred__r.id
                                            FROM Referral__c
                                            WHERE Referral_Status__c != 'Closed' ORDER BY Person_Being_Referred__r.Full_Name__c];               
        set<id> PBRids = new set<id>();
        
        for (Referral__c ref: refs){        
            PBRids.add(ref.Person_Being_Referred__r.id);        
        }
        
        list<Diagnosis__c> diags = [select id, name ,Effective_Date__c, ICD__r.Name, ICD__r.Icd_Description__c, PBR__c from Diagnosis__c where PBR__c in : PBRids ORDER BY ICD__r.Name];
        
        
        for (Referral__c ref: refs){        
            for(Diagnosis__c diag: diags){
                if(ref.Person_Being_Referred__r.id == diag.PBR__c){
                    rptRow row = new rptRow();       
                    row.ref = ref;               
                    row.Diag = diag;
                    rptData.add(row);
                }
            }
            
            
        }        
        
        
        return null;
    }
    
    
    public class rptRow{
        public Referral__c ref {get; set;}
        public Person_Being_Referred__c PBR {get; set;}
        public Diagnosis__c Diag {get; set;}
        public rptRow(){
            Diag = new Diagnosis__c ();
            PBR = new Person_Being_Referred__c ();
            ref = new Referral__c ();
        }
    
    
    
    
    }
}