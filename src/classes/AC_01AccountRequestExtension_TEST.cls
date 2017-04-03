@isTest
/**
@Author Mariappan
@name AC_01AccountRequestExtension_TEST
@CreateDate 12_Jan_2014
@Description Test scenario for Account change Request Visualforce Page 
@Version 1.0
**/
private class AC_01AccountRequestExtension_TEST{
    
    /*     
@name    - accountRequestCreation 
@return   - void  
@description  - Account Change Request creation with the Account Request mandatory fields  
*/   
    static testMethod void accountRequestCreation(){
        User usr =  UtilUnitTest.getUser();  
        Account account = UtilUnitTest.getAccount();
        Database.insert(account,false);
        AC_01AccountRequestExtension accountExtension= UtilUnitTest.getAccountChangeRequestPage(account);
        Test.setCurrentPage(Page.VFP01_AccountChangeRequest);
        accountExtension.ar.Request_Type__c='Update Account Information';
        accountExtension.accountName='Test Swapped';
        accountExtension.accountNameGlobal='';
        accountExtension.ar.Comments__c='Test Comments'; 
        System.runAs(usr) {            
            Test.startTest();
            accountExtension.save();
            Test.stopTest();             
            System.assert( accountExtension.save()!=null);      
        }    
    }
    /*     
@name - accountRequestCreationScenario2
@return - void
@description - Acccount change request creation with the change request to accountName, accountNameGlobal,
PostalCode and Government Indicator
*/   
    static testMethod void accountRequestCreationScenario2(){
        User usr =  UtilUnitTest.getUser();  
        Account account = UtilUnitTest.getAccount();
        Database.insert(account,false);
        AC_01AccountRequestExtension accountExtension= UtilUnitTest.getAccountChangeRequestPage(account);
        Test.setCurrentPage(Page.VFP01_AccountChangeRequest);
        accountExtension.ar.Request_Type__c='Update Account Information';
        accountExtension.accountName='Test Swapped';
        accountExtension.accountNameGlobal='Test Account Name Swapped';
        accountExtension.ar.Comments__c='Test Comments';
        accountExtension.ar.Int_City_Postal_Code__c='12345';
        accountExtension.ar.Gen_City_Postal_Code__c='12345';
        accountExtension.ar.Government_Indicator__c='Federal'; 
        System.runAs(usr) {            
            Test.startTest();
            accountExtension.save();
            Test.stopTest();             
            System.assert( accountExtension.save()!=null);    
        }    
    } 
    /*     
@name - accountRequestCreationScenario3
@return  - void  
@description   - Accountrequestcreation with Potential Duplicate Request Type so that all the request creation 
would be black for all the fields in account request
*/  
    static testMethod void accountRequestCreationScenario3(){
        User usr =  UtilUnitTest.getUser();  
        Account account = UtilUnitTest.getAccount();
        Database.insert(account,false);
        AC_01AccountRequestExtension accountExtension= UtilUnitTest.getAccountChangeRequestPage(account);
        Test.setCurrentPage(Page.VFP01_AccountChangeRequest);
        accountExtension.ar.Account__c=NULL; 
        accountExtension.ar.Request_Type__c='Potential Duplicate';
        accountExtension.accountName='Test Swapped';
        accountExtension.accountNameGlobal='Test Account Name Swapped';
        accountExtension.ar.Comments__c='Test Comments';
        accountExtension.ar.Int_City_Postal_Code__c='12345';
        accountExtension.ar.Gen_City_Postal_Code__c='12345';
        accountExtension.ar.Government_Indicator__c='Federal';
        System.runAs(usr) {            
            Test.startTest();
            accountExtension.save();
            Test.stopTest();             
            System.assert( accountExtension.save()!=null);     
        }    
    } 
    /*     
@name accountRequestCreationScenario4CountryState	 
@return void
@description Accountrequestioncreation with the BillingCountryCode & ShippingCountryCode but
without BillingStateCode & ShippingStateCode so that Billing & shipping state will not be populate from account.
*/   
    static testMethod void accountRequestCreationScenario4CountryState(){
        User usr =  UtilUnitTest.getUser();  
        Account account = UtilUnitTest.getAccount();
        Database.insert(account,false);
        AC_01AccountRequestExtension accountExtension= UtilUnitTest.getAccountChangeRequestPage(account);
        Test.setCurrentPage(Page.VFP01_AccountChangeRequest);
        accountExtension.ar.Account__c=account.Id; 
        accountExtension.ar.Request_Type__c='Potential Duplicate';
        accountExtension.accountName='Test Swapped';
        accountExtension.accountNameGlobal='Test Account Name Swapped';
        accountExtension.ar.Comments__c='Test Comments';
        accountExtension.ar.Int_City_Postal_Code__c='12345';
        accountExtension.ar.Gen_City_Postal_Code__c='12345';
        accountExtension.ar.Government_Indicator__c='Federal';
        accountExtension.acc.BillingCountryCode='US';
        accountExtension.acc.BillingStateCode=null;
        accountExtension.acc.ShippingCountryCode='IN';
        accountExtension.acc.ShippingStateCode=null;
        System.runAs(usr) {            
            Test.startTest();
            accountExtension.save();
            Test.stopTest();             
            System.assert( accountExtension.save()!=null);     
        }    
    } 
}