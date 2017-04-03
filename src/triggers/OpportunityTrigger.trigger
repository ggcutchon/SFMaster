/**
   @Author Haribabu Singamaneni
   @name OpportunityTrigger 
   @CreateDate 12_Jan_2015
   @Description This trigger is used for opportunity rollup to sales project.
   @Version 1.0   
**/
trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update,after delete,after undelete) {
    //ggcutchon 12/14/2016: ER-1553
    List<Opportunity> oppList = new List<Opportunity>(); 
    List<Opportunity> oldOppList = new List<Opportunity>();
    //--------------------------------------
    OpportunityTriggerHandler oppTH = new OpportunityTriggerHandler();
    
    OpportunitySchedulingHandler opprSchedule = new OpportunitySchedulingHandler(); // Updated by Sangeetha Aug19,2016
    
    if(Trigger.isInsert && Trigger.isAfter){
        oppTH.onAfterInsert(Trigger.new);
        opprSchedule.CreateScheduleonInsert(Trigger.newMap);  // Updated by Sangeetha Aug19,2016
        
        //ggcutchon 12/14/2016: ER-1553
        for(Opportunity op: Trigger.new){
            OpportunityTriggerValidation.recordIsNew = true;
            oppList.add(op);
        }
        if(oppList.size() > 0){
            try{
                OpportunityTriggerValidation.autoRevenueSchedule(oppList,oppList);
            }
            catch(DMLException e){
                for(Opportunity opError : oppList){
                    opError.addError(e.getDMLMessage(0));
                }
            }
        }
        //-------------------------------       
        
    }
    
    if(Trigger.isInsert && Trigger.isBefore){
        oppTH.onBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        if(!OpportunityTriggerHandler.SkipOpportunityTrigger){
            oppTH.onAfterUpdate(Trigger.new,Trigger.oldMap);
        }
        map<id, Opportunity> annualRevenueChanged= new map<id, Opportunity>();
        for(Opportunity opp : trigger.new){
            if(opp.Automatic_Revenue_Schedule__c != trigger.oldMap.get(opp.id).Automatic_Revenue_Schedule__c ){
                annualRevenueChanged.put(opp.id, opp);
            }
        }
        if(annualRevenueChanged.size() > 0){
            try{//ggcutchon ER-1553
                opprSchedule.CreateScheduleonInsert(annualRevenueChanged);  // Updated by Sangeetha Aug19,2016
            }
            catch(DMLException e){
                for(Opportunity opError : annualRevenueChanged.values()){
                    opError.addError(e.getDMLMessage(0));
                }
            }
        }       

    //ggcutchon 12/14/2016: ER-1553
        for(Opportunity op: Trigger.new){
            Opportunity oldOpp = Trigger.oldMap.get(op.Id);
            oppList.add(op);
            oldOppList.add(oldOpp);
        }
        if(oppList.size() > 0){
            try{
                OpportunityTriggerValidation.autoRevenueSchedule(oppList,oldOppList);
            }
            catch(DMLException e){
                for(Opportunity opError : oppList){
                    opError.addError(e.getDMLMessage(0));
                }
            }
        }
        //-------------------------------       
    }
    if(Trigger.isDelete && Trigger.isAfter){
        oppTH.onAfterDelete(Trigger.old);
    }
    if(Trigger.isUndelete && Trigger.isAfter){
        oppTH.onAfterUnDelete(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        if(!OpportunityTriggerHandler.SkipOpportunityTrigger){
            oppTH.onBeforeUpdate(Trigger.new,Trigger.oldMap);
        }
        
        
        
        //11_02_2016 : Sandeep
        //TODO:Need to merger in 'OpportunityTriggerHandler' class
     if(Trigger.isUpdate && Trigger.isBefore){
        OpportunityTriggerValidation.onBeforeUpdate(trigger.new,trigger.oldmap);
      }
    }
    
  if((Trigger.isUpdate && Trigger.isAfter) || (Trigger.isInsert && Trigger.isAfter)){
        oppTH.onAfterOrderRequest(Trigger.new,trigger.oldmap);  //run Order Request Trigger Handler
        
        
    }    
}