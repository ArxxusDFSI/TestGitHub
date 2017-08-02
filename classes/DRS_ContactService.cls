///The service class to facilitate Contact and User objects 
public class DRS_ContactService {
    ///Variable declarations
    public static final String ContactUnderscore = 'Contact_';
    public static final String VerificationTypeUserEmailVerificaitonReg = 'User Activation Code';
    public static final String ContactRoleWorker = 'Worker';
    public static final String ContactRoleTriage = 'Triage';
    public static final String ContactRoleClaimsManager = 'Claims Manager';
    public static final String ContactRoleAdministrator = 'Administrator';
    public static final String ContactRoleSolePractitioner = 'Sole Practitioner';
    public static final String ContactRoleLegalRep = 'Legal Rep';
    public static final String PermissionSetMRSWorker = 'MRS_Worker';
    public static final String PermissionSetMRSInsurer = 'MRS_InsureLegalRep';
    public static final String PermissionSetMRSInternalUser = 'MRS_InternalUser';
    public static final String PermissionSetDelegatedAdmin = 'MRS_DelegatedInsurerLegalRepAdmin';
    public static final String PermissionSetSolePractitioner = 'MRS_SolePractitioner';
    public static final String VerificationCodeAvailable = 'Available';
    public static final String VerificationCodeExpired = 'Expired';
    public static final String RecordTypeContact = 'DRS_Contact';
    
    ///Gets the Contact details for contactId
    public static Contact getContactDetails(String contactId) {
        return [
            Select Id, Name, FirstName, LastName, BirthDate, Phone, Email, 
            MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
            Role__c, InterpreterRequired__c, Language__c, KnownWorkerDisabilities__c,
            AccountId, Account.Type, Account.Name, AdminUser__c, Salutation, MobilePhone
            From Contact
            Where Id =: contactId
        ];
    }
    
    ///Gets the User details for the userId
    public static User getUserDetails(String userId) {
        return [
            Select Id, Name, ContactId, Contact.Role__c, Username, Email, IsActive, Address, FirstName, LastName, Phone,
            Street, City, State, PostalCode, Country, LastLoginDate, Contact.Account.Type, Contact.AccountId, Contact.Account.Name,
            Contact.Salutation, Contact.MobilePhone, MobilePhone, Contact.Email, Contact.FirstName, Contact.LastName,
            Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.Phone
            From User 
            Where Id =: userId
        ];
    }
    
    ///Gets the User for the contactId
    public static User getUserForContact(String contactId) {
        return [
            Select Id, Name, ContactId, Contact.Role__c, Username, Email, IsActive, Address, FirstName, LastName, Phone,
            Street, City, State, PostalCode, Country, LastLoginDate, Contact.Account.Type, Contact.AccountId, Contact.Account.Name,
            Contact.Salutation, Contact.MobilePhone, MobilePhone, Contact.Email, Contact.FirstName, Contact.LastName,
            Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.Phone
            From User
            Where ContactId =: contactId
        ];
    }
    
    ///Gets the Users for the provided list of Contacts
    public static List<User> getUsersForContacts(List<Contact> listContacts) {
        return [
            Select Id, Name, ContactId, Contact.Role__c, Username, Email, IsActive, Address, FirstName, LastName, Phone,
            Street, City, State, PostalCode, Country, LastLoginDate, Contact.Account.Type, Contact.AccountId, Contact.Account.Name,
            Contact.Salutation, Contact.MobilePhone, MobilePhone, Contact.Email, Contact.FirstName, Contact.LastName,
            Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.Phone
            From User 
            Where ContactId =: listContacts];
    }
    
    ///Gets the Contacts for parent Account
    /// Also gets Contacts for all (5 level deep) child accounts in Account hierarchy
    public static List<Contact> getContactsForAccount(String accountId) {
        List<Contact> listContacts = new List<Contact>();
        
        for(Contact objContact : [
            Select Id, AccountId, Account.Name
            From Contact
            Where AccountId =: accountId
            Or Account.ParentId =: accountId
            Or Account.Parent.ParentId =: accountId
            Or Account.Parent.Parent.ParentId =: accountId
            Or Account.Parent.Parent.Parent.ParentId =: accountId
        ]) {
            listContacts.add(objContact);
        }
        return listContacts;
    }
    
    ///Gets the users for provided Firstname and Lastname
    public static List<User> getUsersForPartialNames(String partialName) {
        if(String.isBlank(partialName) || partialName.length() < 3) {
            return new List<User>();
        }
        
        partialName = partialName + '%';
        return [
            Select Id, FirstName, LastName
            From User
            Where Profile.UserLicense.Name = 'Salesforce'
            And (FirstName Like: partialName Or LastName Like: partialName)
        ];
    }
    
    ///Gets the Contact for userId
    public static Contact getContactForUser(String userId) {
        User objUser = DRS_ContactService.getUserDetails(userId);
        
        Contact objContact = null;
        if(String.isNotBlank(objUser.ContactId)) {
            objContact = DRS_ContactService.getContactDetails(objUser.ContactId);
        }
        else {
            throw new DRS_GlobalException.DataNotFoundException('Unable to find Contact for the logged in user.');
        }
        return objContact;
    }
    
    ///Gets the Contact for the logged in User
    public static Contact getContactForUser() {
        User objUser =  DRS_ContactService.getUserDetails(UserInfo.getUserId());
        
        Contact objContact = null;
        if(String.isNotBlank(objUser.ContactId)) {
            objContact = DRS_ContactService.getContactDetails(objUser.ContactId);
        }
        else {
            throw new DRS_GlobalException.DataNotFoundException('Unable to find Contact for the logged in user.');
        }
        return objContact;
    }
    
    ///Gets the Contacts for the provided emailAddress
    public static List<Contact> getContactsWithEmail(String emailAddress) {
        return [
            Select Id, Email
            From Contact
            Where Email =: emailAddress];
    }
    
    ///Gets the Users for the provided emailAddress
    public static List<User> getUsersWithEmail(String emailAddress) {
        return [
            Select Id, Email
            From User
            Where Email =: emailAddress];
    }
    
    ///Gets the Users for a Username, the method will return maximum 1 row, the list is used to avoid errors 
    public static List<User> getUsersWithUsername(String username) {
        return [
            Select Id, Email
            From User
            Where Username =: username];
    }
    
    ///Gets the Verificaiton Code for activationCode
    public static VerificationCode__c getVerificationCodeForCode(String activationCode) {
        return [
            Select Id, Contact__c, Status__c, Password__c
            From VerificationCode__c
            Where Code__c =: activationCode
            Limit 1
        ];
    }
    
    ///Gets the Contact using the activationCode
    public static Contact getContactForActivationCode(String activationCode) {
        ///Get the Verification Code record for the activationCode
        VerificationCode__c objVerificationCode = DRS_ContactService.getVerificationCodeForCode(activationCode);
        
        ///Check the Status of the Activation Code
        /// If the code has not expired, get the Contact details
        /// Otherwise throw an exception
        if(objVerificationCode.Status__c != null && objVerificationCode.Contact__c != null) {
            if(objVerificationCode.Status__c == DRS_ContactService.VerificationCodeAvailable) {
                return DRS_ContactService.getContactDetails(objVerificationCode.Contact__c);
            }
            else {
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.VerificationCodeExpired));
            }
        }
        return null;
    }
    
    ///Gets the list oF active Verification Codes with Contact details for the list of Contacts 
    public static List<VerificationCode__c> getContactsForAccountUsingVerificationCode(List<Contact> listContacts) {
        return [
            Select Id, Status__c, Contact__c, Contact__r.Name, Contact__r.Role__c, Contact__r.Email, 
            Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
            Contact__r.MailingCountry, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone, Contact__r.Salutation
            From VerificationCode__c
            Where Status__c =: DRS_ContactService.VerificationCodeAvailable
            And Contact__c =: listContacts
        ];
    }
    
    ///Gets the User with Contact details for the list of userIds
    public static List<User> getUserContactsForUsers(List<Id> listUserIds) {
        return [
            Select Id, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.BirthDate, Contact.Phone, Contact.Email, 
            Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry,
            Contact.Role__c, Contact.InterpreterRequired__c, Contact.Language__c, Contact.KnownWorkerDisabilities__c,
            Contact.AccountId, Contact.Account.Type, Contact.Account.Name, Contact.Salutation, City, State, PostalCode, Street, 
            FirstName, LastName, Phone, UserName, Name, MobilePhone, Contact.MobilePhone, Email
            From User
            Where Id =: listUserIds
        ];
    }
    
    ///Gets the Contact details for the list of contactIds
    public static List<Contact> getContactsForIds(List<Id> listContactIds) {
        return [
            Select Id, Name, FirstName, LastName, BirthDate, Phone, Email, 
            MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
            Role__c, InterpreterRequired__c, Language__c, KnownWorkerDisabilities__c,
            AccountId, Account.Type, Account.Name, Salutation, MobilePhone
            From Contact
            Where Id =: listContactIds
        ];
    }
    
    ///Gets the Triage Users for the Account 
    public static List<User> getTriageUsersForAccount(String accountId) {
        String soql = '' +
            'Select Id, Name, ContactId, Contact.Role__c, Username, Email, IsActive, Address, FirstName, LastName, Phone, ' +
            'Street, City, State, PostalCode, Country, LastLoginDate, Contact.Account.Type, Contact.AccountId, Contact.Account.Name, ' + 
            'Contact.Salutation, Contact.MobilePhone, MobilePhone, Contact.Email, Contact.FirstName, Contact.LastName, ' +
            'Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.Phone ' +
            'From User ' +
            'Where Contact.AccountId = \'' + accountId + '\' ' +
            'And Contact.Role__c Includes (\'' + DRS_ContactService.ContactRoleTriage + '\') ' + 
            'And IsActive = true';
        
        System.debug('---DRS_ContactService:getTriageUsersForAccount:soql:' + soql);
        return (List<User>)Database.query(soql);
    }
    
    ///Gets the Users for the Account
    /// Gets the users for all child accounts (5 level deep) in Account Hierarchy
    public static List<User> getUsersForAccount(String accountId) {
        List<Contact> listContacts = DRS_ContactService.getContactsForAccount(accountId);
        if(listContacts != null && listContacts.size() > 0) {
            return DRS_ContactService.getUsersForContacts(listContacts);
        }
        return null;
    }
    
    ///Gets the Contacts for AccountId for which the User activation is pending
    /// Gets the Contact for all child accounts (5 level deep) in Account Hierarchy
    public static List<Contact> getPendingContactsForAccount(String accountId) {
        List<Contact> listContacts = new List<Contact>();
        Contact objContact;
        
        List<Contact> listContact = DRS_ContactService.getContactsForAccount(accountId);
        
        for(VerificationCode__c objVerificationCode : DRS_ContactService.getContactsForAccountUsingVerificationCode(listContact)) {
            objContact = new Contact(
                Id = objVerificationCode.Contact__c, Salutation = objVerificationCode.Contact__r.Salutation,
                Role__c = objVerificationCode.Contact__r.Role__c, Email = objVerificationCode.Contact__r.Email,
                MailingStreet = objVerificationCode.Contact__r.MailingStreet, MailingCity = objVerificationCode.Contact__r.MailingCity,
                MailingState = objVerificationCode.Contact__r.MailingState, MailingCountry = objVerificationCode.Contact__r.MailingCountry,
                FirstName = objVerificationCode.Contact__r.FirstName, LastName = objVerificationCode.Contact__r.LastName,
                Phone = objVerificationCode.Contact__r.Phone);
            listContacts.add(objContact);
        }
        return listContacts;
    }
    
    ///Gets ther Users for Account with all child accounts (4 level deep) in Account Hierarchy
    public static User getUsersForAccountWithId(String accountId, String userId) {
        return [
            Select Id, Name, ContactId, Contact.Role__c, Username, Email, IsActive, Address, FirstName, LastName, Phone,
            Street, City, State, PostalCode, Country, LastLoginDate, Contact.Account.Type, Contact.AccountId, Contact.Account.Name,
            Contact.Salutation, Contact.MobilePhone, MobilePhone, Contact.Email, Contact.FirstName, Contact.LastName,
            Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.Phone
            From User
            Where Id =: userId 
            And (Contact.AccountId =: accountId
                 Or Contact.Account.ParentId =: accountId
                 Or Contact.Account.Parent.ParentId =: accountId
                 Or Contact.Account.Parent.Parent.ParentId =: accountId)
        ];
    }
    
    ///Gets whether the logged in user is a Salesforce Internal User
    public static boolean isSalesforceInternalUser(String userId) {
        for(User objUser : [
            Select Id
            From User 
            Where Profile.UserLicense.Name = 'Salesforce'
            And Id =: userId]) {
                return true;
            }
        return false;   
    }
    
    ///Gets whether the logged in user is a Worker User
    public static Boolean isWorkerUser(String userId) {
        Contact objContact = DRS_ContactService.getContactForUser(userId);
        if(objContact.Role__c == DRS_ContactService.ContactRoleWorker ||
           objContact.Role__c == DRS_ContactService.ContactRoleSolePractitioner) {
               return true;
           }
        return false;
    }
    
    ///Gets all the Permission Sets assigned to the userId
    public static List<String> getPermissionSetsForUser(String userId) {
        List<String> listPermissionSetNames = new List<String>();
        for(PermissionSetAssignment objPermissionSetAssignment : [
            Select Id, AssigneeId, PermissionSet.Name
            From PermissionSetAssignment 
            Where AssigneeId =: userId]) {
                listPermissionSetNames.add(objPermissionSetAssignment.PermissionSet.Name);
            }
        return listPermissionSetNames;
    }
    
    ///Gets whether the logged in user has a Delegated Administrator permission set assigned to it
    public static Boolean isDelegatedAdmin(String userId) {
        List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>([
            Select Id, AssigneeId, PermissionSet.Name 
            From PermissionSetAssignment 
            Where PermissionSet.Name =: DRS_ContactService.PermissionSetDelegatedAdmin 
            And AssigneeId =: userId]);
        if(listPermissionSetAssignment != null && listPermissionSetAssignment.size() > 0) {
            return true;
        }
        else if(Test.isRunningTest() && DRS_TestData.communityAdminUser != null && DRS_TestData.communityAdminUser.Id == userId) {
            return true;
        }
        return false;
    }
    
    ///Gets the Verification Codes for the Contact that were created numberOfMinutes ago
    public static List<VerificationCode__c> getLastVerificationCodesForContactForXMinutes(String contactId, Integer numberOfMinutes) {
        return [
            Select Id, Status__c, CreatedDate
            From VerificationCode__c
            Where Contact__c =: contactId
            And Type__c =: DRS_ContactService.VerificationTypeUserEmailVerificaitonReg
            And CreatedDate >=: Datetime.now().addMinutes(numberOfMinutes * -1)
            Order By CreatedDate Desc
            Limit 5000
        ];
    }
    
    ///Expires all the Verification Codes for contactId
    public static void expireActivationCodesForContact(String contactId) {
        List<VerificationCode__c> listVerificationCode = [
            Select Id
            From VerificationCode__c
            Where Contact__c =: contactId
            And Status__c =: DRS_ContactService.VerificationCodeAvailable
            And Type__c =: DRS_ContactService.VerificationTypeUserEmailVerificaitonReg
        ];
        for(VerificationCode__c objVerificationCode : listVerificationCode) {
            objVerificationCode.Status__c = DRS_ContactService.VerificationCodeExpired;
        }
        Update listVerificationCode;
    }
    
    ///Expires the Verification Code for the provided activationCode
    public static void expireActivationCode(String activationCode) {
        VerificationCode__c objVerificationCode = DRS_ContactService.getVerificationCodeForCode(activationCode);
        
        if(objVerificationCode.Status__c != null && objVerificationCode.Contact__c != null) {
            objVerificationCode.Status__c = DRS_ContactService.VerificationCodeExpired;
            Update objVerificationCode;
        }
    }
    
    ///Creates an Account and Contact with the provided details
    public static String createCommunityContactAndAccount(
        String salutation,
        String firstName, String lastName, String birthDate, String phone, String emailAddress, 
        String mailingStreet, String mailingCity, String mailingState, String mailingPostalCode, 
        String role, String accountId, Boolean adminUser, String identificationNumber, 
        String identificationValidFrom, String identificationValidTo)
    {
        ///Initialise variables
        Configuration__c objMRSConfiguration = DRS_GlobalUtility.getMRSConfiguration();
        Map<String,Id> mapRecordTypes = DRS_GlobalUtility.getRecordTypes();
        
        ///If accountId is not provided, create a new Account
        if(String.isBlank(accountId)) {
            Account objAccount = new Account(
                Name = firstName + ' ' + lastName + ' ' + emailAddress,
                OwnerId = objMRSConfiguration.CommunityAccountOwner__c,
                RecordTypeId = mapRecordTypes.get(DRS_AccountService.AccountUnderscore + DRS_AccountService.RecordTypeIndividual),
                Type = (role == DRS_ContactService.ContactRoleSolePractitioner ? DRS_AccountService.TypeSolePractitioner : DRS_AccountService.TypeWorkerWorkerRep)
            );
            Insert objAccount;
            accountId = objAccount.Id;
        }
        
        ///Create the Contact
        Contact objContact = new Contact(
            RecordTypeId = mapRecordTypes.get(DRS_ContactService.ContactUnderscore + DRS_ContactService.RecordTypeContact),
            AccountId = accountId,
            Role__c = role,
            Salutation = salutation,
            FirstName = firstName,
            LastName = lastName,
            BirthDate = (String.isNotBlank(birthDate) ? Date.parse(birthDate) : null),
            Phone = phone,
            Email = emailAddress,
            MailingStreet = mailingStreet,
            MailingCity = mailingCity,
            MailingState = mailingState,
            MailingPostalCode = mailingPostalCode,
            AdminUser__c = adminUser
        );
        
        if(String.isNotBlank(identificationNumber)) {
            objContact.IdentificationNumber__c = identificationNumber;
        }
        if(String.isNotBlank(identificationValidFrom)) {
            objContact.IdentificationValidFrom__c = DRS_GlobalUtility.getDateFromString(identificationValidFrom);
        }
        if(String.isNotBlank(identificationValidTo)) {
            objContact.IdentificationValidTo__c = DRS_GlobalUtility.getDateFromString(identificationValidTo);
        }
        
        Insert objContact;
        return objContact.Id;
    }
    
    ///Updates the Contact and User records for the provided email address
    public static void updateProfile(String salutation,
        String firstName, String lastName, String birthDate, String phone, 
        String mailingStreet, String mailingCity, String mailingState, String mailingPostalCode, 
        String interpreterRequired, String language, string disabilities,
        String emailAddress, String role, String userId, String contactId) 
    {
        if(String.isBlank(emailAddress)) {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.EmailAddressBlank));
        }
        System.debug('---DRS_ContactService:updateProfile:userId:' + userId);
        System.debug('---DRS_ContactService:updateProfile:contactId:' + contactId);
        System.debug('---DRS_ContactService:updateProfile:emailAddress:' + emailAddress);
        
        ///Get the users with Email Address
        List<User> existingUsersWithEmail = DRS_ContactService.getUsersWithEmail(emailAddress);
        System.debug('---DRS_ContactService:updateProfile:existingUsersWithEmail:' + existingUsersWithEmail);
        
        ///If the provided email address already exists, throw an exception
        if(existingUsersWithEmail != null && existingUsersWithEmail.size() > 0 && existingUsersWithEmail[0].Id != userId) {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.EmailAlreadyExists, new String[]{emailAddress}));
        }
        
        ///Update the Contact and User records with the provided details
        Contact objContact;
        if(String.isNotBlank(userId)) {
        	objContact = DRS_ContactService.getContactForUser(userId);
        }
        else {
        	objContact = DRS_ContactService.getContactDetails(contactId);
        }
        if(objContact != null) {
            if(String.isNotBlank(role)) {
                objContact.Role__c = role;
            }
            objContact.Salutation = salutation;
            objContact.FirstName = firstName;
            objContact.LastName = lastName;
            if(String.isNotBlank(birthDate)) {
                objContact.BirthDate = Date.parse(birthDate);
            }
            objContact.Phone = phone;
            objContact.MailingStreet = mailingStreet;
            objContact.MailingCity = mailingCity;
            objContact.MailingState = mailingState;
            objContact.MailingPostalCode = mailingPostalCode;
            if(String.isNotBlank(interpreterRequired)) {
                objContact.InterpreterRequired__c = interpreterRequired;
            }
            if(String.isNotBlank(language)) {
                objContact.Language__c = language;
            }
            if(String.isNotBlank(disabilities)) {
                objContact.KnownWorkerDisabilities__c = disabilities;
            }
            objContact.Email = emailAddress;
            Update objContact;
            
            if(String.isNotBlank(userId)) {
	            User objUser = new User();
	            objUser.Id = userId;
	            objUser.FirstName = firstName;
	            objUser.LastName = lastName;
	            objUser.Phone = phone;
	            objUser.Street = mailingStreet;
	            objUser.City = mailingCity;
	            objUser.State = mailingState;
	            objUser.PostalCode = mailingPostalCode;
	            objUser.Email = emailAddress;
	            Update objUser;
                DRS_ContactService.updateUsername(userId, emailAddress);
            }
        }
    }
    
    @Future
    public static void updateUsername(String userId, string username) {
        User objUser = new User(Id = userId, Username = username);
        Update objUser;
    }
    
    ///Gets whether the userId provided is a Super Admin
    public static Boolean isSuperAdmin(String userId) {
        Contact objContact = DRS_ContactService.getContactForUser();
        List<Contact> listContacts = DRS_ContactService.getContactsForAccount(objContact.AccountId);
        Boolean isSuperAdmin = false;
        for(Contact checkContact : listContacts) {
            if(checkContact.AccountId != objContact.AccountId) {
                isSuperAdmin = true;
                break;
            }
        }
        return isSuperAdmin;
    }
    
    ///Copies the Contacts' Lastname field to Contacts' Cases
    ///	This field is required on Case as a Text field and cannot be a formual field
    //	This field is used in aggregate functions for duplicate checking
    public static List<SObject> updateContactLastNameOnCases(String stringMapOldContacts, String stringMapNewContacts) {
        ///Initialize variables
        Boolean isDelete = false;
        List<Case> listCasesToUpdate = new List<Case>();
        
        try {
            ///Deserialze maps
            Map<Id,Contact> mapOldContacts = (Map<Id,Contact>)JSON.deserialize(stringMapOldContacts, Map<Id,Contact>.class);
            Map<Id,Contact> mapNewContacts = (Map<Id,Contact>)JSON.deserialize(stringMapNewContacts, Map<Id,Contact>.class);
            Map<String,Id> mapRecordTypes = DRS_GlobalUtility.getRecordTypes();
            
            ///If the method is called in a Delete context, initialize the newMap
            if(mapNewContacts == null) {
                mapNewContacts = new Map<Id,Contact>();
                isDelete = true;
            }
            List<Id> listUpdatedLastNameIds = new List<Id>();
            for(Contact objContact : mapOldContacts.values()) {
                if(objContact.RecordTypeId == mapRecordTypes.get(DRS_ContactService.ContactUnderscore + DRS_ContactService.RecordTypeContact)) {
                    if((mapNewContacts.containsKey(objContact.Id) && objContact.LastName != mapNewContacts.get(objContact.Id).LastName) ||
                       (isDelete))
                    {
                        listUpdatedLastNameIds.add(objContact.Id);
                    }
                }
            }
            
            for(Case objCase : [
                Select Id, DRS_ContactLastName__c, ContactId
                From Case
                Where ContactId =: listUpdatedLastNameIds
            ]) {
                if(isDelete && String.isNotBlank(objCase.DRS_ContactLastName__c)) {
                    objCase.DRS_ContactLastName__c = '';
                    listCasesToUpdate.add(objCase);
                }
                else if (objCase.DRS_ContactLastName__c != mapNewContacts.get(objCase.ContactId).LastName) {
                    objCase.DRS_ContactLastName__c = mapNewContacts.get(objCase.ContactId).LastName;
                    listCasesToUpdate.add(objCase);
                }
            }
        }
        catch(Exception excep) {
            DRS_GlobalUtility.handleServiceException(excep, 'DRS_CaseService', 'markCaseItemTasksAsCompleted');
        }
        
        return listCasesToUpdate;
    }
    
    ///Gets Contact merge fields for MRS emails
    public static Map<String,String> getContactMergeFields(Contact objContact) {
    	Map<String,String> mapMergeFields = new Map<String,String>();
    	
    	String address = '';
    	String contactName = '';
    	
    	if(String.isNotBlank(objContact.Name)) { 
    		mapMergeFields.put('{Contact.Name}', DRS_GlobalUtility.getStringValue(objContact.Name));
    	}
    	else {
    		if(String.isNotBlank(objContact.FirstName)) {
    			contactName += objContact.FirstName + ' ';
    		}
    		contactName += objContact.LastName;
    		mapMergeFields.put('{Contact.Name}', DRS_GlobalUtility.getStringValue(contactName));
    	}
    	
    	mapMergeFields.put('{Contact.Salutation}', DRS_GlobalUtility.getStringValue(objContact.Salutation));
    	mapMergeFields.put('{Contact.FirstName}', DRS_GlobalUtility.getStringValue(objContact.FirstName));
    	mapMergeFields.put('{Contact.LastName}', DRS_GlobalUtility.getStringValue(objContact.LastName));
    	mapMergeFields.put('{Contact.Phone}', DRS_GlobalUtility.getStringValue(objContact.Phone));
    	mapMergeFields.put('{Contact.MobilePhone}', DRS_GlobalUtility.getStringValue(objContact.MobilePhone));
    	mapMergeFields.put('{Contact.MailingStreet}', DRS_GlobalUtility.getStringValue(objContact.MailingStreet));
    	mapMergeFields.put('{Contact.MailingCity}', DRS_GlobalUtility.getStringValue(objContact.MailingCity));
    	mapMergeFields.put('{Contact.MailingState}', DRS_GlobalUtility.getStringValue(objContact.MailingState));
    	mapMergeFields.put('{Contact.MailingPostalCode}', DRS_GlobalUtility.getStringValue(objContact.MailingPostalCode));
    	
    	if(String.isNotBlank(objContact.MailingStreet)) {
    		address = objContact.MailingStreet;
    	}
    	if(String.isNotBlank(objContact.MailingCity)) {
    		address += '\n' + objContact.MailingCity;
    	}
    	if(String.isNotBlank(objContact.MailingState)) {
    		if(String.isNotBlank(objContact.MailingCity)) {
    			address += ', ';
    		}
    		else {
    			address += '\n';
    		}
    		address += objContact.MailingState;
    	}
    	if(String.isNotBlank(objContact.MailingPostalCode)) {
    		if(String.isNotBlank(objContact.MailingState)) {
    			address += ' ';
    		}
    		else if(String.isNotBlank(objContact.MailingCity)) {
    			address += ', ';
    		}
    		else {
    			address += '\n ';
    		}
    		
    		address += objContact.MailingPostalCode;
    	}
    	
    	mapMergeFields.put('{Contact.MailingAddress}', DRS_GlobalUtility.getStringValue(address));
    	return mapMergeFields;
    }
    
    ///Gets Contact object from User
    public static Contact getContactObjectFromUser(User objUser) {
    	Contact objContact = new Contact();
    	if(String.isNotBlank(objUser.ContactId)) {
	    	objContact.Id = objUser.ContactId;
	    	objContact.Email = objUser.Contact.Email;
	    	objContact.Salutation = objUser.Contact.Salutation;
	    	objContact.FirstName = objUser.Contact.FirstName;
	    	objContact.LastName = objUser.Contact.LastName;
	    	objContact.Phone = objUser.Contact.Phone;
	    	objContact.MobilePhone = objUser.Contact.MobilePhone;
	    	objContact.MailingStreet = objUser.Contact.MailingStreet;
	    	objContact.MailingCity = objUser.Contact.MailingCity;
	    	objContact.MailingState = objUser.Contact.MailingState;
	    	objContact.MailingPostalCode = objUser.Contact.MailingPostalCode;
    	}
    	else {
	    	objContact.Email = objUser.Email;
	    	objContact.FirstName = objUser.FirstName;
	    	objContact.LastName = objUser.LastName;
	    	objContact.Phone = objUser.Phone;
	    	objContact.MobilePhone = objUser.MobilePhone;
	    	objContact.MailingStreet = objUser.Street;
	    	objContact.MailingCity = objUser.City;
	    	objContact.MailingState = objUser.State;
	    	objContact.MailingPostalCode = objUser.PostalCode;
    	}
    	return objContact;
    }
}