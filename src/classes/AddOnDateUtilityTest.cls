@isTest
private class AddOnDateUtilityTest {
  @isTest
  private static void dateRangesOverlap_startBefore_yes() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2018-01-01');
    Date from2 = Date.valueOf('2016-06-06');
    Date thru2 = Date.valueOf('2017-06-06');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates overlap');
  }

  @isTest
  private static void dateRangesOverlap_endsAfter_yes() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2018-01-01');
    Date from2 = Date.valueOf('2017-06-06');
    Date thru2 = Date.valueOf('2018-06-06');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates overlap');
  }

  @isTest
  private static void dateRangesOverlap_wrap_yes() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2018-01-01');
    Date from2 = Date.valueOf('2016-06-06');
    Date thru2 = Date.valueOf('2018-06-06');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates overlap');
  }

  @isTest
  private static void dateRangesOverlap_inside_yes() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2018-01-01');
    Date from2 = Date.valueOf('2017-06-06');
    Date thru2 = Date.valueOf('2017-08-08');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates overlap');
  }

  @isTest
  private static void dateRangesOverlap_endsBefore_no() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2018-01-01');
    Date from2 = Date.valueOf('2015-06-06');
    Date thru2 = Date.valueOf('2016-06-06');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(!overlap, 'The dates do not overlap');
  }

  @isTest
  private static void dateRangesOverlap_startsAfter_no() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2018-01-01');
    Date from2 = Date.valueOf('2019-06-06');
    Date thru2 = Date.valueOf('2020-06-06');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(!overlap, 'The dates do not overlap');
  }

  @isTest
  private static void dateRangesOverlap_startAtSameDate_no() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2017-12-31');
    Date from2 = Date.valueOf('2017-01-01');
    Date thru2 = Date.valueOf('2017-06-30');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates do overlap');
  }

  @isTest
  private static void dateRangesOverlap_endAtSameDate_no() {
    // Arrange
    Date from1 = Date.valueOf('2017-07-01');
    Date thru1 = Date.valueOf('2017-12-31');
    Date from2 = Date.valueOf('2017-01-01');
    Date thru2 = Date.valueOf('2017-12-31');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates do overlap');
  }

  @isTest
  private static void dateRangesOverlap_equalTimefrmaes_yes() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2017-12-31');
    Date from2 = Date.valueOf('2017-01-01');
    Date thru2 = Date.valueOf('2017-12-31');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates do overlap');
  }

  @isTest
  private static void dateRangesOverlap_OneDayOverlap_yes() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2018-01-01');
    Date from2 = Date.valueOf('2018-01-01');
    Date thru2 = Date.valueOf('2018-12-31');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(overlap, 'The dates do overlap');
  }

  @isTest
  private static void dateRangesOverlap_nextToEachOther_no() {
    // Arrange
    Date from1 = Date.valueOf('2017-01-01');
    Date thru1 = Date.valueOf('2017-12-31');
    Date from2 = Date.valueOf('2018-01-01');
    Date thru2 = Date.valueOf('2018-12-31');

    // Act
    Boolean overlap = AddOnDateUtility.dateRangesOverlap(from1, thru1, from2, thru2);

    // Assert
    System.assert(!overlap, 'The dates do not overlap');
  }

  @isTest
  private static void countYears_sameYear_counts1() {
    // Arrange
    Date date1 = Date.newInstance(2017, 3, 3);
    Date date2 = Date.newInstance(2017, 3, 4);

    // Act
    Integer years = AddOnDateUtility.countYears(date1, date2);

    // Assert
    System.assertEquals(1, years);
  }

  @isTest
  private static void countYears_differentYears_counts11() {
    // Arrange
    Date date1 = Date.newInstance(2017, 3, 3);
    Date date2 = Date.newInstance(2027, 3, 4);

    // Act
    Integer years = AddOnDateUtility.countYears(date1, date2);

    // Assert
    System.assertEquals(11, years);
  }

  @isTest
  private static void countYears_differentYearsInverseOrder_counts11() {
    // Arrange
    Date date1 = Date.newInstance(2027, 3, 3);
    Date date2 = Date.newInstance(2017, 3, 4);

    // Act
    Integer years = AddOnDateUtility.countYears(date1, date2);

    // Assert
    System.assertEquals(11, years);
  }

  @isTest
  private static void countYears_sameDate_counts1() {
    // Arrange
    Date date1 = Date.newInstance(2027, 3, 3);

    // Act
    Integer years = AddOnDateUtility.countYears(date1, date1);

    // Assert
    System.assertEquals(1, years);
  }

  @isTest
  private static void countYears_longFormat_counts11() {
    // Arrange
    Date date1 = Date.newInstance(2017, 3, 3);
    Date date2 = Date.newInstance(2027, 3, 4);

    // Act
    Integer years = AddOnDateUtility.countYears(
      AddOnDateUtility.toUnixTimeStampMS(date1),
      AddOnDateUtility.toUnixTimeStampMS(date2)
    );

    // Assert
    System.assertEquals(11, years);
  }

  @isTest
  private static void toEndOfMonth_returnEndOfMonth() {
    // Arrange
    Date date1 = Date.newInstance(2018, 2, 5);

    // Act
    Date result = AddOnDateUtility.toEndOfMonth(date1);

    // Assert
    System.assertEquals(Date.newInstance(2018, 2, 28), result);
  }

  @isTest
  private static void dateFrom1970() {
    // Arrange
    Long todayDate = AddOnDateUtility.getCurrentTimeInSecondsSince1970();
    Long todayDatePlusOneSecond =
      AddOnDateUtility.getCurrentTimeInSecondsSince1970() + 1;

    // Assert
    System.assertEquals(todayDatePlusOneSecond > todayDate, true);
  }

  @isTest
  private static void toUnixTimeStampMS() {
    // Arrange
    Long todayDate = AddOnDateUtility.toUnixTimeStampMS(System.today());
    Long todayDatePlusOneSecond =
      AddOnDateUtility.toUnixTimeStampMS(System.today()) + 1000;

    // Assert
    System.assertEquals(todayDatePlusOneSecond > todayDate, true);
  }
  @isTest
  private static void toUnixTimeStampMSFromDateTime() {
    // Arrange
    Long d1 = AddOnDateUtility.toUnixTimeStampMS(System.now());
    Long d2 = AddOnDateUtility.toUnixTimeStampMS(System.now()) + 1000;

    // Assert
    System.assertEquals(d2 > d1, true);
  }
  @isTest
  private static void countMonthsBetweenTwoDates() {
    // Arrange
    Long d1 = AddOnDateUtility.toUnixTimeStampMS(Date.newInstance(2019, 3, 6));
    Long d2 = AddOnDateUtility.toUnixTimeStampMS(Date.newInstance(2019, 5, 6));
    Integer numOfMonths = AddOnDateUtility.countMonthsBetweenTwoDates(d1, d2);

    // Assert
    System.assertEquals(numOfMonths, 3);
  }
  @isTest
  private static void minDate() {
    // Arrange
    Date d1 = Date.newInstance(2019, 3, 6);
    Date d2 = Date.newInstance(2019, 5, 6);

    // Assert
    System.assertEquals(AddOnDateUtility.minDate(d1, d2), d1);
  }
  @isTest
  private static void maxDate() {
    // Arrange
    Date d1 = Date.newInstance(2019, 3, 6);
    Date d2 = Date.newInstance(2019, 5, 6);

    // Assert
    System.assertEquals(AddOnDateUtility.maxDate(d1, d2), d2);
  }
  @isTest
  private static void toDateTimeFromUnix() {
    // Arrange
    Long d1 = AddOnDateUtility.toUnixTimeStampMS(Date.newInstance(2019, 3, 6));
    System.debug('date1: ' + d1);
    // Assert
    System.assertEquals(
      AddOnDateUtility.toDateTime(d1),
      DateTime.newInstanceGMT(2019, 3, 6)
    );
  }
  @isTest
  private static void toDateFromString() {
    // Arrange
    String d1 = '2019-3-6';

    // Assert
    System.assertEquals(AddOnDateUtility.toDate(d1), Date.newInstance(2019, 3, 6));
  }

  @isTest
  private static void toDateFromObject() {
    // Arrange
    Object d1 = null;
    // Assert
    System.assertEquals(AddOnDateUtility.toDate(d1), null);

    // Arrange
    d1 = (Object) String.valueOf('2019-03-06');
    // Assert
    System.assertNotEquals(AddOnDateUtility.toDate(d1), null);

    // Arrange
    d1 = (Object) Integer.valueOf(
      Datetime.newInstanceGmt(2019, 3, 6).getTime()
    );
    // Assert
    System.assertNotEquals(AddOnDateUtility.toDate(d1), null);

    // Arrange
    d1 = (Object) AddOnDateUtility.toUnixTimeStampMS(Date.newInstance(2019, 3, 6));
    // Assert
    System.assertNotEquals(AddOnDateUtility.toDate(d1), null);

    // Arrange
    d1 = (Object) Date.newInstance(2019, 3, 6);
    // Assert
    System.assertNotEquals(AddOnDateUtility.toDate(d1), null);

    // Arrange
    d1 = (Object) DateTime.newInstance(2019, 3, 6, 10, 10, 10);
    // Assert
    System.assertEquals(AddOnDateUtility.toDate(d1), AddOnConstants.MIN_DATE);
  }
  @isTest
  private static void toDateTimeFromObject() {
    // Arrange
    Object d1 = null;
    // Assert
    System.assertEquals(AddOnDateUtility.toDateTime(d1), null);

    // Arrange
    d1 = (Object) String.valueOf('2019-03-06 00:00:00');
    // Assert
    System.assertNotEquals(AddOnDateUtility.toDateTime(d1), null);

    // Arrange
    d1 = (Object) AddOnDateUtility.toUnixTimeStampMS(Date.newInstance(2019, 3, 6));
    // Assert
    System.assertNotEquals(AddOnDateUtility.toDateTime(d1), null);

    // Arrange
    d1 = (Object) DateTime.newInstance(2019, 3, 6, 10, 10, 10);
    // Assert
    System.assertNotEquals(AddOnDateUtility.toDateTime(d1), null);

    // Arrange
    d1 = (Object) new List<Integer>{ 1, 2, 3 };
    // Assert
    System.assertEquals(AddOnDateUtility.toDateTime(d1), AddOnConstants.MIN_DATE);
  }
}