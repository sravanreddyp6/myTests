@isTest
public with sharing class IncidentPeople {

public Incident__c incident;
private List<Incident_Person__c> relatedPeople{ get; private set; } // list of people related to the incident from the db
private Map<String, Recordtype> rtMap; // record types for related people
private List<RecordType> rectypes; // list of record types
public Incident_Person__c currPerson { get; set; } //currently adding/editing person
public Map<String, IncidentPersonWrapper> relExisting {get; set; } // map of working list of related people - updated after every action
public integer relExistingCount { get { return relExisting.size();} }
public string personTypeToAdd { get; set; } // passed from page to indicate type of curr person
public string personToEditDelete { get; set; } // passed from page to indicate edit/delete item
public boolean isEditing {get; set;} // internal flag to keep track of edit vs. add
public Map<String, IncidentPersonWrapper> mapStaff { get; private set;}
public Map<String, IncidentPersonWrapper> mapMentor { get; private set;}
public Map<String, IncidentPersonWrapper> mapOther { get; private set;}
public list<String> orderStaff { get; private set;}
public list<String> orderMentor { get; private set;}
public list<String> orderOther { get; private set;}
public integer existingStaff { get; set; }
public integer existingMentor { get; set; }
public integer existingOther { get; set; }
Private List<Incident_Person__c> newPeople;
public String newPeopleJSON { get {	
	
	return JSON.serialize(newPeople);} set;}

public IncidentPeople(Apexpages.StandardController controller){
		
		incident = (Incident__c)controller.getRecord();
		isEditing = false;
		currPerson = new Incident_Person__c();
		
		initrelatedPeople();	
	
		rectypes = [ select id, name, developername from recordtype where sobjecttype='Incident_Person__c'];
		rtMap = new Map<String, RecordType>();
		for ( RecordType rec : rectypes ) {
			rtMap.Put( rec.Name, rec);
		}
		system.debug( rtMap);
		
	}
	
	
// get list of people currently related and write to working list
private void initrelatedPeople() {
	
		string PersonName;
		string Title;
		string empId;
		
		newPeople = new List<Incident_Person__c>();	// list of new starts out empty
		relExisting = new Map<String, IncidentPersonWrapper>(); //list of existing people
		mapStaff = new Map<String, IncidentPersonWrapper>();
		mapMentor  = new Map<String, IncidentPersonWrapper>();
		mapOther  = new Map<String, IncidentPersonWrapper>();
		
		  orderStaff = new list<String>();
		  orderMentor = new list<String>();
		  orderOther =	new list<String>();
		if ( incident.id != null)
			relatedPeople = [ select id, title__c, person_type__c, staff_member__c, staff_member__r.name, staff_member__r.employee_number__c, staff_member__r.job_title__c, mentor__c, mentor__r.name, mentor__r.role__c, mentor__r.full_name__c, other_people__c, recordtype.name, createdbyid, createddate, lastmodifieddate, lastmodifiedbyid, lastmodifiedby.name from incident_person__c where incident__c = :this.incident.id order by person_type__c, lastmodifieddate asc ];
		else
			relatedPeople = new List<Incident_Person__c>();
			
		for ( Incident_Person__c rp: relatedPeople ) {

			// create a wrapper for each existing person
			IncidentPersonWrapper ipw = new IncidentPersonWrapper();
			ipw.isnew= false;
			ipw.persontype = rp.person_type__c;
			ipw.lastmodifiedbyid = rp.lastmodifiedbyid;
			ipw.lastmodifiedby = rp.lastmodifiedby.name;
			ipw.lastmodifieddate = rp.lastmodifieddate;
			ipw.relatedPerson = rp;
			
			if ( rp.person_type__c == 'Mentor') {
				ipw.PersonName = rp.mentor__r.full_name__c;
				ipw.Title = rp.mentor__r.role__c;
				ipw.EmpNum = rp.mentor__r.name;
				ipw.mentor = rp.mentor__c;				
				mapMentor.put( ipw.editID, ipw);
				orderMentor.add( ipw.editID);
			}
			else if ( rp.person_type__c == 'Staff') {
				ipw.PersonName = rp.staff_member__r.name;
				ipw.EmpNum = rp.staff_member__r.employee_number__c;
				ipw.Title = rp.staff_member__r.job_title__c;
				ipw.staff= rp.staff_member__c;
				mapStaff.put( ipw.editID, ipw);
				orderStaff.add( ipw.editID);
				
			} 
			else if ( rp.person_type__c == 'Other') {
				ipw.PersonName = rp.other_people__c;
				ipw.other = rp.other_people__c;
				mapOther.put ( ipw.editID, ipw);
				orderOther.add( ipw.editID);
				
			}
			relExisting.put( ipw.editID, ipw );
		}
		
		existingStaff = mapStaff.size();
		if ( mapStaff.size() > 0 )
			incident.staff_present__c = 'Yes';
		
		existingMentor = mapMentor.size();
		if ( mapMentor.size() > 0 )
			incident.mentor_present__c = 'Yes';
			
		existingOther = mapOther.size();
		if ( mapOther.size() > 0 )
			incident.Others_present_at_time_of_incident__c = 'Yes';
}		

	
// initialize current Person record
public void newPerson( ) {
	isEditing = false;
	currPerson = new Incident_Person__c( person_type__c = personTypetoAdd, incident__c = incident.id, recordtypeid= rtMap.get(personTypeToAdd).id);
}

// get current record to edit
public void editPerson () {
	isEditing = true;
	currPerson = relExisting.get(personToEditDelete).relatedPerson;
}

public pageReference delPerson() {
	// ;
	
	removeFromTypeMap( personToEditDelete);
	relExisting.remove( personToEditDelete );
	newPeople = new List<Incident_Person__c>();
	for(IncidentPersonWrapper IW : mapOther.values() ){
		if(IW.isNew)
			newPeople.add(IW.relatedPerson);
	}
	for(IncidentPersonWrapper IW : mapMentor.values() ){
		if(IW.isNew)
			newPeople.add(IW.relatedPerson);
	}
	for(IncidentPersonWrapper IW : mapStaff.values() ){
		if(IW.isNew)
			newPeople.add(IW.relatedPerson);
	}			
	return null;
}

private void removeFromTypeMap( string keytoDel ) {
	
	IncidentPersonWrapper ipw = relExisting.get( keytoDel );
	if ( ipw == null )
		return;
	
	if ( ipw.persontype == 'Other') {
		
		mapOther.remove( keyToDel );
	    orderOther.remove( getIndexForItem(orderOther,keyToDel) );		
	}
	else if ( ipw.persontype == 'Staff') {
		mapStaff.remove( keyToDel );

			orderStaff.remove( getIndexForItem(orderStaff,keyToDel) );
	}
	else if ( ipw.persontype == 'Mentor') {
		mapMentor.remove( keyToDel );	

			orderMentor.remove( getIndexForItem(orderMentor,keyToDel) );	
	}
	
		
	
}
private void addToTypeMap( IncidentPersonWrapper ipw ) {
	
	if ( ipw.persontype == 'Other') {
		mapOther.put( ipw.editID, ipw);
		orderOther.add(ipw.editID);
		incident.others_present_at_time_of_incident__c = 'Yes';
	}
	else if ( ipw.persontype == 'Staff') {
		mapStaff.put ( ipw.editID, ipw);
		orderStaff.add(ipw.editID);
		incident.staff_present__c = 'Yes';
	}
	else if ( ipw.persontype == 'Mentor') {
		mapMentor.put ( ipw.editID, ipw);
		OrderMentor.add(ipw.editID);
		incident.mentor_present__c = 'Yes';
	}
}

private integer getIndexForItem(list<string> items, string itemToCheck){

	
	for(integer i = 0; i <  items.size();  i++){
		if(items[i] == itemToCheck){ return i;}
	}
	
	return null;
}

public pageReference savePerson( ) {
		
		boolean hasError = false;
		string perType = currPerson.Person_type__c;
		IncidentPersonWrapper ipw ;
		
		if (isEditing ) {
			ipw = relExisting.get(personToEditDelete);	
		} else {
			ipw = new IncidentPersonWrapper();
			ipw.persontype = perType;
			ipw.isnew = true;
		}
		
		// check for required fields and duplication
		if ( perType  == 'Mentor' ) {
			if ( currPerson.Mentor__c == null  ) {
				hasError = true;
				currPerson.addError('Please select a Mentor as the related person.');
			}
			if (!hasError) {
				if ( relExisting.size() > 0 && relExisting.keyset().contains( currPerson.Mentor__c) && !(isEditing && currPerson.Mentor__c == personToEditDelete ) ) {
					hasError = true;
					currPerson.addError('This Mentor is already related to this incident.');		
				} else {
					ipw.Mentor = currPerson.Mentor__c;
					
				} 
			}
		}
		else if ( perType == 'Staff') {
			if ( currPerson.Staff_Member__c == null  ) {
				hasError = true;
				currPerson.addError('Please select a Staff Member as the related person.');
			}
			if (!hasError) {
				
				if ( relExisting != null && relExisting.size() > 0 && relExisting.keyset().contains( currPerson.Staff_Member__c) && !(isEditing && currPerson.Staff_Member__c == personToEditDelete ) ) {
					hasError = true;
					currPerson.addError('This Staff Member is already related to this incident.');		
				} else {
					ipw.Staff = currPerson.Staff_Member__c;
				}
			}
		}
		else if ( perType == 'Other') {
			
			if ( String.isBlank( currPerson.Other_People__c )) {
				hasError = true;
				currPerson.addError('Please enter Name (or PBS Initials) ');
			} else {
				if ( relExisting != null && relExisting.size() > 0 && relExisting.keyset().contains( currPerson.Other_people__c) && !(isEditing && currPerson.Other_People__c == personToEditDelete ) ) {
					hasError = true;
					currPerson.addError('You have already added another person with the same information to this incident.');
				} else {		
					ipw.Other = currPerson.Other_People__c;
				}
			}
		if(String.isBlank(currPerson.Title__c) ){hasError = true; currPerson.addError('Please enter a Title');}
		}
		
		try {
			if(!hasError){
				//system.debug('CURR:' + currPerson);
				ipw.relatedPerson = currPerson;
				if ( isEditing ) {
					removeFromTypeMap (persontoEditDelete);
					relExisting.remove(persontoEditDelete);
					newPeople = new List<Incident_Person__c>();
					for(IncidentPersonWrapper IW : mapOther.values() ){
						if(IW.isNew)
							newPeople.add(IW.relatedPerson);
					}
					for(IncidentPersonWrapper IW : mapMentor.values() ){
						if(IW.isNew)
							newPeople.add(IW.relatedPerson);
					}
					for(IncidentPersonWrapper IW : mapStaff.values() ){
						if(IW.isNew)
							newPeople.add(IW.relatedPerson);
					}						
				}
					
				relExisting.put( ipw.editId, ipw);
				addToTypeMap( ipw);
				newPeople.Add( currPerson);
				system.debug('new people:' + newPeople);
				newPerson();
			}
		} catch (DMLException ex) {
		 	hasError = true;
			system.debug(ex);
			// SF will automatically create a PageMessage Error here, so we don't
			// have to do anything
		}
		return null;
	}
	
	// adds new people to parent incident
	public void saveRelatedPeople (ID incId) {
		
		IncidentPersonWrapper ipw;
		Incident_Person__c ip;
		
		for ( string ipwKey : relExisting.keyset()) {
			
			ipw = relExisting.get(ipwKey);
			
			if (ipw.isNew) {
				ip = ipw.RelatedPerson;		
				ip.Incident__c = incId;
				upsert ( ip );
			}
		}
		
	}
	
	public class IncidentPersonWrapper {
	
		public string editId { get; set; }
		public string PersonName { get; set; }
		public string EmpNum { get; set; }
		public string Title { get; set; }
		public ID Mentor { get; set { mentor = value; updateMentorName( value ); editID = value; } }
		public ID Staff { get; set { staff = value; updateStaffName( value ); editID = value;}}
		public String Other { get; set { PersonName = value; editID = value; editID = value;}}
		public string PersonType { get; set; }
		public Boolean isNew { get; private set ;}
		public Incident_Person__c relatedPerson { get; set; }
		public DateTime LastmodifiedDate { get; set; }
		public ID Lastmodifiedbyid { get; set; }
		public String LastmodifiedBy { get; set; }
		public IncidentPersonWrapper() {

		}
		
		private void updateMentorName( ID newID ) {
			if ( isNew && newID != null) {
			TMN_Contact__c newMentor = [ select id, name, full_name__c,  role__c from tmn_contact__c where id=:newID ];		
			if ( newMentor != null )
				PersonName = newMentor.full_name__c;
				EmpNum = newMentor.name;
				Title = newMentor.role__c;
			}
		}
		
		private void updateStaffName( ID newID ) {
			if ( newID != null ) {
			TMN_User__c  newUser = [ select id, name, employee_number__c, job_title__c from TMN_User__c where id=:newID ];		
			if ( newUser != null )
				PersonName = newUser.name;
				EmpNum = newUser.employee_number__c;
				Title = newUser.job_title__c;
			}
		}
		
		
	}
	
}