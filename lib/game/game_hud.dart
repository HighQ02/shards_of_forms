import 'package:flutter/material.dart';
import 'my_game.dart';

class GameHUD extends StatefulWidget {
  final MyGame game;

  const GameHUD({super.key, required this.game});

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HP Bar
          Row(
            children: [
              Text(
                'HP: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: widget.game.player.getHealthPercent(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [Colors.red[700]!, Colors.red[500]!],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${widget.game.player.health.toInt()} / ${widget.game.player.maxHealth.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // XP Bar
          Row(
            children: [
              Text(
                'XP: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: widget.game.player.getExperiencePercent(),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [Colors.blue[700]!, Colors.blue[500]!],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${widget.game.player.experience.toInt()} / ${widget.game.player.experienceToLevelUp.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Level
          Text(
            'Уровень: ${widget.game.player.level}',
            style: TextStyle(
              color: Colors.yellow[300],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Enemies count
          Text(
            'Врагов: ${widget.game.enemyManager.getEnemyCount()}',
            style: TextStyle(
              color: Colors.orange[300],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
