@isTest
public class SoundExTest{
    testmethod static void testing(){
        Person_Being_Referred__c pbr= new Person_being_Referred__c(last_name__c= 'MyEasyLastName', first_name__c='MyEasyFirstName');
        Person_Being_Referred__c pbr2= new Person_being_Referred__c(last_name__c= '', first_name__c='MyNonEmptyFirstName');
        Account acct= new Account(lastname='MyMoreThanComplicatedLastName', firstname='MyMoreThanComplicatedFirstName');
        Account acct2= new Account(lastname='MyNonEmptyLastName', firstname='');
        TMN_Contact__c tmn = new TMN_Contact__c(First_Name__c='testfname1',Last_Name__c='testlanme1');
        TMN_Contact__c tmn2 = new TMN_Contact__c(First_Name__c='testfname2',Last_Name__c='testlanme2');
        insert new List<Account>{acct,acct2};
        insert new List<Person_Being_Referred__c>{pbr,pbr2};
        insert new List<TMN_Contact__c>{tmn,tmn2};
        List<Account> qAccts= [select first_name_soundex_key__c, last_name_soundex_key__c, firstname, lastname from account where id = :acct.id or id=: acct2.id];
        List<Person_Being_Referred__c> qPbrs= [select first_name_soundex_key__c, last_name_soundex_key__c, first_name__c, last_name__c from Person_Being_Referred__c where id=:pbr.id or id=:pbr2.id];
        List<TMN_Contact__c> qtmns= [select id,First_Name_SoundEx_Key__c, Last_Name_SoundEx_Key__c, First_Name__c, Last_Name__c from TMN_Contact__c where id=:tmn.id or id=:tmn2.id];
        
        System.debug(' pbr lastname '+qpbrs[0].last_name__c+' pbr firstname ' + qpbrs[0].first_name__c+' pbr lastname key '+qpbrs[0].last_name_soundex_key__c+' pbr firstname key '+qpbrs[0].first_name_soundex_key__c);
        System.debug(' pbr2 lastname '+qpbrs[1].last_name__c+' pbr2 firstname ' + qpbrs[1].first_name__c+' pbr2 lastname key '+qpbrs[1].last_name_soundex_key__c+' pbr2 firstname key '+qpbrs[1].first_name_soundex_key__c);
        System.debug(' acct lastname '+qaccts[0].lastname+' acct firstname ' +qaccts[0].firstname+ ' acct lastname key '+qaccts[0].last_name_soundex_key__c+' acct firstname key '+qaccts[0].first_name_soundex_key__c);
        System.debug(' acct2 lastname '+qaccts[1].lastname+' acct2 firstname ' +qaccts[1].firstname+ ' acct2 lastname key '+qaccts[1].last_name_soundex_key__c+' acct2 firstname key '+qaccts[1].first_name_soundex_key__c);
        System.debug(' tmn lastname '+qtmns[0].Last_Name__c+' tmn firstname ' +qtmns[0].First_Name__c+ ' tmn lastname key '+qtmns[0].Last_Name_SoundEx_Key__c+' tmn firstname key '+qtmns[0].First_Name_SoundEx_Key__c);
        System.debug(' tmn2 lastname '+qtmns[1].Last_Name__c+' tmn2 firstname ' +qtmns[1].First_Name__c+ ' tmn2 lastname key '+qtmns[1].Last_Name_SoundEx_Key__c+' tmn2 firstname key '+qtmns[1].First_Name_SoundEx_Key__c);
      
        SoundExTriggerUtil util = new SoundExTriggerUtil();
        util.generateKeys( qAccts);
        util.generateKeys( qPbrs );
        util.generateKeys( qtmns );
    }
}