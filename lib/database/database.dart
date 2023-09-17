import 'package:postgres/postgres.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final PostgreSQLConnection _connection = PostgreSQLConnection(
    'localhost',
    5432,
    'nombre_de_tu_base_de_datos',
    username: 'tu_usuario',
    password: 'tu_contraseña',
  );

  Future<void> connect() async {
    try {
      await _connection.open();
      print('Conexión exitosa');
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<void> insertSurvey(String surveyName) async {
    try {
      await _connection.query(
        'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
        substitutionValues: {'surveyName': surveyName},
      );
    } catch (e) {
      print('Error al insertar encuesta: $e');
    }
  }

  Future<void> insertQuestion(
      String surveyName, String questionText, bool isMandatory) async {
    try {
      await _connection.query(
        'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES ((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1), @questionText, @isMandatory)',
        substitutionValues: {
          'surveyName': surveyName,
          'questionText': questionText,
          'isMandatory': isMandatory,
        },
      );
    } catch (e) {
      print('Error al insertar pregunta: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsForSurvey(
      String surveyName) async {
    try {
      final result = await _connection.query(
        'SELECT id_pregunta, texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
        substitutionValues: {'surveyName': surveyName},
      );

      final List<Map<String, dynamic>> retrievedQuestions = [];

      for (final row in result) {
        final questionId = row[0] as int;
        final questionText = row[1] as String;
        final isMandatory = row[2] as bool;
        retrievedQuestions.add({
          'id': questionId,
          'text': '$questionText (Obligatoria: ${isMandatory ? 'Sí' : 'No'})',
          'isMandatory': isMandatory,
        });
      }

      return retrievedQuestions;
    } catch (e) {
      print('Error al obtener preguntas: $e');
      return [];
    }
  }

  Future<void> updateQuestion(String surveyName, int questionId,
      String newQuestionText, bool isMandatory) async {
    try {
      await _connection.query(
        'UPDATE preguntas SET texto_pregunta = @newQuestionText, es_obligatoria = @isMandatory WHERE id_pregunta = @questionId AND id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
        substitutionValues: {
          'surveyName': surveyName,
          'questionId': questionId,
          'newQuestionText': newQuestionText,
          'isMandatory': isMandatory,
        },
      );
    } catch (e) {
      print('Error al actualizar la pregunta: $e');
    }
  }

  Future<void> deleteQuestion(String surveyName, int questionId) async {
    try {
      await _connection.query(
        'DELETE FROM preguntas WHERE id_pregunta = @questionId AND id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
        substitutionValues: {
          'surveyName': surveyName,
          'questionId': questionId
        },
      );
    } catch (e) {
      print('Error al eliminar la pregunta: $e');
    }
  }

  Future<void> close() async {
    await _connection.close();
  }
}


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal() {
//     openConnection();
//   }

//   Future<void> openConnection() async {
//     try {
//       _connection = PostgreSQLConnection(
//         'localhost',
//         5432,
//         'Surveys',
//         username: 'Franco',
//         password: '160120',
//       );
//       await _connection.open();
//       print('Conexión exitosa');
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//       print('Encuesta insertada exitosamente');
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       // questions = await getQuestionsForSurvey(surveyName);
//       print('Pregunta insertada exitosamente');
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions
//             .add('$questionText (Obligatoria: ${isMandatory ? 'Sí' : 'No'})');
//       }

//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       return [];
//     }
//   }

//   Future<void> deleteQuestion(String surveyName, int questionId) async {
//     try {
//       await _connection.query(
//         'DELETE FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1) AND id_pregunta = @questionId',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionId': questionId,
//         },
//       );
//       print('Pregunta eliminada exitosamente');
//     } catch (e) {
//       print('Error al eliminar pregunta: $e');
//     }
//   }

//   Future<void> updateQuestion(String surveyName, int questionId,
//       String newQuestionText, bool isMandatory) async {
//     try {
//       await _connection.query(
//         'UPDATE preguntas SET texto_pregunta = @newQuestionText, es_obligatoria = @isMandatory WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1) AND id_pregunta = @questionId',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionId': questionId,
//           'newQuestionText': newQuestionText,
//           'isMandatory': isMandatory,
//         },
//       );
//       print('Pregunta actualizada exitosamente');
//     } catch (e) {
//       print('Error al actualizar pregunta: $e');
//     }
//   }
// }

// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal() {
//     openConnection();
//   }

//   Future<void> openConnection() async {
//     try {
//       _connection = PostgreSQLConnection(
//         'localhost',
//         5432,
//         'Surveys',
//         username: 'Franco',
//         password: '160120',
//       );
//       await _connection.open();
//       print('Conexión exitosa');
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//       print('Encuesta insertada exitosamente');
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       questions = await getQuestionsForSurvey(surveyName);
//       print('Pregunta insertada exitosamente');
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName LIMIT 1)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions
//             .add('$questionText (Obligatoria: ${isMandatory ? 'Sí' : 'No'})');
//       }

//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       return [];
//     }
//   }

//   Future<void> deleteQuestion(String surveyName, String questionText) async {
//     try {
//       await _connection.query(
//         'DELETE FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName) AND texto_pregunta = @questionText',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText
//         },
//       );
//     } catch (e) {
//       print('Error al eliminar pregunta: $e');
//     }
//   }

//   Future<void> updateQuestion(String surveyName, String oldQuestionText,
//       String newQuestionText, bool isMandatory) async {
//     try {
//       await _connection.query(
//         'UPDATE preguntas SET texto_pregunta = @newQuestionText, es_obligatoria = @isMandatory WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName) AND texto_pregunta = @oldQuestionText',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'oldQuestionText': oldQuestionText,
//           'newQuestionText': newQuestionText,
//           'isMandatory': isMandatory,
//         },
//       );
//     } catch (e) {
//       print('Error al actualizar pregunta: $e');
//     }
//   }
// }


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   PostgreSQLConnection? _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal() {
//     openConnection();
//   }

//   Future<void> openConnection() async {
//     if (_connection == null || _connection!.isClosed) {
//       try {
//         _connection = PostgreSQLConnection(
//           'localhost',
//           5432,
//           'Surveys',
//           username: 'Franco',
//           password: '160120',
//         );
//         await _connection!.open();
//       } catch (e) {
//         print('Error al abrir la conexión: $e');
//       }
//     }
//   }

//   Future<void> closeConnection() async {
//     if (_connection != null && _connection!.isClosed) {
//       try {
//         await _connection!.close();
//       } catch (e) {
//         print('Error al cerrar la conexión: $e');
//       }
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await openConnection();
//       await _connection!.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await openConnection();
//       await _connection!.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       questions = await getQuestionsForSurvey(surveyName);
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       await openConnection();
//       final result = await _connection!.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions
//             .add('$questionText (Obligatoria: ${isMandatory ? 'Sí' : 'No'})');
//       }

//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       return [];
//     }
//   }
// }


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal() {
//     openConnection();
//   }

//   Future<void> openConnection() async {
//     try {
//       _connection = PostgreSQLConnection(
//         'localhost',
//         5432,
//         'Surveys',
//         username: 'Franco',
//         password: '160120',
//       );
//       await _connection.open();
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       questions = await getQuestionsForSurvey(surveyName);
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions
//             .add('$questionText (Obligatoria: ${isMandatory ? 'Sí' : 'No'})');
//       }

//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       return [];
//     }
//   }
// }


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal();

//   Future<void> openConnection() async {
//     try {
//       _connection = PostgreSQLConnection(
//         'localhost',
//         5432,
//         'Surveys',
//         username: 'Franco',
//         password: '160120',
//       );
//       await _connection.open();
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await openConnection();
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await openConnection();
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       questions = await getQuestionsForSurvey(surveyName);
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       await openConnection();
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions.add('$questionText (Obligatoria: $isMandatory)');
//       }

//       await closeConnection();
//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       await closeConnection();
//       return [];
//     }
//   }
// }

// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal();

//   Future<void> openConnection() async {
//     try {
//       _connection = PostgreSQLConnection(
//         'localhost',
//         5432,
//         'Surveys',
//         username: 'Franco',
//         password: '160120',
//       );
//       await _connection.open();
//       print("Conexión abierta");
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//       throw Exception('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//       throw Exception('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await openConnection();
//       var result = await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName) RETURNING id_encuesta',
//         substitutionValues: {'surveyName': surveyName},
//       );
//       print(result);
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//       throw Exception('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await openConnection();
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       questions = await getQuestionsForSurvey(surveyName);
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//       throw Exception('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       await openConnection();
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions.add('$questionText (Obligatoria: $isMandatory)');
//       }

//       await closeConnection();
//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       await closeConnection();
//       return [];
//     }
//   }
// }


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late final PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal() {
//     _connection = PostgreSQLConnection(
//       'localhost',
//       5432,
//       'Surveys',
//       username: 'Franco',
//       password: '160120',
//     );
//   }

//   Future<void> openConnection() async {
//     try {
//       await _connection.open();
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       // Abre la conexión antes de insertar
//       await openConnection();
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//       // Cierra la conexión después de insertar
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       // Abre la conexión antes de insertar
//       await openConnection();
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       // Después de insertar, recupera las preguntas actualizadas
//       questions = await getQuestionsForSurvey(surveyName);
//       // Cierra la conexión después de recuperar las preguntas
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       // Abre la conexión antes de obtener las preguntas
//       await openConnection();
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions.add('$questionText (Obligatoria: $isMandatory)');
//       }

//       // Cierra la conexión después de obtener las preguntas
//       await closeConnection();
//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       // Asegúrate de cerrar la conexión en caso de error
//       await closeConnection();
//       return [];
//     }
//   }
// }



// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late final PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal() {
//     _connection = PostgreSQLConnection(
//       'localhost',
//       5432,
//       'Surveys',
//       username: 'Franco',
//       password: '160120',
//     );
//   }

//   Future<void> openConnection() async {
//     try {
//       await _connection.open();
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       // Abre la conexión antes de insertar
//       await openConnection();
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//       // Cierra la conexión después de insertar
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       // Abre la conexión antes de insertar
//       await openConnection();
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       // Después de insertar, recupera las preguntas actualizadas
//       questions = await getQuestionsForSurvey(surveyName);
//       // Cierra la conexión después de recuperar las preguntas
//       await closeConnection();
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       // Abre la conexión antes de obtener las preguntas
//       await openConnection();
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions.add('$questionText (Obligatoria: $isMandatory)');
//       }

//       // Cierra la conexión después de obtener las preguntas
//       await closeConnection();
//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       // Asegúrate de cerrar la conexión en caso de error
//       await closeConnection();
//       return [];
//     }
//   }
// }


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late final PostgreSQLConnection _connection;
//   List<String> questions = []; // Lista de preguntas de la encuesta actual

//   DatabaseHelper._internal() {
//     _connection = PostgreSQLConnection(
//       'localhost',
//       5432,
//       'Surveys',
//       username: 'Franco',
//       password: '160120',
//     );
//   }

//   Future<void> openConnection() async {
//     try {
//       await _connection.open();
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );

//       // Después de insertar, recupera las preguntas actualizadas
//       questions = await getQuestionsForSurvey(surveyName);
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//     }
//   }

//   Future<List<String>> getQuestionsForSurvey(String surveyName) async {
//     try {
//       final result = await _connection.query(
//         'SELECT texto_pregunta, es_obligatoria FROM preguntas WHERE id_encuesta = (SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );

//       final List<String> retrievedQuestions = [];

//       for (final row in result) {
//         final questionText = row[0] as String;
//         final isMandatory = row[1] as bool;
//         retrievedQuestions.add('$questionText (Obligatoria: $isMandatory)');
//       }

//       return retrievedQuestions;
//     } catch (e) {
//       print('Error al obtener preguntas: $e');
//       return [];
//     }
//   }
// }


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late final PostgreSQLConnection _connection;

//   DatabaseHelper._internal() {
//     _connection = PostgreSQLConnection(
//       'localhost',
//       5432,
//       'Surveys',
//       username: 'Franco',
//       password: '160120',
//     );
//   }

//   Future<void> openConnection() async {
//     try {
//       await _connection.open();
//     } catch (e) {
//       print('Error al abrir la conexión: $e');
//       // Maneja el error apropiadamente, por ejemplo, lanzando una excepción.
//     }
//   }

//   Future<void> closeConnection() async {
//     try {
//       await _connection.close();
//     } catch (e) {
//       print('Error al cerrar la conexión: $e');
//       // Maneja el error apropiadamente, por ejemplo, lanzando una excepción.
//     }
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     try {
//       await _connection.query(
//         'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//         substitutionValues: {'surveyName': surveyName},
//       );
//     } catch (e) {
//       print('Error al insertar encuesta: $e');
//       // Maneja el error apropiadamente, por ejemplo, lanzando una excepción.
//     }
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     try {
//       await _connection.query(
//         'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//         '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//         substitutionValues: {
//           'surveyName': surveyName,
//           'questionText': questionText,
//           'isMandatory': isMandatory,
//         },
//       );
//     } catch (e) {
//       print('Error al insertar pregunta: $e');
//       // Maneja el error apropiadamente, por ejemplo, lanzando una excepción.
//     }
//   }
// }


// import 'package:postgres/postgres.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   late final PostgreSQLConnection _connection;

//   DatabaseHelper._internal() {
//     _connection = PostgreSQLConnection(
//       'localhost',
//       5432,
//       'Surveys',
//       username: 'Franco',
//       password: '160120',
//     );
//   }

//   Future<void> openConnection() async {
//     await _connection.open();
//   }

//   Future<void> closeConnection() async {
//     await _connection.close();
//   }

//   Future<void> insertSurvey(String surveyName) async {
//     await _connection.query(
//       'INSERT INTO encuestas (nombre_encuesta) VALUES (@surveyName)',
//       substitutionValues: {'surveyName': surveyName},
//     );
//   }

//   Future<void> insertQuestion(
//     String surveyName,
//     String questionText,
//     bool isMandatory,
//   ) async {
//     await _connection.query(
//       'INSERT INTO preguntas (id_encuesta, texto_pregunta, es_obligatoria) VALUES '
//       '((SELECT id_encuesta FROM encuestas WHERE nombre_encuesta = @surveyName), @questionText, @isMandatory)',
//       substitutionValues: {
//         'surveyName': surveyName,
//         'questionText': questionText,
//         'isMandatory': isMandatory,
//       },
//     );
//   }
// }
