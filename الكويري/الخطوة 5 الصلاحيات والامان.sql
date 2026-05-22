-- أولاً: إنشاء تسجيلات الدخول على مستوى الخادم
USE master;
GO
CREATE LOGIN Waleed WITH PASSWORD = '123';
CREATE LOGIN Abdalaleem WITH PASSWORD = '124';
CREATE LOGIN Mohammed WITH PASSWORD = '125';
CREATE LOGIN Ahmed WITH PASSWORD = '126';
CREATE LOGIN Oqba WITH PASSWORD = '127';
GO
PRINT N'تم إنشاء تسجيلات الدخول.';

-- ثانياً: إنشاء الأدوار داخل قاعدة البيانات
USE HospitalDB1;
GO
CREATE ROLE DoctorRole;
CREATE ROLE PatientRole;
CREATE ROLE AccountantRole;
CREATE ROLE NurseRole;
CREATE ROLE ReceptionRole;
GO
PRINT N'تم إنشاء الأدوار.';

-- ثالثاً: إنشاء المستخدمين وربطهم بالأدوار (هذا هو الجزء الذي تم تصحيحه)
USE HospitalDB1;
GO
-- الدكتور وليد
CREATE USER Walid FOR LOGIN Waleed;
EXEC sp_addrolemember 'DoctorRole', 'Walid';
GO
-- المريض عبدالعليم
CREATE USER Abdulaleem FOR LOGIN Abdalaleem;
EXEC sp_addrolemember 'PatientRole', 'Abdulaleem';
GO
-- المحاسب محمد
CREATE USER Mohammed FOR LOGIN Mohammed;
EXEC sp_addrolemember 'AccountantRole', 'Mohammed';
GO
-- الممرض أحمد
CREATE USER Ahmed FOR LOGIN Ahmed;
EXEC sp_addrolemember 'NurseRole', 'Ahmed';
GO
-- موظف الاستقبال عقبة
CREATE USER Oqba FOR LOGIN Oqba;
EXEC sp_addrolemember 'ReceptionRole', 'Oqba';
GO
PRINT N'تم إنشاء المستخدمين وربطهم بالأدوار بشكل صحيح.';



-- =================================================================
-- تأمين الصلاحيات باستخدام DENY (سحب الصلاحيات غير المرغوب فيها)
-- =================================================================
USE HospitalDB1;
GO

PRINT N'--- تأمين صلاحيات دور موظف الاستقبال (ReceptionRole) ---';
-- نمنع موظف الاستقبال صراحةً من قراءة أي جدول مالي أو طبي
DENY SELECT ON Invoices TO ReceptionRole;
DENY SELECT ON InvoiceItems TO ReceptionRole;
DENY SELECT ON Payments TO ReceptionRole;
DENY SELECT ON Diagnoses TO ReceptionRole;
DENY SELECT ON Prescriptions TO ReceptionRole;
GO

PRINT N'--- تأمين صلاحيات دور المحاسب (AccountantRole) ---';
-- نمنع المحاسب صراحةً من قراءة أي جدول طبي حساس
DENY SELECT ON Diagnoses TO AccountantRole;
DENY SELECT ON Procedures TO AccountantRole;
DENY SELECT ON Prescriptions TO AccountantRole;
DENY SELECT ON PrescriptionItems TO AccountantRole;
DENY SELECT ON Encounters TO AccountantRole;
GO

PRINT N'--- تأمين صلاحيات دور المريض (PatientRole) ---';
-- نمنع المريض صراحةً من قراءة بيانات الموظفين أو المرضى الآخرين
DENY SELECT ON Doctors TO PatientRole;
DENY SELECT ON Nurses TO PatientRole;
GO

PRINT N'============================================================';
PRINT N'== اكتمل تأمين الصلاحيات باستخدام DENY ==';
PRINT N'============================================================';
GO




-- =================================================================
-- منح الصلاحيات (Permissions) للأدوار على الجداول والأعمدة والإجراءات
-- =================================================================
USE HospitalDB1; -- نتأكد من أننا في قاعدة البيانات الصحيحة
GO

-- =================================================================
-- 1. صلاحيات دور موظف الاستقبال (ReceptionRole)
-- الهدف: البحث عن المرضى، إضافة مرضى جدد، حجز وتعديل المواعيد.
-- الأسلوب الأفضل: استخدام الإجراءات المخزنة.
-- =================================================================
PRINT N'--- منح صلاحيات لدور موظف الاستقبال (ReceptionRole) ---';

-- صلاحية تنفيذ (EXECUTE) الإجراءات المخزنة الخاصة بوظيفته
GRANT EXECUTE ON usp_AddPatient TO ReceptionRole;       -- لإضافة مريض جديد
GRANT EXECUTE ON usp_SearchPatients TO ReceptionRole;   -- للبحث عن المرضى
GRANT EXECUTE ON usp_UpdatePatientInfo TO ReceptionRole;-- لتحديث معلومات الاتصال للمريض
GRANT EXECUTE ON usp_BookAppointment TO ReceptionRole;  -- لحجز موعد
GRANT EXECUTE ON usp_CancelAppointment TO ReceptionRole;-- لإلغاء موعد
GO

-- =================================================================
-- 2. صلاحيات دور المحاسب (AccountantRole)
-- الهدف: إدارة الفواتير والمدفوعات. لا يجب أن يرى المعلومات الطبية.
-- الأسلوب: صلاحيات مباشرة على جداول الفوترة + صلاحيات على بعض الإجراءات.
-- =================================================================
PRINT N'--- منح صلاحيات لدور المحاسب (AccountantRole) ---';

-- صلاحية القراءة (SELECT) على جداول الفواتير والمدفوعات
GRANT SELECT ON Invoices TO AccountantRole;
GRANT SELECT ON InvoiceItems TO AccountantRole;
GRANT SELECT ON Payments TO AccountantRole;

-- صلاحية القراءة (SELECT) على جدول المرضى لمعرفة لمن يصدر الفاتورة
GRANT SELECT ON Patients TO AccountantRole;

-- صلاحية تنفيذ (EXECUTE) الإجراءات الخاصة بالفوترة
GRANT EXECUTE ON usp_CreateInvoiceForEncounter TO AccountantRole;
GRANT EXECUTE ON usp_RegisterPayment TO AccountantRole;
GO

-- =================================================================
-- 3. صلاحيات دور الطبيب (DoctorRole)
-- الهدف: الوصول الكامل للمعلومات الطبية للمرضى.
-- الأسلوب: صلاحيات واسعة على الجداول الطبية + صلاحيات على الإجراءات.
-- =================================================================
PRINT N'--- منح صلاحيات لدور الطبيب (DoctorRole) ---';

-- صلاحية القراءة (SELECT) على بيانات المرضى
GRANT SELECT ON Patients TO DoctorRole;

-- صلاحيات كاملة (SELECT, INSERT, UPDATE, DELETE) على الجداول الطبية
GRANT SELECT, INSERT, UPDATE, DELETE ON Encounters TO DoctorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Diagnoses TO DoctorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Procedures TO DoctorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Prescriptions TO DoctorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON PrescriptionItems TO DoctorRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON BedAssignments TO DoctorRole;

-- صلاحية القراءة فقط على جدول الأدوية لاختيار دواء
GRANT SELECT ON Drugs TO DoctorRole;

-- صلاحية تنفيذ (EXECUTE) الإجراء الخاص بعرض جدوله الزمني
GRANT EXECUTE ON usp_GetDoctorSchedule TO DoctorRole;
GO

-- =================================================================
-- 4. صلاحيات دور الممرض (NurseRole)
-- الهدف: عرض معلومات المرضى والزيارات، وتحديث بعض البيانات الحيوية.
-- الأسلوب: صلاحيات محددة على جداول وأعمدة.
-- =================================================================
PRINT N'--- منح صلاحيات لدور الممرض (NurseRole) ---';

-- صلاحية القراءة (SELECT) على جدول المرضى
GRANT SELECT ON Patients TO NurseRole;

-- صلاحية القراءة (SELECT) على جدول الزيارات والتشخيصات
GRANT SELECT ON Encounters TO NurseRole;
GRANT SELECT ON Diagnoses TO NurseRole;

-- صلاحية تحديث (UPDATE) أعمدة معينة فقط في جدول الزيارات (مثلاً، إضافة ملاحظات)
GRANT UPDATE (ChiefComplaint) ON Encounters TO NurseRole;
GO

-- =================================================================
-- 5. صلاحيات دور المريض (PatientRole)
-- الهدف: عرض بياناته الشخصية ومواعيده وفواتيره فقط.
-- الأسلوب: صلاحيات قراءة (SELECT) على جداول متعددة، ولكن يجب تقييدها لاحقاً
-- في التطبيق ليرى بياناته فقط (هذا لا يمكن عمله بالصلاحيات وحدها).
-- =================================================================
PRINT N'--- منح صلاحيات لدور المريض (PatientRole) ---';

-- صلاحية قراءة (SELECT) أعمدة محددة فقط من بياناته الشخصية (لا يرى مثلاً تاريخ التسجيل)
GRANT SELECT (FullName, DateOfBirth, Gender, PhoneNumber, Email, Address) ON Patients TO PatientRole;

-- صلاحية قراءة (SELECT) مواعيده
GRANT SELECT ON Appointments TO PatientRole;

-- صلاحية قراءة (SELECT) فواتيره
GRANT SELECT ON Invoices TO PatientRole;
GRANT SELECT ON InvoiceItems TO PatientRole;
GO

PRINT N'============================================================';
PRINT N'== اكتمل منح جميع الصلاحيات للأدوار بنجاح ==';
PRINT N'============================================================';
GO

