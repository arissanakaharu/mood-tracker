import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// 1. MODEL (nanti dipindah ke models/mood_entry.dart)
// ─────────────────────────────────────────────
enum Mood { bersemangat, tenang, senang, sedih, cemas }

extension MoodX on Mood {
  String get label => switch (this) {
        Mood.bersemangat => 'Bersemangat',
        Mood.tenang => 'Tenang',
        Mood.senang => 'Senang',
        Mood.sedih => 'Sedih',
        Mood.cemas => 'Cemas',
      };

  Color get color => switch (this) {
        Mood.bersemangat => const Color(0xFFF083B5),
        Mood.tenang => const Color(0xFF77CDC4),
        Mood.senang => const Color(0xFFF6C25B),
        Mood.sedih => const Color(0xFF6C9BEA),
        Mood.cemas => const Color(0xFFB59DEB),
      };
}

class MoodEntry {
  final Mood mood;
  final DateTime time;
  final String note;
  const MoodEntry({required this.mood, required this.time, required this.note});
}

// ─────────────────────────────────────────────
// 2. HOME PAGE
// ─────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ganti dengan data asli (state management / database)
    final today = <MoodEntry>[];
    final yesterday = <MoodEntry>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: navigasi ke halaman tambah mood
        backgroundColor: const Color(0xFF4B36B8),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const _Header(name: 'Zika'),
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

// ─────────────────────────────────────────────
// 3. KOMPONEN (nanti dipindah ke widgets/)
// ─────────────────────────────────────────────

/// Sapaan + avatar inisial di kanan
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
              Text('Halo, $name 👋'), // TODO: style bold
              const SizedBox(height: 4),
              const Text('Bagaimana perasaanmu hari ini?'), // TODO: style abu-abu
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
                  '${entry.time.hour}:${entry.time.minute} · ${entry.note}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, // TODO: edit / hapus
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

/// Kotak berwarna dengan wajah. Sementara placeholder (tanpa asset).
class _MoodIcon extends StatelessWidget {
  final Mood mood;
  const _MoodIcon({required this.mood});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: mood.color,
        borderRadius: BorderRadius.circular(22),
      ),
      // TODO: ganti dengan SvgPicture / Image.asset wajah per mood
      child: const Icon(Icons.emoji_emotions_outlined, color: Colors.white),
    );
  }
}