import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  final String koFiUrl = "https://ko-fi.com/blue_slime";
  final String paypalUrl = "https://paypal.me/YOUR_PAYPAL"; // <-- Replace!
  final String gcashNumber = "09XX-XXX-XXXX"; // <-- Replace!

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open external link?"),
          content: const Text(
            "You're about to open an external link in your browser.\n\nContinue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the link.")),
        );
      }
    }
  }

  void _copyGCashNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: gcashNumber));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Copied: $gcashNumber")));
  }

  void _showGCashQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("GCash QR Code"),
          content: SizedBox(
            height: 220,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Text(
                    "GCash QR\n(Insert Image Here)",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support the Developer"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thank you for considering to support my project! 💙\n\n"
              "Your support helps keep development going and motivates me "
              "to continue improving QtilityKit.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Ko-fi Section
            _buildCard(
              icon: Icons.coffee,
              title: "Ko-fi",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Support me on Ko-fi 💙"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openLink(context, koFiUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("Open Ko-fi"),
                  ),
                ],
              ),
            ),

            // GCash Section
            _buildCard(
              icon: Icons.account_balance_wallet,
              title: "GCash",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GCash Number: $gcashNumber"),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _copyGCashNumber(context),
                        child: const Text("Copy Number"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _showGCashQR(context),
                        child: const Text("Show QR"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // PayPal Section
            _buildCard(
              icon: Icons.paypal,
              title: "PayPal",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Donate via PayPal"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openLink(context, paypalUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("Open PayPal"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
