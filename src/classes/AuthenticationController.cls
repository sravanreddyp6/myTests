public with sharing class AuthenticationController {
    public String username { get; set; }
    public String password { get; set; }
    public String handlerClass { get; set; }
    public Id parentId { get; set; }

    public PageReference authenticate() {
        if (username.toLowerCase() != UserInfo.getUserName().toLowerCase()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot log in as another user!'));
            return null;
        }
        String LOGIN_DOMAIN;
        if (URL.getSalesforceBaseUrl().getHost().left(4).equalsignorecase('c.cs')) {
            // Sandbox
            LOGIN_DOMAIN = 'test';
        } else {
            // Production
            LOGIN_DOMAIN = 'login';
        }
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://' + LOGIN_DOMAIN + '.salesforce.com/services/Soap/u/22.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        request.setBody(buildSoapLogin(username, password));

        // If there is a loginResponse element, then login succeeded; else there
        // would be soap fault element after body
        DOM.Document responseDOM = (new Http()).send(request).getBodyDocument();
        System.debug(responseDOM.toXmlString());
        Boolean verified = responseDOM.getRootElement()
          .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
          .getChildElement('loginResponse', 'urn:partner.soap.sforce.com') != null;

        if (verified) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Correct password!'));
        } else {
            String errorMsg = responseDOM.getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('Fault', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('detail', null)
                .getChildElement('LoginFault', 'urn:fault.partner.soap.sforce.com')
                .getChildElement('exceptionMessage', 'urn:fault.partner.soap.sforce.com')
                .getText();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return null;
        }
        Type t = Type.forName(handlerClass);
        AuthenticatedAction handler = (AuthenticatedAction) t.newInstance();
        return handler.handle(parentId, UserInfo.getUserId());
    }

    public static String buildSoapLogin(String username, String password){
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement('', 'login', 'urn:partner.soap.sforce.com');
        w.writeNamespace('', 'urn:partner.soap.sforce.com');
        w.writeStartElement('', 'username', 'urn:partner.soap.sforce.com');
        w.writeCharacters(username);
        w.writeEndElement();
        w.writeStartElement('', 'password', 'urn:partner.soap.sforce.com');
        w.writeCharacters(password);
        w.writeEndElement();
        w.writeEndElement();

        String xmlOutput =
              '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body>'
            + w.getXmlString()
            + '</Body></Envelope>';
        w.close();
        return xmlOutput;
    }
}