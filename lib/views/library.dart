import 'package:flutter/material.dart';

class PremiumAdPage extends StatefulWidget {
  @override
  _PremiumAdPageState createState() => _PremiumAdPageState();
}

class _PremiumAdPageState extends State<PremiumAdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 53, 0, 62),
        title: Text("MusicHub Premium", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Premium Promo Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Get Premium Free for 1 Month!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enjoy ad-free music, offline playback, and unlimited skips. Upgrade to Spotify Premium for the ultimate experience.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      // Handle premium subscription process here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Get Premium",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),

            // Feature Highlights
            Column(
              children: [
                _buildFeatureTile(Icons.music_off, "Ad-free music", "No more interruptions between your favorite songs."),
                
                _buildFeatureTile(Icons.skip_next, "Unlimited skips", "Skip any song, anytime."),
                _buildFeatureTile(Icons.high_quality, "High-quality audio", "Experience music like never before."),
              ],
            ),
            // Image Banner
            Padding(
              padding: const EdgeInsets.all(0.20),
              child: Image.asset(
                "assets/download.gif", // Example Spotify Premium Ad Banner
                fit: BoxFit.cover,
              ),
              
            ),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String description) {
    return ListTile(
      leading: Icon(icon, color: Colors.green, size: 32),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(description, style: TextStyle(color: Colors.white70, fontSize: 14)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
