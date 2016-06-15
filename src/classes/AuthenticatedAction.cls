public interface AuthenticatedAction {
    /*
     * @param recordId the Id of the record that the authentication runs on
     * @param userId the Id of the user that just succesfully authenticated
     * @return a PageReference that can be used to redirect the user
     */
    PageReference handle(Id recordId, Id userId);
}