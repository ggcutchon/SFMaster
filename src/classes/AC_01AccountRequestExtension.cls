/**
@Author Mariappan
@name AC_01AccountRequestExtension
@CreateDate 1/21/2015
@Description Account Change Request creation from Account Change Request Form
@Version 1.0
@reference <Referenced program names>
**/
public with sharing class AC_01AccountRequestExtension{
    
    public Account_Request__c ar {get;set;}
    private final Account acc;
    public string accountName {get;set;}
    public string accountNameGlobal {get;set;}
    public string localStreet {get;set;}
    public string globalStreet {get;set;}
    public Boolean blockLocal{get;set;}
    public Boolean blockGlobal{get;set;}
    Private String customLabelNIL = Label.CL00027;
    Private String emptyString='';
    Private String customLabelSlash= Label.CL00028;
    Private String customLabelUpdateAccInfo= Label.CL00029;
    private ApexPages.StandardController stdController1;
    private String billingCountryCode;
    private String billingStateCode;
    private String shippingCountryCode;
    private String shippingStateCode;
    // The extension constructor initializes the private member    // variable acct by using the getRecord method from the standard    // controller.    
    /**
*  Description of the purpose of the class the method. 
*  @name AC_01AccountRequestExtension Constructor
*  @param Standardcontroller 
*  @Description - autopopulate accountid & SAP Customer Id field
*  @return Nothing - 
*  @throws exception-Method is not having any exception
*/
    public AC_01AccountRequestExtension(ApexPages.StandardController stdController) {
        ar=new Account_Request__c ();
        this.acc= (Account)stdController.getRecord();
        this.ar.Account__c=this.acc.Id;
        this.ar.SAP_Customer_ID__c=stringNullProcess(this.acc.SAP_Customer_ID__c);
        this.ar.Account_Group__c=stringNullProcess(this.acc.Account_Group__c);
        billingCountryCode=this.acc.BillingCountryCode;
        billingStateCode=this.acc.BillingStateCode;
        shippingCountryCode=this.acc.ShippingCountryCode;
        shippingStateCode=this.acc.ShippingStateCode;
        this.acc.BillingCountryCode=emptyString;
        this.acc.BillingStateCode=emptyString;
        this.acc.ShippingCountryCode=emptyString;
        this.acc.ShippingStateCode=emptyString;
        blockLocal=true;
        blockGlobal=false;
    }
    /**
*  Description of the purpose of the class the method. 
*  @name Save
*  @param Method is not having any parameters
*  @Description - Save the account request and return back the detail page, in case of delete/deactivate ,potential 
duplicate request type all the account request field would be left blank.
*  @return PageReference - return back to the account detail page
*  @throws exception-Method will be throwing the DML Exception in case of any DML issues
*/
    public PageReference save()
    {
        if(this.ar.Comments__c==null || this.ar.Comments__c=='' )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter the comments'));
            return null;
        }
        streetNameProcess();
        postalNameProcess();
        countryStateProcess();
        this.ar.Int_City__c=this.ar.Int_City__c!=null?this.ar.Int_City__c:stringNULLProcess(acc.BillingCity);
        this.ar.Gen_City__c=this.ar.Gen_City__c!=null?this.ar.Gen_City__c:stringNULLProcess(acc.ShippingCity);
        this.ar.Account_Name__c=accountName!=emptyString?accountName:stringNullProcess(acc.Name);
        this.ar.Nm_Addr_ID__c=acc.Nm_Addr_ID__c;
        this.ar.DUNSNumber__c=customLabelNIL;//fix IM1717885 (stringNULLProcess(acc.DunsNumber)) by Remy Chen - 09242015
        this.ar.Int_House_Number__c=customLabelNIL;
        this.ar.Gen_House_Number__c=customLabelNIL;
        try {
            if(this.ar.Request_Type__c!=customLabelUpdateAccInfo)
            {
                Account_Request__c arequest=new Account_Request__c ();
                arequest.Account__c=this.acc.Id;
                arequest.SAP_Customer_ID__c=stringNullProcess(this.acc.SAP_Customer_ID__c);
                arequest.Comments__c=this.ar.Comments__c;
                arequest.Request_Type__c=this.ar.Request_Type__c;
                arequest.Account_Group__c=stringNullProcess(this.acc.Account_Group__c);//added to fix IM1699825 by Remy Chen - 09302015
                Database.insert(arequest,false);
            }
            else
            {
                Database.insert(ar,false);  
            }
            
        }
        Catch(DMLEXception e) {
            String errMsg = e.getMessage(); 
        }
        PageReference pageRef = new PageReference(Label.CL00028+this.acc.Id);
        return pageRef;
    }
    /**
*  Description of the purpose of the class the method. 
*  @name countryStateProcess
*  @param  Method is not having any parameter
*  @Description - To process the country & state based account request else from account in case of no changes to the
account change request
*  @return void
*  @throws exception-Method is not having any Exception
*/   
    private void countryStateProcess()
    {
        this.ar.Int_Country_Key__c=(acc.BillingCountryCode!=null && acc.BillingCountryCode!=emptyString)?acc.BillingCountryCode:stringNULLProcess(billingCountryCode);
        if(acc.BillingStateCode!=null && acc.BillingStateCode!=emptyString)
        {this.ar.Int_Region__c=acc.BillingStateCode;}
        else if(acc.BillingCountryCode!=null && acc.BillingCountryCode!=emptyString)
        {this.ar.Int_Region__c=customLabelNIL;}
        else{this.ar.Int_Region__c=stringNULLProcess(billingStateCode);}
        this.ar.Gen_Country_Key__c=(acc.ShippingCountryCode!=null && acc.ShippingCountryCode!=emptyString) ?acc.ShippingCountryCode:stringNULLProcess(shippingCountryCode);
        if(acc.ShippingStateCode!=null && acc.ShippingStateCode!=emptyString)
        {this.ar.Gen_Region__c=acc.ShippingStateCode;}
        else if(acc.ShippingCountryCode!=null && acc.ShippingCountryCode!=emptyString)
        {this.ar.Gen_Region__c=customLabelNIL;}
        else
        {this.ar.Gen_Region__c=stringNULLProcess(shippingStateCode);}
    }
    /**
*  Description of the purpose of the class the method. 
*  @name streetNameProcess
*  @param  - Method is not having any parameters
*  @Description - To process the City & Postal Code of the account change request
*  @return void
*  @throws exception-Method is not having any exception
*/   
    private void postalNameProcess()
    {
        if(this.ar.Int_City_Postal_Code__c!=null)
        {this.ar.Int_City_Postal_Code__c=this.ar.Int_City_Postal_Code__c;}
        else {this.ar.Int_City_Postal_Code__c=stringNULLProcess(acc.BillingPostalCode);}
        if(this.ar.Gen_City_Postal_Code__c!=null)
        {this.ar.Gen_City_Postal_Code__c=this.ar.Gen_City_Postal_Code__c;}
        else {this.ar.Gen_City_Postal_Code__c=stringNULLProcess(acc.ShippingPostalCode);}
        if(accountNameGlobal!=emptyString)
        {this.ar.Account_Name_Global__c=accountNameGlobal;}
        else {this.ar.Account_Name_Global__c=stringNullProcess(acc.Account_Name_Global__c);}
        if(this.ar.Government_Indicator__c!=null)
        {this.ar.Government_Indicator__c=this.ar.Government_Indicator__c;}
        else {this.ar.Government_Indicator__c=stringNULLProcess(acc.Government_Indicator__c);}
        if(this.ar.Communication_Language__c!=null)
        {this.ar.Communication_Language__c=this.ar.Communication_Language__c;}
        else {this.ar.Communication_Language__c=stringNULLProcess(acc.Communication_Language__c);}
        
    }
    /**
*  Description of the purpose of the class the method. 
*  @name streetNameProcess
*  @param  - Method is not having any parameter
*  @Description -To align the splitted Name and street to the Name & Street fields in account request .
*  @return void
*  @throws exception-Method is not having any exceptions
*/   
    private void streetNameProcess()
    {
        List<String> localStreets=localStreet!=emptyString?stringProcess(localStreet):stringProcess(this.acc.BillingStreet);
        List<String> globalStreets=globalStreet!=emptyString?stringProcess(globalStreet):stringProcess(this.acc.ShippingStreet);
        List<String> localName=accountName!=emptyString?stringProcess(accountName):stringProcess(this.acc.Name);
        List<String> globalName=accountNameGlobal!=emptyString?stringProcess(accountNameGlobal):stringProcess(this.acc.Account_Name_Global__c);
        this.ar.Int_Street_1__c=localStreets.size()>0?localStreets[0]:customLabelNIL;
        this.ar.Int_Street_2__c=localStreets.size()>1?localStreets[1]:customLabelNIL;
        this.ar.Int_Street_3__c=localStreets.size()>2?localStreets[2]:customLabelNIL;
        this.ar.Int_Street_4__c=localStreets.size()>3?localStreets[3]:customLabelNIL;
        this.ar.Int_Street_5__c=localStreets.size()>4?localStreets[4]:customLabelNIL;
        this.ar.Gen_Street_1__c=globalStreets.size()>0?globalStreets[0]:customLabelNIL;
        this.ar.Gen_Street_2__c=globalStreets.size()>1?globalStreets[1]:customLabelNIL;
        this.ar.Gen_Street_3__c=globalStreets.size()>2?globalStreets[2]:customLabelNIL;
        this.ar.Gen_Street_4__c=globalStreets.size()>3?globalStreets[3]:customLabelNIL;
        this.ar.Gen_Street_5__c=globalStreets.size()>4?globalStreets[4]:customLabelNIL;
        this.ar.Int_Name_1__c=localName.size()>0?localName[0]:customLabelNIL;
        this.ar.Int_Name_2__c=localName.size()>1?localName[1]:customLabelNIL;
        this.ar.Int_Name_3__c=localName.size()>2?localName[2]:customLabelNIL;
        this.ar.Int_Name_4__c=localName.size()>3?localName[3]:customLabelNIL;
        this.ar.Gen_Name_1__c=globalName.size()>0?globalName[0]:customLabelNIL;
        this.ar.Gen_Name_2__c=globalName.size()>1?globalName[1]:customLabelNIL;
        this.ar.Gen_Name_3__c=globalName.size()>2?globalName[2]:customLabelNIL;
        this.ar.Gen_Name_4__c=globalName.size()>3?globalName[3]:customLabelNIL;
        
    }
    /**
*  Description of the purpose of the class the method. 
*  @name StringProcess
*  @param String 
*  @Description - To split the string into array of string and each of length 35 characters.
*  @return List of string 
*  @throws exception-Method is not having any exceptions
*/
    private List<String> stringProcess(String s)
    {
        List<String> stringList = new List<String>();
        integer index = 0;
        if(s!=null)
        {
            while (index < s.length()) 
            {
                stringList.add(s.substring(index, Math.min(index + 35,s.length())));
                index += 35;
            }
        }
        return stringList;
    }
    /**
*  Description of the purpose of the class the method. 
*  @name StringNullProcess
*  @param String  
*  @Description - To check whether the parameterized string is null or  not
*  @return String  
*  @throws exception-Method is not having any exceptions
*/
    private string stringNullProcess(String s){
        String stringToBeReturned=s!=null?s:customLabelNIL;
        return stringToBeReturned;
    }
    /**
*  Description of the purpose of the class the method. 
*  @name blockGlobal
*  @param  
*  @Description - To disply Global Country & State open and Local Country & State will be closed
*  @return  
*  @throws exception-Method is not having any exceptions
*/
    public void blockGlobal(){
        blockLocal=false;
        blockGlobal=true;
        
    }
     /**
*  Description of the purpose of the class the method. 
*  @name blockLocal
*  @param   
*  @Description - To disply Local Country & State open and Gloabl Country & State will be closed
*  @return   
*  @throws exception-Method is not having any exceptions
*/
    public void  blockLocal(){
         blockLocal=true;
         blockGlobal=false;
    }
    
    
}