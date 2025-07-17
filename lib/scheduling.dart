import 'package:flutter/material.dart';


class SchedulingPage extends StatefulWidget{
  const SchedulingPage({super.key});

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();

}

class _SchedulingPageState extends State<SchedulingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 14, 14),
        title: const Text('Scheduling Page', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text('Scheduling Page Content Here', style: TextStyle(fontSize: 24)),
      ),
    );

  }

}