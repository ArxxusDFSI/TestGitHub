@IsTest
public class DRS_UserManagement_CC_Test {
	
    @TestSetup
    private static void initializeData(){
        DRS_SetupData.processData();
    }
    
	private static testmethod void testIsDelegatedAdmin() {
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        Boolean isDelegatedAdmin = false;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	isDelegatedAdmin = DRS_UserManagement_CC.isDelegatedAdmin();
        }
        System.assertEquals(false, isDelegatedAdmin);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	isDelegatedAdmin = DRS_UserManagement_CC.isDelegatedAdmin();
        }
        System.assertEquals(true, isDelegatedAdmin);
	}
	
	private static testmethod void testGetUsersForAccount1() {
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String userJSONs;
        DRS_GlobalWrapper.AccountUserCollection objAccountUserCollection = new DRS_GlobalWrapper.AccountUserCollection();
        Boolean hasError = false;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		userJSONs = DRS_UserManagement_CC.getUsersForAccount();
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	userJSONs = DRS_UserManagement_CC.getUsersForAccount();
        }
        System.assert(String.isNotBlank(userJSONs));
        objAccountUserCollection = (DRS_GlobalWrapper.AccountUserCollection)JSON.deserialize(userJSONs, DRS_GlobalWrapper.AccountUserCollection.class);
        System.assert(objAccountUserCollection != null);
        System.assertEquals(2, objAccountUserCollection.activeUsers.size());
	}
    
    private static testmethod void testGetUsersForAccount2() {
        String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String userJSONs;
        DRS_GlobalWrapper.AccountUserCollection objAccountUserCollection = new DRS_GlobalWrapper.AccountUserCollection();
        Boolean hasError = false;
        String successMessage;
        
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        objUserJSON.title = 'Mr.';
        objUserJSON.userName = 'testing12345testing@testing.com';
        objUserJSON.firstName = 'Testing12345';
        objUserJSON.lastName = 'Testing12345';
        objUserJSON.emailAddress = 'testing12345testing@testing.com';
        objUserJSON.phone = '0400000001';
        objUserJSON.address = 'Address';
        objUserJSON.suburb = 'Suburb';
        objUserJSON.state = 'NSW';
        objUserJSON.postcode = '2000';
        objUserJSON.accountId = triageContact.AccountId;
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
            successMessage = DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        }
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		userJSONs = DRS_UserManagement_CC.getUsersForAccount();
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	userJSONs = DRS_UserManagement_CC.getUsersForAccount();
        }
        System.assert(String.isNotBlank(userJSONs));
        objAccountUserCollection = (DRS_GlobalWrapper.AccountUserCollection)JSON.deserialize(userJSONs, DRS_GlobalWrapper.AccountUserCollection.class);
        System.assert(objAccountUserCollection != null);
        System.assertEquals(2, objAccountUserCollection.activeUsers.size());
	}
	
	private static testmethod void testGetUserWithId() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String userJSON;
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        Boolean hasError = false;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		userJSON = DRS_UserManagement_CC.getUserWithId(DRS_ContactService.getUserForContact(triageContactId).Id);
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	try {
        		userJSON = DRS_UserManagement_CC.getUserWithId(DRS_ContactService.getUserForContact(triageContactId).Id);
        	}
        	catch(Exception excep) {
        		hasError = true;
        	}
        }
	}
	
	private static testmethod void testDeactivateUser() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		successMessage = DRS_UserManagement_CC.deactivateUser(DRS_ContactService.getUserForContact(triageContactId).Id);
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	successMessage = DRS_UserManagement_CC.deactivateUser(DRS_ContactService.getUserForContact(triageContactId).Id);
        }
        System.assert(String.isBlank(successMessage));
	}
	
	private static testmethod void testActivateUser() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		successMessage = DRS_UserManagement_CC.activateUser(DRS_ContactService.getUserForContact(triageContactId).Id);
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	successMessage = DRS_UserManagement_CC.activateUser(DRS_ContactService.getUserForContact(triageContactId).Id);
        }
        System.assert(String.isBlank(successMessage));
	}
	
	private static testmethod void testRegisterUser() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        objUserJSON.title = 'Mr.';
        objUserJSON.userName = 'testing12345testing@testing.com';
        objUserJSON.firstName = 'Testing12345';
        objUserJSON.lastName = 'Testing12345';
        objUserJSON.emailAddress = 'testing12345testing@testing.com';
        objUserJSON.phone = '0400000001';
        objUserJSON.address = 'Address';
        objUserJSON.suburb = 'Suburb';
        objUserJSON.state = 'NSW';
        objUserJSON.postcode = '2000';
        objUserJSON.accountId = triageContact.AccountId;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		successMessage = DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	successMessage = DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        }
        System.assertEquals('Success', successMessage);
	}
	
	private static testmethod void testResendActivationEmail() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        objUserJSON.title = 'Mr.';
        objUserJSON.userName = 'testing12345testing@testing.com';
        objUserJSON.firstName = 'Testing12345';
        objUserJSON.lastName = 'Testing12345';
        objUserJSON.emailAddress = 'testing12345testing@testing.com';
        objUserJSON.phone = '0400000001';
        objUserJSON.address = 'Address';
        objUserJSON.suburb = 'Suburb';
        objUserJSON.state = 'NSW';
        objUserJSON.postcode = '2000';
        objUserJSON.accountId = triageContact.AccountId;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		successMessage = DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        		successMessage = DRS_UserManagement_CC.resendActivationEmail(objUserJSON.emailAddress);
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	successMessage = DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        	successMessage = DRS_UserManagement_CC.resendActivationEmail(objUserJSON.emailAddress);
        }
        System.assertEquals('Success', successMessage);
	}
	
	private static testmethod void testResetPassword() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	successMessage = DRS_UserManagement_CC.resetPassword(DRS_ContactService.getUserForContact(triageContactId).Id);
        }
        System.assertEquals('Success', successMessage);
	}
	
	private static testmethod void testUpdateUser() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        objUserJSON.title = 'Mr.';
        objUserJSON.userName = 'testing12345testing@testing.com';
        objUserJSON.firstName = 'Testing12345';
        objUserJSON.lastName = 'Testing12345';
        objUserJSON.emailAddress = 'testing12345testing@testing.com';
        objUserJSON.phone = '0400000001';
        objUserJSON.address = 'Address';
        objUserJSON.suburb = 'Suburb';
        objUserJSON.state = 'NSW';
        objUserJSON.postcode = '2000';
        objUserJSON.accountId = triageContact.AccountId;
        objUserJSON.id = DRS_ContactService.getUserForContact(triageContactId).Id;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		successMessage = DRS_UserManagement_CC.updateUser(JSON.serialize(objUserJSON));
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	successMessage = DRS_UserManagement_CC.updateUser(JSON.serialize(objUserJSON));
        }
        System.assertEquals('', successMessage);
	}
	
	private static testmethod void testVerifyCode() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        objUserJSON.title = 'Mr.';
        objUserJSON.userName = 'testing12345testing@testing.com';
        objUserJSON.firstName = 'Testing12345';
        objUserJSON.lastName = 'Testing12345';
        objUserJSON.emailAddress = 'testing12345testing@testing.com';
        objUserJSON.phone = '0400000001';
        objUserJSON.address = 'Address';
        objUserJSON.suburb = 'Suburb';
        objUserJSON.state = 'NSW';
        objUserJSON.postcode = '2000';
        objUserJSON.accountId = triageContact.AccountId;
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
            DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        }
        
        VerificationCode__c objVerificationCode = [Select Id, Code__c From VerificationCode__c Limit 1];
		successMessage = DRS_UserManagement_CC.verifyCode(objVerificationCode.Code__c);
        
        System.assertEquals('Success', successMessage);
	}
	
	private static testmethod void testActivateAccount() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        objUserJSON.title = 'Mr.';
        objUserJSON.userName = 'testing12345testing@testing.com';
        objUserJSON.firstName = 'Testing12345';
        objUserJSON.lastName = 'Testing12345';
        objUserJSON.emailAddress = 'testing12345testing@testing.com';
        objUserJSON.phone = '0400000001';
        objUserJSON.address = 'Address';
        objUserJSON.suburb = 'Suburb';
        objUserJSON.state = 'NSW';
        objUserJSON.postcode = '2000';
        objUserJSON.accountId = triageContact.AccountId;
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
            DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        }
        
        VerificationCode__c objVerificationCode = [Select Id, Code__c From VerificationCode__c Limit 1];
		successMessage = DRS_UserManagement_CC.activateAccount(objVerificationCode.Code__c, 'pass1word');
	}
	
	private static testmethod void testChangePassword() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        String successMessage;
        Boolean hasError = false;
        
        DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
        objUserJSON.title = 'Mr.';
        objUserJSON.userName = 'testing12345testing@testing.com';
        objUserJSON.firstName = 'Testing12345';
        objUserJSON.lastName = 'Testing12345';
        objUserJSON.emailAddress = 'testing12345testing@testing.com';
        objUserJSON.phone = '0400000001';
        objUserJSON.address = 'Address';
        objUserJSON.suburb = 'Suburb';
        objUserJSON.state = 'NSW';
        objUserJSON.postcode = '2000';
        objUserJSON.accountId = triageContact.AccountId;
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
            DRS_UserManagement_CC.registerUser(JSON.serialize(objUserJSON));
        }
        VerificationCode__c objVerificationCode = [Select Id, Code__c From VerificationCode__c Limit 1];
		DRS_UserManagement_CC.activateAccount(objVerificationCode.Code__c, 'pass1word');
		successMessage = DRS_UserManagement_CC.changePassword('pass1word', 'pass1word', 'pass2word');
        
        System.assert(String.isNotBlank(successMessage));
	}
	
	private static testmethod void testGetAvailableRoles() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        List<CaseTeamRoleAssociation__c> listCaseTeamRoleAssociation;
        String listCaseTeamRoleAssociationJSON;
        Boolean hasError = false;
        
        System.runAs(DRS_ContactService.getUserForContact(triageContactId)) {
        	try {
        		listCaseTeamRoleAssociationJSON = DRS_UserManagement_CC.getAvailableRoles();
        	}
        	catch(Exception excep) {
        		///Authorization Error
        		hasError = true;
        	}
        }
        System.assertEquals(true, hasError);
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	listCaseTeamRoleAssociationJSON = DRS_UserManagement_CC.getAvailableRoles();
        }
        
        listCaseTeamRoleAssociation = (List<CaseTeamRoleAssociation__c>)Json.deserialize(listCaseTeamRoleAssociationJSON, List<CaseTeamRoleAssociation__c>.class);
        System.assert(listCaseTeamRoleAssociation.size() > 0);
	}
	
	private static testmethod void testGetAccounts() {
		String triageContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleTriage, '', false);
        Contact triageContact = DRS_ContactService.getContactDetails(triageContactId);
        String adminContactId = DRS_TestData.createPortalAccountContactAndUser(DRS_AccountService.RecordTypeBusiness, DRS_AccountService.TypeInsurer, DRS_ContactService.ContactRoleAdministrator, triageContact.AccountId, true);
        List<Account> listAccounts;
        String listAccountsJSON;
        Boolean hasError = false;
        
        System.runAs(DRS_ContactService.getUserForContact(adminContactId)) {
        	listAccountsJSON = DRS_UserManagement_CC.getAccounts();
        }
        
        listAccounts = (List<Account>)Json.deserialize(listAccountsJSON, List<Account>.class);
        //System.assert(listAccounts.size() > 0);
	}
}