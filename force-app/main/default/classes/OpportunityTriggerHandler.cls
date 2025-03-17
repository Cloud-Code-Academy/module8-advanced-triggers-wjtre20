public with sharing class OpportunityTriggerHandler extends TriggerHandler{
    private List<Opportunity> newOpportunities;
    private List<Opportunity> oldOpportunities;
    private Map<Id, Opportunity> newOpportunityMap;
    private Map<Id, Opportunity> oldOpportunityMap;
    OpportunityHelper helper = new OpportunityHelper();

    public OpportunityTriggerHandler() {
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.oldOpportunities = (List<Opportunity>) Trigger.old;
        this.newOpportunityMap =(Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunityMap =(Map<Id, Opportunity>) Trigger.oldMap;
    }

    public override void beforeInsert(){
        for(Opportunity opp : newOpportunities){
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }        
        }
    }
    public override void beforeUpdate(){
        for(Opportunity opp : newOpportunities){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
            if (opp.StageName != oldOpportunityMap.get(opp.Id).StageName){
                    opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
            }  
        }
        helper.setPrimaryContact(newOpportunities);
    }
    public override void beforeDelete(){
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :Trigger.old)]);
        for(Opportunity opp : oldOpportunities){
            if(opp.StageName == 'Closed Won'){
                if(accounts.get(opp.AccountId).Industry == 'Banking'){
                    opp.addError('Cannot delete a closed won opportunity for a banking account');
                }
            }
            if (opp.IsClosed){
                    opp.addError('Cannot delete closed opportunity');
            }
        }
    }
    public override void afterInsert(){
         helper.createTaskForNewOpportunity(newOpportunities);
    }
    public override void afterUpdate(){}
    public override void afterDelete(){
        helper.notifyOwnersOpportunityDeleted(oldOpportunities);
    }
    public override void afterUndelete(){
        helper.assignPrimaryContact(newOpportunityMap);
    }
}