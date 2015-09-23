public with sharing class AdmissionTriggeredActions {

    public void OnAfterInsert(Admission__c[] updatedObjects, Map<Id,Admission__c> oldObjMap, Map<Id,Admission__c> newObjMap){
    	if (SystemSettings__c.getOrgDefaults().PB_AdmissionDocumentFeature__c && 
    	       [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() and Operating_Group__c = 'Care Meridian'].size() > 0) {

    		List<PB_DocPacket_Document_JO__c> docs = [SELECT id, DocPacket__c, Document__c, Document__r.Due__c from PB_DocPacket_Document_JO__c
                                                       where Document__r.Status__c = 'Active' And DocPacket__r.Status__c = 'Active' And DocPacket__r.Default_Admission_Packet__c = true];

    		for (Admission__c admission : updatedObjects){
	                List<PB_AssociatedDoc__c> assocDocs = new List<PB_AssociatedDoc__c>();
	                for(PB_DocPacket_Document_JO__c doc: docs){
	                       assocDocs.add( new PB_AssociatedDoc__c ( DocPacket__c = doc.DocPacket__c,
	                                                                Document__c = doc.Document__c,
	                                                                Due_Date__c = getDueDate(admission.Effective_date__c, doc.Document__r.Due__c), //due date = Calculated based on PBS Admission Date or Entered (If "Other" in Due)
	                                                                IsAdded__c = true,
	                                                                sObject_Id__c = admission.Id,
	                                                                sObject_Type__c = 'Admission',
	                                                                Status__c = 'Pending',
	                                                                Status_Date__c = null) );
	                }
	                insert assocDocs;
    		} // end-For all admissions
    	} // end-if the feature is turned ON 
    	
    }

	private Date getDueDate(Date admissionEffDt, String due){
	    Date dueDate;
	    if (due == 'Treatment Start Date')  dueDate = admissionEffDt; 
	    else if (due == '72 Hours after Treatment Start') dueDate = admissionEffDt.addDays(3);
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
            if ( adm.Discharged_Date_Time__c != null )
               adm.Discharged_Date__c = adm.Discharged_Date_Time__c.date();               
        }
    }
    
}