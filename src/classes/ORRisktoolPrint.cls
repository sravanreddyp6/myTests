public class ORRisktoolPrint{
	Apexpages.StandardController controller;
	public Case_Management_Plan__c isp {get; set;}
	public List<Evaluation_Response__c> evaluations {get; set;}
	public List<Evaluation_Response__c> contributors = new List<Evaluation_Response__c>();	
	public List<wContributor> wContributors {get; set;}
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
	
	public ORRisktoolPrint(Apexpages.StandardController controller){
		this.controller = controller;
		this.isp = (Case_Management_Plan__c)controller.getRecord();
		evaluations = new List<Evaluation_Response__c>();
		evaluations = [SELECT ISP_Risks__c, ISP_Specify_Other__c, ISP_Type_of_evaluation__c, ISP_Evaluation_Date__c, ISP_Has_condition_changed_evaluation__c, ISP_Where_evaluation_is_kept__c
    							FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Evaluation'];					
 	    contributors = [SELECT ISP_Contributor_Name__c
    							FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Contributors_Signatures' order by CreatedDate asc];
        wContributors = new List<wContributor>();
        prepareContributorList(contributors);
	}
	
	//This is needed because in word document there are two columns to display the data.
	public void prepareContributorList(List<Evaluation_Response__c> contributors){
		integer j = 0;
		for(integer i=0; i < (contributors.size()+1)/2; i++){
			wContributor wC = new wContributor();
			if(math.mod(j, 2) == 0 && j < contributors.size()){
				wC.name1 = contributors[j].ISP_Contributor_Name__c.substringBeforeLast('--');
				wC.relation1 = contributors[j].ISP_Contributor_Name__c.substringAfterLast('--');
				j = j+1;
			}
			if(math.mod(j, 2) != 0 && j < contributors.size()){
				wC.name2 = contributors[j].ISP_Contributor_Name__c.substringBeforeLast('--');
				wC.relation2 = contributors[j].ISP_Contributor_Name__c.substringAfterLast('--');
				j= j+1;
			}
			
			wContributors.add(wC);
		}
	}
	
	
	public class wContributor{
		public string name1 {get;set;}
		public string relation1 {get; set;}
		public string name2 {get;set;}
		public string relation2 {get; set;}
		
		public wContributor(){
			
		}
	}

}