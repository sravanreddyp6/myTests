public with sharing class PBSExportForm {
    public ApexPages.StandardController PBSController {get;set;}
    public PBSExportForm(ApexPages.StandardController controller) {
        PBSController = controller;
    }
    
    public void exportPerson(){
        DataCreate util = new DataCreate();
        
        xmlout = '<objects>' + util.Export(PBSController.getrecord()) + '</objects>';
    }
    
    public string xmlOut { get ; set;}

}