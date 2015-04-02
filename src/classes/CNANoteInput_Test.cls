@isTest
private class CNANoteInput_Test {

    static testMethod void simpleTest() {
    	
    	// set up the eval
    	List<Eval__c> newrows  = new List<Eval__c>();
    	
    	Eval_type__c newevaltype = new Eval_type__c ( name='CNA Workbook', category__c = 'Care Meridian');
    	insert newevaltype;
    	newevaltype = [ select id from eval_type__c where name='CNA Workbook' and category__c = 'Care Meridian' LIMIT 1];
    	
    	Eval__c newRec = new Eval__c( eval_Type__c = newevaltype.id,
    									category__c = 'Diagnostics',
    									sub_category__c = 'Vitals',
    									field_name__c = 'Blood Pressure',
    									field_type__c = 'string',
    									length__c = 10,
    									htmlid__c = 'signsBP');
    									
		newrows.add( newRec);
    	newRec = new Eval__c( eval_Type__c = newevaltype.id,
    									category__c = 'Diagnostics',
    									sub_category__c = 'Vitals',
    									field_name__c = 'Date/Time',
    									field_type__c = 'Datetime',
    									length__c = 50,
    									htmlid__c = 'signsDateTime');


    	newrows.add( newRec );
    	
    	newRec = new Eval__c( eval_Type__c = newevaltype.id,
    									category__c = 'Diagnostics',
    									sub_category__c = 'Vitals',
    									field_name__c = 'Temperature',
    									field_type__c = 'String',
    									length__c = 50,
    									htmlid__c = 'signsTemp');


    	newrows.add( newRec );
    	
    	insert newrows;
    	
    	// need a PBS, evaluation
		TMN_Generic_Core_TestData testData = new TMN_Generic_Core_TestData();
		testData.LoadData('CA');
		
		ID rtID = [select id from recordtype where sobjecttype='Evaluation__c' and developername = 'CNA_Workbook'].ID;
		
        Evaluation__c eval = new Evaluation__c(recordtypeid = rtID, serviceassignment__c= testData.theSA.Id);
        insert eval;
    	string XML = 
        '<?xml version="1.0" encoding="UTF-8"?>'+ 
		'<form first-page="111.111">' +
		  '<submit email="test@thementornetwork.com" />' +
		  '<field type="boxed" name="eval-signsTime_1" normalized-score="1" resemblance-score="1">1210</field>' +
		  '<field type="boxed" name="eval-signsTime_2" normalized-score="0.919" resemblance-score="0.699">1315</field>' +
		  '<field type="boxed" name="eval-signsTime_3" normalized-score="1" resemblance-score="1">0909</field>' +
		  '<field type="boxed" name="eval-signsBP1_1" normalized-score="1" resemblance-score="1">111</field>' +
		  '<field type="boxed" name="eval-signsBP2_1" normalized-score="1" resemblance-score="1">11</field>' +
		  '<field type="boxed" name="eval-signsTemp_1" normalized-score="1" resemblance-score="1">100</field>' +
		  '<field type="boxed" name="eval-signsHeartRate_1" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsO2Sat_1" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsLbs_1" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsoz_1" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signskgs_1" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsBP1_2" normalized-score="0.957" resemblance-score="0.795">190</field>' +
		  '<field type="boxed" name="eval-signsBP2_2" normalized-score="0.959" resemblance-score="0.701">17</field>' +
		  '<field type="boxed" name="eval-signsTemp_2" normalized-score="0.957" resemblance-score="0.797">142</field>' +
		  '<field type="boxed" name="eval-signsHeartRate_2" normalized-score="0.941" resemblance-score="0.733">210</field>' +
		  '<field type="boxed" name="eval-signsO2Sat_2" normalized-score="0.991" resemblance-score="0.94">77</field>' +
		  '<field type="boxed" name="eval-signsLbs_2" normalized-score="0.87" resemblance-score="0.63">999</field>' +
		  '<field type="boxed" name="eval-signsoz_2" normalized-score="0.99" resemblance-score="0.759">15</field>' +
		  '<field type="boxed" name="eval-signskgs_2" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signskg_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsoz_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signslbs_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsO2Sat_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsHeartRate_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsTemp_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsBP2_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsBP1_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="boxed" name="eval-signsDate_1" normalized-score="1" resemblance-score="1">03222015</field>' +
		  '<field type="boxed" name="eval-signsDate_2" normalized-score="0.741" resemblance-score="0.727">03232015</field>' +
		  '<field type="boxed" name="eval-signsDate_3" normalized-score="1" resemblance-score="1">03242015</field>' +
		  '<field type="boxed" name="eval-signstempPoints_1" normalized-score="1" resemblance-score="1">a</field>' +
		  '<field type="boxed" name="eval-signstempPoints_2" normalized-score="1" resemblance-score="0.947">7</field>' +
		  '<field type="boxed" name="eval-signstempPoints_3" normalized-score="1" resemblance-score="1"></field>' +
		  '<field type="textfield" name="PBSName" normalized-score="1" resemblance-score="1"></field>' +
  		  '<field type="textfield" name="Guardian" normalized-score="1" resemblance-score="1"></field>' +
  		  '<field type="textfield" name="ADField" normalized-score="1" resemblance-score="1"></field>' +
  		  '<field type="textfield" name="PBSNumber" normalized-score="1" resemblance-score="1"></field>' +
  		  '<field type="textfield" name="GuardianPhone" normalized-score="1" resemblance-score="1"></field>' +
  		  '<field type="textfield" name="CodeStatus" normalized-score="1" resemblance-score="1"></field>' +
  		   '<field type="textfield" name="DOB" normalized-score="1" resemblance-score="1"></field>' +
			'</form>';

		System.debug(xml);
	    CNANoteInput handler = new CNANoteInput();
	    handler.handle(eval.Id, 'xml', Blob.valueOf(xml), new RestRequest(), new RestResponse());
    	
    	// handler writes entries to eval_value__c - select those and assert we have correct values
    	Eval_value__c[] evList = [select eval_section_id__c, eval__c, what_id__c, what_id_object__c, boolean__c, text_under_250__c, text_over_250__c, number_no_decimal__c, date_time__c
    					from eval_value__c
    					where eval_section_type__c = 'CNA Workbook'
    					and	what_id__c = :eval.ID
    					and what_id_object__c = 'Evaluation__c'
    					order by eval_section_id__c];
    
    	system.debug( evList );
    	
    	// assert the values are correct 
    	System.AssertEquals( evList.size(), 6);
    	
    						
    }
    
   
}