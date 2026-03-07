import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/weight_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ฟังก์ชันสร้าง Popup สำหรับกรอกส่วนสูง
  void _editHeightDialog(BuildContext context, WeightProvider provider) {
    // ดึงส่วนสูงเดิมมาใส่ในช่องกรอกไว้ก่อน
    TextEditingController heightController = TextEditingController(
      text: provider.heightCm.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("แก้ไขส่วนสูง (Cm)"),
          content: TextField(
            controller: heightController,
            keyboardType: TextInputType.number, // ให้คีย์บอร์ดขึ้นเป็นตัวเลข
            decoration: const InputDecoration(hintText: "เช่น 170"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // ปิด Popup
              child: const Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () {
                // แปลงข้อความเป็นตัวเลขแล้วส่งไปให้ Provider
                double? newHeight = double.tryParse(heightController.text);
                if (newHeight != null && newHeight > 0) {
                  provider.updateHeight(newHeight);
                }
                Navigator.pop(context); // ปิด Popup
              },
              child: const Text("บันทึก"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ดึง Provider มาใช้งาน
    final weightData = context.watch<WeightProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daily BMI",
          style: TextStyle(
            color: Color(0xFF7B61FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Status Card ด้านบน
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ดึงสถานะ Healthy / Overweight มาแสดงแบบอัตโนมัติ
                  Text(
                    weightData.bodyStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "Connect",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _buildDataCard(
                  "Weight",
                  "${weightData.currentWeight.toStringAsFixed(1)} Kg",
                ),

                // ครอบกล่อง Height ด้วย GestureDetector เพื่อให้กดได้
                GestureDetector(
                  onTap: () => _editHeightDialog(context, weightData),
                  child: _buildDataCard(
                    "Height",
                    "${weightData.heightCm.toStringAsFixed(0)} Cm",
                    isEditable: true,
                  ),
                ),

                // ดึง BMI มาแสดง
                _buildDataCard("BMI", weightData.bmi.toStringAsFixed(1)),
                _buildDataCard(
                  "Heart Rate",
                  "${weightData.currentHeartRate} BPM",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // กล่อง Body ด้านล่าง
            _buildDataCard("Body", weightData.bodyStatus, fullWidth: true),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 1. เรียกคำสั่งบันทึกข้อมูลลง History
                    weightData.saveCurrentData();

                    // 2. แสดง Popup เล็กๆ (SnackBar) แจ้งเตือนด้านล่างจอว่าบันทึกสำเร็จ
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("บันทึกข้อมูลลงใน History แล้ว"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ปรับ _buildDataCard ให้มีไอคอนดินสอโผล่มาถ้าตั้งค่า isEditable = true
  Widget _buildDataCard(
    String label,
    String value, {
    bool fullWidth = false,
    bool isEditable = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFF),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B61FF),
                  ),
                ),
              ],
            ),
          ),
          // แสดงไอคอนแก้ไขมุมขวาบน
          if (isEditable)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.edit, size: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
