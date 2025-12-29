import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String value;
  const HourlyForecastItem(this.time, this.icon, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                time,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Icon(icon),
              SizedBox(height: 8),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}
