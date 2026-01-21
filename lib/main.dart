import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'data/models/category.dart';
import 'data/models/transaction.dart';
import 'data/providers/finance_provider.dart';
import 'data/repositories/finance_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/services/hive_service.dart';
import 'features/home/home_shell.dart';
import 'theme/walletlly_palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await HiveService.init();

  final categoryRepository = CategoryRepository(
    Hive.box<Category>(HiveService.categoriesBox),
  );
  final transactionRepository = TransactionRepository(
    Hive.box<TransactionEntry>(HiveService.transactionsBox),
  );
  final financeRepository = FinanceRepository(
    categoryRepository,
    transactionRepository,
  );

  runApp(FinanceTrackerApp(financeRepository: financeRepository));
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key, required this.financeRepository});

  final FinanceRepository financeRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: financeRepository),
        ChangeNotifierProvider(
          create: (_) => FinanceProvider(financeRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Finance Tracker',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeShell(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const palette = WalletllyPalette(
      primaryDark: Color(0xFF1E3A8A),
      primaryBase: Color(0xFF2563EB),
      primaryLight: Color(0xFFE2EAFF),
      accent: Color(0xFF14B8A6),
      accentSoft: Color(0xFFD5F5EF),
      success: Color(0xFF16A34A),
      successContainer: Color(0xFFD1FAE5),
      error: Color(0xFFDC2626),
      errorSoft: Color(0xFFFEE2E2),
    );

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: palette.primaryBase,
      onPrimary: Colors.white,
      primaryContainer: palette.primaryLight,
      onPrimaryContainer: palette.primaryDark,
      secondary: const Color(0xFF4B5563),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE5E7EB),
      onSecondaryContainer: const Color(0xFF111827),
      tertiary: palette.accent,
      onTertiary: Colors.white,
      tertiaryContainer: palette.accentSoft,
      onTertiaryContainer: palette.accent,
      error: palette.error,
      onError: Colors.white,
      errorContainer: palette.errorSoft,
      onErrorContainer: const Color(0xFF7F1D1D),
      background: const Color(0xFFF5F7FB),
      onBackground: const Color(0xFF1F2937),
      surface: Colors.white,
      onSurface: const Color(0xFF1F2937),
      surfaceVariant: const Color(0xFFE5E7EB),
      onSurfaceVariant: const Color(0xFF4B5563),
      outline: const Color(0xFFD1D5DB),
      outlineVariant: const Color(0xFFE2E8F0),
      shadow: const Color(0x33000000),
      scrim: const Color(0x66000000),
      inverseSurface: const Color(0xFF1F2937),
      onInverseSurface: Colors.white,
      inversePrimary: palette.primaryDark,
      surfaceTint: palette.primaryBase,
    );

    final textTheme = GoogleFonts.spaceGroteskTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onBackground,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6B7280),
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        selectedColor: palette.primaryLight,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
      extensions: const [palette],
    );
  }
}
