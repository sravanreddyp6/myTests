@isTest
private class EvalRepeatersTest {

    static testMethod void myUnitTest() {
    	
    	TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        Evaluation__c evaluation = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id, shift_start_time__c = Datetime.newInstance(2015,04,27,0,0,0), shift_end_time__c = Datetime.newInstance(2015,05,2,0,0,0));
        insert evaluation;
        
        list<eval__c> evals = TMN_Generic_Core_TestData.getEvalTestRecords();

        list<GenerateEvalComponent.FormKeyVal> evalVals = new list<GenerateEvalComponent.FormKeyVal>();
        for (Eval__c e : [select id, Field_Type__c, Field_Sub_Type__c
                            from eval__c where eval_type__r.name = 'Head to Toe'
                                                   and category__c = 'TEST'
                                                   and sub_category__c = 'TEST_TEST'
                                                   and visible__c = true]){
            GenerateEvalComponent.FormKeyVal val = new GenerateEvalComponent.FormKeyVal();
            val.name= e.id;
            if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'Boolean')
                    val.value = 'True';
            else if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'String')
                    val.value = 'Error Message';
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Checkbox') 
                    val.value = '1';
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Dropdown') 
                    val.value = 'Yes';
            else if(e.Field_Type__c == 'Int' ) 
                    val.value = '12';
            else if(e.Field_Type__c == 'Date') 
                    val.value = '11/12/2013';
            else if(e.Field_Type__c == 'DateTime') 
                    val.value = '04/27/2015 18:00';
            else if(e.Field_Type__c == 'Multiselect') {
                    val.value = 'TEST';
                    GenerateEvalComponent.FormKeyVal val1 = new GenerateEvalComponent.FormKeyVal();
                    val1.name= e.id;
                    val1.value = 'TEST1';
                    evalVals.add(val1);
            }                    
            

            evalVals.add(val);
        }

        Eval_Type__c evlTyp = [Select Name, id from Eval_Type__c where Name = 'Head to Toe'];
        GenerateEvalComponent.saveFields(evaluation.id, UserInfo.getUserId() + '-' + DateTime.now().formatLong(), 
                                        'Shift', evlTyp.Name, 'TEST', 'TEST_TEST', JSON.serialize(evalVals));
        
        system.assert([select id from eval_value__c].size() > 0 );
        
        Test.setCurrentPage(Page.EvalDynamic);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('opGrp', 'Care Meridian');
        
        EvalRepeaters evalRepeaters = new EvalRepeaters();
                                                
        system.assert(evalRepeaters.getEvals().size() > 0 );
        system.assert(!evalRepeaters.getAnyErrors());
        system.assert(evalRepeaters.getAnyEmpty());
    }
    
}