
@isTest
private class MilitaryDatetimeControllerTest {

    static testMethod void myUnitTest() {
    	Datetime myDateTime = Datetime.now();
 		MilitaryDatetimeController cntlr = new MilitaryDatetimeController();
		cntlr.dateTimeValue = myDateTime;
		
		system.assertEquals(cntlr.getTimeZoneValue(), myDateTime.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString()));		

    }
}