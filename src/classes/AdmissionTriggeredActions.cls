public with sharing class AdmissionTriggeredActions {

    public void OnAfterInsert(Admission__c[] updatedObjects, Map<Id,Admission__c> oldObjMap, Map<Id,Admission__c> newObjMap){
    	
 
    	if (SystemSettings__c.getOrgDefaults().PB_AdmissionDocumentFeature__c){ //Run only when feature is enabled
    		
	    	List<TMN_User__c> currentUser  = [SELECT Id, Operating_group__c, Business_unit__c FROM TMN_User__c WHERE Salesforce_user_account__c = :userinfo.getUserId() LIMIT 1];
	    	Set<string> networks = new set<string>();
	    	Map<string, List<PB_DocPacket_Document_JO__c>> networkMap = new map<string, List<PB_DocPacket_Document_JO__c>>();
	    	List<PB_DocPacket_Document_JO__c> docs = new List<PB_DocPacket_Document_JO__c>();
	    	List<PB_AssociatedDoc__c> assocDocs = new List<PB_AssociatedDoc__c>();
	    	
	    	if(currentUser.size() > 0){
	    		for(Admission__c adm: updatedObjects){
		    		if((adm.Network_offering__c == 'ABI' && currentUser[0].Operating_group__c == 'Care Meridian') || (adm.Network_offering__c == 'ARY' && (null != currentUser[0].Business_unit__c && currentUser[0].Business_unit__c.startsWith('BU 008')))){
		    			networks.add(adm.Network_offering__c);
		    		}
	    		}	
	    	}
	    	
	    	//networks are only populated when either the user belongs to Care Meridian or CA FSS - Sravan - Sep24, 2015
	    	if(networks.size() > 0){
	    		for(string s: networks){
	    			networkMap.put(s, new list<PB_DocPacket_Document_JO__c>());
	    		}
	    		docs = [SELECT id, DocPacket__c, Document__c, Document__r.Due__c, DocPacket__r.Recordtype.name from PB_DocPacket_Document_JO__c
	                                                       where Document__r.Status__c = 'Active' And DocPacket__r.Status__c = 'Active' And DocPacket__r.Default_Admission_Packet__c = true
	                                                       AND DocPacket__r.Recordtype.Name IN: networks];
	         	
	         	for(PB_DocPacket_Document_JO__c dpdJ: docs){
	         		List<PB_DocPacket_Document_JO__c> temp = new List<PB_DocPacket_Document_JO__c>();
	         		if(networkMap.containsKey(dpdJ.DocPacket__r.Recordtype.Name)){
	         			temp = networkMap.get(dpdJ.DocPacket__r.Recordtype.Name);
	         			temp.add(dpdJ);
	         		}
	         		networkMap.put(dpdJ.DocPacket__r.Recordtype.Name, temp);	
	         	}
	         	
	         	for (Admission__c admission : updatedObjects){
		                for(PB_DocPacket_Document_JO__c doc: networkMap.get(admission.Network_offering__c)){
		                       assocDocs.add( new PB_AssociatedDoc__c ( DocPacket__c = doc.DocPacket__c,
		                                                                Document__c = doc.Document__c,
		                                                                Due_Date__c = getDueDate(admission.Effective_date__c, doc.Document__r.Due__c), //due date = Calculated based on PBS Admission Date or Entered (If "Other" in Due)
		                                                                IsAdded__c = true,
		                                                                sObject_Id__c = admission.Id,
		                                                                sObject_Type__c = 'Admission',
		                                                                Status__c = 'Pending',
		                                                                Status_Date__c = null) );
		                }
		                
	    		} // end-For all admissions
	         	
	         	if(assocDocs.size() > 0){
	         		insert assocDocs;
	         	}
	    	}
    		
    	} // end-if the feature is turned ON 
    	
    }

	private Date getDueDate(Date admissionEffDt, String due){
	    Date dueDate;
	    if (due == 'Treatment Start Date')  dueDate = admissionEffDt; 
	    else if (due == '72 Hours after Treatment Start') dueDate = admissionEffDt.addDays(3);
	    else if(due == '2 days from Treatment Start Date') dueDate = admissionEffDt.addDays(2);
	    else if(due == '5 days from Treatment Start Date') dueDate = admissionEffDt.addDays(5);
	    else if(due == '7 days from Treatment Start Date') dueDate = admissionEffDt.addDays(7);
	    else if(due == '90 days from Treatment Start Date') dueDate = admissionEffDt.addDays(90);
	    else dueDate = null;
	    return dueDate;
	}

    public void OnBeforeInsert(Admission__c[] newObjects){            
        updateAdmDate(newObjects);
    }
    
    public void OnBeforeUpdate(Admission__c[] oldObjects, Admission__c[] updatedObjects, Map<Id,Admission__c> newObjMap, Map<Id, Admission__c> oldObjMap){      
        updateAdmDate(updatedObjects);
    }
    
    private void updateAdmDate(Admission__c[] admissions){
        for(Admission__c adm: admissions){
            if ( adm.Admission_Effective_DateTime__c != null )
               adm.Effective_Date__c = adm.Admission_Effective_DateTime__c.date();
        }
    }
    
}