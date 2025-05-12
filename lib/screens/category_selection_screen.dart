import 'package:flutter/material.dart';
import 'package:habitgo/models/category.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<Category> _categories = [
    Category(label: 'Чтение', icon: Icons.book),
    Category(label: 'Спорт', icon: Icons.fitness_center),
    Category(label: 'Программирование', icon: Icons.code),
    Category(label: 'Рисование', icon: Icons.brush),
    Category(label: 'Изучение языков', icon: Icons.language),
    Category(label: 'Здоровье', icon: Icons.favorite),
    Category(label: 'Другое', icon: Icons.more_horiz),
  ];

  void _addCustomCategory() async {
    String? newLabel;
    IconData? newIcon = Icons.star;
    final icons = [
      Icons.star, Icons.favorite, Icons.pets, Icons.coffee, Icons.nightlife, Icons.travel_explore, Icons.spa, Icons.emoji_nature, Icons.palette, Icons.sports_soccer, Icons.computer, Icons.camera_alt
    ];
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1FFFC), Color(0xFF52B3B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Новая категория',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF225B6A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Название категории',
                        labelStyle: const TextStyle(color: Color(0xFF52B3B6)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF52B3B6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF52B3B6), width: 2),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16, color: Color(0xFF225B6A)),
                      onChanged: (value) => newLabel = value,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Иконка',
                      style: TextStyle(fontSize: 16, color: Color(0xFF225B6A), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: GridView.count(
                        crossAxisCount: 5,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: icons.map((icon) {
                          final isSelected = newIcon == icon;
                          return GestureDetector(
                            onTap: () {
                              setStateDialog(() {
                                newIcon = icon;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF52B3B6) : Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? const Color(0xFF225B6A) : const Color(0xFF52B3B6), width: 2),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF52B3B6).withOpacity(0.18),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                icon,
                                size: 32,
                                color: isSelected ? Colors.white : const Color(0xFF52B3B6),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Отмена', style: TextStyle(fontSize: 16)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF52B3B6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (newLabel != null && newLabel!.trim().isNotEmpty) {
                              final newCategory = Category(label: newLabel!.trim(), icon: newIcon!);
                              setState(() {
                                _categories.insert(_categories.length - 1, newCategory);
                              });
                              Navigator.of(context).pop();
                              Navigator.of(context).pop(newCategory);
                            }
                          },
                          child: const Text('Добавить'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1FFFC), Color(0xFF52B3B6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: const [
                    Icon(Icons.category, color: Color(0xFF52B3B6), size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Выберите категорию',
                      style: TextStyle(
                        color: Color(0xFF225B6A),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        if (category.label == 'Другое') {
                          _addCustomCategory();
                        } else {
                          Navigator.pop(context, category);
                        }
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: Icon(category.icon, size: 32, color: const Color(0xFF52B3B6)),
                          title: Text(
                            category.label,
                            style: const TextStyle(fontSize: 18, color: Color(0xFF225B6A), fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF52B3B6)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 