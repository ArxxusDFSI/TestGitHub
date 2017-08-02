@IsTest
public class DRS_CaseItemForm_CC_Test {
    @TestSetup
    private static void initializeData(){
        DRS_SetupData.processData();
        DRS_TestData.createSnippets();
    }
    
    private static testmethod void testGetInsurersByName() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        List<Account> accountsJSON1;
        List<Account> accountsJSON2;
        List<Account> accountsJSON3;
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where ContactId =: workerContactId Limit 1];
        System.runAs(objWorkerUser) {
            accountsJSON1 = DRS_CaseItemForm_CC.getInsurersByName('');
            accountsJSON2 = DRS_CaseItemForm_CC.getInsurersByName('InvalidAccount');
            accountsJSON3 = DRS_CaseItemForm_CC.getInsurersByName('Contact');
        }
        Test.stopTest();
        
        System.assertEquals(0, accountsJSON1.size());
        System.assertEquals(0, accountsJSON2.size());
        System.assertEquals(1, accountsJSON3.size());
    }
    
    private static testmethod void testGetCategories1() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        
        String snippetsJSONWorker;
        String snippetsJSONInsurer;
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where ContactId =: workerContactId Limit 1];
        System.runAs(objWorkerUser) {
            snippetsJSONWorker = DRS_CaseItemForm_CC.getCategories();
        }
        
        User objInsurerUser = [Select Id, Contact.Name From User Where ContactId =: triageContactId Limit 1];
        System.runAs(objInsurerUser) {
            snippetsJSONInsurer = DRS_CaseItemForm_CC.getCategories();
        }
        Test.stopTest();
        
        List<Snippet__c> listSnippetsWorker = (List<Snippet__c>)JSON.deserialize(snippetsJSONWorker, List<Snippet__c>.class);
        System.assertEquals(0, listSnippetsWorker.size());
        
        List<Snippet__c> listSnippetsInsurer = (List<Snippet__c>)JSON.deserialize(snippetsJSONInsurer, List<Snippet__c>.class);
        //System.assertEquals(3, listSnippetsInsurer.size());
    }
    
    private static testmethod void testGetCategories2() {
    	User adminUser = DRS_TestData.adminUser;
    	Map<String, PermissionSet> mapPermissionSets = DRS_GlobalUtility.getPermissionSets();
        DRS_TestData.PermissionSetAssignmentClass objPermissionSetAssignmentClass = new DRS_TestData.PermissionSetAssignmentClass();
        objPermissionSetAssignmentClass.userId = adminUser.Id;
        objPermissionSetAssignmentClass.permissionSetId = mapPermissionSets.get(DRS_ContactService.PermissionSetMRSInternalUser).Id;
        String jobId = System.enqueueJob(objPermissionSetAssignmentClass);
        String snippetsJSONInternal;
        
        Test.startTest();
        System.runAs(adminUser) {
            snippetsJSONInternal = DRS_CaseItemForm_CC.getCategories();
        }
    }
    
    private static testmethod void testGetDateFromSalesforceString() {
    	Date objDate = DRS_GlobalUtility.getDateFromSalesforceString('2017-12-31');
    	System.assertEquals(2017, objDate.year());
    	System.assertEquals(12, objDate.month());
    	System.assertEquals(31, objDate.day());
    }
    
    private static testmethod void testGetMessage() {
    	String message = DRS_MessageService.getMessage(DRS_MessageService.EmailAlreadyExists, new String[]{'email@email.com'});
    	System.assert(message.contains('email@email.com'));
    }
    
    private static testmethod void testGetDateDifferenceWithHolidays() {
    	DateTime objDateTime = DRS_GlobalUtility.getDateDifferenceWithHolidays(DateTime.newInstance(2017,12,4,9,0,0), 1);
    	///Depending on the time of the day this test is executed, the results may change
        ///Not asserting the return values
    }
    
    private static testmethod void testViewDocument() {
    	///Initiate a new worker Case Item
        Case objCase = DRS_TestData.initiateWorkerCaseItem();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        String attachmentJSON;
        DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON;
        
        ///Submit the case as a worker
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        objWorkerUser = [Select Id From User Where ContactId =: objWorkerContact.Id Limit 1];
        System.runAs(objWorkerUser) {
            objCaseItem = DRS_TestData.submitWorkerCaseItem(
                objWorkerContact.Id, objTriageContact.AccountId, objTriageContact.Account.Name, objCase.CaseItems__r[0].Id, objCase.Id, true,
                'myNewEmailAddress@testemail.test.a1b2.com',
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
            
            objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON();
            objAttachmentJSON.name = 'Filename1.png';
            objAttachmentJSON.description = 'File Name 1 description';
            objAttachmentJSON.category = 'Main Category 1';
            objAttachmentJSON.tier2 = 'tier 201';
            objAttachmentJSON.tier3 = 'tier 301';
            objAttachmentJSON.author = 'Author1';
            objAttachmentJSON.dateOfDocument = '12/12/2000';
            objAttachmentJSON.caseId = objCase.Id;
            objAttachmentJSON.caseItemId = objCaseItem.Id;
            objAttachmentJSON.externallyVisible = true;
            attachmentJSON = DRS_CaseItemForm_CC.addAttachmentAndGetSignedURL(JSON.serialize(objAttachmentJSON));
            
            objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
            
            Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(objAttachmentJSON.attachmentId);
            Test.setCurrentPage(Page.DRS_Attachment_View);
            ApexPages.StandardController objStandardController = new ApexPages.StandardController(objAttachment);
            DRS_ViewDocument_CX objViewDocument = new DRS_ViewDocument_CX(objStandardController);
        }
    }
    
    private static testmethod void testInitiateNewCaseItem1() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        String caseItemFormJSON;
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where ContactId =: workerContactId Limit 1];
        System.runAs(objWorkerUser) {
            caseItemFormJSON = DRS_CaseItemForm_CC.initiateNewCaseItem();
        }
        Test.stopTest();
        
        Case objCase = [Select Id, CaseNumber, Status From Case Order By CreatedDate Desc Limit 1];
        Contact objWorkerContact = DRS_ContactService.getContactDetails(workerContactId);
        
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        System.assertEquals(objCase.CaseNumber, objCaseItemFormJSON.caseNumber);
        System.assertEquals(objCase.Id, objCaseItemFormJSON.caseId);
        System.assertEquals(DRS_CaseService.CaseItemStatusDraft, objCaseItemFormJSON.status);
        System.assert(String.isBlank(objCaseItemFormJSON.claimNo));
        System.assertEquals(objWorkerContact.Id, objCaseItemFormJSON.contactId);
        System.assertEquals(objWorkerContact.FirstName, objCaseItemFormJSON.givenName);
        System.assertEquals(objWorkerContact.LastName, objCaseItemFormJSON.surname);
        System.assertEquals(String.valueOf(objWorkerContact.Birthdate), objCaseItemFormJSON.dob);
        System.assertEquals(objWorkerContact.Phone, objCaseItemFormJSON.contact);
        System.assertEquals(objWorkerContact.Email, objCaseItemFormJSON.emailAddress);
        System.assertEquals(objWorkerContact.MailingStreet, objCaseItemFormJSON.postal);
        System.assertEquals(objWorkerContact.MailingCity, objCaseItemFormJSON.suburb);
        System.assertEquals(objWorkerContact.MailingState, objCaseItemFormJSON.state);
        System.assertEquals(objWorkerContact.MailingPostalCode, objCaseItemFormJSON.postcode);
        System.assertEquals(objWorkerContact.InterpreterRequired__c, objCaseItemFormJSON.interpreter);
        System.assertEquals(objWorkerContact.Language__c, objCaseItemFormJSON.language);
        System.assertEquals(objWorkerContact.KnownWorkerDisabilities__c, objCaseItemFormJSON.disabilities);
    }
    
    private static testmethod void testInitiateNewCaseItem2() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        String caseItemFormJSON;
        
        Test.startTest();
        caseItemFormJSON = DRS_CaseItemForm_CC.initiateNewCaseItem();
        Test.stopTest();
        
        Case objCase = [Select Id, CaseNumber, Status From Case Order By CreatedDate Desc Limit 1];
        Contact objWorkerContact = DRS_ContactService.getContactDetails(workerContactId);
        
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(caseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        System.assertEquals(objCase.CaseNumber, objCaseItemFormJSON.caseNumber);
        System.assertEquals(objCase.Id, objCaseItemFormJSON.caseId);
        System.assertEquals(DRS_CaseService.CaseItemStatusDraft, objCaseItemFormJSON.status);
        System.assert(String.isBlank(objCaseItemFormJSON.claimNo));
        System.assert(String.isBlank(objCaseItemFormJSON.contactId));
        System.assert(String.isBlank(objCaseItemFormJSON.givenName));
        System.assert(String.isBlank(objCaseItemFormJSON.surname));
        System.assert(String.isBlank(objCaseItemFormJSON.dob));
        System.assert(String.isBlank(objCaseItemFormJSON.contact));
        System.assert(String.isBlank(objCaseItemFormJSON.emailAddress));
        System.assert(String.isBlank(objCaseItemFormJSON.postal));
        System.assert(String.isBlank(objCaseItemFormJSON.suburb));
        System.assert(String.isBlank(objCaseItemFormJSON.state));
        System.assert(String.isBlank(objCaseItemFormJSON.postcode));
        System.assert(String.isBlank(objCaseItemFormJSON.interpreter));
        System.assert(String.isBlank(objCaseItemFormJSON.language));
        System.assert(String.isBlank(objCaseItemFormJSON.disabilities));
    }
    
    private static testmethod void testSaveCaseItem1() {
        ///Initiate a new worker Case Item
        Case objCase = DRS_TestData.initiateWorkerCaseItem();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        String workerCaseItemId;
        
        ///Submit the case as a worker
        Test.startTest();
        objWorkerContact = [Select Id, Email, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        objWorkerUser = [Select Id From User Where ContactId =: objWorkerContact.Id Limit 1];
        for(CaseItem__c objCaseItemLoop : objCase.CaseItems__r) {
            if(objCaseItemLoop.Type__c == DRS_CaseService.WorkerCaseItemType) {
                workerCaseItemId = objCaseItemLoop.Id;
            }
        }
        objCaseItem = DRS_TestData.submitWorkerCaseItem(
            objWorkerContact.Id, objTriageContact.AccountId, objTriageContact.Account.Name, workerCaseItemId, objCase.Id, false,
            objWorkerContact.Email, ///emailAddress
            'yes', ///behalfOfWorker
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
        Test.stopTest();
        
        ///Assert the Contact details got updated correctly
        System.assert(String.isBlank(objWorkerContact.Language__c));
        System.assert(String.isBlank(objWorkerContact.KnownWorkerDisabilities__c));
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        System.assertEquals('French', objWorkerContact.Language__c);
        System.assertEquals('Disabilities', objWorkerContact.KnownWorkerDisabilities__c);
        
        ///Assert the Case details got updated correctly
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        System.assertEquals('123123123', objCase.ClaimNumber__c);
        System.assertEquals(objTriageContact.AccountId, objCase.Insurer__c);
        System.assertEquals(Date.today(), objCase.DateTimeCaseLodged__c.Date());
        System.assertEquals(objWorkerContact.Id, objCase.ContactId);
        System.assertEquals('Worker Advocate', objCase.RepresentativeType__c);
        System.assertEquals(Date.newInstance(2005, 12, 12), objCase.DateOfInjury__c);
        System.assertEquals(Date.newInstance(2017, 3, 4), objCase.IRDecision__c);
        System.assertEquals(Date.newInstance(2017, 3, 3), objCase.WCDNoticeDate__c);
        System.assertEquals(Date.newInstance(2017, 3, 1), objCase.DateWorkerReceivedIR__c);
        System.assertEquals(true, objCase.S43AWorkCapacity__c);
        System.assertEquals(true, objCase.S43BSuitableEmployment__c);
        System.assertEquals(true, objCase.S43CAmountEarntInSE__c);
        System.assertEquals(true, objCase.S43D1PIAWE__c);
        System.assertEquals(true, objCase.S43D2CurrentWeeklyEarnings__c);
        System.assertEquals(true, objCase.S43EUnableToEngageInCertainEmploy__c);
        System.assertEquals(true, objCase.S43FAnyOtherWeeklyPaymentsDecision__c);
        
        ///Assert the Contact's User was assigned as the Case Team Member with Role = Worker
        Boolean workerCaseTeamMemberFound = false;
        List<CaseTeamMember> listCaseTeamMembers = DRS_CaseService.getCaseTeamMembers(objCase.Id);
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(objCaseTeamMember.TeamRole.Name == DRS_CaseService.WorkerRoleName) {
                workerCaseTeamMemberFound = true;
                System.assertEquals(objWorkerUser.Id, objCaseTeamMember.MemberId);
            }
            else {
                System.assertEquals(DRS_CaseService.InsurerTriageRoleName, objCaseTeamMember.TeamRole.Name);
            }
        }
        System.assertEquals(true, workerCaseTeamMemberFound);
        
        ///Assert the Case Item got updated correctly
        System.assertEquals(DRS_CaseService.CaseItemStatusSubmitted, objCaseItem.Status__c);
        System.assertEquals(null, objCaseItem.ExpiryDate__c);
    }
    
    ///Tests submission of Case Item on behalf of Worker
    private static testmethod void testSaveCaseItem2() {
        ///Initiate a new worker Case Item
        Case objCase = DRS_TestData.initiateWorkerCaseItem();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        String workerCaseItemId;
        
        ///Submit the case as a worker
        Test.startTest();
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        objWorkerUser = [Select Id From User Where ContactId =: objWorkerContact.Id Limit 1];
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        
        for(CaseItem__c objCaseItemLoop : objCase.CaseItems__r) {
            if(objCaseItemLoop.Type__c == DRS_CaseService.WorkerCaseItemType) {
                workerCaseItemId = objCaseItemLoop.Id;
            }
        }
        
        objCaseItem = DRS_TestData.submitWorkerCaseItem(
            objWorkerContact.Id, objTriageContact.AccountId, objTriageContact.Account.Name, workerCaseItemId, objCase.Id, false,
            'myNewEmailAddress@testemail.test.a1b2.com',
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
        Test.stopTest();
        
        ///Assert the Contact details did not get updated because Case Item was submitted on behalf of worker
        System.assert(String.isBlank(objWorkerContact.Language__c));
        System.assert(String.isBlank(objWorkerContact.KnownWorkerDisabilities__c));
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        System.assert(String.isBlank(objWorkerContact.Language__c));
        System.assert(String.isBlank(objWorkerContact.KnownWorkerDisabilities__c));
        
        ///Assert a new Contact was created as result of Case Item submission
        Contact newContact = [Select Id, FirstName, LastName From Contact Where Email = 'myNewEmailAddress@testemail.test.a1b2.com' Limit 1];
        System.assertEquals('Given Name', newContact.FirstName);
        System.assertEquals('Surname', newContact.LastName);
        
        ///Assert the correct Contact was assigned to the Case
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        System.assertEquals(newContact.Id, objCase.ContactId);
        
        ///Assert the Representative's User was assigned as the Case Team Member with Role = Worker Reprentative
        Boolean workerCaseTeamMemberFound = false;
        List<CaseTeamMember> listCaseTeamMembers = DRS_CaseService.getCaseTeamMembers(objCase.Id);
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(objCaseTeamMember.TeamRole.Name == DRS_CaseService.WorkerRepresentativeRoleName) {
                workerCaseTeamMemberFound = true;
                System.assertEquals(objWorkerUser.Id, objCaseTeamMember.MemberId);
            }
            else {
                System.assertEquals(DRS_CaseService.InsurerTriageRoleName, objCaseTeamMember.TeamRole.Name);
            }
        }
        System.assertEquals(true, workerCaseTeamMemberFound);
        
        ///Assert the Case Item got updated correctly
        System.assertEquals(DRS_CaseService.CaseItemStatusSubmitted, objCaseItem.Status__c);
        System.assertEquals(null, objCaseItem.ExpiryDate__c);
    }
    
    ///Tests submission of Case Item as an Internal MRS Staff
    private static testmethod void testSaveCaseItem3() {
        ///Initiate a new worker Case Item
        Case objCase = DRS_TestData.initiateWorkerCaseItem();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        String workerCaseItemId;
        
        ///Submit the case as an Internal MRS Staff
        Test.startTest();
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        for(CaseItem__c objCaseItemLoop : objCase.CaseItems__r) {
            if(objCaseItemLoop.Type__c == DRS_CaseService.WorkerCaseItemType) {
                workerCaseItemId = objCaseItemLoop.Id;
            }
        }
        
        objCaseItem = DRS_TestData.submitWorkerCaseItem(
            null, objTriageContact.AccountId, objTriageContact.Account.Name, workerCaseItemId, objCase.Id, false,
            'myNewEmailAddress@testemail.test.a1b2.com',
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
        Test.stopTest();
        
        ///Assert a new Contact was created as result of Case Item submission
        Contact newContact = [Select Id, FirstName, LastName From Contact Where Email = 'myNewEmailAddress@testemail.test.a1b2.com' Limit 1];
        System.assertEquals('Given Name', newContact.FirstName);
        System.assertEquals('Surname', newContact.LastName);
        
        ///Assert the correct Contact was assigned to the Case
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        System.assertEquals(newContact.Id, objCase.ContactId);
        
        ///Assert the Representative's User was assigned as the Case Team Member with Role = Worker Reprentative
        Boolean workerCaseTeamMemberFound = false;
        List<CaseTeamMember> listCaseTeamMembers = DRS_CaseService.getCaseTeamMembers(objCase.Id);
        for(CaseTeamMember objCaseTeamMember : listCaseTeamMembers) {
            if(objCaseTeamMember.TeamRole.Name == DRS_CaseService.WorkerRepresentativeRoleName) {
                workerCaseTeamMemberFound = true;
                System.assertEquals(DRS_TestData.adminUser.Id, objCaseTeamMember.MemberId);
            }
            else {
                System.assertEquals(DRS_CaseService.InsurerTriageRoleName, objCaseTeamMember.TeamRole.Name);
            }
        }
        System.assertEquals(true, workerCaseTeamMemberFound);
        
        ///Assert the Case Item got updated correctly
        System.assertEquals(DRS_CaseService.CaseItemStatusSubmitted, objCaseItem.Status__c);
        System.assertEquals(null, objCaseItem.ExpiryDate__c);
    }
    
    ///Tests submission of Insurer Case Item
    private static testmethod void testSaveCaseItem4() {
        ///Initiate a new worker Case Item
        Case objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        
        ///Submit the case as an Insurer
        Test.startTest();
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        DRS_TestData.initiateInsurerCaseItem(objCase.Id);
        objCaseItem = DRS_TestData.submitInsurerCaseItem(
            objTriageContact.Id, objCase.Id, false, 
            'yes', ///workInReceipt
            '01/02/2017', ///supportingDocumentAttachedDate
            '02/02/2017' ///workCapacityDecisionDate)
        );
        Test.stopTest();
        
        ///Assert the Case was updated correctly
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        System.assert('BEFORE 01/10/12' == objCase.ClaimType__c);
        System.assertEquals(Date.newInstance(2017, 2, 1), objCase.IRLodged__c);
        
        ///Assert the Case Item got updated correctly
        System.assertEquals(DRS_CaseService.CaseItemStatusSubmitted, objCaseItem.Status__c);
        System.assertEquals(null, objCaseItem.ExpiryDate__c);
    }
    
    ///Tests submission of Insurer Case Item
    private static testmethod void testSaveCaseItem5() {
        ///Initiate a new worker Case Item
        Case objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        
        ///Submit the case as an Insurer
        Test.startTest();
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        DRS_TestData.initiateInsurerCaseItem(objCase.Id);
        objCaseItem = DRS_TestData.submitInsurerCaseItem(
            objTriageContact.Id, objCase.Id, false, 
            'no', ///workInReceipt
            '01/02/2017', ///supportingDocumentAttachedDate
            '02/02/2017' ///workCapacityDecisionDate)
        );
        Test.stopTest();
        
        ///Assert the Case was updated correctly
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        System.assert('ON OR AFTER 01/10/12' == objCase.ClaimType__c);
        System.assertEquals(Date.newInstance(2017, 2, 1), objCase.IRLodged__c);
    }
    
    private static testmethod void testSavePauseCaseItem1() {
        Case objCase;
        
        ///Save Case Item as an Insurer
        Test.startTest();
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSaved();
        Test.stopTest();
        
        ///Assert the Case Item was saved correctly
        System.assertEquals(1, objCase.CaseItems__r.size());
        System.assertEquals(DRS_CaseService.CaseItemStatusDraft, objCase.CaseItems__r[0].Status__c);
        System.assertEquals(Date.today().addDays(DRS_GlobalUtility.getMRSConfiguration().NumberOfDaysToExpire__c.intValue()), objCase.CaseItems__r[0].ExpiryDate__c.Date());
    }
    
    private static testmethod void testSavePauseCaseItem2() {
        Case objCase;
        CaseItem__c objCaseItem;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        Contact objTriageContact;
        
        ///Save Case Item as an Insurer
        Test.startTest();
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        DRS_TestData.initiateInsurerCaseItem(objCase.Id);
        objCaseItem = DRS_TestData.submitInsurerCaseItem(
            objTriageContact.Id, objCase.Id, true, 
            'no', ///workInReceipt
            '01/02/2017', ///supportingDocumentAttachedDate
            '02/02/2017' ///workCapacityDecisionDate)
        );
        Test.stopTest();
        
        ///Assert the Case Item was saved correctly
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        System.assertEquals(4, objCase.CaseItems__r.size());
    }
    
    private static testmethod void testSaveAdditionalInformation() {
        Case objCase;
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        ApexPages.StandardController objStandardController = new ApexPages.StandardController(objCase);
        DRS_AdditionalInformation_CX objDRS_AdditionalInformation_CX = new DRS_AdditionalInformation_CX(objStandardController);
        objDRS_AdditionalInformation_CX.objTask.Description = 'Task Description';
        objDRS_AdditionalInformation_CX.objCaseItem.RoleGroup__c = DRS_AccountService.TypeWorkerWorkerRep;
        objDRS_AdditionalInformation_CX.saveAdditionalInformation();
        
        Test.startTest();
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        objCaseItem = [Select Id, Status__c, RoleGroup__c, CaseItemData__c From CaseItem__c Where Type__c =: DRS_CaseService.AdditionalInformationTaskType And Case__c =: objCase.Id Limit 1];
        String caseItemFormJSON = '' +
            '{' +
            '   \"attachments\": [' +
            '       {' +
            '           \"submitter\": \"\",' +
            '           \"dateLoaded\": \"17/03/2017\",' +
            '           \"description\": \"Description\",' +
            '           \"decisions\": [],' +
            '           \"subcategory\": \"\",' +
            '           \"category\": \"Correspondence and other\",' +
            '           \"name\": \"Image 1.png\"' +
            '       }' +
            '   ],' +
            '   \"caseItemId\": \"' + objCaseItem.Id + '\",' +
            '   \"caseId\": \"' + objCase.Id + '\",' +
            '   \"response\": \"My Additional Response\"' +
            '}';
        DRS_TestData.submitAdditionalInformation(objWorkerContact.Id, caseItemFormJSON);
        Test.stopTest();
        
        objCaseItem = [Select Id, Status__c, RoleGroup__c, CaseItemData__c From CaseItem__c Where Type__c =: DRS_CaseService.AdditionalInformationTaskType And Case__c =: objCase.Id Limit 1];
        System.assertEquals(DRS_CaseService.CaseItemStatusSubmitted, objCaseItem.Status__c);
    }
    
    private static testmethod void testGetExistingCaseItem1() {
        Case objCase;
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        String mrsCaseItemFormJSON;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        String workerCaseItemId;
        
        Test.startTest();
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        System.runAs(DRS_ContactService.getUserForContact(objWorkerContact.Id)) {
            for(CaseItem__c objCaseItemLoop : objCase.CaseItems__r) {
                if(objCaseItemLoop.Type__c == DRS_CaseService.WorkerCaseItemType) {
                    workerCaseItemId = objCaseItemLoop.Id;
                }
            }
            
            mrsCaseItemFormJSON = DRS_CaseItemForm_CC.getExistingCaseItem(workerCaseItemId);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(mrsCaseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        
        System.assertEquals(DRS_CaseService.CaseItemStatusSubmitted, objCaseItemFormJSON.status);
    }
    
    private static testmethod void testGetExistingCaseItem2() {
        Case objCase;
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        String mrsCaseItemFormJSON;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        String workerCaseItemId;
        
        Test.startTest();
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        System.runAs(DRS_ContactService.getUserForContact(objWorkerContact.Id)) {
            for(CaseItem__c objCaseItemLoop : objCase.CaseItems__r) {
                if(objCaseItemLoop.Type__c == DRS_CaseService.WorkerCaseItemType) {
                    workerCaseItemId = objCaseItemLoop.Id;
                }
            }
            
            DRS_TestData.addAttachment(objCase.Id, workerCaseItemId, true);
            mrsCaseItemFormJSON = DRS_CaseItemForm_CC.getExistingCaseItem(objCase.CaseItems__r[0].Id);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseItemJSON objCaseItemFormJSON = (DRS_GlobalWrapper.CaseItemJSON)JSON.deserialize(mrsCaseItemFormJSON, DRS_GlobalWrapper.CaseItemJSON.class);
        
        System.assertEquals(DRS_CaseService.CaseItemStatusSubmitted, objCaseItemFormJSON.status);
    }
    
    private static testmethod void testGetInternalUsers() {
        String workerContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeIndividual, DRS_AccountService.TypeWorkerWorkerRep, DRS_ContactService.ContactRoleWorker, '', false);
        User adminUser = DRS_TestData.adminUser;
        User randomAdminUser = [Select LastName From User Where Profile.Name = 'System Administrator' Limit 1];
        String adminUserList;
        
        ///Run the method as an internal user
        Test.startTest();
        System.runAs(adminUser) {
            adminUserList = DRS_CaseItemForm_CC.getInternalUsers(randomAdminUser.LastName.subString(0,4));
        }
        Test.stopTest();
        
        List<User> listUsers = (List<User>)JSON.deserialize(adminUserList, List<User>.class);
        System.assert(listUsers.size() > 0);
        
        ///Run the method as a worker
        System.runAs(DRS_ContactService.getUserForContact(workerContactId)) {
            adminUserList = DRS_CaseItemForm_CC.getInternalUsers(randomAdminUser.LastName.subString(0,4));
        }
        listUsers = (List<User>)JSON.deserialize(adminUserList, List<User>.class);
        System.assertEquals(0, listUsers.size());
    }
    
    private static testmethod void testAddAndRemoveAttachment() {
        ///Initiate a new worker Case Item
        Case objCase = DRS_TestData.initiateWorkerCaseItem();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        String attachmentJSON;
        DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON;
        
        ///Submit the case as a worker
        objWorkerContact = [Select Id, Language__c, KnownWorkerDisabilities__c From Contact Where Role__c =: DRS_ContactService.ContactRoleWorker Limit 1];
        objTriageContact = [Select Id, AccountId, Account.Name From Contact Where Role__c =: DRS_ContactService.ContactRoleTriage Limit 1];
        objWorkerUser = [Select Id From User Where ContactId =: objWorkerContact.Id Limit 1];
        System.runAs(objWorkerUser) {
            objCaseItem = DRS_TestData.submitWorkerCaseItem(
                objWorkerContact.Id, objTriageContact.AccountId, objTriageContact.Account.Name, objCase.CaseItems__r[0].Id, objCase.Id, true,
                'myNewEmailAddress@testemail.test.a1b2.com',
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
            
            objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON();
            objAttachmentJSON.name = 'Filename1.png';
            objAttachmentJSON.description = 'File Name 1 description';
            objAttachmentJSON.category = 'Main Category 1';
            objAttachmentJSON.tier2 = 'tier 201';
            objAttachmentJSON.tier3 = 'tier 301';
            objAttachmentJSON.author = 'Author1';
            objAttachmentJSON.dateOfDocument = '12/12/2000';
            objAttachmentJSON.caseId = objCase.Id;
            objAttachmentJSON.caseItemId = objCaseItem.Id;
            objAttachmentJSON.externallyVisible = true;
            attachmentJSON = DRS_CaseItemForm_CC.addAttachmentAndGetSignedURL(JSON.serialize(objAttachmentJSON));
        }
        
        objAttachmentJSON = (DRS_GlobalWrapper.AttachmentJSON)JSON.deserialize(attachmentJSON, DRS_GlobalWrapper.AttachmentJSON.class);
        System.assert(String.isNotBlank(objAttachmentJSON.attachmentId));
        Attachment__c objAttachment = DRS_CaseService.getAttachmentDetails(objAttachmentJSON.attachmentId);
        System.assertEquals(objCase.Id, objAttachment.Case__c);
        System.assertEquals('Filename1.png', objAttachment.FileName__c);
        
        Test.startTest();
        Test.setMock(System.HttpCalloutMock.class, new DRS_TestData.DRS_CalloutMock());
        System.runAs(objWorkerUser) {
            DRS_CaseItemForm_CC.removeAttachment(objAttachmentJSON.attachmentId);
        }
        Test.stopTest();
    }
    
    private static testmethod void testSaveAllocationChecklist() {
        ///Initiate a new worker Case Item
        Case objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        CaseItem__c objCaseItem;
        Contact objWorkerContact;
        Contact objTriageContact;
        User objWorkerUser;
        String jurisdictionCaseItemId;
        
        ///Submit the case as an Insurer
        Test.startTest();
        for(CaseItem__c objCaseItemLoop : objCase.CaseItems__r) {
            if(objCaseItemLoop.Type__c == DRS_CaseService.JurisdictionChecklistTaskType) {
                jurisdictionCaseItemId = objCaseItemLoop.Id;
            }
        }
        DRS_GlobalWrapper.CaseItemJSON objCaseItemJSON = new DRS_GlobalWrapper.CaseItemJSON();
        objCaseItemJSON.caseItemId = jurisdictionCaseItemId;
        
        DRS_CaseItemForm_CC.saveAllocationChecklist(JSON.serialize(objCaseItemJSON));
        
        Test.stopTest();
    }
}