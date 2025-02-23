import 'package:eschool_teacher/cubits/holidaysCubit.dart';
import 'package:eschool_teacher/data/models/holiday.dart';
import 'package:eschool_teacher/ui/screens/academicCalendar/widgets/changeCalendarMonthButton.dart';
import 'package:eschool_teacher/utils/animationConfiguration.dart';
import 'package:eschool_teacher/utils/constants.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidaysContainer extends StatefulWidget {
  final DateTime firstDay, lastDay, focusedDay;
  final List<Holiday> holidays;
  final void Function(DateTime)? onPageChanged;

  const HolidaysContainer(
      {Key? key,
      required this.holidays,
      required this.onPageChanged,
      required this.firstDay,
      required this.lastDay,
      required this.focusedDay})
      : super(key: key);

  @override
  State<HolidaysContainer> createState() => _HolidaysContainerState();
}

class _HolidaysContainerState extends State<HolidaysContainer> {
  PageController? calendarPageController;

  Widget _buildHolidayDetailsList() {
    return Column(
      children: List.generate(
        widget.holidays.length,
        (index) => Animate(
          key: isApplicationItemAnimationOn ? UniqueKey() : null,
          effects: listItemAppearanceEffects(
              itemIndex: index, totalLoadedItems: widget.holidays.length),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            width: MediaQuery.of(context).size.width * (0.85),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: LayoutBuilder(
              builder: (context, boxConstraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.holidays[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(
                      height:
                          widget.holidays[index].description.isEmpty ? 0 : 5,
                    ),
                    widget.holidays[index].description.isEmpty
                        ? const SizedBox()
                        : Text(
                            widget.holidays[index].description,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 11.5,
                            ),
                          ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 2),
                              child: Icon(
                                Icons.calendar_month_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 12,
                              ),
                            ),
                          ),
                          TextSpan(
                            text:
                                UiUtils.formatDate(widget.holidays[index].date),
                          ),
                        ],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12.0,
                        ),
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
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
        holidayPredicate: (dateTime) {
          return widget.holidays.indexWhere(
                (element) =>
                    UiUtils.formatDate(dateTime) ==
                    UiUtils.formatDate(element.date),
              ) !=
              -1;
        },
        availableGestures: AvailableGestures.none,
        calendarStyle: CalendarStyle(
          isTodayHighlighted: false,
          holidayTextStyle:
              TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
          holidayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                      if (context.read<HolidaysCubit>().state
                          is HolidaysFetchInProgress) {
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
                      if (context.read<HolidaysCubit>().state
                          is HolidaysFetchInProgress) {
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
