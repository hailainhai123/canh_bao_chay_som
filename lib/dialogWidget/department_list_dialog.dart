import 'package:flutter/material.dart';
import 'package:health_care/model/department.dart';

class DepartmentListDialog extends StatefulWidget {
  final Function(String) callback;

  const DepartmentListDialog({Key key, this.callback}) : super(key: key);

  @override
  _DepartmentListDialogState createState() => _DepartmentListDialogState();
}

class _DepartmentListDialogState extends State<DepartmentListDialog> {
  Department department = Department('vitri', 'mavitri','sdt', '');
  List<Department> departments = List();

  @override
  void initState() {
    for (int i = 0; i < 20; i++) {
      departments.add(department);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return buildItem(
            departments[index],
          );
        },
        shrinkWrap: true,
      ),
    );
  }

  Widget buildItem(Department department) {
    return Container(
      child: Row(
        children: [
          Text(
            department.madiadiem,
          ),
          Text(
            department.departmentDiachiDecode,
          ),
          Text(
            department.sdtdiadiem,
          ),
        ],
      ),
    );
  }
}
