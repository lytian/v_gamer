import 'package:flutter/material.dart';
import 'package:v_gamer/gamer/game_widget.dart';
import 'package:v_gamer/gamer/gamer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '经典游戏合集',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("经典游戏"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 160,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => GamePage(type: GameTypes.teris),
                    ),
                  );
                },
                child: Card(
                  color: Colors.blueAccent,
                  child: Center(
                    child: Text('俄罗斯方块', style: TextStyle(fontSize: 20)),
                  )
                )
              ),
            ),
            SizedBox(
              height: 160,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => GamePage(type: GameTypes.snake),
                    ),
                  );
                },
                child: Card(
                  color: Colors.redAccent,
                  child: Center(
                    child: Text('贪吃蛇', style: TextStyle(fontSize: 20)),
                  )
                )
              )
            ),
          ]
        ),
      ),
    );
  }
}