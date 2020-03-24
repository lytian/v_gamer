import 'dart:async';

import 'package:flutter/material.dart';
import 'package:v_gamer/gamer/gamer.dart';
import 'package:v_gamer/gamer/tetris/block.dart';

import '../game_widget.dart';

class Tetris extends Game {
  
  Tetris(BuildContext context, Function refresh) : super(context, refresh);

  Block next = Block.getRandom();

  Block _current;

  Timer _autoFallTimer;

  Block _getNext() {
    final _next = next;
    next = Block.getRandom();
    return _next;
  }

  @override
  onDownTap() {
    _down();
  }

  @override
  onLeftTap() {
    if (states == GameStates.none && level > LEVEL_MIN) {
      // 如果游戏未开始，降低游戏难度级别
      level--;
    } else if (states == GameStates.running && _current != null) {
      // 开始过后，则正常右移
      final next = _current.left();
      if (next.isValidInMatrix(data)) {
        _current = next;
        sound.move();
      }
    }
    setState(() {});
  }
  

  @override
  onRightTap() {
    if (states == GameStates.none && level < LEVEL_MAX) {
      // 如果游戏未开始，增加游戏难度级别
      level++;
    } else if (states == GameStates.running && _current != null) {
      // 开始过后，则正常右移
      final next = _current.right();
      if (next.isValidInMatrix(data)) {
        _current = next;
        sound.move();
      }
    }
    setState(() {});
  }

  @override
  onUpTap() {
    if (states == GameStates.running && _current != null) {
      final next1 = _current.rotate();
      if (next1.isValidInMatrix(data)) {
        _current = next1;
        sound.rotate();
      }
    }
    setState(() {});
  }

  @override
  onPauseResumeTap() {
    if (states == GameStates.running) {
      pause();
    } else if (states == GameStates.paused || states == GameStates.none) {
      _startGame();
    }
  }

  @override
  onQuickTap() async {
    if (states == GameStates.running && _current != null) {
      for (int i = 0; i < GAME_PAD_MATRIX_H; i++) {
        final fall = _current.fall(step: i + 1);
        if (!fall.isValidInMatrix(data)) {
          _current = _current.fall(step: i);
          states = GameStates.quicken;
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 100));
          _mixCurrentIntoData(mixSound: sound.fall);
          break;
        }
      }
      setState(() {});
    } else if (states == GameStates.paused || states == GameStates.none) {
      _startGame();
    }
  }

  @override
  onResetTap() {
    if (states == GameStates.none) {
      //可以开始游戏
      _startGame();
      return;
    }
    if (states == GameStates.reset) {
      return;
    }
    sound.start();
    states = GameStates.reset;
    // 重置动画
    () async {
      int line = GAME_PAD_MATRIX_H;
      // 从上至下逐行显示
      await Future.doWhile(() async {
        line--;
        for (int i = 0; i < GAME_PAD_MATRIX_W; i++) {
          data[line][i] = 1;
        }
        setState(() {});
        await Future.delayed(REST_LINE_DURATION);
        return line != 0;
      });
      // 清空数据
      _current = null;
      _getNext();
      points = 0;
      cleared = 0;
      // 然后逐行清空
      await Future.doWhile(() async {
        for (int i = 0; i < GAME_PAD_MATRIX_W; i++) {
          data[line][i] = 0;
        }
        setState(() {});
        line++;
        await Future.delayed(REST_LINE_DURATION);
        return line != GAME_PAD_MATRIX_H;
      });
      // 动画结束后重置状态
      setState(() {
        states = GameStates.none;
      });
    }();
  }

  @override
  List<List<int>> build() {
    List<List<int>> mixed = [];
    // 动态计算混合后的显示
    for (var i = 0; i < GAME_PAD_MATRIX_H; i++) {
      mixed.add(List.filled(GAME_PAD_MATRIX_W, 0));
      for (var j = 0; j < GAME_PAD_MATRIX_W; j++) {
        int value = _current?.get(j, i) ?? data[i][j];
        if (mask[i][j] == -1) {
          value = 0;
        } else if (mask[i][j] == 1) {
          value = 2;
        }
        mixed[i][j] = value;
      }
    }
    return mixed;
  }

  @override
  dispose() {
    _autoFallTimer?.cancel();
    _autoFallTimer = null;
  }

  void _startGame() {
    if (states == GameStates.running && _autoFallTimer?.isActive == false) {
      return;
    }
    states = GameStates.running;
    _autoFall(true);
    setState(() {});
  }

  /// 自由下落
  void _autoFall(bool enable) {
    if (!enable && _autoFallTimer != null) {
      _autoFallTimer.cancel();
      _autoFallTimer = null;
    } else if (enable) {
      _autoFallTimer?.cancel();
      // 若当前没有Block，则获取
      _current = _current ?? _getNext();
      // 定时自由下落
      _autoFallTimer = Timer.periodic(SPEED_LIST[level - 1], (t) {
        _down(enableSounds: false);
      });
    }
  }

  /// 下落
  void _down({bool enableSounds = true}) {
    if (states == GameStates.running && _current != null) {
      final next = _current.fall();
      if (next.isValidInMatrix(data)) {
        _current = next;
        if (enableSounds) {
          sound.move();
        }
      } else {
        _mixCurrentIntoData();
      }
    }
    setState(() {});
  }

  /// 块下落到底。与已有的数据混合
  Future<void> _mixCurrentIntoData({void mixSound()}) async{
    if (_current == null) {
      return;
    }
    // 取消当前下落
    _autoFall(false);
    // 遍历表格。融合数据
    _forTable((i, j) => data[i][j] = _current.get(j, i) ?? data[i][j]);
    //消除行
    final clearLines = [];
    for (int i = 0; i < GAME_PAD_MATRIX_H; i++) {
      if (data[i].every((d) => d == 1)) {
        clearLines.add(i);
      }
    }

    if (clearLines.isNotEmpty) {
      setState(() => states = GameStates.clear);

      sound.clear();

      // 消除效果动画。闪烁5次
      for (int count = 0; count < 5; count++) {
        clearLines.forEach((line) {
          mask[line].fillRange(0, GAME_PAD_MATRIX_W, count % 2 == 0 ? -1 : 1);
        });
        setState(() {});
        await Future.delayed(Duration(milliseconds: 100));
      }
      // 消除动画结束。 按行清空_mask
      clearLines
          .forEach((line) => mask[line].fillRange(0, GAME_PAD_MATRIX_W, 0));

      // 移除所有被消除的行
      clearLines.forEach((line) {
        data.setRange(1, line + 1, data);
        data[0] = List.filled(GAME_PAD_MATRIX_W, 0);
      });
      debugPrint("clear lines : $clearLines");
      // 计算分数
      cleared += clearLines.length;
      points += clearLines.length * level * 5;

      // 按分数分级
      int levelB = (cleared ~/ 50) + LEVEL_MIN;
      level = levelB <= LEVEL_MAX && levelB > level ? levelB : level;
    } else {
      states = GameStates.mixing;
      if (mixSound != null) mixSound();
      // 遍历表格。按照Block定义_mask
      _forTable((i, j) => mask[i][j] = _current.get(j, i) ?? mask[i][j]);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 200));
      // 遍历表格。清空_mask
      _forTable((i, j) => mask[i][j] = 0);
      setState(() {});
    }

    //_current已经融入_data了，所以不再需要
    _current = null;

    //检查游戏是否结束,即检查第一行是否有元素为1
    if (data[0].contains(1)) {
      onResetTap();
      return;
    } else {
      //游戏尚未结束，开启下一轮方块下落
      _startGame();
    }
  }

  ///遍历表格
  ///i 为 row
  ///j 为 column
  void _forTable(dynamic function(int row, int column)) {
    for (int i = 0; i < GAME_PAD_MATRIX_H; i++) {
      for (int j = 0; j < GAME_PAD_MATRIX_W; j++) {
        final b = function(i, j);
        if (b is bool && b) {
          break;
        }
      }
    }
  }
}