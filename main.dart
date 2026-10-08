import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controlador = TextEditingController();

  @override
  void initState() {
    super.initState();
    lerArquivo();
  }

  Future<String> get _pastaDocumentos async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _arquivo async {
    final caminho = await _pastaDocumentos;
    return File('$caminho/organiza.md');
  }

  void salvar() async {
    final arquivo = await _arquivo;

    await arquivo.writeAsString(
      controlador.text,
    );
  }

  void lerArquivo() async {
    try {
      final arquivo = await _arquivo;

      final conteudo = await arquivo.readAsString();

      setState(() {
        controlador.text = conteudo;
      });
    } catch (_) {
      setState(() {
        controlador.text = '';
      });
    }
  }

  void apagar() async {
    final arquivo = await _arquivo;

    if (await arquivo.exists()) {
      await arquivo.delete();
    }

    setState(() {
      controlador.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Organiza Markdown'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: controlador,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Digite seu texto Markdown',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: salvar,
                child: const Text('Salvar'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: apagar,
                child: const Text('Apagar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
