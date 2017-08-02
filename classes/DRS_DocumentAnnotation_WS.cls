@RestResource(urlMapping='/v1/Document/Annotation')
global with sharing class DRS_DocumentAnnotation_WS {
    
    @TestVisible
    private class DRS_DocumentAnnotation_WSRequest {
        public string content;
        public string layerRecordId;
        public string userId;
        public string attachmentId;
    }
    
    @TestVisible
    private class DRS_DocumentAnnotation_WSResponse {
        List<DRS_DocumentAnnotation_WS.AnnotationResponseJSON> annotations;
    }
    
    @TestVisible
    private class AnnotationResponseJSON {
        public string content;
        public string userName;
        public string userId;
        public string layerRecordId;
    }
    
    @HttpPut
    global static void saveAnnotations() {
        try {
            System.debug('---DRS_DocumentAnnotation_WS:saveAnnotations:RestContext.request:' + RestContext.request);
            System.debug('---DRS_DocumentAnnotation_WS:saveAnnotations:RestContext.request.requestURI:' + RestContext.request.requestURI);
            System.debug('---DRS_DocumentAnnotation_WS:saveAnnotations:RestContext.request.requestBody:' + RestContext.request.requestBody);
            System.debug('---DRS_DocumentAnnotation_WS:saveAnnotations:RestContext.request.requestBody:String:' + RestContext.request.requestBody.toString());
            
            DRS_DocumentAnnotation_WS.DRS_DocumentAnnotation_WSRequest objDRS_DocumentAnnotation_WSRequest;
            if(RestContext.request.requestBody != null) {
                String requestBodyString = RestContext.request.requestBody.toString();
                objDRS_DocumentAnnotation_WSRequest = (DRS_DocumentAnnotation_WS.DRS_DocumentAnnotation_WSRequest)JSON.deserialize(requestBodyString, DRS_DocumentAnnotation_WS.DRS_DocumentAnnotation_WSRequest.class);
                DRS_CaseService.saveAnnotations(objDRS_DocumentAnnotation_WSRequest.userId, objDRS_DocumentAnnotation_WSRequest.attachmentId, objDRS_DocumentAnnotation_WSRequest.content, objDRS_DocumentAnnotation_WSRequest.layerRecordId);
            }
            System.debug('---DRS_DocumentAnnotation_WS:saveAnnotations:RestContext.response.statusCode:200');
            RestContext.response.statusCode = 200;
        }
        catch(Exception excep) {
            RestContext.response.responseBody = Blob.valueOf(DRS_GlobalUtility.handleRestServiceException(excep, 'DRS_Permission_WS', RestContext.request, RestContext.response));
            RestContext.response.statusCode = 500;
        }
    }
    
    @HttpGet
    global static void getAnnotations() {
        try {
            System.debug('---DRS_DocumentAnnotation_WS:getAnnotations:RestContext.request:' + RestContext.request);
            System.debug('---DRS_DocumentAnnotation_WS:getAnnotations:RestContext.request.requestURI:' + RestContext.request.requestURI);
            
            String userId;
            String attachmentId;
            
            DRS_DocumentAnnotation_WS.DRS_DocumentAnnotation_WSRequest objDRS_DocumentAnnotation_WSRequest;
            DRS_DocumentAnnotation_WS.DRS_DocumentAnnotation_WSResponse objDRS_DocumentAnnotation_WSResponse = new DRS_DocumentAnnotation_WS.DRS_DocumentAnnotation_WSResponse();
            objDRS_DocumentAnnotation_WSResponse.annotations = new List<DRS_DocumentAnnotation_WS.AnnotationResponseJSON>();
            DRS_DocumentAnnotation_WS.AnnotationResponseJSON objAnnotationResponseJSON;
            List<DocumentAnnotation__c> listAnnotations;
            
            if(RestContext.request.requestBody != null) {
                userId = RestContext.request.params.get('userId');
                attachmentId = RestContext.request.params.get('attachmentId');
                System.debug('---DRS_DocumentAnnotation_WS:getAnnotations:userId:' + userId);
                System.debug('---DRS_DocumentAnnotation_WS:getAnnotations:attachmentId:' + attachmentId);
                
                listAnnotations = DRS_CaseService.getAnnotations(userId, attachmentId);
                for(DocumentAnnotation__c objAnnotation : listAnnotations) {
                    objAnnotationResponseJSON = new DRS_DocumentAnnotation_WS.AnnotationResponseJSON();
                    objAnnotationResponseJSON.content = objAnnotation.AnnotationData__c;
                    objAnnotationResponseJSON.layerRecordId = objAnnotation.LayerRecordId__c;
                    objAnnotationResponseJSON.userName = objAnnotation.Username__c;
                    objAnnotationResponseJSON.userId = objAnnotation.User__c;
                    objDRS_DocumentAnnotation_WSResponse.annotations.add(objAnnotationResponseJSON);
                }
            }
            
            System.debug('---DRS_DocumentAnnotation_WS:getAnnotations:responseBody:' + JSON.serializePretty(objDRS_DocumentAnnotation_WSResponse));
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(objDRS_DocumentAnnotation_WSResponse));
            RestContext.response.statusCode = 200;
        }
        catch(Exception excep) {
            RestContext.response.responseBody = Blob.valueOf(DRS_GlobalUtility.handleRestServiceException(excep, 'DRS_DocumentAnnotation_WS', RestContext.request, RestContext.response));
            RestContext.response.statusCode = 500;
        }
    }
    
}