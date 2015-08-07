@isTest
private class EvalDynamicExtTest {
    static list < Eval__c > newEvals = new list < Eval__c > ();
    static Pattern militaryTimePattern = Pattern.compile('^(([0-1]?[0-9])|([2][0-3])):([0-5]?[0-9])(:([0-5]?[0-9]))?$');

    static testMethod void buttonsVisibility() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        EvalDynamicExt extension;
        Evaluation__c evaluation;
        Eval_Type__c evlTyp;
        PageReference pageRef;
        createData();


        evaluation = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;

        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Residential'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'TEST');
        Apexpages.currentPage().getParameters().put('SubCategory', 'TEST_TEST');
        extension =  new EvalDynamicExt();
		
		if ( extension.isTierIII ) {
	        System.assertEquals(true, extension.showEsign);
	        System.assertEquals(false, extension.showRevise);
	        System.assertEquals(true, extension.showDisregard);
        } else {
  	        System.assertEquals(false, extension.showEsign);
	        System.assertEquals(false, extension.showRevise);
	        System.assertEquals(false, extension.showDisregard);
        }      
        evaluation.Status__c = 'Final Admission';
        upsert evaluation;

        extension =  new EvalDynamicExt();
        if ( extension.isTierIII ) {
	        System.assertEquals(false, extension.showEsign);
	        System.assertEquals(true, extension.showRevise);
	        System.assertEquals(true, extension.showDisregard);
        } else {
  	        System.assertEquals(false, extension.showEsign);
	        System.assertEquals(false, extension.showRevise);
	        System.assertEquals(false, extension.showDisregard);
        }      

        Matcher MyMatcher = militaryTimePattern.matcher(extension.getEvalStatusDate().substring(11));
        System.assert(MyMatcher.matches());
        MyMatcher = militaryTimePattern.matcher(extension.getshiftCreatedDate().substring(11));
        System.assert(MyMatcher.matches());

        insert new Evaluation__c(Status__c = 'Draft', RecordtypeId = Utility.getEvaluationRecordType('NursesAssessment'), ServiceAssignment__c = myData.theSA.Id);

        evaluation.Status__c = 'Final Revision';
        upsert evaluation;

        if ( extension.isTierIII ) {
	        System.assertEquals(false, extension.showEsign);
	        System.assertEquals(true, extension.showRevise);
	        System.assertEquals(true, extension.showDisregard);
        } else {
  	        System.assertEquals(false, extension.showEsign);
	        System.assertEquals(false, extension.showRevise);
	        System.assertEquals(false, extension.showDisregard);
        }      
    }
    static testMethod void buttonsVisibilityHeadToToe() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        EvalDynamicExt extension;
        Evaluation__c evaluation;
        Eval_Type__c evlTyp;
        PageReference pageRef;
        createData();
        //head to toe
        evaluation = new Evaluation__c(Status__c = 'Draft', Shift_Start_Time__c = DateTime.now(), Shift_End_Time__c = DateTime.now().addHours(2), Head_to_Toe_Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;
        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Head to Toe'];
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);

        extension =  new EvalDynamicExt();
        System.assertEquals(true, extension.showEsign);
        System.assertEquals(true, extension.showDisregard);
        System.assertEquals(false, extension.showshiftDone);

        Matcher MyMatcher1 = militaryTimePattern.matcher(extension.getEvalStatusDate().substring(11));
        System.assert(MyMatcher1.matches());
        MyMatcher1 = militaryTimePattern.matcher(extension.getshiftStartTime().substring(11));
        System.assert(MyMatcher1.matches());
        MyMatcher1 = militaryTimePattern.matcher(extension.getshiftEndTime().substring(11));
        System.assert(MyMatcher1.matches());


        evaluation.Head_to_toe_Status__c = 'Final';
        upsert evaluation;
        extension =  new EvalDynamicExt();
        System.assertEquals(false, extension.showEsign);
        System.assertEquals(true, extension.showDisregard);
        System.assertEquals(true, extension.showshiftDone);

        evaluation.Status__c = 'Completed';
        upsert evaluation;
        extension =  new EvalDynamicExt();
        System.assertEquals(false, extension.showEsign);
        System.assertEquals(true, extension.showDisregard);
        System.assertEquals(false, extension.showshiftDone);
    }
    static testMethod void buttonsVisibilityRestrained() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        EvalDynamicExt extension;
        Evaluation__c evaluation;
        Eval_Type__c evlTyp;
        PageReference pageRef;
        createData();

        //Restrained
        evaluation = new Evaluation__c(Status__c = 'Not Restrained', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;
        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Restraint Event'];
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);

        extension =  new EvalDynamicExt();
        System.assertEquals(true, extension.showEsign);
        System.assertEquals(true, extension.showDisregard);
        System.assertEquals(false, extension.showshiftDone);
        System.assertEquals(false, extension.showRevise);

        evaluation.Status__c = 'Disregard';
        upsert evaluation;
        extension =  new EvalDynamicExt();
        System.assertEquals(false, extension.showEsign);
        System.assertEquals(false, extension.showDisregard);
        System.assertEquals(false, extension.showshiftDone);

        evaluation.Status__c = 'Applied Alternative to Restraint';
        upsert evaluation;
        extension =  new EvalDynamicExt();
        System.assertEquals(false, extension.showEsign);
        System.assertEquals(true, extension.showDisregard);
        System.assertEquals(true, extension.showshiftDone);
    }
    static testMethod void buttonsVisibilityCNA() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        EvalDynamicExt extension;
        Evaluation__c evaluation;
        Eval_Type__c evlTyp;
        PageReference pageRef;
        createData();
        
        //CNA Workbook
        evaluation = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;
        evlTyp = [Select Name, id from Eval_Type__c where Name = 'CNA Workbook'];
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);

        extension =  new EvalDynamicExt();
        System.assertEquals(true, extension.showEsign);
        System.assertEquals(true, extension.showDisregard);
        System.assertEquals(false, extension.showshiftDone);
        System.assertEquals(false, extension.showRevise);

        evaluation.Status__c = 'Pending Approval';
        upsert evaluation;
        extension =  new EvalDynamicExt();
        System.assertEquals(false, extension.showApprove);
    }

   static testMethod void testMyAction() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        EvalDynamicExt extension;
        Evaluation__c evaluation;
        Eval_Type__c evlTyp;
        PageReference pageRef;
        createData();


        evaluation = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;

        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Head to Toe'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'TEST');
        Apexpages.currentPage().getParameters().put('SubCategory', 'TEST_TEST');
        extension =  new EvalDynamicExt();
        extension.myAction();
        system.assert(extension.showMainComponent);

        Apexpages.currentPage().getParameters().put('Category', 'Skin/Body');
        Apexpages.currentPage().getParameters().put('SubCategory', 'Wound Detail');
        extension =  new EvalDynamicExt();
        extension.myAction();
        system.assert(!extension.showMainComponent);


        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Residential'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'Skin/Body');
        Apexpages.currentPage().getParameters().put('SubCategory', 'Wound Detail');
        extension =  new EvalDynamicExt();
        extension.myAction();
        system.assert(!extension.showMainComponent);

        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Residential'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'Skin/Body');
        Apexpages.currentPage().getParameters().put('SubCategory', 'Wound Detail');
        extension = new EvalDynamicExt();
        extension.evalSecId = UserInfo.getUserId() + '-' + DateTime.now().formatLong();

        Eval__c isValidRec = [select id from Eval__c where Category__c = 'Skin/Body'
                                 and Sub_Category__c = 'Wound Detail'
                                 and Field_Name__c = 'IsValid' limit 1];

        insert (new Eval_value__c(Boolean__c =false, what_id__c = evaluation.id,
                        Eval__c=isValidRec.id, Eval_Section_Id__c = extension.evalSecId, What_ID_Object__c = 'Evaluation__c' ) );

        extension.myAction();
        system.assert(!extension.showMainComponent);


        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Restraint Event'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'Reduction Review');
        Apexpages.currentPage().getParameters().put('SubCategory', 'Reduction Review');
        extension = new EvalDynamicExt();
        extension.myAction();
        system.assert(!extension.showMainComponent);
        system.assert(extension.currentAssessId != null);

        extension = new EvalDynamicExt();
        extension.evalSecId = UserInfo.getUserId() + '-' + DateTime.now().formatLong();
        extension.myAction();
        system.assert(!extension.showMainComponent);
        system.assert(extension.currentAssessId == null);

    }


    static testMethod void testReviseDisregradAssessment() {
        TMN_Generic_Core_TestData myData = new TMN_Generic_Core_TestData();
        EvalDynamicExt extension;
        Evaluation__c evaluation;
        Eval_Type__c evlTyp;
        PageReference pageRef;
        createData();

        evaluation = new Evaluation__c(Status__c = 'Draft', ServiceAssignment__c = myData.theSA.Id);
        insert evaluation;

        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Head to Toe'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'TEST');
        Apexpages.currentPage().getParameters().put('SubCategory', 'TEST_TEST');
        extension =  new EvalDynamicExt();
        pageReference newPage = extension.reviseAssessment();
        system.assert(newPage.getParameters().get('evalID') != evaluation.id);

        newPage = extension.disregardAssessment();
        system.assert(newPage.getParameters().get('evalID') != evaluation.id);



        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Residential'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'TEST');
        Apexpages.currentPage().getParameters().put('SubCategory', 'TEST_TEST');
        extension =  new EvalDynamicExt();
        newPage = extension.reviseAssessment();
        system.assert(newPage.getParameters().get('evalID') != evaluation.id);

        newPage = extension.disregardAssessment();
        system.assert(newPage.getParameters().get('evalID') == evaluation.id);


        evlTyp = [Select Name, id from Eval_Type__c where Name = 'Restraint Event'];
        pageRef = Page.EvalDynamic;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('evalID', evaluation.id);
        Apexpages.currentPage().getParameters().put('evaltype', evlTyp.Name);
        Apexpages.currentPage().getParameters().put('Category', 'TEST');
        Apexpages.currentPage().getParameters().put('SubCategory', 'TEST_TEST');
        extension =  new EvalDynamicExt();
        newPage = extension.disregardAssessment();
        system.assert(newPage.getParameters().get('evalID') == evaluation.id);


    }


    private static void createData() {
        //create Eval_Type__c records
        list<Eval_Type__c> evlTyps = new list<Eval_Type__c>();
        evlTyps.add(new Eval_Type__c(Name = 'Residential', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 1));
        evlTyps.add(new Eval_Type__c(Name = 'Head to Toe', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 2));
        evlTyps.add(new Eval_Type__c(Name = 'CNA Workbook', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 3));
        evlTyps.add(new Eval_Type__c(Name = 'Restraint Event', Category__c = 'Care Meridian', External_Eval_Type_ID__c = 4));
        insert evlTyps;

        Eval_Type__c evlTyp = [Select Name from Eval_Type__c where Name = 'Head to Toe'];

        newEvals.add(new Eval__c(Eval_Type__c = evlTyp.id,
        Required__c = false,
        Category__c = 'Skin/Body',
        Category_Sequence__c = 1,
        Cat_Seq_Text__c = '1',
        Sub_Category__c = 'Wound Detail',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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
        sub_sub_category__c = 'TEST_TEST_TEST',
        Sub_Sub_Category_Sequence__c = 1,
        SubSubCat_Seq_Text__c = '1',
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