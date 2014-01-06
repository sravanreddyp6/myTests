trigger SetOwnerFromZipOrState on Prospects__c (before insert) {
 System.Debug('Starting SetOwnerFromZipOrStateTrigger');


// Will hold Zip Code from the Prospect Record
   Set<String> zipCodes = new Set<String>();

// Will hold State from the Prospect Record
   Set<String> States = new Set<String>();

// Will hold ProgramType from the Prospect Record
   Set<String> ProgramTypes = new Set<String>();

// Get the Zip from the Prospect record into the SET
// Get the State from the Prospect record into the SET
// Get the Program from the Prospect record into the SET
   For (Prospects__c P : trigger.new){
      zipCodes.Add(P.Zip__c);
      States.Add(P.State__c);
      ProgramTypes.Add(P.Im_intersted_in_supporting__c);
   }

// Value pair to hold ZIP NAME and Route To ID
   map<String,Id> assignedToByZips = new map<String,Id>();

// Value pair to hold ZIP NAME and Region ID
   map<String,Id> ZipAndRegion = new map<String,Id>();

// Value pair to hold STATE NAME and Route To ID
   map<String,Id> assignedToByStates = new map<String,Id>();

// Value pair to hold STATE NAME and Region ID
   map<String,Id> StateAndRegion = new map<String,Id>();

// Value strings
   string strRegionID;
   string strProgramInterest;
   string strNextUndecidedProgram;
   boolean bSplitState_Undecided;

   strRegionID = '';
   bSplitState_Undecided = FALSE;
   strNextUndecidedProgram = '';

   if(ProgramTypes.contains('Children and Adolescents')){
      strProgramInterest = 'ARY';
      }
    else if(ProgramTypes.contains('Adults with intellectual/developmental disabilities')){
      strProgramInterest = 'IDD';
      }
    else {     // if(ProgramTypes.contains('Undecided')){
      strProgramInterest = 'Undecided';
    }

// Get Zip and Next Route To ID from the Zip Code Lookup table based on the zip of the Prospect
// and according Program Type
   For(Zip_Codes__c z : [Select Name, RegionID__c, Route_To_ARY_Next__c, Route_To_IDD_Next__c, Route_To_Undecided_Next__c,
       Split_State__c, Route_To_Region_IDD_RegionID__c, Route_To_Region_IDD_Next__c, Route_To_Undecided_Split__c   // these last three fields for split states
       from Zip_Codes__c where Name in : zipCodes]) {

       if (z.Split_State__c == 0) {
          if(strProgramInterest == 'ARY'){
             assignedToByZips.put(z.Name, z.Route_To_ARY_Next__c);
          }
          else if(strProgramInterest == 'IDD'){
             assignedToByZips.put(z.Name, z.Route_To_IDD_Next__c);
          }
          else {
             assignedToByZips.put(z.Name, z.Route_To_Undecided_Next__c);
          }
          strRegionID = z.RegionID__c;
          }
       else {
          // Processing for Split State
          if(strProgramInterest == 'ARY'){
             assignedToByZips.put(z.Name, z.Route_To_ARY_Next__c);       // use primary region, same as above
             strRegionID = z.RegionID__c;
          }
          else if(strProgramInterest == 'IDD'){
             assignedToByZips.put(z.Name, z.Route_To_Region_IDD_Next__c);  // use IDD Region record
             strRegionID = z.Route_To_Region_IDD_RegionID__c;
          }
          else {
            bSplitState_Undecided = TRUE;
            // System.Debug('Split: ' + z.Route_To_Undecided_Split__c);

            if(z.Route_To_Undecided_Split__c == 'ARY') {
               assignedToByZips.put(z.Name, z.Route_To_ARY_Next__c);     // use primary region, same as above
               strRegionID = z.RegionID__c;
               strNextUndecidedProgram = 'ARY';
            }
            else {
               assignedToByZips.put(z.Name, z.Route_To_Region_IDD_Next__c);
               strRegionID = z.Route_To_Region_IDD_RegionID__c;          // use IDD Region record
               strNextUndecidedProgram = 'IDD';
            }
          }
       }
   }

// Get Zip and Region ID from the Zip Code Lookup table based on the zip of the Prospect
   For(Zip_Codes__c z : [Select Name, RegionID__c, Split_State__c, Route_To_Region_IDD_RegionID__c, Route_To_Undecided_Split__c  from Zip_Codes__c where Name in : zipCodes]) {
       // Add Zip Code Name and Region to the Zips MAP
       // Not a split state or accesing the Primary/ARY Region
       if ((z.Split_State__c == 0)|| (strProgramInterest == 'ARY')) {
          ZipAndRegion.put(z.Name, z.RegionID__c);
          strRegionID = z.RegionID__c;
       }
       else if (strProgramInterest == 'IDD') {
          ZipAndRegion.put(z.Name, z.Route_To_Region_IDD_RegionID__c);
          strRegionID = z.Route_To_Region_IDD_RegionID__c;
       }
       // This is a split state and ARY is next
       else if(z.Route_To_Undecided_Split__c == 'ARY') {
          ZipAndRegion.put(z.Name, z.RegionID__c);
          strRegionID = z.RegionID__c;
          strNextUndecidedProgram = 'ARY';
       }
       // This is a split state and IDD is next
       else {
          ZipAndRegion.put(z.Name, z.Route_To_Region_IDD_RegionID__c);
          strRegionID = z.Route_To_Region_IDD_RegionID__c;
          strNextUndecidedProgram = 'IDD';
       }
   }

// Get the State and Next Route To ID from the Region Table based on the States SET
// and according to Program Type
   For(Region__c z : [select State__c, Type__c,  RegionID__c,
       Route_To_ARY_Next__c, Route_To_IDD_Next__c, Route_To_Undecided_Next__c
       from Region__c where State__c in : States]) {
       if(z.Type__c == 'State') {
          if(strProgramInterest == 'ARY'){
            assignedToByStates.put(z.State__c, z.Route_To_ARY_Next__c);
          }
          else if(strProgramInterest == 'IDD'){
            assignedToByStates.put(z.State__c, z.Route_To_IDD_Next__c);
          }
          else {
            assignedToByStates.put(z.State__c, z.Route_To_Undecided_Next__c);
          }
          if (strRegionID == '') {
            strRegionID = z.RegionID__c;
          }
       }
    }

// Get the State and Region ID from the Region Table based on the States SET
   For(Region__c z : [select State__c, ID, Type__c from Region__c where State__c in : States]) {
       if(z.Type__c == 'State'){
          StateAndRegion.put(z.State__c, z.ID);
          if (strRegionID == '') {
            strRegionID = z.RegionID__c;
          }
       }
    }

// Update Last Route To with Route To just used, according on Program Type
   For (Region__c R : [Select Route_To_ARY_Last__c, Route_To_IDD_Last__c, Route_To_Undecided_Last__c,
        Route_To_ARY_Inc__c, Route_To_IDD_Inc__c, Route_To_Undecided_Inc__c,
        Last_Undecided_Date__c
        from Region__c where ID = :strRegionID]) {
        if(strProgramInterest == 'ARY'){
           R.Route_To_ARY_Last__c = R.Route_To_ARY_Inc__c;
        }
        else if(strProgramInterest == 'IDD'){
           R.Route_To_IDD_Last__c = R.Route_To_IDD_Inc__c;
        }
        else if (bSplitState_Undecided == FALSE) {
           R.Route_To_Undecided_Last__c = R.Route_To_Undecided_Inc__c;
        }

        // for undecided on split states
        else if(strNextUndecidedProgram == 'ARY'){
           R.Route_To_ARY_Last__c = R.Route_To_ARY_Inc__c;
        }
        else if(strNextUndecidedProgram == 'IDD'){
           R.Route_To_IDD_Last__c = R.Route_To_IDD_Inc__c;
        }


        // If this was in a split state and user was Undecided, update either the ARY or IDD record, Last Date used
        if(bSplitState_Undecided == TRUE){
           // Update the Date used
           R.Last_Undecided_Date__c = datetime.now();
        }

        update R;
    }

   System.debug('assignedToByZips: ' + assignedToByZips);
// Logic to set the owner of the record properly
   For (Prospects__c p : trigger.new) {
        if(assignedToByStates.get(p.State__c) != Null && p.Entry_Point__c == 'Web') {
            p.OwnerID = assignedToByStates.get(p.State__c);
            p.Routed_To__c = assignedToByStates.get(p.State__c);
            p.Region__c = StateAndRegion.get(p.State__c);
            p.Program__c = strProgramInterest;
            }
        if(assignedToByZips.get(p.Zip__c) != Null && p.Entry_Point__c == 'Web'){
            p.ownerID = assignedToByZips.get(p.Zip__c);
            p.Routed_To__c = assignedToByZips.get(p.Zip__c);
            p.Region__c = ZipAndRegion.get(p.Zip__c);
            p.Program__c = strProgramInterest;
        }
    }
}