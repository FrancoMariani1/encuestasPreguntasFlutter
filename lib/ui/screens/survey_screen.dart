import 'package:flutter/material.dart';

import '../../database/database.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/survey_dropdown.dart';

class SurveyApp extends StatefulWidget {
  final DatabaseHelper dbHelper;

  SurveyApp({required this.dbHelper});

  @override
  _SurveyAppState createState() => _SurveyAppState();
}

class _SurveyAppState extends State<SurveyApp> {
  final TextEditingController _surveyController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _editQuestionController = TextEditingController();
  String _selectedSurvey = '';
  int? _selectedSurveyId;
  bool _isMandatory = false;
  List<Map<String, dynamic>> _surveys = [];

  @override
  void initState() {
    super.initState();
    _fetchSurveys();
  }

  Future<void> _deleteSurveyHandler(int surveyId) async {
    bool confirmed = await showDeleteConfirmationDialog(
      context,
      '¿Estás seguro de eliminar esta encuesta?',
    );
    if (confirmed) {
      try {
        await widget.dbHelper.deleteSurvey(surveyId);
        _fetchSurveys();
      } catch (e) {
        print('Error al eliminar la encuesta: $e');
      }
    }
  }

  Future<void> _fetchSurveys() async {
    final surveys = await widget.dbHelper.getSurveys();
    setState(() {
      _surveys = surveys;
      _updateSelectedSurvey();
    });
  }

  void _updateSelectedSurvey() {
    if (_surveys.isNotEmpty) {
      _selectedSurveyId =
          _surveys.any((survey) => survey['id'] == _selectedSurveyId)
              ? _selectedSurveyId
              : _surveys[0]['id'];
      _selectedSurvey = _surveys
          .firstWhere((survey) => survey['id'] == _selectedSurveyId)['name'];
    } else {
      _selectedSurveyId = null;
      _selectedSurvey = '';
    }
  }

  Future<void> _editQuestion(
      int questionId, String newQuestionText, bool isMandatory) async {
    try {
      await widget.dbHelper.updateQuestion(
          _selectedSurvey, questionId, newQuestionText, isMandatory);
    } catch (e) {
      print('Error al editar la pregunta: $e');
    }
  }

  Future<void> _deleteQuestion(int questionId) async {
    try {
      await widget.dbHelper.deleteQuestion(_selectedSurvey, questionId);
    } catch (e) {
      print('Error al eliminar la pregunta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App de Encuestas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (_surveys.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SurveyDropdown(
                      surveys: _surveys,
                      onChanged: (selectedSurveyName) {
                        final survey = _surveys.firstWhere(
                            (survey) => survey['name'] == selectedSurveyName);
                        setState(() {
                          _selectedSurveyId = survey['id'];
                          _selectedSurvey = survey['name'];
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      if (_selectedSurveyId != null) {
                        _deleteSurveyHandler(_selectedSurveyId!);
                      }
                    },
                  )
                ],
              ),
            TextField(
              controller: _surveyController,
              decoration: InputDecoration(
                labelText: 'Nombre de la encuesta',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.dbHelper.insertSurvey(_surveyController.text);
                _fetchSurveys();
              },
              child: Text('Crear Encuesta'),
            ),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Texto de la pregunta',
              ),
            ),
            CheckboxListTile(
              title: Text('¿Es obligatoria?'),
              value: _isMandatory,
              onChanged: (newValue) {
                setState(() {
                  _isMandatory = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.dbHelper.insertQuestion(
                  _selectedSurvey,
                  _questionController.text,
                  _isMandatory,
                );
                setState(() {});
              },
              child: Text('Agregar Pregunta'),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: widget.dbHelper.getQuestionsForSurvey(_selectedSurvey),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final questions = snapshot.data ?? [];
                    return ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(questions[index]['text'] ??
                              'Texto de la pregunta'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: TextField(
                                          controller: _editQuestionController,
                                          decoration: InputDecoration(
                                            labelText: 'Editar Pregunta',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              _editQuestion(
                                                  questions[index]['id'],
                                                  _editQuestionController.text,
                                                  _isMandatory);
                                              Navigator.of(context).pop();
                                              setState(() {});
                                            },
                                            child: Text('Editar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancelar'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteQuestion(questions[index]['id']);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
