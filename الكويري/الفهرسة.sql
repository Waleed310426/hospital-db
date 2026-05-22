-- =================================================================
-- الخطوة 7: إنشاء فهارس لتحسين أداء الاستعلامات
-- =================================================================
USE HospitalDB1;
GO

PRINT N'--- [1] إنشاء فهارس على جدول المرضى (Patients) ---';
-- فهرس على رقم الهاتف، لأنه يُستخدم بكثرة للبحث عن المرضى (مثلاً في إجراء usp_SearchPatients)
-- UNIQUE يضمن عدم تكرار رقم الهاتف ويسرّع البحث أكثر.
CREATE UNIQUE NONCLUSTERED INDEX IX_Patients_PhoneNumber
ON Patients(PhoneNumber);
GO

-- فهرس على اسم المريض الكامل، لأنه يُستخدم أيضاً للبحث.
CREATE NONCLUSTERED INDEX IX_Patients_FullName
ON Patients(FullName);
GO

PRINT N'--- [2] إنشاء فهارس على جدول المواعيد (Appointments) ---';
-- هذا فهرس مركب (Composite Index) مهم جداً.
-- يُستخدم لتحسين سرعة البحث عن مواعيد طبيب معين في تاريخ معين (مثل إجراء usp_GetDoctorSchedule).
-- ترتيب الأعمدة مهم: نضع DoctorID أولاً ثم AppointmentDateTime لأنه الأكثر استخداماً للتصفية.
CREATE NONCLUSTERED INDEX IX_Appointments_Doctor_Date
ON Appointments(DoctorID, AppointmentDateTime);
GO

-- فهرس على مفتاح المريض الخارجي (PatientID) لتسريع البحث عن جميع مواعيد مريض معين.
CREATE NONCLUSTERED INDEX IX_Appointments_PatientID
ON Appointments(PatientID);
GO

PRINT N'--- [3] إنشاء فهرس على جدول الزيارات (Encounters) ---';
-- فهرس على مفتاح الطبيب الخارجي (DoctorID) لتسريع الاستعلامات التي تحلل أداء الأطباء.
CREATE NONCLUSTERED INDEX IX_Encounters_DoctorID
ON Encounters(DoctorID);
GO

PRINT N'--- [4] إنشاء فهرس مغطّي (Covering Index) على جدول الفواتير (Invoices) ---';
-- هذا النوع من الفهارس متقدم ومفيد جداً، وهو مشابه للمثال الذي أعطيته.
-- الهدف: تسريع الاستعلامات التي تبحث عن فواتير مريض معين وحالتها.
-- INCLUDE: نضيف الأعمدة التي نحتاجها في جملة SELECT إلى الفهرس نفسه.
-- الميزة: SQL Server يجد كل المعلومات التي يحتاجها (TotalAmount, InvoiceStatusID) داخل الفهرس
-- ولا يحتاج للعودة إلى الجدول الأصلي أبداً (وهذا يسمى "Covering the query").
CREATE NONCLUSTERED INDEX IX_Invoices_Patient_Status
ON Invoices(PatientID) -- العمود الذي نبحث به في WHERE
INCLUDE (TotalAmount, InvoiceStatusID, InvoiceDate); -- الأعمدة التي نريد عرضها في SELECT
GO

PRINT N'============================================================';
PRINT N'== اكتمل إنشاء جميع الفهارس لتحسين الأداء ==';
PRINT N'============================================================';




PRINT N'--- إنشاء فهرس مُرشَّح للمواعيد المجدولة فقط ---';

-- أولاً، نحتاج لمعرفة الـ ID الخاص بحالة "مجدول"
-- لنفترض أنه 1 بناءً على البيانات التي أدخلناها سابقاً.
-- SELECT AppointmentStatusID FROM AppointmentStatus WHERE StatusName = N'مجدول'; -- (النتيجة ستكون 1)

CREATE NONCLUSTERED INDEX IX_Appointments_Scheduled
ON Appointments(DoctorID, AppointmentDateTime) -- نفس أعمدة الفهرس السابق
WHERE AppointmentStatusID = 1; -- هذا هو شرط الفلترة!
GO

PRINT N'تم إنشاء الفهرس المُرشَّح بنجاح.';



SET NOCOUNT ON;
SELECT AppointmentDateTime, PatientID
FROM Appointments
WHERE DoctorID = 4081 AND AppointmentDateTime >= '2025-01-01';


select * from Doctors

SELECT PatientID, AdmissionDate
FROM BedAssignments
WHERE DischargeDate IS NULL; 

SELECT *
FROM BedAssignments
WHERE DischargeDate IS NULL; 

SET NOCOUNT OFF;




--====================================================================
-- يجلب كل الأعمدة، مما يهدر الموارد
SELECT * 
FROM Patients;


-- يجلب فقط الأعمدة المطلوبة، وهو أسرع وأكثر كفاءة
SELECT FullName, PhoneNumber 
FROM Patients;


-- أبطأ: يجمع كل أرقام الأطباء من المواعيد أولاً
SELECT DoctorID, FullName
FROM Doctors
WHERE DoctorID IN (
    SELECT DoctorID FROM Appointments
);

-- أسرع: يتوقف عند أول تطابق لكل طبيب
SELECT d.DoctorID, d.FullName
FROM Doctors d
WHERE EXISTS (
    SELECT 1 -- نضع 1 فقط لأننا نهتم بالوجود وليس بالقيمة
    FROM Appointments a
    WHERE a.DoctorID = d.DoctorID
);

-- شرط WHERE s.Gender = N'أنثى' غير ضروري للطلب الحالي ويعقد الاستعلام
SELECT 
    e.EncounterID,
    e.EncounterDateTime,
    p.FullName
FROM 
    Encounters e
JOIN 
    Patients p ON e.PatientID = p.PatientID
WHERE 
    p.Gender = N'أنثى'; -- شرط إضافي غير مطلوب

    -- الاستعلام الآن أبسط ويؤدي الغرض المطلوب فقط
SELECT 
    e.EncounterID,
    e.EncounterDateTime,
    p.FullName
FROM 
    Encounters e
JOIN 
    Patients p ON e.PatientID = p.PatientID;


    -- الإجراء المحسّن
ALTER PROCEDURE usp_AddPatient
    @FirstName NVARCHAR(50), @LastName NVARCHAR(50), @FullName NVARCHAR(152), @DateOfBirth DATE,
    @Gender NVARCHAR(10), @PhoneNumber NVARCHAR(20), @Email NVARCHAR(100), @Address NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON; -- يمنع إرسال رسالة "rows affected"

    INSERT INTO Patients (FirstName, LastName, FullName, DateOfBirth, Gender, PhoneNumber, Email, Address)
    VALUES (@FirstName, @LastName, @FullName, @DateOfBirth, @Gender, @PhoneNumber, @Email, @Address);
END
