///A test data factory class to prepare test data for unit testing
public class DRS_TestData {
    ///Variable declaration
    private static User padminUser;
    public static User communityAdminUser;
    public static User adminUser {
        get {
            if(DRS_TestData.padminUser == null) {
                DRS_TestData.padminUser = [Select Id From User Where Profile.Name = 'System Administrator' Limit 1];
            }
            return DRS_TestData.padminUser;
        }
    }
    
    ///Creates snippets
    public static void createSnippets() {
        List<Snippet__c> listSnippets = new List<Snippet__c>();
        listSnippets.add(new Snippet__c(IsActive__c = true, Location__c = DRS_GlobalUtility.LocationMRSUpload, PermissionSetNames__c = DRS_ContactService.PermissionSetMRSWorker + ';' + DRS_ContactService.PermissionSetMRSInsurer, SnippetName__c = 'Test1', Value__c = 'Test2'));
        listSnippets.add(new Snippet__c(IsActive__c = true, Location__c = DRS_GlobalUtility.LocationMRSUpload, PermissionSetNames__c = DRS_ContactService.PermissionSetMRSWorker + ';' + DRS_ContactService.PermissionSetMRSInsurer, SnippetName__c = 'Test2', Value__c = 'Test2'));
        listSnippets.add(new Snippet__c(IsActive__c = true, Location__c = DRS_GlobalUtility.LocationMRSUpload, PermissionSetNames__c = DRS_ContactService.PermissionSetMRSInsurer, SnippetName__c = 'Test1.Test1', Value__c = 'Test1.Test1'));
        listSnippets.add(new Snippet__c(IsActive__c = true, Location__c = DRS_GlobalUtility.LocationMRSCaseStatus, PermissionSetNames__c = DRS_ContactService.PermissionSetMRSInternalUser, SnippetName__c = 'TestStatus', Value__c = 'TestStatus'));
        listSnippets.add(new Snippet__c(IsActive__c = true, Location__c = DRS_GlobalUtility.LocationMRSCaseDetails, PermissionSetNames__c = DRS_ContactService.PermissionSetMRSInternalUser, SnippetName__c = 'pendingCases', Value__c = 'Testing1'));
        listSnippets.add(new Snippet__c(IsActive__c = true, Location__c = DRS_GlobalUtility.LocationMRSCaseDetails, PermissionSetNames__c = DRS_ContactService.PermissionSetMRSInternalUser, SnippetName__c = 'attachments', Value__c = 'Testing2'));
        listSnippets.add(new Snippet__c(IsActive__c = true, Location__c = DRS_GlobalUtility.LocationMRSCaseDetails, PermissionSetNames__c = DRS_ContactService.PermissionSetMRSInternalUser, SnippetName__c = 'caseItems', Value__c = 'Testing3'));
        Insert listSnippets;
    }
    
    ///Creates a Customer Community Portal Account, Contact and User
    ///The User has IsActive = True and Profile is fetched from Custom Settings
    public static String createPortalAccountContactAndUser(String accountRecordType, String accountType, String contactRole, String accountId, Boolean isAdminUser) {
        String contactId;
        System.runAs(DRS_TestData.adminUser) {
            String randomString = DRS_GlobalUtility.getGuid().left(8);
            String profileId = (accountType == DRS_AccountService.TypeInsurer ? DRS_GlobalUtility.getMRSConfiguration().ProfileId2__c : DRS_GlobalUtility.getMRSConfiguration().ProfileId1__c);
            
            ///Create Contact and Account
            contactId = DRS_ContactService.createCommunityContactAndAccount(
                'Mr.',
                'Contact', 
                'Portal ' + randomString, 
                '01/01/1970', 
                '0400000000', 
                'test' + randomString + '@test.com', 
                'Mailing Street', 
                'Mailing City', 
                'NSW', 
                '2000', 
                contactRole, 
                accountId,
                isAdminUser,
                null,
                null,
                null);
            
            ///Update Account with correct Record Type
            if(String.isBlank(accountId)) {
                Contact objContact = DRS_ContactService.getContactDetails(contactId);
                Account objAccount = new Account();
                objAccount.Id = objContact.AccountId;
                objAccount.Type = accountType;
                objAccount.RecordTypeId = DRS_GlobalUtility.getRecordTypes().get(DRS_AccountService.AccountUnderscore + accountRecordType);
                Update objAccount;
            }
            
            ///Create the User
            User objUser = new User();
            objUser.Username = 'test' + randomString + '@test.com';
            objUser.ContactId = contactId;
            objUser.ProfileId = profileId;
            objUser.Alias = randomString;
            objUser.Email = 'test' + randomString + '@test.com';
            objUser.EmailEncodingKey = 'UTF-8';
            objUser.LastName = 'Portal ' + randomString;
            objUser.CommunityNickname = 'test123' + randomString;
            objUser.TimeZoneSidKey = 'Australia/Sydney';
            objUser.LocaleSidKey = 'en_US';
            objUser.LanguageLocaleKey = 'en_US';
            objUser.IsActive = true;
            Insert objUser;
            
            if(isAdminUser) {
                DRS_TestData.communityAdminUser = objUser;
            }
        }
        return contactId;
    }
    
    ///Creates a Case record with Case Item initiated
    /// The initiated Case Item should be submitted as a Worker
    public static Case initiateWorkerCaseItem() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String claimsManagerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleClaimsManager, triageContact.AccountId, false);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        
        String caseItemFormJSON = DRS_TestData.initiateWorkerCaseItem(workerContactId);
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        
        return DRS_CaseService.getCaseDetails(objCaseItemFormJSON.caseId);
    }
    
    ///Creates an MRS Case with Worker Case Item Saved 
    /// A saved Case Item is Pending and not Submitted 
    public static Case createCaseWithWorkerCaseItemSaved() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String claimsManagerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleClaimsManager, triageContact.AccountId, false);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        
        String caseItemFormJSON = DRS_TestData.initiateWorkerCaseItem(workerContactId);
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        
        DRS_TestData.submitWorkerCaseItem(workerContactId, triageContact.AccountId, triageContact.Account.Name, objCaseItemFormJSON.caseItemId, objCaseItemFormJSON.caseId, true);
        
        return DRS_CaseService.getCaseDetails(objCaseItemFormJSON.caseId);
    }
    
    ///Creates an MRS Case with Worker Case Item Submitted 
    public static Case createCaseWithWorkerCaseItemSubmitted() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String claimsManagerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleClaimsManager, triageContact.AccountId, false);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        
        String caseItemFormJSON = DRS_TestData.initiateWorkerCaseItem(workerContactId);
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        
        DRS_TestData.submitWorkerCaseItem(workerContactId, triageContact.AccountId, triageContact.Account.Name, objCaseItemFormJSON.caseItemId, objCaseItemFormJSON.caseId, false);
        
        return DRS_CaseService.getCaseDetails(objCaseItemFormJSON.caseId);
    }
    
    ///Creates an MRS Case with Worker and Insurer Case Items Submitted 
    public static Case createCaseWithInsurerCaseItemSubmitted() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String claimsManagerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleClaimsManager, triageContact.AccountId, false);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        
        String caseItemFormJSON = DRS_TestData.initiateWorkerCaseItem(workerContactId);
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        
        DRS_TestData.submitWorkerCaseItem(workerContactId, triageContact.AccountId, triageContact.Account.Name, objCaseItemFormJSON.caseItemId, objCaseItemFormJSON.caseId, false);
        DRS_TestData.initiateInsurerCaseItem(objCaseItemFormJSON.caseId);
        DRS_TestData.submitInsurerCaseItem(triageContactId, objCaseItemFormJSON.caseId, false);
        
        return DRS_CaseService.getCaseDetails(objCaseItemFormJSON.caseId);
    }
    
    ///Adds attachments to Case
    public static void addAttachment(String caseId) {
        DRS_TestData.addAttachment(caseId, null, true);
    }
    
    ///Adds attachments to Case
    public static void addAttachment(String caseId, Boolean externallyVisible) {
        DRS_TestData.addAttachment(caseId, null, externallyVisible);
    }
    
    public static void addAttachment(String caseId, String caseItemId, Boolean externallyVisible) {
        DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON();
        objAttachmentJSON.name = 'Filename1.png';
        objAttachmentJSON.description = 'File Name 1 description';
        objAttachmentJSON.category = 'Main Category 1';
        objAttachmentJSON.tier2 = 'tier 201';
        objAttachmentJSON.tier3 = 'tier 301';
        objAttachmentJSON.author = 'Author1';
        objAttachmentJSON.dateOfDocument = '12/12/2000';
        objAttachmentJSON.caseId = caseId;
        objAttachmentJSON.caseItemId = caseItemId;
        objAttachmentJSON.externallyVisible = externallyVisible;
        DRS_CaseService.addAttachment(JSON.serialize(objAttachmentJSON));
    }
    
    ///Initiates the creation of new MRS Case as a worker user
    public static String initiateWorkerCaseItem(String workerContactId) {
        String caseItemFormJSON;
        System.runAs(DRS_ContactService.getUserForContact(workerContactId)) {
            caseItemFormJSON = DRS_CaseItemForm_CC.initiateNewCaseItem();
        }
        return caseItemFormJSON;
    }
    
    ///Initiates the creation of Insurer Case Item
    public static void initiateInsurerCaseItem(String caseId) {
        DRS_CaseService.executeInsurerCaseItemAutomation(caseId);
    }
    
    ///Submits the Worker Case Item
    public static CaseItem__c submitWorkerCaseItem(String workerContactId, String insurerId, String insurerName, String caseItemId, String caseId, Boolean isPauseSave) {
        Contact workerContact = DRS_ContactService.getContactDetails(workerContactId);
        return DRS_TestData.submitWorkerCaseItem(
            workerContactId, insurerId, insurerName, caseItemId, caseId, isPauseSave, workerContact.Email,
            'no', ///behalfOfWorker
            'Given Name', ///givenName
            'Surname', ///surname
            '12/12/1950', ///dob
            'yes', ///interpreter
            'French', ///language
            'Disabilities', ///disabilities
            '12/12/2005', ///dateOfInjury
            '123123123', ///claimNo
            'Worker Advocate', ///representationDetails
            'Representative', ///representative
            '04/03/2017', ///internalReviewDecisionDate
            '03/03/2017', ///workCapacityDecisionDate
            '02/03/2017', ///notReviewDecisionDate
            '01/03/2017', ///supportingDocumentAttachedDate
            'true', ///decisionCurrentWorkCapacity
            'true', ///decisionSuitableEmployment
            'true', ///decisionAmountEarnInSuitableEmployment
            'true', ///decisionAmountPreInjury
            'true', ///decisionResultUnableEngageInEmployment
            'true' ///otherInsurerAfferctsEntitlement
        );
    }
    
    ///Submits the Worker Case Item
    public static CaseItem__c submitWorkerCaseItem(
        String workerContactId, String insurerId, String insurerName, String caseItemId, String caseId, Boolean isPauseSave, 
        String emailAddress, string behalfOfWorker, string givenName, string surname, string dob,  
        string interpreter, string language, string disabilities, string dateOfInjury, string claimNo, string representationDetails, string representative, 
        string internalReviewDecisionDate, string workCapacityDecisionDate, string notReviewDecisionDate, string supportingDocumentAttachedDate, string decisionCurrentWorkCapacity, 
        string decisionSuitableEmployment, string decisionAmountEarnInSuitableEmployment, string decisionAmountPreInjury, string decisionResultUnableEngageInEmployment,
        string otherInsurerAfferctsEntitlement) 
    {
        User objRunAsUser;
        if(String.isBlank(workerContactId)) {
            objRunAsUser = DRS_TestData.adminUser;
        }
        else {
            objRunAsUser = DRS_ContactService.getUserForContact(workerContactId);
        }
        System.runAs(objRunAsUser) {
            DRS_GlobalWrapper.CaseItemJSON objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
            objCaseItemJSON.insurer = new DRS_GlobalWrapper.InsurerJSON();
            objCaseItemJSON.caseItemId = caseItemId;
            objCaseItemJSON.caseId = caseId;
            objCaseItemJSON.insurer.id = insurerId;
            objCaseItemJSON.insurer.name = insurerName;
            objCaseItemJSON.contactId = workerContactId;
            objCaseItemJSON.emailAddress = emailAddress;
            objCaseItemJSON.behalfOfWorker = behalfOfWorker;
            objCaseItemJSON.givenName = givenName;
            objCaseItemJSON.surname = surname;
            objCaseItemJSON.dob = dob;
            objCaseItemJSON.contact = '0400000000';
            objCaseItemJSON.postal = 'Postal';
            objCaseItemJSON.suburb = 'Suburb';
            objCaseItemJSON.state = 'NSW';
            objCaseItemJSON.postcode = '2000';
            objCaseItemJSON.interpreter = interpreter;
            objCaseItemJSON.language = language;
            objCaseItemJSON.disabilities = disabilities;
            objCaseItemJSON.dateOfInjury = dateOfInjury;
            objCaseItemJSON.claimNo = claimNo;
            objCaseItemJSON.representationDetails = representationDetails;
            objCaseItemJSON.representative = representative;
            objCaseItemJSON.internalReviewDecisionDate = internalReviewDecisionDate;
            objCaseItemJSON.workCapacityDecisionDate = workCapacityDecisionDate;
            objCaseItemJSON.notReviewDecisionDate = notReviewDecisionDate;
            objCaseItemJSON.supportingDocumentAttachedDate = supportingDocumentAttachedDate;
            objCaseItemJSON.decisionCurrentWorkCapacity = decisionCurrentWorkCapacity;
            objCaseItemJSON.decisionSuitableEmployment = decisionSuitableEmployment;
            objCaseItemJSON.decisionAmountEarnInSuitableEmployment = decisionAmountEarnInSuitableEmployment;
            objCaseItemJSON.decisionAmountPreInjury = decisionAmountPreInjury;
            objCaseItemJSON.decisionResultUnableEngageInEmployment = decisionResultUnableEngageInEmployment;
            objCaseItemJSON.otherInsurerAfferctsEntitlement = otherInsurerAfferctsEntitlement;
            if(isPauseSave) {
                objCaseItemJSON.isSavedForLater = true;
            }
            
            String workerCaseItemJSON = JSON.serialize(objCaseItemJSON);
            String workerCaseItemAdditionalJSON = '{\"reason\":\"Outline\",\"imNotSure\":true,\"InternalReviewbyInsurer\":\"supportingDocumentAttached\",\"representativePostcode\":\"2000\",\"representativeState\":\"NSW\",\"representativeSuburb\":\"Suburb\",\"representativeAddress\":\"Street\",\"representativeDXAddress\":\"Post\",\"representativeContact\":\"0450123123\",\"emailAddressRepresentative\":\"email123123123123123@email.com\",\"organisation\":\"Firm\",\"representation\":\"yes\"}';
            Map<String,Object> mapWorkerCaseItemJSON = (Map<String,Object>)JSON.deserializeUntyped(workerCaseItemJSON);
            mapWorkerCaseItemJSON.putAll((Map<String,Object>)JSON.deserializeUntyped(workerCaseItemAdditionalJSON));
            
            if(isPauseSave) {
                DRS_CaseItemForm_CC.savePauseWorkerCaseItem(JSON.serialize(mapWorkerCaseItemJSON));
            }
            else {
                DRS_CaseItemForm_CC.saveWorkerCaseItem(JSON.serialize(mapWorkerCaseItemJSON));
            }
        }
        return DRS_CaseService.getCaseItemDetails(caseItemId);
    }
    
    ///Submits the Insurer Case Item
    public static CaseItem__c submitInsurerCaseItem(String insurerContactId, String caseId, Boolean isPauseSave) {
        return DRS_TestData.submitInsurerCaseItem(
            insurerContactId, caseId, isPauseSave,
            'yes', ///workInReceipt
            '02/03/2017', ///supportingDocumentAttachedDate
            '01/03/2017' ///workCapacityDecisionDate
        );
    }
    
    ///Submits the Insurer Case Item
    public static CaseItem__c submitInsurerCaseItem(
        String insurerContactId, String caseId, Boolean isPauseSave, 
        string workInReceipt, string supportingDocumentAttachedDate, string workCapacityDecisionDate) 
    {
        
        CaseItem__c objInsurerCaseItem = [Select Id From CaseItem__c Where Type__c =: DRS_CaseService.InsurerReplyTaskType And Case__c =: caseId];
        System.runAs(DRS_ContactService.getUserForContact(insurerContactId)) {
            DRS_GlobalWrapper.CaseItemJSON objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
            objCaseItemJSON.caseItemId = objInsurerCaseItem.Id;
            objCaseItemJSON.caseId = caseId;
            objCaseItemJSON.workInReceipt = workInReceipt;
            objCaseItemJSON.supportingDocumentAttachedDate = supportingDocumentAttachedDate;
            objCaseItemJSON.workCapacityDecisionDate = workCapacityDecisionDate;
            String insurerCaseItemJSON = JSON.serialize(objCaseItemJSON);
            String insurerCaseItemAdditionalJSON = '{\"category_sub\":\"Independent medical reports (IME)\",\"response\":\"Response\",\"caseNumber\":\"00002547\",\"claimNo\":\"\",\"dateOfInjury\":\"\",\"dob\":\"\",\"surname\":\"\",\"givenName\":\"\",\"weeklyPayment\":\"2\"}';
            Map<String,Object> mapInsurerCaseItemJSON = (Map<String,Object>)JSON.deserializeUntyped(insurerCaseItemJSON);
            mapInsurerCaseItemJSON.putAll((Map<String,Object>)JSON.deserializeUntyped(insurerCaseItemAdditionalJSON));
            
            if(isPauseSave) {
                DRS_CaseItemForm_CC.savePauseInsurerCaseItem(JSON.serialize(mapInsurerCaseItemJSON));
            }
            else {
                DRS_CaseItemForm_CC.saveInsurerCaseItem(JSON.serialize(mapInsurerCaseItemJSON));
            }
        }
        return DRS_CaseService.getCaseItemDetails(objInsurerCaseItem.Id);
    }
    
    public static String submitAdditionalInformation(String contactId, String additionalInformationJSON) {
        String caseId;
        System.runAs(DRS_ContactService.getUserForContact(contactId)) {
            caseId = DRS_CaseItemForm_CC.saveAdditionalInformation(additionalInformationJSON);
        }
        return caseId;
    }
    
    ///A mock implementation class for all DRS related callouts
    public class DRS_CalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest objRequest) {
            String endpoint = objRequest.getEndpoint();
            HttpResponse objResponse;
            if(String.isBlank(endpoint)) {
                return null;
            }
            Configuration__c objConfiguration = DRS_GlobalUtility.getMRSConfiguration();
            if(endpoint.contains(objConfiguration.S3Host__c)) {
                objResponse = this.handleAmazonS3Callouts(objRequest);
            }
            return objResponse;
        }
        
        private HttpResponse handleAmazonS3Callouts(HttpRequest objRequest) {
            HttpResponse objResponse = new HttpResponse();
            if(objRequest.getMethod() == DRS_GlobalUtility.RESTDeleteMethod) {
                objResponse.setStatusCode(204);
            }
            return objResponse;
        }
    }
    
    ///A Queueable class to assign the Permission Sets to the users
    ///The opertions has to be done in a queueable action because of multiple setup objects getting effected in the transaction
    public class PermissionSetAssignmentClass implements Queueable {
        public String userId;
        public String permissionSetId;
        
        public void execute(QueueableContext objContext) {
            PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment();
            objPermissionSetAssignment.AssigneeId = this.userId;
            objPermissionSetAssignment.PermissionSetId = this.permissionSetId;
            Insert objPermissionSetAssignment;
        }
    }
}