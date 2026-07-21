import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:eClassify/app/routes.dart';

class BrandWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const BrandWebViewScreen({super.key, required this.title, required this.url});

  @override
  State<BrandWebViewScreen> createState() => _BrandWebViewScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => BrandWebViewScreen(
        title: arguments['title'] as String,
        url: arguments['url'] as String,
      ),
    );
  }
}

class _BrandWebViewScreenState extends State<BrandWebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool isProductPage = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
             _checkIfProductPage(url);
          },
          onPageFinished: (String url) {
             _checkIfProductPage(url);
            setState(() {
              isLoading = false;
            });
          },
          onUrlChange: (UrlChange change) {
             if (change.url != null) {
               _checkIfProductPage(change.url!);
             }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _checkIfProductPage(String url) {
    // Basic check for product pages across platforms
    bool isAmazonProduct = url.contains('/dp/') || url.contains('/gp/product/');
    bool isFlipkartProduct = url.contains('flipkart.com') && url.contains('/p/');
    // Myntra product URLs usually contain a 5+ digit ID or end with /buy
    bool isMyntraProduct = url.contains('myntra.com') && (url.contains('/buy') || RegExp(r'/[0-9]{5,}').hasMatch(url));
    
    bool isProduct = isAmazonProduct || isFlipkartProduct || isMyntraProduct;
    
    if (isProduct != isProductPage) {
      setState(() {
        isProductPage = isProduct;
      });
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Ready to confirm order?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.color.textLightColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Please confirm the details of the product, size, color and specification! You will not be able to change after this step.",
                  style: TextStyle(
                    fontSize: 16,
                    color: context.color.textDefaultColor.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.color.territoryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _scrapeProductDetails(context);
                        },
                        child: const Text(
                          "Ok",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.color.forthColor, // Red/Orange
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text(
                          "Go Back & Select",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scrapeProductDetails(BuildContext context) async {
    // Show a loading indicator while scraping
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Extracting details...', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );

    final String? currentUrl = await _controller.currentUrl();
    if (currentUrl == null) {
      Navigator.of(context).pop();
      return;
    }

    String jsScript = '';

    if (currentUrl.contains('amazon.in') || currentUrl.contains('amazon.com')) {
      jsScript = '''
        (function() {
          var product = {};
          var titleEl = document.querySelector('#productTitle') || document.querySelector('#title') || document.querySelector('h1.a-size-large');
          var title = titleEl ? titleEl.innerText.trim() : document.title;
          title = title.replace(/^Amazon\\.in(:|\\s*Buy\\s*)/i, '').replace(/ - Buy online.*/i, '').trim();
          product.title = title;
          
          // 3. PRICE
          // Advanced Price Extraction: Try to find the price inside the selected variant box first
          var price = '';
          var selectedBox = document.querySelector('.twister-mobile-tiles-selected, .swatchSelect.selected, .a-button-selected');
          if (selectedBox) {
              var boxPriceMatch = selectedBox.innerText.match(/₹\\s*([0-9,]+)/);
              if (boxPriceMatch) price = boxPriceMatch[1];
          }
          
          if (!price) {
              var priceEl = document.querySelector('#corePrice_mobile_feature_div .a-price-whole') 
                         || document.querySelector('.priceToPay .a-price-whole') 
                         || document.querySelector('.apexPriceToPay .a-price-whole')
                         || document.querySelector('#corePriceDisplay_desktop_feature_div .a-price-whole');
                         
              if (priceEl) {
                  price = priceEl.innerText;
              } else {
                  var bigPrice = document.querySelector('.a-size-large.a-color-price');
                  if (bigPrice) price = bigPrice.innerText;
              }
          }
          product.price = price ? price.replace(/[^0-9]/g, '') : '';
          
          var imgEl = document.querySelector('#landingImage') || document.querySelector('#imgBlkFront') || document.querySelector('#main-image') || document.querySelector('.a-dynamic-image');
          product.image = imgEl ? imgEl.src : '';
          
          var variants = [];
          
          // 1. Try to find texts like "Model: NEW-R1S" or "Color: Black"
          var labels = document.querySelectorAll('span, div, p');
          labels.forEach(function(el) {
              // only look at leaf nodes or nodes with little text
              if(el.children.length <= 2 && el.innerText.length < 50) {
                  var text = el.innerText.trim().replace(/\\n/g, ' ');
                  var match = text.match(/^(Model|Color|Size|Style|Pattern|Capacity)\\s*:\\s*(.+)\$/i);
                  if (match) {
                      var val = match[2].trim();
                      if(val && variants.indexOf(val) === -1) variants.push(val);
                  }
              }
          });
          
          // 2. Fallback to common classes
          if(variants.length === 0) {
              document.querySelectorAll('.selection, .twister-mobile-selection-text').forEach(function(node) {
                var t = node.innerText.trim();
                if(t && !t.includes('₹') && variants.indexOf(t) === -1 && t.length < 30) {
                    variants.push(t);
                }
              });
          }
          
          product.variants = variants.join(', ');
          
          product.url = window.location.href;
          product.brand = 'Amazon';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('flipkart.com')) {
      jsScript = '''
        (function() {
          var product = {};
          var titleEl = document.querySelector('.B_NuCI') || document.querySelector('.VU-Tz5') || document.querySelector('span.VU-Tz5');
          product.title = titleEl ? titleEl.innerText.trim() : '';
          
          var priceEl = document.querySelector('._30jeq3') || document.querySelector('.Nx9bqj');
          product.price = priceEl ? priceEl.innerText.replace(/[^0-9]/g, '') : '';
          
          var imgEl = document.querySelector('._396cs4') || document.querySelector('._2r_T1I') || document.querySelector('img.DByuf4');
          product.image = imgEl ? imgEl.src : '';
          
          product.variants = '';
          product.url = window.location.href;
          product.brand = 'Flipkart';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('myntra.com')) {
      jsScript = '''
        (function() {
          var product = {};
          var titleEl = document.querySelector('.pdp-title') || document.querySelector('.pdp-name');
          var nameEl = document.querySelector('.pdp-name');
          product.title = (titleEl ? titleEl.innerText.trim() : '') + ' ' + (nameEl ? nameEl.innerText.trim() : '');
          
          var priceEl = document.querySelector('.pdp-price');
          product.price = priceEl ? priceEl.innerText.replace(/[^0-9]/g, '') : '';
          
          var imgEl = document.querySelector('.image-grid-image') || document.querySelector('.pdp-image-grid-image');
          product.image = imgEl && imgEl.style.backgroundImage ? imgEl.style.backgroundImage.slice(4, -1).replace(/"/g, "") : (imgEl ? imgEl.src : '');
          
          var variants = [];
          var sizeEl = document.querySelector('.size-buttons-size-selected');
          if(sizeEl) variants.push(sizeEl.innerText.trim());
          product.variants = variants.join(', ');
          
          product.url = window.location.href;
          product.brand = 'Myntra';
          
          return JSON.stringify(product);
        })();
      ''';
    }

    if (jsScript.isNotEmpty) {
      try {
        final Object result = await _controller.runJavaScriptReturningResult(jsScript);
        Navigator.of(context).pop(); // dismiss loading

        // Navigate to new screen with the result
        Navigator.pushNamed(context, Routes.importedProductScreen, arguments: {
          'productData': result.toString(),
        });
      } catch (e) {
        Navigator.of(context).pop(); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to scrape product details.')));
      }
    } else {
      Navigator.of(context).pop(); // dismiss loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: widget.title),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Center(
              child: UiUtils.progress(
                  normalProgressColor: context.color.territoryColor),
            ),
        ],
      ),
      bottomNavigationBar: isProductPage
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.color.territoryColor, // Global theme color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: context.color.buttonColor), // Theme icon color
                    const SizedBox(width: 8),
                    Text(
                      "Import to Bhutan",
                      style: TextStyle(
                        color: context.color.buttonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
