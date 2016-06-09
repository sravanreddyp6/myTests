public with sharing class PersonRegistryDataEntryDoc {

public transient Contact thePBS { get; set; }
public transient List<Related_Party__c> relatedParties { get; set; }
public transient Map<ID, List<ServiceAssignment_Diagnosis_JO__c>> diagnosesbySA { get; set; }
public transient List<Diagnosis__c> diagnosesnoSA { get; set; }
public transient List<Admission__c> admissions {get; set; }
public transient List<Service_Assignment__c> serviceAssignments { get; set; }
public transient String strDiagSAIDList { get; set; }
public transient Map<Id, List<Integer>> admissionStatusCount { get; set; }

public String getPrintView()
    {
        return
        '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
        }
        
        
public PersonRegistryDataEntryDoc  ( ApexPages.StandardController stdController ) {
	
	// get current contact info
	thePBS  = (Contact) stdController.getRecord();
	
	// related parties 
	relatedParties = [ select Name, Phone__c, Address__c, Phone_2__c, Type__c, Comments__c, Phone_1_Type__c, Phone_2_Type__c, status__c from related_party__c where person_Being_served__c = :thePBS.id order by lastmodifieddate desc];
	
	// diagnoses associated to SAs
	diagnosesbySA = new Map<ID, List<ServiceAssignment_Diagnosis_JO__c>>();
	List<ServiceAssignment_Diagnosis_JO__c> diagbySA = [ SELECT service_assignment__c, Diagnosis__r.Icd__c, Diagnosis__r.Icd__r.Name, Diagnosis__r.ICD__r.Icd_Description__c, diagnosis__r.status__c, diagnosis__r.type__c, diagnosis__r.effective_date__c, billable__c, ranking__c, abi_diagnosis__c, date_of_injury__c, injury_type__c, injury_type_other__c, glasgow_coma_score_at_injury__c, glasgow_coma_scale_severity__c  FROM ServiceAssignment_Diagnosis_JO__c WHERE Service_Assignment__r.Admission__r.Person_Being_Served__c = :thePBS.id order by service_assignment__c ];
	for ( ServiceAssignment_Diagnosis_JO__c d : diagbySA ) {
		List<ServiceAssignment_Diagnosis_JO__c> diags = diagnosesbySA.get( d.service_assignment__c); 
		if (  diags == null ) {
			diags = new List<ServiceAssignment_Diagnosis_JO__c>{ d };
		} else {
			diags.add(d);
		}
		diagnosesbySA.put( d.service_assignment__c, diags);
		
	}
	// create a list of IDs in this map so we can test on front end for render condition
	List<String> diagSAIDList = new List<String>();
	for ( ID i : diagnosesbySA.keyset()) {
		diagSAIDList.add( string.valueOf(i));
	}
	strDiagSAIDList = string.join(diagSAIDList, ',');
	
	// diagnoses not linked to SA
	diagnosesnoSA = [ select id, icd__c, icd__r.name, icd__r.icd_description__c, status__c, type__c, effective_date__c  from diagnosis__c where pbs__c = :thePBS.Id and id not in (select diagnosis__c from serviceassignment_Diagnosis_jo__c where service_Assignment__r.admission__r.person_being_served__c = :thePBS.id) order by createddate];

	// service assignments
	serviceAssignments = [select id, sa_hidden__c, episode__c, name, status__c, service_location__r.alias_lookup__r.name, service_location__r.programid__c, service_location__r.iserve_program__c, service_location__r.service_type__c, sa_start_datetime__c, end_date__c from service_assignment__c where admission__r.person_being_served__c = :thePBS.Id order by name];

	// admissions + service assignments 
	admissions = [ select id, name, status__c, admission_effective_datetime__c, admitted_from__c, discharged_date__c, discharged_date_time__c, discharged_to__c, discharged_to_category__c, discharged_to_subcategory__c, discharged_to_other__c,
					(select id, name, status__c, sa_start_datetime__c,  Child_Service_Goal__c, Child_Permanency_Goal__c, Number_of_Out_of_Home_Placements_Pre_Ser__c, Rancho_Score__c, 
						service_location__r.alias_lookup__r.name, service_location__r.programid__c, service_location__r.iserve_program__c, service_location__r.location_nickname__c, service_location__r.street__c, service_location__r.city__c, service_location__r.state__c, service_location__r.zip__c, service_location__r.physical_location__c, service_location__r.service_type__c, service_location__r.network_offering__c, service_location__r.tmn_scope__c, service_location__r.population_served__c,
						End_Date__c, Was_Child_Service_or_Permanency_Goal_met__c, Total_no_of_Internal_moves_during_Servic__c, End_of_Service_Circumstances__c, Was_dissatisfaction_reason_for_service_e__c, Who_was_dissatisfied__c, 	Primary_Reason_for_Dissatisfaction__c 
						from service_agreements__r
						where status__c != 'Created in Error' 
						order by name
					) 	
					  from admission__c where person_being_served__c = :thePBS.Id order by name];

	admissionStatusCount = new Map<Id, List<Integer>>(); 
	for ( Admission__c a : admissions ) {
		integer iActive = 0;
		integer iInactive= 0;
		for ( Service_Assignment__c sa : a.service_agreements__r ) {
			if ( sa.Status__c == 'Active')
				iActive += 1;
			else
				iInactive += 1;
			
		}
		admissionStatusCount.put( a.id, new List<Integer>{ iActive, iInactive});
		
		
	}
	
}

}