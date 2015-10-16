public with sharing class PersonalRecordController {
	public String photoUrl { get; set; }
	public blob photo { get; set; }
	public Contact con { get; set; }
	public Evaluation_Response__c[] evaluationResponses { get; set; }
	public List<Service_Assignment__c> servAssigns { get; set; }
	public Integer guardianCount { get; set;}
	public boolean hasPhoto { get; set; }
	public String contactId { get;
	set {
		if (value == contactId) {
			return;
		}
		this.contactId = value;
		System.debug('Contact ID: ' + value);
		this.con = [
			SELECT Id, FirstName, LastName, Phone, Ethnicity_Picklist__c,
			       Birthdate, Guardian1_Name__c, Guardian_Phone_Number__c,
			       Gender__c, Age__c, Family_Member_Other__c, PBS_Identifier__c, Primary_Language__c, Advanced_Directives__c, Code_Status__c, Flavor__c
			  FROM Contact WHERE id=:value
		];
		this.evaluationResponses = [
			SELECT Id, Allergy_Details__c, Allergy_Type__c
			  FROM Evaluation_Response__c
			 WHERE Person_Being_Served__c = :value
			   AND Life_Threatening__c = true
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

		servAssigns = [Select Id, Name from Service_Assignment__c where Person_Being_Served__c = : value and Status__c = 'Active'];
	}
	}

	public String parentPageName {get; set { System.Debug('parentPage: ' + value); }
	}

	public string getevalType(){
		if( ApexPages.currentPage().getParameters().get('evalType') != null){
			return ApexPages.currentPage().getParameters().get('evalType');
		}
		else{
			return null;
		}

	}

	public string getrecType(){
		if( ApexPages.currentPage().getParameters().get('recType') != null){
			return ApexPages.currentPage().getParameters().get('recType');
		}
		else{
			return null;
		}

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
	public String evalId {get; set; }
	public string authorizationId { get; set; }

	public String opGrp {
		get {
			opGrp = (opGrp == null ? [select Operating_Group__c from TMN_User__c Where Salesforce_User_Account__r.id = :UserInfo.getUserId() limit 1].Operating_Group__c : opGrp);
			return opGrp;
		}
		set;
	}

	public PersonalRecordController() {

	}

	public String primaryDiagnosis {
		get {
			if (primaryDiagnosis != null) {
				return primaryDiagnosis;
			}
			Diagnosis__c[] d = [select Primary_Diagnosis__c from Diagnosis__c where Service_Assignment__r.Admission__r.Person_Being_Served__c=:con.Id And Service_Assignment__r.Status__c = 'Active' order by Effective_Date__c desc limit 1];
			if (opGrp =='Redwood' || opGrp =='Cambridge' || opGrp == 'Care Meridian' || this.con.flavor__c == 'CA FSS') {
				if (d.size() > 0) {
					primaryDiagnosis = d[0].primary_diagnosis__c;
				} else {
					primaryDiagnosis = '';
				}
			} else {
				primaryDiagnosis = '';
			}
			return primaryDiagnosis;
		}
		set;
	}

	public String primaryPhysician{
		get{
			if (primaryPhysician != null) {
				return primaryPhysician;
			}
			Related_Party__c[] party = [select id, Name, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c from Related_Party__c where Person_Being_Served__c = :con.Id And Type__c =: 'Physician - Primary' limit 1];
			if (party.size() > 0 ) {
				primaryPhysician = party[0].Name;
			} else {
				primaryPhysician = '';
			}
			return primaryPhysician;
		}
		set;
	}

	public String primaryPhysicianPhone{
		get{
			if (primaryPhysicianPhone != null) {
				return primaryPhysicianPhone;
			}
			Related_Party__c[] party = [select id, Name, Phone__c, Phone_1_Type__c, Phone_2__c, Phone_2_Type__c from Related_Party__c where Person_Being_Served__c = :con.Id And Type__c =: 'Physician - Primary' limit 1];
			if (party.size() > 0 ) {
				if (party[0].Phone_1_Type__c == 'Work'){
					primaryPhysicianPhone = party[0].Phone__c;
				}
				else if(party[0].Phone_2_Type__c == 'Work'){
					primaryPhysicianPhone = party[0].Phone_2__c;
				}
			} else {
				primaryPhysicianPhone = '';
			}
			return primaryPhysicianPhone;
		}
		set;
	}

	public String isolationStatus{
		get{
			if (isolationStatus != null) {
				return isolationStatus;
			}
			Evaluation_Response__c[] isolation = [
				SELECT Isolation_Status__c
				  FROM Evaluation_Response__c
				 WHERE Service_Assignment__r.Status__c = 'Active'
				   AND Isolation_Status__c = 'Isolated'
				   AND Service_Assignment__r.Admission__r.Person_Being_Served__c=:con.Id
			];
			if(isolation.size() > 0){
				isolationStatus = 'Isolated';
			} else {
				isolationStatus = 'Not Isolated';
			}
			return isolationStatus;
		}
		set;
	}

	public String isolationType{
		get{
			if (isolationType != null) {
				return isolationType;
			}
			set<String> isolation = new set<String>();
			List<evaluation_response__c> isolations = [
				select isolation_type__c,other__c  from evaluation_response__c
				 where service_assignment__r.status__c = 'active'
				   and isolation_status__c = 'isolated'
				   and service_assignment__r.admission__r.person_being_served__c=:con.id
				   and isolation_event_end_date__c = null
				order by isolation_event_start_date__c desc
			];
			for(evaluation_response__c evlres : isolations){
				for (string s : evlres.isolation_type__c.split(';') ){
					if (s == 'other') s = evlres.other__c;
					isolation.add(s);
				}
			}
			isolationType = string.join(new list<string>(isolation), ', ');
			return isolationType;
		}
		set;
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