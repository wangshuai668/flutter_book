import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI记账本',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}

// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double total = 0;
  List<Map> list = [];

  // 读取数据
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('list');
    if (data != null) {
      List items = json.decode(data);
      List<Map> newList = List<Map>.from(items);
      double sum = 0;
      for (var i in newList) {
        sum += double.tryParse(i['money'].toString()) ?? 0;
      }
      setState(() {
        list = newList;
        total = sum;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI记账本"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "本月总支出：¥${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                btn(
                  icon: Icons.add_circle,
                  text: "记一笔",
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddPage()),
                    );
                    loadData();
                  },
                ),
                btn(
                  icon: Icons.list_alt,
                  text: "账单",
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ListPage()),
                    );
                    loadData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget btn({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 50, color: Colors.blue),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}

// 记一笔
class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final moneyCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  Future<void> save() async {
    final money = moneyCtrl.text.trim();
    final note = noteCtrl.text.trim();
    if (money.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('list');
    List list = [];
    if (data != null) list = json.decode(data);

    list.add({
      'money': money,
      'note': note,
      'time': DateTime.now().toString().substring(0, 16),
    });

    await prefs.setString('list', json.encode(list));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("记一笔")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: moneyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "金额",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: "备注",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text("保存账单"),
            ),
          ],
        ),
      ),
    );
  }
}

// 账单列表
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map> list = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('list');
    if (data != null) {
      List items = json.decode(data);
      setState(() {
        list = List<Map>.from(items);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("账单列表")),
      body: list.isEmpty
          ? const Center(child: Text("暂无记录"))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final item = list[i];
                return ListTile(
                  title: Text("¥${item['money']}"),
                  subtitle: Text(item['note'] ?? '无备注'),
                  trailing: Text(item['time'] ?? ''),
                );
              },
            ),
    );
  }
}