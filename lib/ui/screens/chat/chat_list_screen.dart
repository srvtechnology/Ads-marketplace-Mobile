import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_seller_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/services/pusher_service.dart';
import 'package:eClassify/ui/screens/chat/chatTile.dart';
import 'dart:async';

import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return const ChatListScreen();
      },
    );
  }

  @override
  State<ChatListScreen> createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  ScrollController chatBuyerScreenController = ScrollController();
  ScrollController chatSellerScreenController = ScrollController();
  late TabController _tabController;

  StreamSubscription? _pusherSubscription;

  /// Called from MainActivity when the Chat bottom-nav tab is tapped.
  void refresh() {
    if (!mounted) return;
    if (HiveUtils.isUserAuthenticated()) {
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<GetSellerChatListCubit>().fetch();
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // Refresh the relevant cubit whenever the user switches tabs.
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      if (!mounted) return;
      if (_tabController.index == 0) {
        context.read<GetSellerChatListCubit>().fetch();
      } else {
        context.read<GetBuyerChatListCubit>().fetch();
      }
    });

    if (HiveUtils.isUserAuthenticated()) {
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<GetSellerChatListCubit>().fetch();
      context.read<BlockedUsersListCubit>().blockedUsersList();

      int? currentUserId = int.tryParse(HiveUtils.getUserId() ?? "0");
      if (currentUserId != null) {
        PusherService.init(userId: currentUserId);
        _pusherSubscription = PusherService.eventsStream.listen((data) {
          if (mounted) {
            context.read<GetBuyerChatListCubit>().fetch();
            context.read<GetSellerChatListCubit>().fetch();
          }
        });
      }

      chatBuyerScreenController.addListener(() {
        if (chatBuyerScreenController.isEndReached()) {
          if (context.read<GetBuyerChatListCubit>().hasMoreData()) {
            context.read<GetBuyerChatListCubit>().loadMore();
          }
        }
      });
      chatSellerScreenController.addListener(() {
        if (chatSellerScreenController.isEndReached()) {
          if (context.read<GetSellerChatListCubit>().hasMoreData()) {
            context.read<GetSellerChatListCubit>().loadMore();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _pusherSubscription?.cancel();
    _tabController.dispose();
    chatBuyerScreenController.dispose();
    chatSellerScreenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          appBar: UiUtils.buildAppBar(
            context,
            title: "message".translate(context),
            // bottomHeight: 49,
            bottomHeight: 49,
            actions: [
              InkWell(
                child: UiUtils.getSvg(AppIcons.blockedUserIcon,
                    color: context.color.textDefaultColor),
                onTap: () {
                  Navigator.pushNamed(context, Routes.blockedUserListScreen);
                },
              )
            ],

            bottom: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'selling'.translate(context)),
                  Tab(text: 'buying'.translate(context)),
                ],
                indicatorColor: context.color.textDefaultColor,
                indicatorWeight: 1.5,
                labelColor: context.color.textDefaultColor,
                unselectedLabelColor:
                    context.color.textDefaultColor.withValues(alpha: 0.5),
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                labelPadding: EdgeInsets.symmetric(horizontal: 16),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
              Divider(
                height: 0, // Set height to 0 to make it full width
                thickness: 0.5, // Divider thickness
                color: context.color.textDefaultColor
                    .withValues(alpha: 0.2), // Divider color
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              sellingChatListData(),
              buyingChatListData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buyingChatListData() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<GetBuyerChatListCubit>().fetch();
      },
      color: context.color.territoryColor,
      child: BlocBuilder<GetBuyerChatListCubit, GetBuyerChatListState>(
        builder: (context, state) {
          if (state is GetBuyerChatListFailed) {
            if (state.error is ApiException) {
              if (state.error.errorMessage == "no-internet") {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: NoInternet(
                          onRetry: () {
                            context.read<GetBuyerChatListCubit>().fetch();
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const NoChatFound(),
                  ),
                );
              },
            );
          }

          if (state is GetBuyerChatListInProgress) {
            return buildChatListLoadingShimmer();
          }
          if (state is GetBuyerChatListSuccess) {
            if (state.chatedUserList.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: const NoChatFound(),
                    ),
                  );
                },
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: chatBuyerScreenController,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.chatedUserList.length,
                      padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 8, vertical: 4),
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        ChatUser chatedUser = state.chatedUserList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ChatTile(
                            id: chatedUser.sellerId.toString(),
                            itemId: chatedUser.itemId.toString(),
                            isBuyerList: true,
                            profilePicture: chatedUser.seller != null &&
                                    chatedUser.seller!.profile != null
                                ? chatedUser.seller!.profile!
                                : "",
                            userName: chatedUser.seller != null &&
                                    chatedUser.seller!.name != null
                                ? chatedUser.seller!.name!
                                : "",
                            itemPicture: chatedUser.item != null &&
                                    chatedUser.item!.image != null
                                ? chatedUser.item!.image!
                                : "",
                            itemName: chatedUser.item != null &&
                                    chatedUser.item!.name != null
                                ? chatedUser.item!.name!
                                : "",
                            pendingMessageCount: "5",
                            date: chatedUser.createdAt!,
                            itemOfferId: chatedUser.id!,
                            itemPrice: chatedUser.item != null &&
                                    chatedUser.item!.price != null
                                ? chatedUser.item!.price!
                                : 0.0,
                            itemAmount: chatedUser.amount ?? null,
                            status: chatedUser.item != null &&
                                    chatedUser.item!.status != null
                                ? chatedUser.item!.status!
                                : null,
                            buyerId: chatedUser.buyerId.toString(),
                            isPurchased: chatedUser.item?.isPurchased ?? 0,
                            alreadyReview: chatedUser.item?.review != null,
                            unreadCount: chatedUser.unreadCount,
                          ),
                        );
                      }),
                ),
                if (state.isLoadingMore) UiUtils.progress()
              ],
            );
          }

          return Container();
        },
      ),
    );
  }

  Widget sellingChatListData() {
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      builder: (context, userState) {
        final userDetails = userState.user;
        final isBankDetailsIncomplete = userDetails == null ||
            ((userDetails.bankName == null ||
                    userDetails.bankName!.isEmpty ||
                    userDetails.bankName == "null") &&
                (userDetails.accountNumber == null ||
                    userDetails.accountNumber!.isEmpty ||
                    userDetails.accountNumber == "null") &&
                (userDetails.accountHolderName == null ||
                    userDetails.accountHolderName!.isEmpty ||
                    userDetails.accountHolderName == "null"));

        return Column(
          children: [
            // Bank details warning banner
            if (isBankDetailsIncomplete)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.color.territoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.color.territoryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: context.color.territoryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "fillBankDetailsWarning".translate(context),
                        style: TextStyle(
                          color: context.color.textDefaultColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          Routes.bankDetailsScreen,
                        );
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: context.color.territoryColor,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<GetSellerChatListCubit>().fetch();
                },
                color: context.color.territoryColor,
                child:
                    BlocBuilder<GetSellerChatListCubit, GetSellerChatListState>(
                  builder: (context, state) {
                    if (state is GetSellerChatListFailed) {
                      if (state.error is ApiException) {
                        if (state.error.errorMessage == "no-internet") {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: NoInternet(
                                    onRetry: () {
                                      context
                                          .read<GetSellerChatListCubit>()
                                          .fetch();
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: constraints.maxHeight,
                              child: const NoChatFound(),
                            ),
                          );
                        },
                      );
                    }

                    if (state is GetSellerChatListInProgress) {
                      return buildChatListLoadingShimmer();
                    }
                    if (state is GetSellerChatListSuccess) {
                      if (state.chatedUserList.isEmpty) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: const NoChatFound(),
                              ),
                            );
                          },
                        );
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                                controller: chatSellerScreenController,
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: state.chatedUserList.length,
                                padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 8, vertical: 4),
                                itemBuilder: (
                                  context,
                                  index,
                                ) {
                                  ChatUser chatedUser =
                                      state.chatedUserList[index];

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: ChatTile(
                                      id: chatedUser.buyerId.toString(),
                                      itemId: chatedUser.itemId.toString(),
                                      isBuyerList: false,
                                      profilePicture:
                                          chatedUser.buyer?.profile ?? "",
                                      userName: chatedUser.buyer?.name ?? "",
                                      itemPicture: chatedUser.item != null &&
                                              chatedUser.item!.image != null
                                          ? chatedUser.item!.image!
                                          : "",
                                      itemName: chatedUser.item != null &&
                                              chatedUser.item!.name != null
                                          ? chatedUser.item!.name!
                                          : "",
                                      pendingMessageCount: "5",
                                      date: chatedUser.createdAt ?? '',
                                      itemOfferId: chatedUser.id!,
                                      itemPrice: chatedUser.item != null &&
                                              chatedUser.item!.price != null
                                          ? chatedUser.item!.price!
                                          : 0,
                                      itemAmount: chatedUser.amount ?? null,
                                      status: chatedUser.item != null &&
                                              chatedUser.item!.status != null
                                          ? chatedUser.item!.status!
                                          : null,
                                      buyerId: chatedUser.buyerId.toString(),
                                      isPurchased:
                                          chatedUser.item?.isPurchased ?? 0,
                                      alreadyReview:
                                          chatedUser.item?.review != null,
                                      unreadCount: chatedUser.unreadCount,
                                    ),
                                  );
                                }),
                          ),
                          if (state.isLoadingMore) UiUtils.progress()
                        ],
                      );
                    }

                    return Container();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildChatListLoadingShimmer() {
    return ListView.builder(
        itemCount: 10,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsetsDirectional.all(16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 9.0),
            child: SizedBox(
              height: 74,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
                      highlightColor:
                          Theme.of(context).colorScheme.shimmerHighlightColor,
                      child: Stack(
                        children: [
                          const SizedBox(
                            width: 58,
                            height: 58,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 42,
                              height: 42,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  border: Border.all(
                                      width: 1.5, color: Colors.white),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          PositionedDirectional(
                            end: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2)),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: context.color.territoryColor,
                                  // backgroundImage: NetworkImage(profilePicture),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomShimmer(
                          height: 10,
                          borderRadius: 5,
                          width: context.screenWidth * 0.53,
                        ),
                        CustomShimmer(
                          height: 10,
                          borderRadius: 5,
                          width: context.screenWidth * 0.3,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
