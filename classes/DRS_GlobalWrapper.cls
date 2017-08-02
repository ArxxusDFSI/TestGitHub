public class DRS_GlobalWrapper {
    
    public class AdditionalInformationJSON {
        public string requestDetails;
        public string responseDetails;
    }
    
    public class CaseJSON {
        public string caseNumber;
        public string caseId;
        public string status;
        public string claimNumber;
        public string workerName;
        public string dateLodged;
        public string insurer;
        public boolean showManageCaseTeamMembers;
        public string loggedInUserName;
        public string primaryContactName;
        public string primaryContactPublicEmail;
        public string primaryContactPublicPhone;
        public list<DRS_GlobalWrapper.CaseItemJSON> submittedCaseItems;
        public list<DRS_GlobalWrapper.CaseItemJSON> pendingCaseItems;
        public list<DRS_GlobalWrapper.AttachmentJSON> attachments;
        public list<DRS_GlobalWrapper.CaseTeamMemberJSON> caseTeamMembers;
    }
    
    public class CaseItemJSON {
        public string title;
        public string name;
        public string status;
        public String caseItemData;
        public String submittedBy;
        public String submittedDate;
        public string dateSubmitted;
        public string createdDate;
        public String behalfOfWorker;
        public String caseId;
        public string caseNumber;
        public string caseOrigin;
        public String caseItemId;
        public String contactId;
        public String taskId;
        public String yesBehalfOfWorker;
        public String representative;
        public String givenName;
        public String surname;
        public String dob;
        public String contact;
        public String email;
        public String emailAddress;
        public String postal;
        public String suburb;
        public String state;
        public String postcode;
        public String claimNo;
        public string interpreter;
        public string language;
        public string disabilities;
        public string workerName;
        public string dueDate;
        public string caseItemType;
        public boolean showView;
        public boolean isLocked;
        public string communityPageURL;
        public string roleGroup;
        public string openedDateTime;
        public string ownerAlias;
        public string remainingTimeToExpire;
        public string dontPublish;
        public string representationDetails; //If Yes, please specify the type of representation
        public string dateOfInjury; //Date of Injury
        public string supportingDocumentAttachedDate; //When did you receive the insurer’s internal review decision?
        public string insurerSupportingDocumentAttachedDate; //Date the worker applied for the internal review
        public string workCapacityDecisionDate; //Date of the original work capacity decision
        public string internalReviewDecisionDate; //Date of the internal review decision by insurer
        public string workInReceipt; //Was the worker in receipt of weekly payments immediately before 1 October 2012? Yes/No
        public string decisionCurrentWorkCapacity; //Decision about your current work capacity
        public string decisionSuitableEmployment; //Decision about what is suitable employment for you
        public string decisionAmountEarnInSuitableEmployment; //Decision about the amount you are able to earn in suitable employment
        public string decisionAmountPreInjury; //Decision about the amount of your pre-injury average weekly earnings or current weekly earnings
        public string decisionResultUnableEngageInEmployment; //Decision about whether, as a result of your injury, you are unable (without substantial risk of further injury) to engage in employment of a certain kind because of the nature of that employment
        public string otherInsurerAfferctsEntitlement; //any other insurer decision that affects your entitlement to weekly compensation payments, including a decision to suspend, discontinue or reduce the amount of the weekly payments of compensation
        public string notReviewDecisionDate; //Internal review decision has not been made by the insurer within 30 calendar days
        public string q3b; //Date Insurer received application for internal review?
        public boolean workCapacity;
        public boolean suitableEmployment;
        public boolean amountEarntInSE;
        public boolean piawe;
        public boolean currentWeeklyEarnings;
        public boolean unableToEngageInCertainEmploy;
        public boolean anyOtherWeeklyPaymentDecision;
        public string caseReasons;
        public boolean notAWorkerCapacityDecision;
        public boolean isSavedForLater;
        public DRS_GlobalWrapper.InsurerJSON insurer;
        public List<DRS_GlobalWrapper.AttachmentJSON> attachments;
    }
    
    public class AttachmentJSON {
        public string attachmentId;
        public string name;
        public string description;
        public string category;
        public string tier2;
        public string tier3;
        public string caseId;
        public string caseItemId;
        public string submitter;
        public string dateLoaded;
        public string author;
        public string dateOfDocument;
        public string internalAuthor;
        public string decisionSentDate;
        public string internalReviewer;
        public string fromDateCorrespondance;
        public string toDateCorrespondance;
        public Boolean externallyVisible;
        public string viewURL;
        public string saveURL;
        public List<PartJSON> parts;
    }
    
    public class PartJSON {//implements System.Comparable {
        public string partNumber;
        public string eTag;
        
        /*
        //Implementation of compareTo method for the System.Comparable Interface
        //Compares this PartJSON object with another PartJSON object and decides the sorting
        public Integer compareTo(Object compareToObj) {
            PartJSON compareToPartJSON = (PartJSON)compareToObj;
            Integer returnValue = 0;
            if(Integer.valueOf(this.partNumber) > Integer.valueOf(compareToPartJSON.partNumber))
                returnValue = 1;
            else
                returnValue = -1;
            return returnValue;
        }*/
    }
    
    public class CaseDetailJSON {
        public List<SnippetJSON> caseStatuses;
        public SnippetJSON pendingCases;
        public SnippetJSON attachments;
        public SnippetJSON caseItems;
    }
    
    public class SnippetJSON {
        public String name;
        public String description;
    }
    
    public class CaseTeamMemberJSON {
        public string caseId;
        public string memberName;
        public string memberId;
        public string roleName;
        public string roleId;
        public string caseTeamMemberId;
        public boolean isRemoved;
        public boolean isAdded;
        public boolean isExisting;
        public List<RoleJSON> availableRoles;
    }
    
    public class RoleJSON {
        public string roleName;
        public string roleId;
    }
    
    public class UserJSON {
        public string title;
        public string userName;
        public string userId;
        public string id;
        public string firstName;
        public string lastName;
        public string emailAddress;
        public string phone;
        public string address;
        public string suburb;
        public string state;
        public string postcode;
        public string lastLoginDateTime;
        public string role;
        public string accountId;
        public string accountName;
        public string contactId;
    }
    
    public class CaseTeamBuilderJSON {
        public list<DRS_GlobalWrapper.CaseTeamMemberJSON> caseTeamMembers;
        public list<DRS_GlobalWrapper.RoleJSON> roles;
    }
    
    public class DashboardJSON {
        public List<CaseItemJSON> draftCaseItems;
        public List<CaseItemJSON> pendingCaseItems;
        public List<CaseItemJSON> openCaseItems;
        public List<CaseItemJSON> closedCaseItems;
        public String userId;
        public String userFirstName;
        public String userLastName;
        public Boolean showNewApplication;
    }
    
    public class InsurerJSON {
        public string name;
        public string id;
    }
    
    ///Class to handle Profile data for the UI
    public class ProfileJSON {
        public String title;
        public String firstName;
        public String lastName;
        public String birthDate;
        public String phone;
        public String email;
        public String mailingStreet;
        public String mailingCity;
        public String mailingState;
        public String mailingPostalCode;
        public String id;
    }
    
    public class AccountUserCollection {
        public List<DRS_GlobalWrapper.UserJSON> activeUsers;
        public List<DRS_GlobalWrapper.UserJSON> inActiveUsers;
        public List<DRS_GlobalWrapper.UserJSON> pendingUsers;
    }
    
    public class AccountJSON {
        public string id;
        public string name;
    }
}