public without sharing class DRS_CaseItemForm_CC {
    
    @AuraEnabled
    public static List<Account> getInsurersByName(String insurerName) {
        return DRS_AccountService.getActiveInsurersByName(insurerName);
    }
    
    @AuraEnabled
    public static String getCategories() {
        List<Snippet__c> listSnippets;
        List<String> listPermissionSetNames = new List<String>();
        if(DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId())) {
            listPermissionSetNames.add(DRS_ContactService.PermissionSetMRSInternalUser);
        }
        else {
            listPermissionSetNames = DRS_ContactService.getPermissionSetsForUser(UserInfo.getUserId());
        }
        System.debug('---DRS_CaseItemForm_CC:getCategories:listPermissionSetNames:' + listPermissionSetNames);
        listSnippets = DRS_GlobalUtility.getSnippetsForLocation(DRS_GlobalUtility.LocationMRSUpload, listPermissionSetNames);
        System.debug('---DRS_CaseItemForm_CC:getCategories:listSnippets:' + JSON.serializePretty(listSnippets));
        return JSON.serialize(listSnippets);
    }
    
    @AuraEnabled
    public static String initiateNewCaseItem() {
        try{
            Boolean isSalesforceInternalUser = DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId());
            Boolean isWorkerUser = false;
            Contact objContact;
            
            if(!isSalesforceInternalUser) {
                objContact = DRS_ContactService.getContactForUser();
            }
            
            try {
                isWorkerUser = DRS_ContactService.isWorkerUser(UserInfo.getUserId());
            }
            catch (Exception excep) {} ///Do nothing as an exception is expected for a non community user
            
            if(isSalesforceInternalUser || 
               isWorkerUser || 
               (objContact != null && String.isNotBlank(objContact.Role__c) && objContact.Role__c.contains(DRS_ContactService.ContactRoleLegalRep))) 
            {
                Case objCase = DRS_CaseService.createMRSCase();
                CaseItem__c objCaseItem = DRS_CaseService.createWorkerCaseItem(objCase.Id);
                
                DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = new DRS_GlobalWrapper.CaseItemJSON();
                if(!isSalesforceInternalUser) {
                    objCaseItemFormJSON.contactId = objContact.Id;
                    objCaseItemFormJSON.title = (String.isNotBlank(objContact.Salutation) ? objContact.Salutation : 'Mr.');
                    objCaseItemFormJSON.givenName = objContact.FirstName;
                    objCaseItemFormJSON.surname = objContact.LastName;
                    objCaseItemFormJSON.dob = String.valueOf(objContact.Birthdate);
                    objCaseItemFormJSON.contact = objContact.Phone;
                    objCaseItemFormJSON.emailAddress = objContact.Email;
                    objCaseItemFormJSON.postal = objContact.MailingStreet;
                    objCaseItemFormJSON.suburb = objContact.MailingCity;
                    objCaseItemFormJSON.state = objContact.MailingState;
                    objCaseItemFormJSON.postcode = objContact.MailingPostalCode;
                    objCaseItemFormJSON.interpreter = objContact.InterpreterRequired__c;
                    objCaseItemFormJSON.language = objContact.Language__c;
                    objCaseItemFormJSON.disabilities = objContact.KnownWorkerDisabilities__c;
                }
                objCaseItemFormJSON.isLocked = false;
                objCaseItemFormJSON.caseOrigin = 'Post';
                objCaseItemFormJSON.caseItemId = objCaseItem.Id;
                objCaseItemFormJSON.caseNumber = objCase.CaseNumber;
                objCaseItemFormJSON.claimNo = objCase.ClaimNumber__c;
                objCaseItemFormJSON.caseId = objCase.Id;
                objCaseItemFormJSON.status = DRS_CaseService.CaseItemStatusDraft;
                return JSON.serialize(objCaseItemFormJSON);
            }
            throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'initiateNewCaseItem');
        }
    }
    
    @AuraEnabled
    public static String getExistingCaseItem(String caseItemId) {
        try {
            CaseItem__c objCaseItem = DRS_CaseService.getCaseItemDetails(caseItemId);
            Case objCase = DRS_CaseService.getCaseDetails(objCaseItem.Case__c);
            
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objCase.Id);
            Boolean isInternalUser = DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId());
            Contact objContact;
            if(!isInternalUser) {
                objContact = DRS_ContactService.getContactForUser(UserInfo.getUserId());
            }
            
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = new DRS_GlobalWrapper.CaseItemJSON();
            objCaseItemFormJSON.submittedBy = objCaseItem.SubmittedByName__c;
            objCaseItemFormJSON.submittedDate = objCaseItem.CreatedDate.format(DRS_GlobalUtility.DateFormat);
            objCaseItemFormJSON.caseItemData = objCaseItem.CaseItemData__c;
            objCaseItemFormJSON.caseItemId = objCaseItem.Id;
            objCaseItemFormJSON.status = objCaseItem.Status__c;
            objCaseItemFormJSON.caseNumber = objCase.CaseNumber;
            objCaseItemFormJSON.insurer = new DRS_GlobalWrapper.InsurerJSON();
			objCaseItemFormJSON.insurer.name = objCase.MRSInsurerAccount__c;
			objCaseItemFormJSON.insurer.id = objCase.Insurer__c;
            objCaseItemFormJSON.claimNo = objCase.ClaimNumber__c;
            objCaseItemFormJSON.caseId = objCase.Id;
            objCaseItemFormJSON.workerName = objCase.Contact.Name;
            objCaseItemFormJSON.workCapacity = objCase.S43AWorkCapacity__c;
            objCaseItemFormJSON.suitableEmployment = objCase.S43BSuitableEmployment__c;
            objCaseItemFormJSON.amountEarntInSE = objCase.S43CAmountEarntInSE__c;
            objCaseItemFormJSON.piawe = objCase.S43D1PIAWE__c;
            objCaseItemFormJSON.currentWeeklyEarnings = objCase.S43D2CurrentWeeklyEarnings__c;
            objCaseItemFormJSON.unableToEngageInCertainEmploy = objCase.S43EUnableToEngageInCertainEmploy__c;
            objCaseItemFormJSON.anyOtherWeeklyPaymentDecision = objCase.S43FAnyOtherWeeklyPaymentsDecision__c;
            objCaseItemFormJSON.caseReasons = objCase.CaseReasons__c;
            objCaseItemFormJSON.notAWorkerCapacityDecision = objCase.NotAWorkCapacityDecision__c;
            objCaseItemFormJSON.dateOfInjury = DRS_GlobalUtility.convertDateToString(objCase.DateOfInjury__c);
            objCaseItemFormJSON.workCapacityDecisionDate = DRS_GlobalUtility.convertDateToString(objCase.WCDNoticeDate__c);
            objCaseItemFormJSON.internalReviewDecisionDate = DRS_GlobalUtility.convertDateToString(objCase.IRDecision__c);
            objCaseItemFormJSON.supportingDocumentAttachedDate = DRS_GlobalUtility.convertDateToString(objCase.DateWorkerReceivedIR__c);
            
            objCaseItemFormJSON.isLocked = false;
            if(!isInternalUser) {
                objCaseItemFormJSON.isLocked = true;
                if(objCaseItem.RoleGroup__c.contains(objContact.Account.Type)){
                    objCaseItemFormJSON.isLocked = false;
                }
            }
            
            objCaseItemFormJSON.attachments = new List<DRS_GlobalWrapper.AttachmentJSON>();
            DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON();
            for(Attachment__c objAttachment : objCaseItem.Attachments__r) {
                if(isInternalUser == false && objAttachment.ExternallyVisible__c == false) {
                    continue;
                }
                objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON(); 
                objAttachmentJSON.category = objAttachment.CategoryA__c;
                objAttachmentJSON.tier2 = objAttachment.CategoryB__c;
                objAttachmentJSON.tier3 = objAttachment.CategoryC__c;
                objAttachmentJSON.author = objAttachment.Author__c;
                objAttachmentJSON.dateOfDocument = DRS_GlobalUtility.convertDateToString(objAttachment.AuthoredDate__c);
                objAttachmentJSON.description = objAttachment.Description__c;
                objAttachmentJSON.name = objAttachment.FileName__c;
                objAttachmentJSON.caseId = objAttachment.Case__c;
                objAttachmentJSON.caseItemId = objAttachment.CaseItem__c;
                objAttachmentJSON.viewURL = objAttachment.S3Key__c;
                objAttachmentJSON.attachmentId = objAttachment.Id;
                objCaseItemFormJSON.attachments.add(objAttachmentJSON);
            }
            
            System.debug('---DRS_CaseItemForm_CC:getExistingCaseItem:objCaseItemFormJSON:' + JSON.serializePretty(objCaseItemFormJSON));
            return JSON.serialize(objCaseItemFormJSON);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'getExistingCaseItem');
        }
    }
    
    @AuraEnabled
    public static String saveWorkerCaseItem(String caseItemJson) {
        try {
            System.debug('---DRS_CaseItemForm_CC:saveWorkerCaseItem:caseItemJson:' + caseItemJson);
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objCaseItemFormJSON.caseId);
            
           return DRS_CaseService.submitWorkerCaseItem(caseItemJson);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'saveWorkerCaseItem');
        }
    }
    
    @AuraEnabled
    public static String saveInsurerCaseItem(String caseItemJson) {
    	try {
            System.debug('---DRS_CaseItemForm_CC:saveInsurerCaseItem:caseItemJson:' + caseItemJson);
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objCaseItemFormJSON.caseId);
            
            return DRS_CaseService.submitInsurerCaseItem(caseItemJson);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'saveInsurerCaseItem');
        }
    }
    
    @AuraEnabled
    public static String savePauseWorkerCaseItem(String caseItemJson) {
        try {
            System.debug('---DRS_CaseItemForm_CC:savePauseWorkerCaseItem:caseItemJson:' + caseItemJson);
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objCaseItemFormJSON.caseId);
            
            return DRS_CaseService.saveWorkerCaseItem(caseItemJson);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'savePauseWorkerCaseItem');
        }
    }
    
    @AuraEnabled
    public static String savePauseInsurerCaseItem(String caseItemJson) {
        try {
            System.debug('---DRS_CaseItemForm_CC:savePauseInsurerCaseItem:savePauseInsurerCaseItem:' + caseItemJson);
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objCaseItemFormJSON.caseId);
            
            return DRS_CaseService.saveInsurerCaseItem(caseItemJson);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'savePauseInsurerCaseItem');
        }
    }
    
    @AuraEnabled 
    public static String saveAllocationChecklist(string caseItemJson) {
        try {
            System.debug('---DRS_CaseItemForm_CC:saveAllocationChecklist:caseItemJson:' + caseItemJson);
            DRS_CaseService.submitAllocationChecklist(caseItemJson);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'saveAllocationChecklist');
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static String saveAdditionalInformation(String additionalInformationJSON) {
        try {
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(additionalInformationJSON, DRS_GlobalWrapper.CaseItemJSON.class);
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objCaseItemFormJSON.caseId);
            
            System.debug('---DRS_CaseItemForm_CC:saveAdditionalInformation:additionalInformationJSON' + additionalInformationJSON);
            return DRS_CaseService.saveAdditionalInformation(additionalInformationJSON);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'saveAllocationChecklist');
        }
    }
    
    @AuraEnabled
    public static String getDateDifferenceWithHolidays(String startingDate, String numberOfDays){
        if(String.isNotBlank(startingDate)) {
            try {
                Date startingDateDate = DRS_GlobalUtility.getDateFromString(startingDate);
                DateTime startingDateDateTime = DateTime.newInstance(startingDateDate, DateTime.now().time());
                DateTime endingDateTime = DRS_GlobalUtility.getDateDifferenceWithNextWorkingDay(startingDateDateTime, Integer.valueOf(numberOfDays));
                return DRS_GlobalUtility.convertDateToString(endingDateTime.date());
            }
            catch(Exception excep) {
                return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'getDateDifferenceWithHolidays');
            }
        }
        return startingDate;
    }
    
    @AuraEnabled
    public static String getInternalUsers(String partialName) {
        try{
            System.debug('---DRS_CaseItemForm_CC:getInternalUsers:userName' + partialName);
            
            if(DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId())) {
                List<User> listUsers = DRS_ContactService.getUsersForPartialNames(partialName);
                System.debug('---DRS_CaseItemForm_CC:getInternalUsers:listUsers' + JSON.serializePretty(listUsers));
                return JSON.serialize(listUsers);
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'getInternalUsers');
        }
        return JSON.serialize(new List<User>());
    }
    
    @AuraEnabled
    public static String addAttachment(String attachmentJSON) {
        System.debug('---DRS_CaseItemForm_CC:addAttachment:attachmentJSON:' + attachmentJSON);
        try {
            DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objAttachmentJSON.caseId);
            
            return DRS_CaseService.addAttachment(attachmentJSON);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'addAttachment');
        }
    }
    
    @AuraEnabled
    public static String removeAttachment(String attachmentId) {
        try {
            DRS_CaseService.removeAttachment(attachmentId);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'removeAttachment');
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static String addAttachmentAndGetSignedURL(String attachmentJSON) {
        String path;
        
        try {
            String attachmentId = DRS_CaseItemForm_CC.addAttachment(attachmentJSON);
            Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(attachmentId);
            
            path = DRS_CaseItemForm_CC.getAttachmentS3Path(objAttachment);
            String signedURL = DRS_S3Service.getSignedUploadUrl(path);
            DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON();
            objAttachmentJSON.attachmentId = objAttachment.Id;
            objAttachmentJSON.saveURL = signedURL;
            
            objAttachment = new Attachment__c(Id = attachmentId);
            objAttachment.S3Key__c = path;
            Update objAttachment;
            
            return JSON.serialize(objAttachmentJSON);
        }
        catch (Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'addAttachmentAndGetSignedURL');
        }
    }
    
    /*
@AuraEnabled
public static String initiateMultipartUpload(String attachmentJSON) {
System.debug('---DRS_CaseItemForm_CC:initiateMultipartUpload:attachmentJSON:' + attachmentJSON);
String path;
String multipartUploadId;
try{
DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(objAttachmentJSON.attachmentId);
System.debug('---DRS_CaseItemForm_CC:initiateMultipartUpload:objAttachment:' + objAttachment);

path = DRS_CaseItemForm_CC.getAttachmentS3Path(objAttachment);
String signedURL = DRS_S3Service.getMultipartUploadInitiationUrl(path);
objAttachmentJSON.saveURL = signedURL;
System.debug('---DRS_CaseItemForm_CC:initiateMultipartUpload:signedURL:' + signedURL);

HttpResponse objHttpResponse = DRS_GlobalUtility.callRESTAPI(DRS_GlobalUtility.RESTPostMethod, signedURL, null, null);
System.debug('---DRS_CaseItemForm_CC:initiateMultipartUpload:objHttpResponse.getBody():' + objHttpResponse.getBody());

String xmlString = objHttpResponse.getBody();
if(String.isNotBlank(xmlString)) {
DOM.Document xmlDOC = new DOM.Document();
xmlDOC.load(xmlString);
for(Dom.XMLNode child : xmlDOC.getRootElement().getChildElements())
{
if(child.getName().toUpperCase() == 'UPLOADID') {
multipartUploadId = child.getText();
}
}
System.debug('---DRS_CaseItemForm_CC:initiateMultipartUpload:objHttpResponse.multipartUploadId:' + multipartUploadId);
if(String.isBlank(multipartUploadId)) {
DRS_CaseService.removeAttachment(objAttachmentJSON.attachmentId);
throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.MultipartUploadFailed));
}

objAttachment = new Attachment__c(Id = objAttachmentJSON.attachmentId);
objAttachment.S3Key__c = path;
objAttachment.UploadId__c = multipartUploadId;
Update objAttachment;

return JSON.serialize(objAttachmentJSON);
}
else {
DRS_CaseService.removeAttachment(objAttachmentJSON.attachmentId);
throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.MultipartUploadFailed));
}
}
catch (Exception excep) {
DRS_CaseService.abortMultipartUpload(attachmentJSON);
return DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'addAttachmentAndGetSignedURL');
}
}

@AuraEnabled
public static String getUploadUrlForParts(String numberOfParts, String attachmentJSON) {
DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(objAttachmentJSON.attachmentId);
List<String> listS3SignedURLs = new List<String>();
String s3SignedURL;
for(Integer counter = 1; counter <= Integer.valueOf(numberOfParts); counter++) {
s3SignedURL = DRS_S3Service.getMultipartUploadUrl(objAttachment.S3Key__c, String.valueOf(counter), objAttachment.UploadId__c);
System.debug('---DRS_CaseItemForm_CC:getUploadUrlForParts:partNumber:' + counter + ', s3SignedURL:' + s3SignedURL);
listS3SignedURLs.add(s3SignedURL);
}
System.debug('---DRS_CaseItemForm_CC:getUploadUrlForParts:listS3SignedURLs:' + listS3SignedURLs);
return JSON.serialize(listS3SignedURLs);
}

@AuraEnabled
public static void completeMultipartUpload(String attachmentJSON) {
try {
System.debug('---DRS_CaseItemForm_CC:completeMultipartUpload:attachmentJSON:' + attachmentJSON);
DRS_CaseService.completeMultipartUpload(attachmentJSON);
}
catch(Exception excep) {
DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'completeMultipartUpload');
}
}

@AuraEnabled
public static void abortMultipartUpload(String attachmentJSON) {
try {
DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
DRS_CaseService.abortMultipartUpload(objAttachmentJSON.attachmentId);
}
catch(Exception excep) {
DRS_GlobalUtility.handleAuraException(excep, 'DRS_CaseItemForm_CC', 'abortMultipartUpload');
}
}
*/
    
    private static String getAttachmentS3Path(Attachment__c objAttachment) {
        String path = ((String)objAttachment.Case__c).left(15) + '/';
        
        if (String.isNotBlank(objAttachment.CaseItem__c)) {
            path += ((String)objAttachment.CaseItem__c).left(15) + '/';
        }
        
        path += String.valueOF(objAttachment.Id).left(15) +  '/' + EncodingUtil.urlEncode(DRS_S3Service.handleFileNameSpecialChar(objAttachment.FileName__c), 'UTF-8').replace('+', '%20');
        
        return path;
    }
}