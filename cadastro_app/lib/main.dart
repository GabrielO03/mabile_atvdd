import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Usuários',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 8,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const FormCarouselPage(),
    );
  }
}

class FormCarouselPage extends StatefulWidget {
  const FormCarouselPage({super.key});

  @override
  State<FormCarouselPage> createState() => _FormCarouselPageState();
}

class _FormCarouselPageState extends State<FormCarouselPage> {
  final List<FormData> forms = List.generate(3, (_) => FormData());
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Cadastro de Usuários",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Indicador de progresso
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                forms.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? Colors.deepPurple
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
          // Formulários
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: forms.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 16,
                    vertical: 16,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildFormCard(forms[index], index),
                    ),
                  ),
                );
              },
            ),
          ),
          // Botões de navegação
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Anterior"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                Text(
                  "${_currentIndex + 1} de ${forms.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _currentIndex < forms.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () => _showSummary(),
                  icon: Icon(_currentIndex < forms.length - 1
                      ? Icons.arrow_forward
                      : Icons.check),
                  label: Text(_currentIndex < forms.length - 1
                      ? "Próximo"
                      : "Finalizar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(FormData formData, int index) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do formulário
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.deepPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Usuário ${index + 1}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Nome Completo
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nome Completo *',
              prefixIcon: const Icon(Icons.person),
              hintText: 'Digite o nome completo',
              errorText: formData.nome != null && formData.nome!.trim().isEmpty
                  ? 'Nome é obrigatório'
                  : null,
            ),
            initialValue: formData.nome,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              setState(() {
                formData.nome = value;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nome é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Data de Nascimento
          InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: formData.dataNascimento ?? DateTime(2000, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.deepPurple,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => formData.dataNascimento = picked);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Data de Nascimento *",
                prefixIcon: Icon(Icons.calendar_today),
                hintText: "Selecione uma data",
              ),
              child: Text(
                formData.dataNascimento != null
                    ? "${formData.dataNascimento!.day.toString().padLeft(2, '0')}/${formData.dataNascimento!.month.toString().padLeft(2, '0')}/${formData.dataNascimento!.year}"
                    : "Selecione uma data",
                style: TextStyle(
                  color: formData.dataNascimento == null
                      ? Colors.grey[600]
                      : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sexo (Dropdown)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Sexo *",
              prefixIcon: Icon(Icons.wc),
            ),
            value: formData.sexo,
            items: const [
              DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
              DropdownMenuItem(value: "Feminino", child: Text("Feminino"))          ],
            onChanged: (value) => setState(() => formData.sexo = value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Sexo é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Status de preenchimento
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isFormComplete(formData)
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isFormComplete(formData)
                    ? Colors.green
                    : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isFormComplete(formData)
                      ? Icons.check_circle
                      : Icons.warning,
                  color: _isFormComplete(formData)
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isFormComplete(formData)
                        ? 'Formulário completo!'
                        : 'Preencha os campos obrigatórios (*)',
                    style: TextStyle(
                      color: _isFormComplete(formData)
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isFormComplete(FormData formData) {
    return formData.nome != null &&
        formData.nome!.trim().isNotEmpty &&
        formData.email != null &&
        formData.email!.trim().isNotEmpty &&
        _isValidEmail(formData.email!) &&
        formData.dataNascimento != null &&
        formData.sexo != null &&
        formData.sexo!.isNotEmpty;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.summarize, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Resumo dos Cadastros'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              final isComplete = _isFormComplete(form);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isComplete ? Colors.green : Colors.orange,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    form.nome?.isNotEmpty == true ? form.nome! : 'Nome não informado',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (form.email?.isNotEmpty == true)
                        Text('Email: ${form.email}'),
                      if (form.telefone?.isNotEmpty == true)
                        Text('Telefone: ${form.telefone}'),
                      if (form.dataNascimento != null)
                        Text('Nascimento: ${form.dataNascimento!.day.toString().padLeft(2, '0')}/${form.dataNascimento!.month.toString().padLeft(2, '0')}/${form.dataNascimento!.year}'),
                      if (form.sexo?.isNotEmpty == true)
                        Text('Sexo: ${form.sexo}'),
                    ],
                  ),
                  trailing: Icon(
                    isComplete ? Icons.check_circle : Icons.warning,
                    color: isComplete ? Colors.green : Colors.orange,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar Dados'),
          ),
        ],
      ),
    );
  }

  void _saveData() {
    // Aqui você pode implementar a lógica para salvar os dados
    // Por exemplo, enviar para uma API ou salvar localmente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados salvos com sucesso!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class FormData {
  String? nome;
  String? email;
  String? telefone;
  DateTime? dataNascimento;
  String? sexo;

  FormData({
    this.nome,
    this.email,
    this.telefone,
    this.dataNascimento,
    this.sexo,
  });
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length <= 2) {
      return newValue;
    }
    
    String formatted = '';
    
    if (text.length <= 2) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2)}';
    } else if (text.length <= 10) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 6)}-${text.substring(6)}';
    } else {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
