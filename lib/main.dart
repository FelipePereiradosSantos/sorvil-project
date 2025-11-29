import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SorvilApp());
}

class Book {
  String id;
  String title;
  String author;
  String status;
  int rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'status': status,
    'rating': rating,
  };

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      status: json['status'] as String,
      rating: json['rating'] as int,
    );
  }
}

class SorvilApp extends StatelessWidget {
  const SorvilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorvil Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Sans-Serif',
      ),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const String _assetPath = 'assets/images/app_icon.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _assetPath,
                height: 300,
                width: 300,
                errorBuilder: (c, e, s) => Icon(
                  Icons.library_books,
                  size: 100,
                  color: Colors.brown[700],
                ),
              ),
              Text(
                'Seu catálogo de livros pessoal',
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FDC6F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookListScreen()),
                    );
                  },
                  child: const Text(
                    'Ver meus livros',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? booksString = prefs.getString('books_data');

    if (booksString != null) {
      final List<dynamic> jsonList = jsonDecode(booksString);
      setState(() {
        books = jsonList.map((json) => Book.fromJson(json)).toList();
      });
    } else {
      setState(() {
        books = [
          Book(id: '1', title: 'A Sutil Arte de Ligar o F*da-Se', author: 'Mark Manson', status: 'Lido', rating: 5),
          Book(id: '2', title: 'Pai Rico, Pai Pobre', author: 'Robert Kiyosaki', status: 'Lido', rating: 5),
          Book(id: '3', title: '20 mil léguas submarinas', author: 'Jules Verne', status: 'Lido', rating: 5),
          Book(id: '4', title: 'Turma da Mônica - Biblioteca', author: 'Ciranda Cultural', status: 'Quero ler', rating: 0),
        ];
      });
      _saveBooks();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = books.map((book) => book.toJson()).toList();
    final String booksString = jsonEncode(jsonList);
    await prefs.setString('books_data', booksString);
  }

  void _deleteBook(String id) {
    setState(() {
      books.removeWhere((book) => book.id == id);
    });
    _saveBooks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro removido com sucesso!')),
    );
  }

  void _showBookForm({Book? bookToEdit}) {
    final isEditing = bookToEdit != null;
    final titleController = TextEditingController(text: isEditing ? bookToEdit.title : '');
    final authorController = TextEditingController(text: isEditing ? bookToEdit.author : '');

    String selectedStatus = isEditing ? bookToEdit.status : 'Lido';
    int selectedRating = isEditing ? bookToEdit.rating : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Editar Livro' : 'Adicionar Livro',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título do Livro',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(
                        labelText: 'Autor',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Lido', child: Text('Lido')),
                        DropdownMenuItem(value: 'Quero ler', child: Text('Quero ler')),
                      ],
                      onChanged: (value) {
                        setStateModal(() => selectedStatus = value!);
                      },
                    ),
                    const SizedBox(height: 15),

                    const Text("Avaliação:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                          onPressed: () {
                            setStateModal(() => selectedRating = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FDC6F),
                        ),
                        onPressed: () {
                          if (titleController.text.isEmpty || authorController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Preencha título e autor!'))
                            );
                            return;
                          }

                          setState(() {
                            if (isEditing) {
                              bookToEdit!.title = titleController.text;
                              bookToEdit.author = authorController.text;
                              bookToEdit.status = selectedStatus;
                              bookToEdit.rating = selectedRating;
                            } else {
                              books.add(Book(
                                id: DateTime.now().toString(),
                                title: titleController.text,
                                author: authorController.text,
                                status: selectedStatus,
                                rating: selectedRating,
                              ));
                            }
                          });

                          _saveBooks();
                          Navigator.pop(context);
                        },
                        child: Text(
                          isEditing ? 'Salvar Alterações' : 'Adicionar livro',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Image.network(
          'https://cdn-icons-png.flaticon.com/512/3389/3389081.png',
          height: 40,
          errorBuilder: (c, e, s) => const Icon(Icons.library_books, color: Colors.brown),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final isRead = book.status == 'Lido';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.book, color: Colors.green),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isRead ? const Color(0xFFB9F6CA) : const Color(0xFFFFCCBC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    book.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isRead ? Colors.green[900] : Colors.red[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.edit_note, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    book.author,
                                    style: TextStyle(color: Colors.grey[800]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: starIndex < book.rating ? Colors.amber : Colors.grey[300],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_square, color: Colors.black87),
                            onPressed: () => _showBookForm(bookToEdit: book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.black87),
                            onPressed: () => _deleteBook(book.id),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FDC6F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () => _showBookForm(),
                    child: const Text(
                      'Adicionar livro',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '© 2025 Felipe Pereira e Manuela Santos',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}