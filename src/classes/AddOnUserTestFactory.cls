@isTest
public class AddOnUserTestFactory {
	
    public static User systemAdmin;
    //Following variable has been added to retrieve the Global picklist value for Sales Org in Org
    public static List<String> lstSalesOrg;
    
    public static String getLoggedInUserTimeZoneSidKey() {
        User loggedInUser = new User();
        loggedInUser = [select TimeZoneSidKey from User where id =: UserInfo.getUserId() limit 1];
        return loggedInUser.TimeZoneSidKey;
    }
    
    public static User buildUserWithProfile(Integer i, String profile) {
        try
        {
            Profile p = [select id from profile where name=:Profile Limit 1];
            String strUserTimeZoneSidKey = getLoggedInUserTimeZoneSidKey();
            User u = new User();
            u.FirstName = AddOnConstants.Name + i;
            u.LastName = 'of Arendelle';
            u.Email = 'elsa@disney.com';
            u.Alias = 'elsa' + i;
            u.Username = 'elsa' + i + '@disney.com';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = strUserTimeZoneSidKey;
            u.ProfileID = p.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            return u;
        } catch (Exception e)
        {
            return null;
        }
    }
	
	public static User insertUserWithProfile(Integer i, String profile) {
        User user;
        if (systemAdmin == null) {
            systemAdmin = [Select id, name from User where id = :Userinfo.getUserid()];
        }
        System.runAs(systemAdmin){
            user = buildUserWithProfile(i, profile);
            if (user != null)
            {
                insert user;
            }
        }
		return user;
    }

    /*
     * Name : getSalesOrg
     * Purpose : This Method has been created to fetch the picklist from Global Sales Org.
     * See : All the Test Factory relevant for Sales Org
     * Note : Sales Org uses a global picklist which must be deployed with data in target environment before running
     * Sales Org dependent class.
    */
    public static List<String> getSalesOrg() {
        if (lstSalesOrg == null)
        {
            lstSalesOrg = new List<String>();
            Schema.DescribeFieldResult F = User.ACCL__Sales_Org__c.getDescribe();
            for (Schema.PicklistEntry P : F.getPicklistValues())
            {
                lstSalesOrg.add(p.getValue());
            }
        }
        return lstSalesOrg;
    }

    public static String getDefaultSalesOrg() {
        return getSalesOrg()[0];
    }

    public static void insertUserPermissionset(User user, String permissionSet) {

        if (systemAdmin == null) {
            systemAdmin = [Select id, name from User where id = :Userinfo.getUserid()];
        }
        System.runAs(systemAdmin){
            PermissionSetAssignment psa = buildAssignUserPermissionset(user, permissionSet);
            if (psa != null)
            {
                insert psa;
            }
        }
    }

    public static PermissionSetAssignment buildAssignUserPermissionset(User user, String permissionSet) {
        PermissionSetAssignment psa;
        if (systemAdmin == null) {
            systemAdmin = [Select id, name from User where id = :Userinfo.getUserid()];
        }

        try
        {
            System.runAs(systemAdmin){
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permissionSet];
                // Permission Set Assigment for the user.
                psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = user.id);

            }

        } catch (Exception e)
        {
            psa = null;

        }
        return psa;
    }

    public static User buildUser(Integer i) {
        Profile p = [select id from profile where name='System Administrator' Limit 1];
        String strUserTimeZoneSidKey = getLoggedInUserTimeZoneSidKey();
        User u = new User();
        u.FirstName = AddOnConstants.NAME + i;
        u.LastName = 'of Arendelle';
        u.Email = 'elsa@disney.com';
        u.Alias = 'elsa' + i;
        u.Username = AddOnConstants.NAME + i + '@disney.com';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = strUserTimeZoneSidKey;
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        return u;
    }

    public static User buildUserWithProfileAndSalesOrg(
    Integer i,
    String Profile,
    String salesOrg
  ) {
    try {
      Profile p = [SELECT id FROM profile WHERE name = :Profile LIMIT 1];
      String strUserTimeZoneSidKey = getLoggedInUserTimeZoneSidKey();
      User u = new User();
      u.FirstName = AddOnConstants.Name + i;
      u.LastName = 'of Arendelle';
      u.Email = 'elsa@disney.com';
      u.Alias = 'elsa' + i;
      u.Username = 'elsa' + i + '@disney.com';
      u.LocaleSidKey = 'en_US';
      u.TimeZoneSidKey = strUserTimeZoneSidKey;
      u.ProfileID = p.id;
      u.LanguageLocaleKey = 'en_US';
      u.EmailEncodingKey = 'UTF-8';
      u.ACCL__Sales_Org__c = salesOrg;
      return u;
    } catch (Exception e) {
      return null;
    }
  }


}