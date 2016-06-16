/*
Class :  Utility
Created by : Doug Surfleet (Appirio)
Created Date: 5/7/2013
Description: Hold a bunch of utility methods for use in other Apex classes
 */

public without sharing class Utility {

	public static final Integer STATE_COUNT = 52;
	public static final Map<String,String> STATE_MAP = new Map<String,String> {
		'Alabama' => 'AL',
		'Alaska' => 'AK',
		'Arizona' => 'AZ',
		'Arkansas' => 'AR',
		'California' => 'CA',
		'Colorado' => 'CO',
		'Connecticut' => 'CT',
		'Delaware' => 'DE',
		'District of Columbia' => 'DC',
		'Florida' => 'FL',
		'Georgia' => 'GA',
		'Hawaii' => 'HI',
		'Idaho' => 'ID',
		'Illinois' => 'IL',
		'Indiana' => 'IN',
		'Iowa' => 'IA',
		'Kansas' => 'KS',
		'Kentucky' => 'KY',
		'Louisiana' => 'LA',
		'Maine' => 'ME',
		'Maryland' => 'MD',
		'Massachusetts' => 'MA',
		'Michigan' => 'MI',
		'Minnesota' => 'MN',
		'Mississippi' => 'MS',
		'Missouri' => 'MO',
		'Montana' => 'MT',
		'Nebraska' => 'NE',
		'Nevada' => 'NV',
		'New Hampshire' => 'NH',
		'New Jersey' => 'NJ',
		'New Mexico' => 'NM',
		'New York' => 'NY',
		'North Carolina' => 'NC',
		'North Dakota' => 'ND',
		'Ohio' => 'OH',
		'Oklahoma' => 'OK',
		'Oregon' => 'OR',
		'Pennsylvania' => 'PA',
		'Rhode Island' => 'RI',
		'South Carolina' => 'SC',
		'South Dakota' => 'SD',
		'Tennessee' => 'TN',
		'Texas' => 'TX',
		'Utah' => 'UT',
		'Vermont' => 'VT',
		'Virginia' => 'VA',
		'Washington' => 'WA',
		'West Virginia' => 'WV',
		'Wisconsin' => 'WI',
		'Wyoming' => 'WY',
		'CareMeridian' => 'CM',
		'NeuroRestorative' => 'NR',
		'Adult Day Health' => 'AH'
	};

	public static final Map<String,String> REVERSED_STATE_MAP= new Map<String,String>{
		'AL'=>'Alabama',
		'AK'=>'Alaska',
		'AZ'=>'Arizona',
		'AR'=>'Arkansas',
		'CA'=>'California',
		'CO'=>'Colorado',
		'CT'=>'Connecticut',
		'DC' => 'District of Columbia' ,
		'DE'=>'Delaware',
		'FL'=>'Florida',
		'GA'=>'Georgia',
		'HI'=>'Hawaii',
		'ID'=>'Idaho',
		'IL'=>'Illinois',
		'IN'=>'Indiana',
		'IA'=>'Iowa',
		'KS'=>'Kansas',
		'KY'=>'Kentucky',
		'LA'=>'Louisiana',
		'ME'=>'Maine',
		'MD'=>'Maryland',
		'MA'=>'Massachusetts',
		'MI'=>'Michigan',
		'MN'=>'Minnesota',
		'MS'=>'Mississippi',
		'MO'=>'Missouri',
		'MT'=>'Montana',
		'NE'=>'Nebraska',
		'NV'=>'Nevada',
		'NH'=>'New Hampshire',
		'NJ'=>'New Jersey',
		'NM'=>'New Mexico',
		'NY'=>'New York',
		'NC'=>'North Carolina',
		'ND'=>'North Dakota',
		'OH'=>'Ohio',
		'OK'=>'Oklahoma',
		'OR'=>'Oregon',
		'PA'=>'Pennsylvania',
		'RI'=>'Rhode Island',
		'SC'=>'South Carolina',
		'SD'=>'South Dakota',
		'TN'=>'Tennessee',
		'TX'=>'Texas',
		'UT'=>'Utah',
		'VT'=>'Vermont',
		'VA'=>'Virginia',
		'WA'=>'Washington',
		'WV'=>'West Virginia',
		'WI'=>'Wisconsin',
		'WY'=>'Wyoming',
		'CM'=>'CareMeridian',
		'NR'=>'NeuroRestorative',
		'AH'=>'Adult Day Health'

	};

	public static Set<String> currentUserPermissionSets = null;

	static Map<String,Schema.RecordTypeInfo> rtMapByNameForReferral = null;
	static Map<Id,Schema.RecordTypeInfo> rtMapByIdForReferral = null;
	static Map<String,Schema.RecordTypeInfo> rtMapByNameForTask = null;
	static Map<String,Schema.RecordTypeInfo> rtMapByNameForFundingSource = null;


	public static void InsertStateCustomSettings(){
		if(State_Settings__c.getAll().keySet().isEmpty()){
			List<State_Settings__c> l = new List<State_settings__c>();
			for(String s: state_map.keySet()){
				l.add(new State_settings__c(acronym__c = state_map.get(s),name = s));
			}
			try{
				insert l;
			}catch(dmlexception e){

			}
		}
	}

	/**
	 * Backwards compatibility purpose. This method is used for Redwood, or Generic
	 * record type only.
	 */
	public static Id getRecordTypeForReferral(string recordType) {
		return getRecordTypeForReferral(recordType, null);
	}

	public static Id getRecordTypeForReferral(String recordType, String operatingGroup) {
		if(rtMapByNameForReferral == null) {
			Schema.DescribeSObjectResult d1 = Schema.SObjectType.Referral__c;
			rtMapByNameForReferral = d1.getRecordTypeInfosByName();
		}
		Schema.RecordTypeInfo recordTypeDetail;
		if (operatingGroup == null) {  // Redwood or Generic
			recordTypeDetail = rtMapByNameForReferral.get(recordType);
		} else {
			recordTypeDetail = rtMapByNameForReferral.get(operatingGroup + ' ' + recordType);
		}
		if(recordTypeDetail != null) {
			return recordTypeDetail.getRecordTypeId();
		} else {
			return null;
		}
	}

	public static String getRecordTypeNameForReferralObject(Referral__c referral) {
		if (rtMapByIdForReferral == null) {
			Schema.DescribeSObjectResult d1 = Schema.SObjectType.Referral__c;
			rtMapByIdForReferral = d1.getRecordTypeInfosById();
		}
		return rtMapByIdForReferral.get(referral.RecordTypeId).getName();
	}

	public static String getRecordTypeForReferral(Id recordType) {
		return getRecordTypeForReferral(recordType, null);
	}

	public static String getRecordTypeForReferral(Id recordType, String operatingGroup) {
		system.debug( 'Entry to getrecordtypeforreferral with: ' + recordType );
		if(rtMapByIdForReferral == null) {
			Schema.DescribeSObjectResult d1 = Schema.SObjectType.Referral__c;
			rtMapByIdForReferral = d1.getRecordTypeInfosById();
		}
		System.debug(rtMapByIdForReferral);
		Schema.RecordTypeInfo recordTypeDetail;
		if (operatingGroup == null) {
			recordTypeDetail = rtMapByIdForReferral.get(recordType);
		} else {
			recordTypeDetail = rtMapByIdForReferral.get(operatingGroup + ' ' + recordType);
		}
		if(recordTypeDetail != null) {
			return recordTypeDetail.getName();
		} else {
			return null;
		}
	}

	public static Id getRecordTypeForTask(string recordType) {
		if(rtMapByNameForTask == null) {
			Schema.DescribeSObjectResult d1 = Schema.SObjectType.Task;
			rtMapByNameForTask = d1.getRecordTypeInfosByName();
		}
		Schema.RecordTypeInfo recordTypeDetail = rtMapByNameForTask.get(recordType);
		if(recordTypeDetail != null) {
			return recordTypeDetail.getRecordTypeId();
		} else {
			return null;
		}
	}

	public static Id getRecordTypeForFundingSource(string recordType) {
		if(rtMapByNameForFundingSource == null) {
			Schema.DescribeSObjectResult d1 = Schema.SObjectType.Funding_Source__c;
			rtMapByNameForFundingSource = d1.getRecordTypeInfosByName();
		}
		Schema.RecordTypeInfo recordTypeDetail = rtMapByNameForFundingSource.get(recordType);
		if(recordTypeDetail != null) {
			return recordTypeDetail.getRecordTypeId();
		} else {
			return null;
		}
	}

	public static Id getFundingSourceRecordTypeFromReferral(Referral__c referral) {
		if(rtMapByIDForReferral == null) {
			Schema.DescribeSObjectResult d1 = Schema.SObjectType.Referral__c;
			rtMapByIdForReferral = d1.getRecordTypeInfosById();
		}

		Schema.RecordTypeInfo recordTypeDetail = rtMapByIdForReferral.get(referral.recordTypeId);
		if(recordTypeDetail != null) {
			return getRecordTypeForFundingSource(recordTypeDetail.Name);//(getRecordTypeForFundingSource(recordTypeDetail.Name)!=null)?getRecordTypeForFundingSource(recordTypeDetail.Name):getRecordTypeForFundingSource(referral.State_For_Preferred_Service__c);
		} else {
			return getRecordTypeForFundingSource('Generic');
		}
	}

	public static Id getRelatedPartyRecordTypeFromReferral(Referral__c referral) {
		if(rtMapByIDForReferral == null) {
			Schema.DescribeSObjectResult d1 = Schema.SObjectType.Referral__c;
			rtMapByIdForReferral = d1.getRecordTypeInfosById();
		}
		Schema.DescribeSObjectResult d2 = Schema.SObjectType.Related_Party__c;
		Map<String, Schema.RecordtypeInfo> relatedPartyRT = d2.getRecordTypeInfosByName();
		Schema.RecordTypeInfo recordTypeDetail = rtMapByIdForReferral.get(referral.recordTypeId);
		if(recordTypeDetail != null) {
			if (recordTypeDetail.getName().startsWith('Cambridge')) {
				return relatedPartyRT.get('Cambridge').recordTypeId;
			} else if (recordTypeDetail.getName() == 'CareMeridian') {
				return relatedPartyRT.get('CareMeridian').recordTypeId;
			} else {
				return relatedPartyRT.get('Generic').recordTypeId;
			}
		} else {
			return relatedPartyRT.get('Generic').recordTypeId;
		}
	}

	public static Id getRelatedPartyRecordType(String recordTypeName) {
		return Schema.SObjectType.Related_Party__c.getRecordTypeInfosByName().get(recordTypeName).recordTypeId;
	}


	public static Id getEvaluationResponseRecordType(String recordTypeName) {
		return Schema.SObjectType.Evaluation_Response__c.getRecordTypeInfosByName().get(recordTypeName).recordTypeId;
	}

	public static Id getEValuationRecordType(String recordTypeName){
		return Schema.SObjectType.Evaluation__c.getRecordTypeInfosByName().get(recordTypeName).recordTypeId;
	}

	public static Id getIncidentRecordType(String recordTypeName){
		return Schema.SObjectType.Incident__c.getRecordTypeInfosByName().get(recordTypeName).recordTypeId;
	}

	public static string getIncidentRecordTypeName(Id recordTypeId){
		return Schema.SObjectType.Incident__c.getRecordTypeInfosById().get(recordTypeId).Name;
	}

	public static string getStateCodeFromName ( String statename ) {
		System.Debug(' getting state code for: ' + statename );
		if (String.IsEmpty(statename)) {
			return statename;
		} else {
			return STATE_MAP.get(statename);
		}
	}

	public static string getStateNameFromCode ( String statecode ) {
		if (String.IsEmpty(statecode)) {
			return statecode;
		} else {
			return REVERSED_STATE_MAP.get(statecode);
		}
	}

	public static list<SelectOption> getPicklistValues(SObject obj, String fld){
		list<SelectOption> options = new list<SelectOption>();
		// Get the object type of the SObject.
		Schema.sObjectType objType = obj.getSObjectType();
		// Describe the SObject using its object type.
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		// Get a map of fields for the SObject
		map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
		// Get the list of picklist values for this field.
		list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
		// Add these values to the selectoption list.
		for (Schema.PicklistEntry a : values){
			options.add(new SelectOption(a.getLabel(), a.getValue()));
		}
		return options;
	}

	public static string getCreatableFieldsSOQL(String objectName, String whereClause) {
		String selects = '';
		if (whereClause == null || whereClause == '') {
			return null;
		}

		// Get a map of field name and field token
		Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
		list<string> selectFields = new list<string>();

		if (fMap != null) {
			for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
				Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
				if (fd.isCreateable()){ // field is creatable
					selectFields.add(fd.getName());
				}
			}
		}

		if (!selectFields.isEmpty()) {
			for (string s:selectFields){
				selects += s + ',';
			}
			if (selects.endsWith(',')) {
				selects = selects.substring(0,selects.lastIndexOf(','));
			}
		}
		return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
	}

	public static string getMilitarytime(Datetime dt){
		return dt.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString() );
	}
	public static string getMilitarytimeNoSeconds(Datetime dt){
		return dt.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString() );
	}
	public static Datetime getDateTimeFromString(String dateTimeStr) {
		string stringDate='';
		try {
			stringDate = dateTimeStr.substring(6,10) + '-' +dateTimeStr.substring(0,2) + '-' + dateTimeStr.substring(3,5) + ' ' + dateTimeStr.substring(11);
			return Datetime.valueOf(stringDate);
		} catch (Exception e) {
			system.debug(e);
		}
		return null;
	}

	public static Boolean currentUserHasPermissionSet(String permissionSetName) {
		if (currentUserPermissionSets == null) {
			currentUserPermissionSets = new Set<String>();
			for (PermissionSetAssignment assignment: [
				SELECT Id, PermissionSet.Name
				  FROM PermissionSetAssignment
				 WHERE AssigneeId = :UserInfo.getUserId()
			]) {
				currentUserPermissionSets.add(assignment.PermissionSet.Name);
			}
		}
		return currentUserPermissionSets.contains(permissionSetName);
	}
 	public static String  getAge(String numOfyears,String numOfmonths,String numOfdays){
		Integer year = 0;
		Integer month = 0;
		Integer days = 0;
		if(numOfyears!=null)
		 year = Integer.valueOf(numOfyears);
		if(numOfmonths!=null)
		 month = Integer.valueOf(numOfmonths);
		 if(numOfdays!=null)
		 days = Integer.valueOf(numOfdays);
		if(year >0){
			if (year == 1){
			return year +' Year';
			}
		return  year +' Years';
		} else if( year == 0  &&  month > 0 ) {
			if (month == 1) {
			return   month +' Month';
			}
		return   month +' Months';
		}else if( year == 0 &&   month == 0 ) {
			if (days == 1){
			return  days +' Day';
			}
		return  days +' Days';
		}
		return '';
	}

	/**
	 * This returns an array of Integers with 3 elements, the 1st is the year difference, the 2nd
	 * is the month difference, and the 3rd is the day difference
	 */
	public static List<Integer> calculateDateDifference(Date fromDate, Date toDate) {
		if (fromDate < toDate) {
			Date tempDate = fromDate;
			fromDate = toDate;
			toDate = tempDate;
		}
		Integer yearDiff =  fromDate.year() - toDate.year();
		Integer monthDiff = fromDate.month() - toDate.month();
		Integer dayDiff = 0;
		if (monthDiff < 0) {
			yearDiff--;
			monthDiff = 12 - toDate.month() + fromDate.month();
		} else if (monthDiff == 0 && fromDate.day() < toDate.day()) {
				yearDiff--;
				monthDiff = 11;
		}
		if (fromDate.day() < toDate.day()){
			monthDiff--;
		}
		if (fromDate.day() > toDate.day()) {
			dayDiff = fromDate.day() - toDate.day();
		} else if (fromDate.day() < toDate.day()) {
			dayDiff = Date.daysInMonth(fromDate.year(), fromDate.month() -1) - toDate.day() + fromDate.day();
		} else {
			dayDiff = 0;
			if (monthDiff == 12) {
				yearDiff++;
				monthDiff = 0;
			}
		}
		return new Integer[] { yearDiff, monthDiff, dayDiff };
	}


	/**
	This method gives business date  after given numOfDays from given start date.
	I am putting loop count to 15 because i need max 8th business day, If any body want different days, they can increase loop count.
	*/
	public static Date nextBusinessDay(Date startDate,Integer numOfDays) {
		Date saturday = Date.newInstance(2015, 10, 31);
		Date sunday = Date.newInstance(2015, 11, 1);
		Integer count = 0;
		for (integer i=1; i<15; i++) {
			startDate = startDate.addDays(1);
			if( !(Math.mod(startDate.daysBetween(saturday), 7) == 0 || Math.mod(startDate.daysBetween(sunday), 7) == 0) ) {
				count++;
				if(numOfDays == count) {
					return startDate;
				}
			}
		}
		return null;
	}

	public class CustomException extends Exception {}

	public static final String IMPLEMENTATION_EXCEPTION_MESSAGE = 'ERROR: Your account must be reconfigured before you begin using the system. Please contact the Implementation Team at Implementation@thementornetwork.com or the IT Service Center at 888-774-4872.';

	public static Service_Location__c[] getServiceLocationsForTMNUser(TMN_User__c user) {
		return [
			SELECT Id
			  FROM Service_Location__c
			 WHERE Alias_Lookup__c =:user.Alias_lookup__c
			   AND Status__c = 'Active'
		];
	}


	public static TMN_User__c getManagerForTMNUser(TMN_User__c user) {
		List<TMN_User__c> accountableMgr = [
			SELECT id, name
			  FROM TMN_User__c
			 WHERE email__c =:user.Accountable_Manager_Mentor_Email__c
		];
		if (accountableMgr.size() != 1) {
			return null;
		}
		return accountableMgr[0];
	}

	public static final Map<String,Decimal> FACILITYID_MAP = new Map<String,Decimal> {
		'AL'=>500,
		'AK'=>502,
		'AZ'=>14,
		'AR'=>503,
		'CA'=>7,
		'CO'=>504,
		'CT'=>505,
		'DC' =>529,
		'DE'=>9,
		'FL'=>10,
		'GA'=>11,
		'HI'=>506,
		'ID'=>507,
		'IL'=>58,
		'IN'=>18,
		'IA'=>41,
		'KS'=>508,
		'KY'=>509,
		'LA'=>510,
		'ME'=>511,
		'MD'=>3,
		'MA'=>26,
		'MI'=>28,
		'MN'=>5,
		'MS'=>512,
		'MO'=>513,
		'MT'=>514,
		'NE'=>515,
		'NV'=>495,
		'NH'=>516,
		'NJ'=>8,
		'NM'=>517,
		'NY'=>518,
		'NC'=>4,
		'ND'=>475,
		'OH'=>16,
		'OK'=>519,
		'OR'=>38,
		'PA'=>30,
		'RI'=>520,
		'SC'=>501,
		'SD'=>521,
		'TN'=>522,
		'TX'=>523,
		'UT'=>524,
		'VT'=>525,
		'VA'=>526,
		'WA'=>527,
		'WV'=>1,
		'WI'=>12,
		'WY'=>528,
		'CareMeridian'=>13,
		'NeuroRestorative'=>20,
		'Adult Day Health'=> 29
	};

	/**
	 * The following class is used to generate unique error messages for use with .addError() method
	 * by Apex. By default, if the errors string passed into addError are similar, the Visualforce
	 * page will only display it once in the pageMessages, even though that error might apply to
	 * multiple fields. By using this class, we can work around the issue by appending a non-visible
	 * character to each error message, making them unique.
	 */
	public class ErrorGenerator {
		private Map<String, Integer> errorMap;
		private final String CHARACTER = String.fromCharArray(new Integer[]{ 0 });

		public ErrorGenerator() {
			errorMap = new Map<String, Integer>();
		}
		public String generate(String errorMessage) {
			if (!errorMap.containsKey(errorMessage)) {
				errorMap.put(errorMessage, 0);
			}
			errorMap.put(errorMessage, errorMap.get(errorMessage) + 1);
			String resultMessage = errorMessage;
			for (Integer i = 0; i < errorMap.get(errorMessage); i++) {
				resultMessage += CHARACTER;
			}
			return resultMessage;
		}
	}

}