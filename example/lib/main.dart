import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:color_extractor/color_extractor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ColorExtractor extractor = const ColorExtractor();
  final PageController _pageController = PageController();
  final List<String> assetImages = [
    'assets/sample1.jpeg',
    'assets/sample2.jpeg',
    'assets/sample3.jpeg',
    'assets/sample4.jpeg',
    'assets/sample5.jpeg',
    'assets/sample6.jpeg',
    'assets/sample7.jpeg',
    'assets/sample8.jpeg',
    'assets/sample9.jpeg',
    'assets/sample10.jpeg',
    'assets/sample11.jpeg',
    'assets/sample12.jpeg',
  ];

  List<Color> dominantColors = [];
  List<Color> networkColors = [];
  bool isLoading = false;
  int selectedIndex = 0;
  String networkImageUrl = '';

  void _goPrevious() {
    if (selectedIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goNext() {
    if (selectedIndex < assetImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> extractFromAsset(String path) async {
    setState(() => isLoading = true);
    final bytes = await rootBundle.load(path);
    final data = bytes.buffer.asUint8List();
    final colors = await extractor.extractColorsFromBytes(data);
    setState(() {
      dominantColors = colors;
      isLoading = false;
    });
  }

  Future<void> extractFromNetwork(BuildContext context) async {
    if (networkImageUrl.isEmpty) return;

    setState(() {
      isLoading = true;
      networkColors = [];
    });
    final colors = await extractor.extractColorsFromNetwork(networkImageUrl);
    setState(() {
      networkColors = colors;
      isLoading = false;
    });
  }

  Widget _buildColorSwatches({required List<Color> colors}) {
    return Row(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors
          .map(
            (color) => Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Extractor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 24,
          children: [
            //extract from asset bytes
            Column(
              spacing: 12,
              children: [
                SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, size: 32),
                        color: Colors.black45,
                        onPressed: _goPrevious,
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: assetImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              selectedIndex = index;
                              dominantColors = [];
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Image.asset(
                                assetImages[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.chevron_right, size: 32),
                        color: Colors.black45,
                        onPressed: _goNext,
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () => extractFromAsset(assetImages[selectedIndex]),
                  child: const Text('Extract from Image'),
                ),
                if (dominantColors.isNotEmpty) ...[
                  _buildColorSwatches(colors: dominantColors),
                ],
              ],
            ),

            //extract from network image url
            Column(
              spacing: 12,
              children: [
                TextField(
                  onChanged: (value) => networkImageUrl = value,
                  decoration: const InputDecoration(
                    hintText: 'Enter image url...',
                  ),
                ),
                if (networkImageUrl.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.network(networkImageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ],

                ElevatedButton(
                  onPressed: () => extractFromNetwork(context),
                  child: const Text('Extract from Network Image'),
                ),
                if (networkColors.isNotEmpty) ...[
                  _buildColorSwatches(colors: networkColors),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
