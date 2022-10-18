/**
 * Utility class to make comparisons and operations with dates
 */
public with sharing class AddOnDateUtility {
  /**
   * @return the minimum among date1 and date2
   */
  public static Date minDate(Date date1, Date date2) {
    return date1 < date2 ? date1 : date2;
  }

  /**
   * @return the maximum among date1 and date2
   */
  public static Date maxDate(Date date1, Date date2) {
    return date1 > date2 ? date1 : date2;
  }

  /**
   * Check if two date ranges overlap in time (that is, there is a fraction of time
   * when the two date ranges exist.
   */
  public static Boolean dateRangesOverlap(
    Date from1,
    Date thru1,
    Date from2,
    Date thru2
  ) {
    return from1 <= thru2 && from2 <= thru1;
  }

  /** Converts a generic object to a Date
   *  @name toDate
   *  @param o The object to be converted to a Date
   *  @return Date The date
   */
  public static Date toDate(Object o) {
    if (o == null) {
      return null;
    } else if (o instanceof Date) {
      return (Date) o;
    } else if (o instanceof Long) {
      return toDate((Long) o);
    } else if (o instanceof Integer) {
      return toDate((Integer) o);
    } else if (o instanceof String) {
      return toDate((String) o);
    } else {
      return AddOnConstants.MIN_DATE;
    }
  }

  /**
   * Converts a UnixTimeStamp (in milliseconds) to a Date
   * @param unixTimeStampMS The UnixTimeStamp in milliseconds
   * @return The date with timezone GMT
   */
  public static Date toDate(Long unixTimeStampMS) {
    DateTime dt = DateTime.newInstance(unixTimeStampMS);
    return dt.dateGmt();
  }

  public static Datetime toDatetime(Object o) {
    if (o == null) {
      return null;
    } else if (o instanceof Datetime) {
      return (Datetime) o;
    } else if (o instanceof Date) {
      Date d = (Date) o;
      Time timeMidnight = Time.newInstance(0, 0, 0, 0);
      return Datetime.newInstanceGmt(d, timeMidnight);
    } else if (o instanceof Long) {
      return toDatetime((Long) o);
    } else if (o instanceof String) {
      return Datetime.valueOf((String) o);
    } else {
      return AddOnConstants.MIN_DATE;
    }
  }

  /**
   * Converts a UnixTimeStamp (in milliseconds) to a Date
   * @param unixTimeStampMS The UnixTimeStamp in milliseconds
   * @return The date with timezone GMT
   */
  public static Date toDate(Integer unixTimeStampMS) {
    DateTime dt = DateTime.newInstance(unixTimeStampMS);
    return dt.dateGmt();
  }

  /**
   * Converts a string formatted date to a Date
   * @param dateString The date formatted as a string
   * @return The date with timezone GMT
   */
  public static Date toDate(String dateString) {
    return Date.valueOf(dateString);
  }

  /**
   * Converts a UnixTimeStamp (in milliseconds) to a Datetime
   * @param unixTimeStampMS The UnixTimeStamp in milliseconds
   * @return The datetime with timezone GMT
   */
  public static Datetime toDateTime(Long unixTimeStampMS) {
    return DateTime.newInstance(unixTimeStampMS);
  }

  /**
   * Converts a date to a UnixTimeStamp (in milliseconds)
   * @param d The date to be converted
   * @return The UnixTimeStamp in milliseconds
   */
  public static Long toUnixTimeStampMS(Date d) {
    Long dateUnixTimeStamp = (d == null)
      ? null
      : Datetime.newInstanceGmt(d.year(), d.month(), d.day()).getTime();
    return dateUnixTimeStamp;
  }

  /**
   * Converts a datetime to a UnixTimeStamp (in milliseconds)
   * @param dt The datetime to be converted
   * @return The UnixTimeStamp in milliseconds
   */
  public static Long toUnixTimeStampMS(DateTime dt) {
    Long dateUnixTimeStamp = (dt == null)
      ? null
      : Datetime.newInstanceGmt(dt.date(), dt.time()).getTime();
    return dateUnixTimeStamp;
  }

  /**
   * Return the number of different years in a date range
   *
   * For example, from 3/3/2017 to 4/3/2017 would be 1 year,
   * from 30/12/2017 to 2/1/2018 would be 2 years.
   *
   * @param date1 One of the dates
   * @param date2 The other date
   * @return the absolute number of different years beetwee the two dates
   */
  public static Integer countYears(Date date1, Date date2) {
    Date firstDate = (date1 < date2) ? date1 : date2;
    Date secondDate = (date1 < date2) ? date2 : date1;

    return secondDate.year() - firstDate.year() + 1;
  }

  /**
   * Return the number of different years in a date range
   *
   * For example, from 3/3/2017 to 4/3/2017 would be 1 year,
   * from 30/12/2017 to 2/1/2018 would be 2 years.
   *
   * @param date1 One of the dates
   * @param date2 The other date
   * @return the number of different years beetwee the two dates
   */
  public static Integer countYears(Long date1, Long date2) {
    Date dateDate1 = toDate(date1);
    Date dateDate2 = toDate(date2);

    return countYears(dateDate1, dateDate2);
  }

  /**
   * This method calculate the number of months between two dates
   * @param date1 Long one of the dates
   * @param date2 Long the other date
   * @return number of months between two dates
   */
  public static Integer countMonthsBetweenTwoDates(Long date1, Long date2) {
    Date dateDate1 = toDate(date1);
    Date dateDate2 = toDate(date2);

    return Math.abs(dateDate1.monthsBetween(dateDate2)) + 1;
  }

  /**
   * This method return the end of the month of the date passed as parameter
   * @param date1 Date to calculate the end of the month
   */
  public static Date toEndOfMonth(Date date1) {
    Integer noOfDays = Date.daysInMonth(date1.year(), date1.month());

    return Date.newInstance(date1.year(), date1.month(), noOfDays);
  }

  /**
	* Method to get current time in seconds since 1970
	+ @ return Long number of second
	*/
  public static Long getCurrentTimeInSecondsSince1970() {
    return DateTime.now().getTime() / 1000;
  }
}