import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF132A53), Color(0xFF071021)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // الشريط العلوي
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'شروط وأحكام الاستخدام',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 12),

                // نص المقدمة وتاريخ التحديث
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'آخر تحديث: 19 سبتمبر 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'مرحبًا بك في تطبيق SaYo Star. باستخدامك التطبيق أو إنشاء حساب فيه، فإنك توافق على الالتزام بهذه الشروط والأحكام.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // القائمة القابلة للتمرير للشروط الـ 15
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      _TermCard(
                        icon: Icons.app_shortcut_outlined,
                        title: '1. استخدام التطبيق',
                        content:
                            'SaYo Star هو تطبيق ترفيهي واجتماعي يتيح للمستخدمين التواصل من خلال الغرف الصوتية والمحادثات والملفات الشخصية والألعاب والميزات الاجتماعية المتاحة داخل التطبيق.\n\nيجب استخدام التطبيق بطريقة قانونية ومحترمة، ويُمنع استخدامه لأي نشاط مخالف للقوانين أو لهذه الشروط.',
                      ),
                      _TermCard(
                        icon: Icons.account_circle_outlined,
                        title: '2. الحساب',
                        content:
                            '• يجب تقديم معلومات صحيحة عند إنشاء الحساب.\n• المستخدم مسؤول عن المحافظة على أمان حسابه.\n• يمنع انتحال شخصية شخص آخر أو استخدام هوية مزيفة بهدف خداع الآخرين.\n• يمنع إنشاء حسابات متعددة بهدف إساءة استخدام خدمات التطبيق أو التحايل على العقوبات.\n• يحق لإدارة SaYo Star اتخاذ الإجراءات المناسبة عند اكتشاف إساءة استخدام الحساب.',
                      ),
                      _TermCard(
                        icon: Icons.mic_off_outlined,
                        title: '3. قواعد الغرف الصوتية والمحادثات',
                        content:
                            'يُمنع داخل الغرف والمحادثات:\n• الإساءة أو الإهانة أو التنمر على الآخرين.\n• التهديد أو الابتزاز أو المضايقة.\n• نشر محتوى جنسي أو غير مناسب.\n• نشر خطاب كراهية أو محتوى يحرض على العنف.\n• انتحال شخصيات أو جهات أخرى.\n• نشر معلومات شخصية عن الآخرين دون إذنهم.\n• إرسال رسائل مزعجة أو إعلانات غير مصرح بها.\n• استخدام التطبيق للاحتيال أو خداع المستخدمين.\n• تسجيل أو نشر محادثات أو أصوات الآخرين دون الحصول على الإذن اللازم، مع مراعاة القوانين المحلية.',
                      ),
                      _TermCard(
                        icon: Icons.post_add_outlined,
                        title: '4. المحتوى الذي ينشره المستخدمون',
                        content:
                            'قد يسمح SaYo Star للمستخدمين بإضافة صور أو أسماء أو أوصاف أو رسائل أو محتوى آخر.\n\nالمستخدم مسؤول عن المحتوى الذي ينشره، ويجب ألا ينشر أي محتوى مخالف للقوانين أو هذه الشروط.\n\nتحتفظ إدارة SaYo Star بحق مراجعة أو حذف المحتوى المخالف واتخاذ الإجراءات المناسبة بحق الحساب المسؤول عنه.',
                      ),
                      _TermCard(
                        icon: Icons.report_problem_outlined,
                        title: '5. الإبلاغ والحظر',
                        content:
                            'يمكن للمستخدم الإبلاغ عن الحسابات أو المحتوى المخالف من خلال وسائل الإبلاغ المتاحة داخل التطبيق.\n\nيمكن للمستخدم حظر مستخدم آخر لمنع التواصل غير المرغوب فيه.\n\nتراجع إدارة SaYo Star البلاغات وفقًا للإجراءات المتاحة لديها، وقد تؤدي المخالفات إلى تحذير أو تقييد بعض الميزات أو تعليق الحساب أو إغلاقه.',
                      ),
                      _TermCard(
                        icon: Icons.verified_user_outlined,
                        title: '6. السلامة وحماية المستخدمين',
                        content:
                            'يجب عدم مشاركة المعلومات الشخصية الحساسة مع أشخاص لا تعرفهم عبر التطبيق، مثل كلمات المرور أو رموز التحقق أو المعلومات المالية.\n\nSaYo Star لا يضمن أن جميع المعلومات التي يقدمها المستخدمون صحيحة أو أن جميع الأشخاص يستخدمون هوياتهم الحقيقية، لذلك يجب توخي الحذر عند التواصل مع الآخرين.',
                      ),
                      _TermCard(
                        icon: Icons.child_care_outlined,
                        title: '7. العمر والاستخدام المناسب',
                        content:
                            'يجب استخدام التطبيق وفق الفئة العمرية المسموح بها في بلد المستخدم ومتطلبات متجر Google Play والقوانين المحلية.\n\nلا يجوز استخدام التطبيق من قبل الأطفال في الحالات التي تمنع فيها القوانين أو سياسات المتجر ذلك.\n\nوبما أن SaYo Star يحتوي على ميزات اجتماعية ودردشة بين المستخدمين، يجب تحديد الفئة العمرية المناسبة في Google Play بدقة وتطبيق متطلبات السلامة المناسبة.',
                      ),
                      _TermCard(
                        icon: Icons.sports_esports_outlined,
                        title: '8. الألعاب والميزات الترفيهية',
                        content:
                            'قد يحتوي التطبيق على ألعاب وميزات ترفيهية.\n\nيُمنع استخدام أي ميزة داخل التطبيق بطريقة تخالف القوانين أو بهدف الاحتيال أو استغلال المستخدمين.',
                      ),
                      _TermCard(
                        icon: Icons.copyright_outlined,
                        title: '9. الملكية الفكرية',
                        content:
                            'جميع حقوق SaYo Star المتعلقة بالاسم والعلامة التجارية والتصميم والبرمجيات والمواد التي تملكها الشركة أو صاحب التطبيق محفوظة.\n\nلا يجوز نسخ أو إعادة توزيع أو بيع أو تعديل أجزاء من التطبيق دون الحصول على إذن مسبق من صاحب الحقوق.',
                      ),
                      _TermCard(
                        icon: Icons.block_outlined,
                        title: '10. إيقاف أو تعليق الحساب',
                        content:
                            'يحق لإدارة SaYo Star تعليق أو إغلاق الحساب في حال:\n• مخالفة هذه الشروط.\n• إساءة استخدام التطبيق.\n• نشر محتوى مخالف.\n• الاحتيال أو محاولة الاحتيال.\n• مضايقة أو تهديد المستخدمين.\n• محاولة اختراق التطبيق أو أنظمته.\n• استخدام وسائل آلية أو أدوات غير مصرح بها للتلاعب بالخدمات.\n\nوقد يتم اتخاذ الإجراء المناسب حسب طبيعة المخالفة وتكرارها.',
                      ),
                      _TermCard(
                        icon: Icons.cloud_done_outlined,
                        title: '11. توفر الخدمة',
                        content:
                            'نسعى إلى إبقاء SaYo Star متاحًا بصورة مستقرة، ولكن قد تحدث أحيانًا أعطال أو صيانة أو تحديثات أو مشاكل تقنية خارجة عن سيطرتنا.\n\nلا نضمن أن التطبيق سيعمل دون انقطاع أو أخطاء في جميع الأوقات.',
                      ),
                      _TermCard(
                        icon: Icons.privacy_tip_outlined,
                        title: '12. الخصوصية',
                        content:
                            'يتم التعامل مع بيانات المستخدم وفق سياسة الخصوصية الخاصة بـ SaYo Star.\n\nيجب أن توضح سياسة الخصوصية بشكل منفصل البيانات التي يتم جمعها وكيفية استخدامها وتخزينها ومشاركتها وحقوق المستخدمين.',
                      ),
                      _TermCard(
                        icon: Icons.update_outlined,
                        title: '13. التعديلات على الشروط',
                        content:
                            'قد نقوم بتحديث هذه الشروط من وقت لآخر بسبب إضافة ميزات جديدة أو تغييرات قانونية أو تقنية.\n\nسيتم نشر النسخة المحدثة داخل التطبيق أو عبر الوسيلة المناسبة، ويعتبر استمرار استخدام التطبيق بعد التحديث قبولًا بالشروط الجديدة، بالقدر الذي يسمح به القانون.',
                      ),
                      _TermCard(
                        icon: Icons.contact_support_outlined,
                        title: '14. التواصل مع الإدارة',
                        content:
                            'إذا كان لديك استفسار أو بلاغ أو شكوى تتعلق بالتطبيق، يمكنك التواصل مع فريق SaYo Star من خلال وسيلة التواصل الرسمية الموجودة داخل التطبيق.',
                      ),
                      _TermCard(
                        icon: Icons.check_circle_outline,
                        title: '15. قبول الشروط',
                        content:
                            'عند إنشاء حساب أو استخدام SaYo Star، فإنك تؤكد أنك قرأت هذه الشروط وفهمتها وتوافق على الالتزام بها.',
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // زر الموافقة
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      'أوافق على الشروط والأحكام',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// كارت لعرض البند الواحدة بشكل منظم
class _TermCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _TermCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF64B5F6), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
