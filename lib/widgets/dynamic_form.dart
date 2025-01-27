import 'package:flutter/material.dart';
import 'package:shop_manager/helpers/app_language.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'custom_snack_bar.dart';
import 'custom_text_field.dart';

class DynamicForm extends StatefulWidget {
  final List<String> fields;
  final String endpoint;
  final String title;
  final int? id; // Optional ID for updating an item
  final Map<String, String>? initialData; // Data to pre-fill the form fields

  const DynamicForm({
    super.key,
    required this.fields,
    required this.endpoint,
    required this.title,
    this.id,
    this.initialData,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _fieldErrors = {}; // Track validation errors for each field
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _controllers[field] = TextEditingController(
        text: widget.initialData != null ? widget.initialData![field] : null,
      );
      _fieldErrors[field] = null; // Initialize field error as null
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    Map<String, String> formData = {};
    for (var field in widget.fields) {
      formData[field] = _controllers[field]!.text;
    }

    try {
      // Add ID to the endpoint if updating an item
      final String url = widget.id != null ? "${widget.endpoint}/${widget.id}" : widget.endpoint;

      final response = widget.id != null
          ? await ApiHelper.put(url, body: formData)
          : await ApiHelper.post(url, body: formData);

      if (response.status) {
        // Pop the current page and show the SnackBar on the previous page
        if (mounted) {
          Navigator.of(context).pop();
          customSnackBar(context, AppLanguage().translate('request_success'), null);
        }
      } else {
        // Handle validation errors or general errors
        if (response.validations.isNotEmpty) {
          // Validation errors
          setState(() {
            for (var field in response.validations.keys) {
              if (_fieldErrors.containsKey(field)) {
                _fieldErrors[field] = response.validations[field].join(', ');
              }
            }
          });
        } else {
          // General error message
          String errorMessage = response.errors.isNotEmpty
              ? response.errors.first
              : AppLanguage().translate('server_error');

          if (mounted) {
            customSnackBar(context, errorMessage, null);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        customSnackBar(context, '${AppLanguage().translate('network_error')}: $e', null);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Set loading state back to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLanguage().translate('store')} ${AppLanguage().translate(widget.title)}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...widget.fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CustomTextField(
                    controller: _controllers[field],
                    labelText: AppLanguage().translate(field),
                    hintText: AppLanguage().translate(field),
                    validator: (value) {
                      if (_fieldErrors[field] != null) {
                        return _fieldErrors[field]; // Show validation error if exists
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm, // Disable button when loading
                  child: _isLoading
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(AppLanguage().translate('submit')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}