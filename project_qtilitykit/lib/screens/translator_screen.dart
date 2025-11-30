import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_qtilitykit/services/phrasebook_service.dart';
import '../services/translation_service.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  /// Updated languages list (removed German)
  final List<String> _languages = [
    'English',
    'Filipino',
    'Spanish',
    'French',
    'Japanese',
    'Korean',
    'Russian',
  ];

  String _sourceLang = 'English';
  String _targetLang = 'Filipino';
  bool _isTranslating = false;
  bool _isFavorite = false;

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final tmpLang = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = tmpLang;

      final tmpText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tmpText;
    });
  }

  Future<void> _translate() async {
    final input = _sourceController.text.trim();
    if (input.isEmpty) return;

    setState(() => _isTranslating = true);

    /// Actual translation begins here
    final sourceCode = TranslatorService.languageCodes[_sourceLang] ?? "en";
    final targetCode = TranslatorService.languageCodes[_targetLang] ?? "tl";

    final translated = await TranslatorService.translateText(
      input,
      sourceCode,
      targetCode,
    );

    setState(() {
      _targetController.text = translated;
      _isTranslating = false;
    });

    /// Friendly error message
    if (translated.contains("Unable to translate")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Translation failed. Please check your connection."),
        ),
      );
    }
  }

  void _clearSource() => _sourceController.clear();
  void _clearTarget() => _targetController.clear();

  Future<void> _copyTargetToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _targetController.text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  Future<void> _pasteToSource() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      _sourceController.text = data.text ?? "";
    }
  }

  void _toggleFavorite() async {
    if (_targetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No translation to save.")));
      return;
    }

    setState(() => _isFavorite = !_isFavorite);

    if (_isFavorite) {
      await PhrasebookService.addFavorite(
        source: _sourceController.text.trim(),
        translated: _targetController.text.trim(),
        sourceLang: TranslatorService.languageCodes[_sourceLang] ?? "",
        targetLang: TranslatorService.languageCodes[_targetLang] ?? "",
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saved to phrasebook")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed (toggle only)")));
    }
  }

  void _showLanguagePicker({required bool isSource}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          children: _languages
              .map(
                (lang) => ListTile(
                  title: Text(lang),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (isSource) {
                        _sourceLang = lang;
                      } else {
                        _targetLang = lang;
                      }
                    });
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildCard({
    required String language,
    required VoidCallback onLanguageTap,
    required TextEditingController controller,
    required String hint,
    required List<Widget> leadingActions,
    required List<Widget> trailingActions,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Language Picker Row
            InkWell(
              onTap: onLanguageTap,
              child: Row(
                children: [
                  Text(
                    language,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// Text Field
            TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 10),

            /// Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: leadingActions),
                Row(children: trailingActions),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Translator"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: "Phrasebook",
            onPressed: () {
              Navigator.pushNamed(context, '/phrasebook');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// SOURCE CARD
            _buildCard(
              language: _sourceLang,
              onLanguageTap: () => _showLanguagePicker(isSource: true),
              controller: _sourceController,
              hint: "Type or paste text",
              leadingActions: [
                IconButton(
                  onPressed: _pasteToSource,
                  icon: const Icon(Icons.paste),
                ),
                IconButton(
                  onPressed: _clearSource,
                  icon: const Icon(Icons.clear),
                ),
              ],
              trailingActions: [
                IconButton(
                  onPressed: _translate,
                  icon: _isTranslating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.translate),
                ),
              ],
            ),

            /// SWAP BUTTON
            IconButton(
              onPressed: _swapLanguages,
              icon: const Icon(Icons.swap_vert, size: 36),
            ),

            /// TARGET CARD
            _buildCard(
              language: _targetLang,
              onLanguageTap: () => _showLanguagePicker(isSource: false),
              controller: _targetController,
              hint: "Translation appears here",
              leadingActions: [
                IconButton(
                  onPressed: _copyTargetToClipboard,
                  icon: const Icon(Icons.copy),
                ),
              ],
              trailingActions: [
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
                ),
                IconButton(
                  onPressed: _clearTarget,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
            // Disclaimer
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                "⚠️ This translator uses a free public API.\n"
                "Some translations may be inaccurate.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
