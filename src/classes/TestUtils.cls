@isTest
public with sharing class TestUtils {
	public static Service_Location__c createServiceLocation() {
		Service_location__c serviceLocation = new Service_location__c(
			Name = '123',
			UniqueID__c = String.valueOf(Math.abs(Math.random())),
			FacilityID__c = 123,
			Alias__c = '123',
			ProgramID__c = '123',
			Program__c = '123',
			Service_Value__c = 'CA-MNTR-SL-Rancho-IDD'
		);
		insert serviceLocation;
		return serviceLocation;
	}

	/**
	 * Create TMN User record for the current user with some defaults
	 */
	public static TMN_User__c createTmnUser() {
		return createTmnUser(UserInfo.getUserId(), 'Redwood');
	}

	/**
	 * Create TMN User record for a specified user with custom details
	 */
	public static TMN_User__c createTmnUser(Id userId, String operatingGroup) {
		Tmn_User__c tmnUser = new Tmn_User__c(
			Operating_Group__c = operatingGroup,
			Business_unit__c = 'Test',
			Salesforce_User_Account__c = userId
		);
		insert tmnUser;
		return tmnUser;
	}
}