public without sharing class AccountHandler implements ITrigger {
    
    private List<Account> accList = new List<Account>();
    private List<Id> accChatterList = new List<Id>();
    private List<Id> accSLAChatterList = new List<Id>();
    private List<Account> accContactList = new List<Account>();
    // bulk operations
    public void bulkBefore() {
        // Implement if needed
    }
    
    public void bulkAfter() {
        // Implement if needed
    }
    
    // iterative operations
    // before contexts
    public void beforeInsert(SObject so) {
        System.debug('Inside AccountHandler');
        Account theAcc = (Account)so;
        if(theAcc != null){
            accList.add(theAcc);
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }
    
    public void beforeDelete(SObject so) {
        // Implement if needed
    }
    
    // after contexts
    public void afterInsert(SObject so) {
        Account theAcc = (Account)so;
        if(theAcc != null){
            accChatterList.add(theAcc.Id);
        }
        if(theAcc != null){
            accContactList.add(theAcc);
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so) {
        Account theAcc = (Account)so;
        Account oldAcc = (Account)oldSo;
        //Logic Account SLA Update
        if(theAcc != oldAcc){
            accSLAChatterList.add(theAcc.Id);
        }
    }
    
    public void afterDelete(SObject so) {
        // Implement if needed
    }
    
    // Final operations
    public void andFinally() {
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                System.debug('Inside Finally');
                //Chatter post for Update Account Rating
                if(!accChatterList.isEmpty()){
                    System.debug('Calling chatterPost Method');
                    AccountHelper.chatterPostonAccountRatingUpdate(accChatterList);
                }  
                
                //Creating a Contact for the AccountList
                if(!accContactList.isEmpty()){
                    System.debug('Calling helper to Creating Contact');
                    AccountHelper.createContactforAccount(accContactList);
                }              
            }
            
            if (Trigger.isUpdate) {
                if(!accSLAChatterList.isEmpty()){
                    System.debug('Calling chatterPost Method');
                    AccountHelper.chatterPostonAccountSLAUpdate(accSLAChatterList);
                } 
            }
        }
        
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                System.debug('InsideofBefore');
                if(!accList.isEmpty()){
                    System.debug('InsideofUpdateAccountHelper');
                    AccountHelper.updateAccountRating(accList);
                }
               
            }
            
            if (Trigger.isUpdate) {                 
                System.debug('InsideofBefore');
                if(!accList.isEmpty()){
                    System.debug('InsideofSLAUpdateAccountHelper');
                    AccountHelper.chatterPostonAccountSLAUpdate(accChatterList);
                } 
            }
        }
    }
}