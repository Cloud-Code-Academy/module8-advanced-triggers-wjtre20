public with sharing class OpportunityHelper {
    public OpportunityHelper() {

    }

    public void setPrimaryContact(List<Opportunity> opportunities){
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : opportunities){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

        for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
        }

        for(Opportunity opp : opportunities){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            }
        }
    }
    public void createTaskForNewOpportunity(List<Opportunity> opportunities){
        List<Task> tasks = new List<Task>();
        // Create a new Task for newly inserted Opportunities
        for (Opportunity opp : opportunities){
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            tasks.add(tsk);
        }
        insert tasks;
    }
    public void notifyOwnersOpportunityDeleted(List<Opportunity> opportunities) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<Id, String> userIdToEmail = new Map<Id, String>();
        Set<Id> opportunityOwnerIds = new Set<Id>();
        for(Opportunity opp : opportunities){
            opportunityOwnerIds.add(opp.OwnerId);
        }
        for(User userRecord : [SELECT Id, Email FROM User WHERE Id IN :opportunityOwnerIds]){
            userIdToEmail.put(userRecord.Id, userRecord.Email);
        }
        for (Opportunity opp : opportunities){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{userIdToEmail.get(opp.OwnerId)});
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public void assignPrimaryContact(Map<Id,Opportunity> newOpportunityMap) { 
        Map<Id,Id> accountIdToPrimaryContactId = new Map<Id,Id>();
        Set<Id> opportunityAccountIds = new Set<Id>();       
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Opportunity opp : newOpportunityMap.values()){
            opportunityAccountIds.add(opp.AccountId);
        }
        for(Account accountRecord : [SELECT Id, (SELECT Id FROM Contacts WHERE  Title = 'VP Sales' LIMIT 1) FROM Account WHERE Id IN :opportunityAccountIds]){
            accountIdToPrimaryContactId.put(accountRecord.Id, accountRecord.Contacts[0].Id);
        }
        for (Opportunity opp : newOpportunityMap.values()){            
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = accountIdToPrimaryContactId.get(opp.AccountId);
                oppMap.put(opp.Id, oppToUpdate);
            }
        }
        update oppMap.values();
    }
}