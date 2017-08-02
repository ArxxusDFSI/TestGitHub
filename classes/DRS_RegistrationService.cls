///The service class to facilitate User management for communities
public class DRS_RegistrationService {
    ///Variable declarations
    public static final String URLSuffixActivateWithPassword = 'activatewithpassword';
    public static final String URLSuffixActivateAccount = 'activateAccount';
    public static final String EmailAccountVerificationEmail = 'DRS_AccountVerificationEmail';
    
    ///Creates Account and Contact when users register for community
    ///Sends activation email instead, if an Account and Contact exists
    public static String registerApplicant(String salutation,
        String firstName, String lastName, String birthDate, String phone, String emailAddress, 
        String mailingStreet, String mailingCity, String mailingState, String mailingPostalCode, 
        String password, String role, String activationURLSuffix, String accountId, Boolean delegatedAdmin,
        String identificationNumber, String identificationValidFrom, String identificationValidTo)
    {
        System.debug('---DRS_RegistrationService:registerApplicant:firstName:' + firstName + 
                     ', lastName:' + lastName + ', birthDate:' + birthDate + ', phone:' + phone +', emailAddress:' + emailAddress + 
                     ', mailingStreet:' + mailingStreet + ', mailingCity:' + mailingCity + ', mailingState:' + mailingState + 
                     ', mailingPostalCode:' + mailingPostalCode + ' , password:***, role:' + role + ', activationURLSuffix:' + activationURLSuffix +
                     ', accountId:' + accountId + ', delegatedAdmin:' + delegatedAdmin +  ', identificationNumber: ' + identificationNumber + 
                     ', identificationValidFrom:' + identificationValidFrom + ', identificationValidTo:' + identificationValidTo);
        
        ///Get existing users based on the email address provided by user
        ///If a user is found for the email address, throw an Existing User Found error
        List<User> existingUsersWithEmail = DRS_ContactService.getUsersWithUsername(emailAddress);
        if(existingUsersWithEmail != null && existingUsersWithEmail.size() > 0) {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.ExistingUserFound, new String[]{emailAddress}));
        }
        
        ///If user is not found but a Contact is found for the provided email address
        /// Check whether there is a user for the Contact
        ///     If a user is found for the Contact, throw an Existing User Found error
        /// Otherwise send an activation email to the Email Address provided
        List<Contact> existingContactsWithEmail = DRS_ContactService.getContactsWithEmail(emailAddress);
        if(existingContactsWithEmail != null && existingContactsWithEmail.size() > 0) {
            existingUsersWithEmail = DRS_ContactService.getUsersForContacts(existingContactsWithEmail);
            if(existingUsersWithEmail != null && existingUsersWithEmail.size() > 0) {
                throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.ExistingContactFoundWithUser, new String[]{existingUsersWithEmail[0].Email}));
            }
            
            DRS_RegistrationService.sendActivationLinkEmail(existingContactsWithEmail[0].Id, password, activationURLSuffix);
            return 'Success';
        }
        
        try {
            ///Create a community Account and Contact
            String contactId = DRS_ContactService.createCommunityContactAndAccount(
            	salutation,
                firstName, lastName, birthDate, phone, emailAddress, 
                mailingStreet, mailingCity, mailingState, mailingPostalCode, 
                role, accountId, delegatedAdmin, identificationNumber,
                identificationValidFrom, identificationValidTo);
            
            ///Send Activation Email to the Email Address            
            DRS_RegistrationService.sendActivationLinkEmail(contactId, password, activationURLSuffix);
        }
        catch(Exception excep) {
            System.debug('---DRS_RegistrationService:registerApplicant:excep:' + excep);
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.RegisterApplicantError));
        }
        return 'Success';
    }
    
    ///Sends activation email to the email address of the Contact 
    /// Creates a Verification Code and embeds that in the email 
    public static void sendActivationLinkEmail(String contactId, String password, String activationURLSuffix) {
        ///Check if there are more than 3 verification codes present for the email address in last 10 minutes
        /// Throw an exception if there are more than 3 verification codes 
        List<VerificationCode__c> listVerificationCodes = DRS_ContactService.getLastVerificationCodesForContactForXMinutes(contactId, 10);
        if(listVerificationCodes != null && listVerificationCodes.size() >= 3) {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.TooManyActivations));
        }
        
        ///Expire all existing verification codes for the Contact
        Contact objContact = DRS_ContactService.getContactDetails(contactId);
        DRS_ContactService.expireActivationCodesForContact(contactId);
        
        ///Create a new Verification Code
        String verificationCode = DRS_GlobalUtility.getGuid();
        VerificationCode__c objVerificationCode = new VerificationCode__c(
            Code__c = verificationCode,
            Contact__c = objContact.Id,
            Status__c = DRS_ContactService.VerificationCodeAvailable,
            Type__c = DRS_ContactService.VerificationTypeUserEmailVerificaitonReg,
            Password__c = password
        );
        Insert objVerificationCode;
        
        ///Formulate the link for the verification code and send the email
        String activationLink = Site.getBaseUrl() + '/s/' + activationURLSuffix + '?activationCode=' + verificationCode;
        Map<String,String> mapMergeFieldValues = new Map<String,String>();
        mapMergeFieldValues.put('{VerificationLink}', activationLink);
        Map<String,Map<String,String>> mapContactMergeFields = new Map<String,Map<String,String>>();
        mapContactMergeFields.put(objContact.Email, DRS_ContactService.getContactMergeFields(objContact));
        DRS_GlobalUtility.sendEmailUsingTemplate(DRS_RegistrationService.EmailAccountVerificationEmail, mapMergeFieldValues, new string[]{objContact.Email}, mapContactMergeFields);
    }
    
    ///Activates the community user by creating the User record for the Account and Contact
    public static void activateAccount(String contactId, String password, String profileId){
        Contact objContact = DRS_ContactService.getContactDetails(contactId);
        SavePoint savePointBeforeInsert = DRS_GlobalUtility.createSavePoint();
        
        try {
            ///Create the community user with provided profile
            User objUser =  new User(
                ProfileId = profileId,
                Username = objContact.Email,
                FirstName = objContact.FirstName,
                LastName = objContact.LastName,
                CommunityNickname =  objContact.Id + String.valueOf(Datetime.Now()),
                Email = objContact.Email,
                ContactId = objContact.Id,
                Alias = String.valueOf(objContact.Id).right(8), 
                TimeZoneSidKey = 'Australia/Sydney',
                LocaleSidKey = 'en_AU', 
                EmailEncodingKey = 'ISO-8859-1', 
                LanguageLocaleKey = 'en_US',
                Street = objContact.MailingStreet,
                City = objContact.MailingCity,
                State = objContact.MailingState,
                PostalCode = objContact.MailingPostalCode
            );
            
            System.debug('---DRS_RegistrationService:activateAccount:objUser: ' + objUser);
            
            ///Create portal user for the with account, user, and password
            String userId;
            if(!Test.isRunningTest()) {
                userId = Site.createPortalUser(objUser, objContact.AccountId, password);
            }
            else {
                Insert objUser;
                userId = objUser.Id;
            }
            System.debug('---DRS_RegistrationService:activateAccount:userId: ' + userId);
            
            ///Remove the Chatter email notificaitons for community users
            List<NetworkMember> listNetworkMembers = [Select Id From NetworkMember Where MemberId =: userId];
            for(NetworkMember objNetworkMember : listNetworkMembers) {
                objNetworkMember.PreferencesDisableAllFeedsEmail = true;
                //objNetworkMember.PreferencesDisableDirectMessageEmail = false;
            }
            Update listNetworkMembers;
            
            ///Assigns the permission set to the user based on the Contact Role
            //DRS_RegistrationService.assignPermissionSet(userId, objContact.Account.Type, objContact.Role__c, objContact.AdminUser__c);
            PermissionSetAssignmentClass objPermissionSetAssignmentClass = new PermissionSetAssignmentClass();
            objPermissionSetAssignmentClass.userId = userId;
            objPermissionSetAssignmentClass.accountType = objContact.Account.Type;
            objPermissionSetAssignmentClass.contactRoles = objContact.Role__c;
            objPermissionSetAssignmentClass.isAdminUser = objContact.AdminUser__c;
            String jobId = System.enqueueJob(objPermissionSetAssignmentClass);
            System.debug('---DRS_RegistrationService:activateAccount:jobId:' + jobId);
            
            ///Expire all Activation Codes for the Contact to avoid use of the same activation link again
            DRS_ContactService.expireActivationCodesForContact(objContact.Id);
        }
        catch(Exception excep) {
            System.debug('---DRS_RegistrationService:activateAccount:excep:' + excep);
            DRS_GlobalUtility.rollbackSavePoint(savePointBeforeInsert);
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.ActivateApplicantError));
        }
    }
    
    ///Activates the community user by creating the User record for the Account and Contact
    /// Gets the password from Activation Code record
    public static void activateAccount(String activationCode, String profileId){
        Contact objContact = DRS_ContactService.getContactForActivationCode(activationCode);
        if(objContact != null) {
            VerificationCode__c objVerificationCode = DRS_ContactService.getVerificationCodeForCode(activationCode);
            DRS_RegistrationService.activateAccount(objContact.Id, objVerificationCode.Password__c, profileId);
        }
        else {
            throw new DRS_GlobalException.ServiceException(DRS_MessageService.getMessage(DRS_MessageService.InvalidActivationCode));
        }
    }
    
    ///A Queueable class to assign the Permission Sets to the users
    ///The opertions has to be done in a queueable action because of multiple setup objects getting effected in the transaction
    public class PermissionSetAssignmentClass implements Queueable {
        public String userId;
        public String accountType;
        public String contactRoles;
        public Boolean isAdminUser;
        
        public void execute(QueueableContext objContext) {
            Map<String, PermissionSet> mapPermissionSets = DRS_GlobalUtility.getPermissionSets();
            List<PermissionSetAssignment> listPermissionSetAssignments = new List<PermissionSetAssignment>();
            PermissionSetAssignment objPermissionSetAssignment;
            List<String> contactRolesSplited = new List<String>();
            if(String.isNotBlank(contactRoles)) {
                contactRolesSplited = contactRoles.split(';');
            }
            
            if(isAdminUser) {
                objPermissionSetAssignment = new PermissionSetAssignment();
                objPermissionSetAssignment.AssigneeId = userId;
                objPermissionSetAssignment.PermissionSetId = mapPermissionSets.get(DRS_ContactService.PermissionSetDelegatedAdmin).Id;
                listPermissionSetAssignments.add(objPermissionSetAssignment);
            }
            
            objPermissionSetAssignment = new PermissionSetAssignment();
            objPermissionSetAssignment.AssigneeId = userId;
            if(accountType == DRS_AccountService.TypeInsurer || accountType == DRS_AccountService.TypeLegalFirm) {
                objPermissionSetAssignment.PermissionSetId = mapPermissionSets.get(DRS_ContactService.PermissionSetMRSInsurer).Id;
                listPermissionSetAssignments.add(objPermissionSetAssignment);
            }
            else if (accountType == DRS_AccountService.TypeWorkerWorkerRep) {
                objPermissionSetAssignment.PermissionSetId = mapPermissionSets.get(DRS_ContactService.PermissionSetMRSWorker).Id;
                listPermissionSetAssignments.add(objPermissionSetAssignment);
            }
            else if (accountType == DRS_AccountService.TypeSolePractitioner) {
                objPermissionSetAssignment.PermissionSetId = mapPermissionSets.get(DRS_ContactService.PermissionSetSolePractitioner).Id;
                listPermissionSetAssignments.add(objPermissionSetAssignment);
            }
            
            if(listPermissionSetAssignments.size() > 0) {
                Insert listPermissionSetAssignments;
            }
        }
    }
    
}