// import 'package:flutter/material.dart';
// import '../database/database.dart';

// class SurveyProvider extends ChangeNotifier {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<Map<String, dynamic>> questions = [];
//   String? errorMessage; // Variable para manejar mensajes de error

//   final DatabaseHelper _dbHelper =
//       DatabaseHelper(); // Obtén una instancia de DatabaseHelper

//   void updateSurveyName(String value) {
//     surveyName = value;
//     notifyListeners();
//   }

//   void updateQuestionText(String value) {
//     questionText = value;
//     notifyListeners();
//   }

//   void updateIsMandatory(bool value) {
//     isMandatory = value;
//     notifyListeners();
//   }

//   Future<void> addQuestion() async {
//     if (questionText.isNotEmpty && surveyName.isNotEmpty) {
//       try {
//         questions
//             .add({'questionText': questionText, 'isMandatory': isMandatory});

//         // Llamada a la base de datos con el uso de la instancia _dbHelper
//         await _dbHelper.insertQuestion(surveyName, questionText, isMandatory);

//         // Restablecer los campos después de una inserción exitosa
//         questionText = '';
//         isMandatory = false;

//         // Restablecer el mensaje de error en caso de éxito
//         errorMessage = null;
//       } catch (error) {
//         // Captura cualquier error que pueda surgir y asígnalo a errorMessage
//         errorMessage = error.toString();
//       }
//       notifyListeners();
//     } else {
//       // Establecer un mensaje de error apropiado si la validación falla
//       errorMessage =
//           'El nombre de la encuesta y el texto de la pregunta son obligatorios';
//       notifyListeners();
//     }
//   }
// }


// import 'package:flutter/material.dart';
// import '../database/database.dart';

// class SurveyProvider extends ChangeNotifier {
//   String surveyName = "";
//   String questionText = "";
//   bool isMandatory = false;
//   List<Map<String, dynamic>> questions = [];

//   void updateSurveyName(String value) {
//     surveyName = value;
//     notifyListeners();
//   }

//   void updateQuestionText(String value) {
//     questionText = value;
//     notifyListeners();
//   }

//   void updateIsMandatory(bool value) {
//     isMandatory = value;
//     notifyListeners();
//   }

//   void addQuestion() {
//     if (questionText.isNotEmpty && surveyName.isNotEmpty) {
//       questions.add({'questionText': questionText, 'isMandatory': isMandatory});
//       DatabaseHelper.insertQuestion(surveyName, questionText, isMandatory);
//       questionText = '';
//       isMandatory = false;
//       notifyListeners();
//     } else {
//       // Mostrar algún tipo de error o mensaje de validación
//     }
//   }
// }
