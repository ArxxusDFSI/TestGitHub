@IsTest
public class DRS_Case_CC_Test {
    
    @TestSetup
    private static void initializeData(){
        DRS_SetupData.processData();
    }
    
    ///Tests Worker view of Worker Case Item submitted
    private static testmethod void testGetCaseJSON1() {
        Case objCase;
        String caseJSON;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            caseJSON = DRS_Case_CC.getCaseJSON(objCase.Id);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseJSON objCaseJSON = (DRS_GlobalWrapper.CaseJSON)JSON.deserialize(caseJSON, DRS_GlobalWrapper.CaseJSON.class);
        System.debug('---DRS_Case_CC_Test:testGetCaseJSON1:objCaseJSON:' + objCaseJSON);
        System.assert(objCaseJSON != null);
        System.assertEquals(0, objCaseJSON.pendingCaseItems.size());
        System.assertEquals(1, objCaseJSON.submittedCaseItems.size());
        System.assertEquals(1, objCaseJSON.caseTeamMembers.size());
        
        System.assertEquals(objCase.CaseNumber, objCaseJSON.caseNumber);
        System.assertEquals(objCase.Id, objCaseJSON.caseId);
        System.assertEquals(objCase.Status, objCaseJSON.status);
        System.assertEquals(objCase.ClaimNumber__c, objCaseJSON.claimNumber);
        System.assertEquals(objCase.Contact.Name, objCaseJSON.workerName);
        System.assertEquals(objCase.Insurer__r.Name, objCaseJSON.insurer);
        System.assertEquals(objWorkerUser.Contact.Name, objCaseJSON.loggedInUserName);
        System.assertEquals(false, objCaseJSON.showManageCaseTeamMembers);
    }
    
    ///Tests Insurer view of Worker Case Item submitted
    private static testmethod void testGetCaseJSON2() {
        Case objCase;
        String caseJSON;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        Test.startTest();
        User objTriageUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleTriage And Contact.AccountId =: objCase.Insurer__c Limit 1];
        System.runAs(objTriageUser) {
            caseJSON = DRS_Case_CC.getCaseJSON(objCase.Id);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseJSON objCaseJSON = (DRS_GlobalWrapper.CaseJSON)JSON.deserialize(caseJSON, DRS_GlobalWrapper.CaseJSON.class);
        System.debug('---DRS_Case_CC_Test:testGetCaseJSON2:objCaseJSON:' + objCaseJSON);
        System.assert(objCaseJSON != null);
        System.assertEquals(0, objCaseJSON.pendingCaseItems.size());
        System.assertEquals(1, objCaseJSON.submittedCaseItems.size());
        System.assertEquals(1, objCaseJSON.caseTeamMembers.size());
        
        System.assertEquals(objCase.CaseNumber, objCaseJSON.caseNumber);
        System.assertEquals(objCase.Id, objCaseJSON.caseId);
        System.assertEquals(objCase.Status, objCaseJSON.status);
        System.assertEquals(objCase.ClaimNumber__c, objCaseJSON.claimNumber);
        System.assertEquals(objCase.Contact.Name, objCaseJSON.workerName);
        System.assertEquals(objCase.Insurer__r.Name, objCaseJSON.insurer);
        System.assertEquals(objTriageUser.Contact.Name, objCaseJSON.loggedInUserName);
        System.assertEquals(true, objCaseJSON.showManageCaseTeamMembers);
    }
    
    ///Tests Worker view of Insurer Case Item submitted
    private static testmethod void testGetCaseJSON3() {
        Case objCase;
        String caseJSON;
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            caseJSON = DRS_Case_CC.getCaseJSON(objCase.Id);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseJSON objCaseJSON = (DRS_GlobalWrapper.CaseJSON)JSON.deserialize(caseJSON, DRS_GlobalWrapper.CaseJSON.class);
        System.debug('---DRS_Case_CC_Test:testGetCaseJSON3:objCaseJSON:' + objCaseJSON);
        System.assert(objCaseJSON != null);
        System.assertEquals(0, objCaseJSON.pendingCaseItems.size());
        System.assertEquals(2, objCaseJSON.submittedCaseItems.size());
        System.assertEquals(2, objCaseJSON.caseTeamMembers.size());
        
        System.assertEquals(objCase.CaseNumber, objCaseJSON.caseNumber);
        System.assertEquals(objCase.Id, objCaseJSON.caseId);
        System.assertEquals(objCase.Status, objCaseJSON.status);
        System.assertEquals(objCase.ClaimNumber__c, objCaseJSON.claimNumber);
        System.assertEquals(objCase.Contact.Name, objCaseJSON.workerName);
        System.assertEquals(objCase.Insurer__r.Name, objCaseJSON.insurer);
        System.assertEquals(objWorkerUser.Contact.Name, objCaseJSON.loggedInUserName);
        System.assertEquals(false, objCaseJSON.showManageCaseTeamMembers);
    }
    
    ///Tests Insurer view of Insurer Case Item submitted
    private static testmethod void testGetCaseJSON4() {
        Case objCase;
        String caseJSON;
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        Test.startTest();
        User objTriageUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleTriage And Contact.AccountId =: objCase.Insurer__c Limit 1];
        System.runAs(objTriageUser) {
            caseJSON = DRS_Case_CC.getCaseJSON(objCase.Id);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseJSON objCaseJSON = (DRS_GlobalWrapper.CaseJSON)JSON.deserialize(caseJSON, DRS_GlobalWrapper.CaseJSON.class);
        System.debug('---DRS_Case_CC_Test:testGetCaseJSON4:objCaseJSON:' + objCaseJSON);
        System.assert(objCaseJSON != null);
        System.assertEquals(0, objCaseJSON.pendingCaseItems.size());
        System.assertEquals(2, objCaseJSON.submittedCaseItems.size());
        System.assertEquals(2, objCaseJSON.caseTeamMembers.size());
        
        System.assertEquals(objCase.CaseNumber, objCaseJSON.caseNumber);
        System.assertEquals(objCase.Id, objCaseJSON.caseId);
        System.assertEquals(objCase.Status, objCaseJSON.status);
        System.assertEquals(objCase.ClaimNumber__c, objCaseJSON.claimNumber);
        System.assertEquals(objCase.Contact.Name, objCaseJSON.workerName);
        System.assertEquals(objCase.Insurer__r.Name, objCaseJSON.insurer);
        System.assertEquals(objTriageUser.Contact.Name, objCaseJSON.loggedInUserName);
        System.assertEquals(true, objCaseJSON.showManageCaseTeamMembers);
    }
    
    ///Tests Worker view of Worker Case Item submitted with attachments saved
    private static testmethod void testGetCaseJSON5() {
        Case objCase;
        String caseJSON;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        DRS_TestData.addAttachment(objCase.Id, objCase.CaseItems__r[0].Id, true);
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            caseJSON = DRS_Case_CC.getCaseJSON(objCase.Id);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseJSON objCaseJSON = (DRS_GlobalWrapper.CaseJSON)JSON.deserialize(caseJSON, DRS_GlobalWrapper.CaseJSON.class);
        System.debug('---DRS_Case_CC_Test:testGetCaseJSON1:objCaseJSON:' + objCaseJSON);
        System.assert(objCaseJSON != null);
        System.assertEquals(0, objCaseJSON.pendingCaseItems.size());
        System.assertEquals(1, objCaseJSON.submittedCaseItems.size());
        System.assertEquals(1, objCaseJSON.caseTeamMembers.size());
        
        System.assertEquals(objCase.CaseNumber, objCaseJSON.caseNumber);
        System.assertEquals(objCase.Id, objCaseJSON.caseId);
        System.assertEquals(objCase.Status, objCaseJSON.status);
        System.assertEquals(objCase.ClaimNumber__c, objCaseJSON.claimNumber);
        System.assertEquals(objCase.Contact.Name, objCaseJSON.workerName);
        System.assertEquals(objCase.Insurer__r.Name, objCaseJSON.insurer);
        System.assertEquals(objWorkerUser.Contact.Name, objCaseJSON.loggedInUserName);
        System.assertEquals(false, objCaseJSON.showManageCaseTeamMembers);
    }
    
    ///Tests the Case Team Builder JSON creation
    private static testmethod void testGetCaseTeamBuilder() {
        Case objCase;
        String caseTeamBuilderJSON;
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        Test.startTest();
        User objTriageUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleTriage And Contact.AccountId =: objCase.Insurer__c Limit 1];
        System.runAs(objTriageUser) {
            caseTeamBuilderJSON = DRS_Case_CC.getCaseTeamBuilder(objCase.Id);
        }
        Test.stopTest();
        
        DRS_GlobalWrapper.CaseTeamBuilderJSON objCaseTeamBuilderJSON = (DRS_GlobalWrapper.CaseTeamBuilderJSON)JSON.deserialize(caseTeamBuilderJSON, DRS_GlobalWrapper.CaseTeamBuilderJSON.class);
        System.debug('---DRS_Case_CC_Test:testGetCaseTeamBuilder:caseTeamBuilderJSON:' + caseTeamBuilderJSON);
        System.assert(objCaseTeamBuilderJSON != null);
        System.assertEquals(2, objCaseTeamBuilderJSON.caseTeamMembers.size());
        Boolean isTriageUserFound = false;
        Boolean isCaseTeamRoleFound = false;
        List<String> listContactRoles = new List<String>();
        List<String> listCaseTeamRoles = new List<String>();
        listContactRoles.add(DRS_ContactService.ContactRoleClaimsManager);
        List<CaseTeamRoleAssociation__c> listAssociations = DRS_GlobalUtility.getCaseTeamRoleAssociationForContact(listContactRoles, DRS_AccountService.TypeInsurer);
        for(CaseTeamRoleAssociation__c objAssociation : listAssociations) {
            listCaseTeamRoles.add(objAssociation.CaseTeamRole__c);
        }
        
        
        for(DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMember : objCaseTeamBuilderJSON.caseTeamMembers) {
            if(objCaseTeamMember.roleName == DRS_CaseService.InsurerTriageRoleName) {
                isTriageUserFound = true;
                System.assertEquals(true, objCaseTeamMember.isExisting);
            }
            else {
                System.assertEquals(false, objCaseTeamMember.isExisting);
                for(DRS_GlobalWrapper.RoleJSON objRoleJSON : objCaseTeamMember.availableRoles) {
                    isCaseTeamRoleFound = false;
                    for(String caseTeamRole : listCaseTeamRoles) {
                        if(caseTeamRole == objRoleJSON.roleName) {
                            isCaseTeamRoleFound = true;
                            break;
                        }
                    }
                    System.assertEquals(true, isCaseTeamRoleFound);
                }
            }
        }
        System.assertEquals(true, isTriageUserFound);
    }
    
    ///Tests the saving of new Case Team Members
    private static testmethod void testSaveCaseTeamMembers1() {
        Case objCase;
        String caseTeamBuilderJSON;
        DRS_GlobalWrapper.CaseTeamBuilderJSON objCaseTeamBuilderJSON;
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        Test.startTest();
        User objTriageUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleTriage And Contact.AccountId =: objCase.Insurer__c Limit 1];
        System.runAs(objTriageUser) {
            caseTeamBuilderJSON = DRS_Case_CC.getCaseTeamBuilder(objCase.Id);
            objCaseTeamBuilderJSON = (DRS_GlobalWrapper.CaseTeamBuilderJSON)JSON.deserialize(caseTeamBuilderJSON, DRS_GlobalWrapper.CaseTeamBuilderJSON.class);
            
            for(DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMember : objCaseTeamBuilderJSON.caseTeamMembers) {
                if(objCaseTeamMember.isExisting == false) {
                    objCaseTeamMember.isAdded = true;
                    for(DRS_GlobalWrapper.RoleJSON objRoleJSON : objCaseTeamMember.availableRoles) {
                        objCaseTeamMember.roleId = objRoleJSON.roleId;
                    }
                }
            }
            
            DRS_Case_CC.saveCaseTeamMembers(objCase.Id, JSON.serialize(objCaseTeamBuilderJSON.caseTeamMembers));
        }
        Test.stopTest();
        
        List<CaseTeamMember> listCaseTeamMembers = DRS_CaseService.getCaseTeamMembers(objCase.Id);
        System.assertEquals(3, listCaseTeamMembers.size());
    }
    
    ///Tests the deleting exiting Case Team Members
    private static testmethod void testSaveCaseTeamMembers2() {
        Case objCase;
        String caseTeamBuilderJSON;
        DRS_GlobalWrapper.CaseTeamBuilderJSON objCaseTeamBuilderJSON;
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        Test.startTest();
        User objTriageUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleTriage And Contact.AccountId =: objCase.Insurer__c Limit 1];
        System.runAs(objTriageUser) {
            caseTeamBuilderJSON = DRS_Case_CC.getCaseTeamBuilder(objCase.Id);
            objCaseTeamBuilderJSON = (DRS_GlobalWrapper.CaseTeamBuilderJSON)JSON.deserialize(caseTeamBuilderJSON, DRS_GlobalWrapper.CaseTeamBuilderJSON.class);
            Integer indexAddedCaseTeamMember = -1;
            
            for(DRS_GlobalWrapper.CaseTeamMemberJSON objCaseTeamMember : objCaseTeamBuilderJSON.caseTeamMembers) {
                if(objCaseTeamMember.isExisting == false) {
                    objCaseTeamMember.isAdded = true;
                    for(DRS_GlobalWrapper.RoleJSON objRoleJSON : objCaseTeamMember.availableRoles) {
                        objCaseTeamMember.roleId = objRoleJSON.roleId;
                    }
                    indexAddedCaseTeamMember++;
                    break;
                }
            }
            DRS_Case_CC.saveCaseTeamMembers(objCase.Id, JSON.serialize(objCaseTeamBuilderJSON.caseTeamMembers));
            
            ///Use the same object retrieved before update and remove the added Case Team Member
            objCaseTeamBuilderJSON.caseTeamMembers.remove(indexAddedCaseTeamMember);
            DRS_Case_CC.saveCaseTeamMembers(objCase.Id, JSON.serialize(objCaseTeamBuilderJSON.caseTeamMembers));
        }
        Test.stopTest();
        
        List<CaseTeamMember> listCaseTeamMembers = DRS_CaseService.getCaseTeamMembers(objCase.Id);
        System.assertEquals(2, listCaseTeamMembers.size());
    }
    
    //Tests creating new attachments
    private static testmethod void testAddAttachment() {
        Case objCase;
        String caseTeamBuilderJSON;
        DRS_GlobalWrapper.CaseTeamBuilderJSON objCaseTeamBuilderJSON;
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        Test.startTest();
        DRS_GlobalWrapper.AttachmentJSON objAttachmentJSON = new DRS_GlobalWrapper.AttachmentJSON();
        objAttachmentJSON.name = 'FilenameAddAttachment.jpg';
        objAttachmentJSON.description = 'Description';
        objAttachmentJSON.category = 'Category A';
        objAttachmentJSON.tier2 = 'Category B';
        objAttachmentJSON.tier3 = 'Category C';
        objAttachmentJSON.caseId = objCase.Id;
        objAttachmentJSON.author = 'Author';
        objAttachmentJSON.dateOfDocument = '12/12/2000';
        objAttachmentJSON.externallyVisible = true;
        DRS_Case_CC.addAttachment(JSON.serialize(objAttachmentJSON));
        Test.stopTest();
        
        objCase = DRS_CaseService.getCaseDetails(objCase.Id);
        Boolean requiredAttachmentFound = false;
        System.assertEquals(1, objCase.Attachments__r.size());
        for(Attachment__c objAttachment : objCase.Attachments__r) {
            if(objAttachment.FileName__c == objAttachmentJSON.name) {
                requiredAttachmentFound = true;
                System.assertEquals(objAttachmentJSON.category, objAttachment.CategoryA__c);
                System.assertEquals(objAttachmentJSON.tier2, objAttachment.CategoryB__c);
                System.assertEquals(objAttachmentJSON.author, objAttachment.Author__c);
                System.assertEquals(objAttachmentJSON.description, objAttachment.Description__c);
            }
        }
        System.assertEquals(true, requiredAttachmentFound);
    }
    
    //Tests getting the Case List as a worker
    private static testmethod void testGetCaseList1() {
        Case objCase;
        String listCaseJSON;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            listCaseJSON = DRS_Case_CC.getCaseList();
        }
        Test.stopTest();
        
        List<DRS_GlobalWrapper.CaseJSON> objListCaseJSONs = (List<DRS_GlobalWrapper.CaseJSON>)JSON.deserialize(listCaseJSON, List<DRS_GlobalWrapper.CaseJSON>.class);
        System.assertEquals(1, objListCaseJSONs.size());
    }
    
    //Tests getting the Case List as a worker
    private static testmethod void testGetCaseList2() {
        Case objCase;
        String listCaseJSON;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, '', true);
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
            listCaseJSON = DRS_Case_CC.getCaseList();
        }
        Test.stopTest();
        
        List<DRS_GlobalWrapper.CaseJSON> objListCaseJSONs = (List<DRS_GlobalWrapper.CaseJSON>)JSON.deserialize(listCaseJSON, List<DRS_GlobalWrapper.CaseJSON>.class);
    }
    
    private static testmethod void testGetCaseDetailSnippets() {
        Case objCase;
        String listCaseJSON;
        DRS_TestData.createSnippets();
        
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        DRS_GlobalWrapper.CaseDetailJSON objCaseDetailJSON = new DRS_GlobalWrapper.CaseDetailJSON();
        string caseDetailJSON;
        Map<String, PermissionSet> mapPermissionSets = DRS_GlobalUtility.getPermissionSets();
        
        User adminUser = DRS_TestData.adminUser;
        DRS_TestData.PermissionSetAssignmentClass objPermissionSetAssignmentClass = new DRS_TestData.PermissionSetAssignmentClass();
        objPermissionSetAssignmentClass.userId = adminUser.Id;
        objPermissionSetAssignmentClass.permissionSetId = mapPermissionSets.get(DRS_ContactService.PermissionSetMRSInternalUser).Id;
        String jobId = System.enqueueJob(objPermissionSetAssignmentClass);
        
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            caseDetailJSON = DRS_Case_CC.getCaseDetailSnippets();
        }
        Test.stopTest();
        
        ///Run the method as an internal user
        System.runAs(adminUser) {
            caseDetailJSON = DRS_Case_CC.getCaseDetailSnippets();
        }
    }
    
    private static testmethod void testTopicAssignment() {
        Case objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        Topic objTopic = new Topic();
        objTopic.Name = 'Topic';
        objTopic.Description = 'Topic';
        Insert objTopic;
        
        TopicAssignment objTopicAssignment = new TopicAssignment();
        objTopicAssignment.EntityId = objCase.Id;
        objTopicAssignment.TopicId = objTopic.Id;
        Insert objTopicAssignment;
        
        Delete objTopicAssignment;
    }
    
    private static testmethod void testGetAppliationLog() {
        DRS_GlobalUtility.getAppliationLogError(
            'Message', '{}', '502', '', 'Reference Info', 'DDRS_Case_CC_Test', 'testGetAppliationLog', 'DDRS_Case_CC_Test.testGetAppliationLog');
    }
}