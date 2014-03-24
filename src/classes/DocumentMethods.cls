public class DocumentMethods {
	
	public enum Quarter { 
		ONE, 
		TWO, 
		THREE, 
		FOUR 
	}
		
		
	public static void ChangeDueFrom(Service_Assignment__c theServAssign, Id newOwnerId) {
		
		theServAssign.DocDueFromPerson__c = newOwnerId;
		
		List<ServiceAssignment_Document_JO__c> listOfXrefsToChangeDueFroms = new List<ServiceAssignment_Document_JO__c>();
		List<ServiceAssignment_Document_JO__c> listOfXrefsReadyToUpdate = new LIst<ServiceAssignment_Document_JO__c>();
		
		listOfXrefsToChangeDueFroms = [ SELECT Id, Name, Due_From_Employee__c, File_Status__c FROM ServiceAssignment_Document_JO__c
											WHERE Service_Assignment__c = :theServAssign.Id
												AND File_Status__c = 'Not Filed' ];
		
		for(ServiceAssignment_Document_JO__c x : listOfXrefsToChangeDueFroms) {
			x.Due_From_Employee__c = newOwnerId;
			listOfXrefsReadyToUpdate.add(x);
		}
		
		update listOfXrefsReadyToUpdate;
		
	}


///////////////////
///////////////////
///////////////////

// CASE:  If docPop is called with only a list of Service Assignments.
	public static void docPop(Service_Assignment__c[] theServAssigns) {
		Service_Assignment__c theServAssign = new Service_Assignment__c();
		for(Service_Assignment__c sA : theServAssigns) {
    		theServAssign = sA;
    		docPop(theServAssign);
    	}		
	}
	
// CASE:  If docPop is called for what used to be the addDoc and updateDoc methods.  If a single
// document is being added or updated.	
	public static void docPop(Service_Assignment__c[] theServAssigns, String action) {
		ServiceAssignment_Document_JO__c dxref = new ServiceAssignment_Document_JO__c();
		Date fixedDueDate;
		Boolean addDoc = false;
		Boolean updateDoc = false;
		Boolean updateAll = false;
		if(action=='updateDoc') {
			updateDoc = true;
		}
		if(action=='addDoc') {
			addDoc = true;
		}
		if(action=='updateAll') {
			updateAll = true;
		}
		for(Service_Assignment__c sA : theServAssigns) {
    		docPop(sA,dxref,fixedDueDate,addDoc,updateDoc,updateAll,false);
    	}			
	}

// CASE:  For "clean up" call in DocumentUpdateBatch.cls	
	public static void docPop(Service_Assignment__c[] theServAssigns, Boolean isBatch) {
		ServiceAssignment_Document_JO__c dxref = new ServiceAssignment_Document_JO__c();
		Date fixedDueDate;
		Boolean addDoc = false;
		Boolean updateDoc = false;
		Boolean updateAll = false;
		for(Service_Assignment__c sA : theServAssigns) {
    		docPop(sA,dxref,fixedDueDate,addDoc,updateDoc,updateAll,isBatch);
    	}			
	}
	
//
	public static void docPop(Service_Assignment__c theServAssign) {
		ServiceAssignment_Document_JO__c dxref = new ServiceAssignment_Document_JO__c();
		Date fixedDueDate;
		docPop(theServAssign,dxref,fixedDueDate,false,false,false,false);
	}
	
	
	public static void docPop(Service_Assignment__c theServAssign, String action) {
		ServiceAssignment_Document_JO__c dxref = new ServiceAssignment_Document_JO__c();
		Date fixedDueDate;
		Boolean addDoc = false;
		Boolean updateDoc = false;
		Boolean updateAll = false;
		Boolean isBatch = false;
		if(action=='updateDoc') {
			updateDoc = true;
		}
		if(action=='addDoc') {
			addDoc = true;
		}
		if(action=='updateAll') {
			updateAll = true;
		}
		if(action=='isBatch') {
			isBatch = true;
		}
		docPop(theServAssign,dxref,fixedDueDate,addDoc,updateDoc,updateAll,isBatch);
	}
	

// From ServiceAssignmentValidation...
	public static void docPop(Service_Assignment__c theServAssign, ServiceAssignment_Document_JO__c dxref, Date fixedDueDate, Boolean addDoc, Boolean updateDoc, Boolean updateAll, Boolean isBatch) {
	    
		List<ServiceAssignment_Document_JO__c> sadjsToInsert = new List<ServiceAssignment_Document_JO__c>();
	    Set<ServiceAssignment_Document_JO__c> sadjsToDelete = new Set<ServiceAssignment_Document_JO__c>();
        List<ServiceAssignment_Document_JO__c> sadjsToDeleteList = new List<ServiceAssignment_Document_JO__c>();
        //List<Document_Recipient__c> drsToInsert = new List<Document_Recipient__c>();
        List<Contract_Document_JO__c> contractDocXrefs = new List<Contract_Document_JO__c>();
        List<Program_Document_Xref__c> programDocXrefs = new List<Program_Document_Xref__c>();
        List<Contract_Document_JO__c> contractDocXrefsManualIncludes = new List<Contract_Document_JO__c>();
        List<Program_Document_Xref__c> programDocXrefsManualIncludes = new List<Program_Document_Xref__c>();
        Set<Id> docIdsContractDocXrefDocs = new Set<Id>();
        Set<Id> docIdsProgramDocXrefDocs = new Set<Id>();
        Set<Id> intersectionOfAutoIncludeDocIds = new Set<Id>();
        Set<Id> docIdsContractDocXrefDocsManualIncludes = new Set<Id>();
        Set<Id> docIdsProgramDocXrefDocsManualIncludes = new Set<Id>();
        Set<Id> intersectionOfManualIncludeDocIds = new Set<Id>();
        List<Document__c> tempDocList = new List<Document__c>();
        Set<Document__c> tempDocSet = new Set<Document__c>();
        List<Document__c> docs = new List<Document__c>();
        List<Document__c> docsManualIncludes = new List<Document__c>();
        List<ServiceAssignment_Document_JO__c> listOfPreExistingServAssignDocXrefs = new List<ServiceAssignment_Document_JO__c>();
    	List<Id> listOfContractIds = new List<Id>();
    	List<TMN_Contract__c> listOfContracts = new List<TMN_Contract__c>();
    	List<Contact> pbsOwnerContactList = new List<Contact>();
    	Id pbsOwnerId;
    	Id docOwnerId;
    	List<Admission__c> admList = new List<Admission__c>();
    	Id contactIdFromAdm;
    	List<Contact> listForContactOwnerId = new List<Contact>();
    	Id cAccountId;
    	User contactOwnerUser = new User();
		Date startOfServAssignDocRange = theServAssign.Start_Date__c;
		Date endOfServAssignDocRange;
		// The 2 variables ADDED 10/11/13 TO ALLOW FOR GENERIC CALL TO UPDATED calculateDocRelativeDueDate method.
		ServiceAssignment_Document_JO__c nullDxref = new ServiceAssignment_Document_JO__c();
		Date nullFixedDueDate;
			
		if(theServAssign.End_Date__c==null && theServAssign.Projected_Treatment_End_Date__c==null) {
			endOfServAssignDocRange = startOfServAssignDocRange;
		}
		else if(theServAssign.End_Date__c==null) {
			endOfServAssignDocRange = theServAssign.Projected_Treatment_End_Date__c;
		}
		else {
			endOfServAssignDocRange = theServAssign.Projected_Treatment_End_Date__c;
		}
    	
    	pbsOwnerContactList = [ SELECT OwnerId FROM Contact WHERE Id = :theServAssign.Person_Being_Served__c ];
    	
    	admList = [ SELECT Person_Being_Served__c FROM Admission__c ];
    	
    	for (Admission__c a : admList) {
    		contactIdFromAdm = a.Id;
    	}
	    	
    	listForContactOwnerId = [ SELECT Account.OwnerId FROM Contact WHERE Id = :contactIdFromAdm ];
    	
    	for (Contact c : listForContactOwnerId) {
    		cAccountId = c.Account.Id;
    	}
    	
    	
    	for(Contact c : pbsOwnerContactList) {
    		pbsOwnerId = c.OwnerId;
    	}
    	
    	if(addDoc==true || updateDoc==true) {
    		docOwnerId = dxref.Due_From_Employee__c;
    	}
    	else {
    		docOwnerId = pbsOwnerId;
    	}
    	
    	  
        // Select all cross-references between Contracts and this Service Assignment.
        List<ServiceAssignment_Contract_JO__c> servAssignContractXrefs = [ SELECT Id, Name, Contract__c FROM ServiceAssignment_Contract_JO__c WHERE Service_Assignment__c = :theServAssign.Id ];

        for(ServiceAssignment_Contract_JO__c sAJC : servAssignContractXrefs) {
        	listOfContractIds.add(sAJC.Contract__c);
        }
        
		contractDocXrefs = [ SELECT Id, Name, Document__c, Contract__c FROM Contract_Document_JO__c WHERE Contract__c = :listOfContractIds AND Document__r.Auto_Include__c = true ];
       	programDocXrefs = [ SELECT Id, Name, Document__c FROM Program_Document_Xref__c WHERE Program__c = :theServAssign.Program__c AND Document__r.Auto_Include__c = true ];
       
       	contractDocXrefsManualIncludes = [ SELECT Id, Name, Document__c, Contract__c FROM Contract_Document_JO__c WHERE Contract__c = :listOfContractIds AND Document__r.Auto_Include__c = false ];
       	programDocXrefsManualIncludes = [ SELECT Id, Name, Document__c FROM Program_Document_Xref__c WHERE Program__c = :theServAssign.Program__c AND Document__r.Auto_Include__c = false ];        
        
		listOfPreExistingServAssignDocXrefs = [ SELECT Document__c, File_Status__c, Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c, Relative_Due_Date_Resolved__c, Fixed_Due_Date__c FROM ServiceAssignment_Document_JO__c WHERE Service_Assignment__c = :theServAssign.Id ];
		System.debug('listOfPreExistingServAssignDocXrefs: ' + listOfPreExistingServAssignDocXrefs);

        // Populate a set of AUTO INCLUDE Document IDs expected for this Service Assignment by looping through the lists of Contract / Doc Xrefs and Program / Doc Xrefs created above.
		// We need the INTERSECTION of the IDs for Contract/Doc Xref docs and Program/Doc Xref docs
        	for(Contract_Document_JO__c cdj : contractDocXrefs) {
	            docIdsContractDocXrefDocs.add(cdj.Document__c);
	        }
	        for(Program_Document_Xref__c pdx : programDocXrefs) {
	        	docIdsProgramDocXrefDocs.add(pdx.Document__c);
	        }
	        
	        // Copy the first set into our intersection variable because the retainAll() method for getting the intersection of the two sets 	
	        intersectionOfAutoIncludeDocIds = docIdsContractDocXrefDocs.clone();
	        
	        // Use retainAll() to prune the first set, keeping only items found in the second.
	        intersectionOfAutoIncludeDocIds.retainAll(docIdsProgramDocXrefDocs);
        
                
        // Populate a set of MANUAL INCLUDE Document IDs expected for this Service Assignment by looping through the lists of Contract / Doc Xrefs and Program / Doc Xrefs created above.
		// We need the INTERSECTION of the IDs for Contract/Doc Xref docs and Program/Doc Xref docs.
	        for(Contract_Document_JO__c cdjM : contractDocXrefsManualIncludes) {
	            for(ServiceAssignment_Document_JO__c x : listOfPreExistingServAssignDocXrefs) {
	            	if(x.Document__c==cdjM.Document__c) {
	            		docIdsContractDocXrefDocsManualIncludes.add(cdjM.Document__c);
	            	}
	            }
	        }
	        for(Program_Document_Xref__c pdxM : programDocXrefsManualIncludes) {
	        	for(ServiceAssignment_Document_JO__c x : listOfPreExistingServAssignDocXrefs) {
	        		if(x.Document__c==pdxM.Document__c) {
	        			docIdsProgramDocXrefDocsManualIncludes.add(pdxM.Document__c);
	        		}
	        	}
	        }       
	
 
	        // Copy the first set into our intersection variable because the retainAll() method for getting the intersection of the two sets 	
	        intersectionOfManualIncludeDocIds = docIdsContractDocXrefDocsManualIncludes.clone();
	        
	        // Use retainAll() to prune the first set, keeping only items found in the second.
	        intersectionOfManualIncludeDocIds.retainAll(docIdsProgramDocXrefDocsManualIncludes);
	       
	        // Get the documents (AUTO INCLUDE) that match up with that set of IDs.
			if((addDoc==false && updateDoc==false) || (updateAll==true)) {
				docs = [SELECT Id, Name, Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c, Type__c, Required_From_Date__c, 
						Required_To_Date__c, Active__c 
						FROM Document__c 
						WHERE Id = :intersectionOfAutoIncludeDocIds
						AND Active__c = true
						AND Id IN (SELECT Document__c FROM Contract_Document_JO__c WHERE Contract__r.Status__c IN ('Active','Renewed','Approved'))
						AND Id IN (SELECT Document__c FROM Program_Document_Xref__c WHERE Program__c = :theServAssign.Program__c)
						 ];
				// Creating the fidelityDocs list separately and then adding it to docs gets us around the SOQL restrictions on subquery joins. 
				List<Document__c> fidelityDocs = new List<Document__c>();
				fidelityDocs = 	[SELECT Id, Name, Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c, Type__c, Required_From_Date__c, 
									Required_To_Date__c, Active__c 
									FROM Document__c 
									WHERE Active__c = true
									AND Type__c = 'Fidelity Document'
									AND Id IN (SELECT Document__c FROM Program_Document_Xref__c WHERE Program__c = :theServAssign.Program__c)
								]; 
				docs.addall(fidelityDocs);
			}
			else {
				// For case of addDoc or updateDoc; should be only one document in tempDocs!
				List<Document__c> tempDocs = [SELECT Id, Name, Type__c, Required_From_Date__c, Required_To_Date__c, Active__c 
					FROM Document__c WHERE Id = :dxref.Document__c
					AND Active__c = true
					AND Id IN (SELECT Document__c FROM Contract_Document_JO__c WHERE Contract__r.Status__c IN ('Active','Renewed','Approved'))
					AND Id IN (SELECT Document__c FROM Program_Document_Xref__c WHERE Program__c = :theServAssign.Program__c)
					 ]; 
				// Again, this should be only the one document we expected, so we can override the docs
				// list the relative due date info passed in from the ServiceAssignment_Document_JO__c
				// in the docPop method call.  The fixed due date instances are handled separately
				// below.
				for(Document__c tD : tempDocs) {
					tD.Relative_Due_Date_Units__c = dxref.Relative_Due_Date_Units__c;
					tD.Relative_Due_Date_UOM__c = dxref.Relative_Due_Date_UOM__c;
					tD.Relative_Due_Date_Event__c = dxref.Relative_Due_Date_Event__c;
					docs.add(tD);
				}
			}
			System.debug('What is in docs: ' + docs);
	        // Get the documents (MANUAL INCLUDE) that match up with that set of IDs.
			docsManualIncludes = [SELECT Id, Name, Relative_Due_Date_Units__c, Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c, Type__c, Required_From_Date__c, Required_To_Date__c, Active__c 
									FROM Document__c 
									WHERE Id = :intersectionOfManualIncludeDocIds
									AND Active__c = true ];
	
			// Create list of Fidelity Documents for this Service Assignment
			List<ServiceAssignment_Document_JO__c> fidDocsOnly = [ SELECT Id, Name FROM ServiceAssignment_Document_JO__c WHERE Document__r.Type__c = 'Fidelity Document' AND Service_Assignment__c = :theServAssign.Id ];
			
			if((addDoc==true) && fixedDueDate!=null) {
				ServiceAssignment_Document_JO__c sAdJo = new ServiceAssignment_Document_JO__c(
		        	Document__c = dxref.Document__c,
		        	Service_Assignment__c = theServAssign.Id,
		        	File_Status__c = 'Not Filed',
		        	Fixed_Due_Date__c = fixedDueDate,
		        	Due_From_Employee__c = dxref.Due_From_Employee__c
		        );
	        	sadjsToInsert.add(sAdJo);
	        	
	        	//Document_Recipient__c dr = new Document_Recipient__c(
	        	//	ServiceAssignment_Document_JO__c = sAdJo.Id,
	        	//	Recipient_Location__c = theServAssign.Location_Region__c
	        	//);
	        	//drsToInsert.add(dr);					
			}
			//else if(updateDoc==true && fixedDueDate!=null) {
			if(updateDoc==true && fixedDueDate!=null) {
				for(ServiceAssignment_Document_JO__c dx : listOfPreExistingServAssignDocXrefs) {
					if(dx.Document__c==dxref.Document__c && (dx.File_Status__c=='Not Filed' || dx.File_Status__c==null)) {
						sadjsToDelete.add(dx);
					}	
				}
				ServiceAssignment_Document_JO__c sAdJo = new ServiceAssignment_Document_JO__c(
		        	Document__c = dxref.Document__c,
		        	Service_Assignment__c = theServAssign.Id,
		        	File_Status__c = 'Not Filed',
		        	Fixed_Due_Date__c = fixedDueDate,
		        	Due_From_Employee__c = dxref.Due_From_Employee__c
		        );
	        	sadjsToInsert.add(sAdJo);	
			}
			//else if(updateAll==true && fixedDueDate!=null) {
			if(updateAll==true && fixedDueDate!=null) {
				// If this is an update to all documents kicked off by editing info from
				// DocumentDetails.page, then we have to delete pre-existing Serv Assign / Doc Xrefs
				// before inserting the new ones.
				for(ServiceAssignment_Document_JO__c dx : listOfPreExistingServAssignDocXrefs) {
					if(dx.Document__c==dxref.Document__c && (dx.File_Status__c=='Not Filed' || dx.File_Status__c==null)) {
						sadjsToDelete.add(dx);
					}	
				}				
			}
			//else {
			if((addDoc==true && fixedDueDate==null) || (updateDoc==true && fixedDueDate==null) || updateAll==true 
				|| (addDoc==false && updateDoc==false && updateAll==false && isBatch==false)) {
				System.debug('Section 1 Ran');
					// Loop through list of documents expected for this service assignment.
					for(Document__c d : docs) {
						System.debug('Section 1A Ran');
						System.debug('d.Type__c in Section 1A: ' + d.Type__c);
						System.debug('d.Relative_Due_Date_Units__c: ' + d.Relative_Due_Date_Units__c);
						System.debug('thisDocsRelativeDueDate');
						List<date> thisDocsRelativeDueDates = new List<date>();
						if(d.Type__c=='Case Document') {
							thisDocsRelativeDueDates = calculateDocRelativeDueDate(d, theServAssign, nullDxref, nullFixedDueDate, updateAll, isBatch);
						}
						else {
							thisDocsRelativeDueDates = null;
						}
						
						// START: If this is a Fidelity Document, check to see if there's already a Fidelity Document set.  If no, enter the docs for this
						// Program / Service Line combination. If yes, skip.
						
						if(d.Type__c=='Fidelity Document' && fidDocsOnly.size()==0) {
						        ServiceAssignment_Document_JO__c sAdJo = new ServiceAssignment_Document_JO__c(
						        	Document__c = d.Id,
						        	Service_Assignment__c = theServAssign.Id,
						        	File_Status__c = 'Not Filed',
								    Due_From_Employee__c = pbsOwnerId
						        );
					        	sadjsToInsert.add(sAdJo);
		
							// Document_Recipient__c object intended for supporting external document recipients (those other than the regional case file).
							// Saving this code for future iterations, if that work gets approved.  (J. Gilliam, 10/1/13)
							//
					        //	Document_Recipient__c dr = new Document_Recipient__c(
					        //		ServiceAssignment_Document_JO__c = sAdJo.Id,
					        //		Recipient_Location__c = theServAssign.Location_Region__c
					        //	);
					        //	drsToInsert.add(dr);						
							//
						}
						// END: If this is a Fidelity Document, check to see if there's already a Fidelity Document set.  If no, enter the docs for this
						// Program / Service Line combination. If yes, skip.
						
						
						// This loop should only do something if there is at least one relative due date.
						if(thisDocsRelativeDueDates!=null) {
							System.debug('Section 1B Ran');
							System.debug('thisDocsRelativeDueDates: ' + thisDocsRelativeDueDates);
							for(Date dueDate : thisDocsRelativeDueDates) {
								System.debug('Section 1C Ran');
								Boolean skipInsertingThisDueDate = false;				
	
					        	if(dueDate < d.Required_From_Date__c || dueDate > d.Required_To_Date__c || d.Active__c==false){
					        		System.debug('Section 1D Ran');
					        		skipInsertingThisDueDate = true;
					        	}						
	
								// IF THE DOCUMENT ALREADY HAS AN XREF:
					        	// 1. Create list of relative due dates for the document this loop iteration is an XREF for.
					        	// 2. Check to see if the relative due date of this XREF is in that list.
					        	//    - If YES, then move on without doing anything.
					        	//    - If NO, then add this XREF to the list to DELETE IF it is 'Not File', otherwise skip.
								if(listOfPreExistingServAssignDocXrefs.size()!=0){
									System.debug('Section 1E Ran');
									for(ServiceAssignment_Document_JO__c sadj : listOfPreExistingServAssignDocXrefs) {				        
								    System.debug('Section 2 Ran');    
								        if(sadj.Document__c == d.Id) {
								        	
								        	if(sadj.File_Status__c=='Not Filed') {
								        		System.debug('Section 3 Ran');
								        		sadjsToDelete.add(sadj);
								        		System.debug('DELETING ' + d.Name + '; REL DUE DATE: ' + sadj.Relative_Due_Date_Resolved__c);
								        	}
								        	else if(sadj.Relative_Due_Date_Resolved__c==dueDate || dueDate < d.Required_From_Date__c || dueDate > d.Required_To_Date__c || d.Active__c==false){
								        		skipInsertingThisDueDate = true;
								        	}					        						        	
								        	
								        }
									}
									
									if(skipInsertingThisDueDate==false) {
										System.debug('Section 4 Ran');
										ServiceAssignment_Document_JO__c sAdJo = new ServiceAssignment_Document_JO__c(
								        	Document__c = d.Id,
								        	Service_Assignment__c = theServAssign.Id,
								        	File_Status__c = 'Not Filed',
								        	Relative_Due_Date_Units__c = d.Relative_Due_Date_Units__c,
								        	Relative_Due_Date_UOM__c = d.Relative_Due_Date_UOM__c,
								        	Relative_Due_Date_Event__c = d.Relative_Due_Date_Event__c,
								        	Relative_Due_Date_Resolved__c = dueDate,
								        	Due_From_Employee__c = docOwnerId
								        );
							        	sadjsToInsert.add(sAdJo);
			
										// Document_Recipient__c object intended for supporting external document recipients (those other than the regional case file).
										// Saving this code for future iterations, if that work gets approved.  (J. Gilliam, 10/1/13)
										//				        	
							        	// Document_Recipient__c dr = new Document_Recipient__c(
							        	//	 ServiceAssignment_Document_JO__c = sAdJo.Id,
							        	//	 Recipient_Location__c = theServAssign.Location_Region__c
							        	// );
							        	// drsToInsert.add(dr);
										//
									}
								}
						        else {
						        	if(skipInsertingThisDueDate==false) {
						        		System.debug('Section 5 Ran');
								        ServiceAssignment_Document_JO__c sAdJo = new ServiceAssignment_Document_JO__c(
								        	Document__c = d.Id,
								        	Service_Assignment__c = theServAssign.Id,
								        	File_Status__c = 'Not Filed',
								        	Relative_Due_Date_Units__c = d.Relative_Due_Date_Units__c,
								        	Relative_Due_Date_UOM__c = d.Relative_Due_Date_UOM__c,
								        	Relative_Due_Date_Event__c = d.Relative_Due_Date_Event__c,
								        	Relative_Due_Date_Resolved__c = dueDate,
										    Due_From_Employee__c = docOwnerId
								        );
							        	sadjsToInsert.add(sAdJo);
						        	}
									// Document_Recipient__c object intended for supporting external document recipients (those other than the regional case file).
									// Saving this code for future iterations, if that work gets approved.  (J. Gilliam, 10/1/13)
									//
						        	// Document_Recipient__c dr = new Document_Recipient__c(
						        	//	 ServiceAssignment_Document_JO__c = sAdJo.Id,
						        	//	 Recipient_Location__c = theServAssign.Location_Region__c
						        	// );
						        	// drsToInsert.add(dr);		        	
						        	//
						        }
							}
						}
					}
		//			insert sadjsToInsert;
		//			sadjsToDeleteList.addAll(sadjsToDelete);
		//			delete sadjsToDeleteList;
		//			insert drsToInsert;
		
				if(docsManualIncludes.size() > 0) {
					for(Document__c d : docsManualIncludes) {
						Boolean docHasPreExistingSadjo = false;
						Boolean docHasSadjWithFixedDueDate = false;
						ServiceAssignment_Document_JO__c sadjFromWhichToBuildDates = new ServiceAssignment_Document_JO__c();
						
						for(ServiceAssignment_Document_JO__c sadj : listOfPreExistingServAssignDocXrefs) {
							if(sadj.Document__c == d.Id) {
								docHasPreExistingSadjo = true;
								if(sadj.Fixed_Due_Date__c != null) {
									// THEN I DON'T NEED TO CALCULATE RELATIVE DUE DATES, OR DO ANYTHING ELSE.  JUST KEEP THIS SADJ OBJECT
									docHasSadjWithFixedDueDate = true;
								}
								sadjFromWhichToBuildDates = sadj;	
							}
						}
						
					if(docHasSadjWithFixedDueDate == false) {
						List<date> thisDocsRelativeDueDates = new List<date>();
						if(docHasPreExistingSadjo==false) {
							if(d.Type__c=='Case Document') {
								thisDocsRelativeDueDates = calculateDocRelativeDueDate(d, theServAssign, nullDxref, nullFixedDueDate, updateAll, isBatch);
							}
							else {
								thisDocsRelativeDueDates = null;
							}
						}
						else {
							Document__c docFromSadjo = new Document__c (
								Id = sadjFromWhichToBuildDates.Document__c,
								Relative_Due_Date_Units__c = sadjFromWhichToBuildDates.Relative_Due_Date_Units__c,
								Relative_Due_Date_Uom__c = sadjFromWhichToBuildDates.Relative_Due_Date_Uom__c,
								Relative_Due_Date_Event__c = sadjFromWhichToBuildDates.Relative_Due_Date_Event__c
							);
							if(d.Type__c=='Case Document') {
								thisDocsRelativeDueDates = calculateDocRelativeDueDate(docFromSadjo, theServAssign, nullDxref, nullFixedDueDate, updateAll, isBatch);
							}
							else {
								thisDocsRelativeDueDates = null;
							}
						}				
						// This loop should only do something if there is at least one relative due date.
						for(Date dueDate : thisDocsRelativeDueDates) {
							
							Boolean skipInsertingThisDueDate = false;
							
							if(dueDate < d.Required_From_Date__c || dueDate > d.Required_To_Date__c || d.Active__c==false) {
								skipInsertingThisDueDate = true;
							}
	
				        	// 1. Create list of relative due dates for the document this loop iteration is an XREF for.
				        	// 2. Check to see if the relative due date of this XREF is in that list.
				        	//    - If YES, then move on without doing anything.
				        	//    - If NO, then add this XREF to the list to DELETE IF it is 'Not File', otherwise skip.
						
							for(ServiceAssignment_Document_JO__c sadj : listOfPreExistingServAssignDocXrefs) {        
						        
						        
						        if(sadj.Document__c == d.Id) {
						        	
						        	if(sadj.File_Status__c=='Not Filed') {
						        		sadjsToDelete.add(sadj);
						        	}
						        	else if(sadj.Relative_Due_Date_Resolved__c==dueDate){
						        		skipInsertingThisDueDate = true;
						        	}					        						        	
						        	
						        }
							}
								
							if(skipInsertingThisDueDate==false) {
								ServiceAssignment_Document_JO__c sAdJo = new ServiceAssignment_Document_JO__c(
						        	Document__c = d.Id,
						        	Service_Assignment__c = theServAssign.Id,
						        	File_Status__c = 'Not Filed',
						        	Relative_Due_Date_Units__c = d.Relative_Due_Date_Units__c,
						        	Relative_Due_Date_UOM__c = d.Relative_Due_Date_UOM__c,
						        	Relative_Due_Date_Event__c = d.Relative_Due_Date_Event__c,
						        	Relative_Due_Date_Resolved__c = dueDate,
						        	Due_From_Employee__c = docOwnerId
						        );
					        	sadjsToInsert.add(sAdJo);
								// Document_Recipient__c object intended for supporting external document recipients (those other than the regional case file).
								// Saving this code for future iterations, if that work gets approved.  (J. Gilliam, 10/1/13)
								//					        	
					        	// Document_Recipient__c dr = new Document_Recipient__c(
					        	// 	ServiceAssignment_Document_JO__c = sAdJo.Id,
					        	// 	Recipient_Location__c = theServAssign.Location_Region__c
					        	// );
					        	// drsToInsert.add(dr);
					        	//
							}
						}
					}
				}
			}
		}
		insert sadjsToInsert;
		sadjsToDeleteList.addAll(sadjsToDelete);
		delete sadjsToDeleteList;
		//insert drsToInsert;		
	}


	public static List<date> calculateDocRelativeDueDate(Document__c d, Service_Assignment__c sA, ServiceAssignment_Document_JO__c dxref, Date fixedDueDate, Boolean updateAll, Boolean isBatch) {
			
			date relativeDueDateResolved;
			List<date> relativeDueDateList = new List<date>();
			Integer RelativeDueDateUnits;
			String RelativeDueDateUOM;
			String RelativeDueDateEvent;
			
			if(dxref!=null && dxref.Relative_Due_Date_Units__c!=null && dxref.Relative_Due_Date_UOM__c!=null && dxref.Relative_Due_Date_Event__c!=null) {
				RelativeDueDateUnits = dxref.Relative_Due_Date_Units__c.intValue();
				RelativeDueDateUOM = dxref.Relative_Due_Date_UOM__c;
				RelativeDueDateEvent = dxref.Relative_Due_Date_Event__c;
			}
			else if(d!=null && d.Relative_Due_Date_Units__c!=null && d.Relative_Due_Date_UOM__c!=null && d.Relative_Due_Date_Event__c!=null) {
				RelativeDueDateUnits = d.Relative_Due_Date_Units__c.intValue();
				RelativeDueDateUOM = d.Relative_Due_Date_UOM__c;
				RelativeDueDateEvent = d.Relative_Due_Date_Event__c;				
			}
			else if(fixedDueDate!=null) {
				// DO NOTHING, BUT DON'T THROW AN ERROR; LET THE CODE MOVE ON TO THE CODE BELOW HANDLING FIXED DUE DATE.
			}
			else {
				throw new docException('Error: DocumentMethods.calculateDocRelativeDueDate method; missing Relative Due Date info.  Serv. Assign.: ' + sA + '; Doc: ' + d + '; Dxref Doc Id: ' + dxref);	
			}

			if(fixedDueDate!=null){
				relativeDueDateList.add(fixedDueDate);	
			}
			else {			
				if(RelativeDueDateEvent=='Calendar Month End') {
					
					date endDateToUse;
					// Calculate the last day of the first month based on sA.Start_Date__c:
					Date firstDateOfStartMonth;
					firstDateOfStartMonth = sA.Start_Date__c.toStartOfMonth();
					System.Debug('firstDateOfStartMonth: ' + firstDateOfStartMonth);
					Date firstDateOfSecondMonth;
					firstDateOfSecondMonth = date.newInstance(firstDateOfStartMonth.year(),firstDateOfStartMonth.month()+1,firstDateOfStartMonth.day());
					System.debug('firstDateOfSecondMonth' + firstDateOfSecondMonth);
					Date lastDateOfStartMonth;
					lastDateOfStartMonth = firstDateOfSecondMonth.addDays(-1);
					System.debug('lastDateOfStartMonth: ' + lastDateOfStartMonth);
					Integer numberOfMonthsForDocs;
	
					
					if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c==null){
						if(updateAll!=true && isBatch!=true) {
							sA.addError('Document due dates for this Service Assignment cannot be determined because neither a Projected Treatment End Date or End Date have been entered.  Please enter a value for one of those two date fields, then try to save again.');
						}
						else {
							// DO NOTHING; IF END DATE ISN'T PRESENT FOR A BATCH RUN, WE SHOULD SKIP CREATING DUE DATES WITHOUT THROWING AN ERROR.  updateAll should be true in this method's call only for batch calls.
						}
					}
					else {
						
						if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c!=null) {
							endDateToUse = sA.Projected_Treatment_End_Date__c;					
						}
						else if(sA.End_Date__c!=null) {
							endDateToUse = sA.End_Date__c;
						}
						
						// Generate list of resolved due dates for the document.
						numberOfMonthsForDocs = lastDateOfStartMonth.monthsBetween(endDateToUse);
						System.debug('numberOFMonthsForDocs: ' + numberOfMonthsForDocs);
						Date rollingLastDayOfMonth = lastDateOfStartMonth;
						
						for(Integer i = 0; i < numberOfMonthsForDocs; i++) {
							if(RelativeDueDateUOM == 'Day(s)') {
								relativeDueDateResolved = rollingLastDayOfMonth.addDays(RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if(RelativeDueDateUOM == 'Week(s)') {
								relativeDueDateResolved = rollingLastDayOfMonth.addDays(RelativeDueDateUnits * 7);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if (RelativeDueDateUOM == 'Month(s)') {
								// Get the first day of the month following the last day of the month for this loop
								Date firstDayOfNewFilingMonthCount = rollingLastDayOfMonth.addDays(1);
								
								relativeDueDateResolved = firstDayOfNewFilingMonthCount.addMonths(RelativeDueDateUnits);
								relativeDueDateResolved = relativeDueDateResolved.addDays(-1);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							Date firstOfThisIterationsMonth = rollingLastDayOfMonth.toStartOfMonth();	
							Date firstDateOfTwoMonthsOut = date.newInstance(firstOfThisIterationsMonth.year(),firstOfThisIterationsMonth.month()+2,firstOfThisIterationsMonth.day());
							rollingLastDayOfMonth = firstDateOfTwoMonthsOut.addDays(-1);
						}
					}				
				}
				else if(RelativeDueDateEvent=='Calendar Quarter End') {
					date endDateToUse;
					Integer numberOfMonthsForDocs;
						
					if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c==null){
						if(updateAll!=true && isBatch!=true) {
							sA.addError('Document due dates for this Service Assignment cannot be determined because neither a Projected Treatment End Date or End Date have been entered.  Please enter a value for one of those two date fields, then try to save again.');
						}
						else {
							// DO NOTHING; IF END DATE ISN'T PRESENT FOR A BATCH RUN, WE SHOULD SKIP CREATING DUE DATES WITHOUT THROWING AN ERROR.  updateAll should be true in this method's call only for batch calls.
						}
					}
					else {
						
						if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c!=null) {
							endDateToUse = sA.Projected_Treatment_End_Date__c;					
						}
						else if(sA.End_Date__c!=null) {
							endDateToUse = sA.End_Date__c;
						}
						
						// Generate list of resolved due dates for the document.
						numberOfMonthsForDocs = sA.Start_Date__c.monthsBetween(endDateToUse)/3;
						System.debug('numberOFMonthsForDocs: ' + numberOfMonthsForDocs);
						Date referenceDateForRecurringDocs = sA.Start_Date__c;
						
						// Define quarters
						Quarter q;
						Integer quarter1EndMonth = 3;
						Integer quarter1EndDay = 31;
						Integer quarter2EndMonth = 6;
						Integer quarter2EndDay = 30;
						Integer quarter3EndMonth = 9;
						Integer quarter3EndDay = 30;
						Integer quarter4EndMonth = 12;
						Integer quarter4EndDay = 31;
						Date quarterEndDate;
						Date thisLoopQuarterEndDate;
						
						if ( referenceDateForRecurringDocs.Month() >= 1 && referenceDateForRecurringDocs.Month() <= 3 ) {
							q = Quarter.ONE;
							quarterEndDate = date.newInstance(referenceDateForRecurringDocs.year(),quarter1EndMonth,quarter1EndDay);
						}
						else if ( referenceDateForRecurringDocs.Month() >= 4 && referenceDateForRecurringDocs.Month() <= 6 ) {
							q = Quarter.TWO;
							quarterEndDate = date.newInstance(referenceDateForRecurringDocs.year(),quarter2EndMonth,quarter2EndDay);
						}
						else if ( referenceDateForRecurringDocs.Month() >= 7 && referenceDateForRecurringDocs.Month() <= 9 ) {
							q = Quarter.THREE;
							quarterEndDate = date.newInstance(referenceDateForRecurringDocs.year(),quarter3EndMonth,quarter3EndDay);
						}
						else if ( referenceDateForRecurringDocs.Month() >= 10 && referenceDateForRecurringDocs.Month() <= 12 ) {
							q = Quarter.FOUR;
							quarterEndDate = date.newInstance(referenceDateForRecurringDocs.year(),quarter4EndMonth,quarter4EndDay);
						}
						
						referenceDateFOrRecurringDocs = quarterEndDate;
						
						for(Integer i = 0; i < numberOfMonthsForDocs; i++) {
							if(RelativeDueDateUOM == 'Day(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addDays(RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if(RelativeDueDateUOM == 'Week(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addDays(RelativeDueDateUnits * 7);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if (RelativeDueDateUOM == 'Month(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addMonths(RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							
							if(q==Quarter.ONE) {
								q = Quarter.TWO;
								quarterEndDate = date.newInstance(quarterEndDate.year(),quarter2EndMonth,quarter2EndDay);
							}
							else if(q==Quarter.TWO) {
								q = Quarter.THREE;
								quarterEndDate = date.newInstance(quarterEndDate.year(),quarter3EndMonth,quarter3EndDay);
							}
							else if(q==Quarter.THREE) {
								q = Quarter.FOUR;
								quarterEndDate = date.newInstance(quarterEndDate.year(),quarter4EndMonth,quarter4EndDay);
							}
							else if(q==Quarter.FOUR) {
								q = Quarter.ONE;
								quarterEndDate = date.newInstance(quarterEndDate.year()+1,quarter1EndMonth,quarter1EndDay);
							}
							referenceDateForRecurringDocs = quarterEndDate;
						}
					}					
				}					
				else if(RelativeDueDateEvent=='MENTOR Fiscal Year End') {
	
					date endDateToUse;
					Decimal numberOfMonthsForDocs;
	
					if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c==null){
						if(updateAll!=true && isBatch!=true) {
							sA.addError('Document due dates for this Service Assignment cannot be determined because neither a Projected Treatment End Date or End Date have been entered.  Please enter a value for one of those two date fields, then try to save again.');
						}
						else {
							// DO NOTHING; IF END DATE ISN'T PRESENT FOR A BATCH RUN, WE SHOULD SKIP CREATING DUE DATES WITHOUT THROWING AN ERROR.  updateAll should be true in this method's call only for batch calls.
						}					
					}
					else {
						
						if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c!=null) {
							endDateToUse = sA.Projected_Treatment_End_Date__c;					
						}
						else if(sA.End_Date__c!=null) {
							endDateToUse = sA.End_Date__c;
						}
					
						// Generate list of resolved due dates for the document.
						numberOfMonthsForDocs = sA.Start_Date__c.monthsBetween(endDateToUse);
						Decimal numberOfYearsForDocs;
						if(numberOfMonthsForDocs > 12) {
							numberOfYearsForDocs = (numberOfMonthsForDocs/12).round(roundingMode.UP);
						}
						else {
							numberOfYearsForDocs = 1;
						}
						
						Date initialReferenceDate;
						if(sA.Start_Date__c.month()<=9) {
							initialReferenceDate = date.newInstance(sA.Start_Date__c.year(),9,30);
						}
						else {
							initialReferenceDate = date.newInstance(sA.Start_Date__c.year()+1,9,30);
						}
						
						Date referenceDateForRecurringDocs = initialReferenceDate;
						
						for(Integer i = 0; i < numberOfYearsForDocs; i++) {
							if(RelativeDueDateUOM == 'Day(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addDays(RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if(RelativeDueDateUOM == 'Week(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addDays(RelativeDueDateUnits * 7);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if (RelativeDueDateUOM == 'Month(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addMonths(RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							
							referenceDateForRecurringDocs = date.newInstance(referenceDateForRecurringDocs.year()+1,referenceDateForRecurringDocs.month(),referenceDateForRecurringDocs.day());
						}				
					}
				}
				else if(RelativeDueDateEvent=='Client Tx Start') {
					if(RelativeDueDateUOM == 'Day(s)') {
						relativeDueDateResolved = sA.Start_Date__c.addDays(RelativeDueDateUnits);
						relativeDueDateList.add(relativeDueDateResolved);
					}
					else if(RelativeDueDateUOM == 'Week(s)') {
						relativeDueDateResolved = sA.Start_Date__c.addDays(RelativeDueDateUnits * 7);
						relativeDueDateList.add(relativeDueDateResolved);
					}
					else if (RelativeDueDateUOM == 'Month(s)') {
						relativeDueDateResolved = sA.Start_Date__c.addMonths(RelativeDueDateUnits);
						relativeDueDateList.add(relativeDueDateResolved);
					}
				}
				else if(RelativeDueDateEvent=='Client Tx End') {
					if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c==null){
						if(updateAll!=true && isBatch!=true) {
							sA.addError('Document due dates for this Service Assignment cannot be determined because neither a Projected Treatment End Date or End Date have been entered.  Please enter a value for one of those two date fields, then try to save again.');
						}
						else {
							// DO NOTHING; IF END DATE ISN'T PRESENT FOR A BATCH RUN, WE SHOULD SKIP CREATING DUE DATES WITHOUT THROWING AN ERROR.  updateAll should be true in this method's call only for batch calls.
						}
					}
					else if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c!=null) {
						if(RelativeDueDateUOM == 'Day(s)') {
							relativeDueDateResolved = sA.Projected_Treatment_End_Date__c.addDays(RelativeDueDateUnits);
							relativeDueDateList.add(relativeDueDateResolved);
						}
						else if(RelativeDueDateUOM == 'Week(s)') {
							relativeDueDateResolved = sA.Projected_Treatment_End_Date__c.addDays(RelativeDueDateUnits * 7);
							relativeDueDateList.add(relativeDueDateResolved);
						}
						else if (RelativeDueDateUOM == 'Month(s)') {
							relativeDueDateResolved = sA.Projected_Treatment_End_Date__c.addMonths(RelativeDueDateUnits);
							relativeDueDateList.add(relativeDueDateResolved);
						}
					}
					else if(sA.End_Date__c!=null){
						if(RelativeDueDateUOM == 'Day(s)') {
							relativeDueDateResolved = sA.End_Date__c.addDays(RelativeDueDateUnits);
							relativeDueDateList.add(relativeDueDateResolved);
						}
						else if(RelativeDueDateUOM == 'Week(s)') {
							relativeDueDateResolved = sA.End_Date__c.addDays(RelativeDueDateUnits * 7);
							relativeDueDateList.add(relativeDueDateResolved);
						}
						else if (RelativeDueDateUOM == 'Month(s)') {
							relativeDueDateResolved = sA.End_Date__c.addMonths(RelativeDueDateUnits);
							relativeDueDateList.add(relativeDueDateResolved);
						}					
					}				
				}
				else if(RelativeDueDateEvent=='Monthly Anniversary of Client Tx Start') {
	// !!!!!!!!!!!!
	// !!!!!!!!!!!!
	// NEED CLARIFICATION: What do we do if a client started on Jan. 31?  Is the monthly anniversary in Feb. on Feb. 28, except in a leap year when it's on the 29th?
	// Clients who start on the 29, 30, and 31 of any month may not have a monthly anniversary of client treatment start.  Do we flow documents relative to the 
	// monthly anniversary if it exists, and use the last day of the month if it does not (that's what I've done here for lack of a better idea)?
	// !!!!!!!!!!!!
	// !!!!!!!!!!!!
	
					date endDateToUse;
					Integer numberOfMonthsForDocs;
						
					if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c==null){
						if(updateAll!=true && isBatch!=true) {
							sA.addError('Document due dates for this Service Assignment cannot be determined because neither a Projected Treatment End Date or End Date have been entered.  Please enter a value for one of those two date fields, then try to save again.');
						}
						else {
							// DO NOTHING; IF END DATE ISN'T PRESENT FOR A BATCH RUN, WE SHOULD SKIP CREATING DUE DATES WITHOUT THROWING AN ERROR.  updateAll should be true in this method's call only for batch calls.
						}
					}
					else {
						
						if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c!=null) {
							endDateToUse = sA.Projected_Treatment_End_Date__c;					
						}
						else if(sA.End_Date__c!=null) {
							endDateToUse = sA.End_Date__c;
						}
						
						// Generate list of resolved due dates for the document.
						numberOfMonthsForDocs = sA.Start_Date__c.monthsBetween(endDateToUse);
						System.debug('numberOFMonthsForDocs: ' + numberOfMonthsForDocs);
						Date initialReferenceDate = sA.Start_Date__c;
						Date referenceDateForRecurringDocs = sA.Start_Date__c;
						
						for(Integer i = 0; i < numberOfMonthsForDocs; i++) {
							if(RelativeDueDateUOM == 'Day(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addDays(RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if(RelativeDueDateUOM == 'Week(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addDays(RelativeDueDateUnits * 7);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if (RelativeDueDateUOM == 'Month(s)') {
								relativeDueDateResolved = referenceDateForRecurringDocs.addMonths(RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							
							Integer yearForRefDateIncrement;
							Integer monthForRefDateIncrement;
							
							if (referenceDateForRecurringDocs.month()==12){
								yearForRefDateIncrement = referenceDateForRecurringDocs.year()+1;
								monthForRefDateIncrement = 1;
							}
							else {
								yearForRefDateIncrement = referenceDateForRecurringDocs.year();
								monthForRefDateIncrement = referenceDateForRecurringDocs.month()+1;
							}
							
							Integer dayForRefDateIncrement;
							if (referenceDateForRecurringDocs.month()==1 && (referenceDateForRecurringDocs.day()>28)) {
								if(date.isLeapYear(yearForRefDateIncrement)==true) {
									dayForRefDateIncrement = 29;
								}
								else {
									dayForRefDateIncrement = 28;
								}
							}
							else if ((referenceDateForRecurringDocs.month()==3 || referenceDateForRecurringDocs.month()==5 || referenceDateForRecurringDocs.month()==8 || referenceDateForRecurringDocs.month()==10) && (referenceDateForRecurringDocs.day()>30)) {
								dayForRefDateIncrement = 30;
							}
							else {
								dayForRefDateIncrement = initialReferenceDate.day();
							}
							
							referenceDateForRecurringDocs = date.newInstance(yearForRefDateIncrement,monthForRefDateIncrement,dayForRefDateIncrement);
						}
					}					
				}
				else if(RelativeDueDateEvent=='Quarterly Anniversary of Client Tx Start') {
	// !!!!!!!!!!!!
	// !!!!!!!!!!!!
	// We've assumed 90 day intervals for these, but I'm still not sure about it... (Josh Gilliam, 7/17/13)
	// !!!!!!!!!!!!
	// !!!!!!!!!!!!
					date endDateToUse;
					Integer numberOfMonthsForDocs;
						
					if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c==null){
						if(updateAll!=true && isBatch!=true) {
							sA.addError('Document due dates for this Service Assignment cannot be determined because neither a Projected Treatment End Date or End Date have been entered.  Please enter a value for one of those two date fields, then try to save again.');
						}
						else {
							// DO NOTHING; IF END DATE ISN'T PRESENT FOR A BATCH RUN, WE SHOULD SKIP CREATING DUE DATES WITHOUT THROWING AN ERROR.  updateAll should be true in this method's call only for batch calls.
						}
					}
					else {
						
						if(sA.End_Date__c==null && sA.Projected_Treatment_End_Date__c!=null) {
							endDateToUse = sA.Projected_Treatment_End_Date__c;					
						}
						else if(sA.End_Date__c!=null) {
							endDateToUse = sA.End_Date__c;
						}
						
						// Generate list of resolved due dates for the document.
						numberOfMonthsForDocs = sA.Start_Date__c.monthsBetween(endDateToUse);
						System.debug('numberOFMonthsForDocs: ' + numberOfMonthsForDocs);
						Date referenceDateForRecurringDocs = sA.Start_Date__c;
						
						for(Integer i = 0; i < numberOfMonthsForDocs; i++) {
							if(RelativeDueDateUOM == 'Day(s)') {
								relativeDueDateResolved = date.newInstance(referenceDateForRecurringDocs.year(),referenceDateForRecurringDocs.month(),referenceDateForRecurringDocs.day()+RelativeDueDateUnits);
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if(RelativeDueDateUOM == 'Week(s)') {
								relativeDueDateResolved = date.newInstance(referenceDateForRecurringDocs.year(),referenceDateForRecurringDocs.month(),referenceDateForRecurringDocs.day()+(RelativeDueDateUnits * 7));
								relativeDueDateList.add(relativeDueDateResolved);
							}
							else if (RelativeDueDateUOM == 'Month(s)') {
								relativeDueDateResolved = date.newInstance(referenceDateForRecurringDocs.year(),referenceDateForRecurringDocs.month()+RelativeDueDateUnits,referenceDateForRecurringDocs.day());
								relativeDueDateList.add(relativeDueDateResolved);
							}
							referenceDateForRecurringDocs = date.newInstance(referenceDateForRecurringDocs.year(),referenceDateForRecurringDocs.month(),referenceDateForRecurringDocs.day()+90);
						}
					}					
				}			
			}				
				return relativeDueDateList;
					
	}
	
	public class docException extends Exception {}

}