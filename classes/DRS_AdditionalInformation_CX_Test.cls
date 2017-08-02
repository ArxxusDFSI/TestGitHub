@IsTest
public class DRS_AdditionalInformation_CX_Test {
    
    @TestSetup
    private static void initializeData(){
        DRS_SetupData.processData();
        DRS_TestData.createCaseWithInsurerCaseItemSubmitted();
    }
    
    private static testmethod void testConstructor() {
        Case objCase = [Select Id From Case];
        PageReference additionalInfoPage = Page.DRS_Case_AdditionalInformationCreate;
        Test.setCurrentPage(additionalInfoPage);
        
        Test.startTest();
        ApexPages.StandardController objStandardController = new ApexPages.StandardController(objCase);
        DRS_AdditionalInformation_CX objDRS_AdditionalInformation_CX = new DRS_AdditionalInformation_CX(objStandardController);
        Test.stopTest();
        
        TaskTemplate__c objTaskTemplate = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.AdditionalInformationTaskType);
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        
        System.assert(objDRS_AdditionalInformation_CX.objtask != null);
        System.assertEquals(objCase.Id, objDRS_AdditionalInformation_CX.objTask.WhatId);
        System.assertEquals(null, objDRS_AdditionalInformation_CX.objTask.Subject); ///Subject is set in the trigger after Task is saved
        System.assertEquals(null, objDRS_AdditionalInformation_CX.objTask.Type); ///Type is set in the trigger after Task is saved
        System.assertEquals(objMRSConfiguration.DefaultTaskOwner__c, objDRS_AdditionalInformation_CX.objTask.OwnerId);
        System.assertEquals(true, objDRS_AdditionalInformation_CX.objTask.IsReminderSet);
        System.assertEquals(DRS_CaseService.InitialTaskStatus, objDRS_AdditionalInformation_CX.objTask.Status);
    }
    
    private static testmethod void testSave() {
        Case objCase = [Select Id From Case];
        PageReference additionalInfoPage = Page.DRS_Case_AdditionalInformationCreate;
        Test.setCurrentPage(additionalInfoPage);
        String taskDescription = 'My Task Description';
        String roleGroup = 'Insurer';
        
        Test.startTest();
        ApexPages.StandardController objStandardController = new ApexPages.StandardController(objCase);
        DRS_AdditionalInformation_CX objDRS_AdditionalInformation_CX = new DRS_AdditionalInformation_CX(objStandardController);
        objDRS_AdditionalInformation_CX.objTask.Description = taskDescription;
        objDRS_AdditionalInformation_CX.objCaseItem.RoleGroup__c = roleGroup;
        objDRS_AdditionalInformation_CX.saveAdditionalInformation();
        Test.stopTest();
        
        CaseItem__c objCaseItem = [Select Id, Status__c, RoleGroup__c, CaseItemData__c From CaseItem__c Where Type__c =: DRS_CaseService.AdditionalInformationTaskType And Case__c =: objCase.Id Limit 1];
        System.assert(objCaseItem != null);
        System.assertEquals(roleGroup, objCaseItem.RoleGroup__c);
        System.assertEquals(DRS_CaseService.CaseItemStatusPending, objCaseItem.Status__c);
        DRS_GlobalWrapper.AdditionalInformationJSON objAdditionalInformationJSON = (DRS_GlobalWrapper.AdditionalInformationJSON)JSON.deserialize(objCaseItem.CaseItemData__c, DRS_GlobalWrapper.AdditionalInformationJSON.class);
        System.assertEquals(taskDescription, objAdditionalInformationJSON.requestDetails);
        
        TaskTemplate__c objTaskTemplate = DRS_CaseService.getTaskTemplateForType(DRS_CaseService.AdditionalInformationTaskType);
        Task objTask = [Select Id, Description, Type, Subject From Task Where CaseItem__c =: objCaseItem.Id];
        System.assertEquals(objTaskTemplate.Subject__c, objTask.Subject); ///Subject is set in the trigger using values from Task Template
        System.assertEquals(objTaskTemplate.Type__c, objTask.Type); ///Type is set in the trigger using values from Task Template
        System.assertEquals(objTaskTemplate.Description__c, objTask.Description); ///Description is set in the trigger using values from Task Template
    }
    
}