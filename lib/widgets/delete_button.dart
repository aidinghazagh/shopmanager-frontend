import 'package:flutter/material.dart';

import '../helpers/app_language.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteButton({
    super.key,
    required this.onDelete,
  });

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLanguage().translate('confirm_deletion')),
          content: Text(AppLanguage().translate('delete_message')),
          actions: <Widget>[
            TextButton(
              child: Text(AppLanguage().translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(AppLanguage().translate('delete'), style: TextStyle(color: Colors.red)),
              onPressed: () {
                onDelete(); // Perform the deletion
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => _showDeleteConfirmationDialog(context),
      tooltip: AppLanguage().translate('delete'),
    );
  }
}