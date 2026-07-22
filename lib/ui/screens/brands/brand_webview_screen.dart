import 'dart:convert';
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
    
    bool isDecathlonProduct = url.contains('decathlon.in') && url.contains('/p/');
    bool isFirstcryProduct = url.contains('firstcry.com') && url.contains('product-detail');
    bool isIkeaProduct = url.contains('ikea.com') && url.contains('/p/');
    bool isSephoraProduct = url.contains('sephora.in') && url.contains('/product/');
    bool isUniqloProduct = url.contains('uniqlo.com') && url.contains('/products/');
    bool isZaraProduct = url.contains('zara.com') && (url.contains('-p0') || url.contains('.html'));
    
    bool isProduct = isAmazonProduct || isFlipkartProduct || isMyntraProduct || 
                     isDecathlonProduct || isFirstcryProduct || isIkeaProduct || 
                     isSephoraProduct || isUniqloProduct || isZaraProduct;
    
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
      if (mounted) Navigator.of(context).pop();
      return;
    }

    String jsScript = _getJsScript(currentUrl);

    if (jsScript.isNotEmpty) {
      try {
        final Object result = await _controller.runJavaScriptReturningResult(jsScript);
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          Navigator.pushNamed(context, Routes.importedProductScreen, arguments: {
            'productData': result.toString(),
          });
        }
      } catch (e) {
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to scrape product details.')));
      }
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _scrapeAndShowSizeColourDialog(BuildContext context) async {
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
      if (mounted) Navigator.of(context).pop();
      return;
    }

    String jsScript = _getJsScript(currentUrl);

    if (jsScript.isNotEmpty) {
      try {
        final Object result = await _controller.runJavaScriptReturningResult(jsScript);
        if (mounted) Navigator.of(context).pop();

        String data = result.toString();
        if (data.startsWith('"') && data.endsWith('"')) {
          data = data.substring(1, data.length - 1).replaceAll('\\"', '"');
        }
        Map<String, dynamic> product = {};
        try {
          product = jsonDecode(data);
        } catch (_) {}

        if (mounted) {
          if (currentUrl.contains('sephora.in')) {
            _showShadeSelectionDialog(context, product);
          } else {
            _showSizeColourSelectionDialog(context, product);
          }
        }
      } catch (e) {
        if (mounted) Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to scrape product details.')));
      }
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showShadeSelectionDialog(BuildContext context, Map<String, dynamic> product) {
    String detectedShade = '';

    String variantsStr = (product['variants'] ?? '').toString();
    if (variantsStr.isNotEmpty) {
      RegExp shadeRegex = RegExp(r'(?:Shade|Colour|Color):\s*([^,]+)', caseSensitive: false);
      var match = shadeRegex.firstMatch(variantsStr);
      if (match != null) {
        detectedShade = match.group(1)?.trim() ?? '';
      } else {
        detectedShade = variantsStr.trim();
      }
    }

    final TextEditingController shadeController = TextEditingController(text: detectedShade);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Select Shade",
                          style: TextStyle(
                            fontSize: 20,
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
                  const SizedBox(height: 12),
                  Text(
                    "Please specify or confirm your selected product shade:",
                    style: TextStyle(
                      fontSize: 14,
                      color: context.color.textDefaultColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Product Shade",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.color.textDefaultColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: shadeController,
                    style: TextStyle(color: context.color.textDefaultColor),
                    decoration: InputDecoration(
                      hintText: "Enter shade (e.g. 4.5WN, 01 Fair To Light)",
                      hintStyle: TextStyle(fontSize: 14, color: context.color.textLightColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.territoryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: context.color.textDefaultColor, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.color.territoryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            String sVal = shadeController.text.trim();
                            if (sVal.isNotEmpty) {
                              product['variants'] = "Shade: $sVal";
                            } else {
                              product['variants'] = '';
                            }

                            Navigator.of(dialogContext).pop();

                            Navigator.pushNamed(context, Routes.importedProductScreen, arguments: {
                              'productData': jsonEncode(product),
                            });
                          },
                          child: const Text(
                            "Confirm & Import",
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSizeColourSelectionDialog(BuildContext context, Map<String, dynamic> product) {
    String detectedSize = '';
    String detectedColour = '';

    String variantsStr = (product['variants'] ?? '').toString();
    if (variantsStr.isNotEmpty) {
      RegExp colorRegex = RegExp(r'(?:Colour|Color|Shade):\s*([^,]+)', caseSensitive: false);
      RegExp sizeRegex = RegExp(r'Size:\s*([^,]+)', caseSensitive: false);

      var colorMatch = colorRegex.firstMatch(variantsStr);
      var sizeMatch = sizeRegex.firstMatch(variantsStr);

      if (colorMatch != null) {
        detectedColour = colorMatch.group(1)?.trim() ?? '';
      }
      if (sizeMatch != null) {
        detectedSize = sizeMatch.group(1)?.trim() ?? '';
      }

      if (detectedSize.isEmpty && detectedColour.isEmpty) {
        List<String> parts = variantsStr.split(',').map((e) => e.trim()).toList();
        for (var part in parts) {
          if (RegExp(r'^([0-9]{1,3}|S|M|L|XL|XXL|XXXL|XS|Free Size)$', caseSensitive: false).hasMatch(part)) {
            detectedSize = part;
          } else if (part.isNotEmpty) {
            detectedColour = part;
          }
        }
      }

      if (detectedSize.isNotEmpty) {
        detectedSize = detectedSize.split('\n')[0].split('\r')[0];
        detectedSize = detectedSize.replaceAll(RegExp(r'\s*(?:Sizing|Size Chart|Get help|Find your size).*$', caseSensitive: false), '').trim();
        RegExp multiSizeRegex = RegExp(r'^(.+?\b(?:XXS|XS|S|M|L|XL|XXL|XXXL|[0-9]{1,2}))(?:\s+(?:XXS|XS|S|M|L|XL|XXL|XXXL|[0-9]{1,2}))+$', caseSensitive: false);
        var match = multiSizeRegex.firstMatch(detectedSize);
        if (match != null) {
          detectedSize = match.group(1)?.trim() ?? detectedSize;
        }
      }
    }

    final TextEditingController sizeController = TextEditingController(text: detectedSize);
    final TextEditingController colourController = TextEditingController(text: detectedColour);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Select Size & Colour",
                          style: TextStyle(
                            fontSize: 20,
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
                  const SizedBox(height: 12),
                  Text(
                    "Please specify or confirm your selected size and colour:",
                    style: TextStyle(
                      fontSize: 14,
                      color: context.color.textDefaultColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Select Size",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.color.textDefaultColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: sizeController,
                    style: TextStyle(color: context.color.textDefaultColor),
                    decoration: InputDecoration(
                      hintText: "Enter size (e.g. 30, 32, M, L)",
                      hintStyle: TextStyle(fontSize: 14, color: context.color.textLightColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.territoryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select Colour",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.color.textDefaultColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: colourController,
                    style: TextStyle(color: context.color.textDefaultColor),
                    decoration: InputDecoration(
                      hintText: "Enter colour (e.g. Blue, Black)",
                      hintStyle: TextStyle(fontSize: 14, color: context.color.textLightColor),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.color.territoryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: context.color.textLightColor.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: context.color.textDefaultColor, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.color.territoryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            List<String> finalVariants = [];
                            String cVal = colourController.text.trim();
                            String sVal = sizeController.text.trim();

                            if (cVal.isNotEmpty) {
                              finalVariants.add("Colour: $cVal");
                            }
                            if (sVal.isNotEmpty) {
                              finalVariants.add("Size: $sVal");
                            }

                            product['variants'] = finalVariants.join(', ');

                            if (sVal.isNotEmpty && product['sizePrices'] != null && product['sizePrices'] is Map) {
                              Map sizePrices = product['sizePrices'] as Map;
                              String key = sVal.toUpperCase();
                              if (sizePrices.containsKey(key) && sizePrices[key].toString().isNotEmpty) {
                                product['price'] = sizePrices[key].toString();
                              }
                            }

                            Navigator.of(dialogContext).pop();

                            Navigator.pushNamed(context, Routes.importedProductScreen, arguments: {
                              'productData': jsonEncode(product),
                            });
                          },
                          child: const Text(
                            "Confirm & Import",
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getJsScript(String currentUrl) {
    if (currentUrl.contains('amazon.in') || currentUrl.contains('amazon.com')) {
      return r'''
        (function() {
          var product = {};
          var titleEl = document.querySelector('#productTitle') || document.querySelector('#title') || document.querySelector('h1.a-size-large');
          var title = titleEl ? titleEl.innerText.trim() : document.title;
          title = title.replace(/^Amazon\.in(:|\s*Buy\s*)/i, '').replace(/ - Buy online.*/i, '').trim();
          product.title = title;
          
          var price = '';
          var selectedBox = document.querySelector('.twister-mobile-tiles-selected, .swatchSelect.selected, .a-button-selected');
          if (selectedBox) {
              var boxPriceMatch = selectedBox.innerText.match(/₹\s*([0-9,]+)/);
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
          var labels = document.querySelectorAll('span, div, p');
          labels.forEach(function(el) {
              if(el.children.length <= 2 && el.innerText.length < 50) {
                  var text = el.innerText.trim().replace(/\n/g, ' ');
                  var match = text.match(/^(Model|Color|Size|Style|Pattern|Capacity)\s*:\s*(.+)$/i);
                  if (match) {
                      var val = match[2].trim();
                      if(val && variants.indexOf(val) === -1) variants.push(val);
                  }
              }
          });
          
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
      return r'''
        (function() {
          var product = {};
          var titleEl = document.querySelector('h1') || document.querySelector('.B_NuCI') || document.querySelector('.VU-Tz5');
          var title = (titleEl && titleEl.innerText) ? titleEl.innerText.trim() : document.title;
          title = title.replace(/Online.*Mobiles.*Offers!/i, '').replace(/Online at Best Price.*Flipkart.com/i, '').replace(/- Buy.*Flipkart.com/i, '').trim();
          product.title = title;
          
          var maxFontSize = 0;
          var biggestPrice = '';
          var els = document.querySelectorAll('div, span');
          for (var i = 0; i < els.length; i++) {
              var text = els[i].innerText;
              if (text && text.trim().match(/^₹\s*[0-9,]+$/)) {
                  var style = window.getComputedStyle(els[i]);
                  if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                  
                  var fSize = parseInt(style.fontSize, 10) || 0;
                  if (fSize > maxFontSize && fSize > 0) {
                      maxFontSize = fSize;
                      biggestPrice = text;
                  }
              }
          }
          if(!biggestPrice) {
              var priceEl = document.querySelector('._30jeq3') || document.querySelector('.Nx9bqj') || document.querySelector('.hl05eU');
              if(priceEl) biggestPrice = priceEl.innerText;
          }
          product.price = biggestPrice.replace(/[^0-9]/g, '');
          
          var imgEl = document.querySelector('._396cs4') || document.querySelector('._2r_T1I') || document.querySelector('img.DByuf4') || document.querySelector('img.v2bfEK');
          if (!imgEl) {
              var imgs = document.querySelectorAll('img');
              for(var i=0; i<imgs.length; i++) {
                  if(imgs[i].src && imgs[i].src.includes('rukminim') && imgs[i].width > 100) {
                      imgEl = imgs[i];
                      break;
                  }
              }
          }
          product.image = imgEl ? imgEl.src : '';
          
          var variants = [];
          var selEls = document.querySelectorAll('li._3V2wfe._31hAvD, div._3V2wfe._31hAvD, a._1fGeB5._2uv97r, a._1fGeB5');
          for(var i=0; i<selEls.length; i++) {
              if (selEls[i].className.includes('_31hAvD') || selEls[i].className.includes('_2uv97r')) {
                  var txt = selEls[i].innerText.trim().replace(/\n/g, ' ');
                  if (txt && variants.indexOf(txt) === -1) variants.push(txt);
              }
          }
          product.variants = variants.join(', ');
          product.url = window.location.href;
          product.brand = 'Flipkart';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('myntra.com')) {
      return r'''
        (function() {
          var product = {};
          var brandEl = document.querySelector('.pdp-title');
          var titleEl = document.querySelector('.pdp-name') || document.querySelector('.name');
          var titleStr = '';
          if(brandEl) titleStr += brandEl.innerText.trim() + ' ';
          if(titleEl) {
              titleStr += titleEl.innerText.trim();
          } else {
              var h1s = document.querySelectorAll('h1, h2, h3, h4');
              for(var i=0; i<h1s.length; i++) {
                  if(h1s[i].innerText.length > 15 && h1s[i].innerText.length < 100) {
                      titleStr += h1s[i].innerText.trim();
                      break;
                  }
              }
          }
          if (!titleStr.trim()) titleStr = document.title.replace(/Buy.*Myntra/i, '').replace(/Online Shopping.*Myntra/i, '');
          product.title = titleStr.trim();
          
          var variants = [];
          var els = document.querySelectorAll('span, div, p, h4, h3, h2, h1');
          for(var i=0; i<els.length; i++) {
              var t = els[i].innerText.trim();
              
              var cMatch = t.replace(/\n/g, ' ').match(/^(Colour|Color)\s+([a-zA-Z\s]{2,15})$/i);
              if(cMatch) {
                  var val = cMatch[2].trim();
                  if(val.length > 1 && variants.indexOf(val) === -1 && !val.toLowerCase().includes('chart') && !val.toLowerCase().includes('fit')) {
                      variants.push("Colour: " + val);
                  }
              }
              
              var sMatch = t.replace(/\n/g, ' ').match(/^Size\s*:\s*([0-9]{1,3}|S|M|L|XL|XXL|XXXL|XS|One Size|Free Size)/i);
              if(sMatch && !t.toLowerCase().includes('chart') && !t.toLowerCase().includes('fit')) {
                  var val = sMatch[1].trim();
                  if(variants.indexOf("Size: " + val) === -1) {
                      variants.push("Size: " + val);
                  }
              }
          }
          
          var btns = document.querySelectorAll('button, li');
          if(variants.length === 0 || !variants.join(' ').match(/[0-9]{1,3}|S|M|L|XL|XXL|XXXL|XS/i)) {
              for(var i=0; i<btns.length; i++) {
                  if (btns[i].className && typeof btns[i].className === 'string') {
                      var cls = btns[i].className.toLowerCase();
                      if (cls.includes('select') || cls.includes('active') || btns[i].getAttribute('aria-selected') === 'true') {
                          var txt = btns[i].innerText.trim();
                          var sizeMatch = txt.match(/^([0-9]{1,3}|S|M|L|XL|XXL|XXXL|XS|One Size)/i);
                          if(sizeMatch && sizeMatch[1].length < 10) {
                              var sizeVal = "Size: " + sizeMatch[1];
                              if(variants.indexOf(sizeVal) === -1) variants.push(sizeVal);
                          }
                      }
                  }
              }
          }
          product.variants = variants.join(', ');
          
          var sizePrices = {};
          var activeSizePrice = '';
          var sizeBtns = document.querySelectorAll('button[class*="size-buttons"], div[class*="size-buttons-size-button"], .size-buttons-size-button, button');
          for (var i = 0; i < sizeBtns.length; i++) {
              var btnText = sizeBtns[i].innerText.trim();
              var sNameMatch = btnText.match(/^([0-9]{1,3}|S|M|L|XL|XXL|XXXL|XS|One Size|Free Size)/i);
              var sPriceMatch = btnText.match(/₹\s*([0-9,]+)/);
              
              if (sNameMatch) {
                  var sName = sNameMatch[1].toUpperCase();
                  if (sPriceMatch) {
                      sizePrices[sName] = sPriceMatch[1].replace(/[^0-9]/g, '');
                  }
                  
                  var cls = (sizeBtns[i].className || '').toLowerCase();
                  var parentCls = (sizeBtns[i].parentElement ? sizeBtns[i].parentElement.className || '' : '').toLowerCase();
                  if (cls.includes('active') || cls.includes('selected') || parentCls.includes('active') || parentCls.includes('selected')) {
                      if (sPriceMatch) activeSizePrice = sPriceMatch[1].replace(/[^0-9]/g, '');
                  }
              }
          }
          product.sizePrices = sizePrices;
          
          var pdpPriceEl = document.querySelector('.pdp-price strong') || 
                           document.querySelector('.pdp-price') || 
                           document.querySelector('.pdp-selling-price') ||
                           document.querySelector('.pdp-discount-container .pdp-price');
          var mainPdpPrice = '';
          if (pdpPriceEl) {
              var pMatch = pdpPriceEl.innerText.match(/₹\s*([0-9,]+)/) || pdpPriceEl.innerText.match(/([0-9,]{3,})/);
              if (pMatch) mainPdpPrice = pMatch[1].replace(/[^0-9]/g, '');
          }
          
          var finalPrice = activeSizePrice || mainPdpPrice;
          
          if (!finalPrice) {
              var maxFontSize = 0;
              var biggestPrice = '';
              for (var i = 0; i < Math.min(els.length, 300); i++) {
                  var text = els[i].innerText;
                  if (text && text.trim().match(/^₹\s*[0-9,]+$/)) {
                      var style = window.getComputedStyle(els[i]);
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                      var fSize = parseInt(style.fontSize, 10) || 0;
                      if (fSize > maxFontSize && fSize > 0) {
                          maxFontSize = fSize;
                          biggestPrice = text;
                      }
                  }
              }
              finalPrice = biggestPrice ? biggestPrice.replace(/[^0-9]/g, '') : '';
          }
          
          product.price = finalPrice;
          
          var imgEl = document.querySelector('.image-grid-image') || document.querySelector('.pdp-image-grid-image');
          if (!imgEl) {
              var imgs = document.querySelectorAll('img');
              for(var i=0; i<imgs.length; i++) {
                  if(imgs[i].src && imgs[i].src.includes('myntassets') && imgs[i].width > 100) {
                      imgEl = imgs[i];
                      break;
                  }
              }
          }
          product.image = (imgEl && imgEl.style && imgEl.style.backgroundImage) ? imgEl.style.backgroundImage.slice(4, -1).replace(/"/g, "") : (imgEl ? imgEl.src : '');
          
          product.url = window.location.href;
          product.brand = 'Myntra';
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('firstcry.com')) {
      return r'''
        (function() {
          var product = {};
          
          // 1. TITLE
          var titleEl = document.querySelector('.prod-name') || 
                        document.querySelector('h1.prod-name') || 
                        document.querySelector('.p-title') || 
                        document.querySelector('#prod_name') || 
                        document.querySelector('h1');
          var title = titleEl ? titleEl.innerText.trim() : document.title;
          title = title.replace(/^Buy\s+/i, '')
                       .replace(/\s+for\s+Boys.*FirstCry\.com.*/i, '')
                       .replace(/\s+for\s+Girls.*FirstCry\.com.*/i, '')
                       .replace(/\s+Online\s+in\s+India.*FirstCry\.com.*/i, '')
                       .replace(/\s*-\s*[0-9]{5,}.*/i, '')
                       .trim();
          product.title = title;
          
          // 2. PRICE
          var price = '';
          var priceEl = document.querySelector('#prod_price') || 
                        document.querySelector('.prod-price') || 
                        document.querySelector('.p-prod-price') || 
                        document.querySelector('.prod-price-box') || 
                        document.querySelector('.p-price') ||
                        document.querySelector('.dp-price') ||
                        document.querySelector('[class*="prod-price"]') ||
                        document.querySelector('[id*="prod_price"]');
                        
          if (priceEl) {
              var text = priceEl.innerText.trim();
              var m = text.match(/₹\s*([0-9,]+)/) || text.match(/([0-9,]{2,})/);
              if (m) price = m[1].replace(/[^0-9]/g, '');
          }
          
          if (!price) {
              var els = document.querySelectorAll('span, div, p, strong, b, h1, h2, h3');
              var maxFontSize = 0;
              for (var i = 0; i < Math.min(els.length, 400); i++) {
                  var text = els[i].innerText ? els[i].innerText.trim() : '';
                  var m = text.match(/(?:₹|Rs\.?)\s*([0-9,]+)/i);
                  if (m) {
                      var style = window.getComputedStyle(els[i]);
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                      
                      var cls = (els[i].className || '') + ' ' + (els[i].parentElement ? els[i].parentElement.className || '' : '');
                      if (cls.toLowerCase().includes('mrp') || cls.toLowerCase().includes('strike') || cls.toLowerCase().includes('cross')) continue;
                      
                      var fSize = parseInt(style.fontSize, 10) || 0;
                      if (fSize > maxFontSize && fSize > 0) {
                          maxFontSize = fSize;
                          price = m[1].replace(/[^0-9]/g, '');
                      }
                  }
              }
          }
          product.price = price;
          
          // 3. VARIANTS
          var variants = [];
          var sizeSel = document.querySelector('select[name*="size"], select[id*="size"], .size-dropdown, .size-select, #size_select, select');
          if (sizeSel && sizeSel.options && sizeSel.selectedIndex >= 0) {
              var optVal = sizeSel.options[sizeSel.selectedIndex].text.trim();
              if (optVal && !optVal.toLowerCase().includes('select') && !optVal.toLowerCase().includes('choose')) {
                  variants.push("Size: " + optVal);
              }
          }
          if (variants.length === 0) {
              var activeSize = document.querySelector('.size-btn.active, .size-box.active, [class*="size"].active, .size-btn.selected, [class*="size-btn"]');
              if (activeSize) {
                  var t = activeSize.innerText.trim();
                  if (t && t.length < 20) variants.push("Size: " + t);
              }
          }
          if (variants.length === 0) {
              var dropBox = document.querySelector('.size-dropdown-box, .size-box, [class*="size-dropdown"]');
              if (dropBox) {
                  var t = dropBox.innerText.trim();
                  if (t && t.length < 20) variants.push("Size: " + t);
              }
          }
          product.variants = variants.join(', ');
          
          // 4. IMAGE
          var ogImage = document.querySelector('meta[property="og:image"]');
          product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          if (!product.image) {
              var imgEl = document.querySelector('#prod_img') || document.querySelector('.prod-img') || document.querySelector('img.main-img');
              if (imgEl) product.image = imgEl.src;
          }
          if (!product.image) {
              var imgs = document.querySelectorAll('img');
              for(var i=0; i<imgs.length; i++) {
                  if(imgs[i].width > 150 && imgs[i].height > 150 && imgs[i].src.includes('firstcry')) {
                      product.image = imgs[i].src;
                      break;
                  }
              }
          }
          
          product.url = window.location.href;
          product.brand = 'Firstcry';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('ikea.com')) {
      return r'''
        (function() {
          var product = {};
          
          // 1. TITLE
          var titleEl = document.querySelector('.pip-header-section__title--big') || 
                        document.querySelector('h1.pip-header-section__title--big') || 
                        document.querySelector('h1');
          var descEl = document.querySelector('.pip-header-section__description');
          var title = (titleEl ? titleEl.innerText.trim() : '');
          if (descEl && descEl.innerText.trim()) {
              title += ' ' + descEl.innerText.trim();
          }
          if (!title) {
              var ogTitle = document.querySelector('meta[property="og:title"]');
              title = ogTitle ? ogTitle.content : document.title;
          }
          title = title.replace(/\s*-\s*IKEA.*/i, '').trim();
          product.title = title;
          
          // 2. PRICE
          var price = '';
          var ogPrice = document.querySelector('meta[property="product:price:amount"]') || document.querySelector('meta[property="og:price:amount"]');
          if (ogPrice && ogPrice.content) {
              price = ogPrice.content.replace(/[^0-9]/g, '');
          }
          if (!price) {
              var priceEl = document.querySelector('span.pip-temp-lugg-price__integer') || 
                            document.querySelector('span.pip-price__integer') || 
                            document.querySelector('.pip-temp-lugg-price') || 
                            document.querySelector('.pip-price');
              if (priceEl) {
                  price = priceEl.innerText.replace(/[^0-9]/g, '');
              }
          }
          if (!price) {
              var els = document.querySelectorAll('span, div, p, strong, h1, h2, h3');
              var maxFontSize = 0;
              for (var i = 0; i < Math.min(els.length, 300); i++) {
                  var text = els[i].innerText ? els[i].innerText.trim() : '';
                  var m = text.match(/(?:Rs\.?|₹|INR)\s*([0-9,]+)/i);
                  if (m) {
                      var style = window.getComputedStyle(els[i]);
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                      var fSize = parseInt(style.fontSize, 10) || 0;
                      if (fSize > maxFontSize && fSize > 0) {
                          maxFontSize = fSize;
                          price = m[1].replace(/[^0-9]/g, '');
                      }
                  }
              }
          }
          product.price = price;
          
          // 3. VARIANTS
          var dimEl = document.querySelector('.pip-product-dimensions') || document.querySelector('.pip-header-section__description');
          product.variants = dimEl ? dimEl.innerText.trim() : '';
          
          // 4. IMAGE
          var ogImage = document.querySelector('meta[property="og:image"]');
          product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          if (!product.image) {
              var imgEl = document.querySelector('img.pip-image') || document.querySelector('img.pip-aspect-ratio-image__image');
              if (imgEl) product.image = imgEl.src;
          }
          
          product.url = window.location.href;
          product.brand = 'IKEA';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('decathlon.in')) {
      return r'''
        (function() {
          var product = {};
          
          // 1. TITLE
          var titleEl = document.querySelector('h1') || document.querySelector('.pdp-title') || document.querySelector('[class*="title"]');
          var brandEl = document.querySelector('.brand-name') || document.querySelector('[class*="brand"]');
          var title = '';
          if (brandEl) title += brandEl.innerText.trim() + ' ';
          if (titleEl) title += titleEl.innerText.trim();
          if (!title.trim()) {
              var ogTitle = document.querySelector('meta[property="og:title"]');
              title = ogTitle ? ogTitle.content : document.title;
          }
          title = title.replace(/\s*-\s*Decathlon.*/i, '').trim();
          product.title = title;
          
          // 2. PRICE
          var price = '';
          var ogPrice = document.querySelector('meta[property="product:price:amount"]') || document.querySelector('meta[property="og:price:amount"]');
          if (ogPrice && ogPrice.content) {
              price = ogPrice.content.replace(/[^0-9]/g, '');
          }
          if (!price) {
              var priceEl = document.querySelector('.price-text') || 
                            document.querySelector('[class*="sp-price"]') || 
                            document.querySelector('[class*="selling-price"]') || 
                            document.querySelector('.price');
              if (priceEl) {
                  var pMatch = priceEl.innerText.match(/₹\s*([0-9,]+)/) || priceEl.innerText.match(/([0-9,]{2,})/);
                  if (pMatch) price = pMatch[1].replace(/[^0-9]/g, '');
              }
          }
          if (!price) {
              var els = document.querySelectorAll('span, div, p, strong, h1, h2, h3');
              var maxFontSize = 0;
              for (var i = 0; i < Math.min(els.length, 300); i++) {
                  var text = els[i].innerText ? els[i].innerText.trim() : '';
                  var m = text.match(/₹\s*([0-9,]+)/);
                  if (m) {
                      var style = window.getComputedStyle(els[i]);
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                      var cls = (els[i].className || '') + ' ' + (els[i].parentElement ? els[i].parentElement.className || '' : '');
                      if (cls.toLowerCase().includes('mrp') || cls.toLowerCase().includes('strike') || cls.toLowerCase().includes('cross')) continue;
                      
                      var fSize = parseInt(style.fontSize, 10) || 0;
                      if (fSize > maxFontSize && fSize > 0) {
                          maxFontSize = fSize;
                          price = m[1].replace(/[^0-9]/g, '');
                      }
                  }
              }
          }
          product.price = price;
          
          // 3. VARIANTS
          var variants = [];
          var sizeBtns = document.querySelectorAll('button[class*="size"], div[class*="size"], li[class*="size"]');
          for (var i = 0; i < sizeBtns.length; i++) {
              var cls = (sizeBtns[i].className || '').toLowerCase();
              var parentCls = (sizeBtns[i].parentElement ? sizeBtns[i].parentElement.className || '' : '').toLowerCase();
              if (cls.includes('active') || cls.includes('selected') || parentCls.includes('active') || parentCls.includes('selected')) {
                  var txt = sizeBtns[i].innerText.trim();
                  var sMatch = txt.match(/^([0-9]{1,3}|S|M|L|XL|XXL|2XL|3XL|XS)/i);
                  if (sMatch) {
                      variants.push("Size: " + sMatch[1].toUpperCase());
                      break;
                  }
              }
          }
          product.variants = variants.join(', ');
          
          // 4. IMAGE
          var ogImage = document.querySelector('meta[property="og:image"]');
          product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          if (!product.image) {
              var imgEl = document.querySelector('img[src*="decathlon"]') || document.querySelector('.pdp-image img');
              if (imgEl) product.image = imgEl.src;
          }
          
          product.url = window.location.href;
          product.brand = 'Decathlon';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('sephora.in')) {
      return r'''
        (function() {
          var product = {};
          
          // 1. TITLE
          var titleEl = document.querySelector('h1') || 
                        document.querySelector('.pdp-title') || 
                        document.querySelector('.product-name') ||
                        document.querySelector('[class*="product-name"]');
          var title = titleEl ? titleEl.innerText.trim() : '';
          if (!title) {
              var ogTitle = document.querySelector('meta[property="og:title"]');
              title = ogTitle ? ogTitle.content : document.title;
          }
          title = title.replace(/Online at Sephora.*/i, '').replace(/-\s*Sephora.*/i, '').trim();
          product.title = title;
          
          // 2. PRICE
          var price = '';
          try {
              var jsonScripts = document.querySelectorAll('script[type="application/ld+json"]');
              for (var j = 0; j < jsonScripts.length; j++) {
                  var data = JSON.parse(jsonScripts[j].innerText);
                  var target = data.offers || (data[0] ? data[0].offers : null) || data;
                  if (target && (target.price || target.highPrice || target.lowPrice)) {
                      var p = target.price || target.highPrice || target.lowPrice;
                      if (p) {
                          price = p.toString().replace(/[^0-9]/g, '');
                          if (price) break;
                      }
                  }
              }
          } catch(e) {}

          if (!price) {
              var pdpPriceEl = document.querySelector('.pdp-price') || 
                               document.querySelector('.pdp-selling-price') || 
                               document.querySelector('[class*="pdp-price"]') || 
                               document.querySelector('.product-price') ||
                               document.querySelector('[class*="product-price"]');
              if (pdpPriceEl) {
                  var m = pdpPriceEl.innerText.match(/₹\s*([0-9,]+)/) || pdpPriceEl.innerText.match(/([0-9,]{3,})/);
                  if (m) price = m[1].replace(/[^0-9]/g, '');
              }
          }

          if (!price) {
              var rootContainer = document.querySelector('.pdp-container') || document.querySelector('.product-detail') || document.querySelector('#pdp') || document.body;
              var priceEls = rootContainer.querySelectorAll('[class*="price"], [class*="Price"], [id*="price"], div, span, p, strong, h1, h2, h3');
              var maxFontSize = 0;
              for (var i = 0; i < Math.min(priceEls.length, 150); i++) {
                  var text = priceEls[i].innerText ? priceEls[i].innerText.trim() : '';
                  var m = text.match(/(?:MRP\s*)?₹\s*([0-9,]+)/i);
                  if (m) {
                      var style = window.getComputedStyle(priceEls[i]);
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                      var cls = (priceEls[i].className || '') + ' ' + (priceEls[i].parentElement ? priceEls[i].parentElement.className || '' : '');
                      if (cls.toLowerCase().includes('strike') || cls.toLowerCase().includes('cross')) continue;
                      
                      var fSize = parseInt(style.fontSize, 10) || 0;
                      if (fSize > maxFontSize && fSize > 0) {
                          maxFontSize = fSize;
                          price = m[1].replace(/[^0-9]/g, '');
                      }
                  }
              }
          }

          if (!price) {
              var ogPrice = document.querySelector('meta[property="product:price:amount"]') || document.querySelector('meta[property="og:price:amount"]');
              if (ogPrice && ogPrice.content) {
                  price = ogPrice.content.replace(/[^0-9]/g, '');
              }
          }
          
          product.price = price;
          
          // 3. VARIANTS (AUTOMATIC SHADE AUTO-GRAB)
          var shadeVal = '';
          var els = document.querySelectorAll('span, div, p, h4, h3, h2, h1, b, strong');
          for (var i = 0; i < Math.min(els.length, 400); i++) {
              var text = els[i].innerText ? els[i].innerText.trim() : '';
              var m = text.match(/(?:Shade|Colour|Color)\s*:\s*([a-zA-Z0-9\.\-\s\/]+)/i);
              if (m) {
                  var candidate = m[1].split('\n')[0].replace(/VIEW ALL.*/i, '').replace(/Size.*/i, '').trim();
                  if (candidate && candidate.length > 0 && candidate.length < 35 && !candidate.toLowerCase().includes('select')) {
                      shadeVal = candidate;
                      break;
                  }
              }
          }
          if (!shadeVal) {
              var allLabels = document.querySelectorAll('span, div, p, strong, b');
              for (var i = 0; i < Math.min(allLabels.length, 400); i++) {
                  var txt = allLabels[i].innerText ? allLabels[i].innerText.trim() : '';
                  if (txt.match(/^(?:Shade|Colour|Color)\s*:?$/i)) {
                      var sibling = allLabels[i].nextElementSibling || (allLabels[i].parentElement ? allLabels[i].parentElement.querySelector('.active, span:last-child') : null);
                      if (sibling && sibling.innerText) {
                          var sTxt = sibling.innerText.trim().split('\n')[0];
                          if (sTxt && sTxt.length < 35) {
                              shadeVal = sTxt;
                              break;
                          }
                      }
                  }
              }
          }
          if (!shadeVal) {
              var activeSwatch = document.querySelector('[class*="shade"][class*="active"], [class*="swatch"][class*="selected"], [class*="shade"][class*="selected"], [class*="variant"][class*="active"], .active-shade, div[aria-selected="true"]');
              if (activeSwatch) {
                  var titleAttr = activeSwatch.getAttribute('title') || activeSwatch.getAttribute('aria-label') || activeSwatch.getAttribute('data-shade') || activeSwatch.innerText;
                  if (titleAttr && titleAttr.trim()) {
                      shadeVal = titleAttr.trim().split('\n')[0];
                  }
              }
          }
          product.variants = shadeVal ? ("Shade: " + shadeVal) : '';
          
          // 4. IMAGE
          var ogImage = document.querySelector('meta[property="og:image"]');
          product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          if (!product.image) {
              var imgEl = document.querySelector('img[src*="sephora"]') || document.querySelector('.pdp-image img') || document.querySelector('img');
              if (imgEl) product.image = imgEl.src;
          }
          
          product.url = window.location.href;
          product.brand = 'Sephora';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('uniqlo.com')) {
      return r'''
        (function() {
          var product = {};
          
          // 1. TITLE
          var titleEl = document.querySelector('h1') || 
                        document.querySelector('.fr-product-detail-name') || 
                        document.querySelector('[data-test="product-name"]') ||
                        document.querySelector('.product-title');
          var title = titleEl ? titleEl.innerText.trim() : document.title;
          title = title.replace(/\s*[\|I\-]\s*UNIQLO.*$/i, '').trim();
          product.title = title;
          
          // 2. PRICE
          var price = '';
          var priceEl = document.querySelector('.fr-price-value') || 
                        document.querySelector('[data-test="price-value"]') || 
                        document.querySelector('.price') ||
                        document.querySelector('[class*="price"]');
          if (priceEl) {
              var text = priceEl.innerText.trim();
              var m = text.match(/(?:Rs\.?|₹|INR)\s*([0-9,]+(?:\.[0-9]+)?)/i) || text.match(/([0-9,]{3,})/);
              if (m) price = m[1].split('.')[0].replace(/[^0-9]/g, '');
          }
          
          if (!price) {
              var els = document.querySelectorAll('span, div, p, strong, h1, h2, h3');
              var maxFontSize = 0;
              for (var i = 0; i < Math.min(els.length, 300); i++) {
                  var text = els[i].innerText ? els[i].innerText.trim() : '';
                  var m = text.match(/(?:MRP\s*)?(?:Rs\.?|₹|INR)\s*([0-9,]+)/i);
                  if (m) {
                      var style = window.getComputedStyle(els[i]);
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                      var fSize = parseInt(style.fontSize, 10) || 0;
                      if (fSize > maxFontSize && fSize > 0) {
                          maxFontSize = fSize;
                          price = m[1].replace(/[^0-9]/g, '');
                      }
                  }
              }
          }
          product.price = price;
          
          // 3. VARIANTS (Color & Size)
          var variants = [];
          var els = document.querySelectorAll('span, div, p, h4, h3, h2, h1, b, strong');
          var colorVal = '';
          var sizeVal = '';
          for (var i = 0; i < Math.min(els.length, 400); i++) {
              var t = els[i].innerText ? els[i].innerText.trim() : '';
              if (!colorVal) {
                  var cMatch = t.match(/^Color\s*:\s*([^\n\r]+)/i);
                  if (cMatch) {
                      colorVal = cMatch[1].replace(/VIEW ALL.*/i, '').trim();
                  }
              }
              if (!sizeVal) {
                  var sMatch = t.match(/^Size\s*:\s*([^\n\r]+)/i);
                  if (sMatch) {
                      var rawS = sMatch[1].replace(/Sizing.*/i, '').replace(/Size\s*Chart.*/i, '').replace(/Get\s*help.*/i, '').trim();
                      if (rawS && rawS.length < 35) {
                          sizeVal = rawS;
                      }
                  }
              }
          }
          if (!sizeVal) {
              var activeSizeBtn = document.querySelector('button[aria-checked="true"], [data-test*="size"][aria-checked="true"], button[class*="size"][class*="selected"], button[class*="size"][class*="active"], input[name*="size"]:checked + label');
              if (activeSizeBtn) sizeVal = activeSizeBtn.innerText.trim();
          }
          
          if (colorVal) variants.push("Colour: " + colorVal);
          if (sizeVal) variants.push("Size: " + sizeVal);
          
          product.variants = variants.join(', ');
          
          // 4. IMAGE
          var ogImage = document.querySelector('meta[property="og:image"]');
          product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          if (!product.image) {
              var imgEl = document.querySelector('img[src*="uniqlo"]') || document.querySelector('.product-image img');
              if (imgEl) product.image = imgEl.src;
          }
          
          product.url = window.location.href;
          product.brand = 'Uniqlo';
          
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('zara.com')) {
      return r'''
        (function() {
          var product = {};
          var price = '';
          
          // 1. JSON-LD PARSING
          var jsonLdScripts = document.querySelectorAll('script[type="application/ld+json"]');
          for (var i = 0; i < jsonLdScripts.length; i++) {
              try {
                  var data = JSON.parse(jsonLdScripts[i].innerText);
                  var items = Array.isArray(data) ? data : [data];
                  for (var j = 0; j < items.length; j++) {
                      var item = items[j];
                      if (item['@type'] === 'Product' || item.offers) {
                          if (item.offers) {
                              var offer = Array.isArray(item.offers) ? item.offers[0] : item.offers;
                              if (offer.price || offer.lowPrice) {
                                  price = String(offer.price || offer.lowPrice).replace(/[^0-9]/g, '');
                              }
                          }
                          if (item.name && !product.title) product.title = item.name;
                          if (item.image && !product.image) product.image = Array.isArray(item.image) ? item.image[0] : item.image;
                      }
                  }
              } catch (_) {}
          }
          
          // 2. TITLE
          if (!product.title) {
              var titleEl = document.querySelector('h1') || 
                            document.querySelector('.product-detail-info__header-name') || 
                            document.querySelector('[class*="product-detail-info__name"]') ||
                            document.querySelector('.product-name');
              var title = titleEl ? titleEl.innerText.trim() : document.title;
              title = title.replace(/\s*-\s*ZARA.*$/i, '').replace(/\s*\|ZARA.*$/i, '').trim();
              product.title = title;
          }
          
          // 3. PRICE
          if (!price) {
              var priceEls = document.querySelectorAll('.price-current__amount, .price__amount, .money-amount__main, [class*="price-current"], [class*="price"]');
              for (var i = 0; i < priceEls.length; i++) {
                  var text = priceEls[i].innerText ? priceEls[i].innerText.trim() : '';
                  var m = text.match(/(?:₹|INR|Rs\.?)\s*([0-9,]+(?:\.[0-9]+)?)/i) || text.match(/([0-9,]{3,}(?:\.[0-9]+)?)/);
                  if (m) {
                      price = m[1].split('.')[0].replace(/[^0-9]/g, '');
                      if (price) break;
                  }
              }
          }
          if (!price) {
              var els = document.querySelectorAll('span, div, p, strong, h1, h2, h3');
              var maxFontSize = 0;
              for (var i = 0; i < Math.min(els.length, 300); i++) {
                  var text = els[i].innerText ? els[i].innerText.trim() : '';
                  var m = text.match(/(?:₹|INR|Rs\.?)\s*([0-9,]+)/i);
                  if (m) {
                      var style = window.getComputedStyle(els[i]);
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue;
                      var fSize = parseInt(style.fontSize, 10) || 0;
                      if (fSize > maxFontSize && fSize > 0) {
                          maxFontSize = fSize;
                          price = m[1].replace(/[^0-9]/g, '');
                      }
                  }
              }
          }
          product.price = price;
          
          // 4. VARIANTS (Color & Size)
          var variants = [];
          var colorVal = '';
          var sizeVal = '';
          
          var colorEl = document.querySelector('.product-detail-selected-color') || 
                        document.querySelector('[class*="product-detail-color"]') || 
                        document.querySelector('[class*="color-selector"]');
          if (colorEl) {
              colorVal = colorEl.innerText.trim().split('\n')[0].replace(/\|.*/, '').trim();
          }
          
          var sizeEl = document.querySelector('[class*="size-selector"] [class*="selected"]') || 
                       document.querySelector('[class*="size-selector"] [aria-checked="true"]') ||
                       document.querySelector('[data-qa-action="size-selector"] [aria-checked="true"]');
          if (sizeEl) {
              sizeVal = sizeEl.innerText.trim().split('\n')[0];
          }
          
          if (!colorVal || !sizeVal) {
              var els = document.querySelectorAll('span, div, p, h4, h3, h2, h1');
              for (var i = 0; i < Math.min(els.length, 300); i++) {
                  var t = els[i].innerText ? els[i].innerText.trim() : '';
                  if (!colorVal) {
                      var cMatch = t.match(/^(?:Color|Colour)\s*:\s*([^\n\r]+)/i);
                      if (cMatch) colorVal = cMatch[1].replace(/\|.*/, '').trim();
                  }
                  if (!sizeVal) {
                      var sMatch = t.match(/^Size\s*:\s*([^\n\r]+)/i);
                      if (sMatch) sizeVal = sMatch[1].trim();
                  }
              }
          }
          
          if (colorVal) variants.push("Colour: " + colorVal);
          if (sizeVal) variants.push("Size: " + sizeVal);
          product.variants = variants.join(', ');
          
          // 5. IMAGE
          if (!product.image) {
              var ogImage = document.querySelector('meta[property="og:image"]');
              product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          }
          if (!product.image) {
              var imgEl = document.querySelector('.media-image__image') || document.querySelector('picture img') || document.querySelector('img[src*="zara"]');
              if (imgEl) product.image = imgEl.src;
          }
          
          product.url = window.location.href;
          product.brand = 'Zara';
          
          return JSON.stringify(product);
        })();
      ''';
    } else {
      return r'''
        (function() {
          var product = {};
          var ogTitle = document.querySelector('meta[property="og:title"]');
          var titleEl = document.querySelector('h1');
          product.title = (ogTitle && ogTitle.content) ? ogTitle.content : (titleEl ? titleEl.innerText : document.title);
          var price = '';
          var ogPrice = document.querySelector('meta[property="product:price:amount"]') || document.querySelector('meta[property="og:price:amount"]');
          if (ogPrice && ogPrice.content) { 
              price = ogPrice.content; 
          } else { 
              var els = document.querySelectorAll('span, div, p, h2, h3, h4'); 
              var maxFontSize = 0; 
              for(var i=0; i<Math.min(els.length, 400); i++) { 
                  var text = els[i].innerText; 
                  if (text && text.trim().match(/^(₹|Rs\.|INR)\s*[0-9,]+/i)) { 
                      var style = window.getComputedStyle(els[i]); 
                      if (style.textDecoration && style.textDecoration.includes('line-through')) continue; 
                      var fSize = parseInt(style.fontSize, 10) || 0; 
                      if (fSize > maxFontSize && fSize > 0) { 
                          maxFontSize = fSize; 
                          price = text.match(/[0-9,]+/)[0]; 
                      } 
                  } 
              } 
          }
          product.price = price ? price.replace(/[^0-9]/g, '') : '';
          var ogImage = document.querySelector('meta[property="og:image"]');
          product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          if (!product.image) { 
              var imgs = document.querySelectorAll('img'); 
              for(var i=0; i<imgs.length; i++) { 
                  if(imgs[i].width > 200 && imgs[i].height > 200) { 
                      product.image = imgs[i].src; 
                      break; 
                  } 
              } 
          }
          var host = window.location.hostname.replace('www.', '').split('.')[0];
          product.brand = host.charAt(0).toUpperCase() + host.slice(1);
          product.url = window.location.href;
          product.variants = '';
          return JSON.stringify(product);
        })();
      ''';
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
                onPressed: () async {
                  final String? currentUrl = await _controller.currentUrl();
                  if (mounted) {
                    if (currentUrl != null && (currentUrl.contains('myntra.com') || currentUrl.contains('firstcry.com') || currentUrl.contains('decathlon.in') || currentUrl.contains('sephora.in') || currentUrl.contains('uniqlo.com') || currentUrl.contains('zara.com'))) {
                      _scrapeAndShowSizeColourDialog(context);
                    } else if (currentUrl != null && currentUrl.contains('ikea.com')) {
                      _scrapeProductDetails(context);
                    } else {
                      _showConfirmationDialog(context);
                    }
                  }
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
