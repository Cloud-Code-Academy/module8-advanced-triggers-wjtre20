/*
AccountTrigger Overview

This trigger performs several operations on the Account object during its insertion. Depending on the values and conditions of the newly created Account, this trigger can:

1. Set the account's type to 'Prospect' if it's not already set.
2. Copy the shipping address of the account to its billing address.
3. Assign a rating of 'Hot' to the account if it has Phone, Website, and Fax filled.
4. Create a default contact related to the account after it's inserted.

Usage Instructions:
For this lesson, students have two options:
1. Use the provided `AccountTrigger` class as is.
2. Use the `AccountTrigger` from you created in previous lessons. If opting for this, students should:
    a. Copy over the code from the previous lesson's `AccountTrigger` into this file.
    b. Save and deploy the updated file into their Salesforce org.

Let's dive into the specifics of each operation:
*/
trigger AccountTrigger on Account (before insert, after insert) {
    AccountHelper helper = new AccountHelper();
    /*
    * Account Trigger
    * When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
    * Trigger should only fire on insert.
    */
    if (Trigger.isBefore && Trigger.isInsert) {
       helper.setTypeProspect(Trigger.new);
    

    /*
    * Account Trigger
    * When an account is inserted copy the shipping address to the billing address.
    * Trigger should only fire on insert.
    */
       helper.addressCopy(Trigger.new);        

    /*
    * Account Trigger
    * When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax is not empty.
    * Trigger should only fire on insert.
    */
        helper.setRating(Trigger.new);  
    }
    
    /*
    * Account Trigger
    * When an account is inserted create a contact related to the account with the following default values:
    * LastName = 'DefaultContact'
    * Email = 'default@email.com'
    * Trigger should only fire on insert.
    */    
    if(Trigger.isAfter && Trigger.isInsert){     
        helper.defaultContact(Trigger.new);
    }
}