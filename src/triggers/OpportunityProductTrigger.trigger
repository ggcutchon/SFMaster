/**
   @Author Rajesh Kaliyaperumal
   @name OpportunityProductTrigger
   @CreateDate 17th Jul 2015
   @Description This trigger used for calculate first and last revenue scheduled date.
   @Version 1.0   
**/
trigger OpportunityProductTrigger on OpportunityLineItem (before insert,before update,after insert) {
    OpportunityProductTriggerHandler oppProd = new OpportunityProductTriggerHandler();   
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){ // ER-1129
        oppProd.onBefore(trigger.newMap, trigger.oldMap, trigger.isUpdate);
        
    }// ER-1129
    
    if(Trigger.isUpdate && Trigger.isBefore){
        oppProd.onBeforeUpdate(Trigger.new);
    }    
    
    
}