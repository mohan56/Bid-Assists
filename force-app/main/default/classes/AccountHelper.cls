public class AccountHelper {
    //Updating Account Rating
    public static void updateAccountRating(List<Account> theAccList){
        System.debug('Inside');
        List<Account> accList  = new List<Account>();
        if(!theAccList.isEmpty()){
            for(Account theAcc : theAccList){
                if(theAcc.Rating == 'Hot'){
                    theAcc.Type = 'Prospect';
                }
                else{
                    theAcc.Type = '';
                }
                accList.add(theAcc);
            }
        }  
        if(!accList.isEmpty()){
            System.debug('Calling EmailtoUpdatedAccounts');
            EmailtoUpdatedAccounts(accList);
        }
    }
    
    //Sending chatter Post on Account Rating
    public static void chatterPostonAccountRatingUpdate(List<Id> theAccIdList) {
        
        List<Account> fetchedAccountList = [SELECT Id,Rating,Type FROM Account WHERE Id IN : theAccIdList];
        System.debug('fetchedAccountList'+fetchedAccountList);
        
        List<FeedItem> postsToInsert = new List<FeedItem>();
        
        for(Account theAcc : fetchedAccountList){
            if(theAcc.Rating != null){
                FeedItem feed = new FeedItem();
                feed.ParentId = theAcc.Id;
                feed.Body = 'The Account Rating has been Updated to '+theAcc.Rating ;
                postsToInsert.add(feed); 
                System.debug('postsToInsert'+postsToInsert);
            }
        }
        if(!postsToInsert.isEmpty()){
            Insert postsToInsert;
        }
    }  
    
    //Sending chatter Post Mentioning the Record Owner(Hyperlink) on Account SLA Update
    public static void chatterPostonAccountSLAUpdate(List<Id> theAccIdList){
        
        List<Account> theAccList = [SELECT Id,SLA__c,OwnerId FROM Account WHERE Id IN: theAccIdList];
        List<ConnectApi.FeedItemInput> feedItemsToInsert = new List<ConnectApi.FeedItemInput>();
        
        for(Account theAcc : theAccList){
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            mentionSegmentInput.id = theAcc.OwnerId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            String postBody = 'A chatter post added because the Account SLA is updated to ' + theAcc.SLA__c ;
            textSegmentInput.text = postBody;
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = theAcc.Id;
            
            feedItemsToInsert.add(feedItemInput);
        }
        if (!feedItemsToInsert.isEmpty() && !Test.isRunningTest()) {
            for (ConnectApi.FeedItemInput feedItem : feedItemsToInsert) {
                ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItem);
            }
        }
    }
    
    //Sending the Email Template Mail Hyperlinked
    public static void EmailtoUpdatedAccounts(List<Account> accList){
        System.debug('EmailtoUpdatedAccounts::'+accList);
        EmailTemplate fetchedEmailTemplate = [SELECT Id,Body,DeveloperName FROM EmailTemplate WHERE DeveloperName = 'Account_Rating_Update'];
        System.debug('fetchedEmailTemplate'+fetchedEmailTemplate);
        List<Account> fetchedAccountList = [SELECT Id,Name,AccountNumber,SLA__c,Email__c, (SELECT LastName FROM Contacts) from Account];
        String orgDomainUrl = Url.getOrgDomainUrl().toExternalForm();//getting the Current org url
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        if(!fetchedAccountList.isEmpty()){
            for(Account theAcc : fetchedAccountList){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{theAcc.Email__c});
                mail.setSubject('A Account has been Created');
                String htmlBody = fetchedEmailTemplate.Body;
                htmlBody = htmlBody.replace('(hyperlinked to account Name)', '<a href="' + orgDomainUrl + '/' + theAcc.Id+ '">' + theAcc.Name + '</a><br>');                           
                htmlBody = htmlBody.replace('(hyperlinked to account SLA)','<a href="' + orgDomainUrl + '/' + theAcc.Id + '">' + theAcc.SLA__c + '</a><br>') ;                
                mail.setHtmlBody(htmlBody);
                mailList.add(mail);
            }
        } 
        if(!mailList.isEmpty()){
            Messaging.sendEmail(mailList,false); 
        }
    }
    
    public static void createContactforAccount(List<Account> theaccList){
        
        List<Contact> theContactList = new List<Contact>();
        if(!theaccList.isEmpty()){
            for(Account theAcc : theaccList){
                // Check if the Account is a Person Account
                if(theAcc.IsPersonAccount){
                    Contact theCon = new Contact();
                    theCon.LastName = theAcc.Name;
                    theCon.AccountId = theAcc.Id;
                    theContactList.add(theCon);
                }
            }
        }
        if(!theContactList.isEmpty()){
            insert theContactList;
        }
    }
}