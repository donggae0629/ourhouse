import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("슬기로운 하숙 생활"),
            centerTitle: true
        ),
          body: Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width:200,height: 100
                      )
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width:200, height: 200,
                        child: Center(
                            child: Image.asset("assets/dinner.jpg")
                        )

                      ),
                      SizedBox(
                          child: Text("식사")
                      )
                    ],
                  ),
                  SizedBox(
                    width:20
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width:180, height: 200,
                        child: Center(
                            child: Image.asset("assets/washclothes.jpg")
                        )
                      ),
                      SizedBox(
                        child: Text("세탁기 사용")
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                  width: 50, height: 110
              ),
              Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 200, height: 200,
                        child: Center(
                          child: Image.asset("assets/siren.jpg")
                        )
                      ),
                      Text("비상호출")
                    ],
                  ),
                  SizedBox(
                    width:30
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 170, height: 200,
                        child: Center(
                          child: Text("건의")
                        )
                      )
                    ],
                  )
                ],
              )
            ],
          )
        )
    );
  }
}

