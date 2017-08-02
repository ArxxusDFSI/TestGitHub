///The service class to facilitate Account object
public class DRS_AccountService {
    ///Variable declarations
    public static final String TypeInsurer = 'Insurer';
    public static final String TypeWorkerWorkerRep = 'Worker/Worker Rep';
    public static final String TypeSolePractitioner = 'Sole Practitioner';
    public static final String TypeLegalFirm = 'Legal Firm';
    public static final String RecordTypeBusiness = 'DRS_Business';
    public static final String RecordTypeIndividual = 'DRS_Individual';
    public static final String AccountUnderscore = 'Account_';
    
    ///Gets the active Accounts 
    /// Where Type is Insuere and Name is like the provided Name
    public static List<Account> getActiveInsurersByName(String insurerName) {
        if(String.isBlank(insurerName)) {
            return new List<Account>();
        }
        insurerName = insurerName + '%';
        return [
            Select Id, Name
            From Account
            Where Type =: DRS_AccountService.TypeInsurer
            And Name Like: insurerName
            And RecordTypeId =: DRS_GlobalUtility.getRecordTypes().get(DRS_AccountService.AccountUnderscore + DRS_AccountService.RecordTypeBusiness)
        ];
    }
    
    ///Gets Accounts with hierarchy
    public static List<Account> getAccountsWithHierarchy(String accountId) {
        return [
            Select Id, Name
            From Account
            Where Id =: accountId
            Or ParentId =: accountId
            Or Parent.ParentId =: accountId
            Or Parent.Parent.ParentId =: accountId
            Or Parent.Parent.Parent.ParentId =: accountId
        ];
    }
}