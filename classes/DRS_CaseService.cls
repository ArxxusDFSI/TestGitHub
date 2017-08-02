///The service class to facilitate Case, CaseTeamMember, CaseItem__c, and Attachment__c objects
public class DRS_CaseService {
    ///Variables and constants
    public static final String CaseUnderscore = 'Case_';
    public static final String TaskUnderscore = 'Task_';
    public static final String CaseItemUnderscore = 'CaseItem__c_';
    public static final String WorkerRoleName = 'Worker';
    public static final String WorkerRepresentativeRoleName = 'Worker Representative';
    public static final String InsurerTriageRoleName = 'Insurer Triager';
    public static final String CaseStatusDraft = 'Draft';
    public static final String CaseStatusNew = 'New';
    public static final String CaseStatusClosed = 'Closed';
    public static final String CaseReasonExpired = 'Review Declined - Expired application';
    public static final String CaseReasonDeletedDraft = 'Review Declined - Deleted draft application';
    public static final String CaseItemStatusDraft = 'Draft';
    public static final String CaseItemStatusPending = 'Pending';
    public static final String CaseItemStatusSubmitted = 'Submitted';
    public static final String CaseItemStatusExpired = 'Expired';
    public static final String InitialTaskStatus = 'Not Started';
    public static final String CompletedTaskStatus = 'Completed';
    public static final String WorkerCaseItemType = 'Application for merit review by SIRA form';
    public static final String InsurerReplyTaskType = 'Reply to an application for merit review by SIRA form';
    public static final String AdditionalInformationTaskType = 'Additional information request';
    public static final String AllocationChecklistTaskType = 'Allocation Checklist';
    public static final String JurisdictionChecklistTaskType = 'Jurisdiction Checklist';
    public static final String CaseItemRoleGroupInternal = 'Merit Review Service';
    public static final String CaseItemRoleGroupLegalRep = 'Legal Firm';
    public static final String EmailWorkerCaseItemSubmitted = 'Worker_Application_Submitted_Email';
    public static final String EmailWorkerCaseItemSubmittedWorker = 'Worker_Application_Submitted_Worker_Email';
    public static final String EmailInsurerCaseItemSubmitted = 'Insurer_Application_Submitted_Email';
    public static final String EmailAdditionalInformationRequired = 'Additional_Information_has_been_requested';
    public static final String EmailAdditionalInformationSubmitted = 'Additional_Information_has_been_submitted';
    public static final String EmailCaseTeamMemberAdded = 'Case_Team_Member_Added_Email';
    public static final String EmailWorkerApplicationSavedForLater = 'Worker_Application_Saved_for_Later';
    public static final String RecordTypeMeritReviewService = 'Merit_Review_Service';
    public static final String RecordTypeCaseItem = 'Case_Item';
    public static final String WorkerFormCommunityURL = 'form';
    public static final Decimal DefaulDaysUntilDueDate = 7.0;
    
    ///Gets Case details for the provided caseId
    ///The result contains fields for case, related case items, related attachments,
    /// related TeamMembers, and related Tasks
    public static Case getCaseDetails(String caseId) {
        return [
            Select Id, Status, ClaimNumber__c, CreatedDate, ContactId, CaseNumber, Subject, Origin, Insurer__c, Insurer__r.Name,
            DateTimeCaseLodged__c, Contact.Name, DateWorkerReceivedIR__c, Contact.Email,
            S43AWorkCapacity__c, S43BSuitableEmployment__c, S43CAmountEarntInSE__c, 
            S43D1PIAWE__c, S43D2CurrentWeeklyEarnings__c, S43EUnableToEngageInCertainEmploy__c, 
            S43FAnyOtherWeeklyPaymentsDecision__c, CaseReasons__c, NotAWorkCapacityDecision__c,
            DateOfInjury__c, IRDecision__c, WCDNoticeDate__c, RepresentativeType__c, ClaimType__c, IRLodged__c,
            PrimaryContact__c, PrimaryContactPublicEmail__c, PrimaryContactPublicPhone__c,
            PrimaryContactName__c, Contact.Account.Type, MRSInsurerAccount__c,
            (Select Id, Name, CaseItemData__c, CreatedDate, Status__c, Case__r.CaseNumber, Case__r.Insurer__c,
             RoleGroup__c, CommunityPageURL__c, DueDate__c, Type__c, SubmittedBy__c, SubmittedByName__c,
             ExpiryDate__c
             From CaseItems__r),
            (Select Id, Name, FileName__c, Description__c, CreatedDate, SubmittedBy__c, 
             CategoryA__c, CategoryB__c, CategoryC__c, Author__c, AuthoredDate__c,
             ExternallyVisible__c, Case__c, CaseItem__c, S3Key__c
             From Attachments__r),
            (Select Id, Member.Id, Member.Name, TeamRole.Id, TeamRole.Name, TeamRole.PreferencesVisibleInCSP
             From TeamMembers),
            (Select Id, WhatId, WhoId, CaseItem__c, Status, Description, Subject, ActivityDate, TaskTemplate__c
             From Tasks)
            From Case
            Where Id =: caseId
        ];
    }
    
    ///Gets Case details for the provided caseId
    ///The result contains fields for case, related case items, related attachments,
    /// related TeamMembers, and related Tasks
    /// the list is ordered by the CaseNumber in descending order
    public static List<Case> getCaseDetails(Set<Id> caseIds) {
        return [
            Select Id, Status, ClaimNumber__c, CreatedDate, ContactId, CaseNumber, Subject, Origin, Insurer__c, Insurer__r.Name,
            DateTimeCaseLodged__c, Contact.Name, DateWorkerReceivedIR__c, Contact.Email,
            S43AWorkCapacity__c, S43BSuitableEmployment__c, S43CAmountEarntInSE__c, 
            S43D1PIAWE__c, S43D2CurrentWeeklyEarnings__c, S43EUnableToEngageInCertainEmploy__c, 
            S43FAnyOtherWeeklyPaymentsDecision__c, CaseReasons__c, NotAWorkCapacityDecision__c,
            DateOfInjury__c, IRDecision__c, WCDNoticeDate__c, RepresentativeType__c, ClaimType__c, IRLodged__c,
            PrimaryContact__c, PrimaryContactPublicEmail__c, PrimaryContactPublicPhone__c,
            PrimaryContactName__c, Contact.Account.Type, MRSInsurerAccount__c,
            (Select Id, Name, CaseItemData__c, CreatedDate, Status__c, Case__r.CaseNumber, Case__r.Insurer__c,
             RoleGroup__c, CommunityPageURL__c, DueDate__c, Type__c, SubmittedBy__c, SubmittedByName__c,
             ExpiryDate__c
             From CaseItems__r),
            (Select Id, Name, FileName__c, Description__c, CreatedDate, SubmittedBy__c, 
             CategoryA__c, CategoryB__c, CategoryC__c, Author__c, AuthoredDate__c,
             ExternallyVisible__c, Case__c, CaseItem__c, S3Key__c
             From Attachments__r),
            /*(Select Id, Member.Id, Member.Name, TeamRole.Id, TeamRole.Name, TeamRole.PreferencesVisibleInCSP
From TeamMembers),*/
            (Select Id, WhatId, WhoId, CaseItem__c, Status, Description, Subject, ActivityDate, TaskTemplate__c
             From Tasks)
            From Case
            Where Id =: caseIds
            And IsClosed = false
            Order By CaseNumber ASC
        ];
    }
    
    ///Gets Closed Case details for the provided caseId
    ///The result contains fields for case, related case items, related attachments,
    /// related TeamMembers, and related Tasks
    /// the list is ordered by the CaseNumber in descending order
    public static List<Case> getClosedCaseDetails(Set<Id> caseIds) {
        return [
            Select Id, Status, ClaimNumber__c, CreatedDate, ContactId, CaseNumber, Subject, Origin, Insurer__c, Insurer__r.Name,
            DateTimeCaseLodged__c, Contact.Name, DateWorkerReceivedIR__c, Contact.Email,
            S43AWorkCapacity__c, S43BSuitableEmployment__c, S43CAmountEarntInSE__c, 
            S43D1PIAWE__c, S43D2CurrentWeeklyEarnings__c, S43EUnableToEngageInCertainEmploy__c, 
            S43FAnyOtherWeeklyPaymentsDecision__c, CaseReasons__c, NotAWorkCapacityDecision__c,
            DateOfInjury__c, IRDecision__c, WCDNoticeDate__c, RepresentativeType__c, ClaimType__c, IRLodged__c,
            PrimaryContact__c, PrimaryContactPublicEmail__c, PrimaryContactPublicPhone__c,
            PrimaryContactName__c, MRSInsurerAccount__c,
            (Select Id, Name, CaseItemData__c, CreatedDate, Status__c, Case__r.CaseNumber, Case__r.Insurer__c,
             RoleGroup__c, CommunityPageURL__c, DueDate__c, Type__c, SubmittedBy__c, SubmittedByName__c,
             ExpiryDate__c
             From CaseItems__r),
            (Select Id, Name, FileName__c, Description__c, CreatedDate, SubmittedBy__c, 
             CategoryA__c, CategoryB__c, CategoryC__c, Author__c, AuthoredDate__c,
             ExternallyVisible__c, Case__c, CaseItem__c, S3Key__c
             From Attachments__r),
            /*(Select Id, Member.Id, Member.Name, TeamRole.Id, TeamRole.Name
From TeamMembers),*/
            (Select Id, WhatId, WhoId, CaseItem__c, Status, Description, Subject, ActivityDate, TaskTemplate__c
             From Tasks)
            From Case
            Where Id =: caseIds
            And IsClosed = true
            And CaseReasons__c !=: DRS_CaseService.CaseReasonDeletedDraft
            Order By CaseNumber ASC
        ];
    }
    
    ///Creates a new Merit Review Services Case with minimal set of details
    public static Case createMRSCase() {
        Case objCase = new Case(
            Subject = 'Application for merit review by SIRA',
            Status = DRS_CaseService.CaseStatusDraft,
            Origin = (DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId()) ? 'Post' : 'Web'),
            RecordTypeId = DRS_GlobalUtility.getRecordTypes().get(DRS_CaseService.CaseUnderscore + DRS_CaseService.RecordTypeMeritReviewService)
        );
        Insert objCase;
        return DRS_CaseService.getCaseDetails(objCase.Id);
    }
    
    ///Creates a new Case Item for MRS Applicant with minimal set of details
    public static CaseItem__c createWorkerCaseItem(String caseId) {
        CaseItem__c objCaseItem = new CaseItem__c(
            Case__c = caseId,
            Type__c = DRS_CaseService.WorkerCaseItemType,
            Status__c = DRS_CaseService.CaseItemStatusDraft,
            RoleGroup__c = DRS_AccountService.TypeWorkerWorkerRep + ';' + DRS_AccountService.TypeSolePractitioner,
            CommunityPageURL__c = DRS_CaseService.WorkerFormCommunityURL
        );
        Insert objCaseItem;
        return DRS_CaseService.getCaseItemDetails(objCaseItem.Id);
    }
    
    ///Gets Attachment__c details for the attachmentId
    public static Attachment__c getAttachmentDetails(String attachmentId) {
        return [
            Select Id, Name, FileName__c, Description__c, CreatedDate,
            CategoryA__c, CategoryB__c, CategoryC__c, Author__c, AuthoredDate__c,
            ExternallyVisible__c, Case__c, CaseItem__c, S3Key__c, UploadId__c
            From Attachment__c
            Where Id =: attachmentId];
    }
    
    ///Gets all Tasks for a list of Case Items
    public static List<Task> getTasksForCaseItems(List<Id> listCaseItemIds) {
        return [
            Select Id, Status
            From Task
            Where CaseItem__c IN: listCaseItemIds
        ];
    }
    
    ///Gets the first Task Template for a TypeName 
    /// (The TypeName should be unique for Task Templates, therefore only 1 should be present in the System)
    /// Initializes the DaysUntilDueDate__c with Default value if the value is not present.
    public static TaskTemplate__c getTaskTemplateForType(String typeName) {
        TaskTemplate__c objTaskTemplate = [
            Select Id, Type__c, CommunityPageURL__c, Subject__c, Description__c, DaysUntilDueDate__c, TaskStatus__c
            From TaskTemplate__c
            Where Type__c =: typeName
            Order By CreatedDate Desc
            Limit 1
        ];
        
        if(objTaskTemplate.DaysUntilDueDate__c == null) {
            objTaskTemplate.DaysUntilDueDate__c = DRS_CaseService.DefaulDaysUntilDueDate;
        }
        return objTaskTemplate;
    }
    
    ///Gets the details for provided Task Template Ids
    public static Map<Id,TaskTemplate__c> getTaskTemplatesForIds(Set<Id> setTaskTemplateIds) {
        return new Map<Id,TaskTemplate__c> ([
            Select Id, Type__c, CommunityPageURL__c, Subject__c, Description__c, DaysUntilDueDate__c, TaskStatus__c
            From TaskTemplate__c
            Where Id =: setTaskTemplateIds
        ]);
    }
    
    ///Returns a map of CaseTeamRole Names and Ids
    public static Map<String,Id> getCaseTeamRoles() {
        Map<String,Id> mapCaseTeamRoles = new Map<String,Id>();
        for(CaseTeamRole objCaseTeamRole : [Select Id, Name From CaseTeamRole]) {
            mapCaseTeamRoles.put(objCaseTeamRole.Name, objCaseTeamRole.Id);
        }
        return mapCaseTeamRoles;
    }
    
    ///Gets Case Item details for the caseItemId
    public static CaseItem__c getCaseItemDetails(String caseItemId) {
        return [
            Select Id, Name, CaseItemData__c, CreatedDate, Case__c, DueDate__c, Status__c,
            RoleGroup__c, CommunityPageURL__c, SubmittedBy__c, SubmittedByName__c,
            ExpiryDate__c, CreatedBy.Id,
            (Select Id, Name, FileName__c, Description__c, CreatedDate,
             CategoryA__c, CategoryB__c, CategoryC__c, Author__c, AuthoredDate__c,
             ExternallyVisible__c, Case__c, CaseItem__c, S3Key__c
             From Attachments__r)
            From CaseItem__c 
            Where Id =: caseItemId];
    }
    
    ///Gets the CaseTeamMembers for a Case
    public static List<CaseTeamMember> getCaseTeamMembers(String caseId) {
        return [
            Select Id, MemberId, TeamRoleId, TeamRole.Name, Member.Name, Member.Email, TeamRole.PreferencesVisibleInCSP
            From CaseTeamMember
            Where ParentId =: caseId];
    }
    
    ///Gets the open cases for a User. 
    ///The Cases for User are determined based on whether the User is a CaseTeamMember for that Case
    public static List<Case> getOpenCasesForUser(String userId) {
        Set<Id> setCaseIds = new Set<Id>();
        for(CaseTeamMember objCaseTeamMember : [Select ParentId From CaseTeamMember Where MemberId =: userId]) {
            setCaseIds.add(objCaseTeamMember.ParentId);
        }
        for(Case objCase : [Select Id From Case Where OwnerId =: userId]) {
            setCaseIds.add(objCase.Id);
        }
        User objUser = DRS_ContactService.getUserDetails(UserInfo.getUserId());
        if(String.isNotBlank(objUser.ContactId)) {
            for(Case objCase : [Select Id From Case Where ContactId =: objUser.ContactId]) {
                setCaseIds.add(objCase.Id);
            }
        }
        
        return DRS_CaseService.getCaseDetails(setCaseIds);
    }
    
    ///Gets the closed cases for a User. 
    ///The Cases for User are determined based on whether the User is a CaseTeamMember for that Case
    public static List<Case> getClosedCasesForUser(String userId) {
        Set<Id> setCaseIds = new Set<Id>();
        for(CaseTeamMember objCaseTeamMember : [Select ParentId From CaseTeamMember Where MemberId =: userId]) {
            setCaseIds.add(objCaseTeamMember.ParentId);
        }
        for(Case objCase : [Select Id From Case Where OwnerId =: userId]) {
            setCaseIds.add(objCase.Id);
        }
        User objUser = DRS_ContactService.getUserDetails(UserInfo.getUserId());
        if(String.isNotBlank(objUser.ContactId)) {
            for(Case objCase : [Select Id From Case Where ContactId =: objUser.ContactId]) {
                setCaseIds.add(objCase.Id);
            }
        }
        
        return DRS_CaseService.getClosedCaseDetails(setCaseIds);
    }
    
    ///Gets the Cases for Admin users
    ///	Uses the Contacts under the Admin user Account
    ///	Checks all the Cases for which the Contacts of Account are Case Team Members
    public static List<Case> getOpenCasesForAdminUser(String userId) {
        Contact objContact = DRS_ContactService.getContactForUser(UserInfo.getUserId());
        List<User> listUsers = DRS_ContactService.getUsersForAccount(objContact.AccountId);
        
        Set<Id> setCaseIds = new Set<Id>();
        for(CaseTeamMember objCaseTeamMember : [Select ParentId From CaseTeamMember Where MemberId =: listUsers]) {
            setCaseIds.add(objCaseTeamMember.ParentId);
        }
        
        return DRS_CaseService.getCaseDetails(setCaseIds);
    }
    
    ///Gets Annotations for a particular User
    public static List<DocumentAnnotation__c> getAnnotationsForUserAndLayer(String attachmentId, String userId, String layerRecordId) {
        return [
            Select Id, Attachment__c, User__c, LayerRecordId__c, AnnotationData__c, Username__c
            From DocumentAnnotation__c
            Where Attachment__c =: attachmentId
            And User__c =: userId
            For Update
        ];
    }
    
    ///Gets all Annotations for attachmentId
    public static List<DocumentAnnotation__c> getAnnotationsForAttachment(String attachmentId) {
        return [
            Select Id, Attachment__c, User__c, LayerRecordId__c, AnnotationData__c, Username__c
            From DocumentAnnotation__c
            Where Attachment__c =: attachmentId
        ];
    }
    
    ///Gets the permissions for a user on a particular record
    public static List<UserRecordAccess> getUserPermissionsForRecord(String userId, String recordId) {
        return [
            Select RecordId, HasEditAccess, HasReadAccess, MaxAccessLevel 
            From UserRecordAccess 
            Where UserId =: userId
            And RecordId =: recordId
        ];
    }
    
    ///Runs the automation for saving an insurer's Case Item to be resumed later   
    public static String saveInsurerCaseItem(String caseItemJson) {
        ///Variable declaration
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        CaseItem__c objInsurerCaseItem;
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON;
        Case objCase;
        
        try {
            ///Deserialize the incoming JSON structure to DRS_GlobalWrapper.CaseItemJSON
            objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            
            ///If the Case Item is not in Pending status, raise an error
            objInsurerCaseItem = DRS_CaseService.getCaseItemDetails(objCaseItemFormJSON.caseItemId);
            if(objInsurerCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending) {
                ///Update the Case
                objCase = new Case();
                objCase.Id = objCaseItemFormJSON.caseId;
                if(String.isNotBlank(objCaseItemFormJSON.workInReceipt) && objCaseItemFormJSON.workInReceipt == 'yes') {
                    objCase.ClaimType__c = 'BEFORE 01/10/12';
                }
                else {
                    objCase.ClaimType__c = 'ON OR AFTER 01/10/12';
                }
                objCase.IRLodged__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.supportingDocumentAttachedDate);
                objCase = DRS_GlobalUtility.updateCase(objCase);
                objCase = DRS_CaseService.getCaseDetails(objCase.Id);
                
                ///Update the inurer's Case Item
                objInsurerCaseItem.CaseItemData__c = JSON.serializePretty(JSON.deserializeUntyped(caseItemJson));
                Update objInsurerCaseItem;
                System.debug('---DRS_CaseService:saveInsurerCaseItem:objInsurerCaseItem:' + objInsurerCaseItem);
            }
            else{
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.CaseItemAlreadySubmitted));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'saveInsurerCaseItem');
        }
        return objCaseItemFormJSON.caseId;
    }
    
    ///Runs the automation for submission of an insurer's Case Item   
    public static String submitInsurerCaseItem(String caseItemJson) {
        ///Variable declaration
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        CaseItem__c objInsurerCaseItem;
        List<String> toAddresses;
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON;
        Configuration__c objMRSConfiguration;
        Case objCase;
        
        try {
            ///Initialize objects and collections
            objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
            
            ///Deserialize the incoming JSON structure to DRS_GlobalWrapper.CaseItemJSON
            objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            
            ///If the Case Item is not in Pending status, raise an error
            objInsurerCaseItem = DRS_CaseService.getCaseItemDetails(objCaseItemFormJSON.caseItemId);
            if(objInsurerCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending) {
                ///Update the Case
                objCase = new Case();
                objCase.Id = objCaseItemFormJSON.caseId;
                if(String.isNotBlank(objCaseItemFormJSON.workInReceipt) && objCaseItemFormJSON.workInReceipt == 'yes') {
                    objCase.ClaimType__c = 'BEFORE 01/10/12';
                }
                else {
                    objCase.ClaimType__c = 'ON OR AFTER 01/10/12';
                }
                objCase.IRLodged__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.supportingDocumentAttachedDate);
                objCase = DRS_GlobalUtility.updateCase(objCase);
                objCase = DRS_CaseService.getCaseDetails(objCase.Id);
                
                ///Update the inurer's Case Item
                objInsurerCaseItem.CaseItemData__c = JSON.serializePretty(JSON.deserializeUntyped(caseItemJson));
                objInsurerCaseItem.SubmittedBy__c = UserInfo.getUserId();
                objInsurerCaseItem.Status__c = DRS_CaseService.CaseItemStatusSubmitted;
                Update objInsurerCaseItem;
                System.debug('---DRS_CaseService:submitInsurerCaseItem:objInsurerCaseItem:' + objInsurerCaseItem);
                
                ///Send an email to all CaseTeamMembers informing them about insurer's submission
                DRS_CaseService.sendEmailsToAllCaseTeamMembers(DRS_CaseService.EmailInsurerCaseItemSubmitted, objCaseItemFormJSON.caseId, null);
            }
            else{
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.CaseItemAlreadySubmitted));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'saveInsurerCaseItem');
        }
        return objCaseItemFormJSON.caseId;
    }
    
    ///Creates Case Team Member for worker or worker rep
    ///Identifies the Case Contact and returns Case Contact Id 
    public static String saveWorkerCaseTeamMember(DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON) {
        ///Variable declaration
        Map<String,Id> mapCaseTeamRoles = DRS_CaseService.getCaseTeamRoles();
        List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
        List<DRS_GlobalWrapper.CaseTeamMemberJSON> listCaseTeamMemberJSONs = new List<DRS_GlobalWrapper.CaseTeamMemberJSON>();
        DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMemberJSON;
        List<Contact> listContactsForEmail;
        String caseContactId;
        
        ///Delete any existing CaseTeamMembers to ensure that Case Item is assigned to correct people at all times  
        listCaseTeamMembers = DRS_CaseService.getCaseTeamMembers(objCaseItemFormJSON.caseId);
        Delete listCaseTeamMembers;
        
        ///Initailize worker Case Team Member
        objCaseTeamMemberJSON = new DRS_GlobalWrapper.CaseTeamMemberJSON();
        objCaseTeamMemberJSON.memberId = UserInfo.getUserId();
        objCaseTeamMemberJSON.caseId = objCaseItemFormJSON.caseId;
        
        ///If the application was submitted on 'Behalf of a Worker'
        /// Check if the worker, who is mentioned on the case item, exists in the system
        /// If the worker exists, assign the worker as Case Contact, do not change any details of the existing Contact
        /// Otherwise create a new Contact and Account and assign the new Contact and Account to the Case
        ///If the application was submitted by the worker themselves
        /// Update the Contact details of the worker
        /// Add the worker as Case Contact
        if(!DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.behalfOfWorker) || DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId())) {
            objCaseTeamMemberJSON.roleId = mapCaseTeamRoles.get(DRS_CaseService.WorkerRepresentativeRoleName);
            
            if(String.isNotBlank(objCaseItemFormJSON.emailAddress)) {
            	listContactsForEmail = DRS_ContactService.getContactsWithEmail(objCaseItemFormJSON.emailAddress);
            }
            if(listContactsForEmail == null || listContactsForEmail.size() == 0) {
                caseContactId = DRS_ContactService.createCommunityContactAndAccount(
                    objCaseItemFormJSON.title,
                    objCaseItemFormJSON.givenName, 
                    objCaseItemFormJSON.surname, 
                    objCaseItemFormJSON.dob, 
                    objCaseItemFormJSON.contact, 
                    objCaseItemFormJSON.emailAddress, 
                    objCaseItemFormJSON.postal, 
                    objCaseItemFormJSON.suburb, 
                    objCaseItemFormJSON.state, 
                    objCaseItemFormJSON.postcode, 
                    DRS_ContactService.ContactRoleWorker,
                    null,
                    false,
                    null,
                    null,
                    null);
            }
            else {
                caseContactId = listContactsForEmail[0].Id;
            }
        }
        else {
            DRS_ContactService.updateProfile(
                objCaseItemFormJSON.title,
                objCaseItemFormJSON.givenName, objCaseItemFormJSON.surname, objCaseItemFormJSON.dob, objCaseItemFormJSON.contact, 
                objCaseItemFormJSON.postal, objCaseItemFormJSON.suburb, objCaseItemFormJSON.state, objCaseItemFormJSON.postcode, 
                (objCaseItemFormJSON.interpreter == 'yes' ? 'Yes' : 'No'), objCaseItemFormJSON.language, objCaseItemFormJSON.disabilities,
                objCaseItemFormJSON.emailAddress, null, UserInfo.getUserId(), null);
            
            caseContactId = DRS_ContactService.getContactForUser().Id;
            objCaseTeamMemberJSON.roleId = mapCaseTeamRoles.get(DRS_CaseService.WorkerRoleName);
        }
        System.debug('---DRS_CaseService:saveWorkerCaseTeamMember:objCaseTeamMemberJSON:' + objCaseTeamMemberJSON);
        
        listCaseTeamMemberJSONs.add(objCaseTeamMemberJSON);
        DRS_GlobalUtility.insertCaseTeamMembers(listCaseTeamMemberJSONs);
        
        return caseContactId;
    }
    
    ///Runs the automation for save/pause functionality of worker's Case Item
    public static String saveWorkerCaseItem(String caseItemJson) {
        ///Variable declaration
        Case objCase;
        Configuration__c objMRSConfiguration;
        DomainSite objWorkerDomainSite;
        DomainSite objInsurerDomainSite;
        User objCurrentUser;
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        List<String> toAddresses;
        CaseItem__c objWorkerCaseItem;
        String caseContactId;
        String caseItemLink;
        
        try{
            ///Deserialize the incoming JSON structure to DRS_GlobalWrapper.CaseItemJSON
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            
            ///Save worker Case Item
            ///Raise an error if the status is not Pending
            objWorkerCaseItem = DRS_CaseService.getCaseItemDetails(objCaseItemFormJSON.caseItemId);
            if(objWorkerCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending ||
               objWorkerCaseItem.Status__c == DRS_CaseService.CaseItemStatusDraft) {
                   ///Initialize variables
                   objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
                   objWorkerDomainSite = DRS_GlobalUtility.getDomainSiteForId(objMRSConfiguration.SiteId1__c);
                   objInsurerDomainSite = DRS_GlobalUtility.getDomainSiteForId(objMRSConfiguration.SiteId2__c);
                   
                   ///Create worker CaseTeamMember
                   caseContactId = DRS_CaseService.saveWorkerCaseTeamMember(objCaseItemFormJSON);
                   
                   ///Update the Case with details submitted in the Case Item
                   objCase = new Case(
                       Id = objCaseItemFormJSON.caseId,
                       ClaimNumber__c = objCaseItemFormJSON.claimNo,
                       Insurer__c = (objCaseItemFormJSON.insurer != null ? objCaseItemFormJSON.insurer.id : null),
                       ContactId = caseContactId,
                       DoNotPublish__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.dontPublish),
                       RepresentativeType__c = objCaseItemFormJSON.representationDetails,
                       DateOfInjury__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.dateOfInjury),
                       IRDecision__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.internalReviewDecisionDate),
                       WCDNoticeDate__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.workCapacityDecisionDate),
                       DateWorkerReceivedIR__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.supportingDocumentAttachedDate),
                       S43AWorkCapacity__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionCurrentWorkCapacity),
                       S43BSuitableEmployment__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionSuitableEmployment),
                       S43CAmountEarntInSE__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionAmountEarnInSuitableEmployment),
                       S43D1PIAWE__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionAmountPreInjury),
                       S43D2CurrentWeeklyEarnings__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionAmountPreInjury),
                       S43EUnableToEngageInCertainEmploy__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionResultUnableEngageInEmployment),
                       S43FAnyOtherWeeklyPaymentsDecision__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.otherInsurerAfferctsEntitlement)
                   );
                   if(String.isNotBlank(objCaseItemFormJSON.caseOrigin) && DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId())) {
                       objCase.Origin = objCaseItemFormJSON.caseOrigin;
                   }
                   objCase = DRS_GlobalUtility.updateCase(objCase);
                   
                   ///Update the Case Item
                   DateTime expiryDateTime = objWorkerCaseItem.CreatedDate.addDays(objMRSConfiguration.NumberOfDaysToExpire__c.intValue());
                   expiryDateTime = DateTime.newInstance(expiryDateTime.date(), Time.newInstance(23, 59, 59, 0));
                   
                   if(objInsurerDomainSite.PathPrefix == Site.getPathPrefix() 
                      && String.isNotBlank(objWorkerCaseItem.RoleGroup__c)
                      && !objWorkerCaseItem.RoleGroup__c.contains(DRS_CaseService.CaseItemRoleGroupLegalRep)) {
                           objWorkerCaseItem.RoleGroup__c += ';' + DRS_CaseService.CaseItemRoleGroupLegalRep;
                       }
                   objWorkerCaseItem.ExpiryDate__c = expiryDateTime;
                   objWorkerCaseItem.CaseItemData__c = JSON.serializePretty(JSON.deserializeUntyped(caseItemJson));
                   Update objWorkerCaseItem;
                   System.debug('---DRS_CaseService:saveWorkerCaseItem:objWorkerCaseItem:' + objWorkerCaseItem);
                   
                   /*if(objCaseItemFormJSON.isSavedForLater == true) {
                       ///Send an email to worker about the saved Application
                       objCurrentUser = DRS_ContactService.getUserDetails(UserInfo.getUserId());
                       caseItemLink = 'https://' + objWorkerDomainSite.Domain.Domain + objWorkerDomainSite.PathPrefix + '/form?recordId=' + objWorkerCaseItem.Id;
                       Map<String,String> mapMergeFieldValues;
                       mapMergeFieldValues = new Map<String,String>();
                       mapMergeFieldValues.put('{expiryDate}', expiryDateTime.format(DRS_GlobalUtility.DateFormat));
                       mapMergeFieldValues.put('{caseItemLink}', caseItemLink);
                       toAddresses = new List<String>();
                       toAddresses.add(objCurrentUser.Email);
                       Map<String,Map<String,String>> mapContactMergeFields = new Map<String,Map<String,String>>();
                       mapContactMergeFields.put(objCurrentUser.Email, DRS_ContactService.getContactMergeFields(DRS_ContactService.getContactObjectFromUser(objCurrentUser)));
                       
                       DRS_GlobalUtility.sendEmailUsingTemplate(DRS_CaseService.EmailWorkerApplicationSavedForLater, mapMergeFieldValues, toAddresses, mapContactMergeFields);
                   }*/
               }
            else{
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.CaseItemAlreadySubmitted));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'saveWorkerCaseItem');
        }
        return objCase.Id;
    }
    
    ///Runs the automation for submission of worker's Case Item
    public static String submitWorkerCaseItem(String caseItemJson) {
        ///Variable declaration
        Case objCase;
        CaseItem__c objAllocationCheckListCaseItem;
        CaseItem__c objJurisdictionCheckListCaseItem;
        TaskTemplate__c objTaskTemplateAllocation;
        TaskTemplate__c objTaskTemplateJurisdiction;
        List<String> toAddresses;
        Configuration__c objMRSConfiguration;
        CaseItem__c objWorkerCaseItem;
        String caseContactId;
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        
        try{
            ///Deserialize the incoming JSON structure to DRS_GlobalWrapper.CaseItemJSON
            DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            objTaskTemplateAllocation = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.AllocationChecklistTaskType);
            objTaskTemplateJurisdiction = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.JurisdictionChecklistTaskType);
            
            ///Save worker Case Item
            ///Raise an error if the status is not Pending
            objWorkerCaseItem = DRS_CaseService.getCaseItemDetails(objCaseItemFormJSON.caseItemId);
            if(objWorkerCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending ||
               objWorkerCaseItem.Status__c == DRS_CaseService.CaseItemStatusDraft) {
                   ///Initialize variables
                   objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
                   
                   ///Create worker CaseTeamMember
                   caseContactId = DRS_CaseService.saveWorkerCaseTeamMember(objCaseItemFormJSON);
                   
                   ///Update the Case with details submitted in the Case Item
                   objCase = new Case(
                       Id = objCaseItemFormJSON.caseId,
                       Status = DRS_CaseService.CaseStatusNew,
                       OwnerId = objMRSConfiguration.CaseOwner__c,
                       ClaimNumber__c = objCaseItemFormJSON.claimNo,
                       Insurer__c = objCaseItemFormJSON.insurer.id,
                       DateTimeCaseLodged__c = DateTime.now(),
                       ContactId = caseContactId,
                       DoNotPublish__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.dontPublish),
                       RepresentativeType__c = objCaseItemFormJSON.representationDetails,
                       DateOfInjury__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.dateOfInjury),
                       IRDecision__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.internalReviewDecisionDate),
                       WCDNoticeDate__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.workCapacityDecisionDate),
                       DateWorkerReceivedIR__c = DRS_GlobalUtility.getDateFromString(objCaseItemFormJSON.supportingDocumentAttachedDate),
                       S43AWorkCapacity__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionCurrentWorkCapacity),
                       S43BSuitableEmployment__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionSuitableEmployment),
                       S43CAmountEarntInSE__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionAmountEarnInSuitableEmployment),
                       S43D1PIAWE__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionAmountPreInjury),
                       S43D2CurrentWeeklyEarnings__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionAmountPreInjury),
                       S43EUnableToEngageInCertainEmploy__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.decisionResultUnableEngageInEmployment),
                       S43FAnyOtherWeeklyPaymentsDecision__c = DRS_GlobalUtility.getBooleanFromString(objCaseItemFormJSON.otherInsurerAfferctsEntitlement)
                   );
                   if(String.isNotBlank(objCaseItemFormJSON.caseOrigin) && DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId())) {
                       objCase.Origin = objCaseItemFormJSON.caseOrigin;
                   }
                   objCase = DRS_GlobalUtility.updateCase(objCase);
                   objCase = DRS_CaseService.getCaseDetails(objCase.Id);
                   System.debug('---DRS_CaseService:submitWorkerCaseItem:objCase:' + objCase);
                   
                   ///Update the Case Item with details submitted
                   objWorkerCaseItem.CaseItemData__c = JSON.serializePretty(JSON.deserializeUntyped(caseItemJson));
                   objWorkerCaseItem.Status__c = DRS_CaseService.CaseItemStatusSubmitted;
                   objWorkerCaseItem.SubmittedBy__c = UserInfo.getUserId();
                   objWorkerCaseItem.ExpiryDate__c = null;
                   objWorkerCaseItem.CommunityPageURL__c = DRS_CaseService.WorkerFormCommunityURL;
                   Update objWorkerCaseItem;
                   System.debug('---DRS_CaseService:submitWorkerCaseItem:objWorkerCaseItem:' + objWorkerCaseItem);
                   
                   ///Create Jurisdiction Checklist
                   objCaseItemFormJSON.q3b = objCaseItemFormJSON.notReviewDecisionDate;
                   objCaseItemFormJSON.insurer = new DRS_GlobalWrapper.InsurerJSON();
                   objCaseItemFormJSON.insurer.name = objCase.MRSInsurerAccount__c;
                   objCaseItemFormJSON.insurer.id = objCase.Insurer__c;
                   objJurisdictionCheckListCaseItem = new CaseItem__c(
                       Case__c = objCaseItemFormJSON.caseId,
                       Type__c = DRS_CaseService.JurisdictionChecklistTaskType,
                       Status__c = DRS_CaseService.CaseItemStatusPending,
                       RoleGroup__c = DRS_CaseService.CaseItemRoleGroupInternal,
                       CaseItemData__c = JSON.serializePretty(objCaseItemFormJSON),
                       CommunityPageURL__c = objTaskTemplateJurisdiction.CommunityPageURL__c,
                       DueDate__c = Date.Today().addDays(objTaskTemplateJurisdiction.DaysUntilDueDate__c.intValue())
                   );
                   Insert objJurisdictionCheckListCaseItem;
                   
                   ///Create Allocation Checklist
                   objAllocationCheckListCaseItem = new CaseItem__c(
                       Case__c = objCaseItemFormJSON.caseId,
                       Type__c = DRS_CaseService.AllocationChecklistTaskType,
                       Status__c = DRS_CaseService.CaseItemStatusPending,
                       RoleGroup__c = DRS_CaseService.CaseItemRoleGroupInternal,
                       CaseItemData__c = JSON.serializePretty(objCaseItemFormJSON),
                       CommunityPageURL__c = objTaskTemplateAllocation.CommunityPageURL__c,
                       DueDate__c = Date.Today().addDays(objTaskTemplateAllocation.DaysUntilDueDate__c.intValue())
                   );
                   Insert objAllocationCheckListCaseItem;
                   
                   ///Send an email to worker about the submission of Worker Case Item
                   if(String.isNotBlank(objCase.Contact.Email)) {
                       Map<String,String> mapMergeFieldValues;
                       mapMergeFieldValues = new Map<String,String>();
                       mapMergeFieldValues.put('{dateTimeStamp}', DateTime.now().format(DRS_GlobalUtility.DateTimeFormat));
                       mapMergeFieldValues.put('{CaseNumber}', objCase.CaseNumber);
                       toAddresses = new List<String>();
                       toAddresses.add(objCase.Contact.Email);
                       Map<String,Map<String,String>> mapContactMergeFields = new Map<String,Map<String,String>>();
                       mapContactMergeFields.put(objCase.Contact.Email, DRS_ContactService.getContactMergeFields(DRS_ContactService.getContactDetails(objCase.ContactId)));
                       DRS_GlobalUtility.sendEmailUsingTemplate(DRS_CaseService.EmailWorkerCaseItemSubmittedWorker, mapMergeFieldValues, toAddresses, mapContactMergeFields);
                   }
               }
            else{
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.CaseItemAlreadySubmitted));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'submitWorkerCaseItem');
        }
        return objCase.Id;
    }
    
    ///Runs the automation for Additional Information Case Item submission
    public static String saveAdditionalInformation(String additionalInformationJSON) {
        ///Varibale declaration
        Case objCase;
        CaseItem__c objCaseItem;
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        List<String> toAddresses;
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON;
        
        try{
            ///Deserialize the incoming JSON structure to DRS_GlobalWrapper.CaseItemJSON
            objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(additionalInformationJSON, DRS_GlobalWrapper.CaseItemJSON.class);
            
            ///Save the Additional Information
            /// Raise an exception if the Status is not Pending
            objCaseItem = DRS_CaseService.getCaseItemDetails(objCaseItemFormJSON.caseItemId);
            if(objCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending) {
                objCaseItem.CaseItemData__c = JSON.serializePretty(JSON.deserializeUntyped(additionalInformationJSON));
                objCaseItem.SubmittedBy__c = UserInfo.getUserId();
                objCaseItem.Status__c = DRS_CaseService.CaseItemStatusSubmitted;
                Update objCaseItem;
                
                ///Send email to all CaseTeamMembers for submission of the additional details
                Contact objContact = DRS_ContactService.getContactForUser();
                DRS_CaseService.sendEmailsToAllCaseTeamMembers(DRS_CaseService.EmailAdditionalInformationSubmitted, objCaseItemFormJSON.caseId, objContact.Id);
            }
            else {
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.CaseItemAlreadySubmitted));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'saveAdditionalInformation');
        }
        return objCaseItemFormJSON.caseId;
    }
    
    ///Updates the Task Status to Completed for the Case Items
    public static List<SObject> markCaseItemTasksAsCompleted(String oldMapString, String newMapString) {
        ///Variable declarations
        List<Id> listSubmittedCaseItemIds = new List<Id>();
        List<Task> listTasksToBeUpdated = new List<Task>();
        
        try {
            ///Deserialize the new and old maps
            Map<Id,CaseItem__c> oldMap = (Map<Id,CaseItem__c>)JSON.deserialize(oldMapString, Map<Id,CaseItem__c>.class);
            Map<Id,CaseItem__c> newMap = (Map<Id,CaseItem__c>)JSON.deserialize(newMapString, Map<Id,CaseItem__c>.class);
            
            ///Get map of record types
            Map<String,Id> mapRecordTypes = DRS_GlobalUtility.getRecordTypes();
            
            ///Identify the Case Items which have updated Status to Submitted 
            for(CaseItem__c objCaseItem : newMap.values()) {
                if((objCaseItem.RecordTypeId == mapRecordTypes.get(DRS_CaseService.CaseItemUnderscore + DRS_CaseService.RecordTypeCaseItem)) &&
                   (objCaseItem.Status__c == DRS_CaseService.CaseItemStatusSubmitted && oldMap.get(objCaseItem.Id).Status__c != objCaseItem.Status__c)) {
                       listSubmittedCaseItemIds.add(objCaseItem.Id);
                   }
            }
            
            ///Get the Tasks for the updated Case Items
            If(listSubmittedCaseItemIds.size() > 0) {
                List<Task> listCaseItemTasks = DRS_CaseService.getTasksForCaseItems(listSubmittedCaseItemIds);
                
                ///Update the Task Status to Completed
                for(Task objTask : listCaseItemTasks) {
                    if(objTask.Status != DRS_CaseService.CompletedTaskStatus) {
                        objTask.Status = DRS_CaseService.CompletedTaskStatus;
                        listTasksToBeUpdated.add(objTask);
                    }
                }
            }
            return listTasksToBeUpdated;
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'markCaseItemTasksAsCompleted');
        }
        return null;
    }
    
    public static void setupTasksWithTaskTemplateDetails(List<Task> listTasks) {
        Set<Id> setTaskTemplateIds = new Set<Id>();
        Map<Id,TaskTemplate__c> mapTaskTemplates;
        Decimal daysUntilDueDate = DRS_CaseService.DefaulDaysUntilDueDate;
        
        for(Task objTask : listTasks) {
            if(String.isNotBlank(objTask.TaskTemplate__c)) {
                setTaskTemplateIds.add(objTask.TaskTemplate__c);
            }
        }
        if(setTaskTemplateIds.size() > 0) {
            mapTaskTemplates = DRS_CaseService.getTaskTemplatesForIds(setTaskTemplateIds);
            for(Task objTask : listTasks) {
                if(String.isNotBlank(objTask.TaskTemplate__c)) {
                    objTask.Description = mapTaskTemplates.get(objTask.TaskTemplate__c).Description__c;
                    objTask.Subject = mapTaskTemplates.get(objTask.TaskTemplate__c).Subject__c;
                    if(objTask.ActivityDate == null) {
                        daysUntilDueDate = mapTaskTemplates.get(objTask.TaskTemplate__c).DaysUntilDueDate__c;
                        if(daysUntilDueDate == null) {
                            daysUntilDueDate = DRS_CaseService.DefaulDaysUntilDueDate;
                        }
                        if(String.isNotBlank(mapTaskTemplates.get(objTask.TaskTemplate__c).TaskStatus__c) &&
                        	objTask.Status != mapTaskTemplates.get(objTask.TaskTemplate__c).TaskStatus__c) {
                        	objTask.Status = mapTaskTemplates.get(objTask.TaskTemplate__c).TaskStatus__c;
                        }
                        objTask.ActivityDate = Date.Today().addDays(daysUntilDueDate.intValue());
                    }
                    objTask.Type = mapTaskTemplates.get(objTask.TaskTemplate__c).Type__c;
                }
            }
        }
    }
    
    ///Runs the automation for save of the Allocation Checklist
    public static void submitAllocationChecklist(String caseItemJSON) {
        ///Variable declarations
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON;
        CaseItem__c objAllocationCheckListCaseItem;
        List<String> toAddresses;
        Configuration__c objMRSConfiguration;
        Case objCase;
        
        try {
            ///Initialize variables
            objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
            
            ///Deserialize the incoming JSON structure to DRS_GlobalWrapper.CaseItemJSON
            objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemJson, DRS_GlobalWrapper.CaseItemJSON.class);
            
            ///Update the Allocation Checklist Case Item
            objAllocationCheckListCaseItem = DRS_CaseService.getCaseItemDetails(objCaseItemFormJSON.caseItemId);
            if(objAllocationCheckListCaseItem.Status__c == DRS_CaseService.CaseItemStatusPending) {
                objAllocationCheckListCaseItem.CaseItemData__c = JSON.serializePretty(JSON.deserializeUntyped(caseItemJson));
                objAllocationCheckListCaseItem.SubmittedBy__c = UserInfo.getUserId();
                Update objAllocationCheckListCaseItem;
                System.debug('---DRS_CaseService:submitAllocationChecklist:objAllocationCheckListCaseItem:' + objAllocationCheckListCaseItem);
            }
            else{
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.CaseItemAlreadySubmitted));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'submitAllocationChecklist'); 
        }
    }
    
    ///Create Case Team Members using the JSON from the form
    public static void saveCaseTeamMembers(String caseId, String caseTeamMemberJSONs) {
        ///The implementation is moved to DRS_GlobalUtility to run this part Without Sharing
        ///This is required because Community User do not have access to Case Team Roles
        DRS_GlobalUtility.saveCaseTeamMembers(caseId, caseTeamMemberJSONs);
    }
    
    ///Sends emails to all Case Team Members based on the Email Template and other variables
    public static void sendEmailsToAllCaseTeamMembers(String emailTemplate, String caseId, String contactId) {
        ///Initialize variables
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        DomainSite objWorkerDomainSite = DRS_GlobalUtility.getDomainSiteForId(objMRSConfiguration.SiteId1__c);
        DomainSite objInsurerDomainSite = DRS_GlobalUtility.getDomainSiteForId(objMRSConfiguration.SiteId2__c);
        String caseLink = '';
        List<String> toAddresses;
        Map<String,String> mapMergeFieldValues;
        List<CaseTeamMember> listCaseTeamMembers;
        Map<Id,User> mapUsers = new Map<Id,User>();
        List<Id> listUserIds = new List<Id>();
        Map<String,Map<String,String>> mapContactMergeFields = new Map<String,Map<String,String>>();
        
        Map<Id,Contact> mapContacts = new Map<Id,Contact>();
        List<Id> listContactIds = new List<Id>();
        String roleName;
        
        Set<Id> setCaseTeamMembersWithEmailSent = new Set<Id>();
        
        ///Get Case and Case Team Member details
        Case objCase = DRS_CaseService.getCaseDetails(caseId);
        listCaseTeamMembers = DRS_CaseService.getCaseTeamMembers(caseId);
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(((String)objCaseTeamMember.MemberId).subString(0,3) == '005') {
                if(UserInfo.getUserId() == objCaseTeamMember.MemberId) {
                    roleName = objCaseTeamMember.TeamRole.Name;
                }
                listUserIds.add(objCaseTeamMember.MemberId);
            }
        }
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(((String)objCaseTeamMember.MemberId).subString(0,3) == '003') {
                if(UserInfo.getUserId() == objCaseTeamMember.MemberId) {
                    roleName = objCaseTeamMember.TeamRole.Name;
                }
                listContactIds.add(objCaseTeamMember.MemberId);
            }
        }
        
        ///Get User details for the Case Team Members
        for(User objUser : DRS_ContactService.getUserContactsForUsers(listUserIds)) {
            mapUsers.put(objUser.Id, objUser);
        }
        for(Contact objContact : DRS_ContactService.getContactsForIds(listContactIds)) {
            mapContacts.put(objContact.Id, objContact);
        }
        
        ///Initialize the merge fields
        mapMergeFieldValues = new Map<String,String>();
        mapMergeFieldValues.put('{CaseNumber}', objCase.CaseNumber);
        mapMergeFieldValues.put('{dateTimeStamp}', DateTime.now().format(DRS_GlobalUtility.DateTimeFormat));
        if(String.isNotBlank(contactId)) {
            Contact objContact = DRS_ContactService.getContactDetails(contactId);
            mapMergeFieldValues.put('{submitterName}', objContact.Name);
            if(String.isNotBlank(roleName)) {
                mapMergeFieldValues.put('{roleName}', roleName);
            }
            else {
                mapMergeFieldValues.put('{roleName}', objContact.Role__c);
            }
        }
        
        ///Send emails to insurer Case Team Members
        caseLink = 'https://' + objInsurerDomainSite.Domain.Domain + objInsurerDomainSite.PathPrefix + '/casedetail?recordId=' + objCase.Id;
        mapMergeFieldValues.put('{CaseLink}', caseLink);
        toAddresses = new List<String>();
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(mapUsers.containsKey(objCaseTeamMember.MemberId) 
               && (mapUsers.get(objCaseTeamMember.MemberId).Contact.Account.Type == DRS_AccountService.TypeInsurer ||
                   mapUsers.get(objCaseTeamMember.MemberId).Contact.Account.Type == DRS_AccountService.TypeLegalFirm)
               && String.isNotBlank(mapUsers.get(objCaseTeamMember.MemberId).Contact.Email)) {
                   toAddresses.add(mapUsers.get(objCaseTeamMember.MemberId).Contact.Email);
                   mapContactMergeFields.put(mapUsers.get(objCaseTeamMember.MemberId).Contact.Email, DRS_ContactService.getContactMergeFields(DRS_ContactService.getContactObjectFromUser(mapUsers.get(objCaseTeamMember.MemberId))));
                   setCaseTeamMembersWithEmailSent.add(objCaseTeamMember.MemberId);
               }
            else if(mapContacts.containsKey(objCaseTeamMember.MemberId)
                    && (mapContacts.get(objCaseTeamMember.MemberId).Account.Type == DRS_AccountService.TypeInsurer ||
                        mapContacts.get(objCaseTeamMember.MemberId).Account.Type == DRS_AccountService.TypeLegalFirm)
                    && String.isNotBlank(mapContacts.get(objCaseTeamMember.MemberId).Email)) {
                        toAddresses.add(mapContacts.get(objCaseTeamMember.MemberId).Email);
                        mapContactMergeFields.put(mapContacts.get(objCaseTeamMember.MemberId).Email, DRS_ContactService.getContactMergeFields(mapContacts.get(objCaseTeamMember.MemberId)));
                        setCaseTeamMembersWithEmailSent.add(objCaseTeamMember.MemberId);
                    }
        }
        if(toAddresses.size() > 0) {
            DRS_GlobalUtility.sendEmailUsingTemplate(emailTemplate, mapMergeFieldValues, toAddresses, mapContactMergeFields);
        }
        
        ///Send emails to worker Case Team Members
        caseLink = 'https://' + objWorkerDomainSite.Domain.Domain + objWorkerDomainSite.PathPrefix + '/casedetail?recordId=' + objCase.Id;
        mapMergeFieldValues.put('{CaseLink}', caseLink);
        toAddresses = new List<String>();
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(mapUsers.containsKey(objCaseTeamMember.MemberId) 
               && (mapUsers.get(objCaseTeamMember.MemberId).Contact.Account.Type == DRS_AccountService.TypeWorkerWorkerRep ||
                   mapUsers.get(objCaseTeamMember.MemberId).Contact.Account.Type == DRS_AccountService.TypeSolePractitioner)
               && String.isNotBlank(mapUsers.get(objCaseTeamMember.MemberId).Contact.Email)) {
                   toAddresses.add(mapUsers.get(objCaseTeamMember.MemberId).Contact.Email);
                   mapContactMergeFields.put(mapUsers.get(objCaseTeamMember.MemberId).Contact.Email, DRS_ContactService.getContactMergeFields(DRS_ContactService.getContactObjectFromUser(mapUsers.get(objCaseTeamMember.MemberId))));
                   setCaseTeamMembersWithEmailSent.add(objCaseTeamMember.MemberId);
               }
            else if(mapContacts.containsKey(objCaseTeamMember.MemberId) 
                    && (mapContacts.get(objCaseTeamMember.MemberId).Account.Type == DRS_AccountService.TypeWorkerWorkerRep ||
                        mapContacts.get(objCaseTeamMember.MemberId).Account.Type == DRS_AccountService.TypeSolePractitioner)
                    && String.isNotBlank(mapContacts.get(objCaseTeamMember.MemberId).Email)) {
                        toAddresses.add(mapContacts.get(objCaseTeamMember.MemberId).Email);
                        mapContactMergeFields.put(mapContacts.get(objCaseTeamMember.MemberId).Email, DRS_ContactService.getContactMergeFields(mapContacts.get(objCaseTeamMember.MemberId)));
                        setCaseTeamMembersWithEmailSent.add(objCaseTeamMember.MemberId);
                    }
        }
        if(toAddresses.size() > 0) {
            DRS_GlobalUtility.sendEmailUsingTemplate(emailTemplate, mapMergeFieldValues, toAddresses, mapContactMergeFields);
        }
        
        ///Send emails to internal staff Case Team Members
        caseLink = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + objCase.Id;
        mapMergeFieldValues.put('{CaseLink}', caseLink);
        toAddresses = new List<String>();
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(!setCaseTeamMembersWithEmailSent.contains(objCaseTeamMember.MemberId)) {
                if(String.isNotBlank(objCaseTeamMember.Member.Email)) {
                	mapContactMergeFields.put(objCaseTeamMember.Member.Email, DRS_ContactService.getContactMergeFields(DRS_ContactService.getContactObjectFromUser(mapUsers.get(objCaseTeamMember.MemberId))));
                    toAddresses.add(objCaseTeamMember.Member.Email);
                }
            }
        }
        if(toAddresses.size() > 0) {
            DRS_GlobalUtility.sendEmailUsingTemplate(emailTemplate, mapMergeFieldValues, toAddresses, mapContactMergeFields);
        }
    }
    
    ///Adds triage users as Case Team Members to the Case.
    ///Sends emails to the Triage users 
    public static void addTriageUsersToCase(String caseId) {
        ///Initialize variables
        CaseTeamMember objCaseTeamMember;
        List<CaseTeamMember> listCaseTeamMembers = new List<CaseTeamMember>();
        Map<String,String> mapMergeFieldValues;
        List<String> toAddresses;
        Map<String,Id> mapCaseTeamRoles = DRS_CaseService.getCaseTeamRoles();
        Case objCase = DRS_CaseService.getCaseDetails(caseId);
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        DomainSite objInsurerDomainSite = DRS_GlobalUtility.getDomainSiteForId(objMRSConfiguration.SiteId2__c);
        TaskTemplate__c objTaskTemplate = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.InsurerReplyTaskType);
        Map<String,Map<String,String>> mapContactMergeFields = new Map<String,Map<String,String>>();
        
        ///Get the list of traige users for the Account
        List<User> listTriageUsers = DRS_ContactService.getTriageUsersForAccount(objCase.Insurer__c);
        if(listTriageUsers == null || listTriageUsers.size() == 0) {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.InsurerTriageUsersNotFound));
        }
        
        ///Add the triage users as the Case Team Members
        for(User objTriageUser : listTriageUsers) {
            objCaseTeamMember = new CaseTeamMember();
            objCaseTeamMember.MemberId = objTriageUser.Id;
            objCaseTeamMember.ParentId = caseId;
            objCaseTeamMember.TeamRoleId = mapCaseTeamRoles.get(DRS_CaseService.InsurerTriageRoleName);
            System.debug('---DRS_CaseService:addTriageUsersToCase:objCaseTeamMember:' + objCaseTeamMember);
            listCaseTeamMembers.add(objCaseTeamMember);
        }
        if(listCaseTeamMembers.size() > 0) {
            Insert listCaseTeamMembers;
        }
        
        ///Send emails to triage users for being added to the Case Team
        toAddresses = new List<String>();
        String caseLink = 'https://' + objInsurerDomainSite.Domain.Domain + objInsurerDomainSite.PathPrefix + '/casedetail?recordId=' + objCase.Id;
        mapMergeFieldValues = new Map<String,String>();
        mapMergeFieldValues.put('{dateTimeStamp}', DateTime.now().format(DRS_GlobalUtility.DateTimeFormat));
        mapMergeFieldValues.put('{CaseNumber}', objCase.CaseNumber);
        mapMergeFieldValues.put('{workerContact}', objCase.Contact.Name);
        mapMergeFieldValues.put('{dueDate}', DRS_GlobalUtility.convertDateToString(Date.Today().addDays(objTaskTemplate.DaysUntilDueDate__c.intValue())));
        mapMergeFieldValues.put('{CaseLink}', caseLink);
        
        for(User objUser : listTriageUsers) {
            toAddresses.add(objUser.Email);
            mapContactMergeFields.put(objUser.Email, DRS_ContactService.getContactMergeFields(DRS_ContactService.getContactObjectFromUser(objUser)));
        }
        DRS_GlobalUtility.sendEmailUsingTemplate(DRS_CaseService.EmailWorkerCaseItemSubmitted, mapMergeFieldValues, toAddresses, mapContactMergeFields);
    }
    
    public static String addAttachment(String attachmentJSON) {
        try {
            Boolean isInternalUser = DRS_ContactService.isSalesforceInternalUser(UserInfo.getUserId());
            DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
            Attachment__c objAttachment = new Attachment__c();
            objAttachment.Case__c = objAttachmentJSON.caseId;
            objAttachment.FileName__c = objAttachmentJSON.name;
            objAttachment.Description__c = objAttachmentJSON.description;
            objAttachment.CategoryA__c = objAttachmentJSON.category;
            objAttachment.CategoryB__c = objAttachmentJSON.tier2;
            objAttachment.CategoryC__c = objAttachmentJSON.tier3;
            objAttachment.Author__c = objAttachmentJSON.author;
            objAttachment.AuthoredDate__c = DRS_GlobalUtility.getDateFromString(objAttachmentJSON.dateOfDocument);
            objAttachment.DateDecisionSent__c = DRS_GlobalUtility.getDateFromString(objAttachmentJSON.decisionSentDate);
            objAttachment.InternalAuthor__c = (String.isNotBlank(objAttachmentJSON.internalAuthor) ? objAttachmentJSON.internalAuthor : null);
            objAttachment.InternalReviewer__c = (String.isNotBlank(objAttachmentJSON.internalReviewer) ? objAttachmentJSON.internalReviewer : null);
            objAttachment.CorrespondenceDateFrom__c = DRS_GlobalUtility.getDateFromString(objAttachmentJSON.fromDateCorrespondance);
            objAttachment.CorrespondenceDateTo__c = DRS_GlobalUtility.getDateFromString(objAttachmentJSON.toDateCorrespondance);
            objAttachment.ExternallyVisible__c = (isInternalUser == true ? objAttachmentJSON.externallyVisible : true);
            objAttachment.CaseItem__c = (String.isNotBlank(objAttachmentJSON.caseItemId) ? objAttachmentJSON.caseItemId : null);
            Insert objAttachment;
            return objAttachment.Id;
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleServiceException(excep, 'DRS_Case_CC', 'addAttachment');
        }
    }
    
    public static void removeAttachment(String attachmentId) {
        try {
            System.debug('---DRS_CaseService:removeAttachment:attachmentId:' + attachmentId);
            Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(attachmentId);
            System.debug('---DRS_CaseService:removeAttachment:objAttachment:' + JSON.serializePretty(objAttachment));
            
            DRS_CaseService.checkAuthorizedUser(UserInfo.getUserId(), objAttachment.Case__c);
            System.debug('---DRS_CaseService:removeAttachment:authorized');
            
            String signedURL = DRS_S3Service.getSignedDeleteUrl(objAttachment.S3Key__c);
            System.debug('---DRS_CaseService:removeAttachment:signedURL:' + signedURL);
            
            HttpResponse objHttpResponse = DRS_GlobalUtility.callRESTAPI(DRS_GlobalUtility.RESTDeleteMethod, signedURL, null, null);
            System.debug('---DRS_CaseService:removeAttachment:objHttpResponse:' + objHttpResponse);
            
            if(objHttpResponse.getStatusCode() == 204) {
                Delete objAttachment;
            }
            else {
                Insert DRS_GlobalUtility.getAppliationLogError(
                    objHttpResponse.getBody(), DRS_GlobalUtility.RESTDeleteMethod + ' ' + signedURL, String.valueOf(objHttpResponse.getStatusCode()), objAttachment.Id, 'Delete attachment', 'DRS_CaseService', 'removeAttachment', '');
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'removeAttachment');
        }
    }
    
    public static Boolean isUserAllowedToSeeAttachment(String userId, String attachmentId) {
        for(UserRecordAccess objUserRecordAccess : DRS_CaseService.getUserPermissionsForRecord(userId, attachmentId)) {
            if(objUserRecordAccess.HasReadAccess == true) {
                return true;
            }
        }
        return false;
    }
    
    public static List<DocumentAnnotation__c> getAnnotations(String userId, String attachmentId) {
        List<DocumentAnnotation__c> listAnnotations = new List<DocumentAnnotation__c>();
        if(DRS_ContactService.isSalesforceInternalUser(userId)) {
            listAnnotations = DRS_CaseService.getAnnotationsForAttachment(attachmentId);
        }
        else {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
        }
        return listAnnotations;
    }
    
    public static String saveAnnotations(String userId, String attachmentId, String content, String layerRecordId) {
        try{
            if(DRS_ContactService.isSalesforceInternalUser(userId)) {
                List<DocumentAnnotation__c> listAnnotations = DRS_CaseService.getAnnotationsForUserAndLayer(attachmentId, userId, layerRecordId);
                Delete listAnnotations;
                DocumentAnnotation__c objDocumentAnnotation = new DocumentAnnotation__c();
                objDocumentAnnotation.AnnotationData__c = JSON.serialize(content);
                objDocumentAnnotation.User__c = userId;
                objDocumentAnnotation.Attachment__c = attachmentId;
                objDocumentAnnotation.LayerRecordId__c = layerRecordId;
                Insert objDocumentAnnotation;
            }
            else {
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'saveAnnotations');
        }
        return '';
    }
    
    ///Checks the permission of the User against the Case object
    public static void checkAuthorizedUser(String userId, String caseId) {
        Boolean isAuthorized = false;
        
        /*for(UserRecordAccess objUserRecordAccess : DRS_CaseService.getUserPermissionsForRecord(userId, caseId)) {
if(objUserRecordAccess.HasReadAccess == true) {
isAuthorized = true;
}
}*/
        Case objCase = DRS_CaseService.getCaseDetails(caseId);
        List<Case> listCases = DRS_CaseService.getOpenCasesForUser(userId);
        Boolean isInternal = false;
        if(DRS_ContactService.isSalesforceInternalUser(userId)) {
            isAuthorized = true;
            isInternal = true;
        }
        else if(objCase != null && String.isNotBlank(objCase.ContactId)) {
            if(objCase.ContactId == DRS_ContactService.getContactForUser(userId).Id) {
                isAuthorized = true;
            }
        }
        if(!isAuthorized && objCase != null && objCase.TeamMembers != null) {
            for(CaseTeamMember objCaseTeamMember : objCase.TeamMembers) {
                if(objCaseTeamMember.MemberId == userId) {
                    isAuthorized = true;
                    break;
                }
            }
        }
        
        if(!isAuthorized) {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
        }
    }
    
    public static List<SObject> updateCaseTopicAssignment(String oldMapString, String newMapString) {
        ///Variable declarations
        List<Id> listSubmittedCaseItemIds = new List<Id>();
        List<Task> listTasksToBeUpdated = new List<Task>();
        Set<Id> setCasesAffected = new Set<Id>();
        Set<Id> setCasesHavingOtherTopic = new Set<Id>();
        List<Case> listCasesToBeUpdated = new List<Case>();
        Map<Id,TopicAssignment> oldMap;
        Map<Id,TopicAssignment> newMap;
        
        try {
            System.debug('---DRS_CaseService:updateCaseTopicAssignment:oldMapString:' + oldMapString);
            System.debug('---DRS_CaseService:updateCaseTopicAssignment:newMapString:' + newMapString);
            
            ///If the Topic was deleted
            //	Check whether the Topic was deleted from Case
            //	Check wheter the Case has other Topics
            //		If yes, do not do anything
            //		If no, mark the TopicFlag__c on Case as false
            if(string.isNotBlank(oldMapString)) {
                ///Deserialize the old map
                oldMap = (Map<Id,TopicAssignment>)JSON.deserialize(oldMapString, Map<Id,TopicAssignment>.class);
                
                System.debug('---DRS_CaseService:updateCaseTopicAssignment:oldMap is not null, means delete scenario');
                ///Get the Cases from deleted TopicsAssignments
                for(TopicAssignment objTopicAssignment : oldMap.values()) {
                    if(((String)objTopicAssignment.EntityId).startsWith('500')) {
                        setCasesAffected.add(objTopicAssignment.EntityId);
                    }
                }
                
                ///Get the Cases for which other Topics exist
                for(TopicAssignment objTopicAssignment : [
                    Select Id, EntityId
                    From TopicAssignment
                    Where EntityId =: setCasesAffected
                ]) {
                    setCasesHavingOtherTopic.add(objTopicAssignment.EntityId);
                }
                
                ///Remove the Cases with Topics from the list of Cases for unflagging
                setCasesAffected.removeAll(setCasesHavingOtherTopic);
                
                ///Mark Cases with TopicFlag = false
                for(Case objCase : [
                    Select Id, TopicFlag__c
                    From Case
                    Where Id =: setCasesAffected
                    And TopicFlag__c = true
                ]) {
                    objCase.TopicFlag__c = false;
                    listCasesToBeUpdated.add(objCase);
                }
            }
            ///If the Topic was inserted
            //	Check wheter the Case has other Topics
            //		If yes, do not do anything
            //		If no, mark the TopicFlag__c on Case as true
            else if(string.isNotBlank(newMapString)) {
                System.debug('---DRS_CaseService:updateCaseTopicAssignment:newMap is not null, means insert scenario');
                
                ///Deserialize the new map
                newMap = (Map<Id,TopicAssignment>)JSON.deserialize(newMapString, Map<Id,TopicAssignment>.class);
                
                ///Get the Cases from inserted TopicsAssignments
                for(TopicAssignment objTopicAssignment : newMap.values()) {
                    if(((String)objTopicAssignment.EntityId).startsWith('500')) {
                        setCasesAffected.add(objTopicAssignment.EntityId);
                    }
                }
                
                ///Mark Cases with TopicFlag = true
                for(Case objCase : [
                    Select Id, TopicFlag__c
                    From Case
                    Where Id =: setCasesAffected
                    And TopicFlag__c = false
                ]) {
                    objCase.TopicFlag__c = true;
                    listCasesToBeUpdated.add(objCase);
                }
            }
            return listCasesToBeUpdated;
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'markCaseItemTasksAsCompleted');
        }
        return null;
    }
    
    public static void deleteDraftCase(String caseId) {
        DRS_DeleteExpired_Batch objDeleteBatch = new DRS_DeleteExpired_Batch();
        Case objCase = DRS_CaseService.getCaseDetails(caseId);
        objDeleteBatch.execute(null, new List<Case>{objCase});
    }
    
    /*
public static void completeMultipartUpload(String attachmentJSON) {
try {
DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(objAttachmentJSON.attachmentId);
String signedUrl = DRS_S3Service.getMultipartCompleteUrl(objAttachment.S3Key__c, objAttachment.UploadId__c);
String xmlBody = '<CompleteMultipartUpload>';

objAttachmentJSON.parts.sort();
for(DRS_GlobalWrapper.PartJSON objPartJSON : objAttachmentJSON.parts) {
xmlBody += '<Part><PartNumber>' + objPartJSON.partNumber + '</PartNumber><ETag>' + objPartJSON.eTag + '</ETag></Part>';
}
xmlBody += '</CompleteMultipartUpload>';

System.debug('---DRS_CaseService:completeMultipartUpload:xmlBody:' + xmlBody);

HttpResponse objHttpResponse = DRS_GlobalUtility.callRESTAPI(DRS_GlobalUtility.RESTPostMethod, signedURL, xmlBody, null);
if(objHttpResponse.getStatusCode() == 200) {
objAttachment.UploadId__c = '';
Update objAttachment;
}
else {
throw new DRS_GlobalException.ValidationException();
}
}
catch(Exception excep) {
DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'completeMultipartUpload');
}
}

public static void abortMultipartUpload(String attachmentId) {
try {
Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(attachmentId);
String signedUrl = DRS_S3Service.getMultipartAbortUrl(objAttachment.S3Key__c, objAttachment.UploadId__c);

HttpResponse objHttpResponse = DRS_GlobalUtility.callRESTAPI(DRS_GlobalUtility.RESTDeleteMethod, signedURL, null, null);
if(objHttpResponse.getStatusCode() == 204) {
Delete objAttachment;
}
}
catch(Exception excep) {
DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'abortMultipartUpload');
}
}*/
    
    public static void executeInsurerCaseItemAutomation(String caseId) {
        Case objCase;
        CaseItem__c objWorkerCaseItem;
        CaseItem__c objInsurerReplyCaseItem;
        Task objInsurerReplyTask;
        TaskTemplate__c objTaskTemplate;
        Configuration__c objMRSConfiguration;
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        
        System.debug('---DRS_CaseService:executeInsurerCaseItemAutomation:caseId:' + caseId);
        
        try {
            ///Initialize variables
            objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
            objTaskTemplate = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.InsurerReplyTaskType);
            objCase = DRS_CaseService.getCaseDetails(caseId);
            
            for(CaseItem__c objCaseItem : objCase.CaseItems__r) {
                if(objCaseItem.Type__c == DRS_CaseService.WorkerCaseItemType) {
                    objWorkerCaseItem = objCaseItem;
                }
            }
            
            if(objWorkerCaseItem != null && objWorkerCaseItem.Status__c == DRS_CaseService.CaseItemStatusSubmitted) {
                ///Create an insurer's reply Case Item
                objInsurerReplyCaseItem = new CaseItem__c(
                    Case__c = objCase.Id,
                    Type__c = DRS_CaseService.InsurerReplyTaskType,
                    Status__c = DRS_CaseService.CaseItemStatusPending,
                    RoleGroup__c = DRS_AccountService.TypeInsurer + ';' + DRS_AccountService.TypeLegalFirm,
                    CaseItemData__c = objWorkerCaseItem.CaseItemData__c,
                    CommunityPageURL__c = objTaskTemplate.CommunityPageURL__c,
                    DueDate__c = Date.Today().addDays(objTaskTemplate.DaysUntilDueDate__c.intValue())
                );
                Insert objInsurerReplyCaseItem;
                System.debug('---DRS_CaseService:executeInsurerCaseItemAutomation:objInsurerReplyCaseItem:' + objInsurerReplyCaseItem);
                
                ///Create an insurer's reply Case Item Task
                objInsurerReplyTask = new Task();
                objInsurerReplyTask.OwnerId = objMRSConfiguration.DefaultTaskOwner__c;
                objInsurerReplyTask.Status = DRS_CaseService.InitialTaskStatus;
                objInsurerReplyTask.Description = objTaskTemplate.Description__c;
                objInsurerReplyTask.WhatId = objCase.Id;
                objInsurerReplyTask.Subject = objTaskTemplate.Subject__c;
                objInsurerReplyTask.ActivityDate = Date.Today().addDays(objTaskTemplate.DaysUntilDueDate__c.intValue());
                objInsurerReplyTask.CaseItem__c = objInsurerReplyCaseItem.Id;
                objInsurerReplyTask.Type = DRS_CaseService.InsurerReplyTaskType;
                objInsurerReplyTask.TaskTemplate__c = objTaskTemplate.Id;
                objInsurerReplyTask.IsReminderSet  = true;
                objInsurerReplyTask.ReminderDateTime = objInsurerReplyTask.ActivityDate;
                objInsurerReplyTask.IsVisibleInSelfService = true;
                if(String.isNotBlank(objTaskTemplate.TaskStatus__c)) {
					objInsurerReplyTask.Status = objTaskTemplate.TaskStatus__c;                	
                }
                Insert objInsurerReplyTask;
                System.debug('---DRS_CaseService:executeInsurerCaseItemAutomation:objInsurerReplyTask:' + objInsurerReplyTask);
                
                ///Add triage users to the Case
                DRS_CaseService.addTriageUsersToCase(objCase.Id);
            }
            else {
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.WorkerCaseItemNotYetSubmitted));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_Case_CC', 'executeInsurerCaseItemAutomation');
        }
    }
    
    /*private static void sendReminderEmailsToWorkers(String caseId, String caseItemId, String emailTemplateName) {
        try {
            CaseItem__c objCaseItem = DRS_CaseService.getCaseItemDetails(caseItemId);
            if(objCaseItem != null) {
                List<String> toAddresses = new List<String>();
                User objUser = DRS_ContactService.getUserDetails(objCaseItem.CreatedBy.Id);
                toAddresses.add(objUser.Email);
                DRS_GlobalUtility.sendEmailUsingTemplate(emailTemplateName, new Map<String,String>(), toAddresses);
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_Case_CC', 'sendReminderEmailsToWorkers');
        }
    }*/
    
    ///A class to provide a structure for the method parameters when method is called from a Process Builder
    public class DRS_CaseServiceInvocable {
        @InvocableVariable(label='Case Id' description='Case Id' required=true)
        public String caseId;
        
        @InvocableVariable(label='Method Type' description='MRSWorkerCaseItemFirstReminder OR MRSWorkerCaseItemSecondReminder OR MRSInsurerCaseItemAutomation' required=true)
        public String methodType;
        
        @InvocableVariable(label='Email Template Name' description='The API Name of the email template')
        public String emailTemplateName;
        
        @InvocableVariable(label='Case Item Id' description='Case Item Id')
        public String caseItemId;
    }
    
    ///The method will be invoked from Process Builder
    @InvocableMethod(label='Invoke Case Service Automation' description='Invokes automations for Case Service based on the MethodType of DRS_CaseServiceInvocable')
    public static void invokeDRS_CaseServiceAutomation(List<DRS_CaseServiceInvocable> listDRS_CaseServiceInvocable) {
        for(DRS_CaseServiceInvocable objDRS_CaseServiceInvocable : listDRS_CaseServiceInvocable) {
            /*if(objDRS_CaseServiceInvocable.methodType == 'MRSWorkerCaseItemFirstReminder' || 
               objDRS_CaseServiceInvocable.methodType == 'MRSWorkerCaseItemSecondReminder') 
            {
                if(listDRS_CaseServiceInvocable.size() > 1) {
                    throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.InvalidParametersForDRS_CaseServiceAutomation));
                }
                DRS_CaseService.sendReminderEmailsToWorkers(objDRS_CaseServiceInvocable.caseId, objDRS_CaseServiceInvocable.caseItemId, objDRS_CaseServiceInvocable.emailTemplateName);
            }
            else */if(objDRS_CaseServiceInvocable.methodType == 'MRSInsurerCaseItemAutomation') {
                if(listDRS_CaseServiceInvocable.size() > 1) {
                    throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.InvalidParametersForDRS_CaseServiceAutomation));
                }
                DRS_CaseService.executeInsurerCaseItemAutomation(objDRS_CaseServiceInvocable.caseId);
            }
        }
    }
}