public class DRS_MessageService {
    public static final String ExistingUserFound = 'ExistingUserFound';
    public static final String ExistingContactFoundWithUser = 'ExistingContactFoundWithUser';
    public static final String RegisterApplicantError = 'RegisterApplicantError';
    public static final String InvalidActivationCode = 'InvalidActivationCode';
    public static final String ActivateApplicantError = 'ActivateApplicantError';
    public static final String SaveCaseItemError = 'SaveCaseItemError';
    public static final String SaveProfileError = 'SaveProfileError';
    public static final String AddAttachmentError = 'AddAttachmentError';
    public static final String InsurerTriageUsersNotFound = 'InsurerTriageUsersNotFound';
    public static final String AddCaseTeamMemberError = 'AddCaseTeamMemberError';
    public static final String RemoveCaseTeamMemberError = 'RemoveCaseTeamMemberError';
    public static final String CaseItemAlreadySubmitted = 'CaseItemAlreadySubmitted';
    public static final String RegisterUserError = 'RegisterUserError';
    public static final String VerificationCodeExpired = 'VerificationCodeExpired';
    public static final String InvalideUserId = 'InvalideUserId';
    public static final String ChangePasswordError = 'ChangePasswordError';
    public static final String TooManyActivations = 'TooManyActivations';
    public static final String GeneralError = 'GeneralError';
    public static final String EmailAlreadyExists = 'EmailAlreadyExists';
    public static final String EmailAddressBlank = 'EmailAddressBlank';
    public static final String AuthorizationError = 'AuthorizationError';
    public static final String BusinessHoursNotDefined = 'BusinessHoursNotDefined';
    public static final String InvalidParametersForDRS_CaseServiceAutomation = 'InvalidParametersForDRS_CaseServiceAutomation';
    public static final String WorkerCaseItemNotYetSubmitted = 'WorkerCaseItemNotYetSubmitted';
    public static final String EmailNotExists = 'EmailNotExists';
    public static final String MultipartUploadFailed = 'MultipartUploadFailed';
    
    public static String getMessage(String messageName){
        String message = '';
        
        If(String.isNotBlank(messageName)) {
            if(messageName == DRS_MessageService.RegisterApplicantError) { message = 'There was an error creating your user, please try again.'; }
            else if(messageName == DRS_MessageService.InvalidActivationCode) { message = 'Invalid activation code'; }
            else if(messageName == DRS_MessageService.ActivateApplicantError) { message = 'Unable to activate your account, please try again.'; }
            else if(messageName == DRS_MessageService.SaveCaseItemError) { message = 'Unable to save case item.'; }
            else if (messageName == DRS_MessageService.SaveProfileError) { message = 'Unable to save profile.'; }
            else if (messageName == DRS_MessageService.AddAttachmentError) { message = 'Unable to add attachment.'; }
            else if (messageName == DRS_MessageService.InsurerTriageUsersNotFound) { message = 'Unable to find Triage Users for the insurer.'; }
            else if (messageName == DRS_MessageService.AddCaseTeamMemberError) { message = 'Unable to add the member to case team.'; }
            else if (messageName == DRS_MessageService.RemoveCaseTeamMemberError) { message = 'Unable to remove the member from case team.'; }
            else if (messageName == DRS_MessageService.CaseItemAlreadySubmitted) { message = 'Unable to update a submitted Case Item.'; }
            else if (messageName == DRS_MessageService.RegisterUserError) { message = 'Unable to register the new user.'; }
            else if (messageName == DRS_MessageService.VerificationCodeExpired) { message = 'The verification code has expired.'; }
            else if (messageName == DRS_MessageService.InvalideUserId) { message = 'The User Id provided is invalid.'; }
            else if (messageName == DRS_MessageService.ChangePasswordError) { message = 'Unable to change password.'; }
            else if (messageName == DRS_MessageService.TooManyActivations) { message = 'Too many activations requested. Please try again later.'; }
            else if (messageName == DRS_MessageService.GeneralError) { message = 'Unable to process your request. Please try again later.'; }
            else if (messageName == DRS_MessageService.EmailAddressBlank) { message = 'Blank email address provided. Unable to save records.'; }
            else if (messageName == DRS_MessageService.BusinessHoursNotDefined) { message = 'The business hours are not defined. Please configure business hours first.'; }
            else if (messageName == DRS_MessageService.InvalidParametersForDRS_CaseServiceAutomation) { message = 'The parameters provided for Case Service Automation are incorrect. Please contact your System Administrator.'; }
            else if (messageName == DRS_MessageService.WorkerCaseItemNotYetSubmitted) { message = 'The worker case item for this case has not been submitted yet. Insurer reply cannot be created.'; }
            else if(messageName == DRS_MessageService.EmailNotExists) { message = 'Invalid Email. Please check the email you have entered.'; }
            else if(messageName == DRS_MessageService.MultipartUploadFailed) { message = 'Multipart upload failed.'; }
            else if (messageName == DRS_MessageService.AuthorizationError) { message = 'Sorry, you are not authorized to perform this action.'; }
        }
        return message;
    }
    
    public static String getMessage(String messageName, String[] arguments) {
        String message = '';
        
        If(String.isNotBlank(messageName)) {
            if(messageName == DRS_MessageService.ExistingUserFound) { message = 'Unable to create user. An existing user with username \"{0}\" was found'; }
            else if(messageName == DRS_MessageService.ExistingContactFoundWithUser) { message = 'Unable to create user. A user exists for the email address, the username is \"{0}\".'; }
            else if(messageName == DRS_MessageService.EmailAlreadyExists) { message = 'The email address provided \"{0}\" already exists for another user. Please provide a different email address.'; }
        }
        
        if(String.isNotBlank(message)) { message = String.format(message, arguments); }
        
        return message;
    }
}