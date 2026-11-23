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
    _controller
        .runJavaScript(
            "if (document && document.body) document.body.style.pointerEvents = 'none';")
        .catchError((_) {});

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
          _controller
              .runJavaScript(
                  "if (document && document.body) document.body.style.pointerEvents = 'auto';")
              .catchError((_) {});
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

    final String lowerUrl = widget.url.toLowerCase();
    final bool isMeesho = lowerUrl.contains('meesho.com');
    final bool isLacoste = lowerUrl.contains('lacoste.in');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));

    // Only set custom Desktop UA for Lacoste (to satisfy Magento/Varnish 54113 rule).
    // For all other brands (especially Meesho on Akamai Bot Manager),
    // we MUST leave the native platform User-Agent untouched so that
    // TLS fingerprint, WebKit build version, and Client Hints match 100%.
    if (isLacoste) {
      const String desktopUA =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
      _controller.setUserAgent(desktopUA);
    }

    _controller
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
      );

    if (isMeesho) {
      _controller.clearCache();
      _controller.clearLocalStorage();
    }

    if (isLacoste) {
      _controller.loadRequest(
        Uri.parse(widget.url),
        headers: {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      );
    } else {
      _controller.loadRequest(Uri.parse(widget.url));
    }
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
          if (url.includes('/dp/') || url.includes('/gp/product/') || url.includes('/gp/aw/d/') || url.includes('/p/')) return true;
          if (url.includes('myntra.com') && (url.includes('/buy') || /\/[0-9]{5,}/.test(url))) return true;
          if (url.includes('firstcry.com') && url.includes('product-detail')) return true;
          if (url.includes('zara.com') && (url.includes('-p0') || url.includes('.html'))) return true;
          if (url.includes('meesho.com') && (url.includes('/p/') || url.includes('/s/p/'))) return true;

          // 1b. Amazon-specific checks (handles mobile /gp/aw/d/, sponsored /sspa/, /gp/slredirect/, ASINs, and PDP DOM)
          if (url.includes('amazon.') || url.includes('/dp/') || url.includes('/gp/aw/d/')) {
            if (url.includes('/dp/') ||
                url.includes('/gp/product/') ||
                url.includes('/gp/aw/d/') ||
                url.includes('/gp/slredirect/') ||
                url.includes('/sspa/click') ||
                url.includes('/product/') ||
                url.includes('/d/b0') ||
                /\/b0[a-z0-9]{8}/i.test(url)) {
              return true;
            }
            if (document.getElementById('productTitle') ||
                document.getElementById('title') ||
                document.getElementById('add-to-cart-button') ||
                document.getElementById('buy-now-button') ||
                document.getElementById('dp') ||
                document.getElementById('dp-container') ||
                document.getElementById('landingImage') ||
                document.getElementById('main-image') ||
                document.getElementById('corePrice_mobile_feature_div') ||
                document.getElementById('corePriceDisplay_desktop_feature_div') ||
                document.querySelector('#title_feature_div') ||
                document.querySelector('[data-feature-name="title"]') ||
                document.querySelector('input[name="submit.add-to-cart"]')) {
              return true;
            }
          }
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
          var btns = document.querySelectorAll('button, a, input[type="submit"], input[type="button"], div[role="button"], span.a-button-text, [id*="add-to-cart"], [id*="addToCart"], [id*="buy-now"], [id*="buyNow"]');
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
    bool isAmazonProduct = (lowerUrl.contains('amazon.') ||
            lowerUrl.contains('/dp/') ||
            lowerUrl.contains('/gp/aw/d/')) &&
        (lowerUrl.contains('/dp/') ||
            lowerUrl.contains('/gp/product/') ||
            lowerUrl.contains('/gp/aw/d/') ||
            lowerUrl.contains('/gp/slredirect/') ||
            lowerUrl.contains('/sspa/click') ||
            lowerUrl.contains('/product/') ||
            lowerUrl.contains('/d/b0') ||
            RegExp(r'/[bB]0[a-zA-Z0-9]{8}').hasMatch(lowerUrl));
    bool isFlipkartProduct =
        lowerUrl.contains('flipkart.com') && lowerUrl.contains('/p/');
    bool isMyntraProduct = lowerUrl.contains('myntra.com') &&
        (lowerUrl.contains('/buy') || RegExp(r'/[0-9]{5,}').hasMatch(lowerUrl));

    bool isDecathlonProduct =
        lowerUrl.contains('decathlon.in') && lowerUrl.contains('/p/');
    bool isFirstcryProduct = lowerUrl.contains('firstcry.com') &&
        lowerUrl.contains('product-detail');
    bool isIkeaProduct =
        lowerUrl.contains('ikea.com') && lowerUrl.contains('/p/');
    bool isSephoraProduct =
        lowerUrl.contains('sephora.in') && lowerUrl.contains('/product');
    bool isUniqloProduct =
        lowerUrl.contains('uniqlo.com') && lowerUrl.contains('/products');
    bool isZaraProduct = lowerUrl.contains('zara.com') &&
        (lowerUrl.contains('-p0') || lowerUrl.contains('.html'));
    // Lacoste: no URL-based check — detection is handled entirely by the SPA monitor DOM checks
    // (category pages also end in .html on Magento, so DOM detection is the only reliable signal)

    // Snitch, Rare Rabbit, The Bear House, Meesho product URL checks
    bool isSnitchProduct = (lowerUrl.contains('snitch.com') ||
            lowerUrl.contains('snitch.co.in')) &&
        (lowerUrl.contains('/products') || lowerUrl.contains('/product'));
    bool isRareRabbitProduct = lowerUrl.contains('thehouseofrare.com') &&
        (lowerUrl.contains('/products') || lowerUrl.contains('/product'));
    bool isBearHouseProduct = lowerUrl.contains('thebearhouse.com') &&
        (lowerUrl.contains('/products') || lowerUrl.contains('/product'));
    bool isMeeshoProduct = lowerUrl.contains('meesho.com') &&
        (lowerUrl.contains('/p/') || lowerUrl.contains('/s/p/'));

    // Generic fallback for product URLs
    bool isGenericProduct =
        lowerUrl.contains('/products/') || lowerUrl.contains('/product/');

    bool isProduct = isAmazonProduct ||
        isFlipkartProduct ||
        isMyntraProduct ||
        isDecathlonProduct ||
        isFirstcryProduct ||
        isIkeaProduct ||
        isSephoraProduct ||
        isUniqloProduct ||
        isZaraProduct ||
        isSnitchProduct ||
        isRareRabbitProduct ||
        isBearHouseProduct ||
        isMeeshoProduct ||
        isGenericProduct;

    if (isProduct != isProductPage) {
      setState(() {
        isProductPage = isProduct;
      });
    }
  }

  Future<void> _addToCart(
      BuildContext context, Map<String, dynamic> product) async {
    // Allow manual price override from the dialog price field
    final String rawPrice = (product['price'] ?? '').toString().trim();
    double priceNum =
        double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    if (priceNum <= 0) {
      HelperUtils.showSnackBarMessage(context, "Could not detect product price",
          type: MessageType.error);
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
                Text('Adding to Cart...',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );

    final success =
        await context.read<CartCubit>().addScrapedProductToCart(product);
    if (context.mounted) {
      Navigator.of(context).pop(); // hide progress
      if (success) {
        HelperUtils.showSnackBarMessage(context, "Added to Cart successfully",
            type: MessageType.success);
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
        final Object result =
            await _controller.runJavaScriptReturningResult(jsScript);
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
                Text('Extracting details...',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
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
        await Future.delayed(const Duration(milliseconds: 2000));
        product =
            await _runJsScraperWithRetry(jsScript, maxRetries: 4, delayMs: 800);
      } else {
        // iOS: run with fast retry (if attempt 0 has price, returns immediately with 0 delay)
        product =
            await _runJsScraperWithRetry(jsScript, maxRetries: 2, delayMs: 500);
      }
      debugPrint('[SCRAPER RESULT] URL: $currentUrl => product: $product');

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

  void _showShadeSelectionDialog(
      BuildContext context, Map<String, dynamic> product) {
    String detectedShade = '';

    String variantsStr = (product['variants'] ?? '').toString();
    if (variantsStr.isNotEmpty) {
      RegExp shadeRegex =
          RegExp(r'(?:Shade|Colour|Color):\s*([^,]+)', caseSensitive: false);
      var match = shadeRegex.firstMatch(variantsStr);
      if (match != null) {
        detectedShade = match.group(1)?.trim() ?? '';
      } else {
        detectedShade = variantsStr.trim();
      }
    }

    final TextEditingController shadeController =
        TextEditingController(text: detectedShade);

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
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.1),
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
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.8),
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
                        hintStyle: TextStyle(
                            fontSize: 14, color: context.color.textLightColor),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: context.color.territoryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOversizedItemNotice(dialogContext),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                  color: context.color.textLightColor
                                      .withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: context.color.textDefaultColor,
                                  fontSize: 15),
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
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
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

  void _showSizeColourSelectionDialog(
      BuildContext context, Map<String, dynamic> product) {
    String detectedSize = '';
    String detectedColour = '';

    String variantsStr = (product['variants'] ?? '').toString();
    if (variantsStr.isNotEmpty) {
      RegExp colorRegex =
          RegExp(r'(?:Colour|Color|Shade):\s*([^,]+)', caseSensitive: false);
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
        List<String> parts =
            variantsStr.split(',').map((e) => e.trim()).toList();
        for (var part in parts) {
          if (RegExp(r'^([0-9]{1,3}|S|M|L|XL|XXL|XXXL|XS|Free Size)$',
                  caseSensitive: false)
              .hasMatch(part)) {
            detectedSize = part;
          } else if (part.isNotEmpty) {
            detectedColour = part;
          }
        }
      }

      if (detectedSize.isNotEmpty) {
        detectedSize = detectedSize.split('\n')[0].split('\r')[0];
        detectedSize = detectedSize
            .replaceAll(
                RegExp(r'\s*(?:Sizing|Size Chart|Get help|Find your size).*$',
                    caseSensitive: false),
                '')
            .trim();
        RegExp multiSizeRegex = RegExp(
            r'^(.+?\b(?:XXS|XS|S|M|L|XL|XXL|XXXL|[0-9]{1,2}))(?:\s+(?:XXS|XS|S|M|L|XL|XXL|XXXL|[0-9]{1,2}))+$',
            caseSensitive: false);
        var match = multiSizeRegex.firstMatch(detectedSize);
        if (match != null) {
          detectedSize = match.group(1)?.trim() ?? detectedSize;
        }
      }
    }

    final TextEditingController sizeController =
        TextEditingController(text: detectedSize);
    final TextEditingController colourController =
        TextEditingController(text: detectedColour);

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
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.1),
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
                    if ((product['title'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        product['title'].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ],
                    if ((product['price'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "₹${product['price']}",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: context.color.territoryColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      "Please specify or confirm your selected size and colour:",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.8),
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
                        hintStyle: TextStyle(
                            fontSize: 14, color: context.color.textLightColor),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: context.color.territoryColor),
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
                        hintStyle: TextStyle(
                            fontSize: 14, color: context.color.textLightColor),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: context.color.territoryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOversizedItemNotice(dialogContext),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                  color: context.color.textLightColor
                                      .withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: context.color.textDefaultColor,
                                  fontSize: 15),
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

                              if (sVal.isNotEmpty &&
                                  product['sizePrices'] != null &&
                                  product['sizePrices'] is Map) {
                                Map sizePrices = product['sizePrices'] as Map;
                                String key = sVal.toUpperCase();
                                if (sizePrices.containsKey(key) &&
                                    sizePrices[key].toString().isNotEmpty) {
                                  double sizeP = double.tryParse(sizePrices[key]
                                          .toString()
                                          .replaceAll(
                                              RegExp(r'[^0-9.]'), '')) ??
                                      0;
                                  double currentP = double.tryParse(
                                          (product['price'] ?? '0')
                                              .toString()
                                              .replaceAll(
                                                  RegExp(r'[^0-9.]'), '')) ??
                                      0;
                                  if (sizeP > 100 &&
                                      (currentP == 0 ||
                                          (sizeP <= currentP * 1.3 &&
                                              sizeP >= currentP * 0.3))) {
                                    product['price'] = sizeP.toStringAsFixed(0);
                                  }
                                }
                              }

                              Navigator.of(dialogContext).pop();

                              _addToCart(context, product);
                            },
                            child: const Text(
                              "Confirm & Import",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
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
                         || document.querySelector('#corePriceDisplay_desktop_feature_div .a-price-whole')
                         || document.querySelector('.a-price .a-offscreen')
                         || document.querySelector('#priceblock_ourprice')
                         || document.querySelector('#priceblock_dealprice');
              if (priceEl) {
                  price = priceEl.innerText;
              } else {
                  var bigPrice = document.querySelector('.a-size-large.a-color-price');
                  if (bigPrice) price = bigPrice.innerText;
              }
          }
          if (price) {
            var pM = price.replace(/,/g, '').match(/([0-9]+(?:\.[0-9]{1,2})?)/);
            if (pM) {
              var pFloat = parseFloat(pM[1]);
              product.price = isFinite(pFloat) && pFloat > 0 ? String(Math.round(pFloat)) : '';
            } else {
              product.price = price.replace(/[^0-9]/g, '');
            }
          } else {
            product.price = '';
          }
          
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

          function cleanNum(val) {
            if (!val) return 0;
            var n = parseInt(String(val).replace(/[^0-9]/g, ''), 10);
            return isNaN(n) ? 0 : n;
          }

          var discountedPrice = null;
          var originalPrice = null;
          var discountedCandidates = [];

          // ── STRATEGY 1: Top On-Screen Banner & DOM Live Element Detection ──
          try {
            // A. Top Sticky/Header Banner [aria-label="mini-product-banner"], #server-widgets_mini-product-banner
            var miniBannerEl = document.querySelector('[aria-label="mini-product-banner"], #server-widgets_mini-product-banner, [id*="mini-product-banner"]');
            if (miniBannerEl) {
              var mbText = miniBannerEl.innerText || '';
              var mbMatches = mbText.match(/[0-9]{1,3}(?:,[0-9]{3})+|[0-9]{3,6}/g) || [];
              var mbNums = [];
              for (var mbi = 0; mbi < mbMatches.length; mbi++) {
                var mbn = cleanNum(mbMatches[mbi]);
                if (mbn > 50) mbNums.push(mbn);
              }
              if (mbNums.length >= 2) {
                mbNums.sort(function(a, b) { return a - b; });
                var bDisc = mbNums[0];
                var bMrp = mbNums[mbNums.length - 1];
                if (bDisc < bMrp) {
                  discountedPrice = bDisc;
                  originalPrice = bMrp;
                  discountedCandidates.unshift(bDisc);
                }
              } else if (mbNums.length === 1) {
                if (!originalPrice) originalPrice = mbNums[0];
              }
            }

            // B. Live container [aria-label="priceinfo_container"] / [aria-label="price_and_timer_container"]
            var pInfo = document.querySelector('[aria-label="priceinfo_container"], [aria-label="price_and_timer_container"]');
            if (pInfo) {
              var mrpEl = pInfo.querySelector('[aria-label="mrp_price"]');
              if (mrpEl) {
                var mV = cleanNum(mrpEl.innerText);
                if (mV > 50) originalPrice = mV;
              }

              // Extract all numbers inside priceinfo_container (e.g. "MRP ₹4,299 ₹1,504 65% OFF")
              var allMatches = (pInfo.innerText || '').match(/[0-9]{1,3}(?:,[0-9]{3})+|[0-9]{3,6}/g) || [];
              for (var mi = 0; mi < allMatches.length; mi++) {
                var cand = cleanNum(allMatches[mi]);
                // Discounted price must be > 50 and strictly less than MRP (if MRP is known)
                if (cand > 50 && (!originalPrice || cand < originalPrice)) {
                  discountedCandidates.push(cand);
                  if (!discountedPrice) discountedPrice = cand;
                }
              }
            }

            // C. Additional DOM elements: .pdp-price, .pdp-selling-price
            var pdpPriceEl = document.querySelector('.pdp-price, .pdp-selling-price');
            if (pdpPriceEl) {
              var pVal = cleanNum(pdpPriceEl.innerText);
              if (pVal > 50 && (!originalPrice || pVal < originalPrice)) {
                discountedCandidates.push(pVal);
                if (!discountedPrice) discountedPrice = pVal;
              }
            }
            var pdpMrpEl = document.querySelector('.pdp-mrp, s, del');
            if (pdpMrpEl && !originalPrice) {
              var mValDom = cleanNum(pdpMrpEl.innerText);
              if (mValDom > 50) originalPrice = mValDom;
            }
          } catch(e) {}

          // ── STRATEGY 2: Redux SSR State (window.__REDUX_STATE__) ──
          try {
            var state = window.__REDUX_STATE__;
            if (!state) {
              var scripts = document.querySelectorAll('script');
              for (var s = 0; s < scripts.length; s++) {
                var scText = scripts[s].textContent || '';
                if (scText.includes('__REDUX_STATE__')) {
                  var sm = scText.match(/window\.__REDUX_STATE__\s*=\s*(\{.*?\});/);
                  if (sm) {
                    try { state = JSON.parse(sm[1]); break; } catch(e) {}
                  }
                }
              }
            }

            if (state) {
              var le = state.layoutEnginev2 || state.layoutEngine || {};
              var pages = le.pages || {};
              for (var pId in pages) {
                var pData = pages[pId];
                if (!pData || !pData.response || !pData.response.page) continue;
                var page = pData.response.page;

                // GTM Meta for title & price
                if (page.pageMeta && page.pageMeta.gtmData) {
                  var gtm = page.pageMeta.gtmData;
                  if (gtm.productDisplayName && !product.title) {
                    product.title = gtm.productDisplayName;
                  }
                  if (gtm.productPrice && !originalPrice) {
                    var gtmMrp = cleanNum(gtm.productPrice);
                    if (gtmMrp > 50) originalPrice = gtmMrp;
                  }
                  if (gtm.productPriceAfterDiscount) {
                    var gtmDisc = cleanNum(gtm.productPriceAfterDiscount);
                    if (gtmDisc > 50 && (!originalPrice || gtmDisc < originalPrice)) {
                      discountedCandidates.push(gtmDisc);
                      if (!discountedPrice) discountedPrice = gtmDisc;
                    }
                  }
                }

                var comps = (page.layout && page.layout.components) || [];
                for (var ci = 0; ci < comps.length; ci++) {
                  var comp = comps[ci];
                  var itemData = comp.itemData || {};

                  // Check mini-product-banner first for on-screen banner pricing
                  if (comp.id === 'mini-product-banner' || itemData.widgetType === 'MINI_PRODUCT_BANNER') {
                    var mbData = itemData.data || {};
                    if (mbData.price) {
                      var mbMrp = cleanNum(mbData.price.mrp);
                      var mbDisc = cleanNum(mbData.price.discounted);
                      if (mbMrp > 50) originalPrice = mbMrp;
                      if (mbDisc > 50 && (!mbMrp || mbDisc < mbMrp)) {
                        discountedPrice = mbDisc;
                        discountedCandidates.unshift(mbDisc);
                      }
                    }
                    if (mbData.name && !product.title) {
                      product.title = mbData.name;
                    }
                    if (mbData.defaultImageUrl && !product.image) {
                      product.image = mbData.defaultImageUrl;
                    }
                    continue;
                  }

                  var cData = itemData.data || {};
                  if (cData.showAD || cData.adText === 'AD') continue;

                  // Title & Brand from PDP_PRODUCT_INFO
                  if (cData.title && !product.title) {
                    var brandName = (cData.brand && (cData.brand.name || cData.brand)) || '';
                    var titleStr = typeof cData.title === 'string' ? cData.title : (cData.title.title || '');
                    if (titleStr) {
                      if (brandName && titleStr.toLowerCase().indexOf(brandName.toLowerCase()) === -1) {
                        product.title = brandName + ' ' + titleStr;
                      } else {
                        product.title = titleStr;
                      }
                    }
                  }

                  // Proper Price info from PDP_PRODUCT_INFO
                  if (cData.priceInfo) {
                    var pi = cData.priceInfo;
                    var disc = pi.discounted != null ? pi.discounted : pi.discountedPrice;
                    var mrp = pi.mrp != null ? pi.mrp : pi.maximumRetailPrice;
                    var dVal = cleanNum(disc);
                    var mVal2 = cleanNum(mrp);
                    if (mVal2 > 50 && !originalPrice) originalPrice = mVal2;
                    if (dVal > 50 && (!originalPrice || dVal < originalPrice)) {
                      discountedCandidates.push(dVal);
                      if (!discountedPrice) discountedPrice = dVal;
                    }
                  }

                  // Image URL
                  if (!product.image) {
                    if (cData.pdpImageURL) {
                      product.image = cData.pdpImageURL;
                    } else if (Array.isArray(cData.allMedia) && cData.allMedia.length > 0) {
                      var m0 = cData.allMedia[0];
                      var src = (m0.image && m0.image.src) || m0.src;
                      if (src) product.image = src;
                    }
                  }

                  // Sizes & SizePrices
                  if (!product.sizePrices) {
                    var skuData = cData.skuData;
                    if (Array.isArray(skuData)) {
                      var sp = {};
                      for (var k = 0; k < skuData.length; k++) {
                        var sku = skuData[k];
                        var sz = (sku.myntraSize || sku.brandSize || sku.value || '').toString().trim().toUpperCase();
                        var szPrice = null;
                        if (Array.isArray(sku.sellersData) && sku.sellersData.length > 0) {
                          szPrice = sku.sellersData[0].discountedPrice || sku.sellersData[0].price;
                        }
                        if (sz && szPrice && Number(szPrice) > 50) {
                          sp[sz] = Number(szPrice);
                        }
                      }
                      if (Object.keys(sp).length > 0) {
                        product.sizePrices = sp;
                      }
                    }
                  }
                }
              }
            }
          } catch(e) {}

          // ── STRATEGY 3: Myntra Gateway API (Backup & Verification) ──
          if (!product.title || !product.image || !discountedPrice) {
            try {
              var url = window.location.href;
              var styleId = null;
              var segM = url.match(/\/(\d{6,10})(?:[/?#]|$)/);
              if (segM) styleId = segM[1];

              if (styleId) {
                var xhr = new XMLHttpRequest();
                xhr.open('GET', 'https://www.myntra.com/gateway/v2/product/' + styleId, false);
                xhr.setRequestHeader('Accept', 'application/json');
                xhr.setRequestHeader('x-meta-app', 'appFamily=msite');
                xhr.send(null);

                if (xhr.status === 200) {
                  var data = JSON.parse(xhr.responseText);
                  var style = data.style || data.product || data.data || data;

                  var regP = style.price != null ? style.price : style.mrp;
                  if (regP && Number(regP) > 50 && !originalPrice) {
                    originalPrice = Number(regP);
                  }

                  // Price from styleOptions
                  var opts = style.styleOptions || style.sizes;
                  if (Array.isArray(opts)) {
                    for (var oi = 0; oi < opts.length; oi++) {
                      var optItem = opts[oi];
                      var optDisc = optItem.discountedPrice != null ? optItem.discountedPrice : (optItem.sellingPrice != null ? optItem.sellingPrice : null);
                      if (optDisc && Number(optDisc) > 50 && (!originalPrice || Number(optDisc) < originalPrice)) {
                        discountedCandidates.push(Number(optDisc));
                        if (!discountedPrice) discountedPrice = Number(optDisc);
                      }
                    }
                  }
                  var stDisc = style.discountedPrice != null ? style.discountedPrice : style.discounted;
                  if (stDisc && Number(stDisc) > 50 && (!originalPrice || Number(stDisc) < originalPrice)) {
                    discountedCandidates.push(Number(stDisc));
                    if (!discountedPrice) discountedPrice = Number(stDisc);
                  }

                  // Title from API
                  if (!product.title) {
                    var bName = (style.brandName || (style.brand && style.brand.name) || '').trim();
                    var pName = (style.name || '').trim();
                    if (pName) {
                      if (bName && pName.toLowerCase().indexOf(bName.toLowerCase()) === 0) {
                        product.title = pName;
                      } else if (bName) {
                        product.title = bName + ' ' + pName;
                      } else {
                        product.title = pName;
                      }
                    }
                  }

                  // Image from API
                  if (!product.image) {
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
                  }

                  if (style.landingPageUrl) {
                    product.url = 'https://www.myntra.com/' + style.landingPageUrl.replace(/^\//, '');
                  }

                  // Sizes / sizePrices from API
                  if (!product.sizePrices && Array.isArray(opts)) {
                    var sp2 = {};
                    for (var o2 = 0; o2 < opts.length; o2++) {
                      var opt2 = opts[o2];
                      var sz2 = (opt2.value || opt2.label || opt2.size || '').toString().trim().toUpperCase();
                      var pr2 = opt2.discountedPrice != null ? opt2.discountedPrice : (opt2.price != null ? opt2.price : opt2.sellingPrice);
                      if (sz2 && pr2 && Number(pr2) > 50) {
                        sp2[sz2] = Number(pr2);
                      }
                    }
                    if (Object.keys(sp2).length > 0) {
                      product.sizePrices = sp2;
                    }
                  }
                }
              }
            } catch(e) {}
          }

          // ── STRATEGY 4: DOM Text Regex Fallback ──
          if (!discountedPrice) {
            try {
              var rawText = document.body.innerText.replace(/[\s\u00a0]+/g, ' ');

              var reg1 = /mrp\s*[:\s]*(?:rs\.?|inr|[\u20b9₹])?\s*([0-9]{1,3}(?:,[0-9]{3})*)\s*(?:rs\.?|inr|[\u20b9₹])?\s*([0-9]{1,3}(?:,[0-9]{3})*)\s*\(?\s*([0-9]+)%\s*off\)?/i;
              var m1 = rawText.match(reg1);
              if (m1) {
                var mrpV1 = cleanNum(m1[1]);
                var sellV1 = cleanNum(m1[2]);
                if (sellV1 > 50 && sellV1 < mrpV1) {
                  discountedPrice = sellV1;
                  if (!originalPrice) originalPrice = mrpV1;
                }
              }

              var reg2 = /(?:rs\.?|inr|[\u20b9₹])?\s*([0-9]{1,3}(?:,[0-9]{3})*)\s*mrp\s*[:\s]*(?:rs\.?|inr|[\u20b9₹])?\s*([0-9]{1,3}(?:,[0-9]{3})*)\s*\(?\s*([0-9]+)%\s*off\)?/i;
              var m2 = rawText.match(reg2);
              if (m2) {
                var sellV2 = cleanNum(m2[1]);
                var mrpV2 = cleanNum(m2[2]);
                if (sellV2 > 50 && sellV2 < mrpV2) {
                  discountedPrice = sellV2;
                  if (!originalPrice) originalPrice = mrpV2;
                }
              }
            } catch(e) {}
          }

          // ── 5. FINAL PRICE SELECTION (PROPER DISCOUNTED PRICE OR ORIGINAL PRICE) ──
          // "I want to take proper discounted price if have or else take original price."
          if (discountedPrice && discountedPrice > 50 && (!originalPrice || discountedPrice < originalPrice)) {
            product.price = String(discountedPrice);
          } else if (discountedCandidates.length > 0) {
            var minDisc = null;
            for (var dci = 0; dci < discountedCandidates.length; dci++) {
              var dc = discountedCandidates[dci];
              if (dc > 50 && (!originalPrice || dc < originalPrice)) {
                if (minDisc === null || dc < minDisc) minDisc = dc;
              }
            }
            if (minDisc) {
              product.price = String(minDisc);
            } else if (originalPrice && originalPrice > 50) {
              product.price = String(originalPrice);
            } else {
              product.price = String(discountedCandidates[0]);
            }
          } else if (originalPrice && originalPrice > 50) {
            product.price = String(originalPrice);
          }

          // ── 6. ACTIVE SELECTED VARIANT CHECK ──
          try {
            var variants = [];
            var sEls = document.querySelectorAll('button, li');
            var selectedSizeVal = null;
            for (var v = 0; v < sEls.length; v++) {
              var sb = sEls[v];
              var cls = (sb.className || '').toLowerCase();
              if (cls.includes('active') || cls.includes('selected') || sb.getAttribute('aria-selected') === 'true') {
                var stxt = (sb.innerText || '').trim();
                if (stxt.match(/^([0-9]{1,3}|XS|S|M|L|XL|XXL|XXXL|One Size|Free Size)$/i)) {
                  selectedSizeVal = stxt.toUpperCase();
                  variants.push('Size: ' + stxt);
                  break;
                }
              }
            }
            var colBtn = document.querySelector('[class*="colour"][class*="select"], [class*="color"][class*="select"], [aria-selected="true"][class*="colour"]');
            if (colBtn) {
              var colTxt = (colBtn.innerText || colBtn.getAttribute('title') || '').trim();
              if (colTxt && colTxt.length < 20) variants.push('Colour: ' + colTxt);
            }
            product.variants = variants.join(', ');

            // If user has a size selected and we have per-size price, use that size's proper discounted price
            if (selectedSizeVal && product.sizePrices && product.sizePrices[selectedSizeVal]) {
              var spVal = product.sizePrices[selectedSizeVal];
              if (spVal && Number(spVal) > 50) {
                product.price = String(spVal);
              }
            }
          } catch(e) {}

          // ── 7. POST-VALIDATION ANTI-MRP SAFEGUARD ──
          if (originalPrice && product.price && cleanNum(product.price) === originalPrice) {
            // If any valid discounted price strictly less than original price exists, use it!
            if (discountedPrice && discountedPrice < originalPrice) {
              product.price = String(discountedPrice);
            } else if (discountedCandidates.length > 0) {
              for (var ci2 = 0; ci2 < discountedCandidates.length; ci2++) {
                var dv = discountedCandidates[ci2];
                if (dv > 50 && dv < originalPrice) {
                  product.price = String(dv);
                  break;
                }
              }
            }
          }

          // ── 8. TITLE & IMAGE FALLBACKS ──
          if (!product.title || product.title.length < 3) {
            try {
              var dTitle = document.title || '';
              product.title = dTitle.replace(/^Buy\s+/i, '').replace(/\|\s*Myntra.*$/i, '').trim();
            } catch(e) {}
          }

          if (!product.image) {
            try {
              var allImgs = document.querySelectorAll('img');
              for (var im = 0; im < allImgs.length; im++) {
                var iEl = allImgs[im];
                if (iEl.closest && iEl.closest('#mini-product-banner, [id*="mini-product"], [class*="banner"]')) continue;
                var iSrc = iEl.src || iEl.getAttribute('data-src') || '';
                if (iSrc && iSrc.includes('myntassets') && iSrc.includes('/assets/images/') && !iSrc.includes('logo')) {
                  product.image = iSrc;
                  break;
                }
              }
            } catch(e) {}
          }

          if (product.image && product.image.includes('($height)')) {
            product.image = product.image.replace('($height)', '1440').replace('($width)', '1080').replace('($qualityPercentage)', '90');
          }

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

          // ── Helper: Safe number parsing for Indian currency formats ───
          // Handles "₹ 2,550.00", "2,550.00", "₹ 1,650.00", "₹4,950", "2550", "495000" (paise)
          function parseIndianPrice(rawStr) {
            if (!rawStr) return 0;
            var str = String(rawStr).trim();
            var m = str.match(/[\u20b9\u0024]?\s*([0-9]{1,3}(?:,[0-9]{2,3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)/);
            if (!m) return 0;
            var clean = m[1].replace(/,/g, '').replace(/\s+/g, '');
            var num = parseFloat(clean);
            if (!isFinite(num) || num <= 0) return 0;
            var rounded = Math.round(num);
            if (rounded > 100000) {
              rounded = Math.round(rounded / 100);
            }
            return rounded;
          }

          // ── Helper: Check if element or any ancestor is struck-out or old price ─
          function isStrikethroughOrOld(el) {
            if (!el) return false;
            var cur = el;
            for (var d = 0; d < 5 && cur && cur !== document.body; d++) {
              if (cur.tagName === 'DEL' || cur.tagName === 'S') return true;
              var cls = (cur.className && typeof cur.className === 'string') ? cur.className.toLowerCase() : '';
              if (cls.includes('old') || cls.includes('original') || cls.includes('strike') || cls.includes('was-price') || cls.includes('undiscounted') || cls.includes('crossed') || cls.includes('line-through')) return true;
              try {
                var cs = window.getComputedStyle(cur);
                if (cs && cs.textDecoration && cs.textDecoration.includes('line-through')) return true;
              } catch(_) {}
              cur = cur.parentElement;
            }
            return false;
          }

          // ── Helper: Check if element or any ancestor is marked as sale/discount ──
          function isSaleOrDiscounted(el) {
            if (!el) return false;
            var cur = el;
            for (var d = 0; d < 5 && cur && cur !== document.body; d++) {
              var cls = (cur.className && typeof cur.className === 'string') ? cur.className.toLowerCase() : '';
              if (cls.includes('sale') || cls.includes('discount') || cls.includes('special') || cls.includes('highlight') || cls.includes('reduced')) return true;
              cur = cur.parentElement;
            }
            return false;
          }

          // ── Helper: Calculate visibility score in viewport ───────────────
          function getViewportScore(el) {
            if (!el) return -10000;
            try {
              var rect = el.getBoundingClientRect();
              if (rect.width === 0 || rect.height === 0) return -10000;
              var cs = window.getComputedStyle(el);
              if (cs.display === 'none' || cs.visibility === 'hidden' || parseFloat(cs.opacity || '1') === 0) return -10000;

              var vh = window.innerHeight || document.documentElement.clientHeight || 800;
              var vw = window.innerWidth || document.documentElement.clientWidth || 400;

              var visibleTop = Math.max(0, rect.top);
              var visibleBottom = Math.min(vh, rect.bottom);
              var visibleHeight = visibleBottom - visibleTop;

              var visibleLeft = Math.max(0, rect.left);
              var visibleRight = Math.min(vw, rect.right);
              var visibleWidth = visibleRight - visibleLeft;

              if (visibleHeight <= 5 || visibleWidth <= 5) return -10000;

              var visibleArea = visibleHeight * visibleWidth;
              var elCenterY = (rect.top + rect.bottom) / 2;
              var distFromCenter = Math.abs(elCenterY - (vh / 2));

              return visibleArea - (distFromCenter * 50);
            } catch(_) {
              return -10000;
            }
          }

          // ═══════════════════════════════════════════════════════════════════
          // 1. PRICE EXTRACTION — 4-tier strategy for Zara India
          //
          // Tier 0: window.__NEXT_DATA__ (Next.js SPA — single product, no noise)
          // Tier 1: JSON-LD structured data (og:price / ld+json)
          // Tier 2: Body-text scan anchored to "MRP INCL" label
          // Tier 3: Broad viewport scan (last resort)
          //
          // Tiers 0 & 1 are immune to related-product card price noise because
          // they read machine-readable metadata for THIS product only.
          // For sale items the minimum of all extracted prices is used.
          // ═══════════════════════════════════════════════════════════════════
          var bestPriceVal = 0;
          var bestPriceEl = null;
          var dbgTier = 'none';
          var dbgInfo = '';

          // helper: convert raw price text or number to rupees integer
          function extractRupeeVal(raw) {
            if (raw === undefined || raw === null) return 0;
            var s = String(raw).replace(/,/g, '').replace(/[\u20b9\u0024\s]/g, '');
            var n = parseFloat(s);
            if (!isFinite(n) || n <= 0) return 0;
            if (n > 100000) n = Math.round(n / 100); // paise → rupees
            return (n >= 100 && n <= 500000) ? Math.round(n) : 0;
          }

          // ══════════════════════════════════════════════════════════════════
          // STRATEGY 1 (PRIMARY): H1-ANCHORED PRICE LOOKUP
          // The product page h1 belongs ONLY to the main product — never to
          // related/recommended cards. Walk UP from h1 to find the containing
          // product-info block, then find the price inside that block.
          // This is completely immune to related-product card noise.
          // ══════════════════════════════════════════════════════════════════
          try {
            var titleEls = document.querySelectorAll(
              'h1, .product-detail-info__header-name, [class*="product-detail-info__header"], [class*="product-detail-info__name"]'
            );
            var mainTitleEl = null;
            for (var ti = 0; ti < titleEls.length; ti++) {
              var tScore = getViewportScore(titleEls[ti]);
              if (tScore > -5000) { mainTitleEl = titleEls[ti]; break; }
            }

            if (mainTitleEl) {
              var hcur = mainTitleEl.parentElement;
              for (var hd = 0; hd < 12 && hcur && hcur !== document.body && bestPriceVal === 0; hd++) {
                // Look for price elements in this ancestor container
                var hPriceEls = hcur.querySelectorAll(
                  '.money-amount__main, [class*="money-amount__main"], ' +
                  '.price-current__amount-item .money-amount, [class*="price-current__amount-item"] .money-amount'
                );
                var hPrices = [];
                for (var hpi = 0; hpi < hPriceEls.length; hpi++) {
                  var hpEl = hPriceEls[hpi];
                  if (hpEl.querySelector('.money-amount__main')) continue; // skip wrappers
                  if (isStrikethroughOrOld(hpEl)) continue; // skip struck-through old prices
                  var hpTxt = (hpEl.innerText || '').trim();
                  var hpVal = extractRupeeVal(hpTxt);
                  if (hpVal > 0) hPrices.push({ el: hpEl, val: hpVal });
                }
                if (hPrices.length > 0) {
                  hPrices.sort(function(a, b) { return a.val - b.val; });
                  bestPriceVal = hPrices[0].val;
                  bestPriceEl = hPrices[0].el;
                  dbgTier = 'h1-anchor-d' + hd;
                }
                hcur = hcur.parentElement;
              }
            }
          } catch(_s1) { dbgInfo += ' s1err:' + _s1; }

          // ══════════════════════════════════════════════════════════════════
          // STRATEGY 2: URL v1/v2 PARAMS → __NEXT_DATA__ EXACT MATCH
          // Extract the color reference (v1) and size reference (v2) from the
          // URL, then navigate __NEXT_DATA__ to find the EXACT product's price.
          // ══════════════════════════════════════════════════════════════════
          if (bestPriceVal === 0) {
            try {
              var urlParams = new URLSearchParams(window.location.search);
              var urlV1 = urlParams.get('v1') || '';
              var urlV2 = urlParams.get('v2') || '';
              var nd = window.__NEXT_DATA__;
              if (nd && urlV1) {
                var pp = nd.props && nd.props.pageProps;
                // Try multiple possible pageProps structures
                var productDetail = (pp && (
                  (pp.product && pp.product.detail) ||
                  pp.product ||
                  pp.productDetail ||
                  pp.pdp
                )) || null;

                var colorsArr = productDetail ? (productDetail.colors || productDetail.detail && productDetail.detail.colors || []) : [];

                for (var ci = 0; ci < colorsArr.length && bestPriceVal === 0; ci++) {
                  var colorObj = colorsArr[ci];
                  var colorRef = String(colorObj.id || colorObj.reference || colorObj.productId || '');
                  // Match if color ref starts with/equals v1
                  if (colorRef !== urlV1 && !colorRef.startsWith(urlV1) && !urlV1.startsWith(colorRef)) continue;

                  var sizesArr = colorObj.sizes || [];
                  for (var si = 0; si < sizesArr.length; si++) {
                    var sizeObj = sizesArr[si];
                    var sizeRef = String(sizeObj.id || sizeObj.reference || sizeObj.sku || '');
                    // If we have v2, match size; otherwise use first size
                    if (urlV2 && sizeRef !== urlV2 && !sizeRef.startsWith(urlV2) && !urlV2.startsWith(sizeRef)) continue;
                    var szPrice = sizeObj.price || sizeObj.salePrice || sizeObj.currentPrice;
                    if (szPrice !== undefined && szPrice !== null) {
                      var szVal = extractRupeeVal(String(szPrice));
                      if (szVal > 0) {
                        bestPriceVal = szVal;
                        dbgTier = 'next-data-v1match';
                        break;
                      }
                    }
                  }
                  // If v2 didn't match anything, try first size
                  if (bestPriceVal === 0 && sizesArr.length > 0) {
                    var fsPrice = sizesArr[0].price || sizesArr[0].salePrice;
                    if (fsPrice !== undefined) {
                      var fsVal = extractRupeeVal(String(fsPrice));
                      if (fsVal > 0) { bestPriceVal = fsVal; dbgTier = 'next-data-first-size'; }
                    }
                  }
                }
              }
            } catch(_s2) { dbgInfo += ' s2err:' + _s2; }
          }

          // ══════════════════════════════════════════════════════════════════
          // STRATEGY 3: MRP INCL DOM-PROXIMITY WALK
          // Find the "MRP INCL" text node and walk UP the DOM for the price
          // in the same container. Sort by viewport score (most visible first).
          // ══════════════════════════════════════════════════════════════════
          if (bestPriceVal === 0) {
            try {
              var mrpEls = [];
              var scanEls = document.querySelectorAll('p, span, div, li, small');
              for (var ai = 0; ai < scanEls.length; ai++) {
                var aEl = scanEls[ai];
                if (aEl.children.length > 2) continue; // skip big containers
                var aTxt = (aEl.innerText || '').trim().toUpperCase();
                if (!aTxt.startsWith('MRP') || !aTxt.includes('INCL') || aTxt.length > 80) continue;
                var aScore = getViewportScore(aEl);
                if (aScore > -5000) mrpEls.push({ el: aEl, score: aScore });
              }
              mrpEls.sort(function(a, b) { return b.score - a.score; });
              dbgInfo += ' mrpCount:' + mrpEls.length;

              for (var mci = 0; mci < mrpEls.length && bestPriceVal === 0; mci++) {
                var mcur = mrpEls[mci].el.parentElement;
                for (var md = 0; md < 8 && mcur && mcur !== document.body; md++) {
                  var mpEls = mcur.querySelectorAll('.money-amount__main, [class*="money-amount__main"]');
                  var mpPrices = [];
                  for (var mpi = 0; mpi < mpEls.length; mpi++) {
                    var mpEl = mpEls[mpi];
                    if (mpEl.querySelector('.money-amount__main')) continue;
                    if (isStrikethroughOrOld(mpEl)) continue;
                    var mpVal = extractRupeeVal((mpEl.innerText || '').trim());
                    if (mpVal > 0) mpPrices.push({ el: mpEl, val: mpVal });
                  }
                  if (mpPrices.length > 0) {
                    mpPrices.sort(function(a, b) { return a.val - b.val; });
                    bestPriceVal = mpPrices[0].val;
                    bestPriceEl = mpPrices[0].el;
                    dbgTier = 'mrp-incl-d' + md;
                    break;
                  }
                  mcur = mcur.parentElement;
                }
              }
            } catch(_s3) { dbgInfo += ' s3err:' + _s3; }
          }

          // ══════════════════════════════════════════════════════════════════
          // STRATEGY 4: JSON-LD structured data
          // ══════════════════════════════════════════════════════════════════
          if (bestPriceVal === 0) {
            try {
              var ldScripts = document.querySelectorAll('script[type="application/ld+json"]');
              var ldPrices = [];
              for (var li = 0; li < ldScripts.length; li++) {
                try {
                  var ldJ = JSON.parse(ldScripts[li].textContent || '{}');
                  var ldItems = Array.isArray(ldJ['@graph']) ? ldJ['@graph'] : [ldJ];
                  for (var lj = 0; lj < ldItems.length; lj++) {
                    var ldOffers = ldItems[lj].offers || ldItems[lj].Offers;
                    if (!ldOffers) continue;
                    var ldList = Array.isArray(ldOffers) ? ldOffers : [ldOffers];
                    for (var lok = 0; lok < ldList.length; lok++) {
                      var ldp = ldList[lok].price || ldList[lok].lowPrice;
                      var ldpVal = extractRupeeVal(String(ldp || 0));
                      if (ldpVal > 0) ldPrices.push(ldpVal);
                    }
                  }
                } catch(_lj) {}
              }
              if (ldPrices.length > 0) {
                ldPrices.sort(function(a, b) { return a - b; });
                bestPriceVal = ldPrices[0];
                dbgTier = 'json-ld';
              }
            } catch(_s4) {}
          }

          // ══════════════════════════════════════════════════════════════════
          // STRATEGY 5: og:price:amount meta
          // ══════════════════════════════════════════════════════════════════
          if (bestPriceVal === 0) {
            try {
              var ogEl = document.querySelector('meta[property="og:price:amount"], meta[name="og:price:amount"]');
              if (ogEl && ogEl.content) {
                var ogVal = extractRupeeVal(ogEl.content);
                if (ogVal > 0) { bestPriceVal = ogVal; dbgTier = 'og-meta'; }
              }
            } catch(_s5) {}
          }

          if (bestPriceVal > 50) price = String(bestPriceVal);
          product.price = price;
          product._dbg = dbgTier + dbgInfo;

          // ═══════════════════════════════════════════════════════════════════
          // 2. TITLE EXTRACTION (VIEWPORT-AWARE)
          // ═══════════════════════════════════════════════════════════════════
          var bestTitle = '';
          var bestTitleScore = -10000;

          if (bestPriceEl) {
            var cur = bestPriceEl;
            for (var depth = 0; depth < 8 && cur && cur !== document.body; depth++) {
              var containerTitles = cur.querySelectorAll('h1, h2, h3, h4, [class*="header-name"], [class*="product-name"], [class*="title"], [class*="name"]');
              for (var ti = 0; ti < containerTitles.length; ti++) {
                var tEl = containerTitles[ti];
                var tTxt = (tEl.innerText || '').trim().replace(/\s*[-–|]\s*ZARA.*$/i, '').trim();
                if (tTxt.length >= 3 && !/MRP|INCL|TAX|SIZE|COLOR|COLOUR|ADD|BUY|NEW/i.test(tTxt)) {
                  bestTitle = tTxt;
                  break;
                }
              }
              if (bestTitle) break;
              cur = cur.parentElement;
            }
          }

          if (!bestTitle) {
            var titleCandidates = document.querySelectorAll(
              'h1, h2, h3, h4, .product-detail-info__header-name, [class*="product-detail-info__name"], [class*="product-name"], [class*="product-detail"] h1, [class*="product-detail"] h2'
            );
            for (var j = 0; j < titleCandidates.length; j++) {
              var tel = titleCandidates[j];
              var tStr = (tel.innerText || '').trim().replace(/\s*[-–|]\s*ZARA.*$/i, '').trim();
              if (tStr.length < 3 || /MRP|INCL|TAX|SIZE|COLOR|COLOUR|ADD|BUY|NEW/i.test(tStr)) continue;

              var tScore = getViewportScore(tel);
              if (tScore > bestTitleScore) {
                bestTitleScore = tScore;
                bestTitle = tStr;
              }
            }
          }

          if (!bestTitle) {
            bestTitle = (document.title || '').replace(/\s*[-–|]\s*ZARA.*$/i, '').trim();
          }

          product.title = bestTitle;

          // ═══════════════════════════════════════════════════════════════════
          // 3. IMAGE EXTRACTION (VIEWPORT-AWARE)
          // ═══════════════════════════════════════════════════════════════════
          var bestImg = '';
          var bestImgScore = -10000;

          if (bestPriceEl) {
            var curImg = bestPriceEl;
            for (var idepth = 0; idepth < 8 && curImg && curImg !== document.body; idepth++) {
              var cImgs = curImg.querySelectorAll('img[src*="zara"], picture img, img');
              for (var ii = 0; ii < cImgs.length; ii++) {
                var iEl = cImgs[ii];
                if (iEl.src && !iEl.src.startsWith('data:') && (iEl.naturalWidth > 100 || iEl.width > 100 || iEl.src.includes('zara.net'))) {
                  bestImg = iEl.src;
                  break;
                }
              }
              if (bestImg) break;
              curImg = curImg.parentElement;
            }
          }

          if (!bestImg) {
            var allImgs = document.querySelectorAll('picture img, img[src*="static.zara.net"], img[src*="zara"], .media-image__image, main img');
            for (var k = 0; k < allImgs.length; k++) {
              var aImg = allImgs[k];
              if (!aImg.src || aImg.src.startsWith('data:')) continue;
              var iScore = getViewportScore(aImg);
              if (iScore > bestImgScore) {
                bestImgScore = iScore;
                bestImg = aImg.src;
              }
            }
          }

          if (!bestImg) {
            var ogImg = document.querySelector('meta[property="og:image"]');
            if (ogImg && ogImg.content) bestImg = ogImg.content;
          }

          product.image = bestImg;

          // ═══════════════════════════════════════════════════════════════════
          // 4. URL & BRAND
          // ═══════════════════════════════════════════════════════════════════
          var directUrl = '';
          if (bestPriceEl) {
            var curLink = bestPriceEl;
            for (var ldepth = 0; ldepth < 8 && curLink && curLink !== document.body; ldepth++) {
              var links = curLink.querySelectorAll('a[href*="-p0"], a[href*=".html"], a[href*="/product/"]');
              for (var li = 0; li < links.length; li++) {
                if (links[li].href) {
                  directUrl = links[li].href;
                  break;
                }
              }
              if (directUrl) break;
              curLink = curLink.parentElement;
            }
          }

          product.url = directUrl || window.location.href;
          product.brand = 'Zara';

          // ═══════════════════════════════════════════════════════════════════
          // 5. VARIANTS (Colour & Size)
          // ═══════════════════════════════════════════════════════════════════
          var variants = [];
          var colorVal = '';
          var sizeVal = '';

          if (bestPriceEl) {
            var curVar = bestPriceEl;
            for (var vdepth = 0; vdepth < 8 && curVar && curVar !== document.body; vdepth++) {
              var colEl = curVar.querySelector('.product-detail-selected-color, [class*="product-detail-color"], [class*="color-selector"], [class*="selected-color"]');
              if (colEl && !colorVal) {
                colorVal = colEl.innerText.trim().split('\n')[0].replace(/\|.*/, '').trim();
              }
              var szEl = curVar.querySelector('[class*="size-selector"] [class*="selected"], [class*="size-selector"] [aria-checked="true"], [data-qa-action="size-selector"] [aria-checked="true"]');
              if (szEl && !sizeVal) {
                sizeVal = szEl.innerText.trim().split('\n')[0];
              }
              if (colorVal && sizeVal) break;
              curVar = curVar.parentElement;
            }
          }

          if (!colorVal) {
            var pageColorEl = document.querySelector('.product-detail-selected-color, [class*="color-selector"] [class*="selected"]');
            if (pageColorEl) colorVal = pageColorEl.innerText.trim().split('\n')[0].replace(/\|.*/, '').trim();
          }
          if (!sizeVal) {
            var pageSizeEl = document.querySelector('[class*="size-selector"] [class*="selected"], [class*="size-selector"] [aria-checked="true"]');
            if (pageSizeEl) sizeVal = pageSizeEl.innerText.trim().split('\n')[0];
          }

          if (!colorVal || !sizeVal) {
            var vSearchArea = (bestPriceEl && bestPriceEl.parentElement && bestPriceEl.parentElement.parentElement) || document.body;
            var vEls = vSearchArea.querySelectorAll('span, div, p, h4, h3, h2, h1');
            for (var vi = 0; vi < Math.min(vEls.length, 200); vi++) {
              var vt = (vEls[vi].innerText || '').trim();
              if (!colorVal) {
                var cm = vt.match(/^(?:Color|Colour)\s*:\s*([^\n\r]+)/i);
                if (cm) colorVal = cm[1].replace(/\|.*/, '').trim();
              }
              if (!sizeVal) {
                var sm = vt.match(/^Size\s*:\s*([^\n\r]+)/i);
                if (sm) sizeVal = sm[1].trim();
              }
            }
          }

          if (colorVal) variants.push('Colour: ' + colorVal);
          if (sizeVal) variants.push('Size: ' + sizeVal);
          product.variants = variants.join(', ');

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
    } else if (currentUrl.contains('meesho.com')) {
      return r'''
        (function() {
          var product = {};

          // 1. NEXT.js INITIAL STATE (Highly reliable for Meesho SSR & hydration data)
          try {
            if (window.__NEXT_DATA__ && window.__NEXT_DATA__.props && window.__NEXT_DATA__.props.pageProps) {
              var init = window.__NEXT_DATA__.props.pageProps.initialState;
              if (init && init.product && init.product.details && init.product.details.data) {
                var pData = init.product.details.data;
                if (pData.name) product.title = pData.name;
                if (pData.price) product.price = String(pData.price).replace(/[^0-9]/g, '');
                if (pData.images && Array.isArray(pData.images) && pData.images.length > 0) {
                  product.image = pData.images[0];
                }
                var vars = [];
                if (pData.variations && Array.isArray(pData.variations) && pData.variations.length > 0) {
                  vars.push('Size: ' + pData.variations[0]);
                }
                if (pData.product_details && pData.product_details.additional_details && pData.product_details.additional_details.attributes) {
                  var attrs = pData.product_details.additional_details.attributes;
                  for (var a = 0; a < attrs.length; a++) {
                    if (attrs[a].field_name === 'color' && attrs[a].value) {
                      vars.push('Colour: ' + attrs[a].value);
                      break;
                    }
                  }
                }
                if (vars.length > 0) product.variants = vars.join(', ');
                product.brand = 'Meesho';
              }
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

          // 3. META TAGS / OPEN GRAPH
          if (!product.title) {
            var ogTitle = document.querySelector('meta[property="og:title"]');
            if (ogTitle && ogTitle.content) product.title = ogTitle.content.trim();
          }
          if (!product.image) {
            var ogImg = document.querySelector('meta[property="og:image"]');
            if (ogImg && ogImg.content) product.image = ogImg.content;
          }

          // 4. DOM SELECTORS FOR TITLE
          if (!product.title) {
            var titleEl = document.querySelector('h1') ||
                          document.querySelector('[class*="ShippingInfo__DetailCard"] h1') ||
                          document.querySelector('[class*="ProductCard"] h1');
            product.title = titleEl ? titleEl.innerText.trim() : document.title.replace(/\| Meesho.*$/i, '').trim();
          }

          // 5. DOM SELECTORS FOR PRICE
          if (!product.price) {
            var priceEl = document.querySelector('[class*="PriceContainer"] h4') ||
                          document.querySelector('[class*="ShippingInfo__PriceRow"] h4') ||
                          document.querySelector('h4');
            if (priceEl && priceEl.innerText && priceEl.innerText.includes('₹')) {
              var pm = priceEl.innerText.match(/₹\s*([0-9,]+)/);
              if (pm) product.price = pm[1].replace(/[^0-9]/g, '');
            }
          }
          if (!product.price) {
            var allEls = document.querySelectorAll('h4, h3, h2, span, p');
            for (var i = 0; i < Math.min(allEls.length, 300); i++) {
              var t = allEls[i].innerText ? allEls[i].innerText.trim() : '';
              if (t.match(/^₹\s*[0-9,]+$/)) {
                product.price = t.replace(/[^0-9]/g, '');
                break;
              }
            }
          }

          // 6. DOM SELECTORS FOR IMAGE
          if (!product.image) {
            var imgEl = document.querySelector('img[data-testid="product-images"]') ||
                        document.querySelector('[class*="ProductDesktopImage"] img') ||
                        document.querySelector('[class*="ProductCard__ProductImage"] img') ||
                        document.querySelector('img[src*="images.meesho.com/images/products"]');
            if (imgEl && imgEl.src) product.image = imgEl.src;
          }

          // 7. DOM SELECTORS FOR VARIANTS (SIZE & COLOR)
          if (!product.variants) {
            var variants = [];
            var selectedSizeEl = document.querySelector('[class*="SizeSelectorChips"] [class*="SingleChip"]') ||
                                 document.querySelector('[class*="SizeSelection"] [class*="SingleChip"]') ||
                                 document.querySelector('[class*="SingleChip"]');
            if (selectedSizeEl) {
              var sText = selectedSizeEl.innerText.trim();
              if (sText) variants.push('Size: ' + sText.split('\n')[0].trim());
            }
            if (variants.length === 0) {
              var chips = document.querySelectorAll('[class*="SingleChip"] span, [class*="SizeSelectorChips"] span');
              if (chips.length > 0) {
                var sText = chips[0].innerText.trim();
                if (sText) variants.push('Size: ' + sText.split('\n')[0].trim());
              }
            }
            var attrRows = document.querySelectorAll('[class*="AdditionalDetailsContainer"], [class*="AttributeCard"]');
            for (var r = 0; r < attrRows.length; r++) {
              var rowText = attrRows[r].innerText || '';
              if (rowText.toLowerCase().includes('color')) {
                var cVal = rowText.replace(/color/i, '').replace(/[:\n\r]/g, ' ').trim();
                if (cVal && cVal.length < 30) {
                  variants.push('Colour: ' + cVal);
                  break;
                }
              }
            }
            product.variants = variants.join(', ');
          }

          product.url = window.location.href;
          product.brand = 'Meesho';
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

  Future<void> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildOversizedItemNotice(BuildContext context,
      {EdgeInsetsGeometry? margin}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withValues(alpha: 0.15)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.4)
              : const Color(0xFFFFD54F),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: isDark ? Colors.amber.shade400 : Colors.amber.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 11,
                  color: context.color.textDefaultColor.withValues(alpha: 0.9),
                  height: 1.35,
                ),
                children: const [
                  TextSpan(
                    text: "Oversized Item Notice: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        "Final shipping costs for heavy or bulky items (furniture, gym gear, etc.) will be communicated separately before dispatch and may differ from the standard cart estimate.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar:
            UiUtils.buildAppBar(context, showBackButton: true, onBackPress: () {
          _handleBackNavigation();
        },
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
                        icon: Icon(Icons.shopping_cart_outlined,
                            color: context.color.textDefaultColor),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOversizedItemNotice(
                        context,
                        margin: const EdgeInsets.only(bottom: 10),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                context.color.forthColor, // Global theme color
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
                              Icon(Icons.shopping_cart_outlined,
                                  color: context
                                      .color.buttonColor), // Theme icon color
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
                                      color: context.color.buttonColor
                                          .withValues(alpha: 0.85),
                                      fontSize: 11,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
