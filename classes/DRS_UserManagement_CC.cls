public without sharing class DRS_UserManagement_CC {
    
    @AuraEnabled
    public static Boolean isDelegatedAdmin() {
        return DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId());
    }
    
    @AuraEnabled
    public static String getUsersForAccount() {
        try {
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                Contact objContact = DRS_ContactService.getContactForUser(UserInfo.getUserId());
                List<User> listUsers = DRS_ContactService.getUsersForAccount(objContact.AccountId);
                List<Contact> listContacts = DRS_ContactService.getPendingContactsForAccount(objContact.AccountId);
                
                DRS_GlobalWrapper.AccountUserCollection objAccountUserCollection = new DRS_GlobalWrapper.AccountUserCollection();
                objAccountUserCollection.activeUsers = new List<DRS_GlobalWrapper.UserJSON>();
                objAccountUserCollection.inActiveUsers = new List<DRS_GlobalWrapper.UserJSON>();
                objAccountUserCollection.pendingUsers = new List<DRS_GlobalWrapper.UserJSON>();
                DRS_GlobalWrapper.UserJSON objUserJSON;
                for(User objUser : listUsers) {
                    objUserJSON = new DRS_GlobalWrapper.UserJSON();
                    objUserJSON.id = objUser.Id;
                    objUserJSON.firstName = objUser.FirstName;
                    objUserJSON.lastName = objUser.LastName;
                    objUserJSON.emailAddress = objUser.Email;
                    objUserJSON.phone = objUser.Phone;
                    objUserJSON.address = objUser.Street;
                    objUserJSON.suburb = objUser.City;
                    objUserJSON.state = objUser.State;
                    objUserJSON.postcode = objuser.PostalCode;
                    objUserJSON.lastLoginDateTime = objuser.LastLoginDate != null ? objuser.LastLoginDate.format(DRS_GlobalUtility.DateTimeFormat) : '';
                    objUserJSON.role = objUser.Contact.Role__c;
                    objUserJSON.accountId = objUser.Contact.AccountId;
                    objUserJSON.accountName = objUser.Contact.Account.Name;
                    if(objUser.isActive) {
                        objAccountUserCollection.activeUsers.add(objUserJSON);
                    }
                    else {
                        objAccountUserCollection.inActiveUsers.add(objUserJSON);
                    }
                }
                
                for(Contact objPendingUser : listContacts) {
                    objUserJSON = new DRS_GlobalWrapper.UserJSON();
                    objUserJSON.id = null;
                    objUserJSON.firstName = objPendingUser.FirstName;
                    objUserJSON.lastName = objPendingUser.LastName;
                    objUserJSON.emailAddress = objPendingUser.Email;
                    objUserJSON.phone = objPendingUser.Phone;
                    objUserJSON.address = objPendingUser.MailingStreet;
                    objUserJSON.suburb = objPendingUser.MailingCity;
                    objUserJSON.state = objPendingUser.MailingState;
                    objUserJSON.postcode = objPendingUser.MailingPostalCode;
                    objUserJSON.role = objPendingUser.Role__c;
                    objUserJSON.contactId = objPendingUser.Id;
                    objAccountUserCollection.pendingUsers.add(objUserJSON);
                }
                
                System.debug('---DRS_UserManagement_CC:getUsersForAccount:objAccountUserCollection:' + JSON.serializePretty(objAccountUserCollection));
                return JSON.serialize(objAccountUserCollection);
            }
            else {
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'getUsersForAccount');
        }
    }
    
    @AuraEnabled
    public static String getUserWithId(String userId) {
        try{
        	System.debug('---DRS_UserManagement:getUserWithId:userId:' + userId);
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                Contact objContact = DRS_ContactService.getContactForUser(UserInfo.getUserId());
                DRS_GlobalWrapper.UserJSON objUserJSON = new DRS_GlobalWrapper.UserJSON();
                Boolean userWasNotFound = false;
                try {
                	User objUser = DRS_ContactService.getUsersForAccountWithId(objContact.AccountId, userId);
	                objUserJSON.id = objUser.Id;
	                objUserJSON.firstName = objUser.FirstName;
	                objUserJSON.lastName = objUser.LastName;
	                objUserJSON.emailAddress = objUser.Email;
	                objUserJSON.phone = objUser.Phone;
	                objUserJSON.address = objUser.Street;
	                objUserJSON.suburb = objUser.City;
	                objUserJSON.state = objUser.State;
	                objUserJSON.postcode = objuser.PostalCode;
	                objUserJSON.lastLoginDateTime = objuser.LastLoginDate != null ? objuser.LastLoginDate.format(DRS_GlobalUtility.DateTimeFormat) : '';
	                objUserJSON.role = objUser.Contact.Role__c;
	                objUserJSON.accountId = objUser.Contact.AccountId;
	                objUserJSON.accountName = objUser.Contact.Account.Name;
                }
                catch(Exception excep) {userWasNotFound = true; System.debug('---DRS_UserManagement:getUserWithId:exception:' + excep);} //Do Nothing, this is the case of user not yet created
                
                if(userWasNotFound) {
                    objContact = DRS_ContactService.getContactDetails(userId);
                    System.debug('---DRS_UserManagement:getUserWithId:objContact:' + objContact);
                    
                    objUserJSON.id = '';
                    objUserJSON.firstName = objContact.FirstName;
                    objUserJSON.lastName = objContact.LastName;
                    objUserJSON.emailAddress = objContact.Email;
                    objUserJSON.phone = objContact.Phone;
                    objUserJSON.address = objContact.MailingStreet;
                    objUserJSON.suburb = objContact.MailingCity;
                    objUserJSON.state = objContact.MailingState;
                    objUserJSON.postcode = objContact.MailingPostalCode;
                    objUserJSON.lastLoginDateTime = '';
                    objUserJSON.role = objContact.Role__c;
                    objUserJSON.accountId = objContact.AccountId;
                    objUserJSON.accountName = objContact.Account.Name;
                    objUserJSON.contactId = objContact.Id;
                }
                System.debug('---DRS_UserManagement_CC:getUserWithId:objUserJSON:' + JSON.serializePretty(objUserJSON));
                return JSON.serialize(objUserJSON);
            }
            else {
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'getUserWithId');
        }
    }
    
    @AuraEnabled
    public static String deactivateUser(String userId) {
        try{
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                User objUser = new User(
                    Id = userId,
                    IsActive = false
                );
                Update objUser;
            }
            else {
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'deactivateUser');
        }
        return '';
    }
    
    @AuraEnabled
    public static String activateUser(String userId) {
        try {
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                User objUser = new User(
                    Id = userId,
                    IsActive = true
                );
                Update objUser;
            }
            else {
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'activateUser');
        }
        return '';
    }
    
    @AuraEnabled
    public static String resendActivationEmail(String emailAddress) {
        List<Contact> existingContactsWithEmail = DRS_ContactService.getContactsWithEmail(emailAddress);
        try{
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                if(existingContactsWithEmail != null && existingContactsWithEmail.size() == 1) {
                    DRS_RegistrationService.sendActivationLinkEmail(existingContactsWithEmail[0].Id, null, DRS_RegistrationService.URLSuffixActivateWithPassword);
                }
                else {
                    throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.ExistingUserFound, new String[]{emailAddress}));
                }
            }
            else {
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'resendActivationEmail');
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static String resetPassword(String userId) {
        if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
            User objUser = DRS_ContactService.getUserDetails(userId);
            Site.forgotPassword(objUser.Username);
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static String updateUser(String userJSON) {
        System.debug('---DRS_UserManagement_CC:regiserUser:userJSON:' + userJSON);
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        String contactId;
        Boolean sendActivationEmail = false;
        DRS_GlobalWrapper.UserJSON objUserJSON = (DRS_GlobalWrapper.UserJSON)JSON.deserialize(userJSON, DRS_GlobalWrapper.UserJSON.class);
        
        try {
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                if(String.isBlank(objUserJSON.id)) {
                	contactId = objUserJSON.contactId;
                	Contact objContact = DRS_ContactService.getContactDetails(objUserJSON.contactId);
                	
	            	if(objContact.Email != objUserJSON.emailAddress) {
	            		sendActivationEmail = true;
                	}
                    System.debug('---DRS_UserManagement_CC:regiserUser:sendActivationEmail:' + sendActivationEmail);
                }
                
                DRS_ContactService.updateProfile(objUserJSON.title, objUserJSON.firstName, objUserJSON.lastName, null, objUserJSON.phone, 
                    objUserJSON.address, objUserJSON.address, objUserJSON.state, objUserJSON.postcode, 
                    null, null, null,
                    objUserJSON.emailAddress, objUserJSON.role, objUserJSON.id, contactId);
                    
                if(sendActivationEmail) {
            		DRS_RegistrationService.sendActivationLinkEmail(contactId, null, DRS_RegistrationService.URLSuffixActivateWithPassword);
                }
            }
            else {
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'updateUser');
        }
        return '';
    }
    
    @AuraEnabled
    public static String registerUser(String userJSON) {
        System.SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        System.debug('---DRS_UserManagement_CC:regiserUser:userJSON:' + userJSON);
        try {
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                DRS_GlobalWrapper.UserJSON objUserJSON = (DRS_GlobalWrapper.UserJSON)JSON.deserialize(userJSON, DRS_GlobalWrapper.UserJSON.class);
                Contact objContact = DRS_ContactService.getContactForUser();
                String accountId = objContact.AccountId;
                Boolean isSuperAdmin = DRS_ContactService.isSuperAdmin(UserInfo.getUserId());
                
                if(isSuperAdmin) {
                    accountId = objUserJSON.accountId;
                }
                
                DRS_RegistrationService.registerApplicant(
                    objUserJSON.title,
                    objUserJSON.firstName, objUserJSON.lastName, null, objUserJSON.phone, objUserJSON.emailAddress, 
                    objUserJSON.address, objUserJSON.suburb, objUserJSON.state, objUserJSON.postCode, null, 
                    objUserJSON.role, DRS_RegistrationService.URLSuffixActivateWithPassword, accountId, isSuperAdmin, 
                    null, null, null);
            }
            else {
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'registerUser');
        }
        return 'Success';
    }
    
    @AuraEnabled
    public static String verifyCode(String activationCode) {
        Contact objContact = DRS_ContactService.getContactForActivationCode(activationCode);
        if(objContact != null && String.isNotBlank(objContact.Email)) {
            return 'Success';
        }
        throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.InvalidActivationCode));
    }
    
    @AuraEnabled
    public static String activateAccount(String activationCode, String password) {
        Contact objContact = DRS_ContactService.getContactForActivationCode(activationCode);
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        
        if(objContact != null && String.isNotBlank(objContact.Email)) {
            try {
                DRS_RegistrationService.activateAccount(objContact.Id, password, objMRSConfiguration.ProfileId2__c);
                return Site.getBaseUrl();
            }
            catch(Exception excep) {
                System.debug('---DRS_UserManagement_CC:activateAccount:excep:' + excep);
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.ActivateApplicantError));
            }
        }
        throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.InvalidActivationCode));
    }
    
    @AuraEnabled
    public static String changePassword(String oldPassword, String newPassword, String verifyNewPassword) {
        try {
            Site.changePassword(newPassword, verifyNewPassword, oldPassword);
            return 'Success';
        }
        catch (Exception excep) {
            System.debug('---DRS_UserManagement_CC:changePassword:excep:' + excep);
            throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.ChangePasswordError));
        }
    }
    
    @AuraEnabled
    public static String getAvailableRoles() {
        try {
            if(DRS_ContactService.isDelegatedAdmin(UserInfo.getUserId())) {
                Contact objContact = DRS_ContactService.getContactForUser();
                List<CaseTeamRoleAssociation__c> listCaseTeamRoleAssociations = DRS_GlobalUtility.getCaseTeamRoleAssociationForAccountType(objContact.Account.Type);
                System.debug('---UserManagement:getAvailableRoles:listContacRoles:' + JSON.serializePretty(listCaseTeamRoleAssociations));
                return JSON.serialize(listCaseTeamRoleAssociations);
            }
            else 
                throw new AuraHandledException(DRS_MessageService.getMessage(DRS_MessageService.AuthorizationError));
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'UserManagement', 'getAvailableRoles');
        }
    }
    
    @AuraEnabled
    public static String getAccounts() {
        try {
            Contact objContact = DRS_ContactService.getContactForUser();
            List<Account> listAccounts = DRS_AccountService.getAccountsWithHierarchy(objContact.accountId);
            //List<Contact> listContacts = DRS_ContactService.getContactsForAccount(objContact.AccountId);
            List<DRS_GlobalWrapper.AccountJSON> listAccountJSONs = new List<DRS_GlobalWrapper.AccountJSON>();
            DRS_GlobalWrapper.AccountJSON objAccountJSON;
            
            Boolean isSuperAdmin = false;
            for(Account objAccount : listAccounts) {
                objAccountJSON = new DRS_GlobalWrapper.AccountJSON();
                objAccountJSON.id = objAccount.Id;
                objAccountJSON.name = objAccount.Name;
                listAccountJSONs.add(objAccountJSON);
                
                if(objContact.AccountId != objAccount.Id) {
                    isSuperAdmin = true;
                }
            }
            
            if(isSuperAdmin) {
                return JSON.serialize(listAccountJSONs);
            }
            else {
                return JSON.serialize(new List<DRS_GlobalWrapper.AccountJSON>());
            }
        }
        catch(Exception excep) {
            return DRS_GlobalUtility.handleAuraException(excep, 'DRS_UserManagement_CC', 'getAccounts');
        }
    }
    
}