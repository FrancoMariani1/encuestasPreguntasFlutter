import 'package:flutter/material.dart';

class SurveyDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> surveys;
  final Function(String) onChanged;

  SurveyDropdown({required this.surveys, required this.onChanged});

  @override
  _SurveyDropdownState createState() => _SurveyDropdownState();
}

class _SurveyDropdownState extends State<SurveyDropdown> {
  int? _selectedSurveyId;

  @override
  void initState() {
    super.initState();
    _updateSelectedSurveyId();
  }

  void _updateSelectedSurveyId() {
    if (widget.surveys.isNotEmpty) {
      _selectedSurveyId =
          widget.surveys.any((survey) => survey['id'] == _selectedSurveyId)
              ? _selectedSurveyId
              : widget.surveys[0]['id'];
      setState(() {});
    } else {
      _selectedSurveyId = null;
    }
  }

  @override
  void didUpdateWidget(covariant SurveyDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.surveys != oldWidget.surveys) {
      _updateSelectedSurveyId();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.surveys.isEmpty
        ? Text('No hay encuestas disponibles.')
        : DropdownButton<int>(
            value: _selectedSurveyId,
            onChanged: (newValue) {
              setState(() {
                _selectedSurveyId = newValue;
              });
              widget.onChanged(widget.surveys
                  .firstWhere((survey) => survey['id'] == newValue)['name']);
            },
            items: widget.surveys.map<DropdownMenuItem<int>>((survey) {
              return DropdownMenuItem<int>(
                value: survey['id'],
                child: Text(survey['name']),
              );
            }).toList(),
          );
  }
}
