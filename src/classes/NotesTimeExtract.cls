public with sharing class NotesTimeExtract {

    public NotesTimeExtract(ApexPages.StandardController controller) {

    }
String LongDate = ' ';
public String getLongDate() {
Datetime cDT = System.now();
LongDate = cDT.format('EEEE, MMMM d, yyyy');
return LongDate;
  }  
datetime myDate = datetime.newInstance(2008, 12, 1);

public datetime getmyDate() {
return null;
}

}