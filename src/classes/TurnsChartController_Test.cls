@isTest
private class TurnsChartController_Test {

    static testMethod void turnsTest() {

        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        Evaluation__c evaluation = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id, shift_start_time__c = Datetime.newinstance(2015, 4, 27, 0,0,0), shift_end_time__c = DateTime.newInstance(2015,4,28,0,0,0));
        insert evaluation;

        list<eval__c> evals = TMN_Generic_Core_TestData.getEvalTestRecords();
        Eval_Type__c evlTyp = [Select Name, id from Eval_Type__c where Name = 'CNA Workbook'];

        list<Eval_Value__c> evalVals = new list<Eval_Value__c>();
        for (Eval__c e : [select id, Field_Type__c, Field_Sub_Type__c
                            from eval__c where eval_type__r.name = 'CNA Workbook'
                                                   and category__c = 'Turns'
                                                   and sub_category__c = 'Details'
                                                   and visible__c = true]){

            Eval_Value__c val = new Eval_Value__c(Eval__c = e.Id, Eval_Section_Id__c =  UserInfo.getUserId() + '-' + DateTime.now().formatLong(),
                                        What_ID__c = evaluation.id, What_ID_Object__c = 'Evaluation__c', Eval_Section_Type__c = evlTyp.Name); 
            if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'Boolean') val.Boolean__c = true;
            else if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'String') val.Text_Under_250__c = 'Error Message';
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Checkbox')  val.Boolean__c = true;
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Dropdown')  val.Boolean__c = true;
            else if(e.Field_Type__c == 'Int' )  val.Number_No_Decimal__c = 12;
            else if(e.Field_Type__c == 'Date')  val.Date_Time__c = datetime.newInstance(2013, 11, 12, 0, 0, 0);
            else if(e.Field_Type__c == 'DateTime') val.Date_Time__c = datetime.newInstance(2015, 4, 27, 18, 0, 0);
            else if(e.Field_Type__c == 'String') val.Text_Under_250__c = 'back';
            evalVals.add(val);
        }
        insert evalVals;

        system.assert([select id from eval_value__c].size() > 0 );

	   TurnsChartController controller = new TurnsChartController();
	   controller.setEvalID(evaluation.id);
	   system.assertEquals( controller.turnsInnerKeys.size(), 6 );
    }
}