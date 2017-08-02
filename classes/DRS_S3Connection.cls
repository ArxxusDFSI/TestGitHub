public without sharing class DRS_S3Connection {
    public string awsRegion {get; set;}
    public string awsHost {get; set;}
    public string awsRequestType {get; set;}
    public string awsServiceName {get; set;}
    public string bucketName {get; set;}
    public string httpVerb {get; set;}
    public string canonicalUri {get; set;}
    public string expiresSeconds {get; set;}
    public string accessKey {get; set;}
    public string accessSecret {get; set;}
    public string s3ServerSideEncryptionAlgorithm {get;set;}
    public string xAmzSignedHeadersValue {get; set;}
    
    private string awsHeaderEncryptionScheme {get;set;}
    private string awsEncryptionScheme {get;set;}
    
    public Map<string, string> canonicalQueryMap  {
        get {
            if (canonicalQueryMap != null) {
                return canonicalQueryMap;
            } else {
                // provide defaults if not manually set.
                // Map out the canonical query string elements
                Map<string, string> defaults = new Map<string, string>();
                defaults.put('X-Amz-Algorithm', this.awsHeaderEncryptionScheme);
                defaults.put('X-Amz-Credential', this.accessKey + '/' + this.dateStampYYYYMMDD + '/' + this.awsRegion + '/s3/aws4_request');
                defaults.put('X-Amz-Date', this.dateStampISO); // convert to ISO 8601 format
                defaults.put('X-Amz-Expires', this.expiresSeconds);
                defaults.put('X-Amz-Server-Side-Encryption', this.s3ServerSideEncryptionAlgorithm);
                //defaults.put('X-Amz-Server-Side-Encryption-Aws-Kms-Key-Id', 'c068cde9-dba2-4156-b7c6-1f6abeb85076');
                //this.xAmzSignedHeadersValue = 'host;x-amz-server-side-encryption';
                //this.xAmzSignedHeadersValue = this.xAmzSignedHeadersValue.toLowerCase();
                
                if(xAmzSignedHeadersValue != null) {
                    defaults.put('X-Amz-SignedHeaders', xAmzSignedHeadersValue);
                }
                else {
                    defaults.put('X-Amz-SignedHeaders', 'host');
                }
                
                return defaults;
            }
        }
        set;
    }
    public Map <String, String> additionalCanonicalHeaders {get; set;}
    public Map<string, string> canonicalHeaders {get; set;}
    public List<string> signedHeaders {get; set;}
    public Date dateStamp {get; set;}
    
    private static final String S3_SERVICE_NAME = 's3';
    
    public DRS_S3Connection(String httpMethod) {
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        this.awsHeaderEncryptionScheme = objMRSConfiguration.S3HeaderEncryptionScheme__c;
        this.awsEncryptionScheme = objMRSConfiguration.S3EncryptionScheme__c;
        this.s3ServerSideEncryptionAlgorithm = objMRSConfiguration.S3ServerSideEncryptionAlgorithm__c;
        
        this.accessKey = objMRSConfiguration.Username__c;
        this.accessSecret = objMRSConfiguration.Password__c;
        this.bucketName = objMRSConfiguration.S3BucketName__c;
        
        this.awsServiceName = S3_SERVICE_NAME;
        this.awsHost = objMRSConfiguration.S3Host__c;
        this.awsRegion = objMRSConfiguration.S3Region__c;
        this.httpVerb = httpMethod;
        this.expiresSeconds = (objMRSConfiguration.S3Timeout__c != null ? objMRSConfiguration.S3Timeout__c : '10');
        
        // Map out the canonical header elements
        this.canonicalHeaders = new Map<string,string>();
        this.canonicalHeaders.put('host', this.awsHost);
        
        this.additionalCanonicalHeaders = new Map <String, String> ();
        
        // List out the signed headers
        this.signedHeaders = new List<string>();
        this.signedHeaders.add('host');
    }
    
    public string getSignedUrl() {
        string url = 'https://' + this.awsHost + '/' + bucketName + '/' + canonicalUri + (canonicalUri.contains('?') ? '&' : '?');
        
        for (string key: this.canonicalQueryMap.keySet()) {
            url += key + '=' + this.canonicalQueryMap.get(key) + '&';
        }
        
        for (string key: this.additionalCanonicalHeaders.keySet()) {
            url += key + '=' + this.additionalCanonicalHeaders.get(key) + '&';
        }
        
        url += 'X-Amz-Signature=' + this.getSignature();
        return url;
    }
    
    public string getRequestString() {
        
        // ==== CONSTRUCT THE REQUEST STRING FROM THE DATA ====
        // Now construct the canonical request string from these elements.
        string canonicalRequestString = this.httpVerb + '\n'
            + '/' + bucketName + '/' + this.canonicalUri + '\n';
        
        // Add the query string
        // we assume the elements remain in alphabetical order. TODO: sort just to be sure.
        for (string key : this.canonicalQueryMap.keySet()) {
            canonicalRequestString += awsUriEncode(key) + '=' + awsUriEncode(this.canonicalQueryMap.get(key)) + '&';
        }
        
        for (string key : this.additionalCanonicalHeaders.keySet()) {
            canonicalRequestString += awsUriEncode(key) + '=' + awsUriEncode(this.additionalCanonicalHeaders.get(key)) + '&';
        }
        
        // replace the last & with a \n
        canonicalRequestString = canonicalRequestString.left(canonicalRequestString.length() - 1) + '\n';
        
        // Add the canonical headers with a linefeed at the end of each
        for (string key : this.canonicalHeaders.keySet()) {
            if(String.isNotBlank(this.canonicalHeaders.get(key))) {
                canonicalRequestString += key.toLowerCase() + ':' + this.canonicalHeaders.get(key).trim() + '\n';
            }
        }
        
        // add an additional linefeed
        canonicalRequestString += '\n';
        
        // Add signed headers
        // we assume the elements remain in alphabetical order.
        // TODO: sort just to be sure and check that the map isn't empty.
        integer keyNum = 0;
        for (string key : this.signedHeaders) {
            keyNum ++;
            if(keyNum > 1) {
                canonicalRequestString += ';';
            }
            canonicalRequestString += key.toLowerCase();
        }
        
        // add an additional linefeed
        canonicalRequestString += '\n';
        
        // Add the final line which specifies that we aren't sure of the file size.
        canonicalRequestString += 'UNSIGNED-PAYLOAD';
        
        System.debug('Canonical Request: ' + canonicalRequestString);
        return canonicalRequestString;
    }
    
    public string getStringToSign() {
        // ==== CONSTRUCT THE STRING TO SIGN ====
        string stringToSign = this.awsHeaderEncryptionScheme + '\n'
            + this.dateStampISO + '\n'
            + this.dateStampYYYYMMDD + '/' + this.awsRegion + '/s3/aws4_request' + '\n'
            + EncodingUtil.convertToHex(Crypto.generateDigest(this.awsEncryptionScheme, blob.valueOf(this.getRequestString())));
        System.debug('@@String to sign: ' + stringToSign);
        return stringToSign;
    }
    
    public blob getSigningKey() {
        // ==== GENERATE THE SIGNING KEY ====
        Blob dateKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.dateStampYYYYMMDD), Blob.valueOf('AWS4' + this.accessSecret));
        Blob dateRegionKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.awsRegion), dateKey);
        Blob dateRegionServiceKey = Crypto.generateMac('hmacSHA256', blob.valueOf(this.awsServiceName), dateRegionKey);
        Blob signingKey = Crypto.generateMac('hmacSHA256', blob.valueOf('aws4_request'), dateRegionServiceKey);
        return signingKey;
    }
    public string getSignature() {
        // ==== GENERATE THE SIGNATURE ====
        return this.generateSignature(this.getStringToSign(), this.getSigningKey());
    }
    
    public string generateSignature(string stringToSign, blob signingKey) {
        blob signatureBlob = Crypto.generateMac('hmacSHA256', blob.valueOf(stringToSign), signingKey);
        return EncodingUtil.convertToHex(signatureBlob);
    }
    
    /**
* returns the dateStamp in the format YYYYMMDD
* If dateStamp is not available, defaults to current day
*/
    public string dateStampYYYYMMDD {
        get {
            Date dateToday;
            if (this.dateStamp == null) {
                // Current date (GMT)
                Datetime datetimeToday = System.now();
                dateToday = date.newinstance(datetimeToday.yearGmt(), datetimeToday.monthGmt(), datetimeToday.dayGmt());
            } else {
                dateToday = this.dateStamp;
            }
            
            // Calculate today as yyyymmdd
            String sMonth = String.valueof(dateToday.month());
            String sDay = String.valueof(dateToday.day());
            if(sMonth.length()==1){ sMonth = '0' + sMonth; }
            if(sDay.length()==1){ sDay = '0' + sDay;}
            String sToday = String.valueof(dateToday.year()) + sMonth + sDay;
            
            return sToday;
        }
    }
    
    /**
* returns the dateStamp in the ISO format
*/
    public string dateStampISO {
        get {
            if (this.dateStamp == null) {
                String gmtHour = String.valueOf(System.now().hourGmt());
                String gmtMinute = String.valueOf(System.now().minuteGmt());
                String gmtSecond = String.valueOf(System.now().secondGmt());
                
                if(gmtHour.length()==1){ gmtHour = '0' + gmtHour; }
                if(gmtMinute.length()==1){ gmtMinute = '0' + gmtMinute; }
                if(gmtSecond.length()==1){ gmtSecond = '0' + gmtSecond; }
                
                // add GMT ThhmmssZ
                return dateStampYYYYMMDD + 'T' + gmtHour + gmtMinute + gmtSecond + 'Z';
            }else{
                return dateStampYYYYMMDD + 'T000000Z';
            }
        }
    }
    
    public static string awsUriEncode (string str) {
        if (str == null) {
            str = 'null';
        }
        return EncodingUtil.urlEncode(str, 'UTF-8');
    }
}