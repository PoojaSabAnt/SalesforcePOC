/**  PROGRAM NAME : CallOrderDistributionReOrgExecution 
     * This class contains the execution logic for identifying the 
       Distribution Relavant false calls and orders will not sync with Mobility. 
       @Scope of batchable context is Account. Separate DML to be performed on Order__c and Call__c object
     * @version  1.0
     * @Created Date 2017-01-13 
     * Note: As per assumption custom setting Distribution_Reorganisation__c needs to be created in system
     *       else could have unhandled exception
*/
public class CallOrderDistributionReOrgExecution {
     //fetch the CustomSetting for noOfsObject and noOfDaysForsObject
     private static final string ns = AddOnConstants.NAMESPACEPREFIX;
     Private Map<String, Distribution_Reorganisation__c> sCustomSetting;
     {
        sCustomSetting = Distribution_Reorganisation__c.getAll();
     }      
     //For internal usage only
     private final String NEW_STAT = 'New';
     private final String OLD_STAT = 'Old';
     private final String RETURN_STAT = 'Return';
     private final String GENERAL_STAT = 'General';
     private final String CALL_DATE = ns+'Start_Date__c';
     private final String ORDER_DATE = ns+'Delivery_Date__c';

     //Call Fall Back Setting
     private Integer noOfCalls = 1;
     private Integer noOfDaysForCalls = 10 ;

     //Order Fall back setting
     private Integer noOfOrders = 1;
     private Integer noOfDaysForOrders = 10 ;

     /*
     MethodName : process
     Note: Interface Method
     Input: List of sObject which defines the scope for the batch
     Output: None
     Purpose: Contains the business execution logic for the scope
     */
     public void process(List<SObject> listAccount )
     {
        List<Account> lstAccount = (List<Account>)listAccount;
        List<sObject> lstObjectToProcess = new List<sObject>();
        Map<ID, List<ACCL__Call__c>> accCallsMap = new Map<ID, List<ACCL__Call__c>>();    // EBP-6991   Dinakar K
        Map<ID, List<ACCL__Order__c>> accOrdersMap = new Map<ID, List<ACCL__Order__c>>(); // EBP-6991   Dinakar K
        if(!lstAccount.isEmpty())
        {
            //Generating account with related calls Map - EBP-6991   Dinakar K
            for(ACCL__Call__c call: [select ACCL__Distribution_Relevant__c,ACCL__Start_Date__c,ACCL__Status__c,ACCL__Account__c From ACCL__Call__c WHERE ACCL__Distribution_Relevant__c = true AND ACCL__Account__c IN:lstAccount Order By ACCL__Start_Date__c DESC]){
                if(!accCallsMap.containsKey(call.ACCL__Account__c)){
                    accCallsMap.put(call.ACCL__Account__c, new List<ACCL__Call__c>());
                }
                accCallsMap.get(call.ACCL__Account__c).add(call);
            }
            
            //Generating account with related Orders Map - EBP-6991   Dinakar K
            for(ACCL__Order__c order:[SELECT ACCL__Distribution_Relevant__c,ACCL__Delivery_Date__c,ACCL__Phase__c,ACCL__Order_Account__c FROM ACCL__Order__c WHERE  ACCL__Distribution_Relevant__c = true AND ACCL__Order_Account__c IN:lstAccount Order By ACCL__Delivery_Date__c DESC]){
                if(!accOrdersMap.containsKey(order.ACCL__Order_Account__c)){
                    accOrdersMap.put(order.ACCL__Order_Account__c, new List<ACCL__Order__c>());
                }
                accOrdersMap.get(order.ACCL__Order_Account__c).add(order);
            }
            
            //EBP-6991 - Start - Dinakar k
            for(Account acc: lstAccount)
            {
                if(lstObjectToProcess.size()> Limits.getLimitDMLRows())
                {
                    break;
                }
                if(accCallsMap.containsKey(acc.ID) && accCallsMap.get(acc.ID) != NULL){
                  lstObjectToProcess.addAll((List<sObject>)getCallsToUpdate(accCallsMap.get(acc.ID)));
                }
                if(accOrdersMap.containsKey(acc.ID) && accOrdersMap.get(acc.ID) != NULL)
                {                     
                    lstObjectToProcess.addAll((List<sObject>)getOrdersToUpdate(accOrdersMap.get(acc.ID)));
                }
            }
            //EBP-6991 - End - Dinakar k
            if(!lstObjectToProcess.isEmpty() && lstObjectToProcess.size() <= (Limits.getLimitDmlRows()-Limits.getDmlRows()))
            {
                try
                {                     
                    lstObjectToProcess.sort();
                    Database.update(lstObjectToProcess,false);
                }
                catch(Exception ex)
                {
                    System.debug('The following exception has occurred while executing CallOrderDistribution: ' + ex.getMessage());
                }
            }
        }
     }     
     /**This method is for any finish block processing
     * 
     * @name processFinish 
     * @param empty
     * @return void
     */
    public void processFinish() {
        //Send email
    }
    /************************Private Method for Internal Logic *********************************************/
     /*
     MethodName : getCallsToUpdate
     Input: List of Calls to be processed for each account
     Output: List of Calls
     Purpose: Contains the business execution logic for the Calls which dtermines 
              whether a call can be Distribution relevant false
     */
     private List<sObject> getCallsToUpdate(List<sObject> lstOfCalls)
     {
        //Query for Custom Setting for Call
        Map<String, List<sObject>> mapOfCalls = new Map<String, List<sObject>>
        {
            AddOnConstants.CALL_STATUS_COMPLETED => new List<sObject>(),
            AddOnConstants.CALL_STATUS_PLANNED => new List<sObject>(),
            RETURN_STAT => new List<sObject>()
        };
        //if Distribution Relevant Settings are available then process further else use fall back setting
        if(sCustomSetting.containsKey(AddOnConstants.CALL_DISTRIBUTION_SETTING))
        {
            noOfCalls = sCustomSetting.get(AddOnConstants.CALL_DISTRIBUTION_SETTING).Distribution_Relevant_Count__c!=null &&
                        sCustomSetting.get(AddOnConstants.CALL_DISTRIBUTION_SETTING).Distribution_Relevant_Count__c>0 ? 
                        sCustomSetting.get(AddOnConstants.CALL_DISTRIBUTION_SETTING).Distribution_Relevant_Count__c.intValue() : 
                        noOfCalls;

           noOfDaysForCalls = sCustomSetting.get(AddOnConstants.CALL_DISTRIBUTION_SETTING).Distribution_Relevant_CutOff_Date__c!=null &&
                              sCustomSetting.get(AddOnConstants.CALL_DISTRIBUTION_SETTING).Distribution_Relevant_CutOff_Date__c >0 ?
                              sCustomSetting.get(AddOnConstants.CALL_DISTRIBUTION_SETTING).Distribution_Relevant_CutOff_Date__c.intValue() : 
                            noOfDaysForCalls;
        }
        for(sObject call : lstOfCalls)
            {
                if(call.get(ns+'Status__c') == AddOnConstants.CALL_STATUS_CANCELED || call.get(ns+'Status__c') == AddOnConstants.CALL_STATUS_UNSCHEDULED ||
                    call.get(ns+'Status__c') == AddOnConstants.CALL_STATUS_DENIED)
                {
                    //call.Distribution_Relevant__c = false;
                    call.put(ns+'Distribution_Relevant__c',false);
                    mapOfCalls.get(RETURN_STAT).add(call);
                }
                else if(call.get(ns+'Status__c') == AddOnConstants.CALL_STATUS_COMPLETED)
                {
                    mapOfCalls.get(AddOnConstants.CALL_STATUS_COMPLETED).add(call);
                }
                else if(call.get(ns+'Status__c') == AddOnConstants.CALL_STATUS_PLANNED)
                {
                    mapOfCalls.get(AddOnConstants.CALL_STATUS_PLANNED).add(call);
                }
            }
            if(!mapOfCalls.get(AddOnConstants.CALL_STATUS_COMPLETED).isEmpty())
            {
                mapOfCalls.get(RETURN_STAT).addAll((List<sObject>)getListOfExecutedsObject(
                                    mapOfCalls.get(AddOnConstants.CALL_STATUS_COMPLETED),AddOnConstants.CALL_STATUS_COMPLETED,
                                                CALL_DATE,noOfCalls,noOfDaysForCalls));
            }
            if(!mapOfCalls.get(AddOnConstants.CALL_STATUS_PLANNED).isEmpty())
            {
                mapOfCalls.get(RETURN_STAT).addAll((List<sObject>)getListOfExecutedsObject(
                                    mapOfCalls.get(AddOnConstants.CALL_STATUS_PLANNED),AddOnConstants.CALL_STATUS_PLANNED,
                                                CALL_DATE,noOfCalls,noOfDaysForCalls));
            }
        return mapOfCalls.get(RETURN_STAT);
      } 
     /*
     MethodName : getOrdersToUpdate
     Input: List of Orders to be processed for each account
     Output: List of Orders
     Purpose: Contains the business execution logic for the Orders
                whether an order can be Distribution relevant false
     */
      private List<sObject> getOrdersToUpdate(List<sObject> lstOfOrders)
     {
        //Query for Custom Setting for order
        Map<String, List<sObject>> mapOfOrders = new Map<String, List<sObject>>
        {
            AddOnConstants.ORDER_PHASE_READY => new List<sObject>(),
            GENERAL_STAT => new List<sObject>(),
            RETURN_STAT => new List<sObject>()
        };
        //if Distribution Relevant Settings are available then process further else use fall back setting
        if(sCustomSetting.containsKey(AddOnConstants.ORDER_DISTRIBUTION_SETTING))
        {

            noOfOrders = sCustomSetting.get(AddOnConstants.ORDER_DISTRIBUTION_SETTING).Distribution_Relevant_Count__c!=null &&
                        sCustomSetting.get(AddOnConstants.ORDER_DISTRIBUTION_SETTING).Distribution_Relevant_Count__c>0 ? 
                        sCustomSetting.get(AddOnConstants.ORDER_DISTRIBUTION_SETTING).Distribution_Relevant_Count__c.intValue() : 
                        noOfOrders;
            noOfDaysForOrders = sCustomSetting.get(AddOnConstants.ORDER_DISTRIBUTION_SETTING).Distribution_Relevant_CutOff_Date__c!=null &&
                              sCustomSetting.get(AddOnConstants.ORDER_DISTRIBUTION_SETTING).Distribution_Relevant_CutOff_Date__c >0 ?
                              sCustomSetting.get(AddOnConstants.ORDER_DISTRIBUTION_SETTING).Distribution_Relevant_CutOff_Date__c.intValue() : 
                            noOfDaysForOrders;
        }
        for(sObject ord : lstOfOrders)
        {
            if(ord.get(ns+'Phase__c') == AddOnConstants.ORDER_PHASE_CANCELLED)
            {
                //ord.Distribution_Relevant__c = false;
                ord.put(ns+'Distribution_Relevant__c',false);
                mapOfOrders.get(RETURN_STAT).add(ord);
            }
            else if(ord.get(ns+'Phase__c') == AddOnConstants.ORDER_PHASE_READY)
            {
               mapOfOrders.get(AddOnConstants.ORDER_PHASE_READY).add(ord);
            }
            else  //Initial , Released
            {
                mapOfOrders.get(GENERAL_STAT).add(ord);
            }
        }
        if(!mapOfOrders.get(AddOnConstants.ORDER_PHASE_READY).isEmpty())
        {
            mapOfOrders.get(RETURN_STAT).addAll((List<sObject>)getListOfExecutedsObject(
                                mapOfOrders.get(AddOnConstants.ORDER_PHASE_READY),AddOnConstants.ORDER_PHASE_READY,
                                ORDER_DATE,noOfOrders,noOfDaysForOrders));
        }
        if(!mapOfOrders.get(GENERAL_STAT).isEmpty())
        {
            mapOfOrders.get(RETURN_STAT).addAll((List<sObject>)getListOfExecutedsObject(
                                mapOfOrders.get(GENERAL_STAT),GENERAL_STAT,ORDER_DATE,noOfOrders,noOfDaysForOrders));
        }
        return mapOfOrders.get(RETURN_STAT);
      }
     /*
     MethodName : getListOfExecutedsObject
     Input: List of sObject to be processed,status or Phase value,
            ConsiderDate (Date to be considered for age of sObject), Distribution Relevant Count,
            Distribution Relevant cut off days for sObject
     Output: List of sObject
     Purpose: Determines the age of calls and to be processed
     */
     private List<sObject> getListOfExecutedsObject(List<sObject> listofsObject,String status,String considerDate,
                                                                    Integer noOfsObject, Integer noOfDaysForsObject)
     {
        Map<String, List<sObject>> mapSObject = new Map<String, List<sObject>>
        {
            NEW_STAT => new List<sObject>(),
            OLD_STAT => new List<sObject>(),
            RETURN_STAT => new List<sObject>()
        };
        for(sObject sObj : listofsObject)
        {
            Date startDate = (Date)sObj.get(considerDate);
            /*daysBetween Date 1 and Date 2 is negative if Date 1 is future date and Date 2 is past
              daysBetweeen Date 1 and Date 2 is positive if Date 1 is past date and Date 2 is future
            */
            if(startDate.daysBetween(system.today())>0) //start date is a past date.
            {                
                if(startDate.daysBetween(system.today())<= noOfDaysForsObject)//recent Calls/Orders
                {
                    mapSObject.get(NEW_STAT).add(sObj);

                }
                else //old calls/Orders
                {
                    mapSObject.get(OLD_STAT).add(sObj);
                }    
            }
        }         
        if(!mapSObject.get(OLD_STAT).isEmpty()) // if Empty, then nothing to process
        { 
            //Only for executed call, check for noOfCalls parameter else process all old calls
            if(status == AddOnConstants.CALL_STATUS_COMPLETED || status == GENERAL_STAT)
            {                 
                if(mapSObject.get(NEW_STAT).size()>=noOfsObject)
                {   //Process all the old calls
                    mapSObject.get(RETURN_STAT).addAll(setDistributionRelevant(mapSObject.get(OLD_STAT),0));
                }
                else //read the comment below
                {
                    /*Leave the balanced Old Calls and process the rest.
                    If listOfNewCalls.size() = 2, noOfCalls = 5,
                    Leave 5-2 = 3 calls which are 10 days older and process the rest.
                    */
                    mapSObject.get(RETURN_STAT).addAll(
                                                    setDistributionRelevant(
                                                        mapSObject.get(OLD_STAT),noOfsObject-mapSObject.get(NEW_STAT).size()));
                }
            }
            else //Process all sObject with status as Unplanned, Released,Initial
            {
                mapSObject.get(RETURN_STAT).addAll(setDistributionRelevant(mapSObject.get(OLD_STAT),0));
            }
        }
        return mapSObject.get(RETURN_STAT);
     }
     /*
     MethodName : setDistributionRelevant
     Input: List of sObject to be processed, count of the sObjects not to be processed
     Output: List of sObject
     Purpose: Sets distribution Relevant flag of object to false
     */
     private List<sObject> setDistributionRelevant(List<sObject> listofObject, Integer iCount)
     {
        /*iCount is the number of sObjects which will be distribution Relevant.
          see getListOfExecutedsObject method to get a clear idea
        */
        if(iCount<listofObject.size())
        {    
            for(Integer i = iCount ; i<=listofObject.size()-1;i++)
            {
                listofObject.get(i).put(ns+'Distribution_Relevant__c',false);
            }
        }
        return listofObject;
     }
    /****************************************************************************************************/
}