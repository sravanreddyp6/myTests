public with sharing class stubController {
	
	public stubController(Apexpages.StandardController controller){
		
		
	}
	
	public stubController(){
		
		
	}
	
	public static Boolean showdiagModal { get; set; }
    public string diagEditId {get; set; }
    
    public Boolean newDiagnosis{ get; set;} // comment after release
   
   public Boolean showDiagnosis { get {
    	//Returning a dummy value. Commented for easy deployment - Will delete after the release - Sravan - 11/13/2015
       /* if (! psetFlags ) {
            psetFlags = setShowFlags();
        }
        return pshowDiag;*/
        return false; 
    }}
    
    
    public list<Diagnosis__c> diagnoses{get; set;}

    public Diagnosis__c diag {
        get {
            if (diag == null)
                diag = new Diagnosis__c();
            return diag;
        }
        set;
    }
    
    public void showAddDiagnosis() {
       /* newDiagnosis = true;
        showdiagModal = true;
        diag = new Diagnosis__c();
        System.Debug('showdiagModal='+ showdiagModal);*/
    }

    public void showEditDiagnosis() {
       /* showdiagModal = true;
        System.Debug('showdiagModal=' + showdiagModal);*/
    }

    public void saveDiagnosis() {
       /* Boolean foundDiag = false;
        Diagnosis__c dgnew = this.diag;
        System.debug('dgnew: ' + dgnew);
        // if this diagnosis contains an ID, look for it to update
        if ( diagnoses != null ) {
            for ( Diagnosis__c dg : diagnoses ) {
                if ( dg.Id != null && dg.Id == dgnew.Id ) {
                    // update in place
                    dg.Effective_Date__c = dgnew.Effective_Date__c;
                    dg.Axis_I__c = dgnew.Axis_I__c;
                    dg.Axis_II__c = dgnew.Axis_II__c;
                    dg.Axis_III__c = dgnew.Axis_III__c;
                    dg.Axis_IV__c = dgnew.Axis_IV__c;
                    dg.Axis_V__c = dgnew.Axis_V__c;
                    dg.Primary_Diagnosis__c = dgnew.Primary_Diagnosis__c;
                    dg.Secondary_Diagnosis__c = dgnew.Secondary_Diagnosis__c;
                    dg.Level_of_Disability__c = dgnew.Level_of_Disability__c;
                    dg.Comments__c = dgnew.Comments__c;
                    system.debug('updating ' + dg.Id + ', ' + dgnew);
                    foundDiag = true;
                    break;
                }
            }
        }
        if ( !foundDiag )
            this.diagnoses.add(dgnew);

        this.diag= new Diagnosis__c();
        //newDiagnosis = false;*/
    }

    public void refreshDiagnoses() {
        // requery the diagnosis list
     /*   diagnoses = [select id, Service_Assignment__r.Name, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c, Effective_Date__c, Comments__c from Diagnosis__c where Service_Assignment__c = :currentID order by createddate desc];
        newDiagnosis = false;*/

    }

    public void createDiagnoses() {
       /* if (diagnoses != null && this.theServAssign.Id != null) {
            for (Diagnosis__c dg : diagnoses ) {
                dg.Service_Assignment__c = this.theServAssign.Id;
            }
            System.Debug('DIAG LIST = ' + diagnoses);
            upsert diagnoses;
        }*/

    } 
    
      @RemoteAction
    public static Diagnosis__c loadDiagnosis(string diagnosisId) {
        /*Diagnosis__c dg =
                [select Id, Effective_Date__c, Axis_I__c, Axis_II__c, Axis_III__c, Axis_IV__c, Axis_V__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Level_of_Disability__c, Comments__c, Service_Assignment__c
                 from Diagnosis__c where id = :diagnosisId];
        system.debug('LOD:' + dg.Level_Of_disability__c);
        return dg;*/
        return new Diagnosis__c();
    }


    @RemoteAction
    public static boolean saveSingleDiagnosis (string diagId, long effDate, string axisI, string axisII, string axisIII, string axisIV, string axisV, string primDiag, string secondDiag, string lod, string comments, string saID) {
        /*Diagnosis__c dg;
        ID newID;
        if (diagId == '') {

            dg = new Diagnosis__c ( Effective_Date__c = datetime.newInstance(effDate), Axis_I__c = axisI, Axis_II__c = axisII, Axis_III__c = axisIII, Axis_IV__c = axisIV, Axis_V__c = axisV, Primary_Diagnosis__c = primDiag, Secondary_Diagnosis__c = secondDiag, Level_of_Disability__c = lod, Comments__c = comments, Service_Assignment__c = saID );
        }
        else {

            dg = [select Id, Effective_Date__c, Axis_I__c, Axis_II__c, Axis_III__c, Axis_IV__c, Axis_V__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Level_of_Disability__c, Comments__c, Service_Assignment__c
                  from Diagnosis__c where id = :diagId];

            dg.Effective_Date__c = datetime.newInstance(effDate);
            dg.Axis_I__c = axisI;
            dg.Axis_II__c = axisII;
            dg.Axis_III__c = axisIII;
            dg.Axis_IV__c = axisIV;
            dg.Axis_V__c = axisV;
            dg.Primary_Diagnosis__c = primDiag;
            dg.Secondary_Diagnosis__c = secondDiag;
            dg.Level_of_Disability__c = lod;
            dg.Comments__c = comments;
            dg.Service_Assignment__c = saID;
            system.debug('updating ' + dg.Id + ', ' + dg);
        }

        upsert dg;
        return true;*/
        return false;
    } 
    
    
    //FROM PBS EDIT CONTROLLER
     public string loadThisDiag {get; set;} // comment after dec23 release- sravan
    
    //Remove this method after Dec-23 release
    public PageReference loadDiagnosis(){
       /* for(Diagnosis__c dg : diagnosis){
            if(dg.id == loadThisDiag){
                diag = dg;
            }
        }*/
        return null;
    }
    
    //end
    
    public list<Diagnosis__c> diagnosis{get{
    	//Sravan - Commented this code for ease of deployment. Shoould remove the property after Dec 23, 2015 release
        /*return [select id, Status__c, ICD__c, Type__c, Service_Assignment__r.Name, Service_Assignment__c, Primary_Diagnosis__c, Secondary_Diagnosis__c, Axis_I__c,Axis_II__c,Axis_III__c,Axis_IV__c,Axis_V__c, Effective_Date__c, Comments__c from Diagnosis__c where Service_Assignment__r.Admission__r.Person_Being_Served__c=:Apexpages.currentpage().getparameters().get('Id')];*/
        return null;
    } set;}

}