import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/weight_provider.dart';
import 'package:fl_chart/fl_chart.dart'; 

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Daily BMI", style: TextStyle(color: Color(0xFF7B61FF), fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: "แบบย่อ"), Tab(text: "กราฟรายเดือน"), Tab(text: "กราฟรายปี")],
              labelColor: Color(0xFF7B61FF),
              indicatorColor: Color(0xFF7B61FF),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSummaryList(context),
                  _buildGraphView(context, "Monthly"), 
                  _buildGraphView(context, "Yearly"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryList(BuildContext context) {
    final provider = context.watch<WeightProvider>();
    final records = provider.historyRecords;

    if (records.isEmpty) {
      return const Center(child: Text("ยังไม่มีข้อมูลบันทึก", style: TextStyle(color: Colors.grey, fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final dateStr = "${record.timestamp.day}/${record.timestamp.month}/${record.timestamp.year + 543}";
        final timeStr = "${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')} น.";

        Color statusColor = Colors.green;
        String statusText = "สมส่วน";
        if (record.status == "Underweight") { statusText = "ผอมเกินไป"; statusColor = Colors.orange; }
        else if (record.status == "Healthy") { statusText = "สมส่วน"; statusColor = Colors.green; }
        else if (record.status == "Overweight") { statusText = "น้ำหนักเกิน"; statusColor = Colors.orangeAccent; }
        else if (record.status == "Obese") { statusText = "อ้วน"; statusColor = Colors.red; }

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF80F0F0), 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text("$dateStr   $timeStr", style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 15),
                  Text("Weight: ${record.weight.toStringAsFixed(1)} กก.", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Height: ${record.height.toStringAsFixed(0)} ซม.", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Heart Rate: ${record.heartRate} ครั้ง/นาที", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("BMI: ${record.bmi.toStringAsFixed(1)}", style: const TextStyle(fontSize: 16)),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(15)),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => provider.deleteRecord(index), 
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGraphView(BuildContext context, String type) {
    final provider = context.watch<WeightProvider>();
    final records = provider.historyRecords;
    final aiData = provider.aiAnalysis;

    if (records.isEmpty) {
      return const Center(child: Text("ต้องมีข้อมูลอย่างน้อย 1 รายการเพื่อสร้างกราฟ", style: TextStyle(color: Colors.grey)));
    }

    final chartData = records.reversed.toList();
    final latestRecord = records.first;
    double weightChange = 0.0;
    if (records.length > 1) {
      weightChange = records.first.weight - records[1].weight;
    }

    // ป้องกัน null กรณีที่ยังไม่มีข้อมูล prediction
    String predictionText = '-';
    if (aiData['prediction'] != null && aiData['prediction'] is double && aiData['prediction'] > 0) {
      predictionText = (aiData['prediction'] as double).toStringAsFixed(2);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 1. กราฟเส้น
          Container(
            height: 250,
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
                    isCurved: true,
                    color: const Color(0xFF00BFFF), 
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true), 
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF00BFFF).withValues(alpha: 0.1), 
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 2. ข้อมูลสรุป
          Row(
            children: [
              Expanded(child: _buildInfoCard("BMI", latestRecord.bmi.toStringAsFixed(1))),
              const SizedBox(width: 15),
              Expanded(
                child: _buildInfoCard(
                  "การเปลี่ยนแปลง", 
                  "${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(2)} Kg",
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 3. AI Analysis Box (กันพังด้วยการใส่ ?? '-')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6), 
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.smart_toy, color: Colors.deepOrange),
                    SizedBox(width: 10),
                    Text("AI วิเคราะห์แนวโน้ม", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
                const Divider(color: Colors.orangeAccent),
                const SizedBox(height: 10),
                Center(child: Text("แนวโน้ม: ${aiData['trend'] ?? '-'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Center(child: Text("คาดการณ์ BMI ครั้งถัดไป: $predictionText", style: const TextStyle(fontSize: 16))),
                
                const SizedBox(height: 20),
                const Text("📌 การประเมินสถานะ:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 5),
                Text(aiData['evaluation'] ?? '-', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                
                const SizedBox(height: 15),
                const Text("💡 คำแนะนำจากระบบ:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 5),
                Text(aiData['recommendation'] ?? '-', style: const TextStyle(fontSize: 15, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF7B61FF))),
        ],
      ),
    );
  }
}