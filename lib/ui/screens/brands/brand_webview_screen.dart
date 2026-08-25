import 'dart:convert';
import 'dart:io';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:eClassify/app/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/data/cubits/ecommerce/cart_cubit.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/ui/screens/brands/coming_soon_screen.dart';

class BrandWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const BrandWebViewScreen({super.key, required this.title, required this.url});

  @override
  State<BrandWebViewScreen> createState() => _BrandWebViewScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    if (arguments['isComingSoon'] == true ||
        arguments['isComingSoon'] == 'true' ||
        arguments['url'] == 'coming_soon') {
      return MaterialPageRoute(
        builder: (_) => ComingSoonScreen(
          title: arguments['title'] as String,
          image: arguments['image'] as String?,
        ),
      );
    }
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
  int _activeDialogCount = 0;

  bool get _isDialogShowing => _activeDialogCount > 0;

  Future<T?> _showAppDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) async {
    setState(() {
      _activeDialogCount++;
    });
    _controller.runJavaScript("if (document && document.body) document.body.style.pointerEvents = 'none';").catchError((_) {});

    try {
      return await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder,
      );
    } finally {
      if (mounted) {
        setState(() {
          _activeDialogCount = (_activeDialogCount - 1).clamp(0, 999);
        });
        if (_activeDialogCount == 0) {
          _controller.runJavaScript("if (document && document.body) document.body.style.pointerEvents = 'auto';").catchError((_) {});
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<CartCubit>().fetchCart(isSilent: true);
      }
    });

    // Use a Desktop Chrome User-Agent for two reasons:
    // 1. Varnish-based CDNs (e.g. Lacoste.in) blocklist mobile/WebView UA strings (Error 54113).
    // 2. IKEA and many e-commerce sites serve a different React layout to mobile UAs
    //    with different CSS class names, breaking our price/title scraping selectors.
    //    Desktop UA ensures both Android and iOS get the same page structure.
    const String _browserUA =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_browserUA)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FlutterProductDetector',
        onMessageReceived: (JavaScriptMessage message) {
          if (!mounted) return;
          final bool isProduct = message.message == 'true';
          if (isProduct != isProductPage) {
            setState(() {
              isProductPage = isProduct;
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            _checkIfProductPage(url);
          },
          onPageFinished: (String url) {
            _checkIfProductPage(url);
            setState(() {
              isLoading = false;
            });
            // Inject JS monitor for SPA-based brands (Snitch Next.js, Shopify)
            _injectSpaProductMonitor();
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              _checkIfProductPage(change.url!);
            }
          },
        ),
      )
      // Include browser-standard headers so Varnish CDN (Lacoste.in Error 54113)
      // accepts the request. Missing Accept/Accept-Language headers are a common
      // cause of 403 blocks on Varnish-guarded e-commerce sites.
      ..loadRequest(
        Uri.parse(widget.url),
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );
  }

  /// Injects a JavaScript monitor into the page that intercepts SPA navigation
  /// (history.pushState / history.replaceState used by Next.js and Shopify)
  /// and continuously reports product page status back to Flutter via a named JS channel.
  void _injectSpaProductMonitor() {
    _controller.runJavaScript(r'''
      (function() {
        if (window.__koraMonitorActive) return;
        window.__koraMonitorActive = true;

        function isProductPageNow() {
          var url = (window.location.href || '').toLowerCase();

          // 1. Specific & general URL pattern checks
          if (url.includes('/products/') || url.includes('/products') || url.includes('/product/') || url.includes('/product')) return true;
          if (url.includes('/dp/') || url.includes('/gp/product/') || url.includes('/p/')) return true;
          if (url.includes('myntra.com') && (url.includes('/buy') || /\/[0-9]{5,}/.test(url))) return true;
          if (url.includes('firstcry.com') && url.includes('product-detail')) return true;
          if (url.includes('zara.com') && (url.includes('-p0') || url.includes('.html'))) return true;
          // Lacoste (Magento): use DOM check below — URL alone is not reliable (category pages also end in .html)

          // 2. Shopify check (non-Lacoste pages only)
          try {
            if (window.ShopifyAnalytics && window.ShopifyAnalytics.meta && window.ShopifyAnalytics.meta.product) return true;
          } catch(e) {}

          // 3. Lacoste (Magento 2): use ONLY PDP-exclusive element IDs.
          // form#product_addtocart_form and button#product-addtocart-button are generated
          // by Magento ONLY on product detail pages — never on listing/category/sale pages.
          if (url.includes('lacoste.in')) {
            return !!(document.querySelector('form#product_addtocart_form') ||
                      document.querySelector('button#product-addtocart-button') ||
                      document.querySelector('button[data-action="add-to-cart"]'));
          }

          // 4. og:type=product metadata check (for non-Lacoste brands)
          var ogType = document.querySelector('meta[property="og:type"]');
          if (ogType && (ogType.content === 'product' || ogType.content === 'og:product')) return true;

          // 4. DOM check: "ADD TO BAG" or "ADD TO CART" buttons on page
          var btns = document.querySelectorAll('button, a, input[type="submit"], div[role="button"]');
          for (var i = 0; i < Math.min(btns.length, 120); i++) {
            var txt = (btns[i].innerText || btns[i].value || '').trim().toUpperCase();
            if (txt === 'ADD TO BAG' || txt === 'ADD TO CART' || txt === 'BUY NOW' || txt.includes('ADD TO BAG') || txt.includes('ADD TO CART')) {
              return true;
            }
          }

          return false;
        }

        var lastReportedStatus = null;
        function reportStatus() {
          try {
            var currentStatus = isProductPageNow() ? 'true' : 'false';
            if (currentStatus !== lastReportedStatus) {
              lastReportedStatus = currentStatus;
              FlutterProductDetector.postMessage(currentStatus);
            }
          } catch(e) {}
        }

        // Report immediately
        reportStatus();

        // Intercept history.pushState & history.replaceState (Next.js & React SPA routing)
        var _origPushState = history.pushState.bind(history);
        history.pushState = function() {
          _origPushState.apply(history, arguments);
          setTimeout(reportStatus, 200);
          setTimeout(reportStatus, 600);
          setTimeout(reportStatus, 1200);
        };

        var _origReplaceState = history.replaceState.bind(history);
        history.replaceState = function() {
          _origReplaceState.apply(history, arguments);
          setTimeout(reportStatus, 200);
          setTimeout(reportStatus, 600);
          setTimeout(reportStatus, 1200);
        };

        window.addEventListener('popstate', function() {
          setTimeout(reportStatus, 200);
          setTimeout(reportStatus, 600);
        });

        // Periodic check every 1 second to handle delayed dynamic DOM rendering
        setInterval(reportStatus, 1000);
      })();
    ''').catchError((_) {});
  }

  void _checkIfProductPage(String url) {
    String lowerUrl = url.toLowerCase();
    
    // Basic check for product pages across platforms
    bool isAmazonProduct = lowerUrl.contains('/dp/') || lowerUrl.contains('/gp/product/');
    bool isFlipkartProduct = lowerUrl.contains('flipkart.com') && lowerUrl.contains('/p/');
    bool isMyntraProduct = lowerUrl.contains('myntra.com') && (lowerUrl.contains('/buy') || RegExp(r'/[0-9]{5,}').hasMatch(lowerUrl));
    
    bool isDecathlonProduct = lowerUrl.contains('decathlon.in') && lowerUrl.contains('/p/');
    bool isFirstcryProduct = lowerUrl.contains('firstcry.com') && lowerUrl.contains('product-detail');
    bool isIkeaProduct = lowerUrl.contains('ikea.com') && lowerUrl.contains('/p/');
    bool isSephoraProduct = lowerUrl.contains('sephora.in') && lowerUrl.contains('/product');
    bool isUniqloProduct = lowerUrl.contains('uniqlo.com') && lowerUrl.contains('/products');
    bool isZaraProduct = lowerUrl.contains('zara.com') && (lowerUrl.contains('-p0') || lowerUrl.contains('.html'));
    // Lacoste: no URL-based check — detection is handled entirely by the SPA monitor DOM checks
    // (category pages also end in .html on Magento, so DOM detection is the only reliable signal)
    
    // Snitch, Rare Rabbit, The Bear House product URL checks
    bool isSnitchProduct = (lowerUrl.contains('snitch.com') || lowerUrl.contains('snitch.co.in')) && (lowerUrl.contains('/products') || lowerUrl.contains('/product'));
    bool isRareRabbitProduct = lowerUrl.contains('thehouseofrare.com') && (lowerUrl.contains('/products') || lowerUrl.contains('/product'));
    bool isBearHouseProduct = lowerUrl.contains('thebearhouse.com') && (lowerUrl.contains('/products') || lowerUrl.contains('/product'));
    
    // Generic fallback for product URLs
    bool isGenericProduct = lowerUrl.contains('/products/') || lowerUrl.contains('/product/');

    bool isProduct = isAmazonProduct || isFlipkartProduct || isMyntraProduct || 
                     isDecathlonProduct || isFirstcryProduct || isIkeaProduct || 
                     isSephoraProduct || isUniqloProduct || isZaraProduct ||
                     isSnitchProduct || isRareRabbitProduct || isBearHouseProduct ||
                     isGenericProduct;
    
    if (isProduct != isProductPage) {
      setState(() {
        isProductPage = isProduct;
      });
    }
  }

  Future<void> _addToCart(BuildContext context, Map<String, dynamic> product) async {
    // Allow manual price override from the dialog price field
    final String rawPrice = (product['price'] ?? '').toString().trim();
    double priceNum = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    if (priceNum <= 0) {
      HelperUtils.showSnackBarMessage(context, "Could not detect product price", type: MessageType.error);
      return;
    }

    _showAppDialog(
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
                Text('Adding to Cart...', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );

    final success = await context.read<CartCubit>().addScrapedProductToCart(product);
    if (context.mounted) {
      Navigator.of(context).pop(); // hide progress
      if (success) {
        HelperUtils.showSnackBarMessage(context, "Added to Cart successfully", type: MessageType.success);
        // Prompt to go to cart
        _showAppDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Added to Cart'),
            content: const Text('Do you want to view your cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Continue Shopping'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushNamed(context, Routes.ecommerceCart);
                },
                child: const Text('View Cart'),
              ),
            ],
          ),
        );
      } else {
        String msg = "Failed to add product to cart";
        final state = context.read<CartCubit>().state;
        if (state is CartFailure) {
          msg = state.errorMessage;
        }
        HelperUtils.showSnackBarMessage(context, msg, type: MessageType.error);
      }
    }
  }



  /// Safely parses the Object returned by runJavaScriptReturningResult into a Map.
  /// Handles single-encoded JSON (iOS) and double-encoded JSON (Chromium Android)
  /// without corrupting newlines, quotes, or unicode characters.
  Map<String, dynamic> _parseJsResult(Object? result) {
    if (result == null) return {};
    try {
      dynamic decoded = result;
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      debugPrint('[SCRAPER] parse error: $e');
    }
    return {};
  }

  /// Runs a synchronous JS scraper with retry support.
  /// Retries up to [maxRetries] times (with [delayMs] between attempts)
  /// to handle React/SPA hydration lag — especially on Android WebView.
  Future<Map<String, dynamic>> _runJsScraperWithRetry(
    String jsScript, {
    int maxRetries = 4,
    int delayMs = 800,
  }) async {
    Map<String, dynamic> lastResult = {};
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      if (attempt > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
      try {
        final Object result = await _controller.runJavaScriptReturningResult(jsScript);
        final Map<String, dynamic> product = _parseJsResult(result);
        if (product.isNotEmpty) {
          lastResult = product;
          final String price = (product['price'] ?? '').toString();
          if (price.isNotEmpty && price != '0') {
            return product; // success
          }
        }
      } catch (e) {
        debugPrint('[SCRAPER] attempt=$attempt error=$e');
      }
    }
    return lastResult;
  }

  Future<void> _scrapeAndShowSizeColourDialog(BuildContext context) async {
    _showAppDialog(
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

    final String jsScript = _getJsScript(currentUrl);
    if (jsScript.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      Map<String, dynamic> product;

      if (Platform.isAndroid) {
        // Android WebView: wait for React SPA hydration before scraping
        await Future.delayed(const Duration(milliseconds: 2500));
        product = await _runJsScraperWithRetry(jsScript, maxRetries: 4, delayMs: 800);
      } else {
        // iOS: existing single-shot synchronous JS — untouched
        final Object result = await _controller.runJavaScriptReturningResult(jsScript);
        product = _parseJsResult(result);
      }

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        if (currentUrl.contains('sephora.in')) {
          _showShadeSelectionDialog(context, product);
        } else {
          _showSizeColourSelectionDialog(context, product);
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scrape product details.')),
      );
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

    _showAppDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
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

                            _addToCart(context, product);
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

    _showAppDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: context.color.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
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
                                double sizeP = double.tryParse(sizePrices[key].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                                double currentP = double.tryParse((product['price'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
                                if (sizeP > 100 && (currentP == 0 || (sizeP <= currentP * 1.3 && sizeP >= currentP * 0.3))) {
                                  product['price'] = sizeP.toStringAsFixed(0);
                                }
                              }
                            }

                            Navigator.of(dialogContext).pop();

                            _addToCart(context, product);
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
          
          var selectedVariants = [];
          var seenLabels = {};
          
          // Strategy 1: Amazon's variation containers (most reliable - desktop & mobile)
          // Each container has a label span and a .selection span showing the chosen value
          var variationContainers = document.querySelectorAll('[id^="variation_"], [id^="native_"]');
          variationContainers.forEach(function(container) {
              // Get label (e.g. "Colour:", "Size:")
              var labelEl = container.querySelector('.a-form-label, label, .a-size-base.a-text-bold');
              var label = labelEl ? labelEl.innerText.trim().replace(/:$/, '').trim() : '';
              // Get selected value from .selection span (Amazon's standard)
              var selEl = container.querySelector('.selection, .twister-mobile-selection-text');
              if (!selEl) {
                  selEl = container.querySelector('.a-button-selected .a-button-text, li[aria-selected="true"], .a-button-text[data-action*="select"]');
              }
              var val = selEl ? selEl.innerText.trim().split('\n')[0].trim() : '';
              // Clean up common Amazon suffixes like "  2XL Chest 48..." - keep only first word group
              if (val) {
                  val = val.split(/\s{2,}/)[0].trim(); // split on 2+ spaces
                  val = val.replace(/\s+(Chest|Length|Waist|Size Guide|Get help|Find your).*/i, '').trim();
              }
              if (val && val.length > 0 && val.length < 60 && !val.includes('₹')) {
                  var key = label.toLowerCase() || val.toLowerCase().substring(0, 5);
                  if (!seenLabels[key]) {
                      seenLabels[key] = true;
                      selectedVariants.push(val);
                  }
              }
          });
          
          // Strategy 2: Twister tiles (mobile Amazon) - look for the selected tile text
          if (selectedVariants.length === 0) {
              var tilesSel = document.querySelectorAll('.twister-mobile-tiles-selected, .twister-tile-selected, .twister-mobile-tile-selected');
              tilesSel.forEach(function(tile) {
                  var t = tile.innerText.trim().split('\n')[0].trim();
                  if (t && !t.includes('₹') && t.length < 50) {
                      selectedVariants.push(t);
                  }
              });
          }
          
          // Strategy 3: Generic "selected" buttons/li with size/colour values
          if (selectedVariants.length === 0) {
              var activeSels = document.querySelectorAll(
                  '.a-button-selected .a-button-text, ' +
                  'li.a-selected span.a-size-base, ' +
                  'li[aria-selected="true"], ' +
                  '.swatchSelect.selected, ' +
                  '.swatchAvailable.selected, ' +
                  '.selection'
              );
              activeSels.forEach(function(el) {
                  var t = el.innerText.trim().split('\n')[0].trim();
                  t = t.split(/\s{2,}/)[0].replace(/\s+(Chest|Length|Waist|Size Guide|Find your).*/i, '').trim();
                  if (t && !t.includes('₹') && t.length < 50 && selectedVariants.indexOf(t) === -1) {
                      selectedVariants.push(t);
                  }
              });
          }

          // Strategy 4: Visible inline "Color: X" or "Size: X" labels on page (last resort)
          // Only take FIRST match per attribute type to avoid picking up all available options
          if (selectedVariants.length === 0) {
              var seen = {};
              var all = document.querySelectorAll('span, div');
              for (var i = 0; i < all.length; i++) {
                  var el = all[i];
                  if (el.children.length > 0) continue;
                  var text = el.innerText.trim().replace(/\n/g, ' ');
                  var m = text.match(/^(Colour|Color|Size|Style)\s*:\s*(.{1,40})$/i);
                  if (m) {
                      var attrKey = m[1].toLowerCase();
                      var val = m[2].trim().split(/\s{2,}/)[0].replace(/\s+(Chest|Length|Size Guide).*/i, '').trim();
                      if (!seen[attrKey] && val && !val.includes('₹')) {
                          seen[attrKey] = true;
                          selectedVariants.push(val);
                      }
                  }
              }
          }
          
          product.variants = selectedVariants.join(', ');
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
          var product = { brand: 'Myntra', url: window.location.href };

          // ── STRATEGY 1: Myntra Gateway API for Title & Image ──
          // (Called within WebView so session cookies are sent - no CORS issue)
          try {
            var url = window.location.href;
            // Extract style ID from URL (e.g. /watches/brand/.../30389309/buy or /30389309)
            var styleId = null;
            var pathM = url.match(/\/(\d{6,10})(?:\/buy)?(?:[?#].*)?$/);
            if (pathM) styleId = pathM[1];
            if (!styleId) {
              var segM = url.match(/\/(\d{7,9})(?:\/|$|\?)/);
              if (segM) styleId = segM[1];
            }

            if (styleId) {
              var xhr = new XMLHttpRequest();
              xhr.open('GET', 'https://www.myntra.com/gateway/v2/product/' + styleId, false);
              xhr.setRequestHeader('Accept', 'application/json');
              xhr.setRequestHeader('x-meta-app', 'appFamily=msite');
              xhr.send(null);

              if (xhr.status === 200) {
                var data = JSON.parse(xhr.responseText);
                var style = data.style || data.product || data.data || data;

                // Title from API
                var bName = style.brandName || (style.brand && style.brand.name) || '';
                var pName = style.name || '';
                if (pName) product.title = (bName + ' ' + pName).trim();

                // Image from API (recursive search for first myntassets /images/ URL)
                function findImg(obj, depth) {
                  if (!obj || depth > 12) return null;
                  if (typeof obj === 'string') {
                    if (obj.startsWith('http') && obj.includes('myntassets') && obj.includes('/images/') && !obj.includes('logo')) return obj;
                    return null;
                  }
                  if (Array.isArray(obj)) {
                    for (var i = 0; i < obj.length; i++) { var r = findImg(obj[i], depth+1); if (r) return r; }
                    return null;
                  }
                  if (typeof obj !== 'object') return null;
                  for (var k in obj) {
                    if (k === 'reviews' || k === 'relatedProducts' || k === 'similar') continue;
                    var res = findImg(obj[k], depth+1);
                    if (res) return res;
                  }
                  return null;
                }
                var img = findImg(style.media, 0) || findImg(style.styleImages, 0) || findImg(style.images, 0);
                if (img) product.image = img;

                // URL from API
                if (style.landingPageUrl) {
                  product.url = 'https://www.myntra.com/' + style.landingPageUrl.replace(/^\//, '');
                } else {
                  product.url = 'https://www.myntra.com/' + styleId;
                }
              }
            }
          } catch(e) {}

          // ── STRATEGY 2: Price from raw DOM text (Primary - most reliable) ──
          // Handles TWO cases:
          //   Case A (Discounted): "MRP ₹5,400 ₹2,538 53% OFF!" → selling price = ₹2,538
          //   Case B (Full Price):  "MRP ₹1,799"  (no discount badge) → selling price = ₹1,799
          try {
            var rawText = document.body.innerText.replace(/\n/g, ' ');

            // Case A: Discounted product - look for "MRP price1 price2 X% OFF" pattern
            // The "X% OFF" badge MUST be present within 30 chars of price2 to confirm it's a real discount
            var discReg = /mrp\s*(?:rs\.?|inr|[\u20b9₹])?\s*([0-9]{1,3}(?:,[0-9]{3})*)\s*(?:rs\.?|inr|[\u20b9₹])?\s*([0-9]{1,3}(?:,[0-9]{3})*)\s*[0-9]+%\s*off/i;
            var md = rawText.match(discReg);
            if (md) {
              var mrpV = parseInt(md[1].replace(/,/g, ''), 10);
              var sellV = parseInt(md[2].replace(/,/g, ''), 10);
              if (sellV > 50 && sellV < mrpV) {
                product.price = String(sellV);
              }
            }

            // Case B: Non-discounted - just MRP shown, use it as the selling price
            if (!product.price) {
              var mrpReg = /mrp\s*(?:rs\.?|inr|[\u20b9₹])?\s*([0-9]{1,3}(?:,[0-9]{3})*)/i;
              var mm = rawText.match(mrpReg);
              if (mm) {
                var mrpPrice = parseInt(mm[1].replace(/,/g, ''), 10);
                if (mrpPrice > 50) product.price = String(mrpPrice);
              }
            }
          } catch(e) {}

          // Price last-resort: first ₹ price on page
          if (!product.price) {
            try {
              var rawText2 = document.body.innerText.replace(/\n/g, ' ');
              var m2 = rawText2.match(/[\u20b9₹]\s*([1-9][0-9,]{2,8})/i);
              if (m2) product.price = String(parseInt(m2[1].replace(/,/g, ''), 10));
            } catch(e) {}
          }

          // Title fallback (if API didn't work)
          if (!product.title || product.title.length < 3) {
            try {
              var dTitle = document.title || '';
              product.title = dTitle.replace(/^Buy\s+/i, '').replace(/\|\s*Myntra.*$/i, '').trim();
            } catch(e) {}
          }

          // ── STRATEGY 3: Variants ──
          try {
            var variants = [];
            var sEls = document.querySelectorAll('button, li');
            for (var v = 0; v < sEls.length; v++) {
              var sb = sEls[v];
              var cls = (sb.className || '').toLowerCase();
              if (cls.includes('active') || cls.includes('selected') || sb.getAttribute('aria-selected') === 'true') {
                var stxt = (sb.innerText || '').trim();
                if (stxt.match(/^([0-9]{1,3}|XS|S|M|L|XL|XXL|XXXL|One Size|Free Size)$/i)) {
                  variants.push('Size: ' + stxt);
                  break;
                }
              }
            }
            // Also try colour
            var colBtn = document.querySelector('[class*="colour"][class*="select"], [class*="color"][class*="select"], [aria-selected="true"][class*="colour"]');
            if (colBtn) {
              var colTxt = (colBtn.innerText || colBtn.getAttribute('title') || '').trim();
              if (colTxt && colTxt.length < 20) variants.push('Colour: ' + colTxt);
            }
            product.variants = variants.join(', ');
          } catch(e) {}

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

          // ─── 1. TITLE ───────────────────────────────────────────────────
          var titleEl = document.querySelector('.pip-header-section__title--big') ||
                        document.querySelector('h1.pip-header-section__title--big') ||
                        document.querySelector('[class*="pip-header"] h1') ||
                        document.querySelector('h1');
          var descEl = document.querySelector('.pip-header-section__description') ||
                       document.querySelector('[class*="pip-header"] [class*="description"]');
          var title = titleEl ? titleEl.innerText.trim() : '';
          if (descEl && descEl.innerText.trim()) title += ' ' + descEl.innerText.trim();
          if (!title) {
            var ogT = document.querySelector('meta[property="og:title"]');
            title = ogT ? ogT.content : document.title;
          }
          product.title = title.replace(/\s*-\s*IKEA.*/i, '').trim();

          // ─── 2. PRICE ───────────────────────────────────────────────────
          var price = '';

          // 1. Classic IKEA CSS classes & test IDs
          var selectors = [
            'span.pip-temp-lugg-price__integer',
            'span.pip-price__integer',
            '.pip-temp-lugg-price__integer',
            '.pip-price__integer',
            '.pip-price__sr-text',
            '.pip-temp-lugg-price',
            '.pip-price',
            '.pip-price-module__price',
            '.pip-price-module__integer',
            '[class*="pip-price-module__price"]',
            '[class*="pip-price-module__integer"]',
            '.pip-price-package__main-price',
            '[class*="price-package__main"]',
            '[data-testid="pip-price-module__price"]',
            '[data-testid="regular-price-value"]',
            '[data-testid*="regular-price"]',
            '[data-testid="pip-price"]'
          ];
          for (var si = 0; si < selectors.length; si++) {
            var el = document.querySelector(selectors[si]);
            if (el) {
              var txt = (el.innerText || el.textContent || '').trim();
              var numMatch = txt.match(/(?:Rs\.?|\u20b9)?\s*([0-9][0-9,\s]{1,})/i);
              if (numMatch) {
                var pClean = numMatch[1].replace(/[^0-9]/g, '');
                if (pClean && parseInt(pClean, 10) > 0) {
                  price = pClean;
                  break;
                }
              }
            }
          }

          // 2. Open Graph & Product Meta Tags
          if (!price) {
            var ogP = document.querySelector('meta[property="product:price:amount"]') ||
                      document.querySelector('meta[property="og:price:amount"]');
            if (ogP && ogP.content) {
              price = ogP.content.replace(/[^0-9]/g, '');
            }
          }

          // 3. JSON-LD structured data
          if (!price) {
            try {
              var ldEls = document.querySelectorAll('script[type="application/ld+json"]');
              for (var j = 0; j < ldEls.length; j++) {
                var ld = JSON.parse(ldEls[j].textContent || '{}');
                var ldP = (ld.offers && ld.offers.price) ||
                          (ld.offers && ld.offers[0] && ld.offers[0].price) || ld.price;
                if (ldP) {
                  price = String(ldP).replace(/[^0-9]/g, '');
                  if (price) break;
                }
              }
            } catch(e) {}
          }

          // 4. Tealium / dataLayer / ecommerce analytics objects
          if (!price) {
            try {
              if (window.utag_data) {
                var ud = window.utag_data;
                var udPrice = ud.product_price_sale || ud.product_special_price ||
                              ud.product_price || ud.sale_price || ud.price;
                if (udPrice) price = String(udPrice).replace(/[^0-9]/g, '');
              }
            } catch(e) {}
          }

          // 5. Global scan for largest font-size element with Rs. / ₹ / INR
          if (!price) {
            var allEls = document.querySelectorAll('*');
            var maxFs = 0;
            for (var ae = 0; ae < Math.min(allEls.length, 600); ae++) {
              var curr = allEls[ae];
              if (curr.children && curr.children.length > 2) continue;
              var cTxt = (curr.innerText || curr.textContent || '').trim();
              if (!cTxt || cTxt.length > 40) continue;
              var cMatch = cTxt.match(/(?:Rs\.?|\u20b9|INR)\s*([0-9,]+)/i);
              if (cMatch) {
                var cStyle = window.getComputedStyle(curr);
                if (cStyle.textDecoration && cStyle.textDecoration.includes('line-through')) continue;
                var cCls = (curr.className || '') + ' ' + (curr.parentElement ? curr.parentElement.className || '' : '');
                if (cCls.toLowerCase().includes('off') || cCls.toLowerCase().includes('save') || cCls.toLowerCase().includes('discount')) continue;
                var fs = parseInt(cStyle.fontSize, 10) || 0;
                if (fs > maxFs) {
                  maxFs = fs;
                  price = cMatch[1].replace(/[^0-9]/g, '');
                }
              }
            }
          }

          // 6. Body text regex fallback
          if (!price) {
            try {
              var bodyTxt = document.body ? (document.body.innerText || document.body.textContent || '') : '';
              var bM = bodyTxt.match(/(?:Rs\.?|\u20b9)\s*([0-9][0-9,]{2,})/i);
              if (bM) price = bM[1].replace(/[^0-9]/g, '');
            } catch(e) {}
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
    } else if (currentUrl.contains('snitch.com')) {
      return r'''
        (function() {
          var product = {};

          // 1. SHOPIFY NATIVE PRODUCT DATA (most reliable)
          try {
            var meta = window.ShopifyAnalytics && window.ShopifyAnalytics.meta && window.ShopifyAnalytics.meta.product;
            if (meta) {
              product.title = (meta.vendor ? meta.vendor + ' ' : '') + (meta.title || '');
              product.brand = 'Snitch';
              // price from selected variant
              var selVar = null;
              if (meta.variants && meta.variants.length > 0) {
                selVar = meta.variants[0];
                if (window.__st && window.__st.v) {
                  var selVarId = window.__st.v;
                  for (var vi = 0; vi < meta.variants.length; vi++) {
                    if (meta.variants[vi].id == selVarId) { selVar = meta.variants[vi]; break; }
                  }
                }
              }
              if (selVar && selVar.price) {
                product.price = Math.round(selVar.price / 100).toString();
              }
              // variants
              var varParts = [];
              if (selVar) {
                if (selVar.option1 && selVar.option1 !== 'Default Title') varParts.push(selVar.option1);
                if (selVar.option2 && selVar.option2 !== 'Default Title') varParts.push(selVar.option2);
                if (selVar.option3 && selVar.option3 !== 'Default Title') varParts.push(selVar.option3);
              }
              product.variants = varParts.join(', ');
            }
          } catch(_) {}

          // 2. JSON-LD STRUCTURED DATA
          if (!product.title || !product.price) {
            try {
              var scripts = document.querySelectorAll('script[type="application/ld+json"]');
              for (var i = 0; i < scripts.length; i++) {
                var data = JSON.parse(scripts[i].innerText);
                var items = Array.isArray(data) ? data : [data];
                for (var j = 0; j < items.length; j++) {
                  var item = items[j];
                  if (item['@type'] === 'Product' || (item.offers && item.name)) {
                    if (!product.title && item.name) {
                      product.title = item.name;
                    }
                    if (!product.price && item.offers) {
                      var offer = Array.isArray(item.offers) ? item.offers[0] : item.offers;
                      var p = offer.price || offer.lowPrice;
                      if (p) product.price = String(p).replace(/[^0-9]/g, '');
                    }
                    if (!product.image && item.image) {
                      product.image = Array.isArray(item.image) ? item.image[0] : item.image;
                    }
                    break;
                  }
                }
              }
            } catch(_) {}
          }

          // 3. DOM FALLBACK
          if (!product.title) {
            var titleEl = document.querySelector('h1.product__title') ||
                          document.querySelector('.product__title h1') ||
                          document.querySelector('h1.product-title') ||
                          document.querySelector('h1');
            product.title = titleEl ? titleEl.innerText.trim() : document.title.replace(/- Snitch.*/i, '').trim();
          }

          if (!product.price) {
            var priceEl = document.querySelector('.price-item--sale') ||
                          document.querySelector('.price-item--regular') ||
                          document.querySelector('[class*="price-item"]') ||
                          document.querySelector('.product__price') ||
                          document.querySelector('[class*="product-price"]');
            if (priceEl) {
              var m = priceEl.innerText.match(/(?:Rs\.?|₹|INR)\s*([0-9,]+)/i) || priceEl.innerText.match(/([0-9,]{3,})/);
              if (m) product.price = m[1].replace(/[^0-9]/g, '');
            }
          }
          if (!product.price) {
            var ogPrice = document.querySelector('meta[property="product:price:amount"]') || document.querySelector('meta[property="og:price:amount"]');
            if (ogPrice && ogPrice.content) product.price = ogPrice.content.replace(/[^0-9]/g, '');
          }

          if (!product.variants) {
            var variants = [];
            var colorEl = document.querySelector('[class*="swatch"][class*="active"], [class*="color"][class*="selected"], [class*="colour"][class*="active"]');
            if (colorEl) {
              var c = colorEl.getAttribute('data-value') || colorEl.getAttribute('title') || colorEl.innerText.trim();
              if (c) variants.push('Colour: ' + c.split('\n')[0].trim());
            }
            var sizeEl = document.querySelector('[class*="size"][class*="active"], [class*="size"][aria-pressed="true"], button[class*="size"][class*="selected"]');
            if (!sizeEl) {
              sizeEl = document.querySelector('input[name*="size"]:checked + label, .variant-button--active');
            }
            if (sizeEl) {
              var s = sizeEl.getAttribute('data-value') || sizeEl.innerText.trim();
              if (s && s.length < 15) variants.push('Size: ' + s);
            }
            product.variants = variants.join(', ');
          }

          if (!product.image) {
            var ogImage = document.querySelector('meta[property="og:image"]');
            product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          }
          if (!product.image) {
            var imgEl = document.querySelector('.product__media img') ||
                        document.querySelector('.product-single__photo img') ||
                        document.querySelector('[class*="product-image"] img') ||
                        document.querySelector('img[src*="snitch"]');
            if (imgEl) product.image = imgEl.src;
          }

          product.url = window.location.href;
          if (!product.brand) product.brand = 'Snitch';
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('thehouseofrare.com')) {
      return r'''
        (function() {
          var product = {};

          // 1. SHOPIFY NATIVE PRODUCT DATA (most reliable)
          try {
            var meta = window.ShopifyAnalytics && window.ShopifyAnalytics.meta && window.ShopifyAnalytics.meta.product;
            if (meta) {
              product.title = (meta.vendor ? meta.vendor + ' ' : '') + (meta.title || '');
              product.brand = 'Rare Rabbit';
              var selVar = null;
              if (meta.variants && meta.variants.length > 0) {
                selVar = meta.variants[0];
                if (window.__st && window.__st.v) {
                  var selVarId = window.__st.v;
                  for (var vi = 0; vi < meta.variants.length; vi++) {
                    if (meta.variants[vi].id == selVarId) { selVar = meta.variants[vi]; break; }
                  }
                }
              }
              if (selVar && selVar.price) {
                product.price = Math.round(selVar.price / 100).toString();
              }
              var varParts = [];
              if (selVar) {
                if (selVar.option1 && selVar.option1 !== 'Default Title') varParts.push(selVar.option1);
                if (selVar.option2 && selVar.option2 !== 'Default Title') varParts.push(selVar.option2);
                if (selVar.option3 && selVar.option3 !== 'Default Title') varParts.push(selVar.option3);
              }
              product.variants = varParts.join(', ');
            }
          } catch(_) {}

          // 2. JSON-LD STRUCTURED DATA
          if (!product.title || !product.price) {
            try {
              var scripts = document.querySelectorAll('script[type="application/ld+json"]');
              for (var i = 0; i < scripts.length; i++) {
                var data = JSON.parse(scripts[i].innerText);
                var items = Array.isArray(data) ? data : [data];
                for (var j = 0; j < items.length; j++) {
                  var item = items[j];
                  if (item['@type'] === 'Product' || (item.offers && item.name)) {
                    if (!product.title && item.name) product.title = item.name;
                    if (!product.price && item.offers) {
                      var offer = Array.isArray(item.offers) ? item.offers[0] : item.offers;
                      var p = offer.price || offer.lowPrice;
                      if (p) product.price = String(p).replace(/[^0-9]/g, '');
                    }
                    if (!product.image && item.image) {
                      product.image = Array.isArray(item.image) ? item.image[0] : item.image;
                    }
                    break;
                  }
                }
              }
            } catch(_) {}
          }

          // 3. DOM FALLBACK
          if (!product.title) {
            var titleEl = document.querySelector('h1.product__title') ||
                          document.querySelector('.product__title h1') ||
                          document.querySelector('h1.product-title') ||
                          document.querySelector('h1');
            product.title = titleEl ? titleEl.innerText.trim() : document.title.replace(/- Rare Rabbit.*/i, '').replace(/- The House of Rare.*/i, '').trim();
          }

          if (!product.price) {
            var priceEl = document.querySelector('.price-item--sale') ||
                          document.querySelector('.price-item--regular') ||
                          document.querySelector('[class*="price-item"]') ||
                          document.querySelector('.product__price') ||
                          document.querySelector('[class*="product-price"]');
            if (priceEl) {
              var m = priceEl.innerText.match(/(?:Rs\.?|₹|INR)\s*([0-9,]+)/i) || priceEl.innerText.match(/([0-9,]{3,})/);
              if (m) product.price = m[1].replace(/[^0-9]/g, '');
            }
          }
          if (!product.price) {
            var ogPrice = document.querySelector('meta[property="product:price:amount"]') || document.querySelector('meta[property="og:price:amount"]');
            if (ogPrice && ogPrice.content) product.price = ogPrice.content.replace(/[^0-9]/g, '');
          }

          if (!product.variants) {
            var variants = [];
            var colorEl = document.querySelector('[class*="swatch"][class*="active"], [class*="color"][class*="selected"], [class*="colour"][class*="active"]');
            if (colorEl) {
              var c = colorEl.getAttribute('data-value') || colorEl.getAttribute('title') || colorEl.innerText.trim();
              if (c) variants.push('Colour: ' + c.split('\n')[0].trim());
            }
            var sizeEl = document.querySelector('[class*="size"][class*="active"], [class*="size"][aria-pressed="true"], button[class*="size"][class*="selected"]');
            if (!sizeEl) {
              sizeEl = document.querySelector('input[name*="size"]:checked + label, .variant-button--active');
            }
            if (sizeEl) {
              var s = sizeEl.getAttribute('data-value') || sizeEl.innerText.trim();
              if (s && s.length < 15) variants.push('Size: ' + s);
            }
            product.variants = variants.join(', ');
          }

          if (!product.image) {
            var ogImage = document.querySelector('meta[property="og:image"]');
            product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          }
          if (!product.image) {
            var imgEl = document.querySelector('.product__media img') ||
                        document.querySelector('.product-single__photo img') ||
                        document.querySelector('[class*="product-image"] img') ||
                        document.querySelector('img[src*="thehouseofrare"]') ||
                        document.querySelector('img[src*="cdn.shopify"]');
            if (imgEl) product.image = imgEl.src;
          }

          product.url = window.location.href;
          if (!product.brand) product.brand = 'Rare Rabbit';
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('lacoste.in')) {
      return r'''
        (function() {
          var product = {};

          // 1. TITLE — try JSON-LD first (most reliable on Magento)
          try {
            var scripts = document.querySelectorAll('script[type="application/ld+json"]');
            for (var i = 0; i < scripts.length; i++) {
              var data = JSON.parse(scripts[i].innerText);
              var items = Array.isArray(data) ? data : [data];
              for (var j = 0; j < items.length; j++) {
                var item = items[j];
                if (item["@type"] === "Product" || (item.offers && item.name)) {
                  if (!product.title && item.name) product.title = item.name;
                  if (!product.price && item.offers) {
                    var offer = Array.isArray(item.offers) ? item.offers[0] : item.offers;
                    var p = offer.price || offer.lowPrice;
                    if (p) product.price = String(p).replace(/[^0-9]/g, "");
                  }
                  if (!product.image && item.image) {
                    product.image = Array.isArray(item.image) ? item.image[0] : item.image;
                  }
                  break;
                }
              }
            }
          } catch(_) {}

          // 2. DOM TITLE fallback
          if (!product.title) {
            var titleEl = document.querySelector("h1.page-title") ||
                          document.querySelector("h1.product-name") ||
                          document.querySelector(".product-info-main h1") ||
                          document.querySelector("h1");
            var title = titleEl ? titleEl.innerText.trim() : document.title;
            title = title.replace(/[|\-]\s*LACOSTE.*/i, "").trim();
            product.title = title;
          }

          // 3. PRICE fallback
          if (!product.price) {
            // Magento uses og:price:amount meta tag reliably
            var ogPrice = document.querySelector('meta[property="product:price:amount"]') ||
                          document.querySelector('meta[property="og:price:amount"]');
            if (ogPrice && ogPrice.content) {
              product.price = ogPrice.content.replace(/[^0-9]/g, "");
            }
          }
          if (!product.price) {
            var priceEl = document.querySelector(".price-box .special-price .price") ||
                          document.querySelector(".price-box .price") ||
                          document.querySelector(".product-info-price .price") ||
                          document.querySelector("[data-price-type=\"finalPrice\"] .price") ||
                          document.querySelector(".final-price .price");
            if (priceEl) {
              var m = priceEl.innerText.match(/(?:₹|Rs\.?|INR)\s*([0-9,]+)/i) || priceEl.innerText.match(/([0-9,]{3,})/);
              if (m) product.price = m[1].replace(/[^0-9]/g, "");
            }
          }
          if (!product.price) {
            var els = document.querySelectorAll("span, div, p, strong, h1, h2, h3");
            var maxFontSize = 0;
            for (var i = 0; i < Math.min(els.length, 300); i++) {
              var text = els[i].innerText ? els[i].innerText.trim() : "";
              var m = text.match(/(?:₹|Rs\.?|INR)\s*([0-9,]+)/i);
              if (m) {
                var style = window.getComputedStyle(els[i]);
                if (style.textDecoration && style.textDecoration.includes("line-through")) continue;
                var cls = (els[i].className || "") + " " + (els[i].parentElement ? els[i].parentElement.className || "" : "");
                if (cls.toLowerCase().includes("old-price") || cls.toLowerCase().includes("mrp") || cls.toLowerCase().includes("strike")) continue;
                var fSize = parseInt(style.fontSize, 10) || 0;
                if (fSize > maxFontSize && fSize > 0) {
                  maxFontSize = fSize;
                  product.price = m[1].replace(/[^0-9]/g, "");
                }
              }
            }
          }

          // 4. VARIANTS (Size & Colour) — Magento swatch pattern
          var variants = [];
          var colorVal = "";
          var sizeVal = "";

          // Selected colour swatch
          var activeColorSwatch = document.querySelector(".swatch-option.color.selected, .swatch-option.color.active, .swatch-opt [option-selected]");
          if (activeColorSwatch) {
            colorVal = activeColorSwatch.getAttribute("aria-label") ||
                       activeColorSwatch.getAttribute("option-label") ||
                       activeColorSwatch.getAttribute("title") ||
                       activeColorSwatch.innerText.trim();
          }
          if (!colorVal) {
            var colorLabel = document.querySelector(".swatch-attribute[attribute-code=\"color\"] .swatch-attribute-selected-option, .swatch-attribute[attribute-code=\"colour\"] .swatch-attribute-selected-option");
            if (colorLabel) colorVal = colorLabel.innerText.trim();
          }

          // Selected size swatch
          var activeSizeSwatch = document.querySelector(".swatch-option.text.selected, .swatch-option.text.active");
          if (activeSizeSwatch) sizeVal = activeSizeSwatch.innerText.trim();
          if (!sizeVal) {
            var sizeLabel = document.querySelector(".swatch-attribute[attribute-code=\"size\"] .swatch-attribute-selected-option");
            if (sizeLabel) sizeVal = sizeLabel.innerText.trim();
          }
          if (!sizeVal) {
            var sizeSelect = document.querySelector("select[name=\"super_attribute[93]\"], select[name*=\"size\"]");
            if (sizeSelect && sizeSelect.selectedIndex >= 0) {
              var selText = sizeSelect.options[sizeSelect.selectedIndex].text.trim();
              if (selText && !selText.toLowerCase().includes("select") && !selText.toLowerCase().includes("choose")) {
                sizeVal = selText;
              }
            }
          }

          if (colorVal) variants.push("Colour: " + colorVal.split("\n")[0].trim());
          if (sizeVal) variants.push("Size: " + sizeVal.split("\n")[0].trim());
          product.variants = variants.join(", ");

          // 5. IMAGE
          if (!product.image) {
            var ogImage = document.querySelector('meta[property="og:image"]');
            product.image = (ogImage && ogImage.content) ? ogImage.content : "";
          }
          if (!product.image) {
            var imgEl = document.querySelector(".product.media .fotorama__active img") ||
                        document.querySelector(".gallery-placeholder img") ||
                        document.querySelector(".product.media img") ||
                        document.querySelector("img[src*=\"lacoste\"]");
            if (imgEl) product.image = imgEl.src;
          }

          product.url = window.location.href;
          product.brand = "Lacoste";
          return JSON.stringify(product);
        })();
      ''';
    } else if (currentUrl.contains('thebearhouse.com')) {
      return r'''
        (function() {
          var product = {};

          // 1. SHOPIFY NATIVE PRODUCT DATA (most reliable)
          try {
            var meta = window.ShopifyAnalytics && window.ShopifyAnalytics.meta && window.ShopifyAnalytics.meta.product;
            if (meta) {
              product.title = (meta.vendor ? meta.vendor + ' ' : '') + (meta.title || '');
              product.brand = 'The Bear House';
              var selVar = null;
              if (meta.variants && meta.variants.length > 0) {
                selVar = meta.variants[0];
                if (window.__st && window.__st.v) {
                  var selVarId = window.__st.v;
                  for (var vi = 0; vi < meta.variants.length; vi++) {
                    if (meta.variants[vi].id == selVarId) { selVar = meta.variants[vi]; break; }
                  }
                }
              }
              if (selVar && selVar.price) {
                product.price = Math.round(selVar.price / 100).toString();
              }
              var varParts = [];
              if (selVar) {
                if (selVar.option1 && selVar.option1 !== 'Default Title') varParts.push(selVar.option1);
                if (selVar.option2 && selVar.option2 !== 'Default Title') varParts.push(selVar.option2);
                if (selVar.option3 && selVar.option3 !== 'Default Title') varParts.push(selVar.option3);
              }
              product.variants = varParts.join(', ');
            }
          } catch(_) {}

          // 2. JSON-LD STRUCTURED DATA
          if (!product.title || !product.price) {
            try {
              var scripts = document.querySelectorAll('script[type="application/ld+json"]');
              for (var i = 0; i < scripts.length; i++) {
                var data = JSON.parse(scripts[i].innerText);
                var items = Array.isArray(data) ? data : [data];
                for (var j = 0; j < items.length; j++) {
                  var item = items[j];
                  if (item['@type'] === 'Product' || (item.offers && item.name)) {
                    if (!product.title && item.name) product.title = item.name;
                    if (!product.price && item.offers) {
                      var offer = Array.isArray(item.offers) ? item.offers[0] : item.offers;
                      var p = offer.price || offer.lowPrice;
                      if (p) product.price = String(p).replace(/[^0-9]/g, '');
                    }
                    if (!product.image && item.image) {
                      product.image = Array.isArray(item.image) ? item.image[0] : item.image;
                    }
                    break;
                  }
                }
              }
            } catch(_) {}
          }

          // 3. DOM FALLBACK
          if (!product.title) {
            var titleEl = document.querySelector('h1.product__title') ||
                          document.querySelector('.product__title h1') ||
                          document.querySelector('h1.product-title') ||
                          document.querySelector('h1');
            product.title = titleEl ? titleEl.innerText.trim() : document.title.replace(/- The Bear House.*/i, '').trim();
          }

          if (!product.price) {
            var priceEl = document.querySelector('.price-item--sale') ||
                          document.querySelector('.price-item--regular') ||
                          document.querySelector('[class*="price-item"]') ||
                          document.querySelector('.product__price') ||
                          document.querySelector('[class*="product-price"]');
            if (priceEl) {
              var m = priceEl.innerText.match(/(?:Rs\.?|₹|INR)\s*([0-9,]+)/i) || priceEl.innerText.match(/([0-9,]{3,})/);
              if (m) product.price = m[1].replace(/[^0-9]/g, '');
            }
          }
          if (!product.price) {
            var ogPrice = document.querySelector('meta[property="product:price:amount"]') || document.querySelector('meta[property="og:price:amount"]');
            if (ogPrice && ogPrice.content) product.price = ogPrice.content.replace(/[^0-9]/g, '');
          }

          if (!product.variants) {
            var variants = [];
            var colorEl = document.querySelector('[class*="swatch"][class*="active"], [class*="color"][class*="selected"], [class*="colour"][class*="active"]');
            if (colorEl) {
              var c = colorEl.getAttribute('data-value') || colorEl.getAttribute('title') || colorEl.innerText.trim();
              if (c) variants.push('Colour: ' + c.split('\n')[0].trim());
            }
            var sizeEl = document.querySelector('[class*="size"][class*="active"], [class*="size"][aria-pressed="true"], button[class*="size"][class*="selected"]');
            if (!sizeEl) {
              sizeEl = document.querySelector('input[name*="size"]:checked + label, .variant-button--active');
            }
            if (sizeEl) {
              var s = sizeEl.getAttribute('data-value') || sizeEl.innerText.trim();
              if (s && s.length < 15) variants.push('Size: ' + s);
            }
            product.variants = variants.join(', ');
          }

          if (!product.image) {
            var ogImage = document.querySelector('meta[property="og:image"]');
            product.image = (ogImage && ogImage.content) ? ogImage.content : '';
          }
          if (!product.image) {
            var imgEl = document.querySelector('.product__media img') ||
                        document.querySelector('.product-single__photo img') ||
                        document.querySelector('[class*="product-image"] img') ||
                        document.querySelector('img[src*="thebearhouse"]') ||
                        document.querySelector('img[src*="cdn.shopify"]');
            if (imgEl) product.image = imgEl.src;
          }

          product.url = window.location.href;
          if (!product.brand) product.brand = 'The Bear House';
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
          showBackButton: true, 
          titleWidget: Image.asset(
            'assets/kora.png',
            height: 28,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.contactUs);
              },
              icon: Icon(
                Icons.support_agent,
                color: context.color.textDefaultColor,
                size: 28,
              ),
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                int count = 0;
                if (state is CartSuccess) {
                  count = state.cart.totalItemsCount > 0 
                      ? state.cart.totalItemsCount 
                      : state.cart.items.fold(0, (sum, i) => sum + i.qty);
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart_outlined, color: context.color.textDefaultColor),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.ecommerceCart);
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ]),
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: _isDialogShowing,
            child: WebViewWidget(controller: _controller),
          ),
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
                  backgroundColor: context.color.forthColor, // Global theme color
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _scrapeAndShowSizeColourDialog(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: context.color.buttonColor), // Theme icon color
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Order via Kora",
                          style: TextStyle(
                            color: context.color.buttonColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "login not required",
                          style: TextStyle(
                            color: context.color.buttonColor.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
