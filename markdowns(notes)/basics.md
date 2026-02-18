```
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  int age = 0; 
  String name = "John Doe";

  void greet(String name){
      print("Hello, $name!");
    }

    /*
===================================================
  D A T A S T R U C T U R E S
  
 */

List numbers = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    // if(age>=18){
    //   print("You are an adult.");
    // }
    // else if(age>=13 && age<18){
    //   print("You are a teenager.");
    // }
    // else{
    //   print("You are a child.");
    // }
  greet( name);

  // ===================================================
  // L O O P S
    for(int i =0;i<6;i++){
      print(i);
      if(i==3){
        continue; 
        // This will exit the loop when i is 3
      }
    }

    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Scaffold(),
    );
  }
}


```
Last edited : 16-02-2026  


```
body:Center(
          child: Container(
            height:300,
            width:300,
            
            // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red[500],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(20),
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 50,
            
            ),
            // child: Text(
            //   "Renji",
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize:26,
            //     fontWeight: FontWeight.bold,
            //   ),//TextStyle
            // ),//Text
          ),//Container
        ),//Center
```


import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
  print(" Hello World");
  
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.blue[200],
        appBar: AppBar(
          title: Text("Flutter Demo"),
          elevation: 0,
          leading: Icon(Icons.menu),
          actions: [
            IconButton(onPressed: () {},
                      icon: Icon(Icons.logout)),
          ],
        ),
      
        
      ),//Scaffold
    );//MaterialApp
  }
}



=================
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ── Todo Model ─────────────────────────────────────────────────
class Todo {
  String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});
}

// ── Home Page ──────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Todo> _todos = [
    Todo(title: 'Buy groceries'),
    Todo(title: 'Read for 30 minutes'),
    Todo(title: 'Go for a walk'),
  ];

  // FIX 1: controller is properly disposed in dispose()
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // ✅ always dispose controllers
    super.dispose();
  }

  int get _doneCount => _todos.where((t) => t.isDone).length;

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _showAddSheet() {
    // FIX 2: clear old text every time sheet opens
    _controller.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // FIX 3: use a separate builder context (ctx) — never use
      // the outer page context inside a bottom sheet builder
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'New Task',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),

              // Text field
              TextField(
                controller: _controller,
                autofocus: true,
                onSubmitted: (_) => _addTodo(ctx),
                decoration: InputDecoration(
                  hintText: 'What do you need to do?',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6366F1),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addTodo(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _addTodo(BuildContext ctx) {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(Todo(title: text));
    });

    _controller.clear();
    Navigator.pop(ctx); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ─
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Tasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_doneCount of ${_todos.length} completed',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: _todos.isEmpty
                          ? 0
                          : _doneCount / _todos.length,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF34D399),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Task List ─────────
            Expanded(
              child: _todos.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        return _buildTodoCard(_todos[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),

      // ── FAB ───────
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // ── Todo Card ───────
  Widget _buildTodoCard(Todo todo, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [

          // Checkbox
          GestureDetector(
            onTap: () => _toggleTodo(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: todo.isDone
                    ? const Color(0xFF6366F1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: todo.isDone
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: todo.isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Task title
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: todo.isDone
                    ? Colors.grey.shade400
                    : const Color(0xFF1E293B),
                decoration: todo.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.grey.shade400,
              ),
            ),
          ),

          // Delete button
          GestureDetector(
            onTap: () => _deleteTodo(index),
            
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.grey.shade300,
              size: 20,
             
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ─────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 36,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the + button to add one.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}