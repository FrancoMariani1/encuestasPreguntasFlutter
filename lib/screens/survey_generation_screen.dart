// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../question_widget.dart';
// import '../providers/survey_provider.dart';

// class SurveyGenerationScreen extends StatelessWidget {
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
//           children: [
//             SurveyNameInput(),
//             SizedBox(height: 20),
//             AddQuestionSection(),
//             SizedBox(height: 20),
//             Expanded(child: QuestionsList()),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SurveyNameInput extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTitle('Nombre de la Encuesta:'),
//         SizedBox(height: 8),
//         TextField(
//           onChanged: (value) {
//             Provider.of<SurveyProvider>(context, listen: false)
//                 .updateSurveyName(value);
//           },
//           decoration:
//               _buildInputDecoration('Introduce el nombre de la encuesta'),
//         ),
//       ],
//     );
//   }

//   Text _buildTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }

//   InputDecoration _buildInputDecoration(String hintText) {
//     return InputDecoration(
//       hintText: hintText,
//       border: OutlineInputBorder(),
//     );
//   }
// }

// class AddQuestionSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTitle('Agregar Pregunta:'),
//         SizedBox(height: 8),
//         TextField(
//           onChanged: (value) {
//             Provider.of<SurveyProvider>(context, listen: false)
//                 .updateQuestionText(value);
//           },
//           decoration: _buildInputDecoration('Texto de la Pregunta'),
//         ),
//         SizedBox(height: 10),
//         _buildMandatoryCheckbox(context),
//         _buildAddButton(context),
//       ],
//     );
//   }

//   Text _buildTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }

//   InputDecoration _buildInputDecoration(String hintText) {
//     return InputDecoration(
//       hintText: hintText,
//       border: OutlineInputBorder(),
//     );
//   }

//   Row _buildMandatoryCheckbox(BuildContext context) {
//     return Row(
//       children: [
//         Text('Obligatoria:', style: TextStyle(fontSize: 16)),
//         Checkbox(
//           value: Provider.of<SurveyProvider>(context).isMandatory,
//           onChanged: (value) {
//             if (value != null) {
//               Provider.of<SurveyProvider>(context, listen: false)
//                   .updateIsMandatory(value);
//             }
//           },
//         ),
//       ],
//     );
//   }

//   ElevatedButton _buildAddButton(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         await Provider.of<SurveyProvider>(context, listen: false).addQuestion();
//         final provider = Provider.of<SurveyProvider>(context, listen: false);
//         if (provider.errorMessage != null) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Pregunta agregada correctamente')));
//         }
//       },
//       child: Text('Agregar Pregunta'),
//     );
//   }
// }

// class QuestionsList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTitle('Preguntas Agregadas:'),
//         Expanded(child: _buildQuestionsListView(context)),
//       ],
//     );
//   }

//   Text _buildTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }

//   Widget _buildQuestionsListView(BuildContext context) {
//     return ListView.builder(
//       itemCount: Provider.of<SurveyProvider>(context).questions.length,
//       itemBuilder: (context, index) {
//         final question = Provider.of<SurveyProvider>(context).questions[index];
//         return QuestionWidget(
//           questionText: question['questionText'],
//           isMandatory: question['isMandatory'],
//         );
//       },
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../question_widget.dart';
// import '../providers/survey_provider.dart';

// class SurveyGenerationScreen extends StatelessWidget {
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
//           children: [
//             SurveyNameInput(),
//             SizedBox(height: 20),
//             AddQuestionSection(),
//             SizedBox(height: 20),
//             Expanded(child: QuestionsList()),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SurveyNameInput extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Nombre de la Encuesta:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         SizedBox(height: 8),
//         TextField(
//           onChanged: (value) {
//             Provider.of<SurveyProvider>(context, listen: false)
//                 .updateSurveyName(value);
//           },
//           decoration: InputDecoration(
//             hintText: 'Introduce el nombre de la encuesta',
//             border: OutlineInputBorder(),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class AddQuestionSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Agregar Pregunta:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         SizedBox(height: 8),
//         TextField(
//           onChanged: (value) {
//             Provider.of<SurveyProvider>(context, listen: false)
//                 .updateQuestionText(value);
//           },
//           decoration: InputDecoration(
//             hintText: 'Texto de la Pregunta',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         SizedBox(height: 10),
//         Row(
//           children: [
//             Text('Obligatoria:', style: TextStyle(fontSize: 16)),
//             Checkbox(
//               value: Provider.of<SurveyProvider>(context).isMandatory,
//               onChanged: (value) {
//                 if (value != null) {
//                   Provider.of<SurveyProvider>(context, listen: false)
//                       .updateIsMandatory(value);
//                 }
//               },
//             ),
//           ],
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Provider.of<SurveyProvider>(context, listen: false).addQuestion();
//           },
//           child: Text('Agregar Pregunta'),
//         ),
//       ],
//     );
//   }
// }

// class QuestionsList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Preguntas Agregadas:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         Expanded(
//           child: ListView.builder(
//             itemCount: Provider.of<SurveyProvider>(context).questions.length,
//             itemBuilder: (context, index) {
//               final question =
//                   Provider.of<SurveyProvider>(context).questions[index];
//               return QuestionWidget(
//                 questionText: question['questionText'],
//                 isMandatory: question['isMandatory'],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'database.dart';
// import 'models.dart';

// class SurveyGenerationScreen extends StatefulWidget {
//   @override
//   _SurveyGenerationScreenState createState() => _SurveyGenerationScreenState();
// }

// class _SurveyGenerationScreenState extends State<SurveyGenerationScreen> {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<Question> questions = [];
//   int selectedQuestionIndex = -1;
//   final dbHelper = DatabaseHelper();

//   @override
//   void initState() {
//     super.initState();
//     dbHelper.openConnection();
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
//         backgroundColor: Colors.blueGrey,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text('Nombre de la Encuesta:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   surveyName = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Introduce el nombre de la encuesta',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text('Agregar Pregunta:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             TextField(
//               onChanged: (value) {
//                 setState(() {
//                   questionText = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Texto de la Pregunta',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
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
//                 if (surveyName.isEmpty || questionText.isEmpty) {
//                   // Implementa un mensaje de error aquí
//                   return;
//                 }
//                 await dbHelper.insertSurvey(surveyName);
//                 await dbHelper.insertQuestion(
//                   surveyName,
//                   questionText,
//                   isMandatory,
//                 );
//                 loadQuestions();
//               },
//               child: Text('Agregar Pregunta'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blueAccent,
//                 textStyle: TextStyle(fontSize: 16),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text('Preguntas Agregadas:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: questions.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(
//                       questions[index].text +
//                           (questions[index].isMandatory
//                               ? ' (Obligatoria)'
//                               : ''),
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     // Añade las opciones de editar y eliminar aquí
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
