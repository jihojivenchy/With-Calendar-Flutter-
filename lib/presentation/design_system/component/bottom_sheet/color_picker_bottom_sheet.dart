import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../button/app_button.dart';

class ColorPickerBottomSheet extends StatefulWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPickerBottomSheet({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerBottomSheet> createState() => _ColorPickerBottomSheetState();
}

class _ColorPickerBottomSheetState extends State<ColorPickerBottomSheet> {
  static const List<Color> _colorList = [
    Color(0xFF00925B),
    Color(0xFF66C28D),
    Color(0xFF50A196),
    Color(0xFF52925A),
    Color(0xFF6ECCAF),
    Color(0xFFFDD3D2),
    Color(0xFFFCDAE8),
    Color(0xFFEAA1C0),
    Color(0xFFFD8687),
    Color(0xFFC9485B),
    Color(0xFFABD9FF),
    Color(0xFFA7B3E2),
    Color(0xFF92D9E5),
    Color(0xFF5E9DF6),
    Color(0xFF277BC0),
    Color(0xFFFAEFE5),
    Color(0xFFD9C1AF),
    Color(0xFF90806B),
    Color(0xFF9E7677),
    Color(0xFF6F4C5B),
  ];

  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 34,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _colorList.length,
              itemBuilder: (BuildContext context, int index) {
                final Color color = _colorList[index];
                final bool isSelected = _selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Center(
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppButton(
                text: '완료',
                onTapped: () => widget.onColorSelected(_selectedColor),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
