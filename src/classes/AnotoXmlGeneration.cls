public with sharing class AnotoXmlGeneration {

	public List<Widget> Widgets {get;set;}
	public List<OutputPage> Pages {get;set;}
    public Id RecordId {get;set;}
	
	public enum WidgetTypeEnum {
		textfield,
		textfieldmulti,
		boxed,
		checkbox,
		image,
		sendpidget,
		anotostatement,
		hidepattern
	}
    
    public enum FontWeightEnum {
        regular,
        bold,
        italic
    }
	
    public enum RecognitionTypeEnum {
        numeric,
        upper,
        free
    }
    
	public AnotoXmlGeneration(){
		Widgets = new List<Widget>();
		Pages = new List<OutputPage>();
	}

	public Dom.Document GenerateDocument(){
		Dom.Document doc= new Dom.Document();
		
		Dom.Xmlnode root = doc.createRootElement('root', '', '');
        
		Dom.Xmlnode settingsnode = root.addChildElement('settings', 'http://www.penvision.se/printprocessor', '');
		Dom.Xmlnode processors = settingsnode.addChildElement('processors',null,null);
		Dom.Xmlnode onode = processors.addChildElement('object', null, null);
        onode.setAttribute('ref', 'ps2pdfConverter');
        
        onode = processors.addChildElement('object', null, null);
        onode.setAttribute('ref', 'pdfSaver');

        Dom.Xmlnode pmapnode = onode.addChildElement('propertymapping', null, null);
        pmapnode.setAttribute('name', 'DestinationFile');
        pmapnode.setAttribute('value', '$pdfLocation$');

        onode = processors.addChildElement('object', null, null);
        onode.setAttribute('ref', 'psSaver');

        Dom.Xmlnode pnode = onode.addChildElement('property', null, null);
        pnode.setAttribute('name', 'Enabled');
        pnode.setAttribute('value', 'false');

        onode = processors.addChildElement('object', null, null);
        onode.setAttribute('ref', 'formPrinter');

		pnode = onode.addChildElement('property', null, null);
        pnode.setAttribute('name', 'Enabled');
        pnode.setAttribute('value', 'false');        
        
        onode = processors.addChildElement('object', null, null);
        onode.setAttribute('ref', 'psGenPreProcessor');

		pmapnode = onode.addChildElement('propertymapping', null, null);
        pmapnode.setAttribute('name', 'NumCopies');
        pmapnode.setAttribute('value', '1');        
        
        onode = processors.addChildElement('object', null, null);
        onode.setAttribute('ref', 'psGenerator');

		pmapnode = onode.addChildElement('propertymapping', null, null);
        pmapnode.setAttribute('name', 'Duplex');
        pmapnode.setAttribute('value', 'False');        
        
		pmapnode = onode.addChildElement('propertymapping', null, null);
        pmapnode.setAttribute('name', 'Tumble');
        pmapnode.setAttribute('value', 'False');        
        
		pnode = onode.addChildElement('property', null, null);
        pnode.setAttribute('name', 'Cropmarks');
        pnode.setAttribute('value', 'False');        
        
		pnode = onode.addChildElement('property', null, null);
        pnode.setAttribute('name', 'Offset');
        pnode.setAttribute('value', 'False');        
        
		pnode = onode.addChildElement('property', null, null);
        pnode.setAttribute('name', 'Rotate');
        pnode.setAttribute('value', 'False');        
        
		pnode = onode.addChildElement('property', null, null);
        pnode.setAttribute('name', 'PaperPrintCodeSize');
        pnode.setAttribute('value', '3.25');        
        
		// some data that needs to be in XML but not prepopulated:
		// checksheet ID
		Dom.XmlNode layout = settingsnode.addChildElement('layout', null, null);
		
		// need to generate the Person Being Served name, and month/year
		
		/*
        Dom.XmlNode pagesnode = layout.addChildElement('Pages', null, null);
        pagesnode.addTextNode('1');
        
        Dom.XmlNode bkgnode = layout.addChildElement('Background', null, null);
        bkgnode.setAttribute('page', '1');
        bkgnode.setAttribute('ref', 'c:\\background.pdf');
        bkgnode.setAttribute('type', 'application/pdf');
        bkgnode.setAttribute('refPage', '1');
		*/
		Dom.XmlNode pagesnode = layout.addChildElement('Pages', null, null);
        pagesnode.addTextNode(Pages.size().format());
        
        for(OutputPage pageiter:Pages){
        	pageiter.GenerateBackgroundNode(layout);
        }
        
        for(Widget child:Widgets){
			child.GenerateLayout(layout);
		}
		
        // Inject authentication details
        Anoto_Settings__c settings = Anoto_Settings__c.getInstance();
        Dom.Xmlnode authnode = root.AddChildElement('SalesforceUsername', null, null);
        authnode.addTextNode(settings.Username__c == null ? '' : settings.Username__c);
        authnode = root.AddChildElement('SalesforcePassword', null, null);
        authnode.addTextNode(settings.Password__c == null ? '' : settings.Password__c);
        authnode = root.AddChildElement('SalesforceClientId', null, null);
        authnode.addTextNode(settings.Consumer_Key__c == null ? '' : settings.Consumer_Key__c);
        authnode = root.AddChildElement('SalesforceClientSecret', null, null);
        authnode.addTextNode(settings.Consumer_Secret__c == null ? '' : settings.Consumer_Secret__c);
        string url = AnotoUtility.getLoginUrl();
        authnode = root.AddChildElement('SalesforceLoginUrl', null, null);
        authnode.addTextNode(url == null ? '' : url);

        Dom.Xmlnode recordidnode = root.AddChildElement('SalesforceId', null, null);
        recordidnode.addTextNode(RecordId);
        
		for(Widget child:Widgets){
			child.GeneratePrepopulateValue(root);
		}
		
		return doc;
	}
	
	public class Widget {
		public string Name {get;set;}
        public boolean WriteEnabled {get;set;}
		public integer Page {get;set;}
		public WidgetTypeEnum WidgetType {get;set;} // subclasses?
		public Decimal TopAp {get;set;}
		public Decimal LeftAp {get;set;}
		public Decimal OffsetxAp {get;set;}
		public Decimal OffsetyAp {get;set;}
		public Decimal WidthAp {get;set;}
		public Decimal HeightAp {get;set;}
		public string DefaultValue {get;set;}
        public string FontFamily {get;set;}
        public FontWeightEnum FontWeight {get;set;}
        public integer FontSize {get;set;}
        public integer CharCount {get;set;}
        public RecognitionTypeEnum RecognitionType {get;set;}
		
		public Widget(WidgetTypeEnum wtype, string name){
			WidgetType = wtype;
			this.Name = name;
			TopAp = LeftAp = WidthAp = HeightAp = 0;
			page = 1;
            FontFamily = 'Arial';
            FontWeight = FontWeightEnum.regular;
            FontSize = 12;
            CharCount = 1;
            WriteEnabled = wtype == WidgetTypeEnum.textfield ||
                wtype == WidgetTypeEnum.boxed ||
                wtype == WidgetTypeEnum.textfieldmulti ||
                wtype == WidgetTypeEnum.checkbox;
            RecognitionType = RecognitionTypeEnum.free;    
		}
		
		public void Layout(integer page, Decimal top, Decimal left, Decimal height, Decimal width){
			this.page = page;
			TopAp = top * 10 / 3; // convert to Ap
			LeftAp = left * 10 / 3;
            HeightAp = height * 10 / 3;
            WidthAp = width * 10 / 3;
		}
        
        public void ValueOffset(decimal x, decimal y){
            OffsetxAp = x * 10 / 3;
            OffsetyAp = y * 10 / 3;
        }
        
        public void Font(string family, FontWeightEnum weight, integer size){
            FontFamily = family;
            FontWeight = weight;
            FontSize = size;
        }    
		
		public string GenerateLayout(Dom.Xmlnode parent){
			Dom.XmlNode node = parent.addChildElement('Widget', null, null);
			node.setAttribute('name', Name);
			node.setAttribute('page', Page.format());
			node.setAttribute('type', WidgetType.name());
			node.setAttribute('left', LeftAp.format());
			node.setAttribute('top', TopAp.format());
			node.setAttribute('height', HeightAp.format());
			node.setAttribute('width', WidthAp.format());
			node.setAttribute('font', FontFamily);
			node.setAttribute('fontStyle', FontWeight.name());
			node.setAttribute('fontSize', FontSize.format());
			node.setAttribute('prepop', DefaultValue == null ? 'false' : 'true');
            if (OffsetxAp != null){
                node.setAttribute('offsetX', OffsetxAp.format());
            }
            if (OffsetyAp != null){
                node.setAttribute('offsetY', OffsetyAp.format());
            }
			if (DefaultValue != null){
				node.setAttribute('lineSpacing', '16.9');
			}
            if (WidgetType == WidgetTypeEnum.boxed) {
                node.setAttribute('boxes', CharCount.format());
            }
            if (WidgetType == WidgetTypeEnum.checkbox) {
                node.setAttribute('checkedvalue', 'true');
            }
            if (WidgetType == WidgetTypeEnum.image) {
                node.setAttribute('compression', 'none');
            }
            if (WriteEnabled) {
                node.setAttribute('hwrEnabled', 'true');
                Dom.XmlNode resourcenode = node.addChildElement('Resource', null, null);
                resourcenode.setAttribute('type', RecognitionType == RecognitionTypeEnum.numeric || RecognitionType == RecognitionTypeEnum.upper ? 'subset' : 'lexicon');
                resourcenode.setAttribute('name', RecognitionType == RecognitionTypeEnum.numeric ? 'digit' : RecognitionType == RecognitionTypeEnum.upper ? 'upper' : 'text');
                resourcenode.setAttribute('custom', 'false');
            	Dom.XmlNode viewernode = node.AddChildElement('ViewerSettings', null, null);
            	viewernode.setAttribute('presentation', 'edit');
            }
            
			return '';
		}
		
		public string GeneratePrepopulateValue(Dom.Xmlnode parent){
			if (DefaultValue != null){
				Dom.XmlNode node = parent.addChildElement(Name, null, null);
				node.addTextNode(DefaultValue);
			}
			return '';
		}
	}
	
	public class OutputPage {
		public string DocumentLocation {get;set;}
		public integer Index {get;set;}
		
		public OutputPage(String documentLocation, integer index){
			this.DocumentLocation = documentLocation;
			this.Index = index;
		}
		
		public string GenerateBackgroundNode(Dom.XmlNode parent){
            if (DocumentLocation != null){
				Dom.XmlNode node = parent.AddChildElement('Background', null, null);
				node.setAttribute('page', Index.format());
				node.setAttribute('ref', DocumentLocation == null ? '' : DocumentLocation);
				node.setAttribute('type', 'application/pdf');
				node.setAttribute('refPage', '1');
            }
			return '';
		}
	}
}