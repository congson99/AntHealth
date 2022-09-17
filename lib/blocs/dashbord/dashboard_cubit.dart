import 'dart:convert';

import 'package:anthealth_mobile/blocs/app_states.dart';
import 'package:anthealth_mobile/blocs/dashbord/dashboard_states.dart';
import 'package:anthealth_mobile/generated/l10n.dart';
import 'package:anthealth_mobile/logics/server_logic.dart';
import 'package:anthealth_mobile/models/common/gps_models.dart';
import 'package:anthealth_mobile/models/dashboard/dashboard_models.dart';
import 'package:anthealth_mobile/models/family/family_models.dart';
import 'package:anthealth_mobile/models/medic/medical_directory_models.dart';
import 'package:anthealth_mobile/models/medic/medical_record_models.dart';
import 'package:anthealth_mobile/models/medic/medication_reminder_models.dart';
import 'package:anthealth_mobile/models/post/post_models.dart';
import 'package:anthealth_mobile/services/message/message_id_path.dart';
import 'package:anthealth_mobile/services/service.dart';
import 'package:anthealth_mobile/views/common_widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardCubit extends Cubit<CubitState> {
  DashboardCubit() : super(InitialState()) {
    home();
  }

  /// Initial State
  home() async {
    emit(HomeLoadingState());
    List<MedicalAppointment> medicalAppointment = [];
    List<ReminderMask> reminderMask = [];
    DateTime now = DateTime.now();
    medicalAppointment.addAll([
      MedicalAppointment(DateTime(now.year, now.month, now.day + 50, 0, 0),
          "Bệnh viện đại học y dược", now, "Kiểm tra sức khoẻ định kỳ")
    ]);
    reminderMask.addAll([
      ReminderMask(
          "Name",
          MedicineData(
              "",
              "Paradol Paradol ",
              30,
              0,
              0,
              "https://drugbank.vn/api/public/gridfs/box-panadol-extra-optizobaddvi-thuoc100190do-chinh-dien-15236089259031797856781.jpg",
              "https://drugbank.vn/thuoc/Panadol-Extra-with-Optizorb&VN-19964-16",
              ""),
          DateTime(now.year, now.month, now.day, 7, 0),
          1,
          "")
    ]);
    List<dynamic> result = [];
    while (medicalAppointment.length + reminderMask.length > 0) {
      if (medicalAppointment.length == 0) {
        result.addAll(reminderMask);
        break;
      }
      if (reminderMask.length == 0) {
        result.addAll(medicalAppointment);
        break;
      }
      if (medicalAppointment.first.dateTime.isBefore(reminderMask.first.time)) {
        result.add(medicalAppointment.first);
        medicalAppointment.removeAt(0);
      } else {
        result.add(reminderMask.first);
        reminderMask.removeAt(0);
      }
    }
    List<Post> posts = [];
    await Post.fromJson("assets/hardData/height.json")
        .then((value) => posts.add(value));
    await Post.fromJson("assets/hardData/weight.json")
        .then((value) => posts.add(value));
    await Post.fromJson("assets/hardData/blood_pressure.json")
        .then((value) => posts.add(value));
    emit(HomeState(result, posts));
  }

  health() async {
    emit(HealthLoadingState());
    await CommonService.instance.send(MessageIDPath.getHealthData(), {});
    CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(
          MessageIDPath.getHealthData(), value)) {
        List<double> indicatorLatestData = HealthPageData.formatIndicatorsList(
            ServerLogic.formatList(
                ServerLogic.getData(value)["indicatorInfo"]));
        emit(HealthState(HealthPageData(indicatorLatestData)));
      }
    });
  }

  void medic() async {
    emit(MedicLoadingState());
    await CommonService.instance.send(MessageIDPath.getMedicData(), {});
    CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(
          MessageIDPath.getMedicData(), value)) {
        emit(MedicState(MedicPageData.formatData(
            ServerLogic.getData(value)["latestMedicalRecord"],
            ServerLogic.getData(value)["upcomingAppointment"],
            ServerLogic.getData(value)["medicineBoxes"])));
      }
    });
  }

  family() async {
    emit(FamilyLoadingState());
    await CommonService.instance.send(MessageIDPath.getFamilyData(), {});
    CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(
          MessageIDPath.getFamilyData(), value)) {
        List<Invitation> invitations = [];
        if (ServerLogic.getData(value)["invite_list"] != null)
          for (dynamic x in ServerLogic.getData(value)["invite_list"])
            invitations.add(Invitation(x["id"], x["adminInfo"]["name"]));
        List<FamilyMemberData> members = [];
        if (ServerLogic.getData(value)["member_list"] != null) {
          for (dynamic x in ServerLogic.getData(value)["member_list"])
            members.add(FamilyMemberData(
                x["uid"].toString(),
                x["name"],
                x["base_info"]["avatar"],
                x["base_info"]["phone"],
                x["base_info"]["email"],
                x["rule"] == 2,
                [],
                x["birthDay"]));
          for (dynamic x in ServerLogic.getData(value)["member_list"][0]
              ["permission"]) {
            for (FamilyMemberData y in members) {
              if (y.id == x["uid"].toString()) {
                List<bool> temp = [];
                for (bool per in x["permissions"]) temp.add(per);
                y.permission = temp;
              }
            }
          }
        }
        emit(FamilyState(members, invitations));
      }
    });
  }

  Future<List<FamilyMemberData>> getMemberData() async {
    List<FamilyMemberData> members = [];
    await CommonService.instance.send(MessageIDPath.getFamilyData(), {});
    await CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(
          MessageIDPath.getFamilyData(), value)) {
        if (ServerLogic.getData(value)["member_list"] != null) {
          for (dynamic x in ServerLogic.getData(value)["member_list"]) {
            members.add(FamilyMemberData(
                x["uid"].toString(),
                x["name"],
                x["base_info"]["avatar"],
                x["base_info"]["phone"],
                x["base_info"]["email"],
                x["rule"] == 2,
                [],
                x["birthDay"]));
          }
          for (dynamic x in ServerLogic.getData(value)["member_list"][0]
              ["permission"]) {
            for (FamilyMemberData y in members) {
              if (y.id == x["uid"].toString()) {
                List<bool> temp = [];
                for (bool per in x["permissions"]) temp.add(per);
                y.permission = temp;
              }
            }
          }
        }
      }
    });
    return members;
  }

  Future<bool> addMember(String email) async {
    bool result = false;
    Map<String, dynamic> data = {"email": email};
    await CommonService.instance.send(MessageIDPath.addMember(), data);
    await CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(MessageIDPath.addMember(), value)) {
        if (ServerLogic.getData(value)["status"] != null)
          result = ServerLogic.getData(value)["status"];
      }
    });
    return result;
  }

  settings([SettingsState? state]) {
    emit(SettingsLoadingState());
    emit(state ?? SettingsState());
  }

  /// Server Functions
  Future<List<FamilyMemberData>> findUser(String email) async {
    if (email.length < 2) return [];
    List<FamilyMemberData> familyMemberData = [];
    Map<String, dynamic> data = {"email": email};
    await CommonService.instance.send(MessageIDPath.findUser(), data);
    await CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(MessageIDPath.findUser(), value)) {
        var data = ServerLogic.getData(value)["data"];
        for (dynamic x in data)
          familyMemberData.add(FamilyMemberData(
              x["uid"].toString(),
              x["name"],
              x["avatar"],
              "",
              x["email"],
              false,
              [true, true, true, true, true, true, true, true],
              0));
      }
    });
    return familyMemberData;
  }

  Future<void> createFamily() async {
    await CommonService.instance.send(MessageIDPath.createFamily(), {});
    CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(
          MessageIDPath.createFamily(), value)) {
        if (ServerLogic.getData(value)["status"]) family();
      }
    });
  }

  Future<void> handleInvitation(
      BuildContext context, String familyID, bool isAccept) async {
    Map<String, dynamic> data = {"familyId": familyID, "accept": isAccept};
    await CommonService.instance.send(MessageIDPath.handleInvitation(), data);
    CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(
          MessageIDPath.handleInvitation(), value)) {
        if (ServerLogic.getData(value)["status"]) {
          ShowSnackBar.showSuccessSnackBar(context, S.of(context).successfully);
        }
        family();
      }
    });
  }


  Future<HealthPageData> getHealthPageData(String id) async {
    Map<String, dynamic> j = {"uid": id};
    HealthPageData data = HealthPageData([]);
    await CommonService.instance.send(MessageIDPath.getHealthData(), j);
    await CommonService.instance.client!.getData().then((value) {
      if (ServerLogic.checkMatchMessageID(MessageIDPath.getHealthData(), value))
        data.indicatorsLatestData = HealthPageData.formatIndicatorsList(
            ServerLogic.formatList(
                ServerLogic.getData(value)["indicatorInfo"]));
    });
    return data;
  }

  Future<List<MedicalDirectoryData>> getMedicalContacts() async {
    var jsonText = await rootBundle.loadString('assets/hardData/hospital.json');
    List data = json.decode(jsonText);
    List<MedicalDirectoryData> result = [];
    for (dynamic x in data) {
      result.add(MedicalDirectoryData("", x["name"], x["address"], x["phone"],
          x["time"], "", GPS(double.parse(x["lat"]), double.parse(x["long"]))));
    }
    return result;
  }

  Future<List<MedicineData>> getMedications() async {
    var jsonText = await rootBundle.loadString('assets/hardData/medicine.json');
    List data = json.decode(jsonText);
    List<MedicineData> result = [];
    for (dynamic x in data) {
      result.add(MedicineData(
          "",
          x["name"],
          0,
          0,
          0,
          x["image"],
          x["Link"],
          "Thành phần:\n" +
              x["ingredients"] +
              "\n\n1. Chỉ định:\n" +
              x["allocate"] +
              "\n\n2. Chống chỉ định:\n" +
              x["contraindications"] +
              "\n\n3. Liều dùng/Cách dùng:\n" +
              x["dosage"] +
              "\n\n4. Tác dụng phụ:\n" +
              x["sideEffects"] +
              "\n\n5. Thận trọng:\n" +
              x["Careful"] +
              "\n\n6. Tương tác thuốc:\n" +
              x["Interactions"] +
              "\n\n7. Bảo quản:\n" +
              x["Preserve"] +
              "\n\n8. Đóng gói:\n" +
              x["Pack"]));
    }
    return result;
  }

  Future<bool> removeFromFamily(String uid) async {
    bool result = false;
    Map<String, dynamic> data = {"uid": uid};
    await CommonService.instance.send(MessageIDPath.outFamily(), data);
    await CommonService.instance.client!.getData().then((value) {
      if (value != "null") if (ServerLogic.checkMatchMessageID(
          MessageIDPath.outFamily(), value)) {
        result = ServerLogic.getData(value)["status"];
      }
    });
    return result;
  }

  Future<bool> grantFamilyMember(String uid) async {
    bool result = false;
    Map<String, dynamic> data = {"uid": uid};
    await CommonService.instance.send(MessageIDPath.grantFamilyMember(), data);
    await CommonService.instance.client!.getData().then((value) {
      if (value != "null") if (ServerLogic.checkMatchMessageID(
          MessageIDPath.grantFamilyMember(), value)) {
        result = ServerLogic.getData(value)["status"];
      }
    });
    return result;
  }

  Future<List<MedicineData>> getMedicationsWithoutNote() async {
    var jsonText = await rootBundle.loadString('assets/hardData/medicine.json');
    List data = json.decode(jsonText);
    List<MedicineData> result = [];
    for (dynamic x in data) {
      result
          .add(MedicineData("", x["name"], 0, 0, 0, x["image"], x["Link"], ""));
    }
    return result;
  }
}
