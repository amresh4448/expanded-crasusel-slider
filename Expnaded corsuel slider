package Name: flutter_carousel_widget

class ListViewAppAlertPage extends GetView<DashboardMainController> {
  ListViewAppAlertPage({super.key});
  final PageController pageController = PageController();
  @override
  final controller = Get.isRegistered<DashboardMainController>() ? Get.find<DashboardMainController>() : Get.put(DashboardMainController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final alertResults = controller.adminAlertResult;
      final userUcc = controller.appUserUcc.toString();

      final visibleAlerts = alertResults.where((alertData) {
        if (controller.dismissedAlerts.contains(alertData.alertId.toString())) return false;

        if (alertData.alertType == "public" && alertData.uccNo == null) return true;

        if (alertData.alertType == "private" && alertData.uccNo != null) {
          final uccList = alertData.uccNo!.split(',');
          return uccList.contains(userUcc);
        }

        return false;
      }).toList();

      if (visibleAlerts.isEmpty) return const SizedBox();

      return SizedBox(
        width: double.infinity,
        child: ExpandableCarousel(
          options: ExpandableCarouselOptions(
            showIndicator: false,
            aspectRatio: 9 / 18,
            viewportFraction: 1.0,
            physics: BouncingScrollPhysics(),
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (i, value){
              controller.currentNotificationIndex.value = i;
            }
          ),

          items: visibleAlerts.map((alertData) {
            final description = alertData.description?.toString() ?? '';
            final hashtag = ipoChecking(description)?.toLowerCase();
            return Builder(
              builder: (BuildContext context) {
                final width = MediaQuery.of(context).size.width;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: SizedBox(
                    width: width,
                    child: hashtag == '#ipo'
                        ? AppAlertIpo(
                      closePressed: () {
                        controller.dismissAlert(alertData.alertId.toString());
                      },
                      campaign: alertData.iconUpload.toString(),
                      alertTitle: alertData.title.toString(),
                      alertSubtitle: alertData.description.toString(),
                      widget: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          visibleAlerts.length,
                              (index) => buildDot(
                            totalLength: visibleAlerts.length,
                            index: index,
                            currentIndex: controller.currentNotificationIndex.value,
                            activeColor: AppColors.primaryOrange,
                            inactiveColor: AppColors.tertiaryBackground,
                          ),
                        ),
                      )),
                    )
                        : AppAlert(
                      closePressed: () {
                        controller.dismissAlert(alertData.alertId.toString());
                      },
                      campaign: alertData.iconUpload.toString(),
                      alertTitle: alertData.title.toString(),
                      alertSubtitle: alertData.description.toString(),
                      widget: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          visibleAlerts.length,
                              (index) => buildDot(
                            totalLength: visibleAlerts.length,
                            index: index,
                            currentIndex:
                            controller.currentNotificationIndex.value,
                            activeColor: AppColors.primaryOrange,
                            inactiveColor: AppColors.tertiaryBackground,
                          ),
                        ),
                      )),

                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );

