-- =================================================================
-- مثال على أمر INSERT: تسجيل مريض جديد
-- =================================================================
PRINT N'--- [1] جاري إضافة مريض جديد... ---';

-- نستخدم INSERT INTO ثم نحدد اسم الجدول والأعمدة التي سنضيف فيها البيانات
INSERT INTO Patients (
    FirstName, 
    LastName, 
    FullName, 
    DateOfBirth, 
    Gender, 
    PhoneNumber, 
    Email, 
    Address
)
-- ثم نستخدم VALUES لتحديد القيم التي نريد إضافتها بنفس ترتيب الأعمدة أعلاه
VALUES (
    N'علي',                      -- FirstName
    N'اليافعي',                  -- LastName
    N'علي ناصر اليافعي',         -- FullName
    '1985-05-15',                -- DateOfBirth (تنسيق YYYY-MM-DD)
    N'ذكر',                      -- Gender
    '777999888',                 -- PhoneNumber (يجب أن يكون فريداً)
    'ali.nasser@email.com',      -- Email (يجب أن يكون فريداً)
    N'شارع الشوارع، حي الوحدة، صعدة' -- Address
);

-- للتأكد من أن المريض قد تمت إضافته، يمكننا البحث عنه مباشرة
PRINT N'تم إضافة المريض بنجاح. جاري البحث عنه للتأكيد:';
SELECT * FROM Patients WHERE PhoneNumber = '777999888';
GO



-- =================================================================
-- مثال على أمر UPDATE: تحديث بيانات مريض
-- =================================================================
PRINT N'--- [2] جاري تحديث بيانات المريض... ---';

-- نستخدم UPDATE ثم نحدد اسم الجدول
UPDATE Patients
-- نستخدم SET لتحديد العمود والقيمة الجديدة
SET 
    PhoneNumber = '771234567',  -- القيمة الجديدة لرقم الهاتف
    Address = N'شارع الجزائر، حي التحرير، صنعاء' -- القيمة الجديدة للعنوان
-- نستخدم WHERE لتحديد السجل الذي نريد تحديثه بالضبط
WHERE 
    PatientID = (SELECT PatientID FROM Patients WHERE Email = 'ali.nasser@email.com'); -- نستخدم البريد الإلكتروني الفريد لتحديد المريض

-- للتأكد من أن البيانات قد تم تحديثها
PRINT N'تم تحديث البيانات بنجاح. جاري عرض البيانات الجديدة:';
SELECT * FROM Patients WHERE Email = 'ali.nasser@email.com';
GO


-- مثال آخر على UPDATE: تحديث حالة فاتورة بعد أن قام المريض بدفعها
PRINT N'--- [2.1] تحديث حالة فاتورة من "غير مدفوعة" إلى "مدفوعة بالكامل" ---';
UPDATE Invoices
SET 
    InvoiceStatusID = (SELECT InvoiceStatusID FROM InvoiceStatus WHERE StatusName = N'مدفوعة بالكامل'),
    AmountPaid = TotalAmount -- نجعل المبلغ المدفوع مساوياً للمبلغ الإجمالي
WHERE 
    InvoiceID = 10; -- نفترض أننا نحدث الفاتورة رقم 10
GO


-- =================================================================
-- مثال على أمر DELETE: حذف سجل موعد
-- =================================================================
PRINT N'--- [3] جاري حذف موعد... ---';

-- قبل الحذف، من الجيد دائماً عرض السجل الذي ننوي حذفه للتأكد
PRINT N'الموعد الذي سيتم حذفه (رقم 5):';
SELECT * FROM Appointments WHERE AppointmentID = 5;

-- نستخدم DELETE FROM ثم نحدد اسم الجدول
DELETE FROM Appointments
-- نستخدم WHERE لتحديد السجل الذي نريد حذفه
WHERE 
    AppointmentID = 5;

-- للتأكد من أن الموعد قد تم حذفه
PRINT N'تم حذف الموعد. جاري محاولة البحث عنه مرة أخرى (يجب ألا تظهر نتائج):';
SELECT * FROM Appointments WHERE AppointmentID = 5;
GO

