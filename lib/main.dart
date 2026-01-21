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
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.spaceGroteskTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: baseScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      textTheme: textTheme.copyWith(
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF1F2937),
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF4B5563),
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6B7280),
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: const Color(0xFF1F2937),
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: const Color(0xFF1F2937),
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          color: const Color(0xFF1F2937),
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: const Color(0xFF1F2937),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1F2937),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Color(0xFF1F2937),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: baseScheme.primary, width: 1.6),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: baseScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: const Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE5E7EB),
        selectedColor: baseScheme.primary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(color: Color(0xFF1F2937)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: baseScheme.primary,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
