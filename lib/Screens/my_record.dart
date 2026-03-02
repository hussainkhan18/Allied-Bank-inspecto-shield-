import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class MyRecords extends StatefulWidget {
  final int id;
  const MyRecords({super.key, required this.id});

  @override
  State<MyRecords> createState() => _MyRecordsState();
}

class _MyRecordsState extends State<MyRecords> {
  List<dynamic> recordList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getRecordList();
  }

  Future<void> getRecordList() async {
    try {
      final response = await http.get(
        Uri.parse('https://inspectoshield.com/api/my_records/${widget.id}'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> tempEquipments = [];
        for (Map i in jsonResponse["data"]) {
          tempEquipments.add([
            i["equipment_name"],
            i["updated_at"],
            i["location_description"],
            i["location_name"],
            i["area"],
          ]);
        }
        setState(() {
          recordList = tempEquipments;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Failed to load data");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print({"error": e.toString()});
    }
  }

  String formatWithLineBreaks(String originalString) {
    List<String> words = originalString.split(' ');
    String result = '';
    String currentLine = '';
    for (String word in words) {
      if ((currentLine + word).length > 15) {
        result += '${currentLine.trim()}\n';
        currentLine = '$word ';
      } else {
        currentLine += '$word ';
      }
    }
    result += currentLine.trim();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff0DC5B9);

    return Scaffold(
      backgroundColor: const Color(0xffF2FAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header with iOS back button ──────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 10),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // iOS style back button
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.chevron_back,
                          size: 25,
                        ),
                        SizedBox(width: 2),
                      ],
                    ),
                  ),
                  // Title centered
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.translate("My Records"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1C2B2B),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Record count badge (right side to balance layout)
                  if (!isLoading && recordList.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${recordList.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    )
                  else
                    // Spacer to keep title centered when badge not visible
                    const SizedBox(width: 44),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Column Header Row ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _headerLabel(context, "EQUIPMENT", flex: 5),
                  _headerLabel(context, "WHEN", flex: 4),
                  _headerLabel(context, "LOCATION", flex: 4),
                  _headerLabel(context, "AREA", flex: 4),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : recordList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open_outlined,
                                  size: 44,
                                  color: primaryColor.withOpacity(0.35)),
                              const SizedBox(height: 10),
                              Text(
                                AppLocalizations.of(context)!
                                    .translate("No Records Found"),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: recordList.length,
                          itemBuilder: (context, index) {
                            // ── Date ────────────────────────────
                            String datetimeStr =
                                recordList[index][1].toString();
                            DateTime datetime = DateTime.parse(datetimeStr);
                            String formattedDate =
                                DateFormat('dd MMM yy').format(datetime);
                            String formattedTime =
                                DateFormat('hh:mm a').format(datetime);

                            // ── Equipment name (unchanged logic) ──
                            String equipmentText =
                                recordList[index][0].toString();
                            String displayEquipment = equipmentText
                                        .split(' ')
                                        .length ==
                                    3
                                ? '${equipmentText.split(' ').take(2).join(' ')}\n${equipmentText.split(' ').last}'
                                : equipmentText;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 9),
                              decoration: BoxDecoration(
                                color: const Color(0xff0DC5B9),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff0DC5B9)
                                        .withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 11),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        displayEquipment,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white
                                                  .withOpacity(0.82),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        recordList[index][2].toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        formatWithLineBreaks(
                                            recordList[index][4].toString()),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerLabel(BuildContext context, String key, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        AppLocalizations.of(context)!.translate(key),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xff0DC5B9),
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}
