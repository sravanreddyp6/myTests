public with sharing class AvatarBillingReport_ProgNotesLiteForMD {
    public Date fStartDate{get{return fStartDate;} set;}
    public Date fEndDate{get{return fEndDate;} set;}
    public integer allCount{get; set;}    
	public transient List<ProgNotesModel> pNotesWithPlaceholder {get; set;}
		  
	public AvatarBillingReport_ProgNotesLiteForMD () {
	       allCount=0;
    } 	  

   public PageReference runReport(){
        if(fEndDate < fStartDate){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date must be before the End Date'); 
            ApexPages.addMessage(myMsg);            
            return null;
        }

        Datetime startdt = DateTime.newInstance( fStartDate, Time.newInstance(0,0,0,0));
        Datetime enddt = DateTime.newInstance ( fEndDate, Time.newInstance(23, 59, 59, 999));

		List<Progress_note__c>  progressNotesMD = [ Select	Date_of_Service_String__c, Auth_Service_Code__c, Program_Code__c, Staff_Employee_ID__c, Billing_ID__c, Service_Assignment__r.Episode__c,
									Blank__c, Blank2__c, Total_Time__c, Location_Type_AZ_Report_Map__c, BlankUnits__c, Blank4__c, Blank5__c, Blank6__c, Blank7__c, Blank8__c,
									Blank9__c, Blank10__c, Blank11__c, Start_Time_Only__c, End_Time_Only__c, Blank_Cost__c, Primary_Care_Provider_Name__c, 
									Primary_Care_Provider_NPI_Number__c, NAME, Service_Assignment__r.Program__c, Service_Assignment__r.Service_Line__c, CreatedBy.Name,
									Program_Detail__c, Approval_Status_Date__c, Purpose_Service_is_Billable__c, Disregard_Note__c, Notes_Sequence_Identifier__c, Date_of_Service__c,Person_Being_Served__c 
							  from  progress_note__c
							 Where  Service_code__r.Service_Code__c = '100'
							   And  Purpose_Service_is_Billable__c = true
						  	   And  Status__c = 'Final'
						  	   And  Start_Time__c >= :startdt
						  	   And  End_Time__c <= :enddt
							  Order By Person_Being_Served__c, Start_Time__c Asc];

		Map<String, ProgNotesModel> mapProgNotesModels = new Map<String, ProgNotesModel>();
		List<ProgNotesModel> ProgNotesModels = new List<ProgNotesModel>();
		for(Progress_note__c pn : progressNotesMD){			
			ProgNotesModel placeHoderModel = new ProgNotesModel(pn.id, pn.Date_of_Service_String__c, pn.Auth_Service_Code__c, pn.Program_Code__c, pn.Staff_Employee_ID__c, pn.Billing_ID__c, pn.Service_Assignment__r.Episode__c,
									pn.Total_Time__c, pn.Location_Type_AZ_Report_Map__c, pn.BlankUnits__c, pn.Start_Time_Only__c, pn.End_Time_Only__c, pn.Blank_Cost__c, pn.Primary_Care_Provider_Name__c, 
									pn.Primary_Care_Provider_NPI_Number__c, pn.NAME, pn.Service_Assignment__r.Program__c, pn.Service_Assignment__r.Service_Line__c, pn.CreatedBy.Name,
									pn.Program_Detail__c, getDateString(pn.Approval_Status_Date__c), pn.Purpose_Service_is_Billable__c, pn.Disregard_Note__c, pn.Notes_Sequence_Identifier__c, pn.Date_of_Service__c,pn.Person_Being_Served__c);
									
			ProgNotesModel.setBlanks(placeHoderModel, pn.Blank__c, pn.Blank2__c,pn.Blank4__c, pn.Blank5__c, pn.Blank6__c, pn.Blank7__c, pn.Blank8__c, pn.Blank9__c, pn.Blank10__c, pn.Blank11__c);
			ProgNotesModels.add(placeHoderModel);
			mapProgNotesModels.put(placeHoderModel.Date_of_Service_String + placeHoderModel.Person_Being_Served, placeHoderModel);
			
		} 
        allCount = ProgNotesModels.size();

            
        pNotesWithPlaceholder = new List<ProgNotesModel>();
        ProgNotesModel placeHolderPN;
        Date weekStart;
            
		Iterator<ProgNotesModel> pnIterator = ProgNotesModels.iterator();
        
        while (pnIterator.hasNext()){
        	ProgNotesModel progNote =  pnIterator.next();
        	if (progNote.isProcessed) continue;
        	
        	weekStart = progNote.Date_of_Service.toStartofWeek();
        	integer pnDayAfterWeekStart = weekStart.daysBetween(progNote.Date_of_Service);
        	            				
        	if (pnDayAfterWeekStart >= 0 && (progNote.Notes_Sequence_Identifier == null || progNote.Notes_Sequence_Identifier == '')){
				for(integer i=0; i<7; i++){
            		if(progNote.Date_of_Service.isSameDay(weekStart.addDays(i))){
            				pNotesWithPlaceholder.add(progNote);
            				progNote.isProcessed = true;
           			}else if(mapProgNotesModels.get(getDateString(weekStart.addDays(i)) + progNote.Person_Being_Served)!= null && !mapProgNotesModels.get(getDateString(weekStart.addDays(i)) + progNote.Person_Being_Served).isProcessed){
           				pNotesWithPlaceholder.add(mapProgNotesModels.get(getDateString(weekStart.addDays(i)) + progNote.Person_Being_Served));
           				mapProgNotesModels.get(getDateString(weekStart.addDays(i)) + progNote.Person_Being_Served).isProcessed = true;
           			}
            		else {
	            			placeHolderPN = progNote.placeHolderClone(getDateString(weekStart.addDays(i)));
	            			pNotesWithPlaceholder.add(placeHolderPN);
           			}
            	} 
			}
			
			
			if (pnDayAfterWeekStart >= 0 && (progNote.Notes_Sequence_Identifier == 'Initial Note')){
				for(integer i=0; i < 7 - pnDayAfterWeekStart ; i++){
            		if(progNote.Date_of_Service.isSameDay(weekStart.addDays(i+pnDayAfterWeekStart))){
            				pNotesWithPlaceholder.add(progNote);
            				progNote.isProcessed = true;
           			}else if(mapProgNotesModels.get(getDateString(weekStart.addDays(i+pnDayAfterWeekStart)) + progNote.Person_Being_Served)!= null && !mapProgNotesModels.get(getDateString(weekStart.addDays(i+pnDayAfterWeekStart)) + progNote.Person_Being_Served).isProcessed){
           				pNotesWithPlaceholder.add(mapProgNotesModels.get(getDateString(weekStart.addDays(i+pnDayAfterWeekStart)) + progNote.Person_Being_Served));
           				mapProgNotesModels.get(getDateString(weekStart.addDays(i+pnDayAfterWeekStart)) + progNote.Person_Being_Served).isProcessed = true;
           			}
            		else {
	            			placeHolderPN = progNote.placeHolderClone(getDateString(weekStart.addDays(i+pnDayAfterWeekStart)));
	            			pNotesWithPlaceholder.add(placeHolderPN);
           			}
            	} 
			}
			
		}
        return null; 
    }


    private string getDateString(Date st) {
       if(st==null) return null;
       integer curr_month = st.month();
       string month_str = '';
       string day_str = '';
       if ( curr_month < 10 )
           month_str = '0';
       integer day = st.day();
       if ( day < 10 )
           day_str = '0';
		return month_str + string.valueOf(curr_month) + day_str + string.valueOf(day ) + string.valueOf(st.year());
    }

}