class Datetime {
  String getServerDatetime(String year, String month, String day) {
    //2011-10-12T12:12:32Z
    String ret =
        "$year-${month.length == 1 ? "0$month" : month}-${day.length == 1 ? "0$day" : day}T00:00:00Z";
    return ret;
  }

  String getAgeFromDatetime(String datetime) {
    final DateTime parsedDt = DateTime.parse(datetime);
    final now = DateTime.now();
    return (now.year - parsedDt.year).toString();
  }

  String getSimpleDateFromServerDatetime(String datetime) {
    try {
      final DateTime parsedDt = DateTime.parse(datetime);
      final String year = parsedDt.year.toString();
      final String month = parsedDt.month < 10
          ? "0${parsedDt.month.toString()}"
          : parsedDt.month.toString();
      final String day = parsedDt.day < 10
          ? "0${parsedDt.day.toString()}"
          : parsedDt.day.toString();
      return "$year.$month.$day";
    } catch (err) {
      return "";
    }
  }
}
