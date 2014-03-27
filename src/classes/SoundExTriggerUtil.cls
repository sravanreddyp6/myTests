public without sharing class SoundExTriggerUtil {
    
    public void generateKeys(List<Account> accts){
        for (Account a:accts){
            a.Last_Name_Soundex_Key__c = Soundex.toSoundex(a.LastName);
            a.First_Name_Soundex_Key__c = Soundex.toSoundex(a.FirstName);
        }
    }
    public void generateKeys(List<Person_Being_Referred__c> pbrs){
        for (Person_being_Referred__c pbr:pbrs){
            pbr.Last_Name_Soundex_Key__c = Soundex.toSoundex(pbr.Last_Name__c);
            pbr.First_Name_Soundex_Key__c = Soundex.toSoundex(pbr.First_Name__c);
        }
    }
     public void generateKeys(List<TMN_Contact__c> tmns){
        for (TMN_Contact__c tmn:tmns){
            tmn.Last_Name_SoundEx_Key__c = Soundex.toSoundex(tmn.Last_Name__c);
            tmn.First_Name_SoundEx_Key__c = Soundex.toSoundex(tmn.First_Name__c);
        }
    }
}