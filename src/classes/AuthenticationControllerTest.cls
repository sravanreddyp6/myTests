@isTest
public with sharing class AuthenticationControllerTest {
    static testmethod void simpleTests() {
        AuthenticationController controller = new AuthenticationController();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        controller.username = 'alpha1@testorg.com';
        controller.password = 'testPassword1';
        controller.handlerClass = 'MockAuthenticatedAction';

        PageReference page = controller.authenticate();
        System.assertEquals('You cannot log in as another user!', ApexPages.getMessages()[0].getSummary());
        controller.username = UserInfo.getUserName();
        controller.password = 'wrongpassword';
        controller.authenticate();
        System.assert(ApexPages.getMessages()[1].getSummary().indexOf('Invalid') != -1);

        controller.password = 'rightpassword';
        controller.authenticate();
        System.debug('Page Messages: ' + ApexPages.getMessages());
        System.assert(ApexPages.getMessages()[2].getSummary().indexOf('Correct') != -1);
    }

    class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            DOM.Document doc = new DOM.Document();
            doc.load(req.getBody());
            System.debug(req.getBody());
            String password = doc.getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('login', 'urn:partner.soap.sforce.com')
                .getChildElement('password', 'urn:partner.soap.sforce.com')
                .getText();
            System.debug('Password: ' + password);
            // Create a fake response
            HttpResponse res = new HttpResponse();
            if (password=='rightpassword') {
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><metadataServerUrl>https://cs10.salesforce.com/services/Soap/m/22.0/00DJ0000003OBCG</metadataServerUrl><passwordExpired>false</passwordExpired><sandbox>true</sandbox><serverUrl>https://cs10.salesforce.com/services/Soap/u/22.0/00DJ0000003OBCG</serverUrl><sessionId>00DJ0000003OBCG!ARQAQJnYSBorlg0nVVULaxGy9sroK3fe.EvFoeMLI50o8RAKhRl86ZlrA8OI3g3XeydkuHIXl6Oo.cuMM5zQJvBFxAlfAanE</sessionId><userId>005U00000027ievIAA</userId><userInfo><accessibilityMode>false</accessibilityMode><currencySymbol>$</currencySymbol><orgAttachmentFileSizeLimit>5242880</orgAttachmentFileSizeLimit><orgDefaultCurrencyIsoCode>USD</orgDefaultCurrencyIsoCode><orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments><orgHasPersonAccounts>true</orgHasPersonAccounts><organizationId>00DJ0000003OBCGMA4</organizationId><organizationMultiCurrency>false</organizationMultiCurrency><organizationName>The Mentor Network</organizationName><profileId>00eU0000000myCwIAI</profileId><roleId>00EU0000000DQV6MAO</roleId><sessionSecondsValid>7200</sessionSecondsValid><userDefaultCurrencyIsoCode xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" /><userEmail>dang.mai@thementornetwork.com</userEmail><userFullName>Dang Mai</userFullName><userId>005U00000027ievIAA</userId><userLanguage>en_US</userLanguage><userLocale>en_US</userLocale><userName>dang.mai@thementornetwork.com.sandboxdm</userName><userTimeZone>America/New_York</userTimeZone><userType>Standard</userType><userUiSkin>Theme3</userUiSkin></userInfo></result></loginResponse></soapenv:Body></Envelope>');
            } else {
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>sf:INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><sf:LoginFault xsi:type="sf:LoginFault" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sf="urn:fault.partner.soap.sforce.com"><sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode><sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage></sf:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
            }
            res.setStatusCode(200);
            return res;
        }
    }
}