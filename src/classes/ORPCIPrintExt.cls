public with sharing class ORPCIPrintExt {
     public Case_Management_plan__c isp {get; set;}
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

    public ORPCIPrintExt(ApexPages.StandardController controller) {
        this.isp = (Case_Management_Plan__c) controller.getRecord();
        contributors = [SELECT ISP_Contributor_Name__c, ISP_Title_Relationship_Person__c
    							FROM Evaluation_Response__c WHERE Case_Management_Plan__c = :this.isp.Id AND Recordtype.DEVELOPERNAME = 'Contributors_Signatures' 
    							AND PCI_Contributor_to_Person_Centered__c = true  order by CreatedDate asc];
        wContributors = new List<wContributor>();
        prepareContributorList(contributors);
    }
    //This is needed because in word document there are two columns to display the data.
	public void prepareContributorList(List<Evaluation_Response__c> contributors){
		integer j = 0;
		for(integer i=0; i < (contributors.size()+1)/2; i++){
			wContributor wC = new wContributor();
			if(math.mod(j, 2) == 0 && j < contributors.size()){
				wC.name1 = contributors[j].ISP_Contributor_Name__c;
				wC.relation1 = contributors[j].ISP_Title_Relationship_Person__c;
				j = j+1;
			}
			if(math.mod(j, 2) != 0 && j < contributors.size()){
				wC.name2 = contributors[j].ISP_Contributor_Name__c;
				wC.relation2 = contributors[j].ISP_Title_Relationship_Person__c;
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