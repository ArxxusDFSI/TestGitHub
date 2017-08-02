@IsTest
public class DRS_RegisterLogin_CC_Test {

    @TestSetup
    public static void setup() {
        DRS_SetupData.processData();
    }
    
    public static testmethod void testRegisterApplicant() {
        Test.startTest();
        String result = DRS_RegisterLogin_CC.registerApplicant('Mr.', 'DEV', 'TEST', '01/01/1900', '0123456789', 'dev.test@test.dfsi.org', 'Martin Pl', 'Sydney', 'NSW', '2000', 'SystemPartners01', null, null, null, null);
        System.assert(result == 'Success', 'Registration failed');
        Test.stopTest();
    }
    
    public static testmethod void testActivateApplicant() {
        Test.startTest();
        String result = DRS_RegisterLogin_CC.registerApplicant('Mr.', 'DEV', 'TEST', '01/01/1900', '0123456789', 'dev.test@test.dfsi.org', 'Martin Pl', 'Sydney', 'NSW', '2000', 'SystemPartners01', null, null, null, null);
        System.assert(result == 'Success', 'Registration failed');
        
        VerificationCode__c objVerificationCode = [Select Code__c From VerificationCode__c Limit 1];
        result = DRS_RegisterLogin_CC.activateAccount(objVerificationCode.Code__c);
        System.assert(result == 'Success', 'Activation failed');
        Test.stopTest();
    }
}