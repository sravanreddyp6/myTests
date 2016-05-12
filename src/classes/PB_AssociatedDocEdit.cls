public with sharing class PB_AssociatedDocEdit {
public ApexPages.StandardController assocDocEditCntrlr {get;set;}


public PB_AssociatedDocEdit(ApexPages.StandardController controller){
    this.assocDocEditCntrlr = controller;	
}

public pageReference save(){
    assocDocEditCntrlr.save();
    Pagereference pg =  new Pagereference('/apex/Home');
    pg.setRedirect(true);
    return pg;
}
  

}