import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controladorNome = TextEditingController();
  TextEditingController controladorCep = TextEditingController();
  TextEditingController controladorNumero = TextEditingController();

  bool escuro = false;

  String rua = '';
  String bairro = '';
  String cidade = '';
  String estado = '';

  @override
  void initState() {
    super.initState();
    buscarSalvo();
  }

  void mudarTema(bool valor) async {
    setState(() {
      escuro = valor;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('escuro', escuro);
  }

  void buscarCep() async {
    String cep = controladorCep.text;

    final resposta = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cep/json/'),
    );

    final dados = jsonDecode(resposta.body);

    setState(() {
      rua = dados['logradouro'] ?? '';
      bairro = dados['bairro'] ?? '';
      cidade = dados['localidade'] ?? '';
      estado = dados['uf'] ?? '';
    });

    salvar();
  }

  void salvar() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('nome', controladorNome.text);
    await prefs.setBool('escuro', escuro);

    await prefs.setString('cep', controladorCep.text);
    await prefs.setString('numero', controladorNumero.text);

    await prefs.setString('rua', rua);
    await prefs.setString('bairro', bairro);
    await prefs.setString('cidade', cidade);
    await prefs.setString('estado', estado);
  }

  void buscarSalvo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      controladorNome.text = prefs.getString('nome') ?? '';

      escuro = prefs.getBool('escuro') ?? false;

      controladorCep.text = prefs.getString('cep') ?? '';
      controladorNumero.text = prefs.getString('numero') ?? '';

      rua = prefs.getString('rua') ?? '';
      bairro = prefs.getString('bairro') ?? '';
      cidade = prefs.getString('cidade') ?? '';
      estado = prefs.getString('estado') ?? '';
    });
  }

  void apagar() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('nome');
    await prefs.remove('escuro');

    await prefs.remove('cep');
    await prefs.remove('numero');

    await prefs.remove('rua');
    await prefs.remove('bairro');
    await prefs.remove('cidade');
    await prefs.remove('estado');

    setState(() {
      controladorNome.text = '';

      escuro = false;

      controladorCep.text = '';
      controladorNumero.text = '';

      rua = '';
      bairro = '';
      cidade = '';
      estado = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: escuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'Configuração do usuário',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controladorNome,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tema escuro'),
                    Switch(
                      value: escuro,
                      onChanged: mudarTema,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Endereço',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controladorCep,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controladorNumero,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número da casa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: buscarCep,
                  child: const Text('Buscar CEP'),
                ),
                const SizedBox(height: 20),
                Text('Rua: $rua'),
                Text('Número: ${controladorNumero.text}'),
                Text('Bairro: $bairro'),
                Text('Cidade: $cidade'),
                Text('Estado: $estado'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: salvar,
                  child: const Text('Salvar'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: apagar,
                  child: const Text('Apagar dados'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
