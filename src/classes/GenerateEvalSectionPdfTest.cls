@isTest
private class GenerateEvalSectionPdfTest {
    static list < Eval__c > newEvals = new list < Eval__c > ();

    static testMethod void myUnitTest() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        Evaluation__c evaluation = new Evaluation__c(shift_start_time__c=DateTime.now().addDays(-1), shift_end_time__c=DateTime.now().addDays(1), Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;

        createData();

        Eval_Type__c evlTyp = [Select Name, id from Eval_Type__c where Name = 'TEST'];

        list<GenerateEvalComponent.FormKeyVal> evalVals = new list<GenerateEvalComponent.FormKeyVal>();
        String evalSecId = UserInfo.getUserId() + '-' + DateTime.now().formatLong();
        for (Eval__c e : newEvals){
            GenerateEvalComponent.FormKeyVal val = new GenerateEvalComponent.FormKeyVal();
            val.name= e.id;
            if (e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'Boolean')
                val.value = 'True';
            else if(e.Field_Type__c == 'Hidden' && e.Field_Sub_Type__c == 'String')
                val.value = 'Error Message';
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Checkbox')
                val.value = '1';
            else if(e.Field_Type__c == 'Boolean' && e.Field_Sub_Type__c == 'Dropdown')
                val.value = 'TEST';
            else if(e.Field_Type__c == 'Int' )
                val.value = '12';
            else if(e.Field_Type__c == 'Date')
                val.value = '11/12/2013';
            else if(e.Field_Type__c == 'DateTime')
                val.value = '2015/04/27 18:00';
            else if(e.Field_Type__c == 'Multiselect') {
                val.value = 'TEST';
                GenerateEvalComponent.FormKeyVal val1 = new GenerateEvalComponent.FormKeyVal();
                val1.name= e.id;
                val1.value = 'TEST1';
                evalVals.add(val1);
            }
            else
                val.value = 'String,ID,Dropdown,Double,Currency values.';

            evalVals.add(val);
            GenerateEvalComponent.FormKeyVal valEsi = new GenerateEvalComponent.FormKeyVal();
            valEsi.name = e.id + '_esi';
            valEsi.value = evalSecId;
            evalVals.add(valEsi);
        }

        GenerateEvalComponent.saveFields(evaluation.id, UserInfo.getUserId() + '-' + DateTime.now().formatLong(),
                                        'Shift', evlTyp.Name, JSON.serialize(evalVals), false, false);

        pageReference pageRef = Page.EvalLogView;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evalname', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('cat', 'TEST');
        Apexpages.currentPage().getParameters().put('subCat', 'TEST_TEST');
        GenerateEvalSectionPDF evalComponent = new GenerateEvalSectionPDF();

        system.assert(GenerateEvalSectionPDF.mapEvalItems.size() > 0);
        system.assert(evalComponent.mapEntryHTML.size() > 0);
        system.assert(evalComponent.getApprovalHistory().size() == 0);
        system.assert(evalComponent.assessments.size() == 0);
        system.assert(evalComponent.getAnnotations('').size() == 0);
    }

    private static void createData() {
        //create Eval_Type__c records
        Eval_Type__c evlTyp = new Eval_Type__c(Name = 'TEST', Category__c = 'TEST', External_Eval_Type_ID__c = 1);
        insert evlTyp;

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'IsValid',
        htmlid__c = 'IsValid',
        Field_Type__c = 'Hidden',
        Field_Sub_Type__c = 'Boolean',
        Field_Sequence__c = Decimal.valueOf('0.00')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c='ErrorMsg',
        htmlid__c='ErrorMsg',
        Field_Type__c='Hidden',
        Field_Sub_Type__c='String',
        Field_Sequence__c=Decimal.valueOf('0.10')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Checkbox',
        htmlid__c = 'Boolean_Checkbox',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('1.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',
        Field_Name__c = 'Boolean_Dropdown',
        htmlid__c = 'Boolean_Dropdown',
        Field_Type__c = 'Boolean',
        Field_Sub_Type__c = 'Dropdown',
        Field_Sequence__c = Decimal.valueOf('2.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        length__c = 3000,
        Field_Name__c = 'String_3000',
        htmlid__c = 'String_3000',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'String_300',
        htmlid__c = 'String_300',
        Field_Type__c = 'String',
        Field_Sequence__c = Decimal.valueOf('3.1')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Double',
        htmlid__c = 'Double',
        Field_Type__c = 'Double',
        Field_Sequence__c = Decimal.valueOf('4.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Int',
        htmlid__c = 'Int',
        Field_Type__c = 'Int',
        Field_Sequence__c = Decimal.valueOf('5.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'DropDown',
        htmlid__c = 'DropDown',
        Field_Type__c = 'DropDown',
        Field_Sequence__c = Decimal.valueOf('6.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Date',
        htmlid__c = 'Date',
        Field_Type__c = 'Date',
        Field_Sequence__c = Decimal.valueOf('7.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Datetime',
        htmlid__c = 'Datetime',
        Field_Type__c = 'Datetime',
        Field_Sequence__c = Decimal.valueOf('8.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = true,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Multiselect_Checkbox',
        htmlid__c = 'Multiselect_Checkbox',
        Field_Type__c = 'Multiselect',
        Field_Sub_Type__c = 'Checkbox',
        Field_Sequence__c = Decimal.valueOf('9.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Multiselect',
        htmlid__c = 'Multiselect',
        Field_Type__c = 'Multiselect',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'BodyMap',
        htmlid__c = 'BodyMap',
        Field_Type__c = 'BodyMap',
        Field_Sequence__c = Decimal.valueOf('11.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Image',
        htmlid__c = 'Image',
        Field_Type__c = 'Image',
        field_sub_type__c= 'Image',
        Field_Sequence__c = Decimal.valueOf('12.0')));

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'TEST',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'TEST_TEST',
        Sub_Category_Sequence__c = 1,
        SubCat_Seq_Text__c = '1',



        Field_Name__c = 'Slider',
        htmlid__c = 'Slider',
        Field_Type__c = 'Slider',
        Field_Sequence__c = Decimal.valueOf('10.0')));

        insert newEvals;

        list < eval_drop_down__c > dropdowns = new list < eval_drop_down__c > ();
        //create eval_drop_down__c
        for (eval__c eval: [Select Id from Eval__c where Category__c = 'TEST' and (Field_Type__c = 'DropDown' Or Field_Type__c = 'Multiselect')] ) {
            dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST', option_value__c = 'TEST'));
            dropdowns.add(new eval_drop_down__c(What_Id_Object__c = 'Eval__c', whatid__c = eval.id, option_name__c = 'TEST1', option_value__c = 'TEST1'));
        }
        insert dropdowns;

    }
}