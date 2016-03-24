public without sharing class StringDateTimeFormatter {
    public transient String gmtDateTimeStrVal {get;set;}
    public String GetDtValFormattedLocal() {
        if(!String.IsBlank(gmtDateTimeStrVal)) {
            return DateTime.valueOf(gmtDateTimeStrVal.replace('T',' ').substringBeforeLast('+')).format();
        }
        return null;
    }
}