// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Generates Word Mate app icons (golden opened book)
/// Run: dart run tool/generate_app_icon.dart
void main() async {
  print('🎨 Generating Word Mate app icons (opened book)...\n');

  // Create assets directory
  final assetsDir = Directory('assets');
  if (!await assetsDir.exists()) {
    await assetsDir.create();
  }

  // Generate main icon (1024x1024)
  print('Creating main app icon...');
  final mainIcon = generateOpenBookIcon(1024, withBackground: true);
  await File('assets/app_icon.png').writeAsBytes(img.encodePng(mainIcon));
  print('✓ assets/app_icon.png');

  // Generate foreground for adaptive icon
  print('Creating adaptive icon foreground...');
  final foreground = generateOpenBookIcon(1024, withBackground: false);
  await File('assets/app_icon_foreground.png').writeAsBytes(img.encodePng(foreground));
  print('✓ assets/app_icon_foreground.png');

  print('\n✅ Icons generated successfully!');
  print('\nNext step: Run this command to update app icons:');
  print('  dart run flutter_launcher_icons\n');
}

img.Image generateOpenBookIcon(int size, {required bool withBackground}) {
  final image = img.Image(width: size, height: size);
  
  final centerX = size / 2;
  final centerY = size / 2;

  // Fill background
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      if (withBackground) {
        // Dark gradient background
        final gradientFactor = y / size;
        final r = (22 + gradientFactor * 14).round();
        final g = (22 + gradientFactor * 14).round();
        final b = (26 + gradientFactor * 14).round();
        image.setPixelRgba(x, y, r, g, b, 255);
      } else {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  // Open book parameters
  final bookWidth = size * 0.7;
  final bookHeight = size * 0.5;
  final pageWidth = bookWidth * 0.48;
  final spineWidth = size * 0.04;
  
  // Book vertical position (slightly above center)
  final bookCenterY = centerY - size * 0.02;
  
  // Draw pages (left and right)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - centerX;
      final dy = y - bookCenterY;
      
      // Left page
      if (isInLeftPage(dx, dy, pageWidth, bookHeight, spineWidth, size)) {
        final colors = getPageColor(x, y, centerX - pageWidth/2 - spineWidth/2, bookCenterY, pageWidth, bookHeight, isLeft: true);
        image.setPixelRgba(x, y, colors[0], colors[1], colors[2], 255);
      }
      
      // Right page
      if (isInRightPage(dx, dy, pageWidth, bookHeight, spineWidth, size)) {
        final colors = getPageColor(x, y, centerX + pageWidth/2 + spineWidth/2, bookCenterY, pageWidth, bookHeight, isLeft: false);
        image.setPixelRgba(x, y, colors[0], colors[1], colors[2], 255);
      }
      
      // Spine (center binding)
      if (isInSpine(dx, dy, spineWidth, bookHeight)) {
        // Darker golden for spine
        final gradientPos = (dy + bookHeight/2) / bookHeight;
        final r = (180 + gradientPos * 40).round().clamp(0, 255);
        final g = (80 + gradientPos * 60).round().clamp(0, 255);
        final b = (40 + gradientPos * 20).round().clamp(0, 255);
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  // Draw text lines on pages
  drawTextLines(image, centerX, bookCenterY, pageWidth, bookHeight, spineWidth, size);
  
  // Add page curl effect and shadows
  addPageEffects(image, centerX, bookCenterY, pageWidth, bookHeight, spineWidth, size);

  return image;
}

bool isInLeftPage(double dx, double dy, double pageWidth, double bookHeight, double spineWidth, int size) {
  // Left page: from -pageWidth-spineWidth/2 to -spineWidth/2
  final leftEdge = -pageWidth - spineWidth/2;
  final rightEdge = -spineWidth/2;
  final topEdge = -bookHeight/2;
  final bottomEdge = bookHeight/2;
  
  // Basic rectangle check
  if (dx < leftEdge || dx > rightEdge) return false;
  if (dy < topEdge || dy > bottomEdge) return false;
  
  // Round corners
  final cornerRadius = size * 0.03;
  
  // Top-left corner
  if (dx < leftEdge + cornerRadius && dy < topEdge + cornerRadius) {
    final cornerDist = sqrt(pow(dx - (leftEdge + cornerRadius), 2) + pow(dy - (topEdge + cornerRadius), 2));
    if (cornerDist > cornerRadius) return false;
  }
  
  // Bottom-left corner
  if (dx < leftEdge + cornerRadius && dy > bottomEdge - cornerRadius) {
    final cornerDist = sqrt(pow(dx - (leftEdge + cornerRadius), 2) + pow(dy - (bottomEdge - cornerRadius), 2));
    if (cornerDist > cornerRadius) return false;
  }
  
  return true;
}

bool isInRightPage(double dx, double dy, double pageWidth, double bookHeight, double spineWidth, int size) {
  final leftEdge = spineWidth/2;
  final rightEdge = pageWidth + spineWidth/2;
  final topEdge = -bookHeight/2;
  final bottomEdge = bookHeight/2;
  
  if (dx < leftEdge || dx > rightEdge) return false;
  if (dy < topEdge || dy > bottomEdge) return false;
  
  final cornerRadius = size * 0.03;
  
  // Top-right corner
  if (dx > rightEdge - cornerRadius && dy < topEdge + cornerRadius) {
    final cornerDist = sqrt(pow(dx - (rightEdge - cornerRadius), 2) + pow(dy - (topEdge + cornerRadius), 2));
    if (cornerDist > cornerRadius) return false;
  }
  
  // Bottom-right corner
  if (dx > rightEdge - cornerRadius && dy > bottomEdge - cornerRadius) {
    final cornerDist = sqrt(pow(dx - (rightEdge - cornerRadius), 2) + pow(dy - (bottomEdge - cornerRadius), 2));
    if (cornerDist > cornerRadius) return false;
  }
  
  return true;
}

bool isInSpine(double dx, double dy, double spineWidth, double bookHeight) {
  return dx.abs() <= spineWidth/2 && dy.abs() <= bookHeight/2;
}

List<int> getPageColor(int x, int y, double pageCenterX, double pageCenterY, double pageWidth, double bookHeight, {required bool isLeft}) {
  // Golden gradient from top (coral) to bottom (gold)
  final relY = (y - (pageCenterY - bookHeight/2)) / bookHeight;
  
  // Base gradient: coral (#FF6B6B) to gold (#FFD93D)
  int r = 255;
  int g = (110 + relY * 107).round().clamp(0, 255);
  int b = (90 - relY * 30).round().clamp(0, 255);
  
  // Add slight variation based on x position for depth
  final relX = isLeft 
      ? (x - (pageCenterX - pageWidth/2)) / pageWidth
      : (x - pageCenterX + pageWidth/2) / pageWidth;
  
  // Lighter towards outer edge, darker towards spine
  final edgeFactor = isLeft ? (1 - relX) : relX;
  r = (r + edgeFactor * 10).round().clamp(0, 255);
  g = (g + edgeFactor * 15).round().clamp(0, 255);
  b = (b + edgeFactor * 10).round().clamp(0, 255);
  
  return [r, g, b];
}

void drawTextLines(img.Image image, double centerX, double bookCenterY, double pageWidth, double bookHeight, double spineWidth, int size) {
  final lineHeight = size * 0.004;
  final lineSpacing = bookHeight / 10;
  
  // Lines on left page
  for (int lineNum = 2; lineNum <= 7; lineNum++) {
    final lineY = (bookCenterY - bookHeight/2 + lineSpacing * lineNum).round();
    final lineStartX = (centerX - pageWidth - spineWidth/2 + pageWidth * 0.15).round();
    final lineEndX = (centerX - spineWidth/2 - pageWidth * 0.1).round();
    
    // Vary line lengths
    final actualEnd = lineEndX - (lineNum % 3) * (size * 0.05).round();
    
    for (int y = lineY; y < lineY + lineHeight; y++) {
      for (int x = lineStartX; x < actualEnd; x++) {
        if (x >= 0 && x < size && y >= 0 && y < size) {
          final pixel = image.getPixel(x, y);
          final r = (pixel.r * 0.75).round();
          final g = (pixel.g * 0.75).round();
          final b = (pixel.b * 0.75).round();
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
  }
  
  // Lines on right page
  for (int lineNum = 2; lineNum <= 7; lineNum++) {
    final lineY = (bookCenterY - bookHeight/2 + lineSpacing * lineNum).round();
    final lineStartX = (centerX + spineWidth/2 + pageWidth * 0.1).round();
    final lineEndX = (centerX + pageWidth + spineWidth/2 - pageWidth * 0.15).round();
    
    final actualEnd = lineEndX - ((lineNum + 1) % 3) * (size * 0.04).round();
    
    for (int y = lineY; y < lineY + lineHeight; y++) {
      for (int x = lineStartX; x < actualEnd; x++) {
        if (x >= 0 && x < size && y >= 0 && y < size) {
          final pixel = image.getPixel(x, y);
          final r = (pixel.r * 0.75).round();
          final g = (pixel.g * 0.75).round();
          final b = (pixel.b * 0.75).round();
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
  }
}

void addPageEffects(img.Image image, double centerX, double bookCenterY, double pageWidth, double bookHeight, double spineWidth, int size) {
  // Add shadow near spine on both pages
  final shadowWidth = size * 0.04;
  
  for (int y = (bookCenterY - bookHeight/2).round(); y < (bookCenterY + bookHeight/2).round(); y++) {
    // Left page shadow (near spine)
    for (int x = (centerX - spineWidth/2 - shadowWidth).round(); x < (centerX - spineWidth/2).round(); x++) {
      if (x >= 0 && x < size && y >= 0 && y < size) {
        final shadowFactor = (x - (centerX - spineWidth/2 - shadowWidth)) / shadowWidth;
        final pixel = image.getPixel(x, y);
        if (pixel.a > 0) {
          final darkening = 0.7 + shadowFactor * 0.3;
          final r = (pixel.r * darkening).round().clamp(0, 255);
          final g = (pixel.g * darkening).round().clamp(0, 255);
          final b = (pixel.b * darkening).round().clamp(0, 255);
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
    
    // Right page shadow (near spine)
    for (int x = (centerX + spineWidth/2).round(); x < (centerX + spineWidth/2 + shadowWidth).round(); x++) {
      if (x >= 0 && x < size && y >= 0 && y < size) {
        final shadowFactor = 1 - (x - (centerX + spineWidth/2)) / shadowWidth;
        final pixel = image.getPixel(x, y);
        if (pixel.a > 0) {
          final darkening = 0.7 + (1 - shadowFactor) * 0.3;
          final r = (pixel.r * darkening).round().clamp(0, 255);
          final g = (pixel.g * darkening).round().clamp(0, 255);
          final b = (pixel.b * darkening).round().clamp(0, 255);
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
  }
  
  // Add subtle highlight on outer edges
  final highlightWidth = size * 0.01;
  
  for (int y = (bookCenterY - bookHeight/2).round(); y < (bookCenterY + bookHeight/2).round(); y++) {
    // Left page outer edge highlight
    final leftEdge = (centerX - pageWidth - spineWidth/2).round();
    for (int x = leftEdge; x < leftEdge + highlightWidth.round(); x++) {
      if (x >= 0 && x < size && y >= 0 && y < size) {
        final pixel = image.getPixel(x, y);
        if (pixel.a > 0) {
          final r = min(255, pixel.r.toInt() + 20);
          final g = min(255, pixel.g.toInt() + 20);
          final b = min(255, pixel.b.toInt() + 15);
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
    
    // Right page outer edge highlight
    final rightEdge = (centerX + pageWidth + spineWidth/2).round();
    for (int x = (rightEdge - highlightWidth).round(); x < rightEdge; x++) {
      if (x >= 0 && x < size && y >= 0 && y < size) {
        final pixel = image.getPixel(x, y);
        if (pixel.a > 0) {
          final r = min(255, pixel.r.toInt() + 20);
          final g = min(255, pixel.g.toInt() + 20);
          final b = min(255, pixel.b.toInt() + 15);
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
  }
}

