public without sharing class Im_EventSummary {
    private Im_Report_Incident cntlr;
    public list<MyRemoteMethods.Im_partyData> invPrties {get; set;}
    
    
        
	public Im_EventSummary(Im_Report_Incident cntlr){
        this.cntlr = cntlr;		
    	
        String file = cntlr.getEventTitle() + '.pdf';
        file = file.replaceAll('[|,||\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ' ');
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="'+file+'"');
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename="'+file+'"');                        

        invPrties = MyRemoteMethods.getInvolvedParties(String.ValueOf(cntlr.eventId));



		
	}

}