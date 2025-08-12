import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      home: CadastroScreen(),
    );
  }
}

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  List<FormData> formList = [];
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Lista inicia vazia
  }

  void _addNewCard() {
    setState(() {
      formList.add(FormData());
    });
    
    // Navega para o novo card criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (formList.isNotEmpty) {
        _pageController.animateToPage(
          formList.length - 1,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _removeCard(int index) {
    if (formList.length > 1) {
      setState(() {
        formList.removeAt(index);
      });
    }
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Limpeza'),
        content: Text('Tem certeza que deseja remover todos os cadastros?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                formList.clear();
              });
              Navigator.pop(context);
            },
            child: Text('Confirmar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Pessoas'),
        backgroundColor: Colors.blue[600],
      ),
      body: Column(
        children: [
          Expanded(
            child: formList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 80,
                          color: Colors.blue[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Nenhum cadastro encontrado',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Clique em "Adicionar Card" para começar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: formList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FormCard(
                          formData: formList[index],
                          onRemove: () => _removeCard(index),
                          canRemove: formList.length > 1,
                        ),
                      );
                    },
                  ),
          ),
          Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addNewCard,
                    icon: Icon(Icons.add),
                    label: Text('Adicionar Card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  if (formList.isNotEmpty) ...[
                     SizedBox(width: 10),
                     ElevatedButton.icon(
                       onPressed: () {
                         _showAllData();
                       },
                       icon: Icon(Icons.list),
                       label: Text('Ver Dados'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blue,
                         foregroundColor: Colors.white,
                         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                       ),
                     ),
                     SizedBox(width: 10),
                     ElevatedButton.icon(
                       onPressed: _clearAllData,
                       icon: Icon(Icons.clear_all),
                       label: Text('Limpar Tudo'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.red,
                         foregroundColor: Colors.white,
                         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                       ),
                     ),
                   ]
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dados Cadastrados'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: formList.length,
            itemBuilder: (context, index) {
              final data = formList[index];
              return Card(
                child: ListTile(
                  title: Text(data.nomeCompleto.isEmpty ? 'Nome não informado' : data.nomeCompleto),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data: ${data.dataNascimento != null ? '${data.dataNascimento!.day}/${data.dataNascimento!.month}/${data.dataNascimento!.year}' : 'Não informada'}'),
                      Text('Sexo: ${data.sexo}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class FormData {
  String nomeCompleto = '';
  DateTime? dataNascimento;
  String sexo = 'Homem';
}

class FormCard extends StatefulWidget {
  final FormData formData;
  final VoidCallback onRemove;
  final bool canRemove;

  FormCard({
    required this.formData,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  _FormCardState createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  late TextEditingController _nomeController;
  late TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.formData.nomeCompleto);
    _dataController = TextEditingController(
      text: widget.formData.dataNascimento != null
          ? '${widget.formData.dataNascimento!.day.toString().padLeft(2, '0')}/${widget.formData.dataNascimento!.month.toString().padLeft(2, '0')}/${widget.formData.dataNascimento!.year}'
          : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.formData.dataNascimento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Locale('pt', 'BR'),
    );

    if (pickedDate != null) {
      setState(() {
        widget.formData.dataNascimento = pickedDate;
        _dataController.text = '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Formulário de Cadastro',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                if (widget.canRemove)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remover card',
                  ),
              ],
            ),
            SizedBox(height: 20),
            
            // Campo Nome Completo
            Text(
              'Nome Completo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                hintText: 'Digite o nome completo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.person, color: Colors.blue[600]),
              ),
              onChanged: (value) {
                widget.formData.nomeCompleto = value;
              },
            ),
            SizedBox(height: 20),
            
            // Campo Data de Nascimento
            Text(
              'Data de Nascimento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _dataController,
              decoration: InputDecoration(
                hintText: 'DD/MM/AAAA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[600]),
                suffixIcon: IconButton(
                  onPressed: _selectDate,
                  icon: Icon(Icons.date_range, color: Colors.blue[600]),
                ),
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            SizedBox(height: 20),
            
            // Campo Sexo
            Text(
              'Sexo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                value: widget.formData.sexo,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  prefixIcon: Icon(Icons.wc, color: Colors.blue[600]),
                ),
                items: ['Homem', 'Mulher'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      widget.formData.sexo = newValue;
                    });
                  }
                },
              ),
            ),
            
            Spacer(),
            
            // Espaço para melhor layout
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}