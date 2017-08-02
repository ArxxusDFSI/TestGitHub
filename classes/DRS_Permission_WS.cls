@RestResource(urlMapping='/v1/Permission/*')
global with sharing class DRS_Permission_WS {
    
    private class DRS_Permission_WSResponse {
        private Boolean isAllowed;
    }
    
    @HttpGet
    global static void getPermissions() { /*
        try {
            System.debug('---DRS_Permission_WS:getPermissions:RestContext.request:' + RestContext.request);
            System.debug('---DRS_Permission_WS:getPermissions:RestContext.request.requestURI:' + RestContext.request.requestURI);
            
            String requestURI = RestContext.request.requestURI;
            String requestURIprefix = '/v1/Permission/';
            String userId;
            String objectId;
            Boolean isAllowed = false;
            DRS_Permission_WS.DRS_Permission_WSResponse objDRS_Permission_WSResponse = new DRS_Permission_WS.DRS_Permission_WSResponse();
            
            if(requestURI.contains(requestURIprefix + 'Attachment')) {
                System.debug('---DRS_Permission_WS:getPermissions:Attachment endpoint');
                
                userId = RestContext.request.params.get('userId');
                objectId = RestContext.request.params.get('attachmentId');
                System.debug('---DRS_Permission_WS:getPermissions:userId:' + userId);
                System.debug('---DRS_Permission_WS:getPermissions:attachmentId:' + objectId);
                
                objDRS_Permission_WSResponse.isAllowed = DRS_CaseService.isUserAllowedToSeeAttachment(userId, objectId);
                System.debug('---DRS_Permission_WS:getPermissions:objDRS_Permission_WSResponse.isAllowed:' + objDRS_Permission_WSResponse.isAllowed);
            }
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(objDRS_Permission_WSResponse));
            RestContext.response.statusCode = 200;
        }
        catch(Exception excep) {
            RestContext.response.responseBody = Blob.valueOf(DRS_GlobalUtility.handleRestServiceException(excep, 'DRS_Permission_WS', RestContext.request, RestContext.response));
            RestContext.response.statusCode = 500;
        }*/
    }
}