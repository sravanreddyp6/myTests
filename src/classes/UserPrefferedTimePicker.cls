public with sharing class UserPrefferedTimePicker {
	public static final boolean isMilitaryTime = UserDefaults__c.getInstance(userinfo.getuserId()).MilitaryTime__c;
	public boolean getIsMilitaryTime(){ return isMilitaryTime; }
    public transient DateTime dateTimeValue { get; set; }
    public transient boolean isEdit { get; set; }
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
        	String localeFormatDT;
        	if (isMilitaryTime)
            	localeFormatDT = dateTimeValue.format('MM/dd/yyyy HH:mm', UserInfo.getTimeZone().toString() );
            else
            	localeFormatDT = dateTimeValue.format( (isEdit ? 'MM/dd/yyyy hh:mm a' : 'M/d/yyyy h:mm a'), UserInfo.getTimeZone().toString() );
            return localeFormatDT;
        }
        return null;
    }
    
    public String getTimeWithSeconds() {
        if( dateTimeValue != null) {
        	String localeFormatDT;
        	if (isMilitaryTime)
            	localeFormatDT = dateTimeValue.format('MM/dd/yyyy HH:mm:ss', UserInfo.getTimeZone().toString() );
            else localeFormatDT = dateTimeValue.format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().toString() );
            return localeFormatDT;
        }
        
        return null;
    }
}