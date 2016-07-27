/*
Created By     : Doug Surfleet (Appirio)
Updated Date   : April 24, 2013
Description    : Trigger handler for PersonBeingReferred object.
*/
public class PersonBeingReferred_TriggerHandler {
	
	/*
	Method		   : UpdateAge
	Params		   : Person_Being_Referred sObject
	Description    : Updates the Age field if the Date of Birth is filled in.
	Created By     : Doug Surfleet (Appirio)
	Updated Date   : April 24, 2013
	*/
	public static void UpdateAge(Person_Being_Referred__c pbr) {
		if (pbr.Date_of_Birth__c != null) {
			Date now = Date.today();
			decimal months = Decimal.valueOf(pbr.Date_of_Birth__c.MonthsBetween(now));
			decimal age = months.divide(12,0,System.RoundingMode.DOWN);
			pbr.age__c = age;
		}
	}

}