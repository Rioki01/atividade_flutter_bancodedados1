import 'package:flutter/material.dart';
import 'package:alimento/models/alimento.dart';
import 'package:alimento/helpers/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Mercado',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  List<Alimento> _alimentos = [];
  bool _isLoading = false;

  Future<void> _loadAlimentos() async {
    setState(() => _isLoading = true);
    final alimentos = await SqlHelper().getAllAlimentos();
    setState(() {
      _alimentos = alimentos;
      _isLoading = false;
    });
  }

  Future<void> _showAlimentoDialog(BuildContext context, {Alimento? alimento}) async {
    if (alimento != null) {
      _nomeController.text = alimento.nome;
      _precoController.text = alimento.preco.toString();
    } else {
      _nomeController.clear();
      _precoController.clear();
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(alimento == null ? 'Adicionar Alimento' : 'Editar Alimento'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(hintText: 'Nome do Alimento'),
                ),
                TextField(
                  controller: _precoController,
                  decoration: const InputDecoration(hintText: 'Preço do Alimento'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(alimento == null ? 'Adicionar' : 'Salvar'),
              onPressed: () async {
                if (_nomeController.text.isNotEmpty && _precoController.text.isNotEmpty) {
                  setState(() => _isLoading = true);
                  if (alimento == null) {
                    await SqlHelper().insertAlimento(
                      Alimento(
                        nome: _nomeController.text,
                        preco: double.parse(_precoController.text),
                      ),
                    );
                  } else {
                    await SqlHelper().updateAlimento(
                      Alimento(
                        id: alimento.id,
                        nome: _nomeController.text,
                        preco: double.parse(_precoController.text),
                      ),
                    );
                  }
                  _nomeController.clear();
                  _precoController.clear();
                  await _loadAlimentos();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAlimento(int id) async {
    setState(() => _isLoading = true);
    await SqlHelper().deleteAlimento(id);
    await _loadAlimentos();
  }

  @override
  void initState() {
    super.initState();
    _loadAlimentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Mercado'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _alimentos.length,
              itemBuilder: (context, index) {
                final alimento = _alimentos[index];
                return ListTile(
                  title: Text(alimento.nome),
                  subtitle: Text('Preço: R\$${alimento.preco.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAlimentoDialog(context, alimento: alimento),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteAlimento(alimento.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAlimentoDialog(context),
        tooltip: 'Adicionar Alimento',
        child: const Icon(Icons.add),
      ),
    );
  }
}