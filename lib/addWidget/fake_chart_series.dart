class FakeChartSeries {
  Map<DateTime, double> createLineData(double factor) {
    Map<DateTime, double> data = {};

    for (int c = 50; c > 0; c--) {
      data[DateTime.now().subtract(Duration(minutes: c))] =
          c.toDouble() * factor;
    }

    return data;
  }

  Map<DateTime, double> createLineAlmostSaveValues() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 24.9;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 25.0;

    return data;
  }

  Map<DateTime, double> createLine1() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 37.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 37.9;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 40.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 37.0;

    return data;
  }

  Map<DateTime, double> createLine2() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 105))] = 37.2;
    data[DateTime.now().subtract(Duration(minutes: 100))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 95))] = 37.0;
    data[DateTime.now().subtract(Duration(minutes: 90))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 85))] = 37.4;
    data[DateTime.now().subtract(Duration(minutes: 80))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 75))] = 37.8;
    data[DateTime.now().subtract(Duration(minutes: 70))] = 37.7;
    data[DateTime.now().subtract(Duration(minutes: 65))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 60))] = 38.5;
    data[DateTime.now().subtract(Duration(minutes: 55))] = 38.0;
    data[DateTime.now().subtract(Duration(minutes: 50))] = 38.1;
    data[DateTime.now().subtract(Duration(minutes: 45))] = 38.0;
    data[DateTime.now().subtract(Duration(minutes: 40))] = 38.3;
    data[DateTime.now().subtract(Duration(minutes: 35))] = 38.4;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 25))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 37.9;
    data[DateTime.now().subtract(Duration(minutes: 10))] = 40.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 37.0;
    return data;
  }

  Map<DateTime, double> createLine2_2() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 105))] = 37.2;
    data[DateTime.now().subtract(Duration(minutes: 100))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 95))] = 37.0;
    data[DateTime.now().subtract(Duration(minutes: 90))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 85))] = 37.4;
    data[DateTime.now().subtract(Duration(minutes: 80))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 75))] = 37.8;
    data[DateTime.now().subtract(Duration(minutes: 70))] = 37.7;
    data[DateTime.now().subtract(Duration(minutes: 65))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 60))] = 38.5;
    data[DateTime.now().subtract(Duration(minutes: 55))] = 38.0;
    data[DateTime.now().subtract(Duration(minutes: 50))] = 38.1;
    data[DateTime.now().subtract(Duration(minutes: 45))] = 38.0;
    data[DateTime.now().subtract(Duration(minutes: 40))] = 38.3;
    data[DateTime.now().subtract(Duration(minutes: 35))] = 38.4;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 25))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 37.9;
    data[DateTime.now().subtract(Duration(minutes: 10))] = 40.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 37.0;
    return data;
  }

  Map<DateTime, double> createLine3() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(days: 6))] = 1100.0;
    data[DateTime.now().subtract(Duration(days: 5))] = 2233.0;
    data[DateTime.now().subtract(Duration(days: 4))] = 3744.0;
    data[DateTime.now().subtract(Duration(days: 3))] = 3100.0;
    data[DateTime.now().subtract(Duration(days: 2))] = 2900.0;
    data[DateTime.now().subtract(Duration(days: 1))] = 1100.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 3700.0;
    return data;
  }
}
