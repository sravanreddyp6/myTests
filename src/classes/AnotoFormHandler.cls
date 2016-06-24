public interface AnotoFormHandler {
    /*
     * @param recordId The Id of the record associated with the form. This is
     * pulled from the <SalesforceId> node in your prepop XML file. For example,
     * for the CareMeridian Evaluation form, the recordId is the Id for the
     * Evaluation record.
     * @param fileType This is the extension of the file that was sent over from
     * Anoto (e.g. pdf, jpg, xml)
     * @param fileContent The content of the file. For XML file, you can use
     * toString() to convert the Blob to a String representation.
     * @param request the RestRequest object.
     * @param response the RestResponse object, which allows you to change the
     * response status code (e.g. 404 for File Not Found, 500 for Internal Server
     * Error). The default is 200 (Success).
     * @return the String that gets sent back in the response body to Anoto
     * server.
     */
    String handle(Id recordId, String fileType, Blob fileContent, RestRequest req, RestResponse response);
}