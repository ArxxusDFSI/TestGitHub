public without sharing class DRS_S3Service {
    
    public static String getSignedUploadUrl(String path) {
        DRS_S3Connection objS3Connection = new DRS_S3Connection('PUT');
        objS3Connection.canonicalUri = path;
        objS3Connection.xAmzSignedHeadersValue = 'host;x-amz-server-side-encryption';
        objS3Connection.canonicalHeaders.put('x-amz-server-side-encryption', objS3Connection.s3ServerSideEncryptionAlgorithm);
        objS3Connection.signedHeaders.add('x-amz-server-side-encryption');
        return objS3Connection.getSignedUrl();
    }
    
    public static String getSignedDownloadUrl(String path) {
        String signedUrl = DRS_S3Service.getSignedUrl(path, 'GET');
        return signedUrl;
    }
    
    public static String getSignedDeleteUrl(String path) {
        String signedUrl = DRS_S3Service.getSignedUrl(path, 'DELETE');
        return signedUrl;
    }
    
    /*
    public static String getMultipartUploadInitiationUrl(String path) {
        DRS_S3Connection objS3Connection = new DRS_S3Connection('POST');
        objS3Connection.canonicalUri = path;
        objS3Connection.additionalCanonicalHeaders.put('uploads','');
        return objS3Connection.getSignedUrl();
    }
    
    public static String getMultipartAbortUrl(String path, String uploadId) {
        DRS_S3Connection objS3Connection = new DRS_S3Connection('DELETE');
        objS3Connection.canonicalUri = path;
        objS3Connection.additionalCanonicalHeaders.put('uploadId', uploadId);
        return objS3Connection.getSignedUrl();
    }
    
    public static String getMultipartCompleteUrl(String path, String uploadId) {
        DRS_S3Connection objS3Connection = new DRS_S3Connection('POST');
        objS3Connection.canonicalUri = path;
        objS3Connection.additionalCanonicalHeaders.put('uploadId', uploadId);
        return objS3Connection.getSignedUrl();
    }
    
    public static String getMultipartUploadUrl(String path, String partNumber, String uploadId) {
        DRS_S3Connection objS3Connection = new DRS_S3Connection('PUT');
        objS3Connection.canonicalUri = path;
        objS3Connection.additionalCanonicalHeaders.put('partNumber', String.valueOf(partNumber));
        objS3Connection.additionalCanonicalHeaders.put('uploadId', String.valueOf(uploadId));
        return objS3Connection.getSignedUrl();
    }
*/
    
    // get a signed url for a file
    private static String getSignedUrl(String path, String httpMethod) {
        
        DRS_S3Connection s3 = new DRS_S3Connection(httpMethod);
        
        // urlEncode replaces whitespace with + instead of %20. + is invalid for AWS as it treats it as a character, so we need to substitute it after encoding
        s3.canonicalUri = path;
        string signedUrl = s3.getSignedUrl();
        system.debug('@@SignedURL;' + signedUrl);
        
        return signedUrl;
    }
    
    public static String handleFileNameSpecialChar(String path){
        return path.replaceAll('[^a-zA-Z0-9.-]', '_');
    }       
    
}