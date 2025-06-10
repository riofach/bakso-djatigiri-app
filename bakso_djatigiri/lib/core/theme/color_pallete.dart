// Color palette utama aplikasi Bakso Djatigiri
import 'package:flutter/material.dart';

// Primary color shades (500 - 950)
const primary100 = Color(0xFFFCE1E4);
const primary200 = Color(0xFFFAC2C9);
const primary300 = Color(0xFFF7A4AE);
const primary400 = Color(0xFFF5859A);
const primary500 = Color(0xFFF4909B);
const primary600 = Color(0xFFF27887);
const primary700 = Color(0xFFF06676);
const primary800 = Color(0xFFEE5365);
const primary900 = Color(0xFFEC3C50);
const primary950 = Color(0xFFEB3349);

// Secondary color shades (500 - 950)
const secondary500 = Color(0xFFF9A79A);
const secondary600 = Color(0xFFF89687);
const secondary700 = Color(0xFFF78573);
const secondary800 = Color(0xFFF67460);
const secondary900 = Color(0xFFF5634D);
const secondary950 = Color(0xFFF45C43);

// Gradient styles
const _gradientColors = [primary950, secondary950];

// Vertical 01: primary atas, secondary bawah
LinearGradient get vertical01 => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _gradientColors,
    );

// Vertical 02: secondary atas, primary bawah
LinearGradient get vertical02 => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [secondary950, primary950],
    );

// Horizontal 01: primary kiri, secondary kanan
LinearGradient get horizontal01 => const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: _gradientColors,
    );

// Horizontal 02: secondary kiri, primary kanan
LinearGradient get horizontal02 => const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [secondary950, primary950],
    );

// Diagonal 01: primary kiri atas, secondary kanan bawah
LinearGradient get diagonal01 => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _gradientColors,
    );

// Diagonal 02: secondary kiri atas, primary kanan bawah
LinearGradient get diagonal02 => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [secondary950, primary950],
    );

// Dark Color Shades
const dark800 = Color(0xFF552211);
const dark900 = Color(0xFF2F1309);
const dark950 = Color(0xFF190A05);

// White Color Shades
const white900 = Color(0xFFFFFFFF);
const white950 = Color(0xFFFAFAFA);

// Gray Color Shades
const gray100 = Color(0xFFF5F5F8);
const gray200 = Color(0xFFEBEBF0);
const gray300 = Color(0xFFE0E0E8);
const gray400 = Color(0xFFD8D8E0);
const gray500 = Color(0xFFCFCFD8);
const gray600 = Color(0xFFD5D5DD);
const gray700 = Color(0xFFC7C7D1);
const gray800 = Color(0xFFB4B4C1);
const gray900 = Color(0xFF9B9BAC);
const gray950 = Color(0xFF7A7A90);

// Status Colors
const successColor = Color(0xFF4CAF50);
const warningColor = Color(0xFFFFC107);
const infoColor = Color(0xFF2196F3);

// Alias untuk kemudahan penggunaan di seluruh project
const backgroundColor = white950;
const errorColor = primary900;

// =========================
// Contoh Penggunaan:
//
// import '../../../../core/theme/color_pallete.dart';
//
// Container(
//   color: primary500,
//   child: Text('Hello', style: TextStyle(color: white900)),
// )
//
// BoxDecoration(
//   gradient: vertical01,
// )
// =========================
