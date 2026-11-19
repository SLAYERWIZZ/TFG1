import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const KallarimantaApp());
}

class KallarimantaApp extends StatelessWidget {
  const KallarimantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kallarimanta',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F6F5C),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    InicioScreen(),
    Center(child: Text('Explorar (por hacer)')),
    Center(child: Text('Mapa (por hacer)')),
    Center(child: Text('Recursos (por hacer)')),
    Center(child: Text('Mi cuenta (por hacer)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Recursos'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Mi cuenta'),
        ],
      ),
    );
  }
}

class Manifestacion {
  final String nombre;
  final String descripcion;
  final String categoria;
  final String comunidad;

  Manifestacion({
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.comunidad,
  });

  factory Manifestacion.fromJson(Map<String, dynamic> json) {
    return Manifestacion(
      nombre: json['nombre'] ?? '(sin nombre)',
      descripcion: (json['descripcion_espanol'] ?? '')
    .toString()
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .trim(),
      categoria: json['categoria'] ?? '',
      comunidad: json['comunidad'] ?? '',
    );
  }
}

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late Future<List<Manifestacion>> _futureData;

  // Cambia esta URL si tu sitio en Local tiene otro dominio.
  static const String apiUrl =
      'http://kallarimanta.local/wp-json/wp/v2/manifestacion';

  @override
  void initState() {
    super.initState();
    _futureData = _fetchManifestaciones();
  }

  Future<List<Manifestacion>> _fetchManifestaciones() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Manifestacion.fromJson(e)).toList();
    } else {
      throw Exception('Error ${response.statusCode} al leer la API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kallarimanta')),
      body: FutureBuilder<List<Manifestacion>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudo conectar:\n${snapshot.error}'),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No hay manifestaciones todavía.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final m = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${m.comunidad} · ${m.categoria}\n${m.descripcion}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}