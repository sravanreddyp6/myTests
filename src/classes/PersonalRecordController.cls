public with sharing class PersonalRecordController {
    public String photoUrl { get; set; }
    public blob photo { get; set; }
    public Contact con { get; set; }
    public Integer guardianCount { get; set;}
    public boolean hasPhoto { get; set; }
    public String contactId { get;
        set {
            System.debug('Contact ID: ' + value);
            this.con = [
                SELECT Id, FirstName, LastName, Phone, Ethnicity_Picklist__c,
                       Birthdate, Guardian1_Name__c, Guardian_Phone_Number__c,
                       Gender__c, Age__c, Family_Member_Other__c, PBS_Identifier__c, Primary_Language__c, Advanced_Directives__c, Code_Status__c
                FROM Contact WHERE id=:value
            ];
            
            this.guardianCount = [select count() from related_party__c where person_being_served__c =:value and type__c = 'Guardian'];
            
            
            List<Attachment> headShot = [
                SELECT id, parentId, Name, Description FROM Attachment
                WHERE Name LIKE 'HeadShot-Current%' and parentID=:value LIMIT 1
            ];
            if(headShot.size()>0){
            	this.photoUrl='/servlet/servlet.FileDownload?file=' + headShot[0].id; 
            	this.hasPhoto = true;
            } else
            	this.hasPhoto = false;
        }
    }

	public String parentPageName {get; set { System.Debug('parentPage: ' + value); }
	}
	
	public String admissionId { get {
									if ( String.isEmpty(admissionId))  {
										Admission__c[] adm = [ select id from admission__c where person_being_served__c = :con.Id order by createddate desc];
										
										if ( adm.size() > 0 ) {
											admissionId = adm[0].Id; 
											return adm[0].Id;
										}
										else
											return null;
									} else { return admissionId; }
									} set { System.Debug('admissionId: ' + value); }}
									
	public String assessmentId { get; set { System.Debug('assessmentId: ' + value); }}
	public String assessmentType { get; set { System.Debug('assessmenttype: ' + value); }}
	public String saId { get; set; }
	public Boolean saNew { get; set; }
    public String planId { get; set; }
    public String servAssignClosure { get; set; }
	public PageReference breadcrumb { get; set; }
	
	public String opGrp { get { 
						TMN_User__c TU = [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1]; 
						return TU.Operating_Group__c; 
        				} set;}
	
    public PersonalRecordController() {
      
    }
    
    public String primaryDiagnosis {    	
    	get {
            Diagnosis__c[] d = [select Primary_Diagnosis__c from Diagnosis__c where Service_Assignment__r.Admission__r.Person_Being_Served__c=:con.Id And Service_Assignment__r.Status__c = 'Active' order by Effective_Date__c desc limit 1];    		
    		if (opGrp =='Redwood' || opGrp =='Cambridge' || opGrp == 'Care Meridian') {
                if (d.size() > 0) {
                    return d[0].primary_diagnosis__c;
                } else
                return null;
    		}
            else
                return null;    	
        }    
    }
    
    public String primaryPhysician{
    	get{
    		Related_Party__c[] party = [select id, Name, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c from Related_Party__c where Person_Being_Served__c = :con.Id And Type__c =: 'Physician - Primary' limit 1];
            if (party.size() > 0 ) {
                return party[0].Name;
            } else
    		  return null;
    	}
    }

    public String primaryPhysicianPhone{
        get{
        	String physicianPhone;
            Related_Party__c[] party = [select id, Name, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c from Related_Party__c where Person_Being_Served__c = :con.Id And Type__c =: 'Physician - Primary' limit 1];
            if (party.size() > 0 ) {
            	if (party[0].Phone_1_Type__c == 'Work'){
                    physicianPhone = party[0].Phone__c;
            	}
                else if(party[0].Phone_2_Type__c == 'Work'){
                    physicianPhone = party[0].Phone_2__c;
                }
                return physicianPhone;
            } else
              return null;
        }
    }    

    public void uploadPhoto(){
        Attachment objA=new Attachment();
        objA.body = photo;
        objA.name = con.FirstName;
        objA.parentid= con.id;
        objA.ContentType = 'application/jpg';
        insert objA;
        string Attid= objA.id;
        string attachmentid=Attid.substring(0,15);
        this.photoUrl = '/servlet/servlet.FileDownload?file='+attachmentid;
        objA.body = null;
        this.photo=null;
    }
}