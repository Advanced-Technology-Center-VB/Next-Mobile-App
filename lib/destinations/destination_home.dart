// Home destination

import 'dart:async';
import 'dart:math';

import 'package:atc_mobile_app/contracts/notification_service_contract.dart';
import 'package:atc_mobile_app/models/event_model.dart';
import 'package:atc_mobile_app/provider/base_view.dart';
import 'package:atc_mobile_app/view_models/home_view_model.dart';
import 'package:atc_mobile_app/widgets/connection_error.dart';
import 'package:atc_mobile_app/widgets/lazy_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class DestinationHome extends StatefulWidget {
  const DestinationHome({super.key});

  @override
  State<DestinationHome> createState() => _DestinationHomeState();
}

class _DestinationHomeState extends State<DestinationHome> {
  final _headlineScrollController = PageController();
  var _currentHeadline = 0;

  Timer? _headlineScrollTimer;

  @override void initState() {
    super.initState();

    if (GetIt.instance.get<HomeViewModel>().events.where((e) => e.headline).length > 1) _startScrollTimer();
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_headlineScrollTimer != null) _headlineScrollTimer!.cancel();
  }

  void _startScrollTimer() {
    _headlineScrollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        _headlineScrollController.animateToPage(
          ++_currentHeadline, 
          duration: const Duration(seconds: 1), 
          curve: Curves.easeInOutCirc
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(builder: (context, viewModel, _) {
      HomeViewModel vm = viewModel as HomeViewModel;

      //Get events that are headlines to display in the top headline box.
      var headlines = vm.events.where((event) => event.headline == true).toList();

      //Check if there is an error or if the vm is still fetching data.
      if (!vm.isReady) {
        return Center(
          child: vm.error ? const ConnectionError() : const CircularProgressIndicator(),
        );
      }

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          vm.headlineImageCache.isNotEmpty ? SliverAppBar.large(
            expandedHeight: 200,
            floating: false,
            pinned: false,
            stretchTriggerOffset: 100,
            stretch: true,
            flexibleSpace: PageView.builder( //This PageView lets the user scroll horizontally between headlines.
              controller: _headlineScrollController,
              onPageChanged: (value) => _currentHeadline = value,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _buildExpandedHeadlineWidget(headlines[index % headlines.length], vm.headlineImageCache[index % vm.headlineImageCache.length]))), //Displays the headline in an expanded view.
                child: FlexibleSpaceBar(
                  collapseMode: CollapseMode.none,
                  background: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                    Color.fromARGB(95, 0, 0, 0),
                     BlendMode.darken
                   ),
                   child: vm.headlineImageCache[index % vm.headlineImageCache.length]
              ),
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              titlePadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              title: Wrap(
                children: [
                  Text(headlines[index % headlines.length].headlineTitle ?? headlines[index % headlines.length].title, style: const TextStyle(
                    color: Colors.white
                  )),
                  const Text(
                    "Learn more",
                    style: TextStyle(
                      color: Color.fromARGB(217, 217, 217, 255),
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                    ),
                  ),
                  Center( //This renders the dots at the bottom of the headline widget, I know it's pretty funky...
                    child: Wrap(
                      spacing: 4,
                      children: LazyWidget(
                        count: headlines.length,
                        builder: (selection) => Container(width: 5, height: 5, decoration: BoxDecoration(color: selection == index % headlines.length ? Colors.white : const Color.fromARGB(121, 255, 255, 255), borderRadius: BorderRadius.circular(100)),)
                      ).getList(),
                    ),
                  )
                ],
              )
            )),   
            )
          ) : const SliverAppBar(title: Text("Events"), centerTitle: true,),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList.builder(
              itemCount: vm.events.length,
              itemBuilder: (context, index) {
                var model = vm.events[index];

                return ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        model.startTimestamp.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 22,
                          height: 1,
                          color: Theme.of(context).colorScheme.onSurface
                        ),
                      ),
                      Text(
                        DateFormat.MMM().format(model.startTimestamp).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                        )
                      ),
                    ],
                  ),
                  title: Text(model.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, height: 2)),
                  subtitle: Wrap(
                    spacing: 6,  
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      Text(TimeOfDay.fromDateTime(model.startTimestamp).format(context)),
                      const Text("•"),
                      const Icon(Icons.location_on_outlined, size: 16),
                      Text(model.location)
                    ],
                  ),
                );
              }
            ),
          )
        ],
      );
    });
  }
  void _showAlertAddModal(EventModel model) {
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      constraints: const BoxConstraints.expand(), 
      builder: (context) {
        int mask = 32;

        List<String> triggerLabels = [
          "1 day before",
          "12 hours before",
          "6 hours before",
          "1 hour before",
          "10 minutes before",
          "When event starts"
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.notification_add),
              const Text(
                "Get Notified",
                style: TextStyle(
                  fontSize: 22
               )
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        model.startTimestamp.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 22,
                          height: 1,
                          color: Theme.of(context).colorScheme.onSurface
                        ),
                      ),
                      Text(
                        DateFormat.MMM().format(model.startTimestamp).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                        )
                      ),
                    ],
                  ),
                  title: Text(model.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, height: 2)),
                    subtitle: Wrap(
                      spacing: 6,  
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(Icons.schedule, size: 16),
                        Text(TimeOfDay.fromDateTime(model.startTimestamp).format(context)),
                        const Text("•"),
                        const Icon(Icons.location_on_outlined, size: 16),
                        Text(model.location)
                      ],
                    ),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setCheckboxState) {
                    builder(i) {
                      return Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Checkbox(
                            value: mask >> i & 1 == 1,
                            onChanged: (change) => setCheckboxState(() {
                              mask = (change == true ? mask + pow(2, i) : mask - pow(2, i)) as int; //See destination_app_hub.dart for more information about this method of storing checkboxes.
                            })),
                            Text(triggerLabels[i])
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: LazyWidget(count: 3, builder: builder).getList()
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: LazyWidget(start: 3, count: triggerLabels.length, builder: builder).getList()
                          )
                        ]
                      ),
                    );
                  }
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        GetIt.instance.get<NotificationServiceContract>().scheduleEventNotification(model, mask);

                        setState(() {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("You will be notified at the chosen times!")
                          ));
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Enable notifications")
                    )
                  ]
                )
              ]
            )
          );      
      }
    );  
  }

  ///This method builds the expanded view for a headline when you select 'learn more'
  Widget _buildExpandedHeadlineWidget(EventModel model, Image cachedImage) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: Text(model.title),
              actions: [
                false ? IconButton( //Temporarily disabled
                  onPressed: () => _showAlertAddModal(model), 
                  icon: const Icon(Icons.add_alert_outlined)
                ) : const SizedBox.shrink()
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: cachedImage
                ),
              )
            ),
            PinnedHeaderSliver(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                height: 40,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      spacing: 4,
                      children: [
                        Icon(Icons.calendar_month_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        Text("${DateFormat.MMMd().format(model.startTimestamp)}, ${model.startTimestamp.year}", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      spacing: 4,
                      children: [
                        Icon(Icons.schedule, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        Text(TimeOfDay.fromDateTime(model.startTimestamp).format(context), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      spacing: 4,
                      children: [
                        Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        Text(model.location, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                      ],
                    )
                  ],
                )
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverToBoxAdapter(
                child: Text(model.summary ?? "Failed to load content."),
              ),
            )
          ],
      ),
      ),
    );
  }
}