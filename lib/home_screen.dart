import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formatter = DateFormat('yyyy-MM-dd');

  // By default today is selected
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final date = _formatter.format(_selectedDate);

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Виберіть дату:",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2022, 2, 24),
                          lastDate: DateTime.now());

                      if (date == null) {
                        return;
                      }

                      setState(() => _selectedDate = date);
                    },
                    child: Text(date),
                  ),
                ],
              ),
              const SizedBox(height: 150),
              // TODO: Display war stats
              FutureBuilder(
                future: getStats(date),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;

                  return Center(
                    child: Column(
                      children: [
                        const Text(
                          "Втрати окупанта",
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Утилізовано орків: ${data[0]}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlueAccent),
                        ),
                        Text(
                          "Підірвано танчиків: ${data[1]}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlueAccent),
                        ),
                        Text(
                          "Впало літаків: ${data[2]}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlueAccent),
                        ),
                        Text(
                          "Впало гелікоптерів: ${data[3]}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlueAccent),
                        ),
                        const SizedBox(height: 150),
                        Container(
                          width: 250,
                          height: 250,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Image.network(
                              "https://i1.sndcdn.com/artworks-pFXchTImzWbxzmBC-vyyy4w-t240x240.jpg"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<int>> getStats(String date) async {
    const url = "https://russianwarship.rip/api/v2";
    final date = _formatter.format(_selectedDate);
    final uri = Uri.parse("$url/statistics/$date");
    final response = await get(uri);
    final json = jsonDecode(response.body);
    final personnel = json['data']['stats']['personnel_units'] as int;
    final tanks = json['data']['stats']['tanks'] as int;
    final planes = json['data']['stats']['planes'] as int;
    final helicopters = json['data']['stats']['helicopters'] as int;
    return [
      personnel,
      tanks,
      planes,
      helicopters,
    ];
  }
}
