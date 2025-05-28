import 'package:flutter/material.dart';
import 'package:barber_app/models/service.dart';
import 'package:barber_app/utils/colors.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Service> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }
}
