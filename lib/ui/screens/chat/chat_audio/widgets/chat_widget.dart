// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:eClassify/app/app_theme.dart';
import 'package:eClassify/data/cubits/chat/send_message.dart';
import 'package:eClassify/data/cubits/chat/change_offer_status_cubit.dart';
import 'package:eClassify/data/cubits/chat/load_chat_messages.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/ui/screens/payment/bfs_payment_screen.dart';
import 'package:eClassify/data/repositories/bfs_payment_repository.dart';
import 'package:eClassify/ui/screens/chat/chat_screen.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

part "parts/attachment.part.dart";

part "parts/linkpreview.part.dart";

part "parts/recordmsg.part.dart";

////Please don't make changes without sufficent knowledege in this file. otherwise you will be responsable for it
///
//This will store and ensure that msg is already sent so we don't have to send it again
Set sentMessages = {};

class ChatMessage extends StatefulWidget {
  final int? id;
  final int senderId;
  final int itemOfferId;
  final String? message;
  final String? file;
  final String? audio;
  final String createdAt;
  final String updatedAt;
  final String? messageType;
  final bool? isSentNow;
  final String? type;
  final double? amount;
  final String? offerStatus; // 'A', 'R', 'IP' from API
  final String? itemStatus; // Item status like 'sold out', 'active', etc.

  const ChatMessage(
      {super.key,
      this.id,
      required this.senderId,
      required this.itemOfferId,
      this.message,
      this.file,
      this.audio,
      required this.createdAt,
      required this.updatedAt,
      this.messageType,
      this.isSentNow,
      this.type,
      this.amount,
      this.offerStatus,
      this.itemStatus});

  Map toJson() {
    Map data = {};

    data['key'] = key;
    data['id'] = this.id;
    data['sender_id'] = this.senderId;
    data['item_offer_id'] = this.itemOfferId;
    data['message'] = this.message;
    data['file'] = this.file;
    data['audio'] = this.audio;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_sent_now'] = this.isSentNow;
    data['message_type'] = this.messageType;
    data['type'] = this.type;
    data['amount'] = this.amount;
    data['offer_status'] = this.offerStatus;
    data['item_status'] = this.itemStatus;
    return data;
  }

  factory ChatMessage.fromJson(Map json) {
    var chat = ChatMessage(
        key: json['key'],
        id: json['id'],
        senderId: json['sender_id'],
        itemOfferId: json['item_offer_id'],
        message: json['message'],
        file: json['file'],
        audio: json['audio'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        isSentNow: json['is_sent_now'],
        messageType: json['message_type'],
        type: json['type'],
        amount: json['amount'],
        offerStatus: json['offer_status'],
        itemStatus: json['item_status']);
    return chat;
  }

  @override
  State<ChatMessage> createState() => ChatMessageState();
}

class ChatMessageState extends State<ChatMessage>
    with AutomaticKeepAliveClientMixin {
  bool isChatSent = false;
  bool selectedMessage = false;
  static bool isMounted = false;
  String? link;
  final ValueNotifier _linkAddNotifier = ValueNotifier("");
  String? _offerStatus; // 'A', 'R', or null
  bool _isOfferLoading = false;

  @override
  void initState() {
    if (widget.senderId.toString() == HiveUtils.getUserId() &&
        (widget.isSentNow == true) &&
        isChatSent == false) {
      if (!sentMessages.contains(widget.key)) {
        context.read<SendMessageCubit>().send(
              attachment: widget.file,
              message: widget.message!,
              itemOfferId: widget.itemOfferId,
              audio: widget.audio,
              type: widget.type ?? "N",
              amount: widget.amount,
            );
      }
      sentMessages.add(widget.key);

      isMounted = true;
    }

    super.initState();
  }

  // Helper method to check if item is disabled
  bool _isItemDisabled() {
    if (widget.itemStatus == null) return false;

    final status = widget.itemStatus!.toLowerCase();
    return status == "sold out" ||
        status == "review" ||
        status == "rejected" ||
        status == "inactive" ||
        status == "soft rejected" ||
        status == "permanent rejected";
  }

  bool get _isOffer {
    return widget.type == "O" ||
        (widget.message?.trim().startsWith("Offered:") ?? false);
  }

  String get _offerDisplayAmount {
    if (widget.type == "O") {
      return (Constant.currencyPositionIsLeft
              ? "${Constant.currencySymbol} "
              : "") +
          (widget.amount?.toStringAsFixed(0) ?? '0') +
          (Constant.currencyPositionIsLeft
              ? ""
              : " ${Constant.currencySymbol}");
    }
    String cleanMessage = widget.message?.trim() ?? "";
    String raw = "";
    if (cleanMessage.startsWith("Offered:")) {
      raw = cleanMessage.substring("Offered:".length).trim();
    }

    if (raw.startsWith(Constant.currencySymbol)) {
      raw = raw.substring(Constant.currencySymbol.length).trim();
    } else if (raw.endsWith(Constant.currencySymbol)) {
      raw =
          raw.substring(0, raw.length - Constant.currencySymbol.length).trim();
    }
    return (Constant.currencyPositionIsLeft
            ? "${Constant.currencySymbol} "
            : "") +
        raw +
        (Constant.currencyPositionIsLeft ? "" : " ${Constant.currencySymbol}");
  }

  String _emptyTextIfAttachmentHasNoCustomText() {
    if (widget.file != "") {
      if (widget.message == "[File]") {
        return "";
      } else {
        return widget.message!;
      }
    } else if (widget.message == null) {
      return "";
    } else {
      return widget.message!;
    }
  }

  bool _isLink(String input) {
    ///This will check if text contains link
    final matcher = RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");
    return matcher.hasMatch(input);
  }

  List _replaceLink() {
    //This function will make part of text where link starts. we put invisible charector so we can split it with it
    final linkPattern = RegExp(
        r"(http(s)?:\/\/.)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)");

    ///This is invisible charector [You can replace it with any special charector which generally nobody use]
    const String substringIdentifier = "‎";

    ///This will find and add invisible charector in prefix and suffix
    String splitMapJoin = _emptyTextIfAttachmentHasNoCustomText().splitMapJoin(
      linkPattern,
      onMatch: (match) {
        return substringIdentifier + match.group(0)! + substringIdentifier;
      },
      onNonMatch: (match) {
        return match;
      },
    );
    //finally we split it with invisible charector so it will become list
    return splitMapJoin.split(substringIdentifier);
  }

  List<String> _matchAstric(String data) {
    var pattern = RegExp(r"\*(.*?)\*");

    String mapJoin = data.splitMapJoin(
      pattern,
      onMatch: (p0) {
        return "‎${p0.group(0)!}‎";
      },
      onNonMatch: (p0) {
        return p0;
      },
    );

    return mapJoin.split("‎");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool isDark =
        context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark;

    return BlocListener<ChangeOfferStatusCubit, ChangeOfferStatusState>(
        listener: (context, state) {
          if (state is ChangeOfferStatusInProgress) {
            // You might want to set loading state only if it matches this item
            // But since we don't have ID in progress, maybe show generic loading or ignore
            // Ideally passing ID in progress would be better, but for now:
            // We can't distinguish loading state easily without ID.
            // However, we can set _isOfferLoading = true WHEN we call the function.
          }
          if (state is ChangeOfferStatusSuccess) {
            if (state.chatId == widget.id) {
              setState(() {
                _offerStatus = state.status;
                _isOfferLoading = false;
              });
            }
          }
          if (state is ChangeOfferStatusFailure) {
            if (_isOfferLoading) {
              setState(() {
                _isOfferLoading = false;
              });
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
          }
        },
        child: GestureDetector(
          onLongPress: () {
            selectedMessageId.value = (widget.key as ValueKey).value;
            showDeleteButton.value = true;
          },
          onTap: () {
            selectedMessage = false;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Container(
              alignment: widget.senderId.toString() == HiveUtils.getUserId()
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsetsDirectional.only(
                // top: MediaQuery.of(context).size.height * 0.007,
                end: widget.senderId.toString() == HiveUtils.getUserId()
                    ? 20
                    : 0,
                start: widget.senderId.toString() == HiveUtils.getUserId()
                    ? 0
                    : 20,
              ),
              child: Column(
                crossAxisAlignment:
                    widget.senderId.toString() == HiveUtils.getUserId()
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints:
                        BoxConstraints(maxWidth: context.screenWidth * 0.74),
                    decoration: BoxDecoration(
                        color: _isOffer
                            ? context.color.territoryColor.withOpacity(0.25)
                            : (selectedMessage == true
                                ? (widget.senderId.toString() ==
                                        HiveUtils.getUserId()
                                    ? context.color.territoryColor
                                        .withOpacity(0.45)
                                    : context.color.textLightColor
                                        .withOpacity(0.1))
                                : (widget.senderId.toString() ==
                                        HiveUtils.getUserId()
                                    ? context.color.territoryColor
                                        .withOpacity(0.3)
                                    : context.color.secondaryColor)),
                        borderRadius: BorderRadius.circular(8)),
                    child: Wrap(
                      runAlignment: WrapAlignment.end,
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            child: _isOffer
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.local_offer,
                                              color:
                                                  context.color.territoryColor,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          CustomText(
                                            "Offer",
                                            color: context.color.territoryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font.small,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      CustomText(
                                        _offerDisplayAmount,
                                        color: context.color.textColorDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font.large,
                                      ),
                                      if (widget.message != null &&
                                          widget.message!.isNotEmpty &&
                                          !widget.message!
                                              .startsWith("Offered:"))
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: CustomText(widget.message!),
                                        ),
                                      if (widget.senderId.toString() !=
                                          HiveUtils.getUserId()) ...[
                                        SizedBox(height: 8),
                                        if (_offerStatus == 'A' ||
                                            widget.offerStatus == 'A')
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check,
                                                    size: 16,
                                                    color: Colors.green),
                                                SizedBox(width: 4),
                                                CustomText("Accepted",
                                                    color: Colors.green,
                                                    fontSize:
                                                        context.font.small),
                                              ],
                                            ),
                                          )
                                        else if (_offerStatus == 'R' ||
                                            widget.offerStatus == 'R')
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.close,
                                                    size: 16,
                                                    color: Colors.red),
                                                SizedBox(width: 4),
                                                CustomText("Rejected",
                                                    color: Colors.red,
                                                    fontSize:
                                                        context.font.small),
                                              ],
                                            ),
                                          )
                                        else
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: _isOfferLoading ||
                                                        widget.id == null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _isOfferLoading =
                                                              true;
                                                        });
                                                        context
                                                            .read<
                                                                ChangeOfferStatusCubit>()
                                                            .changeOfferStatus(
                                                              chatId:
                                                                  widget.id!,
                                                              itemOfferId: widget
                                                                  .itemOfferId,
                                                              status: 'A',
                                                            );
                                                      },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .color.territoryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: _isOfferLoading
                                                      ? SizedBox(
                                                          width: 12,
                                                          height: 12,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ))
                                                      : CustomText("Accept",
                                                          color: Colors.white,
                                                          fontSize: context
                                                              .font.small),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              InkWell(
                                                onTap: _isOfferLoading ||
                                                        widget.id == null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _isOfferLoading =
                                                              true;
                                                        });
                                                        context
                                                            .read<
                                                                ChangeOfferStatusCubit>()
                                                            .changeOfferStatus(
                                                              chatId:
                                                                  widget.id!,
                                                              itemOfferId: widget
                                                                  .itemOfferId,
                                                              status: 'R',
                                                            );
                                                      },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    border: Border.all(
                                                        color: Colors.red),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: CustomText("Reject",
                                                      color: Colors.red,
                                                      fontSize:
                                                          context.font.small),
                                                ),
                                              ),
                                            ],
                                          )
                                      ],
                                      // Buyer sees "Pay Now" when offer is accepted
                                      if (widget.senderId.toString() ==
                                          HiveUtils.getUserId()) ...[
                                        if (_offerStatus == 'A' ||
                                            widget.offerStatus == 'A') ...[
                                          SizedBox(height: 8),
                                          InkWell(
                                            onTap: _isItemDisabled()
                                                ? null
                                                : () {
                                                    // Navigate to BFS payment screen for offer
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            BfsPaymentScreen(
                                                          paymentType:
                                                              BfsPaymentType
                                                                  .offer,
                                                          offerId: widget
                                                              .itemOfferId
                                                              .toString(),
                                                          price: widget
                                                                  .amount ??
                                                              double.tryParse(
                                                                  _offerDisplayAmount
                                                                      .replaceAll(
                                                                          RegExp(
                                                                              r'[^\d.]'),
                                                                          '')) ??
                                                              0.0,
                                                          packageName:
                                                              "Offer Payment",
                                                        ),
                                                      ),
                                                    ).then((result) {
                                                      if (result == true) {
                                                        // Reload chat messages to show updated payment status
                                                        final loadChatCubit =
                                                            context.read<
                                                                LoadChatMessagesCubit>();
                                                        loadChatCubit.load(
                                                          itemOfferId: widget
                                                              .itemOfferId,
                                                        );

                                                        HelperUtils
                                                            .showSnackBarMessage(
                                                                context,
                                                                "Payment Successful!",
                                                                type: MessageType
                                                                    .success);
                                                      }
                                                    });
                                                  },
                                            child: Opacity(
                                              opacity:
                                                  _isItemDisabled() ? 0.5 : 1.0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: _isItemDisabled()
                                                      ? Colors.grey
                                                      : Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.payment,
                                                        size: 16,
                                                        color: Colors.white),
                                                    SizedBox(width: 4),
                                                    CustomText("Pay Now",
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            context.font.small),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ] else if (_offerStatus == 'R' ||
                                            widget.offerStatus == 'R') ...[
                                          SizedBox(height: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: CustomText("Offer Rejected",
                                                color: Colors.red,
                                                fontSize: context.font.small),
                                          ),
                                        ]
                                      ]
                                    ],
                                  )
                                : widget.audio != ""
                                    ? RecordMessage(
                                        url: widget.audio ?? "",
                                        isSentByMe:
                                            widget.senderId.toString() ==
                                                HiveUtils.getUserId(),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (widget.file != "")
                                            AttachmentMessage(
                                                url: widget.file!),

                                          //This is preview builder for image
                                          ValueListenableBuilder(
                                              valueListenable: _linkAddNotifier,
                                              builder:
                                                  (context, dynamic value, c) {
                                                if (value == null) {
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                return FutureBuilder(
                                                  future: AnyLinkPreview
                                                      .getMetadata(link: value),
                                                  builder: (context,
                                                      AsyncSnapshot snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      if (snapshot.data ==
                                                          null) {
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                      return LinkPreviw(
                                                        snapshot: snapshot,
                                                        link: value,
                                                      );
                                                    }
                                                    return const SizedBox
                                                        .shrink();
                                                  },
                                                );
                                              }),
                                          SelectableText.rich(
                                            TextSpan(
                                              style: TextStyle(
                                                  color: (isDark &&
                                                          widget.senderId
                                                                  .toString() !=
                                                              HiveUtils
                                                                  .getUserId())
                                                      ? context
                                                          .color.buttonColor
                                                      : context.color
                                                          .textDefaultColor),
                                              children:
                                                  _replaceLink().map((data) {
                                                //This will add link to msg
                                                if (_isLink(data)) {
                                                  //This will notify priview object that it has link
                                                  _linkAddNotifier.value = data;
                                                  _linkAddNotifier
                                                      .notifyListeners();

                                                  return TextSpan(
                                                      text: data,
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () async {
                                                              await launchUrl(
                                                                  Uri.parse(
                                                                      data));
                                                            },
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color: Colors
                                                              .blue[800]));
                                                }
                                                //This will make text bold
                                                return TextSpan(
                                                  text: "",
                                                  children: _matchAstric(data)
                                                      .map((text) {
                                                    if (text
                                                            .toString()
                                                            .startsWith("*") &&
                                                        text
                                                            .toString()
                                                            .endsWith("*")) {
                                                      return TextSpan(
                                                          text: text.replaceAll(
                                                              "*", ""),
                                                          style: TextStyle(
                                                              color: (isDark &&
                                                                      widget.senderId
                                                                              .toString() !=
                                                                          HiveUtils
                                                                              .getUserId())
                                                                  ? context
                                                                      .color
                                                                      .buttonColor
                                                                  : context
                                                                      .color
                                                                      .textDefaultColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800));
                                                    }

                                                    return TextSpan(
                                                        text: text,
                                                        style: TextStyle(
                                                            color: (isDark &&
                                                                    widget.senderId
                                                                            .toString() !=
                                                                        HiveUtils
                                                                            .getUserId())
                                                                ? context.color
                                                                    .buttonColor
                                                                : context.color
                                                                    .textDefaultColor));
                                                  }).toList(),
                                                  style: TextStyle(
                                                      color: widget.senderId
                                                                  .toString() ==
                                                              HiveUtils
                                                                  .getUserId()
                                                          ? context.color
                                                              .secondaryColor
                                                          : context.color
                                                              .textColorDark),
                                                );
                                              }).toList(),
                                            ),
                                            style: TextStyle(
                                                color: (isDark &&
                                                        widget.senderId
                                                                .toString() !=
                                                            HiveUtils
                                                                .getUserId())
                                                    ? context.color.buttonColor
                                                    : context.color
                                                        .textDefaultColor),
                                          ),
                                        ],
                                      ),
                          ),
                        ),
                        if (widget.senderId.toString() !=
                                HiveUtils.getUserId() &&
                            (widget.isSentNow != null
                                ? widget.isSentNow!
                                : widget.createdAt ==
                                    DateTime.now().toString())) ...[
                          BlocConsumer<SendMessageCubit, SendMessageState>(
                            listener: (context, state) {
                              if (state is SendMessageSuccess) {
                                isChatSent = true;

                                WidgetsBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  if (mounted) setState(() {});
                                });
                              }
                              if (state is SendMessageFailed) {
                                HelperUtils.showSnackBarMessage(
                                    context, state.error.toString());
                              }
                            },
                            builder: (context, state) {
                              if (state is SendMessageInProgress) {
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      end: 5.0, bottom: 2),
                                  child: Icon(
                                    Icons.watch_later_outlined,
                                    size: context.font.smaller,
                                    color: context.color.textLightColor,
                                  ),
                                );
                              }

                              if (state is SendMessageFailed) {
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      end: 5.0, bottom: 2),
                                  child: Icon(
                                    Icons.error,
                                    size: context.font.smaller,
                                    color: context.color.primaryColor,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          )
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 3.0),
                    child: CustomText(
                      (DateTime.parse(widget.createdAt))
                          .toLocal()
                          .toIso8601String()
                          .toString()
                          .formatDate(
                            format: "hh:mm aa",
                          ),
                      color: widget.senderId.toString() != HiveUtils.getUserId()
                          ? context.color.textLightColor
                          : context.color.textLightColor,
                      fontSize: context.font.smaller,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
