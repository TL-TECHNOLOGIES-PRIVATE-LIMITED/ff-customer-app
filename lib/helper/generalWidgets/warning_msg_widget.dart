import 'package:project/helper/utils/generalImports.dart';

Widget WarningMessageContainer({
  required BuildContext context,
  required String text,
  required MessageType type,
}) {
  return Container(
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        stops: const [0.02, 0.02],
        colors: [
          messageColors[type]!,
          messageColors[type]!.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: messageColors[type]!.withOpacity(0.5),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 3,
        ),
        messageIcon[type]!,
        Container(
          width: 350,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 1),
            child: CustomTextLabel(
              jsonKey: text,
              softWrap: true,
              style: TextStyle(
                color: messageColors[type],
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
