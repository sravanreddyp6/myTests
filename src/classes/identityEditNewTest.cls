@isTest
public with sharing class identityEditNewTest {
    
    private static TMN_User__c TMNUser { get;  set; }
    
    static testmethod void identityEdit(){
        List<TMN_User__c> newTmnUser = 	PDMControllerTest.tmnUsers();
        TMN_User__c manager = [SELECT Id, Email__c FROM TMN_User__c WHERE Email__c = 'shaun@tmntest.com' LIMIT 1];
        PageReference ref = Page.identity_create;
        test.setCurrentPage(ref);
        ref.getParameters().put('LN', 'TestLast1');
        //ref.getParameters().put('TAU', 'adam.vernatter1@thementornetwork.com');
        ref.getParameters().put('TAU', manager.Id);
        ref.getParameters().put('FN', 'TestFirst1');
        
        String aliasName = 'adam.vernatter1@thementornetwork.com';
        Attachment attach = new Attachment();
        attach.ParentId = newTmnUser[0].id;
        attach.Name ='Test String';
        attach.body = blob.ValueOf('test data');
        insert attach;
        ref.getParameters().put('ID', newTmnUser[0].id);
        User testUser = [SELECT Id FROM User WHERE Id =:newTmnUser[0].Salesforce_User_Account__c];
        Alias__c alias =	PDMControllerTest.getNewAlias('111111'); 
        system.runas(testUser){
            
            ApexPages.StandardController sc = new ApexPages.StandardController( newTMNUser[0]);
            identityEditNew identity = new identityEditNew(sc);
            //identity.id = newTmnUser[0].id;
            identity.attchmentId = attach.id;
            identity.aliasUser = newTmnUser[0];
            identity.auAlias = alias;
            //identity.aliasName = aliasName;
            identity.aliasName = manager.Id;
            identity.myManager = '';
            identity.myOpGroup= '';
            
            system.assert(identity.myManager == '');
            system.assert(identity.myOpGroup == '');
            identity.goRequestAccess();
            identity.goTerminate();
        }		
    }
    
    static testmethod void identityNew(){
        List<TMN_User__c> newTmnUser = 	PDMControllerTest.tmnUsers();
        TMN_User__c manager = [SELECT Id, Email__c FROM TMN_User__c WHERE Email__c = 'shaun@tmntest.com' LIMIT 1];
        Attachment attach = new Attachment();
        attach.ParentId = newTmnUser[0].id;
        attach.Name ='Test String';
        attach.body = blob.ValueOf('test data');
        insert attach;
        
        PageReference ref = Page.identity_create;
        test.setCurrentPage(ref);
        ref.getParameters().put('LN', 'TestLast1');
        //ref.getParameters().put('TAU', 'adam.vernatter1@thementornetwork.com');
        ref.getParameters().put('TAU', manager.id);
        ref.getParameters().put('FN', 'TestFirst1');
        ref.getParameters().put('retURL', '/apex/identity_nonemployees');
        //String aliasName = 'adam.vernatter1@thementornetwork.com';
        String aliasName = manager.id;
        User testUser = [SELECT Id FROM User WHERE Id =:newTmnUser[0].Salesforce_User_Account__c];
        Alias__c alias =	PDMControllerTest.getNewAlias('222222'); 
        system.runas(testUser){
            ApexPages.StandardController sc = new ApexPages.StandardController( newTMNUser[0]);
            identityEditNew identity = new identityEditNew(sc);
            
            system.assert(((map<String,String>) JSON.DeSerialize(identity.getGlCodesForTherapist(), map<String,String>.class )).keySet().contains('Physical Therapy'));
            system.assert(identityEditNew.validate(manager.Email__c));
            system.assert(identity.getVendorvalues().size() == 3);
            identityEditNew.sendPreHireEmail(newTmnUser);
            identity.sendEmail(newTmnUser[0]);

            ref.getParameters().put('attchmentId', String.valueOf(attach.Id));
            identity.attDeatils = attach;
            identity.attchmentId = identity.attachmentView.Id;
            identity.attachmentDeatils();
            identity.goAttachmentEdit();
            identity.saveAttachment();
            identity.updateAttachment();
            identity.deleteattachment();
            
            
            //identity.id = newTmnUser[0].id;
            identity.retURL = '/apex/identity_nonemployees';
            identity.aliasUser = newTmnUser[0];
            identity.auAlias = alias;
            identity.aliasName = aliasName;
            alias =	PDMControllerTest.getNewAlias('333333');
            identity.TMNUser.Alias__c = alias.Alias_unique__c;
            identity.updateAliasInfo();
            identity.save();
            identity.createCancel();
            
            identityEditNew.setJobStatus(newTmnUser);
            identity.goEdit();
            identity.goCancel();
            identity.goBack();
            identity.closePopup();
            identity.displayPopup =true;
            identity.showPopup();
            
            identity.getManagerList();

        }		
    }
    
    
}