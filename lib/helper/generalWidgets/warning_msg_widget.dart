import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart'; // Contains messageColors and MessageType

class WarningMessageContainer extends StatelessWidget {
  final String text;
  final MessageType type;

  const WarningMessageContainer({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = messageColors[type]!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconFromType(type),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getTitleFromType(type),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomTextLabel(
            jsonKey: text,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  height: 1.5,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }

  String _getTitleFromType(MessageType type) {
    switch (type) {
      case MessageType.warning:
        return "Warning!";
      case MessageType.error:
        return "Error!";
      case MessageType.success:
        return "Success!";
    }
  }

  IconData _getIconFromType(MessageType type) {
    switch (type) {
      case MessageType.warning:
        return Icons.warning_amber_rounded;
      case MessageType.error:
        return Icons.error_outline_rounded;
      case MessageType.success:
        return Icons.check_circle_outline_rounded;
    }
  }
}
