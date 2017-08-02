@IsTest
public class DRS_Dashboard_CC_Test {
    
    ///Initializes the SetupData
    @TestSetup
    private static void initializeData(){
        DRS_SetupData.processData();
    }
    
    ///Tests the whether the flag for delegated admin is returned for different users
    private static testmethod void testIsDelegatedAdmin() {
        Case objCase;
        Boolean isAdminUser;
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        ///Test with delegated admin user
        Test.startTest();
        User objAdminUser = [Select Id, Contact.Name From User Where Contact.Role__c = 'Administrator' And IsActive = true Limit 1];
        System.runAs(objAdminUser) {
            isAdminUser = DRS_Dashboard_CC.isDelegatedAdmin();
        }
        Test.stopTest();
        
        System.assertEquals(true, isAdminUser);
        
        ///Test with non-delegated admin user
        User objNonAdminUser = [Select Id, Contact.Name From User Where Contact.Role__c != 'Administrator' And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objNonAdminUser) {
            isAdminUser = DRS_Dashboard_CC.isDelegatedAdmin();
        }
        
        System.assertEquals(false, isAdminUser);
    }
    
    ///Tests GetCaseItems as a Worker for Worker Case Item submitted
    private static testmethod void testGetCaseItems1() {
        Case objCase;
        String dashboardJSON;
        
        ///Submit a Worker Case Item
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        ///Call GetCaseItem as a Worker
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();
        
        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assertEquals(objWorkerUser.Id, objDashboardJSON.userId);
        System.assertEquals(0, objDashboardJSON.draftCaseItems.size());
        System.assertEquals(0, objDashboardJSON.pendingCaseItems.size());
        System.assertEquals(1, objDashboardJSON.openCaseItems.size());
        System.assertEquals(objCase.Id, objDashboardJSON.openCaseItems[0].caseId);
        System.assertEquals(objCase.CaseNumber, objDashboardJSON.openCaseItems[0].caseNumber);
        System.assertEquals(objWorkerUser.Contact.Name, objDashboardJSON.openCaseItems[0].submittedBy);
        System.assertEquals(objCase.Status, objDashboardJSON.openCaseItems[0].status);
        System.assert(String.isBlank(objDashboardJSON.openCaseItems[0].communityPageURL));
        System.assert(String.isBlank(objDashboardJSON.openCaseItems[0].remainingTimeToExpire));
    }
    
    ///Tests GetCaseItems as an Insurer for Worker Case Item submitted
    private static testmethod void testGetCaseItems2() {
        Case objCase;
        String dashboardJSON;
        
        ///Submit a Worker Case Item
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSubmitted();
        
        ///Call GetCaseItem as an Insurer
        Test.startTest();
        User objTriageUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleTriage And Contact.AccountId =: objCase.Insurer__c Limit 1];
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objTriageUser) {
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();
        
        TaskTemplate__c objInsurerReplyTemplate = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.InsurerReplyTaskType);
        
        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assertEquals(objTriageUser.Id, objDashboardJSON.userId);
        System.assertEquals(0, objDashboardJSON.draftCaseItems.size());
        System.assertEquals(0, objDashboardJSON.pendingCaseItems.size());
        System.assertEquals(0, objDashboardJSON.openCaseItems.size());
    }
    
    ///Tests GetCaseItems as a Worker for Insurer Case Item submitted
    private static testmethod void testGetCaseItems3() {
        Case objCase;
        String dashboardJSON;
        
        ///Submit an Insurer Case Item
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        ///Call GetCaseItem as a Worker
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();
        
        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assertEquals(objWorkerUser.Id, objDashboardJSON.userId);
        System.assertEquals(0, objDashboardJSON.draftCaseItems.size());
        System.assertEquals(0, objDashboardJSON.pendingCaseItems.size());
        System.assertEquals(1, objDashboardJSON.openCaseItems.size());
        System.assertEquals(objCase.Id, objDashboardJSON.openCaseItems[0].caseId);
        System.assertEquals(objCase.CaseNumber, objDashboardJSON.openCaseItems[0].caseNumber);
        System.assertEquals(objWorkerUser.Contact.Name, objDashboardJSON.openCaseItems[0].submittedBy);
        System.assertEquals(objCase.Status, objDashboardJSON.openCaseItems[0].status);
        System.assert(String.isBlank(objDashboardJSON.openCaseItems[0].communityPageURL));
        System.assert(String.isBlank(objDashboardJSON.openCaseItems[0].remainingTimeToExpire));
    }
    
    ///Tests GetCaseItems as an Insurer for Insurer Case Item submitted
    private static testmethod void testGetCaseItems4() {
        Case objCase;
        String dashboardJSON;
        
        ///Submit an Insurer Case Item
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
        
        ///Call GetCaseItem as an Insurer
        Test.startTest();
        User objTriageUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleTriage And Contact.AccountId =: objCase.Insurer__c Limit 1];
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objTriageUser) {
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();
        
        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assertEquals(objTriageUser.Id, objDashboardJSON.userId);
        System.assertEquals(0, objDashboardJSON.draftCaseItems.size());
        System.assertEquals(0, objDashboardJSON.pendingCaseItems.size());
        System.assertEquals(1, objDashboardJSON.openCaseItems.size());
        System.assertEquals(objCase.Id, objDashboardJSON.openCaseItems[0].caseId);
        System.assertEquals(objCase.CaseNumber, objDashboardJSON.openCaseItems[0].caseNumber);
        System.assertEquals(objWorkerUser.Contact.Name, objDashboardJSON.openCaseItems[0].submittedBy);
        System.assertEquals(objCase.Status, objDashboardJSON.openCaseItems[0].status);
        System.assert(String.isBlank(objDashboardJSON.openCaseItems[0].communityPageURL));
        System.assert(String.isBlank(objDashboardJSON.openCaseItems[0].remainingTimeToExpire));
    }
    
    ///Tests GetCaseItems as a Worker for Worker Case Item "saved for later"
    private static testmethod void testGetCaseItems5() {
        Case objCase;
        String dashboardJSON;
        
        ///Save a Worker Case Item
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSaved();
        
        ///Call GetCaseItem as a Worker
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();
        
        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assertEquals(objWorkerUser.Id, objDashboardJSON.userId);
        System.assertEquals(1, objDashboardJSON.draftCaseItems.size());
        System.assertEquals(0, objDashboardJSON.pendingCaseItems.size());
        System.assertEquals(0, objDashboardJSON.openCaseItems.size());
        System.assertEquals(objCase.Id, objDashboardJSON.draftCaseItems[0].caseId);
        System.assertEquals(objCase.CaseNumber, objDashboardJSON.draftCaseItems[0].caseNumber);
        System.assertEquals(objWorkerUser.Contact.Name, objDashboardJSON.draftCaseItems[0].submittedBy);
        System.assertEquals(objCase.Status, objDashboardJSON.draftCaseItems[0].status);
        System.assert(String.isNotBlank(objDashboardJSON.draftCaseItems[0].communityPageURL));
        System.assert(String.isNotBlank(objDashboardJSON.draftCaseItems[0].remainingTimeToExpire));
    }
    
    ///Tests GetCaseItems as a Worker for Worker Case Item expired
    private static testmethod void testGetCaseItems6() {
        Case objCase;
        String dashboardJSON;
        
        ///Save a Worker Case Item
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSaved();
        
        ///Expire the saved Worker Case Item
        Test.startTest();
        for(CaseItem__c objCaseItem : objCase.CaseItems__r) {
            if(objCaseItem.Type__c == DRS_CaseService.WorkerCaseItemType) {
                objCaseItem.Status__c = DRS_CaseService.CaseItemStatusExpired;
                Update objCaseItem;
                break;
            }
        }
        
        ///Call GetCaseItem as a Worker
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();

        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assertEquals(objWorkerUser.Id, objDashboardJSON.userId);
        System.assertEquals(0, objDashboardJSON.draftCaseItems.size());
        System.assertEquals(0, objDashboardJSON.pendingCaseItems.size());
        System.assertEquals(0, objDashboardJSON.openCaseItems.size());
    }

    ///Tests GetCaseItems as a Worker for Case closed
    private static testmethod void testgetClosedCaseListJSON() {
        Case objCase;
        String dashboardJSON;
        
        ///Submit an Insurer Case Item
        objCase = DRS_TestData.createCaseWithInsurerCaseItemSubmitted();

        ///Update the status as Closed
        objCase.status = 'Closed';
        update objCase;
        
        ///Call GetCaseItem as a Worker
        Test.startTest();
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();

        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assert(objDashboardJSON != null);
        System.assertEquals(1, objDashboardJSON.closedCaseItems.size());
    }
    
    ///Tests DeleteDraftCaseItem as a Worker
    private static testmethod void testDeleteDraftCaseItem() {
        Case objCase;
        String dashboardJSON;
        
        ///Save a Worker Case Item
        objCase = DRS_TestData.createCaseWithWorkerCaseItemSaved();
        
        ///Call deleteDrafCaseItem as a Worker
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DRS_TestData.DRS_CalloutMock());
        User objWorkerUser = [Select Id, Contact.Name From User Where Contact.Role__c =: DRS_ContactService.ContactRoleWorker And ContactId =: objCase.ContactId Limit 1];
        System.runAs(objWorkerUser) {
            DRS_Dashboard_CC.deleteDrafCaseItem(objCase.Id);
            dashboardJSON = DRS_Dashboard_CC.getCaseItems();
        }
        Test.stopTest();
        
        ///Assert the returned arrays are as expected
        DRS_GlobalWrapper.DashboardJSON objDashboardJSON = (DRS_GlobalWrapper.DashboardJSON)JSON.deserialize(dashboardJSON, DRS_GlobalWrapper.DashboardJSON.class);
        System.assertEquals(objWorkerUser.Id, objDashboardJSON.userId);
        System.assertEquals(0, objDashboardJSON.draftCaseItems.size());
        System.assertEquals(0, objDashboardJSON.pendingCaseItems.size());
        System.assertEquals(0, objDashboardJSON.openCaseItems.size());
    }
}