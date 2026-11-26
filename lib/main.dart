import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mood_tracker_app/pages/add_edit_mood_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('moods');
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
  final String id;
  final Mood mood;
  final DateTime time;
  final String note;
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.time,
    required this.note,
  });

  String get timeLabel =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'id': id,
        'mood': mood.name,
        'time': time.toIso8601String(),
        'note': note,
      };

  factory MoodEntry.fromMap(Map map) => MoodEntry(
        id: map['id'] as String,
        mood: Mood.values.byName(map['mood'] as String),
        time: DateTime.parse(map['time'] as String),
        note: map['note'] as String,
      );
}

// 2. HOME PAGE

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  final _box = Hive.box('moods');
  late List<MoodEntry> _entries;

  @override
  void initState() {
    super.initState();
    // READ: muat data yang tersimpan di Hive
    _entries = _box.values.map((v) => MoodEntry.fromMap(v as Map)).toList();
  }

  // ── CREATE ──
  Future<void> _addEntry() async {
    final result = await Navigator.push<MoodEntry>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditMoodPage()),
    );
    if (!mounted || result == null) return;
    setState(() => _entries.add(result));
    _box.put(result.id, result.toMap());
  }

  // ── UPDATE ──
  Future<void> _editEntry(MoodEntry entry) async {
    final result = await Navigator.push<MoodEntry>(
      context,
      MaterialPageRoute(builder: (_) => AddEditMoodPage(entry: entry)),
    );
    if (!mounted || result == null) return;
    setState(() {
      final i = _entries.indexWhere((e) => e.id == result.id);
      if (i != -1) _entries[i] = result;
    });
    _box.put(result.id, result.toMap()); // id sama = menimpa data lama
  }

  // ── DELETE ──
  Future<void> _deleteEntry(MoodEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus mood?'),
        content: const Text('Catatan mood ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
    _box.delete(entry.id);
  }

  // ── READ: kelompokkan per hari, terbaru di atas ──
  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  Map<String, List<MoodEntry>> _grouped() {
    final sorted = [..._entries]..sort((a, b) => b.time.compareTo(a.time));
    final map = <String, List<MoodEntry>>{};
    for (final e in sorted) {
      map.putIfAbsent(_dayLabel(e.time), () => []).add(e);
    }
    return map;
  }

  // jumlah hari berturut-turut yang ada catatannya
  int _streak() {
    final days = _entries
        .map((e) => DateTime(e.time.year, e.time.month, e.time.day))
        .toSet();
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped();
    final streak = _streak();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
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
            if (streak > 0) _StreakChip(days: streak),
            const SizedBox(height: 28),
            if (groups.isEmpty) const _EmptyState(),
            for (final group in groups.entries) ...[
              _SectionTitle(group.key),
              for (final e in group.value)
                _MoodCard(
                  entry: e,
                  onEdit: () => _editEntry(e),
                  onDelete: () => _deleteEntry(e),
                ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: Text('Belum ada mood. Ketuk + untuk mencatat.')),
      );
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
  final VoidCallback onEdit;
final VoidCallback onDelete;
const _MoodCard({
  required this.entry,
  required this.onEdit,
  required this.onDelete,
  });
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
                  '${entry.timeLabel} · ${entry.note}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
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