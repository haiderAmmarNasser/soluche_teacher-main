import 'package:eschool_teacher/cubits/eventsCubit.dart';
import 'package:eschool_teacher/data/models/event.dart';
import 'package:eschool_teacher/ui/screens/academicCalendar/widgets/changeCalendarMonthButton.dart';
import 'package:eschool_teacher/ui/screens/academicCalendar/widgets/listItemForEvents.dart';
import 'package:eschool_teacher/ui/styles/colors.dart';
import 'package:eschool_teacher/utils/animationConfiguration.dart';
import 'package:eschool_teacher/utils/constants.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsContainer extends StatefulWidget {
  final DateTime firstDay, lastDay, focusedDay;
  final List<DateTime> innerDates;
  final List<DateTime> startWithNoEnd;
  final List<DateTime> startDates;
  final List<DateTime> endDates;
  final List<Event> events;
  final void Function(DateTime)? onPageChanged;

  const EventsContainer(
      {Key? key,
      required this.events,
      required this.onPageChanged,
      required this.firstDay,
      required this.lastDay,
      required this.focusedDay,
      required this.innerDates,
      required this.startWithNoEnd,
      required this.startDates,
      required this.endDates})
      : super(key: key);

  @override
  State<EventsContainer> createState() => _EventsContainerState();
}

class _EventsContainerState extends State<EventsContainer> {
  PageController? calendarPageController;

  Widget _buildHolidayDetailsList() {
    return Column(
      children: List.generate(
        widget.events.length,
        (index) => Animate(
            key: isApplicationItemAnimationOn ? UniqueKey() : null,
            effects: listItemAppearanceEffects(
                itemIndex: index, totalLoadedItems: widget.events.length),
            child: EventItemContainer(event: widget.events[index])),
      ),
    );
  }

  Widget _buildCalendarContainer() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.075),
            offset: const Offset(5.0, 5),
            blurRadius: 10,
          )
        ],
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: TableCalendar(
        headerVisible: false,
        daysOfWeekHeight: 40,
        onPageChanged: widget.onPageChanged,
        onCalendarCreated: (contoller) {
          calendarPageController = contoller;
        },
        calendarBuilders: CalendarBuilders(
          rangeHighlightBuilder: (context, day, isWithinRange) {
            bool isFirst = false,
                isLast = false,
                isInner = false,
                isStartWithNoEnd = false;

            isFirst = widget.startDates.any((element) =>
                UiUtils.formatDate(day) == UiUtils.formatDate(element));

            isLast = widget.endDates.any((element) =>
                UiUtils.formatDate(day) == UiUtils.formatDate(element));

            isInner = widget.innerDates.any((element) =>
                UiUtils.formatDate(day) == UiUtils.formatDate(element));

            if (!isFirst && !isLast && !isInner) {
              isStartWithNoEnd = widget.startWithNoEnd.any((element) =>
                  UiUtils.formatDate(day) == UiUtils.formatDate(element));
            }

            return isInner || isFirst || isLast || isStartWithNoEnd
                ? Stack(
                    children: [
                      if (!isStartWithNoEnd)
                        Container(
                          margin: EdgeInsetsDirectional.only(
                              top: 7,
                              bottom: 7,
                              start: isFirst && !isInner ? 10 : 0,
                              end: isLast && !isInner ? 10 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.only(
                              topEnd: isLast && !isInner
                                  ? const Radius.circular(50)
                                  : Radius.zero,
                              bottomEnd: isLast && !isInner
                                  ? const Radius.circular(50)
                                  : Radius.zero,
                              topStart: isFirst && !isInner
                                  ? const Radius.circular(50)
                                  : Radius.zero,
                              bottomStart: isFirst && !isInner
                                  ? const Radius.circular(50)
                                  : Radius.zero,
                            ),
                            color: onPrimaryColor.withOpacity(0.5),
                          ),
                        ),
                      if (isFirst || isLast || isStartWithNoEnd)
                        Container(
                          margin: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: onPrimaryColor),
                        ),
                    ],
                  )
                : null;
          },
        ),
        availableGestures: AvailableGestures.none,
        calendarStyle: const CalendarStyle(
          isTodayHighlighted: false,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          weekdayStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle:
            const HeaderStyle(titleCentered: true, formatButtonVisible: false),
        firstDay: widget.firstDay, //start education year
        lastDay: widget.lastDay, //end education year
        focusedDay: widget.focusedDay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width *
            UiUtils.screenContentHorizontalPaddingPercentage,
        right: MediaQuery.of(context).size.width *
            UiUtils.screenContentHorizontalPaddingPercentage,
        bottom: UiUtils.getScrollViewBottomPadding(context),
        top: UiUtils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: UiUtils.appBarBiggerHeightPercentage,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.075),
                  offset: const Offset(2.5, 2.5),
                  blurRadius: 5,
                )
              ],
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            width: MediaQuery.of(context).size.width * (0.85),
            child: Stack(
              children: [
                Align(
                  child: Text(
                    "${UiUtils.getMonthName(widget.focusedDay.month)} ${widget.focusedDay.year}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ChangeCalendarMonthButton(
                    onTap: () {
                      if (context.read<EventsCubit>().state
                          is EventsFetchInProgress) {
                        return;
                      }
                      calendarPageController?.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    isDisable: false,
                    isNextButton: false,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: ChangeCalendarMonthButton(
                    onTap: () {
                      if (context.read<EventsCubit>().state
                          is EventsFetchInProgress) {
                        return;
                      }

                      calendarPageController?.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    isDisable: false,
                    isNextButton: true,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildCalendarContainer(),
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.025),
              ),
              _buildHolidayDetailsList()
            ],
          ),
        ],
      ),
    );
  }
}
