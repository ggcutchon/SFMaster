/**
    @Author Henry Jiang
    @name Account_AccountPenetrationBatch 
    @CreateDate 4/28/2016
    @Description Batch class to process sales assignment.
    @Version 1.0
    **/
global class Account_AccountPenetrationBatch implements Database.Batchable<SObject>{
    
    /*  Description of the purpose of the method. 
    *  @name start
    *  @Description - 
    *  @return - 
    */
    global Database.queryLocator start(Database.BatchableContext context)
    {
    	string query = 'SELECT Id,Account_Penetration_Reference__c,Account_Potential__c,FOUNDATIONAL__c,Product_Category__c,Account__c  FROM Account_Penetration__c WHERE Account__c != null AND (Account_Penetration_Reference__c = null or Account_Potential__c = null)';
    	if(Test.isRunningTest()){
    		query += ' LIMIT 1';
    	}
        return Database.getQueryLocator(query);
    }
    
    
    /*  Description of the purpose of the method. 
    *  @name execute
    *  @Description - 
    *  @return - Nothing
    */
    global void execute(Database.BatchableContext context, List<Account_Penetration__c> accPenetrationList)
    {    
       Set<Id> accIdSet = new Set<Id>();
       Map<Id, Account_Penetration__c> updatedAccPeneMap = new Map<Id, Account_Penetration__c>();
       Set<string> countryBGDivsionSet = new Set<string>();
       Map<Id, List<Account_Penetration__c>> accPeneIdMap = new Map<Id, List<Account_Penetration__c>>();
       Map<string, List<Account_Penetration__c>> accPeneStrMap = new Map<string, List<Account_Penetration__c>>();
       
       //get data for account potential and account penetration reference
       For(Account_Penetration__c ap : accPenetrationList){
       		if(ap.FOUNDATIONAL__c != ''){
       			countryBGDivsionSet.add(ap.FOUNDATIONAL__c);
       		}
       		
       		if(ap.Account__c != null && accPeneIdMap.get(ap.Account__c) != null){
       			accPeneIdMap.get(ap.Account__c).add(ap);
       		} else if(ap.Account__c != null) {
       			List<Account_Penetration__c> apList = new List<Account_Penetration__c>();
       			apList.add(ap);
       			accPeneIdMap.put(ap.Account__c, apList);
       		}
       		
       		if(ap.FOUNDATIONAL__c != '' && accPeneStrMap.get(ap.FOUNDATIONAL__c) != null){
       			accPeneStrMap.get(ap.FOUNDATIONAL__c).add(ap);
       		} else if(ap.FOUNDATIONAL__c != ''){
       			List<Account_Penetration__c> apList = new List<Account_Penetration__c>();
       			apList.add(ap);
       			accPeneStrMap.put(ap.FOUNDATIONAL__c, apList);
       		}
       }
       
       //add account potential to account penetration
       if(accPeneIdMap.size()>0){
       		List<Account_Potential__c> accPotList = [SELECT Id, Account__c, FOUNDATIONAL__c FROM Account_Potential__c WHERE Account__c in: accPeneIdMap.keySet() AND FOUNDATIONAL__c in: countryBGDivsionSet];
       		Map<string,Map<Id, Account_Potential__c>> accPotIdMap = new Map<string,Map<Id, Account_Potential__c>>();
       		
       		for(Account_Potential__c accPot : accPotList){
       			if(accPotIdMap.get(accPot.FOUNDATIONAL__c)!=null){
       				accPotIdMap.get(accPot.FOUNDATIONAL__c).put(accPot.Account__c, accPot);
       			} else {
       				Map<Id, Account_Potential__c> accPotMap = new Map<Id, Account_Potential__c>();
       				accPotMap.put(accPot.Account__c, accPot);
       				accPotIdMap.put(accPot.FOUNDATIONAL__c, accPotMap);
       			}
       		}
       		
       		for(Account_Penetration__c accPene : accPenetrationList){
       			if(accPotIdMap.get(accPene.FOUNDATIONAL__c) != null && accPotIdMap.get(accPene.FOUNDATIONAL__c).get(accPene.Account__c) != null){
       				accPene.Account_Potential__c =  accPotIdMap.get(accPene.FOUNDATIONAL__c).get(accPene.Account__c).Id;
       				updatedAccPeneMap.put(accPene.Id, accPene);
       			}
       		}
       }
       
        //add account penetration reference to account penetration
       if(accPeneStrMap.size()>0){
       		List<Account_Penetration_Reference__c> aprList = [SELECT Id, FOUNDATIONAL__c, Product_Category__c FROM Account_Penetration_Reference__c WHERE FOUNDATIONAL__c in: countryBGDivsionSet AND Active__c = true];
       		for(Account_Penetration_Reference__c apr : aprList){
       			List<Account_Penetration__c> accPeneList = accPeneStrMap.get(apr.FOUNDATIONAL__c);
       			if(accPeneList != null){
       				for(Account_Penetration__c accPene : accPeneList){
       					if(accPene.Product_Category__c == apr.Product_Category__c){
       						Account_Penetration__c tempAccPene = new Account_Penetration__c();
       						if(updatedAccPeneMap.get(accPene.Id) != null){
       							tempAccPene = updatedAccPeneMap.get(accPene.Id);
       						} else {
       							tempAccPene = accPene;
       						}
       						tempAccPene.Account_Penetration_Reference__c = apr.Id;
       						updatedAccPeneMap.put(tempAccPene.Id, tempAccPene);
       					}
       				}
       			}
       		}
       }
       
       if(updatedAccPeneMap.size()>0){
	       	try{
	       	    update updatedAccPeneMap.values();
	       	} catch (Exception ex){
	       		Logs__c log = new Logs__c(Class_Name__c = 'Account_AccountPenetrationBatch',Error_Line__c = String.valueof(ex.getLineNumber()),Error_Message__c = ex.getMessage(), Full_Error__c = String.valueof(ex));Database.insert(log);
	       	}
       }
    }
    
    
    /*  Description of the purpose of the method. 
    *  @name Finish
    *  @Description - nothing.
    *  @return - Nothing
    */
    global void finish(Database.BatchableContext context)
    {     
    	
    }
    
}