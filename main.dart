import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const DailyLifeApp());

class DailyLifeApp extends StatelessWidget {
  const DailyLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

String todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String monthKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}';
}

int habitStreak(List<String> days) {
  final set = days.toSet();
  var streak = 0;
  var day = DateTime.now();
  // If today is not checked yet, the streak counts from yesterday.
  if (!set.contains(todayKey())) {
    day = day.subtract(const Duration(days: 1));
  }
  while (true) {
    final key =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    if (set.contains(key)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  // Tasks: {title: String, done: bool}
  List<Map<String, dynamic>> _tasks = [];
  // Habits: {name: String, days: List<String>}
  List<Map<String, dynamic>> _habits = [];
  // Expenses: {amount: double, category: String, note: String, date: String}
  List<Map<String, dynamic>> _expenses = [];

  final _taskController = TextEditingController();
  final _habitController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Food';

  static const _categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _habitController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = _decodeList(prefs.getString('tasks'));
      _habits = _decodeList(prefs.getString('habits'));
      _expenses = _decodeList(prefs.getString('expenses'));
    });
  }

  List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(_tasks));
    await prefs.setString('habits', jsonEncode(_habits));
    await prefs.setString('expenses', jsonEncode(_expenses));
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _tasks.insert(0, {'title': title, 'done': false});
      _taskController.clear();
    });
    _save();
  }

  void _addHabit() {
    final name = _habitController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _habits.insert(0, {'name': name, 'days': <String>[]});
      _habitController.clear();
    });
    _save();
  }

  void _toggleHabitToday(int index) {
    final days = List<String>.from(_habits[index]['days'] as List);
    final today = todayKey();
    if (days.contains(today)) {
      days.remove(today);
    } else {
      days.add(today);
    }
    setState(() => _habits[index]['days'] = days);
    _save();
  }

  void _addExpense() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;
    setState(() {
      _expenses.insert(0, {
        'amount': amount,
        'category': _category,
        'note': _noteController.text.trim(),
        'date': todayKey(),
      });
      _amountController.clear();
      _noteController.clear();
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_tasksPage(), _habitsPage(), _expensesPage()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyLife'),
        centerTitle: true,
      ),
      body: pages[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department_outlined), label: 'Habits'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Expenses'),
        ],
      ),
    );
  }

  Widget _tasksPage() {
    final open = _tasks.where((t) => t['done'] != true).length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: 'New task for today...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _addTask, child: const Text('Add')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              open == 0 ? 'All done. Nice work.' : '$open task${open == 1 ? '' : 's'} to do',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Expanded(
          child: _tasks.isEmpty
              ? const Center(child: Text('No tasks yet. Add your first one above.'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, i) {
                    final task = _tasks[i];
                    final done = task['done'] == true;
                    return CheckboxListTile(
                      title: Text(
                        task['title'] as String,
                        style: done
                            ? const TextStyle(decoration: TextDecoration.lineThrough)
                            : null,
                      ),
                      value: done,
                      onChanged: (v) {
                        setState(() => _tasks[i]['done'] = v ?? false);
                        _save();
                      },
                      secondary: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => _tasks.removeAt(i));
                          _save();
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _habitsPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _habitController,
                  decoration: const InputDecoration(
                    hintText: 'New habit (e.g. Drink water, Read 10 pages)...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addHabit(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _addHabit, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: _habits.isEmpty
              ? const Center(child: Text('No habits yet. Add one you want to do daily.'))
              : ListView.builder(
                  itemCount: _habits.length,
                  itemBuilder: (context, i) {
                    final habit = _habits[i];
                    final days = List<String>.from(habit['days'] as List);
                    final doneToday = days.contains(todayKey());
                    final streak = habitStreak(days);
                    return ListTile(
                      leading: Icon(
                        doneToday ? Icons.local_fire_department : Icons.local_fire_department_outlined,
                        color: doneToday ? Colors.orange : null,
                      ),
                      title: Text(habit['name'] as String),
                      subtitle: Text(streak == 0
                          ? 'No streak yet'
                          : '$streak day streak'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.tonal(
                            onPressed: () => _toggleHabitToday(i),
                            child: Text(doneToday ? 'Done' : 'Check in'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() => _habits.removeAt(i));
                              _save();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _expensesPage() {
    final todayTotal = _expenses
        .where((e) => e['date'] == todayKey())
        .fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());
    final monthTotal = _expenses
        .where((e) => (e['date'] as String).startsWith(monthKey()))
        .fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('Today'),
                        Text(
                          '£${todayTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('This month'),
                        Text(
                          '£${monthTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addExpense(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _addExpense, child: const Text('Add')),
            ],
          ),
        ),
        Expanded(
          child: _expenses.isEmpty
              ? const Center(child: Text('No expenses yet.'))
              : ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (context, i) {
                    final e = _expenses[i];
                    return ListTile(
                      title: Text('£${(e['amount'] as num).toDouble().toStringAsFixed(2)}'
                          '${(e['note'] as String).isNotEmpty ? ' - ${e['note']}' : ''}'),
                      subtitle: Text('${e['category']}  ·  ${e['date']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() => _expenses.removeAt(i));
                          _save();
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
