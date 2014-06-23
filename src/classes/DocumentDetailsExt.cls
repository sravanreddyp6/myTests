public class DocumentDetailsExt {
    public ServiceAssignment_Document_JO__c theSadjo { get; private set; }
    public Service_Assignment__c theServAssign { get; private set; }
    public String rddUnits { get; set; }
    public String rddUom { get; set; }
    public String rddEvent { get; set; }
    public String isFixedActiveStyle { get; set; }
    public String isFixedInactiveStyle { get; set; }
    public String isRelativeActiveStyle { get; set; }
    public String isRelativeInactiveStyle { get; set; }
    public String fixedCheckedStatus { get; set; }
    public String relativeCheckedStatus { get; set; }
    public List<SelectOption> selectOptionsRddUom { get; set; }
    public List<SelectOption> selectOptionsRddEvent { get; set; }
    public Boolean updateAllUnfiledDueFroms { get; set; }
        
    public DocumentDetailsExt(ApexPages.StandardController controller) {
        theSadjo = (ServiceAssignment_Document_JO__c)controller.getRecord();
               
        theServAssign = [ SELECT Id, Name, Admission__c, Admission__r.State__c, Program__c, Admission__r.Person_Being_Served__c, Admission__r.Name,
                    Admission__r.Effective_Date__c, Person_Being_Served__c, Start_Date__c, End_Date__c, Projected_Treatment_End_Date__c, 
                    Location_Region__c, Person_Being_Served__r.Owner.Id
                     FROM Service_Assignment__c WHERE Id = :theSadjo.Service_Assignment__c ];
                     
        rddUnits = String.valueOf(theSadjo.Relative_Due_Date_Units__c);
        rddUom = theSadjo.Relative_Due_Date_UOM__c;
        rddEvent = theSadjo.Relative_Due_Date_Event__c;
        
        isFixedActiveStyle = 'display:none';
        isFixedInactiveStyle = 'display:inline';
        isRelativeActiveStyle = 'display:inline';
        isRelativeInactiveStyle = 'display:none';
        fixedCheckedStatus = '';
        relativeCheckedStatus = 'checked';
        if(theSadjo.Relative_Due_Date_Units__c==null) {
            isFixedActiveStyle = 'display:inline';
            isFixedInactiveStyle = 'display:none';
            isRelativeActiveStyle = 'display:none';
            isRelativeInactiveStyle = 'display:inline';            
            fixedCheckedStatus = 'checked';
            relativeCheckedStatus = '';             
        }
/*
        if(theSadjo.Fixed_Due_Date__c==null) {
            isFixedActiveStyle = 'display:none';
            isFixedInactiveStyle = 'display:inline';
            isRelativeActiveStyle = 'display:inline';
            isRelativeInactiveStyle = 'display:none';            
            fixedCheckedStatus = '';
            relativeCheckedStatus = 'checked';            
        }
*/
        
        Schema.DescribeFieldResult fieldInfo = Schema.SObjectType.Document__c.fields.Relative_Due_Date_UOM__c;
        List<Schema.PicklistEntry> picklistValues = fieldInfo.getPicklistValues();
        selectOptionsRddUom = new List<SelectOption>();
        selectOptionsRddUom.add(new SelectOption('--None--','--None--')); 
        for (Schema.PicklistEntry picklistValue : picklistValues) {
            selectOptionsRddUom.add(new SelectOption(picklistValue.getLabel(),picklistValue.getLabel()));
        }      

        Schema.DescribeFieldResult fieldInfo2 = Schema.SObjectType.Document__c.fields.Relative_Due_Date_Event__c;
        List<Schema.PicklistEntry> picklistValues2 = fieldInfo2.getPicklistValues();
        selectOptionsRddEvent = new List<SelectOption>();
        selectOptionsRddEvent.add(new SelectOption('--None--','--None--')); 
        for (Schema.PicklistEntry picklistValue2 : picklistValues2) {
            selectOptionsRddEvent.add(new SelectOption(picklistValue2.getLabel(),picklistValue2.getLabel()));
        }        
    }

    
    public PageReference resetToDefaults() {
        
        Document__c dD = [ SELECT Id, Name, Relative_Due_Date_Units__c, 
                        Relative_Due_Date_UOM__c, Relative_Due_Date_Event__c
                        FROM Document__c WHERE Id = :theSadjo.Document__c ];
        
        
        rddUnits = String.valueOf(dD.Relative_Due_Date_Units__c);
        rddUom = dD.Relative_Due_Date_UOM__c;
        rddEvent = dD.Relative_Due_Date_Event__c;
        theSadjo.Due_From_Employee__c = theServAssign.Person_Being_Served__r.Owner.Id;
        theSadjo.Fixed_Due_Date__c = null;
        isFixedActiveStyle = 'display:none';
        isFixedInactiveStyle = 'display:inline';
        isRelativeActiveStyle = 'display:inline';
        isRelativeInactiveStyle = 'display:none';            
        relativeCheckedStatus = 'checked';
        fixedCheckedStatus = '';

        PageReference refreshPageRef = new PageReference('/apex/DocumentDetails?id=' + theSadjo.Id);
        
        return refreshPageRef;
        
    }

    
    public PageReference saveUpdateXrefs() {
        
        // Add logic for handling saves...
        System.debug('AT SAVE theServAssign: ' + theServAssign);
        System.debug('AT SAVE theSadjo: ' + theSadjo);
        System.debug('AT SAVE theSadjo.Fixed_Due_Date__c: ' + theSadjo.Fixed_Due_Date__c);
        if(rddUnits==null || rddUnits=='') {
            theSadjo.Relative_Due_Date_Units__c = null;
        }
        else {
            theSadjo.Relative_Due_Date_Units__c = Decimal.valueOf(rddUnits);
        }
        theSadjo.Relative_Due_Date_UOM__c = rddUom;
        theSadjo.Relative_Due_Date_Event__c = rddEvent;
        
        System.debug('What is in theSadjo.Due_From_Employee__c at DocumentDetailsExt.saveUpdateXrefs() before docPop() call: ' + theSadjo.Due_From_Employee__c);
        
        DocumentMethods.docPop(theServAssign, theSadjo, theSadjo.Fixed_Due_Date__c, false, true, false, false);
        if(updateAllUnfiledDueFroms==true) {
            DocumentMethods.ChangeDueFrom(theServAssign, theSadjo.Due_From_Employee__c);
        }
        PageReference pageRef = new PageReference('/apex/ServAssignExpectedDocs?id='+theServAssign.Id);
        return pageRef;         
    }


    public void ClearRelativeDueDateFields() {
          rddUnits = null;
          rddUom = '--None--';
          rddEvent = '--None--';     
    }

    
    public void ClearFixedDueDateField() {
          theSadjo.Fixed_Due_Date__c = null;
    }
    
}