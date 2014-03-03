public class HelpLinkController{
    private final LIST<cGuide__Guide__c> CrowdGuideid {get ; set;}
    Boolean showGuide{get; set;}
    public String prefix{get; set;}
    
    public HelpLinkController(){
        crowdGuideid= [SELECT ID FROM cGuide__Guide__c WHERE (cGuide__Object_Prefix__c = :prefix and cGuide__Active__c = true) order by cGuide__Likes__c desc limit 1];
        showGuide = Boolean.Valueof(CrowdGuideid.size()>0);
    
    }
    Public id getCrowdGuideid(){
        return CrowdGuideid[0].id;
        }
    public Boolean getshowGuide(){
        return showGuide;
        }
    
    }