public with sharing class DRS_ViewDocument_CX {
    public String url {get; set;}
    public Boolean isMultimedia {get;set;}
    public String videoMultiMediaURL {get;set;}
    public String audioMultiMediaURL {get;set;}
    
    public DRS_ViewDocument_CX(ApexPages.StandardController stdController) {
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        DomainSite objWorkerDomainSite = DRS_GlobalUtility.getDomainSiteForId(objMRSConfiguration.SiteId1__c);
        Boolean isSalesforceInternalUser = DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId());
        Attachment__c objAttachment = (Attachment__c)stdController.getRecord();
        objAttachment = [Select Id, Filename__c, S3Key__c from Attachment__c where Id =:objAttachment.Id];
        Organization objOrganization = [Select IsSandbox From Organization Limit 1];
        
        String fileExtension = objAttachment.FileName__c.subString(objAttachment.FileName__c.lastIndexOf('.') + 1);
        fileExtension = fileExtension.toLowerCase();
        String signedURL = DRS_S3Service.getSignedDownloadUrl(objAttachment.S3Key__c);
        List<String> listDownloadedExtensions = new List<String>();
        Boolean downloadMedia = false;
        
        listDownloadedExtensions.add('mkv');
        listDownloadedExtensions.add('flv');
        listDownloadedExtensions.add('vob');
        listDownloadedExtensions.add('drc');
        listDownloadedExtensions.add('gif');
        listDownloadedExtensions.add('gifv');
        listDownloadedExtensions.add('mng');
        listDownloadedExtensions.add('avi');
        listDownloadedExtensions.add('mov');
        listDownloadedExtensions.add('qt');
        listDownloadedExtensions.add('wmv');
        listDownloadedExtensions.add('yuv');
        listDownloadedExtensions.add('rm');
        listDownloadedExtensions.add('rmvb');
        listDownloadedExtensions.add('asf');
        listDownloadedExtensions.add('amv');
        listDownloadedExtensions.add('mpg');
        listDownloadedExtensions.add('mp2');
        listDownloadedExtensions.add('mpeg');
        listDownloadedExtensions.add('mpe');
        listDownloadedExtensions.add('mpv');
        listDownloadedExtensions.add('m2v');
        listDownloadedExtensions.add('svi');
        listDownloadedExtensions.add('3gp');
        listDownloadedExtensions.add('3g2');
        listDownloadedExtensions.add('mxf');
        listDownloadedExtensions.add('roq');
        listDownloadedExtensions.add('nsv');
        listDownloadedExtensions.add('f4v');
        listDownloadedExtensions.add('f4p');
        listDownloadedExtensions.add('f4a');
        listDownloadedExtensions.add('f4b');
        listDownloadedExtensions.add('aa');
        listDownloadedExtensions.add('aac');
        listDownloadedExtensions.add('aax');
        listDownloadedExtensions.add('act');
        listDownloadedExtensions.add('aiff');
        listDownloadedExtensions.add('amr');
        listDownloadedExtensions.add('ape');
        listDownloadedExtensions.add('au');
        listDownloadedExtensions.add('awb');
        listDownloadedExtensions.add('dct');
        listDownloadedExtensions.add('dss');
        listDownloadedExtensions.add('dvf');
        listDownloadedExtensions.add('flac');
        listDownloadedExtensions.add('gsm');
        listDownloadedExtensions.add('iklax');
        listDownloadedExtensions.add('ivs');
        listDownloadedExtensions.add('m4a');
        listDownloadedExtensions.add('m4b');
        listDownloadedExtensions.add('mmf');
        listDownloadedExtensions.add('mpc');
        listDownloadedExtensions.add('msv');
        listDownloadedExtensions.add('opus');
        listDownloadedExtensions.add('ra');
        listDownloadedExtensions.add('rm');
        listDownloadedExtensions.add('raw');
        listDownloadedExtensions.add('sln');
        listDownloadedExtensions.add('tta');
        listDownloadedExtensions.add('vox');
        listDownloadedExtensions.add('wv');
        
        for(String downloadedExtension : listDownloadedExtensions) {
        	if(fileExtension == downloadedExtension) {
        		downloadMedia = true;
        	}
        }
        
        isMultimedia = false;
        if(fileExtension == 'ogg' || fileExtension == 'ogv' || fileExtension == 'webm' || fileExtension == 'mp4' ||
        	fileExtension == 'm4v' || fileExtension == 'm4p') {
            isMultimedia = true;
            videoMultiMediaURL = signedURL;
        }
        else if (fileExtension == 'mp3' || fileExtension == 'wav' || fileExtension == 'oga' || fileExtension == 'mogg') {
            isMultimedia = true;
            audioMultiMediaURL = signedURL;
        }
        else if (downloadMedia) {
        	this.url = signedURL;
        }
        else {
            this.url = ''
                + objMRSConfiguration.EC2ServerPath__c + '/?userId=' + UserInfo.getUserId()
                + '&userName=' + UserInfo.getName()
                + '&attachmentId=' + objAttachment.Id
                + '&communityURL=' + EncodingUtil.urlEncode(objWorkerDomainSite.Domain.Domain, 'UTF-8')
                + '&externalView=' + !isSalesforceInternalUser
                + '&isTest=' + objOrganization.IsSandbox
                + '&document=' + EncodingUtil.urlEncode(signedURL, 'UTF-8');
        }
    }
}