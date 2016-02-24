public with sharing class referral_attachment_rpt {

    public date StartDate {get; set;}
    public date EndDate {get; set;}

	public List<Attachment> filelist { get; set; }    
	public integer numfiles { get { return filelist.size(); } set; }
    public referral_attachment_rpt () {
        filelist = new List<Attachment>();
    }

	private string objType;
	private string nameMatch;

    public pagereference runReport(){
    
    	// get hidden url inputs - used for debugging
    	objType = ApexPages.currentPage().getParameters().get('objType');
    	nameMatch = ApexPages.currentPage().getParameters().get('nameMatch');
    
    	// for NEVAL-72, restrict to referrals
    	if (String.isBlank(objType)) {
    		// get the object prefix for referrals
    		Schema.DescribeSObjectResult r = Referral__c.sObjectType.getDescribe();
			objType = 'Referral';
		} else if ( objType == 'all') {
			objType = '%';
		} else {
			objType += '%';
		}
    	
    	// for NEVAL-72, restrict to files starting with POC only
    	if (String.isBlank(nameMatch)) {
    		nameMatch = 'PlanOfCare%';
    	} else if ( nameMatch == 'all') {	// leave this in for debugging the front-end - allows you to get all files
    		nameMatch = '%';
    	} else {
    		nameMatch += '%';
    	}    		

       boolean inputErr = false;
       ApexPages.getMessages().clear();
       
       system.debug( 'sd=' + startDate + ', ed=' + endDate + ', type=' + objType + ', name=' + nameMatch );
       
       if(startDate == null || endDate == null   ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       } else if ( startDate > endDate ) {
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please choose valid start and end dates');
                    ApexPages.addMessage(myMsg);
                    inputErr = true;
       }
       if ( inputErr ) {
			return null;
       }
		
			
//       hasRunOnce = true;
       TimeZone zone = UserInfo.getTimeZone();
       datetime startDateTime = StartDate;
       if(startDateTime !=null){startDateTime = startDateTime.addSeconds((zone.getOffset(startDateTime)/1000)*-1);}
       
       datetime endDateTime = endDate;
       if(endDateTime !=null){
           endDateTime = endDateTime.addSeconds((zone.getOffset(endDateTime)/1000)*-1);
           endDateTime = endDateTime.addDays(1);
           endDateTime = endDateTime.addseconds(-1);
       }

		filelist = [ select id, name, parentid, parent.name, createdbyid, createdby.name, createddate 
					from attachment 
					where createddate >= :StartDate 
					and createddate <= :EndDate 
					and name like :nameMatch
					and parent.type like :objType
					];
		                      	
        return null;
    }


}