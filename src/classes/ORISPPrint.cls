public with sharing class ORISPPrint {

    public Case_Management_plan__c isp {get; set;}
    public List<Evaluation_Response__c> desiredOutcomes {get; set;}
    public List<Evaluation_Response__c> employmentOutcomes {get; set;}
    
    public String getPrintView()
    {
        return
        '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
        }

    public ORISPPrint(ApexPages.StandardController controller) {
        this.isp = (Case_Management_Plan__c) controller.getRecord();
        desiredOutcomes  = new List<Evaluation_Response__c>();
        desiredOutComes = [SELECT ISP_What_is_the_desired_result__c, ISP_Key_Steps_to_work_toward_outcome__c, ISP_Is_there_a_paid_Service__c,ISP_Paid_Services__c, ISP_Who_is_responsible__c, ISP_Timelines_Frequency_when__c, ISP_Where_to_Record_progress__c, ISP_Note_if_Written_Implementation__c 
                                FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Desired_Outcomes'];
    	
    	employmentOutcomes = new List<Evaluation_Response__c>();
    	employmentOutcomes = [SELECT ISP_What_is_the_desired_result__c, ISP_Key_Steps_to_work_toward_outcome__c, ISP_Is_there_a_paid_Service__c, ISP_Paid_Services__c, ISP_Who_is_responsible__c, ISP_Timelines_Frequency_when__c, ISP_Where_to_Record_progress__c, ISP_Note_if_Written_Implementation__c
    							FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Employment_Outcomes'];
    }

}