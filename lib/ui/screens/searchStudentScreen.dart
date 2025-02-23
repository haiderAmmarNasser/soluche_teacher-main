import 'package:eschool_teacher/data/models/student.dart';
import 'package:eschool_teacher/ui/widgets/studentAttendanceTileContainer.dart';
import 'package:eschool_teacher/ui/widgets/studentTileContainer.dart';
import 'package:eschool_teacher/ui/widgets/svgButton.dart';
import 'package:eschool_teacher/utils/labelKeys.dart';
import 'package:eschool_teacher/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchStudentScreen extends StatefulWidget {
  final List<Student> students;
  final bool fromAttendanceScreen;
  final List<Map<int, bool>>? listOfAttendanceReport;
  const SearchStudentScreen({
    Key? key,
    required this.fromAttendanceScreen,
    required this.students,
    this.listOfAttendanceReport,
  }) : super(key: key);

  @override
  State<SearchStudentScreen> createState() => _SearchStudentScreenState();

  static Route<List<Map<int, bool>>?> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (_) => SearchStudentScreen(
        fromAttendanceScreen: arguments['fromAttendanceScreen'],
        students: arguments['students'],
        listOfAttendanceReport: arguments['listOfAttendanceReport'],
      ),
    );
  }
}

class _SearchStudentScreenState extends State<SearchStudentScreen> {
  late final TextEditingController searchQueryTextEditingController =
      TextEditingController()..addListener(searchQueryTextControllerListener);

  bool searchTextEmpty = false;
  late List<Student> searchedStudents = [];

  late List<Map<int, bool>> listOfAttendance =
      widget.fromAttendanceScreen ? widget.listOfAttendanceReport! : [];

  void _updateAttendance(int studentId) {
    final index = listOfAttendance
        .indexWhere((element) => element.keys.first == studentId);
    listOfAttendance[index][studentId] = !listOfAttendance[index][studentId]!;
    setState(() {});
  }

  // Timer? waitForNextSearchRequestTimer;

  // int waitForNextRequestSearchQueryTimeInMilliSeconds = 500;

  void searchQueryTextControllerListener() {
    //waitForNextSearchRequestTimer?.cancel();
    //setWaitForNextSearchRequestTimer();
    if (searchQueryTextEditingController.text.isNotEmpty) {
      searchedStudents.clear();
      searchedStudents.addAll(
        widget.students.where(
          (element) => element.getFullName().toLowerCase().contains(
                searchQueryTextEditingController.text.trim().toLowerCase(),
              ),
        ),
      );
      if (searchTextEmpty) {
        searchTextEmpty = false;
      }
      setState(() {});
    } else {
      if (!searchTextEmpty) {
        setState(() {
          searchTextEmpty = true;
        });
      }
    }
  }

  @override
  void dispose() {
    searchQueryTextEditingController.dispose();
    super.dispose();
  }

  Widget _buildSearchTextField() {
    return TextField(
      controller: searchQueryTextEditingController,
      autofocus: true,
      cursorColor: Theme.of(context).scaffoldBackgroundColor,
      style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Theme.of(context).scaffoldBackgroundColor),
        border: InputBorder.none,
        hintText: UiUtils.getTranslatedLabel(context, searchStudentKey),
      ),
    );
  }

  Widget _buildStudents() {
    return searchTextEmpty
        ? Center(
            child: Text(
              UiUtils.getTranslatedLabel(context, searchStudentKey),
              style: const TextStyle(fontSize: 16),
            ),
          )
        : searchedStudents.isEmpty
            ? Center(
                child: Text(
                  UiUtils.getTranslatedLabel(context, noStudentsFoundKey),
                  style: const TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: MediaQuery.of(context).size.width *
                      UiUtils.screenContentHorizontalPaddingPercentage,
                ),
                itemCount: searchedStudents.length,
                itemBuilder: (context, index) {
                  if (widget.fromAttendanceScreen) {
                    final isPresent = listOfAttendance
                        .where(
                          (element) =>
                              element.keys.first == searchedStudents[index].id,
                        )
                        .toList()
                        .first[searchedStudents[index].id]!;

                    return StudentAttendanceTileContainer(
                      isPresent: isPresent,
                      student: searchedStudents[index],
                      updateAttendance: _updateAttendance,
                    );
                  }

                  return StudentTileContainer(student: searchedStudents[index]);
                },
              );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(listOfAttendance);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              iconSize: 26,
              color: Theme.of(context).scaffoldBackgroundColor,
              onPressed: () {
                searchQueryTextEditingController.clear();
                searchedStudents.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clear),
            )
          ],
          title: _buildSearchTextField(),
          leading: Padding(
            padding: const EdgeInsets.all(17),
            child: SvgButton(
              onTap: () {
                Navigator.of(context).pop(listOfAttendance);
              },
              svgIconUrl: UiUtils.getBackButtonPath(context),
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: _buildStudents(),
      ),
    );
  }
}
