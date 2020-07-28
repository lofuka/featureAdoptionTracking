public class AdoptionCounter  {

    //Method for Processbuilder
    @InvocableMethod(label='Increase Adoption Counter' description='Provide it a featuer action combination to incease adoption count')
    public static void increaseAdoptionCountInvocable(List<FeatureActionWrapper > featureActionList){

        //GET Current User
        Id userId = UserInfo.getUserId();
    
        //Create FeatureActionCompound Keyset
        Set<String> featureActionKeySet = new Set<String>();
        
        for(FeatureActionWrapper fAw:  featureActionList){
            featureActionKeySet.add(fAw.Feature+' '+fAw.Action);
        }
        
    
        //Get List of existing entries where USER, This Week, Actio IN: FeatureActionList and Feature IN: FeatureActionList
    
        //Fill Map<String,Adoption_Counter__c> featureActionMap
        Map<String,Adoption_Counter__c> featureActionMap = new Map<String,Adoption_Counter__c>();
        for(Adoption_Counter__c acElement : [SELECT Feature_Action_Compound__c, Id, Action__c, Count__c, User__c, Feature__c FROM Adoption_Counter__c WHERE User__c =: userId AND CreatedDate = THIS_Week ANd Feature_Action_Compound__c	 IN: featureActionKeySet]){
            featureActionMap.put(acElement.Feature_Action_Compound__c,acElement);
            
        }
    
        List<Adoption_Counter__c>  adoptionCountersToUpdate = new List<Adoption_Counter__c>();
    
        //Iterate over FeatureActionList
        for(FeatureActionWrapper fAw:  featureActionList){
            
            
            //Get AdoptionCounter from Map
            
            Adoption_Counter__c existingAdoptionCounter = featureActionMap.get(fAw.Feature+' '+fAw.Action);
            system.debug('featureActionMap '+featureActionMap);
            system.debug('fAw.Feature fAw.Action');
            system.debug(fAw.Feature+' '+fAw.Action);
            //Entry already exists -> Increase by one 
            if(existingAdoptionCounter != null){
                featureActionMap.get(fAw.Feature+' '+fAw.Action).Count__c +=1;
            }
            
            //Entry does not exist -> Create One
    
            if(existingAdoptionCounter == null){
	            Adoption_Counter__c  newAdoptionCounter = new Adoption_Counter__c();            
                newAdoptionCounter.User__c = userId;
                newAdoptionCounter.Action__c = fAw.Action;
                newAdoptionCounter.Feature__c = fAw.feature;
                newAdoptionCounter.Count__c = 1;
                featureActionMap.put(fAw.Feature+' '+fAw.Action,newAdoptionCounter);
            }
            
    
        }
        //Upsert Entry
        if(!featureActionMap.isEmpty()){
            upsert featureActionMap.values();
        }	
    
        
    }    
    
    //Lightning Component Method
    @AuraEnabled
    public static void increaseAdoptionCount(String feature, String actionType){
        FeatureActionWrapper newFeatureAction = new FeatureActionWrapper();
        newFeatureAction.feature = feature;
        newFeatureAction.action = actionType;
        List<FeatureActionWrapper> featureActionList = new List<FeatureActionWrapper>();
        featureActionList.add(newFeatureAction);
        AdoptionCounter.increaseAdoptionCountInvocable(featureActionList);
    }

    /*public static void performAdoptionOperation(String feature, String actionType){
        //Get Current User
        Id userId = UserInfo.getUserId();

        //Check if entry already exists
        Adoption_Counter__c newAdoptionCounter = new Adoption_Counter__c();
        //Test
        String query = 'SELECT Id, Action__c, Count__c, User__c, Feature__c FROM Adoption_Counter__c WHERE User__c =: userId AND CreatedDate = THIS_Week ANd Feature__c =: feature AND Action__c =: actionType';
        query += ' LIMIT 1 ';

        List<Adoption_Counter__c> adoptionEntryCurrentWeek = Database.query(query);

        //Entry already exists -> Increase by one 
        if(!adoptionEntryCurrentWeek.isEmpty()) {
            newAdoptionCounter = adoptionEntryCurrentWeek[0];
            newAdoptionCounter.Count__c +=1;
        
        }

        //Entry does not exist -> Create One

        if(adoptionEntryCurrentWeek.isEmpty()) {
            newAdoptionCounter.User__c = userId;
            newAdoptionCounter.Action__c = actionType;
            newAdoptionCounter.Feature__c = feature;
            newAdoptionCounter.Count__c = 1;
        }

        //Upsert Entry
        upsert newAdoptionCounter;
    
    }*/
    
    public class FeatureActionWrapper {
        @InvocableVariable(required=true)
        public String feature;
        
        @InvocableVariable(required=true)
        public String action;
        
              
    }    
}
