// ignore_for_file: prefer_const_constructors

/*
 https://www.youtube.com/watch?v=HQ_ytw58tC4&t=20s&ab_channel=MitchKoko
 https://www.figma.com/file/UFtYbWaZOjjyK0OkjN1eHL/Den%C3%ADk-ZZA?type=design&node-id=0-1&mode=design&t=ljxD6YfuybVZWLmH-0
 */

/* 

REFORMATING IN VISUAL CODE -> SHIFT + ALT + F

1) PADDING 
padding: EdgeInsets.only(left: 100,bottom: 50),
EdgeInsets.all(60),
EdgeInsets.symmetric(horizontal: 25,vertical: 30),


2) TEXT
Text(
            "Přihlášení",
            style: TextStyle(
              color: Colors.green, // changing color of the text
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )
  
3) ICONS
Icon(
            Icons.favorite,
            color: Colors.red,
            size: 50,
          )



4) WIDGETS - CENTER, COLUMN, ROW, LISTVIEW, GRIDVIEW, GESTURE DETECTOR


5) CONTAINER
child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // rounded fields
          ),
          padding: EdgeInsets.all(30),
          child: Icon(
            Icons.favorite,
            color: Colors.red,
            size: 50,
          ),
        )

6) APP-BAR
 appBar: AppBar(
            title: Text("Hello World"),
            elevation: 0, // no shadows
            leading: Icon(Icons.menu),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(Icons.logout))
            ] // logout icon,
            )


7) COLUMN
  body: Column(
          -mainAxisAlignment: MainAxisAlignment.center,
          -mainAxisAlignment: MainAxisAlignment.end,
          -mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          -crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // box 1
            Container(
              height: 200, 
              width: 200, 
              color: Colors.deepPurple),

            // box 2
            Container(
              height: 200,
              width: 200,
              color: Colors.deepPurple[400]),

              EXPANDED WIDGET
            // box 3
            Expanded(
              flex: 3, // RATIO OF THE BOXES
                child: Container(
              color: Colors.deepPurple[200],
            )),
          ],
        )

        8) LISTVIEW - for scrolling 

        body: ListView(
          scrollDirection: Axis.horizontal, FOR HORIZONTAL SCROLLING, BUT CHANGE HEIGHT WITH WIDTH
          children: [
            // box 1
            Container(
              height: 350,
              color: Colors.deepPurple,
            ),

            // box 2
            Container(
              height: 350,
              color: Colors.deepPurple[200],
            ),

            // box 3

            Container(
              height: 350,
              color: Colors.deepPurple[400],
            ),
          ],
        ),


        // LISTVIEW FROM 0 TO 9 

        body: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => ListTile(
            title: Text(index.toString()),
          ),
          

          // OWN LIST
          List names = ["Ester", "Terka", "Zaneta", "Dan", "Vojta"];


        body: ListView.builder(
          itemCount: names.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(names[index]),
          ),
        ),

        ),


        // 9) GRIDVIEW

        body: GridView.builder(
          itemCount: 64,
          gridDelegate: 
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), // 8 block in 1 row
        itemBuilder: (context,index) => Container(
          color: Colors.deepPurple,
          margin: EdgeInsets.all(2),)
        ),


        // 10) STACK

         body: Stack(
            alignment: Alignment.center,
        children: [
          // big box
          Container(
            height: 300,
            width: 300,
            color: Colors.deepPurple,
          ),
          // medium box
          Container(
            height: 200,
            width: 200,
            color: Colors.deepPurple[400],
          ),

          // small box
          Container(
            height: 100,
            width: 100,
            color: Colors.deepPurple[200],
          )
        ],
      )


      11) GESTURE DETECTOR
      
         child: GestureDetector(
              onTap: () {
                print("Haha");
              },
              child: Container(
                height: 200,
                width: 200,
                color: Colors.deepOrange[300],
                child: Center(child: Text("Tap me"),
            
                ),
              ),
            ),
 */

import 'package:denik_zza/screens/actions/profile.dart';
import 'package:denik_zza/screens/login/login_page.dart';
import 'package:denik_zza/screens/login/register_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // for deleting the debug text
      home: Login(),
      routes: {
        '/register_screen':(context) => RegisterScreen(),
        //'/profile_screen':(context) => Profile(),
      },
    );
  }
}
