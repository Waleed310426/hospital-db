-- =================================================================
-- الجزء الأول: بناء الإجراءات المخزنة
-- =================================================================
USE HospitalDB1;
GO

IF OBJECT_ID('usp_AddPatient', 'P') IS NOT NULL DROP PROCEDURE usp_AddPatient;
-- 1. إجراء لإضافة مريض جديد
CREATE PROCEDURE usp_AddPatient
    @FirstName NVARCHAR(50), @LastName NVARCHAR(50), @FullName NVARCHAR(152), @DateOfBirth DATE,
    @Gender NVARCHAR(10), @PhoneNumber NVARCHAR(20), @Email NVARCHAR(100), @Address NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Patients WHERE PhoneNumber = @PhoneNumber OR Email = @Email)
    BEGIN
        PRINT N'خطأ: رقم الهاتف أو البريد الإلكتروني مسجل مسبقاً.';
        RETURN;
    END
    INSERT INTO Patients (FirstName, LastName, FullName, DateOfBirth, Gender, PhoneNumber, Email, Address)
    VALUES (@FirstName, @LastName, @FullName, @DateOfBirth, @Gender, @PhoneNumber, @Email, @Address);
    PRINT N'تمت إضافة المريض بنجاح.';
END
GO

-- -----------------------------------------------------------------
-- الخطوة 1: إضافة مريض جديد.
-- -----------------------------------------------------------------
PRINT N'--- [1] اختبار: إضافة مريض جديد "خالد عبدالله اليافعي" ---';
-- نحذف المريض القديم إن وجد لضمان نجاح الإضافة في كل مرة
IF EXISTS (SELECT 1 FROM Patients WHERE PhoneNumber = '770123456')
    DELETE FROM Patients WHERE PhoneNumber = '770123456';
GO

EXEC usp_AddPatient
    @FirstName = N'مجبور', @LastName = N'الجابري', @FullName = N'مجبور عبدالله الجابري',
    @DateOfBirth = '1995-03-20', @Gender = N'ذكر', @PhoneNumber = '770123456',
    @Email = 'majbor.test@email.com', @Address = N'شارع المنصورة، عدن';
GO

IF OBJECT_ID('usp_SearchPatients', 'P') IS NOT NULL DROP PROCEDURE usp_SearchPatients;
-- 2. إجراء للبحث عن مريض
CREATE PROCEDURE usp_SearchPatients
    @SearchTerm NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PatientID, FullName, PhoneNumber, Address, DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age
    FROM Patients
    WHERE (@SearchTerm IS NULL) OR (FullName LIKE '%' + @SearchTerm + '%') OR (PhoneNumber LIKE '%' + @SearchTerm + '%');
END
GO
-- -----------------------------------------------------------------
-- الخطوة 2: البحث عن المريض الذي أضفناه للتأكيد.
-- -----------------------------------------------------------------
PRINT N'--- [2] اختبار: البحث عن المريض برقم هاتفه "770123456" ---';
EXEC usp_SearchPatients @SearchTerm = '770123456';
GO

IF OBJECT_ID('usp_UpdatePatientInfo', 'P') IS NOT NULL DROP PROCEDURE usp_UpdatePatientInfo;
-- 3. إجراء لتحديث بيانات مريض (باستخدام رقم الهاتف للبحث)
CREATE PROCEDURE usp_UpdatePatientInfo
    @OldPhoneNumber NVARCHAR(20),
    @NewPhoneNumber NVARCHAR(20),
    @NewEmail NVARCHAR(100),
    @NewAddress NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Patients
    SET PhoneNumber = @NewPhoneNumber, Email = @NewEmail, Address = @NewAddress
    WHERE PhoneNumber = @OldPhoneNumber;
    PRINT N'تم تحديث بيانات المريض بنجاح.';
END
GO

-- -----------------------------------------------------------------
-- الخطوة 3: تحديث بيانات المريض.
-- -----------------------------------------------------------------
PRINT N'--- [3] اختبار: تحديث بيانات المريض "خالد" ---';
EXEC usp_UpdatePatientInfo
    @OldPhoneNumber = '770123456',
    @NewPhoneNumber = '770123456',
    @NewEmail = 'mmmmm.new@email.com',
    @NewAddress = N'حي السنافر، عدن';
GO
-- نعيد البحث بالرقم الجديد للتأكد من التحديث
PRINT N'--- البحث مرة أخرى بالرقم الجديد "" ---';
EXEC usp_SearchPatients @SearchTerm = '770123456';
GO


IF OBJECT_ID('usp_BookAppointment', 'P') IS NOT NULL DROP PROCEDURE usp_BookAppointment;
-- 4. إجراء لحجز موعد جديد (نسخة محصّنة)
CREATE PROCEDURE usp_BookAppointment
    @PatientPhoneNumber NVARCHAR(20),
    @DoctorID INT,
    @AppointmentDateTime DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    -- التحقق من وجود المريض
    DECLARE @PatientID INT = (SELECT PatientID FROM Patients WHERE PhoneNumber = @PatientPhoneNumber);
    IF @PatientID IS NULL
    BEGIN
        PRINT N'خطأ: لا يوجد مريض بهذا الرقم.';
        RETURN; -- إنهاء الإجراء
    END
    -- التحقق من وجود الطبيب
    IF NOT EXISTS (SELECT 1 FROM Doctors WHERE DoctorID = @DoctorID)
    BEGIN
        PRINT N'خطأ: لا يوجد طبيب بهذا الرقم.';
        RETURN; -- إنهاء الإجراء
    END

    INSERT INTO Appointments (PatientID, DoctorID, AppointmentDateTime, VisitTypeID, AppointmentStatusID)
    VALUES (@PatientID, @DoctorID, @AppointmentDateTime, 37, 26);
    PRINT N'تم حجز الموعد بنجاح.';
END
GO
-- -----------------------------------------------------------------
-- الخطوة 4: حجز موعد (بشكل ذكي)
-- -----------------------------------------------------------------
PRINT N'--- [4] اختبار: حجز موعد للمريض "مجبور" مع أول طبيب في الجدول ---';
DECLARE @FirstDoctorID INT;
SELECT TOP 1 @FirstDoctorID = DoctorID FROM Doctors ORDER BY DoctorID; -- نختار أول طبيب موجود فعلاً

EXEC usp_BookAppointment
    @PatientPhoneNumber = '770123456',
    @DoctorID = @FirstDoctorID, -- نستخدم الرقم الصحيح الذي اخترناه
    @AppointmentDateTime = '2025-09-22 10:00:00';
GO


IF OBJECT_ID('usp_CancelAppointment', 'P') IS NOT NULL DROP PROCEDURE usp_CancelAppointment;

-- 5. إجراء لإلغاء موعد
CREATE PROCEDURE usp_CancelAppointment
    @AppointmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Appointments SET AppointmentStatusID = 28 WHERE AppointmentID = @AppointmentID; -- 3 = ملغي
    PRINT N'تم إلغاء الموعد.';
END
GO
SELECT * FROM InvoiceStatus
-- -----------------------------------------------------------------
-- الخطوة 5: إلغاء الموعد (بشكل ذكي)
-- -----------------------------------------------------------------
PRINT N'--- [6] اختبار: إلغاء آخر موعد تم حجزه للمريض "مجبور" ---';
DECLARE @LastAppointmentID INT;
-- نختار آخر موعد تم حجزه للمريض الذي يستخدم رقم الهاتف هذا
SELECT TOP 1 @LastAppointmentID = ap.AppointmentID
FROM Appointments ap JOIN Patients p ON ap.PatientID = p.PatientID
WHERE p.PhoneNumber = '770123456'
ORDER BY ap.AppointmentID DESC;

EXEC usp_CancelAppointment @AppointmentID = @LastAppointmentID;
GO

IF OBJECT_ID('usp_GetDoctorSchedule', 'P') IS NOT NULL DROP PROCEDURE usp_GetDoctorSchedule;
-- 6. إجراء لعرض جدول الطبيب
CREATE PROCEDURE usp_GetDoctorSchedule
    @DoctorID INT,
    @Date DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.AppointmentID, a.AppointmentDateTime, p.FullName AS PatientName, ast.StatusName
    FROM Appointments a
    JOIN Patients p ON a.PatientID = p.PatientID
    JOIN AppointmentStatus ast ON a.AppointmentStatusID = ast.AppointmentStatusID
    WHERE a.DoctorID = @DoctorID AND CAST(a.AppointmentDateTime AS DATE) = @Date
    ORDER BY a.AppointmentDateTime;
END
GO

-- -----------------------------------------------------------------
-- الخطوة 6: عرض جدول الطبيب
-- -----------------------------------------------------------------
PRINT N'---  اختبار: عرض جدول الطبيب الذي تم حجز الموعد معه ---';
DECLARE @TestDoctorID_6 INT;
SELECT TOP 1 @TestDoctorID_6 = DoctorID FROM Doctors ORDER BY DoctorID;

EXEC usp_GetDoctorSchedule
    @DoctorID = @TestDoctorID_6,
    @Date = '2025-09-22';
GO







IF OBJECT_ID('usp_CreateInvoiceForEncounter', 'P') IS NOT NULL DROP PROCEDURE usp_CreateInvoiceForEncounter;

-- 7. إجراء لإنشاء فاتورة
CREATE PROCEDURE usp_CreateInvoiceForEncounter
    @EncounterID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- التحقق من وجود الزيارة
    IF NOT EXISTS (SELECT 1 FROM Encounters WHERE EncounterID = @EncounterID)
    BEGIN
        PRINT N'خطأ: الزيارة (Encounter) غير موجودة.';
        RETURN;
    END
    -- التحقق من عدم وجود فاتورة مسبقة
    IF EXISTS (SELECT 1 FROM Invoices WHERE EncounterID = @EncounterID)
    BEGIN
        PRINT N'خطأ: توجد فاتورة بالفعل لهذه الزيارة.';
        RETURN;
    END

    DECLARE @PatientID INT = (SELECT PatientID FROM Encounters WHERE EncounterID = @EncounterID);
    INSERT INTO Invoices (PatientID, EncounterID, InvoiceDate, TotalAmount, InvoiceStatusID)
    VALUES (@PatientID, @EncounterID, GETDATE(), 15000, 26);
    PRINT N'تم إنشاء الفاتورة بنجاح.';
END
GO
-- -----------------------------------------------------------------
-- الخطوة 7: إنشاء فاتورة (بشكل ذكي)
-- -----------------------------------------------------------------
PRINT N'--- [7] اختبار: إنشاء فاتورة لآخر زيارة ليس لها فاتورة ---';
DECLARE @EncounterToTest INT;
-- نختار آخر زيارة في النظام ليس لها فاتورة
SELECT TOP 1 @EncounterToTest = e.EncounterID
FROM Encounters e LEFT JOIN Invoices i ON e.EncounterID = i.EncounterID
WHERE i.InvoiceID IS NULL ORDER BY e.EncounterID DESC;

IF @EncounterToTest IS NOT NULL
BEGIN
    EXEC usp_CreateInvoiceForEncounter @EncounterID = @EncounterToTest;
    SELECT * FROM Invoices WHERE EncounterID = @EncounterToTest;
END
ELSE
    PRINT N'لا توجد زيارات بدون فواتير لإنشاء فاتورة لها.';
GO



IF OBJECT_ID('usp_RegisterPayment', 'P') IS NOT NULL DROP PROCEDURE usp_RegisterPayment;
GO
-- 8. إجراء لتسجيل دفعة
CREATE PROCEDURE usp_RegisterPayment
    @InvoiceID INT,
    @AmountPaid DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;
    -- التحقق من وجود الفاتورة
    IF NOT EXISTS (SELECT 1 FROM Invoices WHERE InvoiceID = @InvoiceID)
    BEGIN
        PRINT N'خطأ: الفاتورة غير موجودة.';
        RETURN;
    END

    INSERT INTO Payments (InvoiceID, PaymentDate, Amount, PaymentMethod)
    VALUES (@InvoiceID, GETDATE(), @AmountPaid, N'نقداً');
    UPDATE Invoices SET AmountPaid = AmountPaid + @AmountPaid WHERE InvoiceID = @InvoiceID;
    UPDATE Invoices SET InvoiceStatusID = 25 WHERE InvoiceID = @InvoiceID AND AmountPaid < TotalAmount;
    UPDATE Invoices SET InvoiceStatusID = 26 WHERE InvoiceID = @InvoiceID AND AmountPaid >= TotalAmount;
    PRINT N'تم تسجيل الدفعة بنجاح.';
END
GO

-- -----------------------------------------------------------------
-- الخطوة 8: تسجيل دفعة (بشكل ذكي)
-- -----------------------------------------------------------------
PRINT N'--- [8] اختبار: تسجيل دفعة لآخر فاتورة غير مدفوعة بالكامل ---';
DECLARE @InvoiceToTest INT;
-- نختار آخر فاتورة لم يتم دفعها بالكامل
SELECT TOP 1 @InvoiceToTest = InvoiceID FROM Invoices WHERE InvoiceStatusID != 1 ORDER BY InvoiceID DESC;

IF @InvoiceToTest IS NOT NULL
BEGIN
    EXEC usp_RegisterPayment @InvoiceID = @InvoiceToTest, @AmountPaid = 5000;
    SELECT * FROM Invoices WHERE InvoiceID = @InvoiceToTest;
END
ELSE
    PRINT N'لا توجد فواتير مفتوحة لتسجيل دفعة لها.';
GO
