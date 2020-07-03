import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:signalr_client/signalr_client.dart';
class Forecast {
  final String date;
  final int temperatureC;
  final int temperatureF;
  final String summary;
  Forecast({this.date, this.temperatureC, this.temperatureF, this.summary});
  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
        date: json['date'],
        temperatureC: json['temperatureC'],
        temperatureF: json['temperatureF'],
        summary: json['summary']);
  }
}
void main() {
  runApp(AppWebsocket());
}
class AppWebsocket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SocketStream());
  }
}
class SocketStream extends StatefulWidget {
  @override
  _SocketStreamState createState() => _SocketStreamState();
}
class _SocketStreamState extends State<SocketStream> {
  String socketStreamResponse = '';
  @override
  void initState() {
    _startWebsocket();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(8.0),
      child: Center(
          child: Text(socketStreamResponse, style: TextStyle(fontSize: 10))),
    );
  }
  _startWebsocket() async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message} ${rec.object}');
    });
    final transportProtLogger = Logger('SignalR - transport');
    final serverUrl = 'http://websocket.fansupport.dijitalsahne.com/scoreboard';
    final httpOptions = new HttpConnectionOptions(logger: transportProtLogger);
    final hubConnection = HubConnectionBuilder().withUrl(serverUrl, options: httpOptions).configureLogging(transportProtLogger).build();
    hubConnection.on('forecast', (arguments) {
      
      List<Forecast> o = List<Forecast>.from(arguments.map((i) => Forecast.fromJson(i)));
      
      print(o.toString());
      setState(() {
        socketStreamResponse = o[0].summary.toString();
      });
    });
    await hubConnection.start();
  }
}