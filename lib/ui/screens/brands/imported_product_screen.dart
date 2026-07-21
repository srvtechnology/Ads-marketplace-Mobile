import 'dart:convert';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ImportedProductScreen extends StatefulWidget {
  final String productData;

  const ImportedProductScreen({super.key, required this.productData});

  @override
  State<ImportedProductScreen> createState() => _ImportedProductScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => ImportedProductScreen(
        productData: arguments['productData'] as String,
      ),
    );
  }
}

class _ImportedProductScreenState extends State<ImportedProductScreen> {
  Map<String, dynamic> product = {};

  @override
  void initState() {
    super.initState();
    try {
      String data = widget.productData;
      // webview runJavaScriptReturningResult returns a JSON string, which might be double stringified
      if (data.startsWith('"') && data.endsWith('"')) {
        data = data.substring(1, data.length - 1).replaceAll('\\"', '"');
      }
      product = jsonDecode(data);
    } catch (e) {
      print("Error decoding product data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: "Imported Product"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product['image'] != null && product['image'].isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product['image'],
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 100, color: context.color.textLightColor),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              (product['title'] != null && product['title'].toString().isNotEmpty) ? product['title'] : 'Unknown Title',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: context.color.textDefaultColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Price: ${product['price'] != null && product['price'].isNotEmpty ? '₹${product['price']}' : 'N/A'}",
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: context.color.territoryColor,
              ),
            ),
            const SizedBox(height: 12),
            if (product['variants'] != null && product['variants'].toString().isNotEmpty)
              Text(
                "Selected Variants: ${product['variants']}",
                style: TextStyle(
                  fontSize: 16,
                  color: context.color.textDefaultColor,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              "Brand: ${product['brand'] ?? 'Unknown'}",
              style: TextStyle(
                fontSize: 16,
                color: context.color.textDefaultColor,
              ),
            ),
            if (product['url'] != null && product['url'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Source URL: ${product['url']}",
                style: TextStyle(
                  fontSize: 14,
                  color: context.color.textLightColor,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.territoryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Finalize import to backend
                  Navigator.pop(context);
                },
                child: Text(
                  "Confirm & Add to Inventory",
                  style: TextStyle(
                    color: context.color.buttonColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
