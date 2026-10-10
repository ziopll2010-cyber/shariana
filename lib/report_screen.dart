import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // مكتبة قاعدة البيانات

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedHazard = 'حفرة بالشارع';
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController(
    text: 'البصرة - شط العرب',
  );
  bool imageAttached = false;
  bool isLoading = false; // مؤشر التحميل أثناء الإرسال للسحابة

  final List<String> hazardTypes = [
    'حفرة بالشارع',
    'تسريب زيوت / كاز',
    'مطبة غير معلمة',
    'عمود كهرباء أو إنارة مائل',
    'انسداد مجاري / طفح مياه',
  ];

  // دالة إرسال البلاغ إلى Firebase Firestore
  Future<void> _submitReportToFirebase() async {
    setState(() {
      isLoading = true;
    });

    try {
      // إرسال البيانات إلى مجموعة (Collection) اسمها reports في السحابة
      await FirebaseFirestore.instance.collection('reports').add({
        'type': selectedHazard,
        'description': descController.text.isEmpty
            ? 'لا يوجد وصف إضافي'
            : descController.text,
        'locationText': locationController.text,
        'hasImage': imageAttached,
        'status': 'قيد المراجعة',
        'timestamp': FieldValue.serverTimestamp(), // وقت السيرفر الرسمي
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال البلاغ بنجاح إلى قاعدة بيانات البصرة! 🚀'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      Navigator.pop(context, true); // إرجاع مؤشر النجاح
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الإرسال: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'تقديم بلاغ جديد (سحابي)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نوع الضرر في الطريق:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedHazard,
                items: hazardTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedHazard = val!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'وصف إضافي للموقع أو الحالة:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'مثال: حفرة عميقة بالقرب من التقاطع الرئيسي...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'تحديد الموقع في البصرة:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Color(0xFF10B981),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'إلتقاط أو إرفاق صورة الضرر:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    imageAttached = !imageAttached;
                  });
                },
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: imageAttached ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: imageAttached
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          imageAttached
                              ? Icons.check_circle_rounded
                              : Icons.camera_alt_rounded,
                          color: imageAttached
                              ? const Color(0xFF10B981)
                              : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          imageAttached
                              ? 'تم إرفاق صورة الضرر بنجاح'
                              : 'اضغط لالتقاط صورة الضرر بالكاميرا',
                          style: TextStyle(
                            color: imageAttached
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submitReportToFirebase,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.cloud_upload_rounded,
                          color: Colors.white,
                        ),
                  label: Text(
                    isLoading
                        ? 'جاري الإرسال للسحابة...'
                        : 'إرسال البلاغ إلى السحابة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
