import 'package:flutter/material.dart';

class TitleWithLogo extends StatelessWidget {
  const TitleWithLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 110,
          width: 110,
        ),
        const SizedBox(width: 0),
        const Align(
          alignment: Alignment.center,
          child: Text(
            'ReDish',
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 76,
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }
}
