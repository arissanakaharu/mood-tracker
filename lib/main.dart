import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_app/pages/add_edit_mood_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Tracker',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

// 1. MODEL (nanti dipindah ke models/mood_entry.dart)

enum Mood { bersemangat, tenang, senang, sedih, cemas, marah }

extension MoodX on Mood {
  String get label => switch (this) {
        Mood.bersemangat => 'Bersemangat',
        Mood.tenang => 'Tenang',
        Mood.senang => 'Senang',
        Mood.sedih => 'Sedih',
        Mood.cemas => 'Cemas',
        Mood.marah => 'Marah'
      };

  Color get color => switch (this) {
        Mood.bersemangat => const Color(0xFFF083B5),
        Mood.tenang => const Color(0xFF77CDC4),
        Mood.senang => const Color(0xFFF6C25B),
        Mood.sedih => const Color(0xFF6C9BEA),
        Mood.cemas => const Color(0xFFB59DEB),
        Mood.marah => const Color(0xFFEB7566)
      };
  String get asset => 'assets/images/moods/$name.png';    
}

class MoodEntry {
  final Mood mood;
  final DateTime time;
  final String note;
  const MoodEntry({required this.mood, required this.time, required this.note});

String get timeLabel =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

// 2. HOME PAGE

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
final yesterdayDate = now.subtract(const Duration(days: 1));

DateTime at(DateTime day, int h, int m) =>
    DateTime(day.year, day.month, day.day, h, m);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// TODO: ganti dengan data asli (state management / database)
final entries = [
  MoodEntry(mood: Mood.bersemangat, time: at(now, 14, 20), note: 'Dapat kabar baik dari klien'),
  MoodEntry(mood: Mood.tenang, time: at(now, 11, 0), note: 'Meditasi pagi terasa menenangkan'),
  MoodEntry(mood: Mood.senang, time: at(now, 8, 30), note: 'Pagi yang cerah dan menyenangkan'),
  MoodEntry(mood: Mood.sedih, time: at(yesterdayDate, 20, 15), note: 'Kangen rumah tiba-tiba'),
  MoodEntry(mood: Mood.cemas, time: at(yesterdayDate, 9, 0), note: 'Deadline bikin deg-degan'),
];

final today = entries.where((e) => sameDay(e.time, now)).toList();
final yesterday = entries.where((e) => sameDay(e.time, yesterdayDate)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_)=> const AddEditMoodPage()),
        ),
        backgroundColor: const Color(0xFF4B36B8),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const _Header(name: 'Hanun'),
            const SizedBox(height: 24),
            const _StreakChip(days: 5),
            const SizedBox(height: 28),
            const _SectionTitle('Hari Ini'),
            ...today.map((e) => _MoodCard(entry: e)),
            const SizedBox(height: 24),
            const _SectionTitle('Kemarin'),
            ...yesterday.map((e) => _MoodCard(entry: e)),
          ],
        ),
      ),
    );
  }
}

// 3. KOMPONEN (nanti dipindah ke widgets/)

///  profile
class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name 👋', 
              style: const TextStyle(fontSize: 24,fontWeight: FontWeight.w600,color: Color(0xFF1A1A2E),
              )
              ),  
              const SizedBox(height: 4),
              const Text('Bagaimana perasaanmu hari ini?',style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFE5DEF7),
          child: Text(name[0]), // TODO: style ungu
        ),
      ],
    );
  }
}

/// Pill "5 hari berturut-turut mencatat mood"
class _StreakChip extends StatelessWidget {
  final int days;
  const _StreakChip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE5DEF7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text('🔥 $days hari berturut-turut mencatat mood'),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text), // TODO: style semi-bold
      );
}

/// Satu kartu mood: [ikon] [judul + jam · catatan] [menu ⋮]
class _MoodCard extends StatelessWidget {
  final MoodEntry entry;
  const _MoodCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _MoodIcon(mood: entry.mood),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.mood.label),
                const SizedBox(height: 4),
                Text(
                  '${entry.time.hour} · ${entry.note}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditMoodPage(entry: entry)),
            ),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

/// Kotak berwarna pake wajah. Sementara placeholder (tanpa asset).
class _MoodIcon extends StatelessWidget {
  final Mood mood;
  const _MoodIcon({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Image.asset(mood.asset, width: 70, height: 70);
  }
}