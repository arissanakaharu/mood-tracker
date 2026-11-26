import 'package:material_ui/material_ui.dart';
import 'package:mood_tracker_app/main.dart';

/// Halaman Tambah / Edit Mood.
class AddEditMoodPage extends StatefulWidget {
  /// null = tambah mood baru, berisi = edit mood yang sudah ada
  final MoodEntry? entry;
  const AddEditMoodPage({super.key, this.entry});

  @override
  State<AddEditMoodPage> createState() => _AddEditMoodPageState();
}

class _AddEditMoodPageState extends State<AddEditMoodPage> {
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  // Urutan sesuai Figma (3 kolom x 2 baris)
  static const _moodOrder = [
    Mood.senang, Mood.sedih, Mood.marah,
    Mood.tenang, Mood.cemas, Mood.bersemangat,
  ];

  late DateTime _date;
  Mood? _selectedMood;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _date = e?.time ?? DateTime.now();
    _selectedMood = e?.mood;
    _noteController.text = e?.note ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _dateLabel {
    final now = DateTime.now();
    final isToday =
        _date.year == now.year && _date.month == now.month && _date.day == now.day;
    final text = '${_date.day} ${_months[_date.month - 1]} ${_date.year}';
    return isToday ? 'Hari ini, $text' : text;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final old = widget.entry;
  final now = DateTime.now();
  final base = old?.time ?? now;
  final time = DateTime(_date.year, _date.month, _date.day, base.hour, base.minute);

  Navigator.pop(
    context,
    MoodEntry(
      id: old?.id ?? now.microsecondsSinceEpoch.toString(),
      mood: _selectedMood!,
      time: time,
      note: _noteController.text.trim(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: isEdit ? 'Edit Mood' : 'Tambah Mood'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  const _FieldLabel('Tanggal'),
                  _DateField(label: _dateLabel, onTap: _pickDate),
                  const SizedBox(height: 24),
                  const _FieldLabel('Bagaimana perasaanmu?'),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: _moodOrder
                        .map((m) => _MoodOption(
                              mood: m,
                              selected: m == _selectedMood,
                              onTap: () => setState(() => _selectedMood = m),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const _FieldLabel('Catatan (opsional)'),
                  TextField(
                    controller: _noteController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Tulis catatanmu...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  // nonaktif sampai mood dipilih
                  onPressed: _selectedMood == null ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B36B8),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Simpan Mood'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Komponen kecil khusus halaman ini

class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(title, style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)
              )),
            ),
          ),
          const SizedBox(width: 48), // biar judul tepat di tengah
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF6B7280),
        )),
      );
}

class _DateField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

class _MoodOption extends StatelessWidget {
  final Mood mood;
  final bool selected;
  final VoidCallback onTap;
  const _MoodOption({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? mood.color : Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(mood.asset, width: 44, height: 44),
            const SizedBox(height: 6),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}