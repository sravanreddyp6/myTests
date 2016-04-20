global class Sch_rpt_Auth_Utilization_Batch implements Database.Batchable<sObject> {
  global final list<User> query ;
global Sch_rpt_Auth_Utilization_Batch(List<User> q){
    system.debug('starting construct');
    query=q; 
}
global list<SObject> start(Database.BatchableContext bc) {
    //system.debug('starting start');
    
    return query;
  }

     global void execute(Database.BatchableContext BC, List<User> scope) {

       system.debug('starting ex');
       //string devMsg = '';
      try {
          date sDate = system.today().addDays(-8);
          date eDate = system.today().addDays(-4);
          Sch_rpt_Auth_Utilization_helper helper = new Sch_rpt_Auth_Utilization_helper (sDate,eDate);
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(helper.getAttach());
            string csvname= 'Authorization Utilization report - '+ simpleDate(sDate) + ' to ' + simpleDate(eDate) + '.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);          
          //csvData = helper.getAttach();
          Messaging.reserveSingleEmailCapacity(scope.size());
          for(user u: scope){
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
              //User idForAssmtDeveloper = [ SELECT Id FROM User WHERE FirstName = 'Paul' AND LastName = 'Perisic' LIMIT 1];
        
              mail.setTargetObjectId(u.Id);
              mail.setReplyTo('notifications@thementornetwork.com');
              mail.setSenderDisplayName('DNR');
              mail.setSubject('Authorization Utilization report - '+ simpleDate(sDate) + ' to ' + simpleDate(eDate) );
              mail.setBccSender(false);
              mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});  
              mail.setUseSignature(false);
              mail.setHtmlBody('See attached report' ) ;
              mail.setSaveAsActivity(false);
              List<Messaging.SingleEmailMessage> allEmail = new List<Messaging.SingleEmailMessage>();
              allEmail.add(mail);          
              Messaging.sendEmail(allEmail);
        }

    }
    catch( Exception e ){
      Messaging.reserveSingleEmailCapacity(1);
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

      User idForAssmtDeveloper = [ SELECT Id FROM User WHERE FirstName = 'Paul' AND LastName = 'Perisic' LIMIT 1];

      mail.setTargetObjectId(idForAssmtDeveloper.Id);
      mail.setReplyTo('notifications@thementornetwork.com');
      mail.setSenderDisplayName('FAILURE: MENTOR Auth Utilization Notification');
      mail.setSubject('FAILURE: MENTOR Auth Utilization Notification');
      mail.setBccSender(false);
      //mail.setccAddresses(new string[] {'_TMN_Dev_Team@thementornetwork.com'});
      mail.setUseSignature(false);
      mail.setHtmlBody('Hello an error occured: <br/>' + e + '<br/>Stack trace:' + e.getStackTraceString() ) ;
      mail.setSaveAsActivity(false);
      List<Messaging.SingleEmailMessage> errorEmail = new List<Messaging.SingleEmailMessage>();
      errorEmail.add(mail);
      Messaging.sendEmail(errorEmail);

    }
  }

  
  
  global void finish(Database.BatchableContext BC) {
 
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        User idForAssmtDeveloper = [ SELECT Id FROM User WHERE FirstName = 'Paul' AND LastName = 'Perisic' LIMIT 1];

        mail.setTargetObjectId(idForAssmtDeveloper.Id);
        mail.setReplyTo('notifications@thementornetwork.com');
        mail.setSenderDisplayName('Complete: MENTOR Auth Utilization Notification');
        mail.setSubject('Complete: MENTOR Incomplete Auth Utilization Notification');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('completed auth report send' ) ;
        mail.setSaveAsActivity(false);
        List<Messaging.SingleEmailMessage> devEmail = new List<Messaging.SingleEmailMessage>();
        devEmail.add(mail);
        Messaging.sendEmail(devEmail);    
  }

    public string simpleDate(date d){
        if (d != null){
            return d.Month()  + '-'+ d.Day()+ '-' + d.year();
        }
        return null;
    }

}