@RestResource(urlMapping='/AnotoOutput/*')
global with sharing class RESTAnotoOutputController {
    @HttpPost
    global static String postOutput() {
        Map<String, String> contentTypeToFormatMap = new Map<String, String>{
            'text/xml' => 'xml',
            'application/pdf' => 'pdf',
            'image/jpeg' => 'jpg',
            'image/png' => 'png'
        };
        RestRequest req = RestContext.request;
        RestResponse resp = RestContext.response;
        String format;
        String appId = req.params.get('app_id');
        String recordId = req.params.get('id');
        System.debug('Req params: ' + req.params);
        System.debug('Req headers: ' + req.headers);
        String contentType = req.headers.get('Content-Type');
        if (contentType == null) {
            resp.statusCode = 400;
            return 'You have to specify the Content-Type of the request';
        }
        if (contentType.indexOf('boundary=')!=-1) {
            resp.statusCode = 400;
            return 'multipart is not supported by Salesforce';
        }
        for (String acceptableContentType: contentTypeToFormatMap.keySet()) {
            if (contentType.toLowerCase().indexOf(acceptableContentType) != -1) {
                format = contentTypeToFormatMap.get(acceptableContentType);
            }
        }
        if (format == null) {
            resp.statusCode = 400;
            return 'Content-Type ' + contentType + ' is not supported!';
        }
        Anoto_Form_Handler__c[] handlers = [
            SELECT Id, Handler__c FROM Anoto_Form_Handler__c
            WHERE App_Id__c=:appId
        ];
        if (handlers.size() == 0) {
            resp.statusCode = 404;
            return 'No handler found for app ' + appId;
        }
        Type t = Type.forName(handlers[0].Handler__c);
        AnotoFormHandler handler = (AnotoFormHandler) t.newInstance();
        return handler.handle(recordId, format, req.requestBody, req, resp);
    }
}