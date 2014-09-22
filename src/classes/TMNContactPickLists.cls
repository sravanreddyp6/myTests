global with sharing class TMNContactPickLists {
    TMN_Contact__c tmnContact;
    List<SelectOption> gender;
    List<SelectOption> maritalStatus;
    List<SelectOption> race;
    List<SelectOption> hispHeritage;
    List<SelectOption> dhrCpaRace1;
    List<SelectOption> dhrCpaRace2;
    List<SelectOption> hearAboutUs;
    List<SelectOption> referralTyp;
    List<SelectOption> homeAssctn;
    
    
    public TMNContactPickLists(String id){
    	tmnContact = [select id from tmn_contact__c where id =: id];
    	gender = Utility.getPicklistValues(tmnContact, 'Gender__c');
        maritalStatus = Utility.getPicklistValues(tmnContact, 'Marital_Status__c');    	
    	race = Utility.getPicklistValues(tmnContact, 'Race__c');
    	hispHeritage = Utility.getPicklistValues(tmnContact, 'Hispanic_Heritage__c');
    	dhrCpaRace1 = Utility.getPicklistValues(tmnContact, 'DHR_CPA_Race_1__c');
    	dhrCpaRace2 = Utility.getPicklistValues(tmnContact, 'DHR_CPA_Race_2__c');
    	hearAboutUs = Utility.getPicklistValues(tmnContact, 'How_did_you_hear_about_us__c');
    	referralTyp = Utility.getPicklistValues(tmnContact, 'Referral_Type__c');
    	homeAssctn = Utility.getPicklistValues(tmnContact, 'Population_This_Home_Is_Associated_With__c');
    }



}