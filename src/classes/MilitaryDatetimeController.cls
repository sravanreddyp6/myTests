public with sharing class MilitaryDatetimeController {
    public transient DateTime dateTimeValue { get; set; }
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString() );
            return localeFormatDT;
        }
        return null;
    }
    
    public String getTimeWithSeconds() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString() );
            return localeFormatDT;
        }
        return null;
    }
}