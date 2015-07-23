@isTest
public with sharing class CareMeridianAnotoFormHandlerTests {
    static testmethod void simpleTests() {
        Person_Being_Referred__c pbr = new Person_Being_Referred__c();
        insert pbr;
        Referral__c referral = new Referral__c(Person_Being_Referred__c=pbr.Id);
        insert referral;
        Evaluation__c eval = new Evaluation__c(Referral__c=referral.Id);
        insert eval;
        Related_Party__c rp = new Related_Party__c(
            Person_Being_Referred__c=pbr.Id,
            Name = 'Test',
            Paper_Id__c = '111.111-2'
        );
        insert rp;
        String xml =
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<form first-page="111.111">' +
                '<field name="date-person_being_referred__c-date_of_birth__c">11/20/1980</field>' +  // DOB
                '<field name="number-evaluation__c-number_of_children__c">2</field>' +  // number, no error
                '<field name="number-evaluation__c-number_of_children_at_home__c">a</field>' +  // number, error
                '<field name="picklist-evaluation__c-code_status__c-Full">true</field>' +  // single, no error
                '<field name="checkbox-evaluation__c-employed__c">true</field>' +
                '<field name="multipicklist-evaluation__c-employment_status__c-Employed">true</field>' +  // multi
                '<field name="multipicklist-evaluation__c-employment_status__c-FT">true</field>' +  // multi
                '<field name="multipicklist-evaluation__c-employment_status__c-PT">false</field>' +  // multi
                '<field name="checkbox-evaluation__c-advanced_directives__c">true</field>' +  // checkbox
                '<field name="picklist-evaluation__c-receptive_language__c-Intact">true</field>' +  // single, error
                '<field name="picklist-evaluation__c-receptive_language__c-Impaired">true</field>' +  // single, error
                '<field name="date-evaluation__c-date_of_injury_onset__c">11/2/2013</field>' +  // date, no error
                '<field name="date-evaluation__c-evaluation_date__c">asdf</field>' +  // date, error
                '<field name="custom-evaluation__c-rancho_level__c-1">true</field>' +  // custom field
                '<field name="custom-evaluation__c-discharge_to__c-acute_rehab">true</field>' +  // custom fields
                '<field name="custom-evaluation__c-discharge_to__c-ltc">true</field>' +  // custom fields
                '<field name="custom-evaluation__c-awareness_of_deficits__c">in</field>' +  // custom field
                '<field name="custom-evaluation__c-safety_awareness__c">asdf</field>' +  // custom field, wrong mapping
                // Evaluation Response
                '<field name="date-evaluation_response__c-lab_detail-date__c__1" stroked="2013-12-05T15:40:13+00:00">asdf</field>' +  // date, error
                '<field name="text-evaluation_response__c-lab_detail-wbc__c__1" stroked="2013-12-05T15:40:13+00:00">Test</field>' +  // text, no error
                '<field name="date-evaluation_response__c-lab_detail-date__c__2">asdf</field>' +  // date, error
                '<field name="date-evaluation_response__c-lab_detail-wbc__c__2"></field>' +  // text, nothing here
                '<field name="date-evaluation_response__c-lab_detail-date__c__3">sad</field>' +
                '<field name="custom-evaluation_response__c-wound_detail-wound_type__c__1" stroked="2013-12-05T15:40:13+00:00">a</field>' +  // custom, correct mapping
                '<field name="custom-evaluation_response__c-wound_detail-wound_type__c__2" stroked="2013-12-05T15:40:13+00:00">sadf</field>' +  // custom, incorrect mapping
                //'<field name="text-evaluation_response__c-allergy-allergy_details__c__1">Test Details</field>' +
                //'<field name="custom-evaluation_response__c-allergy-allergy_type__c__1">F</field>' +
                // Related Party
                '<field name="text-related_party__c-name__1" stroked="2013-12-05T15:40:13+00:00">Test</field>' +
                '<field name="custom-related_party__c-street_address__1" stroked="2013-12-05T15:40:13+00:00">Address 1</field>' +
                '<field name="custom-related_party__c-street_address_2__1" stroked="2013-12-05T15:40:13+00:00">Address 2</field>' +
                '<field name="custom-related_party__c-zip_code__1" stroked="2013-12-05T15:40:13+00:00">02134</field>' +
                '<field name="text-related_party__c-type__c__1" stroked="2013-12-05T15:40:13+00:00">FF</field>' +
                '<field name="custom-related_party__c-phone_1_type__c__1" stroked="2013-12-05T15:40:13+00:00">asdf</field>' +
                // Updating RP
                '<field name="text-related_party__c-phone__c__2" stroked="2013-12-05T15:40:13+00:00">1234567890</field>' +
            '</form>';
        System.debug(xml);
        CareMeridianAnotoFormHandler handler = new CareMeridianAnotoFormHandler();
        handler.handle(eval.Id, 'xml', Blob.valueOf(xml), new RestRequest(), new RestResponse());
        eval = [
            SELECT Id, number_of_children__c, number_of_children_at_home__c,
                   code_status__c, employment_status__c, advanced_directives__c,
                   receptive_language__c, date_of_injury_onset__c, discharge_to__c,
                   evaluation_date__c, rancho_level__c, pen_upload_error__c,
                   awareness_of_deficits__c, safety_awareness__c
            FROM Evaluation__c WHERE ID=:eval.Id
        ];
        pbr = [
            SELECT Id, Date_of_Birth__c
            FROM Person_Being_Referred__c WHERE Id=:pbr.Id
        ];
        System.assertEquals(2, eval.Number_of_children__c);
        System.assertEquals(null, eval.Number_of_children_at_home__c);
        System.assertEquals('Full', eval.code_status__c);
        System.assertEquals('FT;Employed', eval.employment_status__c);
        System.assertEquals(true, eval.advanced_directives__c);
        System.assertEquals('(1) No Response', eval.rancho_level__c);
        System.assertEquals('Acute Rehab;LTC', eval.discharge_to__c);
        System.assertEquals('Intact', eval.awareness_of_deficits__c);
        System.assertEquals(null, eval.safety_awareness__c);
        System.assertEquals(null, eval.receptive_language__c);
        System.assertEquals(Date.newInstance(2013, 11, 2), eval.date_of_injury_onset__c);
        System.assertEquals(Date.newInstance(1980, 11, 20), pbr.date_of_birth__c);
        System.assertEquals(null, eval.evaluation_date__c);
        System.assertEquals(2, [SELECT Id FROM Evaluation_Response__c WHERE Evaluation__c=:eval.Id].size());
        eval = [
            SELECT Id, Referral__r.Person_Being_Referred__c, Pen_Upload_Error__c FROM Evaluation__c WHERE Id=:eval.Id
        ];
        Related_Party__c[] rps = [SELECT Id, Name, Address__c, Type__c FROM Related_Party__c WHERE Person_Being_Referred__c=:eval.Referral__r.Person_Being_Referred__c];
        System.assertEquals(2, rps.size());
        rp = [SELECT Id, Phone__c FROM Related_Party__c WHERE Id=:rp.Id];
        System.assertEquals('1234567890', rp.Phone__c);
        System.debug('Related Party: ' + rp);
        System.debug('Pen Upload Errors: ' + eval.Pen_Upload_Error__c);
    }
}