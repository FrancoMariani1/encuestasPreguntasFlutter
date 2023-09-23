import 'package:flutter/material.dart';
import 'database/database.dart';

void main() async {
  final DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.connect();
  runApp(MyApp(dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  MyApp({required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SurveyApp(dbHelper: dbHelper),
    );
  }
}

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
    bool confirmed = await _showDeleteConfirmationDialog(
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
      _selectedSurveyId = surveys.isNotEmpty ? surveys.first['id'] : null;
      _selectedSurvey = surveys.isNotEmpty ? surveys.first['name'] : '';
    });
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

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmación'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Si se hace clic fuera del cuadro de diálogo, devuelve false
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
                      child: DropdownButton<int>(
                    value: _selectedSurveyId,
                    items: _surveys.map((survey) {
                      return DropdownMenuItem<int>(
                        value: survey['id'],
                        child: Text(survey['name']),
                      );
                    }).toList(),
                    // DropdownButton<int>(
                    //   value: _selectedSurveyId,
                    //   items: _surveys.map((survey) {
                    //     return DropdownMenuItem<int>(
                    //       value: survey['id'],
                    //       child: Text(survey['name']),
                    //     );
                    //   }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSurveyId = newValue;
                        _selectedSurvey = _surveys.firstWhere(
                            (survey) => survey['id'] == newValue)['name'];
                      });
                    },
                  )),
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


// import 'package:flutter/material.dart';
// import 'database/database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SurveyApp(),
//     );
//   }
// }

// class SurveyApp extends StatefulWidget {
//   @override
//   _SurveyAppState createState() => _SurveyAppState();
// }

// class _SurveyAppState extends State<SurveyApp> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final TextEditingController _surveyController = TextEditingController();
//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _editQuestionController = TextEditingController();
//   String _selectedSurvey = '';
//   bool _isMandatory = false;
//   List<String> _surveys = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadSurveys();
//   }

//   Future<void> _loadSurveys() async {
//     final surveys = await _dbHelper.getAllSurveys();
//     setState(() {
//       _surveys = surveys;
//       if (_surveys.isNotEmpty) {
//         _selectedSurvey = _surveys[0];
//       }
//     });
//   }

//   Future<void> _editQuestion(
//       int questionId, String newQuestionText, bool isMandatory) async {
//     try {
//       await _dbHelper.updateQuestion(
//           _selectedSurvey, questionId, newQuestionText, isMandatory);
//     } catch (e) {
//       print('Error al editar la pregunta: $e');
//     }
//   }

//   Future<void> _deleteQuestion(int questionId) async {
//     try {
//       await _dbHelper.deleteQuestion(_selectedSurvey, questionId);
//     } catch (e) {
//       print('Error al eliminar la pregunta: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('App de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             if (_surveys.isNotEmpty)
//               DropdownButton<String>(
//                 value: _selectedSurvey,
//                 items: _surveys.map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedSurvey = newValue!;
//                   });
//                 },
//               ),
//             TextField(
//               controller: _surveyController,
//               decoration: InputDecoration(
//                 labelText: 'Nombre de la encuesta',
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertSurvey(_surveyController.text);
//                 _loadSurveys();
//               },
//               child: Text('Crear Encuesta'),
//             ),
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 labelText: 'Texto de la pregunta',
//               ),
//             ),
//             CheckboxListTile(
//               title: Text('¿Es obligatoria?'),
//               value: _isMandatory,
//               onChanged: (newValue) {
//                 setState(() {
//                   _isMandatory = newValue!;
//                 });
//               },
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertQuestion(
//                   _selectedSurvey,
//                   _questionController.text,
//                   _isMandatory,
//                 );
//                 setState(() {});
//               },
//               child: Text('Agregar Pregunta'),
//             ),
//             Expanded(
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                 future: _dbHelper.getQuestionsForSurvey(_selectedSurvey),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else {
//                     final questions = snapshot.data ?? [];
//                     return ListView.builder(
//                       itemCount: questions.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(questions[index]['text']),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.edit),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         content: TextField(
//                                           controller: _editQuestionController,
//                                           decoration: InputDecoration(
//                                             labelText: 'Editar Pregunta',
//                                           ),
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               _editQuestion(
//                                                   questions[index]['id'],
//                                                   _editQuestionController.text,
//                                                   _isMandatory);
//                                               Navigator.of(context).pop();
//                                               setState(() {});
//                                             },
//                                             child: Text('Editar'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                             child: Text('Cancelar'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.delete),
//                                 onPressed: () {
//                                   _deleteQuestion(questions[index]['id']);
//                                   setState(() {});
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'database/database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SurveyApp(),
//     );
//   }
// }

// class SurveyApp extends StatefulWidget {
//   @override
//   _SurveyAppState createState() => _SurveyAppState();
// }

// class _SurveyAppState extends State<SurveyApp> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final TextEditingController _surveyController = TextEditingController();
//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _editQuestionController = TextEditingController();
//   String _selectedSurvey = '';
//   int? _selectedSurveyId;
//   bool _isMandatory = false;
//   List<Map<String, dynamic>> _surveys = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchSurveys();
//   }

//   Future<void> _fetchSurveys() async {
//     final surveys = await _dbHelper.getSurveys();
//     setState(() {
//       _surveys = surveys;
//       _selectedSurveyId = surveys.isNotEmpty ? surveys.first['id'] : null;
//       _selectedSurvey = surveys.isNotEmpty ? surveys.first['name'] : '';
//     });
//   }

//   Future<void> _editQuestion(int questionId, String newQuestionText, bool isMandatory) async {
//     try {
//       await _dbHelper.updateQuestion(_selectedSurvey, questionId, newQuestionText, isMandatory);
//     } catch (e) {
//       print('Error al editar la pregunta: $e');
//     }
//   }

//   Future<void> _deleteQuestion(int questionId) async {
//     try {
//       await _dbHelper.deleteQuestion(_selectedSurvey, questionId);
//     } catch (e) {
//       print('Error al eliminar la pregunta: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('App de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             if (_surveys.isNotEmpty)
//               DropdownButton<int>(
//                 value: _selectedSurveyId,
//                 items: _surveys.map((survey) {
//                   return DropdownMenuItem<int>(
//                     value: survey['id'],
//                     child: Text(survey['name']),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedSurveyId = newValue;
//                     _selectedSurvey = _surveys.firstWhere((survey) => survey['id'] == newValue)['name'];
//                   });
//                 },
//               ),
//             TextField(
//               controller: _surveyController,
//               decoration: InputDecoration(
//                 labelText: 'Nombre de la encuesta',
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertSurvey(_surveyController.text);
//                 _fetchSurveys();
//               },
//               child: Text('Crear Encuesta'),
//             ),
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 labelText: 'Texto de la pregunta',
//               ),
//             ),
//             CheckboxListTile(
//               title: Text('¿Es obligatoria?'),
//               value: _isMandatory,
//               onChanged: (newValue) {
//                 setState(() {
//                   _isMandatory = newValue!;
//                 });
//               },
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertQuestion(
//                   _selectedSurvey,
//                   _questionController.text,
//                   _isMandatory,
//                 );
//                 setState(() {});
//               },
//               child: Text('Agregar Pregunta'),
//             ),
//             Expanded(
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                 future: _dbHelper.getQuestionsForSurvey(_selectedSurvey),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else {
//                     final questions = snapshot.data ?? [];
//                     return ListView.builder(
//                       itemCount: questions.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(questions[index]['question_text']),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.edit),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         content: TextField(
//                                           controller: _editQuestionController,
//                                           decoration: InputDecoration(
//                                             labelText: 'Editar Pregunta',
//                                           ),
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               _editQuestion(
//                                                   index,
//                                                   _editQuestionController.text,
//                                                   _isMandatory);
//                                               Navigator.of(context).pop();
//                                               setState(() {});
//                                             },
//                                             child: Text('Editar'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                             child: Text('Cancelar'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.delete),
//                                 onPressed: () {
//                                   _deleteQuestion(index);
//                                   setState(() {});
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'database/database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SurveyApp(),
//     );
//   }
// }

// class SurveyApp extends StatefulWidget {
//   @override
//   _SurveyAppState createState() => _SurveyAppState();
// }

// class _SurveyAppState extends State<SurveyApp> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final TextEditingController _surveyController = TextEditingController();
//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _editQuestionController = TextEditingController();
//   String _selectedSurvey = '';
//   bool _isMandatory = false;

//   Future<void> _editQuestion(
//       int questionId, String newQuestionText, bool isMandatory) async {
//     try {
//       // Llama al método para editar la pregunta en tu clase DatabaseHelper
//       await _dbHelper.updateQuestion(
//           _selectedSurvey, questionId, newQuestionText, isMandatory);
//     } catch (e) {
//       print('Error al editar la pregunta: $e');
//     }
//   }

//   Future<void> _deleteQuestion(int questionId) async {
//     try {
//       // Llama al método para eliminar la pregunta en tu clase DatabaseHelper
//       await _dbHelper.deleteQuestion(_selectedSurvey, questionId);
//     } catch (e) {
//       print('Error al eliminar la pregunta: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('App de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _surveyController,
//               decoration: InputDecoration(
//                 labelText: 'Nombre de la encuesta',
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertSurvey(_surveyController.text);
//                 setState(() {
//                   _selectedSurvey = _surveyController.text;
//                 });
//               },
//               child: Text('Crear Encuesta'),
//             ),
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 labelText: 'Texto de la pregunta',
//               ),
//             ),
//             CheckboxListTile(
//               title: Text('¿Es obligatoria?'),
//               value: _isMandatory,
//               onChanged: (newValue) {
//                 setState(() {
//                   _isMandatory = newValue!;
//                 });
//               },
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertQuestion(
//                   _selectedSurvey,
//                   _questionController.text,
//                   _isMandatory,
//                 );
//                 setState(() {});
//               },
//               child: Text('Agregar Pregunta'),
//             ),
//             Expanded(
//               child: FutureBuilder<List<Map<String, dynamic>>>(
//                 future: _dbHelper.getQuestionsForSurvey(_selectedSurvey),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else {
//                     final questions = snapshot.data ?? [];
//                     return ListView.builder(
//                       itemCount: questions.length,
//                       itemBuilder: (context, index) {
//                         final question = questions[index];
//                         return ListTile(
//                           title: Text(question['text']),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.edit),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         content: TextField(
//                                           controller: _editQuestionController,
//                                           decoration: InputDecoration(
//                                             labelText: 'Editar Pregunta',
//                                           ),
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               _editQuestion(
//                                                   question['id'],
//                                                   _editQuestionController.text,
//                                                   question['isMandatory']);
//                                               Navigator.of(context).pop();
//                                               setState(() {});
//                                             },
//                                             child: Text('Editar'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                             child: Text('Cancelar'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.delete),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         title: Text('Eliminar Pregunta'),
//                                         content: Text(
//                                             '¿Estás seguro de eliminar esta pregunta?'),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               _deleteQuestion(question['id']);
//                                               Navigator.of(context).pop();
//                                               setState(() {});
//                                             },
//                                             child: Text('Eliminar'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                             child: Text('Cancelar'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                   setState(() {});
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'database/database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SurveyApp(),
//     );
//   }
// }

// class SurveyApp extends StatefulWidget {
//   @override
//   _SurveyAppState createState() => _SurveyAppState();
// }

// class _SurveyAppState extends State<SurveyApp> {
//   final DatabaseHelper _dbHelper = DatabaseHelper();
//   final TextEditingController _surveyController = TextEditingController();
//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _editQuestionController = TextEditingController();
//   String _selectedSurvey = '';
//   bool _isMandatory = false;

//   Future<void> _editQuestion(
//       int questionId, String newQuestionText, bool isMandatory) async {
//     try {
//       // Llama al método para editar la pregunta en tu clase DatabaseHelper
//       await _dbHelper.updateQuestion(
//           _selectedSurvey, questionId, newQuestionText, isMandatory);
//     } catch (e) {
//       print('Error al editar la pregunta: $e');
//     }
//   }

//   Future<void> _deleteQuestion(int questionId) async {
//     try {
//       // Llama al método para eliminar la pregunta en tu clase DatabaseHelper
//       await _dbHelper.deleteQuestion(_selectedSurvey, questionId);
//     } catch (e) {
//       print('Error al eliminar la pregunta: $e');
//     }
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('App de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _surveyController,
//               decoration: InputDecoration(
//                 labelText: 'Nombre de la encuesta',
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertSurvey(_surveyController.text);
//                 setState(() {
//                   _selectedSurvey = _surveyController.text;
//                 });
//               },
//               child: Text('Crear Encuesta'),
//             ),
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 labelText: 'Texto de la pregunta',
//               ),
//             ),
//             CheckboxListTile(
//               title: Text('¿Es obligatoria?'),
//               value: _isMandatory,
//               onChanged: (newValue) {
//                 setState(() {
//                   _isMandatory = newValue!;
//                 });
//               },
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await _dbHelper.insertQuestion(
//                   _selectedSurvey,
//                   _questionController.text,
//                   _isMandatory,
//                 );
//                 setState(() {});
//               },
//               child: Text('Agregar Pregunta'),
//             ),
//             Expanded(
//               child: FutureBuilder<List<String>>(
//                 future: _dbHelper.getQuestionsForSurvey(_selectedSurvey),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else {
//                     final questions = snapshot.data ?? [];
//                     return ListView.builder(
//                       itemCount: questions.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(questions[index]),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.edit),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         content: TextField(
//                                           controller: _editQuestionController,
//                                           decoration: InputDecoration(
//                                             labelText: 'Editar Pregunta',
//                                           ),
//                                         ),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               _editQuestion(
//                                                   index,
//                                                   _editQuestionController.text,
//                                                   _isMandatory);
//                                               Navigator.of(context).pop();
//                                               setState(() {});
//                                             },
//                                             child: Text('Editar'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                             child: Text('Cancelar'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.delete),
//                                 onPressed: () {
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return AlertDialog(
//                                         title: Text('Eliminar Pregunta'),
//                                         content: Text(
//                                             '¿Estás seguro de eliminar esta pregunta?'),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               _deleteQuestion(index);
//                                               Navigator.of(context).pop();
//                                               setState(() {});
//                                             },
//                                             child: Text('Eliminar'),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                             },
//                                             child: Text('Cancelar'),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                   setState(() {});
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'database/database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.blue,
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: Colors.blue,
//         ),
//         fontFamily: 'Roboto',
//       ),
//       home: SurveyGenerationScreen(),
//     );
//   }
// }

// class SurveyGenerationScreen extends StatefulWidget {
//   @override
//   _SurveyGenerationScreenState createState() => _SurveyGenerationScreenState();
// }

// class _SurveyGenerationScreenState extends State<SurveyGenerationScreen> {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<String> questions = [];
//   int selectedQuestionIndex = -1;
//   final dbHelper = DatabaseHelper();

//   @override
//   void initState() {
//     super.initState();
//     loadQuestions();
//   }

//   Future<void> loadQuestions() async {
//     final loadedQuestions = await dbHelper.getQuestionsForSurvey(surveyName);
//     setState(() {
//       questions = loadedQuestions;
//     });
//   }

//   @override
//   void dispose() {
//     dbHelper.closeConnection();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Generación de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'Nombre de la Encuesta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   surveyName = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Agregar Pregunta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   questionText = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//               decoration: InputDecoration(
//                 hintText: 'Texto de la Pregunta',
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 Text('Obligatoria:', style: TextStyle(fontSize: 16)),
//                 Checkbox(
//                   value: isMandatory,
//                   onChanged: (value) {
//                     setState(() {
//                       isMandatory = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await dbHelper.insertSurvey(surveyName);
//                 await dbHelper.insertQuestion(
//                   surveyName,
//                   questionText,
//                   isMandatory,
//                 );
//                 // Después de insertar, las preguntas se actualizarán automáticamente
//                 questions = await dbHelper.getQuestionsForSurvey(surveyName);
//               },
//               child: Text(selectedQuestionIndex == -1
//                   ? 'Agregar Pregunta'
//                   : 'Guardar Cambios'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blueAccent,
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Preguntas Agregadas:',
//               style: TextStyle(fontSize: 18),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: questions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       questions[index],
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () {
//                             setState(() {
//                               selectedQuestionIndex = index;
//                               String selectedQuestion = questions[index];
//                               List<String> parts =
//                                   selectedQuestion.split('(Obligatoria: ');
//                               questionText = parts[0].trim();
//                               isMandatory = parts[1].contains('Sí');
//                             });
//                           },
//                           color: Colors.blueAccent,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             setState(() {
//                               questions.removeAt(index);
//                               if (selectedQuestionIndex == index) {
//                                 selectedQuestionIndex = -1;
//                                 questionText = '';
//                                 isMandatory = false;
//                               }
//                             });
//                           },
//                           color: Colors.red,
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

    
  



// import 'package:flutter/material.dart';
// import 'database/database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.blue,
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: Colors.blue,
//         ),
//         fontFamily: 'Roboto',
//       ),
//       home: SurveyGenerationScreen(),
//     );
//   }
// }

// class SurveyGenerationScreen extends StatefulWidget {
//   @override
//   _SurveyGenerationScreenState createState() => _SurveyGenerationScreenState();
// }

// class _SurveyGenerationScreenState extends State<SurveyGenerationScreen> {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<String> questions = [];
//   int selectedQuestionIndex = -1;
//   final dbHelper = DatabaseHelper();

//   @override
//   void initState() {
//     super.initState();
//     // Abre la conexión al cargar el widget
//     dbHelper.openConnection();
//     // Recupera las preguntas al cargar el widget
//     loadQuestions();
//   }

//   Future<void> loadQuestions() async {
//     // Recupera las preguntas al cargar el widget
//     final loadedQuestions = await dbHelper.getQuestionsForSurvey(surveyName);
//     setState(() {
//       questions = loadedQuestions;
//     });
//   }

//   @override
//   void dispose() {
//     // Cierra la conexión al eliminar el widget
//     dbHelper.closeConnection();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Generación de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'Nombre de la Encuesta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   surveyName = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Agregar Pregunta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   questionText = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//               decoration: InputDecoration(
//                 hintText: 'Texto de la Pregunta',
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 Text('Obligatoria:', style: TextStyle(fontSize: 16)),
//                 Checkbox(
//                   value: isMandatory,
//                   onChanged: (value) {
//                     setState(() {
//                       isMandatory = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await dbHelper.insertSurvey(surveyName);
//                 await dbHelper.insertQuestion(
//                   surveyName,
//                   questionText,
//                   isMandatory,
//                 );
//                 // Después de insertar, las preguntas se actualizarán automáticamente
//                 questions = await dbHelper.getQuestionsForSurvey(surveyName);
//               },
//               child: Text(selectedQuestionIndex == -1
//                   ? 'Agregar Pregunta'
//                   : 'Guardar Cambios'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blueAccent,
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Preguntas Agregadas:',
//               style: TextStyle(fontSize: 18),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: questions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       questions[index],
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () {
//                             setState(() {
//                               selectedQuestionIndex = index;
//                               String selectedQuestion = questions[index];
//                               List<String> parts =
//                                   selectedQuestion.split('(Obligatoria: ');
//                               questionText = parts[0].trim();
//                               isMandatory = parts[1].contains('Sí');
//                             });
//                           },
//                           color: Colors.blueAccent,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             setState(() {
//                               questions.removeAt(index);
//                               if (selectedQuestionIndex == index) {
//                                 selectedQuestionIndex = -1;
//                                 questionText = '';
//                                 isMandatory = false;
//                               }
//                             });
//                           },
//                           color: Colors.red,
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'providers/survey_provider.dart';
// import 'screens/survey_generation_screen.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => SurveyProvider(),
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.blueGrey,
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: Colors.blueGrey,
//         ).copyWith(
//           secondary: Colors.blueAccent,
//         ),
//         fontFamily: 'Roboto',
//       ),
//       home: SurveyGenerationScreen(),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'survey_generation_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.blueGrey,
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: Colors.blueGrey,
//         ).copyWith(
//           secondary: Colors.blueAccent,
//         ),
//         fontFamily: 'Roboto',
//       ),
//       home: SurveyGenerationScreen(),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.blue,
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: Colors.blue,
//         ),
//         fontFamily: 'Roboto',
//       ),
//       home: SurveyGenerationScreen(),
//     );
//   }
// }

// class SurveyGenerationScreen extends StatefulWidget {
//   @override
//   _SurveyGenerationScreenState createState() => _SurveyGenerationScreenState();
// }

// class _SurveyGenerationScreenState extends State<SurveyGenerationScreen> {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<String> questions = [];
//   int selectedQuestionIndex = -1;
//   final dbHelper = DatabaseHelper();

//   @override
//   void initState() {
//     super.initState();
//     // Abre la conexión al cargar el widget
//     dbHelper.openConnection();
//     // Recupera las preguntas al cargar el widget
//     loadQuestions();
//   }

//   Future<void> loadQuestions() async {
//     // Recupera las preguntas al cargar el widget
//     final loadedQuestions = await dbHelper.getQuestionsForSurvey(surveyName);
//     setState(() {
//       questions = loadedQuestions;
//     });
//   }

//   @override
//   void dispose() {
//     // Cierra la conexión al eliminar el widget
//     dbHelper.closeConnection();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Generación de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'Nombre de la Encuesta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   surveyName = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Agregar Pregunta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   questionText = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//               decoration: InputDecoration(
//                 hintText: 'Texto de la Pregunta',
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 Text('Obligatoria:', style: TextStyle(fontSize: 16)),
//                 Checkbox(
//                   value: isMandatory,
//                   onChanged: (value) {
//                     setState(() {
//                       isMandatory = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await dbHelper.insertSurvey(surveyName);
//                 await dbHelper.insertQuestion(
//                   surveyName,
//                   questionText,
//                   isMandatory,
//                 );
//                 // Después de insertar, las preguntas se actualizarán automáticamente
//                 questions = await dbHelper.getQuestionsForSurvey(surveyName);
//               },
//               child: Text(selectedQuestionIndex == -1
//                   ? 'Agregar Pregunta'
//                   : 'Guardar Cambios'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blueAccent,
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Preguntas Agregadas:',
//               style: TextStyle(fontSize: 18),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: questions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       questions[index],
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () {
//                             setState(() {
//                               selectedQuestionIndex = index;
//                               String selectedQuestion = questions[index];
//                               List<String> parts =
//                                   selectedQuestion.split('(Obligatoria: ');
//                               questionText = parts[0].trim();
//                               isMandatory = parts[1].contains('Sí');
//                             });
//                           },
//                           color: Colors.blueAccent,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             setState(() {
//                               questions.removeAt(index);
//                               if (selectedQuestionIndex == index) {
//                                 selectedQuestionIndex = -1;
//                                 questionText = '';
//                                 isMandatory = false;
//                               }
//                             });
//                           },
//                           color: Colors.red,
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'database.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Colors.blue,
//         colorScheme: ColorScheme.fromSwatch(
//           primarySwatch: Colors.blue,
//         ),
//         fontFamily: 'Roboto', // Cambiar a una fuente personalizada si lo deseas
//       ),
//       home: SurveyGenerationScreen(),
//     );
//   }
// }

// class SurveyGenerationScreen extends StatefulWidget {
//   @override
//   _SurveyGenerationScreenState createState() => _SurveyGenerationScreenState();
// }

// class _SurveyGenerationScreenState extends State<SurveyGenerationScreen> {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<String> questions = [];
//   int selectedQuestionIndex = -1;
//   final dbHelper = DatabaseHelper(); // Instancia de la clase DatabaseHelper

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Generación de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'Nombre de la Encuesta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   surveyName = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Agregar Pregunta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   questionText = value;
//                 });
//               },
//               style: TextStyle(fontSize: 16),
//               decoration: InputDecoration(
//                 hintText: 'Texto de la Pregunta',
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 Text('Obligatoria:', style: TextStyle(fontSize: 16)),
//                 Checkbox(
//                   value: isMandatory,
//                   onChanged: (value) {
//                     setState(() {
//                       isMandatory = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 await dbHelper.openConnection();
//                 await dbHelper.insertSurvey(surveyName);
//                 await dbHelper.insertQuestion(
//                   surveyName,
//                   questionText,
//                   isMandatory,
//                 );
//                 await dbHelper.closeConnection();
//               },
//               child: Text(selectedQuestionIndex == -1
//                   ? 'Agregar Pregunta'
//                   : 'Guardar Cambios'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blueAccent,
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Preguntas Agregadas:',
//               style: TextStyle(fontSize: 18),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: questions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       questions[index],
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () {
//                             setState(() {
//                               selectedQuestionIndex = index;
//                               String selectedQuestion = questions[index];
//                               // Separar el texto y la opción "Obligatoria"
//                               List<String> parts =
//                                   selectedQuestion.split('(Obligatoria: ');
//                               questionText = parts[0].trim();
//                               isMandatory = parts[1].contains('Sí');
//                             });
//                           },
//                           color: Colors.blueAccent,
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             setState(() {
//                               questions.removeAt(index);
//                               // Si la pregunta eliminada era la seleccionada, limpiar la edición
//                               if (selectedQuestionIndex == index) {
//                                 selectedQuestionIndex = -1;
//                                 questionText = '';
//                                 isMandatory = false;
//                               }
//                             });
//                           },
//                           color: Colors.red,
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: SurveyGenerationScreen(),
//     );
//   }
// }

// class SurveyGenerationScreen extends StatefulWidget {
//   @override
//   _SurveyGenerationScreenState createState() => _SurveyGenerationScreenState();
// }

// class _SurveyGenerationScreenState extends State<SurveyGenerationScreen> {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<String> questions = [];
//   int selectedQuestionIndex = -1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Generación de Encuestas'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(
//               'Nombre de la Encuesta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   surveyName = value;
//                 });
//               },
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Agregar Pregunta:',
//               style: TextStyle(fontSize: 18),
//             ),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   questionText = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Texto de la Pregunta',
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 Text('Obligatoria:'),
//                 Checkbox(
//                   value: isMandatory,
//                   onChanged: (value) {
//                     setState(() {
//                       isMandatory = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (selectedQuestionIndex == -1) {
//                   // Agregar una nueva pregunta
//                   if (questionText.isNotEmpty) {
//                     questions.add('$questionText (Obligatoria: $isMandatory)');
//                     setState(() {
//                       questionText = '';
//                       isMandatory = false;
//                     });
//                   }
//                 } else {
//                   // Editar la pregunta seleccionada
//                   if (questionText.isNotEmpty) {
//                     questions[selectedQuestionIndex] =
//                         '$questionText (Obligatoria: $isMandatory)';
//                     setState(() {
//                       selectedQuestionIndex = -1;
//                       questionText = '';
//                       isMandatory = false;
//                     });
//                   }
//                 }
//               },
//               child: Text(selectedQuestionIndex == -1
//                   ? 'Agregar Pregunta'
//                   : 'Guardar Cambios'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Preguntas Agregadas:',
//               style: TextStyle(fontSize: 18),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: questions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(questions[index]),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () {
//                             setState(() {
//                               selectedQuestionIndex = index;
//                               String selectedQuestion = questions[index];
//                               // Separar el texto y la opción "Obligatoria"
//                               List<String> parts =
//                                   selectedQuestion.split('(Obligatoria: ');
//                               questionText = parts[0].trim();
//                               isMandatory = parts[1].contains('Sí');
//                             });
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () {
//                             setState(() {
//                               questions.removeAt(index);
//                               // Si la pregunta eliminada era la seleccionada, limpiar la edición
//                               if (selectedQuestionIndex == index) {
//                                 selectedQuestionIndex = -1;
//                                 questionText = '';
//                                 isMandatory = false;
//                               }
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


