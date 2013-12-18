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
'NeuroRestorative' => 'NR'
  };

    public static final Map<String,String> REVERSED_STATE_MAP= new Map<String,String>{
          'AL'=>'Alabama',
'AK'=>'Alaska',
'AZ'=>'Arizona',
'AR'=>'Arkansas',
'CA'=>'California',
'CO'=>'Colorado',
'CT'=>'Connecticut',
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
'NR'=>'NeuroRestorative'
                                      };

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
        }/*else{
            if(State_Settings__c.getAll().keySet().size()!=STATE_COUNT){
                List<State_Settings__c> l = new List<State_settings__c>();
                for(String s: state_map.keySet()){
                    l.add(new State_settings__c(acronym__c = state_map.get(s),name = s));
                }
                try{
                    delete State_Settings__c.getAll().values();
                    insert l;
                }catch(dmlexception e){

                }
            }
        }*/
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

    public static Id getEvaluationResponseRecordType(String recordTypeName) {
        return Schema.SObjectType.Evaluation_Response__c.getRecordTypeInfosByName().get(recordTypeName).recordTypeId;
    }
}