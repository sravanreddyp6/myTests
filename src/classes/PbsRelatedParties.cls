public with sharing class PbsRelatedParties {
	public Contact contact { get; set; }
	public Integer rows { get; set; }

	private transient List<Related_Party__c> relatedParties;
	public String relatedPartiesJSON {
		get {
			List<RelatedParty> relatedPartiesData = new List<RelatedParty>();
			if (relatedParties.size() > 0) {
				for (Related_Party__c rp: relatedParties){
					relatedPartiesData.add(new RelatedParty(rp.id, rp.Type__c));
				}
			}
			return JSON.serialize(relatedPartiesData);
		}
	}

	public class RelatedParty{
		Id Id;
		String typeC;

		RelatedParty(Id Id, String typeC) {
			this.Id = Id;
			this.typeC = typeC;
		}
	}

	public Related_Party__c relatedParty {
		get {
			if (relatedParty == null) {
				relatedParty = new Related_Party__c();
			}
			return relatedParty;
		}
		set;
	}

	public Id getRelatedPartyReport() {
		Report[] reports = [
			select id, developername from report where developername = 'Related_Party_for_PBS'
		];
		Id reportId;
		if (reports.size() > 0) {
			reportId = reports[0].Id;
		}
		return reportId;
	}

	public Related_Party__c[] getRelatedParties() {
		if (relatedParties != null) {
			return relatedParties;
		}
		this.relatedParties = [
			select Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c,
			       Phone_2_Type__c, Comments__c, Person_Being_Served__c, Status__c, CreatedDate
			  from Related_Party__c
			 where Person_Being_Served__c = :contact.Id
			 order by Type__c, Name
			 limit :rows
		];
		return relatedParties;
	}

	public void showAddRelatedParty() {
		relatedParty = new Related_Party__c(
			Status__c = 'Active'
		);
	}

	@RemoteAction
	public static Related_Party__c loadRelatedParty(string relPartyId) {
		Related_Party__c party = [
			select Id,Name, Type__c, Phone__c, Email__c, Address__c, Phone_1_Type__c, Phone_2__c,
			       Phone_2_Type__c, comments__c,Status__c, Person_Being_Served__c, createddate
			  from Related_Party__c
			 where id = :relPartyId
		];
		return party;
	}

	@RemoteAction
	public static Related_Party__c saveRelatedParty(string partyID, string Name, string PartyType,
	                                                string Phone1, string Email, string Address,
	                                                string Phone2, string Phone1Type,
	                                                string Phone2Type, string comments,
	                                                string pStatus, string PBSId) {
		Related_Party__c party;
		if (String.isEmpty(partyID)) {
			party = new Related_Party__c(
				Name = Name,
				Type__c = PartyType,
				Phone__c = Phone1,
				Email__c = Email,
				Address__c = Address,
				Phone_2__c = Phone2,
				Phone_1_Type__c = Phone1Type,
				Phone_2_Type__c = Phone2Type,
				Comments__c = Comments,
				Status__c = pStatus,
				Person_Being_Served__c = PBSId
			);
		} else {
			party = new Related_Party__c(
				Name = Name,
				Type__c = PartyType,
				Phone__c = Phone1,
				Email__c = Email,
				Address__c = Address,
				Phone_2__c = Phone2,
				Phone_1_Type__c = Phone1Type,
				Phone_2_Type__c = Phone2Type,
				Comments__c = Comments,
				Status__c = pStatus,
				Person_Being_Served__c = PBSId,
				ID = partyID
			);
		}
		upsert party;
		return party;
	}
}