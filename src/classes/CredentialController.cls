public class CredentialController {

	public Id contactID = apexpages.currentpage().getparameters().get('contactid');
    public List<Credential_Record__c> allRecords  {get;set;}
    private List<Credential_Record__c> allRecordsAtConstruction {get;set;}
    public TMN_Contact__c theTmnContact {get;set;}
    public String baseUrl { get; set; }
    public Boolean editMode { get; set; }
    public List<CredentialSection> credSectionList { get; set; }

	class CredentialRecordWrapper implements Comparable {
		
		public Credential_Record__c cred { get; set; }
		
		public CredentialRecordWrapper(Credential_Record__c c) {
			cred = c;
		}
		
		public Integer compareTo(Object compareTo) {
			CredentialRecordWrapper compareToCredRecWrapper = (CredentialRecordWrapper)compareTo;
			if (cred.Credential_Profile__r.Order__c==compareToCredRecWrapper.cred.Credential_Profile__r.Order__c) return 0;
			if (cred.Credential_Profile__r.Order__c > compareToCredRecWrapper.cred.Credential_Profile__r.Order__c) return 1;
			return -1;
		}
		
	}
       
    class CredentialSection implements Comparable {
    	
    	public List<Credential_Record__c> creds { get;set; }
    	public String sectionName { get; set; }
    	public Integer sectionOrder { get; set; }
    	
    	public CredentialSection(String theSectionName, Integer theSectionOrder, List<Credential_Record__c> credRecs) {
    		creds = credRecs;
    		sectionName = theSectionName;
    		sectionOrder = theSectionOrder;
    	}

		public Integer compareTo(Object compareTo) {
		    CredentialSection compareToCredSection = (CredentialSection)compareTo;
		    if (sectionOrder == compareToCredSection.sectionOrder) return 0;
		    if (sectionOrder > compareToCredSection.sectionOrder) return 1;
		    return -1;        
		}
    	
    }
    
    public CredentialController() {
            allRecords = [SELECT Name, Requested_Date__c, Documented_Date__c, Received_Date__c, Expiration_Date__c, Note__c,
            	Credential_Profile__r.Name, Credential_Profile__r.Applies_Requested_Date__c, Credential_Profile__r.Applies_Documented_Date__c, Credential_Profile__r.Applies_Received_Date__c, 
                Credential_Profile__r.Applies_Expiration_Date__c, Credential_Profile__r.Applies_Note__c, Credential_Profile__r.OLM_Requirement__c, Credential_Profile__r.NPA_Requirement__c,
                Credential_Profile__r.Applies_CPS_Full_Disclosure__c, CPS_Full_Disclosure_Required__c, Credential_Profile__r.Applies_State_Conviction__c,
                State_Conviction__c, Type_of_Conviction_State__c, Credential_Profile__r.Applies_Type_of_Conviction_State__c,
                Credential_Profile__r.Applies_Conviction_Past_5_State__c, Conviction_Past_5_Years_State__c,
                Credential_Profile__r.Applies_Federal_Conviction__c, Federal_Conviction__c, Type_of_Conviction_Federal__c, 
                Credential_Profile__r.Applies_Type_of_Conviction_Federal__c,
                Credential_Profile__r.Applies_Conviction_Past_5_Federal__c, Conviction_Past_5_Years_Federal__c, 
                Credential_Profile__r.Applies_FBI_Full_Disclosure__c, FBI_Full_Disclosure_Required__c, Credential_Profile__r.Help_Text__c,
                Outcome_of_Clearance__c, Credential_Profile__r.Applies_Outcome_of_Clearance__c,
                Credential_Profile__r.Section__c, Credential_Profile__r.Section_Order__c, Credential_Profile__r.Order__c
                FROM Credential_Record__c WHERE TMN_Contact__c = :contactID ORDER BY Credential_Profile__r.Name];
            
            Set<String> sectionNames = new Set<String>();
            for(Credential_Record__c cR: allRecords) {
            	sectionNames.add(cR.Credential_Profile__r.Section__c);
            }
            
			credSectionList = new List<CredentialSection>();
			
            for(String s : sectionNames) {
            	Integer thisSectionOrder = 0;
            	List<Credential_Record__c> thisCredList = new List<Credential_Record__c>();
            	for(Credential_Record__c cR: allRecords) {
            		if(s==cR.Credential_Profile__r.Section__c) {
            			thisCredList.add(cR);
            			thisSectionOrder = cR.Credential_Profile__r.Section_Order__c.intValue();
            		}
            	}
            	
            	List<CredentialRecordWrapper> listCredRecWraps = new List<CredentialRecordWrapper>();            	
            	for(Credential_Record__c cR : thisCredList) {
            		listCredRecWraps.add(new CredentialRecordWrapper(cR));
            	}
            	
            	listCredRecWraps.sort();
            	
            	List<Credential_Record__c> sortedCredList = new List<Credential_Record__c>();
            	for(CredentialRecordWrapper cRW : listCredRecWraps) {
            		sortedCredList.add(cRW.cred);
            	}

            	credSectionList.add(new CredentialSection(s, thisSectionOrder, sortedCredList));           	
    		}
    		
    		credSectionList.sort();
                
            allRecordsAtConstruction = [SELECT Name, Requested_Date__c, Documented_Date__c, Received_Date__c, Expiration_Date__c, Note__c,
            	Credential_Profile__r.Name, Credential_Profile__r.Applies_Requested_Date__c, Credential_Profile__r.Applies_Documented_Date__c, Credential_Profile__r.Applies_Received_Date__c, 
                Credential_Profile__r.Applies_Expiration_Date__c, Credential_Profile__r.Applies_Note__c, Credential_Profile__r.OLM_Requirement__c, Credential_Profile__r.NPA_Requirement__c,
                Credential_Profile__r.Applies_CPS_Full_Disclosure__c, CPS_Full_Disclosure_Required__c, Credential_Profile__r.Applies_State_Conviction__c,
                State_Conviction__c, Type_of_Conviction_State__c, Credential_Profile__r.Applies_Type_of_Conviction_State__c,
                Credential_Profile__r.Applies_Conviction_Past_5_State__c, Conviction_Past_5_Years_State__c,
                Credential_Profile__r.Applies_Federal_Conviction__c, Federal_Conviction__c, Type_of_Conviction_Federal__c, 
                Credential_Profile__r.Applies_Type_of_Conviction_Federal__c,
                Credential_Profile__r.Applies_Conviction_Past_5_Federal__c, Conviction_Past_5_Years_Federal__c, 
                Credential_Profile__r.Applies_FBI_Full_Disclosure__c, FBI_Full_Disclosure_Required__c, Credential_Profile__r.Help_Text__c,
                Outcome_of_Clearance__c, Credential_Profile__r.Applies_Outcome_of_Clearance__c
                FROM Credential_Record__c WHERE TMN_Contact__c = :contactID ORDER BY Credential_Profile__r.Name];
                
            theTmnContact = [ SELECT Full_Name__c FROM TMN_Contact__c WHERE Id = :contactID ];
            
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    
    		String mode = ApexPages.currentPage().getParameters().get('mode');
    		
    		if(mode=='Edit') {
    			editMode = true;
    		}
    		else {
    			editMode = false;
    		}
    
    }
    
    public PageReference SaveCreds() {
    	
    	List<Credential_Record__c> recordsToUpdate = new List<Credential_Record__c>();
    	
    	for(Credential_Record__c c : allRecords) {
    		for(Credential_Record__c c2 : allRecordsAtConstruction) {
    			System.debug('c before if: ' + c);
    			System.debug('c2 before if: ' + c2);
    			if(c.Id==c2.Id) {
    				System.debug('c after if: ' + c);
    				System.debug('c2 after if: ' + c2);
    				System.debug('c.Documented_Date__c: ' + c.Documented_Date__c);
    				System.debug('c2.Documented_Date__c: ' + c2.Documented_Date__c);
    				if(c.Requested_Date__c!=c2.Requested_Date__c
    					|| c.Documented_Date__c!=c2.Documented_Date__c
    					|| c.Received_Date__c!=c2.Received_Date__c
    					|| c.Expiration_Date__c!=c2.Expiration_Date__c
    					|| c.Note__c!=c2.Note__c
    					|| c.CPS_Full_Disclosure_Required__c!=c2.CPS_Full_Disclosure_Required__c
    					|| c.State_Conviction__c!=c2.State_Conviction__c
    					|| c.Type_of_Conviction_State__c!=c2.Type_of_Conviction_State__c
    					|| c.Conviction_Past_5_Years_State__c!=c2.Conviction_Past_5_Years_State__c
    					|| c.Federal_Conviction__c!=c2.Federal_Conviction__c
    					|| c.Type_of_Conviction_Federal__c!=c2.Type_of_Conviction_Federal__c
    					|| c.Conviction_Past_5_Years_Federal__c!=c2.Conviction_Past_5_Years_Federal__c
    					|| c.FBI_Full_Disclosure_Required__c!=c2.FBI_Full_Disclosure_Required__c
    					|| c.Outcome_of_Clearance__c!=c2.Outcome_of_Clearance__c 
    					) {
    					System.debug('The inmost if executing here...');
    					recordsToUpdate.add(c);	
    				}		
    			}
    		}
    	}
    	
    	update recordsToUpdate;
    	
    	PageReference myPageRef = new PageReference('/apex/Credential?contactId=' + contactID);
    	myPageRef.setRedirect(true);
    	return myPageRef;
    	
    }
    
    public PageReference CancelCreds() {
    	PageReference cancelPageRef = new PageReference('/apex/Credential?contactId=' + contactID);
    	cancelPageRef.setRedirect(true);
    	return cancelPageRef;
    }
    
    public PageReference GoEditMode() {
		PageReference editModePageRef = new PageReference('/apex/Credential?contactId=' + contactID + '&mode=Edit');
		editModePageRef.setRedirect(true);
		return editModePageRef;
    }   
}