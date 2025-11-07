// game/pause_menu.dart
import 'dart:ui'; // <--- НОВЫЙ ИМПОРТ для размытия (BackdropFilter)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- НОВЫЙ ИМПОРТ для шрифтов
import 'my_game.dart';
import '../menu/main_menu.dart';

class PauseMenu extends StatelessWidget {
  final MyGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        // <--- ФИЛЬТР РАЗМЫТИЯ
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ), // Размываем игру на фоне
        child: Container(
          // --- 1. СЛОЙ ЗАТЕМНЕНИЯ (твой градиент) ---
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                Colors.black.withOpacity(0.2), // В центре (светлее)
                Colors.black.withOpacity(0.6), // По краям (темнее)
              ],
              stops: const [0.0, 1.0],
            ),
          ),

          // --- 2. СЛОЙ КНОПОК ---
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                // Полупрозрачный "стеклянный" фон
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4), // Тонкая белая рамка
                  width: 1.5,
                ),
                boxShadow: [
                  // Тень, чтобы "отлепить" меню от фона
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Пауза',
                    style: GoogleFonts.ebGaramond(
                      // <--- Красивый шрифт
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 1. Кастомная кнопка "Продолжить"
                  _PauseMenuButton(
                    text: 'Продолжить',
                    onPressed: () {
                      game.togglePauseMenu(); // Снимаем игру с паузы
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Кастомная кнопка "Настройки"
                  _PauseMenuButton(
                    text: 'Настройки',
                    onPressed: () {
                      print('Настройки (пока не реализовано)');
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Кастомная кнопка "Выйти в меню"
                  _PauseMenuButton(
                    text: 'Выйти в меню',
                    onPressed: () {
                      game.togglePauseMenu();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainMenu()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --- Наша собственная КРАСИВАЯ КНОПКА ---
/// (Это приватный виджет, он будет виден только внутри этого файла)
class _PauseMenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PauseMenuButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230, // Задаем ширину
      child: InkWell(
        // <--- InkWell для эффекта "клик" (рябь)
        onTap: onPressed,
        splashColor: Colors.white.withOpacity(0.3), // Цвет ряби
        highlightColor: Colors.white.withOpacity(0.1), // Цвет при удержании
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3), // Фон кнопки
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 1.5,
            ), // Рамка
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.ebGaramond(
                // <--- Тот же красивый шрифт
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
