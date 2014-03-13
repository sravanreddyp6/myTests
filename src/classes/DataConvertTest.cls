/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DataConvertTest {
    static testMethod void NumericConversion() {
    	System.assertEquals(123, DataConvert.ToInteger('123'));
    	System.assertEquals(123, DataConvert.ToLong('123'));
    	System.assertEquals(123.0, DataConvert.ToDouble('123'));
    	System.assertEquals(123.0, DataConvert.ToDecimal('123'));
    	System.assertEquals('123', DataConvert.ToString(123));
    	System.assertEquals('123', DataConvert.ToString(123.0));
    }
    
    static long ToLong(object testval){
    	return DataConvert.ToLong(testval);
    }

    static integer ToInteger(object testval){
    	return DataConvert.ToInteger(testval);
    }

    static decimal ToDecimal(object testval){
    	return DataConvert.ToDecimal(testval);
    }

    static double ToDouble(object testval){
    	return DataConvert.ToDouble(testval);
    }

    static boolean ToBoolean(object testval){
    	return DataConvert.ToBoolean(testval);
    }

    static Date ToDate(object testval){
    	return DataConvert.ToDate(testval);
    }

    static DateTime ToDateTime(object testval){
    	return DataConvert.ToDateTime(testval);
    }

    static Time ToTime(object testval){
    	return DataConvert.ToTime(testval);
    }

    static String ToString(object testval){
    	return DataConvert.ToString(testval);
    }

    static testMethod void LongConversion() {
    	System.assertEquals(123, ToLong('123'));
    	System.assertEquals(123, ToLong('123.0'));
    	System.assertEquals(123, ToLong(123.0));
    	System.assertEquals(123, ToLong(123L));
    	System.assertEquals(123, ToLong(123));
    	decimal testdecimal = 123.0D;
    	System.assertEquals(123, ToLong(testdecimal));
    	System.assertEquals(123, ToInteger(testdecimal));
    	System.assertEquals(123.0, ToDouble(testdecimal));
    	System.assertEquals(123.0, ToDecimal(testdecimal));
    	System.assertEquals('123', ToString(testdecimal));
    	double testdouble = 123.0;
    	System.assertEquals(123, ToLong(testdouble));
    	System.assertEquals(123, ToInteger(testdouble));
    	System.assertEquals(123.0, ToDecimal(testdouble));
    	System.assertEquals(123.0, ToDouble(testdouble));
    	System.assertEquals('123', ToString(testdouble));
    	integer testinteger = 123;
    	System.assertEquals(123, ToLong(testinteger));
    	System.assertEquals(123, ToInteger(testinteger));
    	System.assertEquals(123.0, ToDecimal(testinteger));
    	System.assertEquals(123.0, ToDouble(testinteger));
    	System.assertEquals('123', ToString(testinteger));
    }
    static testMethod void IntConversion() {
    	System.assertEquals(123, ToInteger('123'));
    	System.assertEquals(123, ToInteger('123.0'));
    	System.assertEquals(123, ToInteger(123.0));
    	System.assertEquals(123, ToInteger(123L));
    	System.assertEquals(123, ToInteger(123));
    }
    static testMethod void DoubleConversion() {
    	System.assertEquals(123, ToDouble('123'));
    	System.assertEquals(123, ToDouble('123.0'));
    	System.assertEquals(123, ToDouble(123.0));
    	System.assertEquals(123, ToDouble(123L));
    	System.assertEquals(123, ToDouble(123));
    }
    static testMethod void DecimalConversion() {
    	System.assertEquals(123, ToDecimal('123'));
    	System.assertEquals(123, ToDecimal('123.0'));
    	System.assertEquals(123, ToDecimal(123.0));
    	System.assertEquals(123, ToDecimal(123L));
    	System.assertEquals(123, ToDecimal(123));
    }

    static testMethod void BooleanConversion() {
    	System.assertEquals(true, ToBoolean('true'));
    	System.assertEquals(false, ToBoolean('false'));
    	System.assertEquals(true, ToBoolean(true));
    	System.assertEquals(false, ToBoolean(false));
    	//System.assertEquals(true, ToBoolean(1));
    	//System.assertEquals(false, ToBoolean(0));
    }

    static testMethod void DateTimeConversion() {
    	System.assertEquals(date.newinstance(2000,1,10), ToDate('1/10/2000'));
    	System.assertEquals(date.newinstance(2000,1,10), ToDate(datetime.newinstance(2000,1,10,13,5,0)));
    	System.assertEquals('1/10/2000', ToString(date.newinstance(2000,1,10)));
    	System.assertEquals(time.newinstance(13,5,6,0), ToTime('13:05:06'));
    	System.assertEquals(time.newinstance(13,5,6,0), ToTime(time.newinstance(13,5,6,0)));
    	System.assertEquals('13:5:6', ToString(time.newinstance(13,5,6,0)));
    	System.assertEquals(datetime.newinstance(2000,1,10,13,5,0), ToDateTime('1/10/2000 1:05 PM'));
    	System.assertEquals(datetime.newinstanceGMT(2000,1,10,0,0,0), ToDateTime(date.newinstance(2000,1,10)));
    	System.assertEquals(datetime.newinstance(2000,1,10,13,5,0), ToDateTime(datetime.newinstance(2000,1,10,13,5,0)));
    	System.assertEquals('1/10/2000 1:05 PM', ToString(datetime.newinstance(2000,1,10,13,5,6)));
    }
    
        static testMethod void StringConversion() {
    		System.assertEquals('123', ToString(123L));
    		System.assertEquals('true', ToString(true));
    		System.assertEquals('false', ToString(false));
        }
    
}