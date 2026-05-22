/* ===================== إعداد ===================== */
USE HospitalDB1;
SET NOCOUNT ON;

DECLARE @NumPatients     INT     = 12000;
DECLARE @NumDoctors      INT     = 3000;
DECLARE @NumNurses       INT     = 6000;
DECLARE @NumRooms        INT     = 5000;
DECLARE @NumDrugs        INT     = 2000;
DECLARE @NumAppointments INT     = 300000;
DECLARE @SeedOffset      BIGINT  = 1000000;

/* ===================== قوائم مساعدة (مؤقتة) ===================== */
IF OBJECT_ID('tempdb..#Governorates') IS NOT NULL DROP TABLE #Governorates;
CREATE TABLE #Governorates (GovID INT IDENTITY(1,1) PRIMARY KEY, GovName NVARCHAR(100) UNIQUE);
INSERT INTO #Governorates (GovName) VALUES
(N'أمانة العاصمة'),(N'صنعاء'),(N'عدن'),(N'تعز'),(N'الحديدة'),
(N'إب'),(N'ذمار'),(N'عمران'),(N'صعدة'),(N'حجة'),
(N'المحويت'),(N'ريمة'),(N'الضالع'),(N'لحج'),(N'أبين'),
(N'شبوة'),(N'حضرموت'),(N'المهرة'),(N'البيضاء'),(N'مأرب'),
(N'الجوف'),(N'سقطرى');

IF OBJECT_ID('tempdb..#Cities') IS NOT NULL DROP TABLE #Cities;
CREATE TABLE #Cities (CityID INT IDENTITY(1,1) PRIMARY KEY, GovID INT NOT NULL, CityName NVARCHAR(100) NOT NULL);
INSERT INTO #Cities (GovID, CityName)
SELECT g.GovID, v.CityName
FROM #Governorates g
JOIN (VALUES
(N'أمانة العاصمة',N'صنعاء'),
(N'صنعاء',N'بني حشيش'),
(N'عدن',N'كريتر'),
(N'تعز',N'تعز'),
(N'الحديدة',N'الحديدة'),
(N'إب',N'إب'),
(N'ذمار',N'ذمار'),
(N'عمران',N'عمران'),
(N'صعدة',N'صعدة'),
(N'حجة',N'حجة'),
(N'المحويت',N'المحويت'),
(N'ريمة',N'الجبين'),
(N'الضالع',N'الضالع'),
(N'لحج',N'الحوطة'),
(N'أبين',N'زنجبار'),
(N'شبوة',N'عتق'),
(N'حضرموت',N'المكلا'),
(N'المهرة',N'الغيضة'),
(N'البيضاء',N'البيضاء'),
(N'مأرب',N'مأرب'),
(N'الجوف',N'الحزم'),
(N'سقطرى',N'حديبو')
) v(GovName,CityName) ON v.GovName = g.GovName;

IF OBJECT_ID('tempdb..#Streets') IS NOT NULL DROP TABLE #Streets;
CREATE TABLE #Streets (StreetID INT IDENTITY(1,1) PRIMARY KEY, StreetName NVARCHAR(200) UNIQUE);
INSERT INTO #Streets (StreetName) VALUES
(N'شارع النصر'),(N'شارع الوحدة'),(N'شارع تعز'),(N'شارع الستين'),(N'شارع التحرير'),
(N'شارع الملك'),(N'شارع الحرية'),(N'شارع الجامعة'),(N'شارع الثورة'),(N'شارع صنعاء');

IF OBJECT_ID('tempdb..#GivenNames') IS NOT NULL DROP TABLE #GivenNames;
CREATE TABLE #GivenNames (Name NVARCHAR(50));
INSERT INTO #GivenNames VALUES
(N'أحمد'),(N'محمد'),(N'علي'),(N'سالم'),(N'عمر'),(N'يوسف'),
(N'مصطفى'),(N'عبدالله'),(N'خالد'),(N'إبراهيم'),
(N'سعيد'),(N'حسن'),(N'نبيل'),(N'رامي'),(N'طارق'),
(N'ناصر'),(N'صالح'),(N'مروان'),(N'مازن'),(N'زياد')
,(N'قاسم'),(N'محمود'),(N'عقبة'),(N'يونس'),(N'مهند'),(N'رياض'),(N'وليد'),(N'عبدالعليم'),(N'نجيب'),(N'مفرح'),(N'اسامة'),(N'نخران'),(N'نجران'),(N'كرار')
,(N'جني'),(N'عصيد'),(N'جميز'),(N'ديمو'),(N'حمي'),(N'علوش'),(N'يام'),(N'قرموم'),(N'بعسوس');

IF OBJECT_ID('tempdb..#FamilyNames') IS NOT NULL DROP TABLE #FamilyNames;
CREATE TABLE #FamilyNames (Name NVARCHAR(80));
INSERT INTO #FamilyNames VALUES
(N'الحيدري'),(N'الهاشمي'),(N'الزبيدي'),(N'السيد'),(N'العامري'),
(N'المرادي'),(N'النجار'),(N'المعمري'),(N'الزريقي'),(N'الشريف'),
(N'الحديفي'),(N'البخيتي'),(N'القتبي'),(N'الحميري'),(N'العنسي'),
(N'الشرعي'),(N'الفقيه'),(N'الغيثي'),(N'العريقي'),(N'الدعيس');

DECLARE @GN INT = (SELECT COUNT(*) FROM #GivenNames);
DECLARE @FN INT = (SELECT COUNT(*) FROM #FamilyNames);
DECLARE @CT INT = (SELECT COUNT(*) FROM #Cities);
DECLARE @ST INT = (SELECT COUNT(*) FROM #Streets);

/* ===================== تعبئة المرجع إن كان فارغًا ===================== */
IF NOT EXISTS (SELECT 1 FROM Specialties)
INSERT INTO Specialties (SpecialtyName) VALUES
(N'طب عام'),(N'أطفال'),(N'جراحة عامة'),(N'أمراض القلب'),(N'أمراض العيون'),
(N'أنف وأذن وحنجرة'),(N'الأمراض الجلدية'),(N'العظام'),(N'النساء والتوليد'),
(N'الأمراض الباطنية'),(N'التخدير'),(N'الأورام'),(N'طب الطوارئ'),
(N'الأشعة'),(N'الأمراض النفسية'),(N'المناظير'),(N'الكُلى'),(N'الغدد');

IF NOT EXISTS (SELECT 1 FROM VisitTypes)
INSERT INTO VisitTypes (VisitTypeName) VALUES
(N'كشف أولي'),(N'متابعة'),(N'استشارة'),(N'طوارئ'),(N'فحص دوري'),(N'عمليات');

IF NOT EXISTS (SELECT 1 FROM AppointmentStatus)
INSERT INTO AppointmentStatus (StatusName) VALUES
(N'مؤكد'),(N'قيد الانتظار'),(N'مكتمل'),(N'ملغي');

IF NOT EXISTS (SELECT 1 FROM InvoiceStatus)
INSERT INTO InvoiceStatus (StatusName) VALUES
(N'غير مدفوعة'),(N'مدفوعة جزئياً'),(N'مدفوعة'),(N'معلقة');

IF NOT EXISTS (SELECT 1 FROM RoomTypes)
INSERT INTO RoomTypes (RoomTypeName, CostPerDay) VALUES
(N'غرفة مشتركة',2000.00),(N'غرفة خاصة',5000.00),(N'جناح',12000.00),
(N'عناية مركزة',25000.00),(N'عناية متوسطة',10000.00),(N'ملاحظة',1500.00);

IF NOT EXISTS (SELECT 1 FROM Departments)
INSERT INTO Departments (DepartmentName) VALUES
(N'الطوارئ'),(N'الجراحة'),(N'طب الأطفال'),(N'الباطنية'),(N'النساء والولادة'),
(N'الأشعة'),(N'المختبر'),(N'الصيدلة'),(N'العناية المركزة'),(N'العيادات الخارجية');

/* تحقّق من توفر المرجع */
DECLARE @RT INT = (SELECT COUNT(*) FROM RoomTypes);
DECLARE @SP INT = (SELECT COUNT(*) FROM Specialties);
DECLARE @DP INT = (SELECT COUNT(*) FROM Departments);
DECLARE @VT INT = (SELECT COUNT(*) FROM VisitTypes);
DECLARE @AS INT = (SELECT COUNT(*) FROM AppointmentStatus);
DECLARE @IS INT = (SELECT COUNT(*) FROM InvoiceStatus);
IF @RT=0 OR @SP=0 OR @DP=0 OR @VT=0 OR @AS=0 OR @IS=0
    THROW 51000, N'جداول المرجع فارغة. توقّف.', 1;

/* ===================== Rooms (توزيع آمن) ===================== */
;WITH r AS (
    SELECT TOP (@NumRooms) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS k
    FROM sys.all_objects
),
rt AS (SELECT RoomTypeID, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM RoomTypes),
dp AS (SELECT DepartmentID, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM Departments),
cnt AS (SELECT rtC = (SELECT COUNT(*) FROM rt), dpC = (SELECT COUNT(*) FROM dp))
INSERT INTO Rooms (RoomNumber, RoomTypeID, DepartmentID)
SELECT
  N'R-' + RIGHT('0000' + CAST(r.k AS NVARCHAR(10)), 4),
  rt.RoomTypeID,
  dp.DepartmentID
FROM r
CROSS JOIN cnt
JOIN rt ON rt.rn = ((r.k - 1) % cnt.rtC) + 1
JOIN dp ON dp.rn = ((r.k - 1) % cnt.dpC) + 1
WHERE NOT EXISTS (SELECT 1 FROM Rooms);

/* ===================== Doctors (اسم1 + اسم2 + لقب) ===================== */
;WITH d AS (
  SELECT TOP (@NumDoctors) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
GN1 AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #GivenNames),
GN2 AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #GivenNames),
FAM AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #FamilyNames),
sp AS (SELECT SpecialtyID, ROW_NUMBER() OVER (ORDER BY NEWID()) rn FROM Specialties),
dp2 AS (SELECT DepartmentID, ROW_NUMBER() OVER (ORDER BY NEWID()) rn FROM Departments),
cnt2 AS (
    SELECT gC=(SELECT COUNT(*) FROM GN1), fC=(SELECT COUNT(*) FROM FAM),
           sC=(SELECT COUNT(*) FROM sp),  dC=(SELECT COUNT(*) FROM dp2)
)
INSERT INTO Doctors (FirstName, LastName, SpecialtyID, DepartmentID, PhoneNumber, Email, HireDate, FullName)
SELECT
  g1.Name,
  f1.Name,
  sp.SpecialtyID,
  dp2.DepartmentID,
  N'+967' + RIGHT('000000000' + CAST(@SeedOffset + d.n AS NVARCHAR(20)), 9),
  N'd' + CAST(d.n AS NVARCHAR(10)) + N'@example.com',
  DATEADD(day, -(ABS(CHECKSUM(d.n)) % 3650), GETDATE()),
  g1.Name + N' ' + g2.Name + N' ' + f1.Name
FROM d
CROSS JOIN cnt2
JOIN GN1 g1 ON g1.rn = ((d.n*5      ) % cnt2.gC) + 1
JOIN GN2 g2 ON g2.rn = ((d.n*9  + 1 ) % cnt2.gC) + 1
JOIN FAM f1 ON f1.rn = ((d.n*7  + 3 ) % cnt2.fC) + 1
JOIN sp  ON sp.rn  = ((d.n*11 + 2 ) % cnt2.sC) + 1
JOIN dp2 ON dp2.rn = ((d.n*13 + 4 ) % cnt2.dC) + 1
WHERE NOT EXISTS (SELECT 1 FROM Doctors);

/* ===================== Nurses ===================== */
;WITH n AS (
  SELECT TOP (@NumNurses) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
GN1 AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #GivenNames),
GN2 AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #GivenNames),
FAM AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #FamilyNames),
dp2 AS (SELECT DepartmentID, ROW_NUMBER() OVER (ORDER BY NEWID()) rn FROM Departments),
cnt3 AS (
    SELECT gC=(SELECT COUNT(*) FROM GN1), fC=(SELECT COUNT(*) FROM FAM),
           dC=(SELECT COUNT(*) FROM dp2)
)
INSERT INTO Nurses (FirstName, LastName, DepartmentID, PhoneNumber, HireDate, FullName)
SELECT
  g1.Name,
  f1.Name,
  dp2.DepartmentID,
  N'+967' + RIGHT('000000000' + CAST(@SeedOffset + 200000 + n.n AS NVARCHAR(20)), 9),
  DATEADD(day, -(ABS(CHECKSUM(n.n)) % 3650), GETDATE()),
  g1.Name + N' ' + g2.Name + N' ' + f1.Name
FROM n
CROSS JOIN cnt3
JOIN GN1 g1  ON g1.rn  = ((n.n*3      ) % cnt3.gC) + 1
JOIN GN2 g2  ON g2.rn  = ((n.n*8  + 2 ) % cnt3.gC) + 1
JOIN FAM f1 ON f1.rn  = ((n.n*11 + 4 ) % cnt3.fC) + 1
JOIN dp2    ON dp2.rn = ((n.n*5  + 1 ) % cnt3.dC) + 1
WHERE NOT EXISTS (SELECT 1 FROM Nurses);

/* ===================== Drugs ===================== */
;WITH g AS (
  SELECT TOP (@NumDrugs) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM sys.all_objects
)
INSERT INTO Drugs (DrugName, ScientificName, Manufacturer, UnitPrice)
SELECT
  N'دواء ' + CAST(n AS NVARCHAR(10)),
  N'Generic' + CAST(n AS NVARCHAR(10)),
  N'شركة محلية ' + CAST((n % 15) + 1 AS NVARCHAR(3)),
  CAST( (10 + (n % 200)) + (n / 100.0) AS DECIMAL(10,2))
FROM g
WHERE NOT EXISTS (SELECT 1 FROM Drugs);

/* ===================== Patients (اسم1 + اسم2 + لقب) ===================== */
;WITH p AS (
  SELECT TOP (@NumPatients) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
GN1 AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #GivenNames),
GN2 AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #GivenNames),
FAM AS (SELECT Name, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #FamilyNames),
CT  AS (SELECT CityName,   ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #Cities),
ST  AS (SELECT StreetName, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn FROM #Streets),
cnt4 AS (
    SELECT gC=(SELECT COUNT(*) FROM GN1), fC=(SELECT COUNT(*) FROM FAM),
           cC=(SELECT COUNT(*) FROM CT),  sC=(SELECT COUNT(*) FROM ST)
)
INSERT INTO Patients (FirstName, LastName, DateOfBirth, Gender, PhoneNumber, Email, Address, RegistrationDate, FullName)
SELECT
  g1.Name AS FirstName,
  f.Name  AS LastName,
  DATEADD(day, -(18*365 + (ABS(CHECKSUM(p.n)) % (60*365))), CAST(GETDATE() AS DATE)),
  CASE WHEN (p.n % 2)=0 THEN N'ذكر' ELSE N'أنثى' END,
  N'+967' + RIGHT('000000000' + CAST(@SeedOffset + 500000 + p.n AS NVARCHAR(20)), 9),
  N'u' + CAST(p.n AS NVARCHAR(10)) + N'@example.com',
  c.CityName + N', ' + s.StreetName + N' - منزل ' + CAST(1 + (p.n % 5000) AS NVARCHAR(10)),
  DATEADD(day, -(ABS(CHECKSUM(p.n)) % 3650), GETDATE()),
  g1.Name + N' ' + g2.Name + N' ' + f.Name
FROM p
CROSS JOIN cnt4
JOIN GN1 g1 ON g1.rn = ((p.n*7      ) % cnt4.gC) + 1
JOIN GN2 g2 ON g2.rn = ((p.n*11 + 3 ) % cnt4.gC) + 1
JOIN FAM f  ON f.rn  = ((p.n*13 + 5 ) % cnt4.fC) + 1
JOIN CT  c  ON c.rn  = ((p.n*17 + 2 ) % cnt4.cC) + 1
JOIN ST  s  ON s.rn  = ((p.n*19 + 4 ) % cnt4.sC) + 1
WHERE NOT EXISTS (SELECT 1 FROM Patients);

/* ===================== Appointments ===================== */
;WITH a AS (
  SELECT TOP (@NumAppointments) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
pt AS (SELECT PatientID,  ROW_NUMBER() OVER (ORDER BY NEWID()) rn FROM Patients),
dc AS (SELECT DoctorID,   ROW_NUMBER() OVER (ORDER BY NEWID()) rn FROM Doctors),
vt AS (SELECT VisitTypeID,ROW_NUMBER() OVER (ORDER BY NEWID()) rn FROM VisitTypes),
asT AS (SELECT AppointmentStatusID, ROW_NUMBER() OVER (ORDER BY NEWID()) rn FROM AppointmentStatus),
cnt5 AS (
  SELECT pC=(SELECT COUNT(*) FROM pt), dC=(SELECT COUNT(*) FROM dc),
         vC=(SELECT COUNT(*) FROM vt), aC=(SELECT COUNT(*) FROM asT)
)
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDateTime, VisitTypeID, AppointmentStatusID, Notes)
SELECT
  pt.PatientID,
  dc.DoctorID,
  DATEADD(minute, (a.n*17) % (60*24*365), DATEADD(day, - (a.n % 365), GETDATE())),
  vt.VisitTypeID,
  asT.AppointmentStatusID,
  N'ملاحظة ' + CAST(a.n AS NVARCHAR(10))
FROM a
CROSS JOIN cnt5
JOIN pt  ON pt.rn  = ((a.n-1) % cnt5.pC) + 1
JOIN dc  ON dc.rn  = ((a.n-1) % cnt5.dC) + 1
JOIN vt  ON vt.rn  = ((a.n-1) % cnt5.vC) + 1
JOIN asT ON asT.rn = ((a.n-1) % cnt5.aC) + 1
WHERE NOT EXISTS (SELECT 1 FROM Appointments);

/* ===================== Encounters: ~80% ===================== */
INSERT INTO Encounters (PatientID, DoctorID, AppointmentID, EncounterDateTime, ChiefComplaint)
SELECT TOP (CAST(@NumAppointments * 0.8 AS INT))
  ap.PatientID,
  ap.DoctorID,
  ap.AppointmentID,
  DATEADD(minute, 15, ap.AppointmentDateTime),
  N'شكوى'
FROM Appointments ap
ORDER BY ap.AppointmentID;

/* ===================== Diagnoses: ~65% ===================== */
INSERT INTO Diagnoses (EncounterID, DiagnosisCode, DiagnosisDescription, IsChronic)
SELECT e.EncounterID,
       N'ICD-' + RIGHT('000' + CAST(ABS(CHECKSUM(e.EncounterID)) % 999 AS NVARCHAR(3)),3),
       N'تشخيص تجريبي',
       CASE WHEN (e.EncounterID % 10) = 0 THEN 1 ELSE 0 END
FROM Encounters e
WHERE (e.EncounterID % 100) < 65;

/* ===================== Prescriptions: ~65% ===================== */
INSERT INTO Prescriptions (EncounterID, PrescriptionDate)
SELECT e.EncounterID, CAST(e.EncounterDateTime AS DATE)
FROM Encounters e
WHERE (e.EncounterID % 100) < 65
  AND NOT EXISTS (SELECT 1 FROM Prescriptions p WHERE p.EncounterID = e.EncounterID);

/* ===================== PrescriptionItems (آمن مع مفاتيح Drugs) ===================== */
DECLARE @DrugCount INT = (SELECT COUNT(*) FROM Drugs);
IF @DrugCount = 0 THROW 51001, N'جدول Drugs فارغ.', 1;

;WITH p0 AS (
  SELECT p.PrescriptionID,
         ROW_NUMBER() OVER (ORDER BY p.PrescriptionID) AS rn
  FROM Prescriptions p
  WHERE NOT EXISTS (SELECT 1 FROM PrescriptionItems i WHERE i.PrescriptionID = p.PrescriptionID)
),
drugLkp AS (
  SELECT DrugID, ROW_NUMBER() OVER (ORDER BY DrugID) AS drn FROM Drugs
),
cntPI AS (SELECT dC = (SELECT COUNT(*) FROM drugLkp)),
reps AS (
  SELECT PrescriptionID, rn, 1 AS r FROM p0
  UNION ALL SELECT PrescriptionID, rn, 2 FROM p0 WHERE (rn % 100) < 60
  UNION ALL SELECT PrescriptionID, rn, 3 FROM p0 WHERE (rn % 100) < 40
  UNION ALL SELECT PrescriptionID, rn, 4 FROM p0 WHERE (rn % 100) < 20
)
INSERT INTO PrescriptionItems (PrescriptionID, DrugID, Dosage, Frequency, Duration, Quantity)
SELECT
  reps.PrescriptionID,
  d.DrugID,
  CAST(250 + ((reps.PrescriptionID * reps.r) % 500) AS NVARCHAR(20)) + N'mg',
  CASE WHEN ((reps.PrescriptionID + reps.r) % 2)=0 THEN N'مرتين يومياً' ELSE N'مرة يومياً' END,
  CAST(3 + ((reps.PrescriptionID + reps.r) % 10) AS NVARCHAR(10)) + N' أيام',
  1 + ((reps.PrescriptionID + reps.r) % 30)
FROM reps
CROSS APPLY (SELECT drn = ((reps.rn + reps.r - 1) % (SELECT dC FROM cntPI)) + 1) pick
JOIN drugLkp d ON d.drn = pick.drn;

/* ===================== Invoices (آمن مع حالات الفواتير) ===================== */
DECLARE @InvStatusCount INT = (SELECT COUNT(*) FROM InvoiceStatus);
IF @InvStatusCount = 0 THROW 51002, N'InvoiceStatus فارغ.', 1;

;WITH e0 AS (
  SELECT e.EncounterID, e.PatientID, e.EncounterDateTime,
         ROW_NUMBER() OVER (ORDER BY e.EncounterID) AS rn
  FROM Encounters e
  WHERE (e.EncounterID % 100) < 60
    AND NOT EXISTS (SELECT 1 FROM Invoices i WHERE i.EncounterID = e.EncounterID)
),
stat AS (
  SELECT InvoiceStatusID, ROW_NUMBER() OVER (ORDER BY InvoiceStatusID) AS srn
  FROM InvoiceStatus
),
cntInv AS (SELECT sC = (SELECT COUNT(*) FROM stat))
INSERT INTO Invoices (PatientID, EncounterID, InvoiceDate, TotalAmount, AmountPaid, InvoiceStatusID)
SELECT
  e0.PatientID,
  e0.EncounterID,
  CAST(e0.EncounterDateTime AS DATE),
  CAST(100 + (e0.EncounterID % 20000) AS DECIMAL(10,2)),
  0.00,
  s.InvoiceStatusID
FROM e0
CROSS APPLY (SELECT srn = ((e0.rn - 1) % (SELECT sC FROM cntInv)) + 1) pick
JOIN stat s ON s.srn = pick.srn;

/* ===================== InvoiceItems ===================== */
;WITH ii AS (
  SELECT InvoiceID, 1 AS r FROM Invoices
  UNION ALL SELECT InvoiceID, 2 FROM Invoices WHERE (InvoiceID % 100) < 60
  UNION ALL SELECT InvoiceID, 3 FROM Invoices WHERE (InvoiceID % 100) < 30
)
INSERT INTO InvoiceItems (InvoiceID, ItemDescription, Quantity, UnitPrice)
SELECT
  ii.InvoiceID,
  N'خدمة ' + CAST((ii.InvoiceID * ii.r) % 1000 AS NVARCHAR(10)),
  1 + ((ii.InvoiceID + ii.r) % 3),
  CAST(50 + ((ii.InvoiceID * 37 + ii.r) % 5000) AS DECIMAL(10,2))
FROM ii
WHERE NOT EXISTS (SELECT 1 FROM InvoiceItems x WHERE x.InvoiceID = ii.InvoiceID);

/* ===================== Payments ===================== */
INSERT INTO Payments (InvoiceID, PaymentDate, Amount, PaymentMethod)
SELECT i.InvoiceID,
       DATEADD(day, (i.InvoiceID % 30), CAST(i.InvoiceDate AS DATETIME)),
       CAST(i.TotalAmount * ((i.InvoiceID % 100) / 100.0) AS DECIMAL(10,2)),
       CASE WHEN (i.InvoiceID % 2) = 0 THEN N'نقدي' ELSE N'بطاقة' END
FROM Invoices i
WHERE (i.InvoiceID % 100) < 30
  AND NOT EXISTS (SELECT 1 FROM Payments p WHERE p.InvoiceID = i.InvoiceID);

UPDATE i
SET AmountPaid = ISNULL((SELECT SUM(p.Amount) FROM Payments p WHERE p.InvoiceID = i.InvoiceID), 0)
FROM Invoices i;

/* ===================== BedAssignments (آمن) ===================== */
DECLARE @PatientsCount INT = (SELECT COUNT(*) FROM Patients);
DECLARE @RoomsCount    INT = (SELECT COUNT(*) FROM Rooms);
IF @PatientsCount = 0 OR @RoomsCount = 0
    THROW 51003, N'Patients أو Rooms فارغ.', 1;

;WITH need AS (
  SELECT TOP (CAST(@NumPatients * 0.1 AS INT))
         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects
),
pt2 AS (SELECT PatientID, ROW_NUMBER() OVER (ORDER BY PatientID) AS prn FROM Patients),
rm2 AS (SELECT RoomID,    ROW_NUMBER() OVER (ORDER BY RoomID)    AS rrn FROM Rooms),
cntBA AS (SELECT pC = (SELECT COUNT(*) FROM pt2),
                 rC = (SELECT COUNT(*) FROM rm2))
INSERT INTO BedAssignments (PatientID, RoomID, AdmissionDate, DischargeDate)
SELECT
  p.PatientID,
  r.RoomID,
  DATEADD(day, - (ABS(CHECKSUM(need.n)) % 30), GETDATE()),
  CASE WHEN (ABS(CHECKSUM(need.n)) % 3) = 0
       THEN DATEADD(day, ABS(CHECKSUM(need.n)) % 10, GETDATE())
       ELSE NULL END
FROM need
CROSS APPLY (SELECT prn = ((need.n - 1) % (SELECT pC FROM cntBA)) + 1,
                    rrn = ((need.n - 1) % (SELECT rC FROM cntBA)) + 1) pick
JOIN pt2 p ON p.prn = pick.prn
JOIN rm2 r ON r.rrn = pick.rrn;

/* ===================== Procedures ===================== */
INSERT INTO Procedures (EncounterID, ProcedureCode, ProcedureName, ProcedureCost)
SELECT e.EncounterID,
       N'CPT' + RIGHT('000' + CAST(e.EncounterID % 999 AS NVARCHAR(3)),3),
       N'إجراء طبي',
       CAST(100 + ((e.EncounterID * 23) % 10000) AS DECIMAL(10,2))
FROM Encounters e
WHERE (e.EncounterID % 100) < 20
  AND NOT EXISTS (SELECT 1 FROM Procedures pr WHERE pr.EncounterID = e.EncounterID);

/* ===================== إحصاءات ===================== */
SELECT
 (SELECT COUNT(*) FROM Patients)      AS PatientsCount,
 (SELECT COUNT(*) FROM Doctors)       AS DoctorsCount,
 (SELECT COUNT(*) FROM Nurses)        AS NursesCount,
 (SELECT COUNT(*) FROM Rooms)         AS RoomsCount,
 (SELECT COUNT(*) FROM Drugs)         AS DrugsCount,
 (SELECT COUNT(*) FROM Appointments)  AS AppointmentsCount,
 (SELECT COUNT(*) FROM Encounters)    AS EncountersCount,
 (SELECT COUNT(*) FROM Prescriptions) AS PrescriptionsCount,
 (SELECT COUNT(*) FROM Invoices)      AS InvoicesCount;
 SELECT * FROM Patients