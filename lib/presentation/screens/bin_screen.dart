import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/bin/bin_bloc.dart';
import 'package:coo_list/logic/bin/bin_event.dart';
import 'package:coo_list/presentation/widgets/bin/bin_products_list.dart';

class BinScreen extends StatefulWidget {
  static const String routeName = '/bin';

  const BinScreen({super.key});

  @override
  State<BinScreen> createState() => _BinScreenState();
}

class _BinScreenState extends State<BinScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BinBloc>().add(const LoadBinItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuka'),
      ),
      body: const BinProductsList(),
    );
  }
}
