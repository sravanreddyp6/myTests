@isTest
public with sharing class TMNLocationTest {


private static String location {set;get;}
private static String identityPage {set;get;}
private static String state {set;get;} 
private static List<TMN_User__c> locationList {set;get;}
private static list<AggregateResult> userAggregateResult {set;get;}

		static testmethod void simpleTests(){
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();


			PageReference ref = Page.TMNUser_JSON;
			test.setCurrentPage(ref);
					ref.getParameters().put('location', 'boston');
		//ref.getParameters().put('identityPage', 'identityPage');
		//ref.getParameters().put('state', 'MA');
		List<TMN_User__c> newTmnUser = 	PDMControllerTest.tmnUsers();
	
	TMNLocation tmnlocation =  new TMNLocation();			
					
	//tmnlocation.location ='BOSTON';
	System.debug('tmnlocation.location :' + tmnlocation.location );
	userAggregateResult = tmnlocation.userAggregateResult;
	System.debug('userAggregateResult :' + userAggregateResult );
	//String tmlLocations = tmnlocation.tmlLocations;
	//System.debug('tmlLocations :' + tmlLocations );
	
	String searchLocation = tmnlocation.searchLocation;
			System.debug('searchLocation :' + searchLocation );
			
			new tmnlocation.UserWrapper('boston');
	
			new tmnlocation.LocationWrapper('Bosotn','boston','ma','02111','313 congress st','5th floor');
	
	PageReference ref2 = Page.TMNUser_JSON;
					ref2.getParameters().put('location', 'boston');
		
	 tmnlocation =  new TMNLocation();		
	
	PageReference ref3 = Page.TMNUser_JSON;
					ref3.getParameters().put('location', 'boston');
		ref3.getParameters().put('state', 'MA');
	 tmnlocation =  new TMNLocation();		
	
	
		}

}