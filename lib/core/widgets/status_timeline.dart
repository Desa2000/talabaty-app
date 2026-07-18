import 'package:flutter/material.dart';

class StatusTimeline extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const StatusTimeline({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isLast = index == steps.length - 1;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.orange : Colors.grey.shade300,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? Colors.orange : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  steps[index],
                  style: TextStyle(
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
