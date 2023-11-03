import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/models/api/patient_data.dart';
import 'package:medic_app/utils/datetime.dart';

class ProfileCardDetail extends StatelessWidget {
  final PatientDataRes? patient;

  ProfileCardDetail({this.patient, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.pWidth,
        padding: EdgeInsets.all(context.hPadding * 0.8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            _patientInfo(context, patient!),
            Padding(
              padding: EdgeInsets.all(context.vPadding * 0.5),
            ),
            _medicInfo(context, patient!),
          ],
        ));
  }

  Widget _patientInfo(BuildContext context, PatientDataRes patientData) {
    return Column(
      children: [
        Row(children: [
          Text(patientData.name!,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.85,
                  fontWeight: FontWeight.bold)),
          Padding(padding: EdgeInsets.all(context.hPadding * 0.2)),
          Container(
              padding: EdgeInsets.only(
                top: context.vPadding * 0.2,
                bottom: context.vPadding * 0.2,
                left: context.hPadding * 0.4,
                right: context.hPadding * 0.4,
              ),
              decoration: BoxDecoration(
                  color: patientData.gender == 'F'
                      ? Color(0xFFFFF3F3)
                      : Color(0xFFE5F0FF),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                  "${patientData.gender == 'F' ? '여' : '남'} / ${patientData.age}",
                  style: TextStyle(
                      color: patientData.gender == 'F'
                          ? Color(0xFFBB3C6A)
                          : Color(0xFF0D2487),
                      fontSize: context.hPadding * 0.6,
                      fontWeight: FontWeight.bold))),
        ]),
        Padding(
          padding: EdgeInsets.all(context.vPadding * 0.4),
        ),
        Row(
          children: [
            SizedBox(
                child: Text('등록번호',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.7,
                        fontWeight: FontWeight.normal))),
            Container(
                margin: EdgeInsets.only(
                  left: context.hPadding * 0.5,
                  right: context.hPadding * 0.5,
                ),
                width: 1,
                height: context.vPadding * 0.8,
                color: AppColors.gray02),
            SizedBox(
                child: Text(patientData.code!,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.7,
                        fontWeight: FontWeight.normal))),
            Padding(
              padding: EdgeInsets.only(left: context.hPadding * 1.2),
            ),
            SizedBox(
                child: Text('병실',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.7,
                        fontWeight: FontWeight.normal))),
            Container(
                margin: EdgeInsets.only(
                  left: context.hPadding * 0.5,
                  right: context.hPadding * 0.5,
                ),
                width: 1,
                height: context.vPadding * 0.8,
                color: AppColors.gray02),
            SizedBox(
                child: Text(patientData.roomCode!,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: context.hPadding * 0.7,
                        fontWeight: FontWeight.normal))),
          ],
        )
      ],
    );
  }

  Widget _medicInfo(BuildContext context, PatientDataRes patientData) {
    final lastUpdatedDate = Datetime()
        .getSimpleDateFromServerDatetime(patientData.lastFeedDate!)
        .substring(2);
    return Container(
        padding: EdgeInsets.all(context.hPadding * 0.8),
        decoration: BoxDecoration(
            color: AppColors.blue01, borderRadius: BorderRadius.circular(5)),
        child: Row(children: [
          Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('담당의',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.6,
                          fontWeight: FontWeight.normal)),
                  Padding(
                    padding: EdgeInsets.all(context.vPadding * 0.2),
                  ),
                  Text(patientData.doctorName!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.75,
                          fontWeight: FontWeight.bold)),
                ],
              )),
          Container(
              margin: EdgeInsets.only(
                left: context.hPadding,
                right: context.hPadding,
              ),
              width: 1,
              height: context.vPadding * 2,
              color: AppColors.gray02),
          Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('간호사',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.6,
                          fontWeight: FontWeight.normal)),
                  Padding(
                    padding: EdgeInsets.all(context.vPadding * 0.2),
                  ),
                  Text(patientData.nurseName!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.75,
                          fontWeight: FontWeight.bold)),
                ],
              )),
          Container(
              margin: EdgeInsets.only(
                left: context.hPadding,
                right: context.hPadding,
              ),
              width: 1,
              height: context.vPadding * 2,
              color: AppColors.gray02),
          Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('촬영일자',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.6,
                          fontWeight: FontWeight.normal)),
                  Padding(
                    padding: EdgeInsets.all(context.vPadding * 0.2),
                  ),
                  Text(lastUpdatedDate.length < 8 ? '해당없음' : lastUpdatedDate,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.75,
                          fontWeight: FontWeight.bold)),
                ],
              )),
        ]));
  }
}
