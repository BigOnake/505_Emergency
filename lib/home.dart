import 'package:wakelock/wakelock.dart';

import 'number.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  final textController = TextEditingController();

  //Timer, controller
  late AnimationController _controller;
  int levelClock = 180;

  //Saving phoneNumber
  static const String NUM_KEY = "EmergencyNumber";
  late String emergencyNumber = "911";

  void _incrementCounter() {
    setState(() {
      _controller.reset();
      _controller.forward();
    });
  }

  void pauseTimer() {
    _controller.reset();
  }

  @override
  void dispose() {
    textController.dispose();
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // Loads emergencyNumber before anything else loads up
  @override
  void initState() {
    loadEmergencyNumber();
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Wakelock.enable();

    _controller = AnimationController(
        vsync: this,
        duration: const Duration(
            seconds: 305) // gameData.levelClock is a user entered number elsewhere in the applciation
        );
  }

  void loadEmergencyNumber() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      globals.emergencyNumber = pref.getString(NUM_KEY) ?? "911"; //Assigns emergencyNumber with the value behind NUM_KEY. If null, assigns "911"
    });
  }

  void updateEmergencyNumber(String textController) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    globals.emergencyNumber = textController;
    pref.setString(NUM_KEY, globals.emergencyNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Emergency 505",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton(
                    onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Text('Type in your Emergency Number', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: textController,
                                      //obscureText: true,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'EmergencyNumber',
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        updateEmergencyNumber(
                                            textController.text);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                    child: Text("Add Emergency Contact", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),))),
            const SizedBox(
              height: 180,
            ),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: Countdown(
                animation: StepTween(
                  begin: 305, // THIS IS A USER ENTERED NUMBER
                  end: 0,
                ).animate(_controller),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        //FloatingActionButton(
        onPressed: pauseTimer,
        //tooltip: 'Cancel',
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  Animation<int> animation;
  bool isCalled = false;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    //print('animation.value  ${animation.value} ');
    //print('inMinutes ${clockTimer.inMinutes.toString()}');
    //print('inSeconds ${clockTimer.inSeconds.toString()}');
    //print('inSeconds.remainder ${clockTimer.inSeconds.remainder(60).toString()}');

    if (clockTimer.inSeconds == 0 && !isCalled) {
      FlutterPhoneDirectCaller.callNumber(globals.emergencyNumber);
      isCalled = true;
    }

    if (clockTimer.inSeconds <= 35 && !isCalled) {
      HapticFeedback.heavyImpact();
    }

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 110,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
