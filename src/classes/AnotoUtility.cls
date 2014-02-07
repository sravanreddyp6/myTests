public with sharing class AnotoUtility {
    public static String generatePdfByHandlerName(String handlerName, String xml){
        Anoto_Form_Handler__c[] handlers = [
            SELECT Id, App_Id__c FROM Anoto_Form_Handler__c
            WHERE name=:handlerName
        ];
        if (handlers.size() == 0) {
            throw new PdfGenerationException('Handler not found: ' + handlerName);
        }
        return generatePdf(handlers[0].App_Id__c, xml);
        
    }
    public static String generatePdf(String appId, String xml) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://pengateway.thementornetwork.com/pdf');
        req.setBody('app_id=' + appId + '&xml='+EncodingUtil.urlEncode(xml, 'UTF-8'));
        req.setMethod('POST');
        req.setTimeout(120000); // Max time out possible (2 mins)
        HttpResponse res = h.send(req);
        if (res.getStatusCode() != 200) {
            throw new PdfGenerationException(res.getBody());
        }
        return res.getBody();
    }

    public static XmlStreamWriter startXmlWriter() {
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument('UTF-8', '1.0');
        //w.writeAttribute(null, null, 'standalone', 'yes');
        w.writeStartElement(null, 'root',null);
        w.writeStartElement('',  'settings', 'http://www.penvision.se/printprocessor');
        w.writeNamespace('', 'http://www.penvision.se/printprocessor');
        w.writeStartElement(null, 'processors', null);
        w.writeStartElement(null, 'object', null);
        w.writeAttribute(null, null, 'ref', 'ps2pdfConverter');
        w.writeEndElement(); // end object
        w.writeStartElement(null, 'object', null);
        w.writeAttribute(null, null, 'ref', 'pdfSaver');
        w.writeStartElement(null, 'propertymapping',null);
        w.writeAttribute(null, null, 'name', 'DestinationFile');
        w.writeAttribute(null, null, 'value', '$pdfLocation$');
        w.writeEndElement(); // propertymapping
        w.writeEndElement(); // object
        w.writeStartElement(null, 'object', null);
        w.writeAttribute(null, null, 'ref', 'psSaver');
        w.writeStartElement(null, 'property',null);
        w.writeAttribute(null, null, 'name', 'Enabled');
        w.writeAttribute(null, null, 'value', 'false');
        w.writeEndElement(); // property
        w.writeEndElement(); // object
        w.writeStartElement(null, 'object', null);
        w.writeAttribute(null, null, 'ref', 'formPrinter');
        w.writeStartElement(null, 'property',null);
        w.writeAttribute(null, null, 'name', 'Enabled');
        w.writeAttribute(null, null, 'value', 'false');
        w.writeEndElement(); // property
        w.writeEndElement(); // object
        w.writeStartElement(null, 'object', null);
        w.writeAttribute(null, null, 'ref', 'psGenPreProcessor');
        w.writeStartElement(null, 'propertymapping',null);
        w.writeAttribute(null, null, 'name', 'NumCopies');
        w.writeAttribute(null, null, 'value', '1');
        w.writeEndElement(); // property
        w.writeEndElement(); // object
        w.writeStartElement(null, 'object', null);
        w.writeAttribute(null, null, 'ref', 'psGenerator');
        w.writeStartElement(null, 'propertymapping',null);
        w.writeAttribute(null, null, 'name', 'Duplex');
        w.writeAttribute(null, null, 'value', 'False');
        w.writeEndElement(); // property
        w.writeStartElement(null, 'propertymapping',null);
        w.writeAttribute(null, null, 'name', 'Tumble');
        w.writeAttribute(null, null, 'value', 'False');
        w.writeEndElement(); // property
        w.writeStartElement(null, 'property',null);
        w.writeAttribute(null, null, 'name', 'Cropmarks');
        w.writeAttribute(null, null, 'value', 'False');
        w.writeEndElement(); // property
        w.writeStartElement(null, 'property',null);
        w.writeAttribute(null, null, 'name', 'Offset');
        w.writeAttribute(null, null, 'value', 'False');
        w.writeEndElement(); // property
        w.writeStartElement(null, 'property',null);
        w.writeAttribute(null, null, 'name', 'Rotate');
        w.writeAttribute(null, null, 'value', 'False');
        w.writeEndElement(); // property
        w.writeStartElement(null, 'property',null);
        w.writeAttribute(null, null, 'name', 'PaperPrintCodeSize');
        w.writeAttribute(null, null, 'value', '3.25');
        w.writeEndElement(); // property

        w.writeEndElement(); // object
        w.writeEndElement(); // processors
        w.writeEndElement(); // settings

        // Inject authentication details
        Anoto_Settings__c settings = Anoto_Settings__c.getInstance();
        w.writeStartElement(null, 'SalesforceUsername', null);
        w.writeCharacters(settings.Username__c);
        w.writeEndElement();
        w.writeStartElement(null, 'SalesforcePassword', null);
        w.writeCharacters(settings.Password__c);
        w.writeEndElement();
        w.writeStartElement(null, 'SalesforceClientId', null);
        w.writeCharacters(settings.Consumer_Key__c);
        w.writeEndElement();
        w.writeStartElement(null, 'SalesforceClientSecret', null);
        w.writeCharacters(settings.Consumer_Secret__c);
        w.writeEndElement();
        w.writeStartElement(null, 'SalesforceLoginUrl', null);
        w.writeCharacters(AnotoUtility.getLoginUrl());
        w.writeEndElement();
        return w;
    }

    public static String endXmlWriter(XmlStreamWriter w) {
        w.writeEndElement(); // root
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        return xmlOutput;
    }

    public static String getLoginUrl() {
        System.debug('Salesforce URL Host: ' + URL.getSalesforceBaseUrl().getHost());
        if (URL.getSalesforceBaseUrl().getHost().left(4).equalsignorecase('c.cs')) {
            // Sandbox
            return 'https://test.salesforce.com/services/oauth2/token';
        } else {
            // Production
            return 'https://login.salesforce.com/services/oauth2/token';
        }
    }

    public class PdfGenerationException extends Exception {}
}