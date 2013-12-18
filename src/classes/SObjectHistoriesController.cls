public with sharing class SObjectHistoriesController {
    /**
     * This class is a decorated SObject with the fields of the Histories.
     * It is needed because a generic SObject does not have these fields, and
     * as such we can't reference them for all the custom objects.
     */
    public class HistoryItem {
    	public SObject histItem { get; set; }
        public DateTime CreatedDate {
        	get {
        		return (DateTime) histItem.get('CreatedDate');
        	}
        }
        public String Field {
        	get {
        		return (String) histItem.get('Field');
        	}
        }
        public String CreatedBy {
        	get {
        		return (String)  histItem.getSObject('CreatedBy').get('Name'); 
        	}
        }
        public String oldValue {
        	get {
        		return String.valueOf(histItem.get('oldValue'));
        	}
        }
        public String newValue {
            get {
                return String.valueOf(histItem.get('newValue'));
            }
        }
        public HistoryItem(SObject histItem) {
        	this.histItem = histItem;
        }
    }

    public HistoryItem getHistoryItem(SObject item) {
    	return new HistoryItem(item);
    }

    public SObject item { get;
        set {
            item = value;
            String query = 'SELECT (SELECT CreatedDate, Field, OldValue, NewValue, CreatedBy.Name FROM Histories ORDER BY CreatedDate DESC) FROM ' + item.getSObjectType().getDescribe().getName() + ' WHERE ID=\''+item.ID+'\'';
            record = Database.query(query);
            Map<String, Schema.SObjectField> tempMap = Schema.getGlobalDescribe().get('Admission__c').getDescribe().fields.getMap();
            fieldMap = new Map<String, String>();
            for (String fieldName: tempMap.keySet()) {
                fieldMap.put(fieldName, tempMap.get(fieldName).getDescribe().getLabel());
            }
        }
    }
    // In order to show field labels instead of API names for history
    public Map<String, String> fieldMap { get; set; }

    public SObject record { get; set; }

    public HistoryItem[] Histories {
        get {
            SObject[] histItems = record.getSObjects('Histories');
            System.debug('HistItems: ' + histItems);
            HistoryItem[] histList = new HistoryItem[]{};
            if (histItems!=null) {
	            for (SObject histItem: histItems) {
	            	histList.add(new HistoryItem(histItem));
	            }
            }
            return histList;
        }
    } 
}