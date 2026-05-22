-- =================================================================
-- الخطوة 1: إنشاء قاعدة البيانات والتبديل إليها
-- =================================================================
-- التأكد من عدم وجود قاعدة بيانات بنفس الاسم قبل إنشائها
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'HospitalDB1')
BEGIN
    CREATE DATABASE HospitalDB1;
END
GO

-- استخدام قاعدة البيانات التي تم إنشاؤها لتنفيذ الأوامر التالية عليها
USE HospitalDB1;
GO

-- =================================================================
-- الخطوة 2: إنشاء الجداول المرجعية (Lookup Tables)
-- وظيفتها توفير قوائم ثابتة ومنظمة للبيانات التي تتكرر في النظام
-- =================================================================


--لقد قمنا بإنشاء 21 جدولاً في المجموع.
--يمكن تقسيمها كالتالي:
--6 جداول مرجعية (Lookup Tables):
--Specialties
--VisitTypes
--AppointmentStatus
--InvoiceStatus
--RoomTypes
--Departments
--5 جداول أساسية (Core Entities):
--7.  Patients
--8.  Doctors
--9.  Nurses
--10. Rooms
--11. Drugs
--10 جداول عمليات (Transactional Tables):
--12. Appointments
--13. Encounters
--14. Diagnoses
--15. Prescriptions
--16. PrescriptionItems
--17. Invoices
--18. InvoiceItems
--19. Payments
--20. BedAssignments
--21. Procedures 


-- جدول التخصصات الطبية
CREATE TABLE Specialties (
    SpecialtyID INT PRIMARY KEY IDENTITY(1,1),  -- المعرف الرقمي الفريد للتخصص (مفتاح أساسي)
    SpecialtyName NVARCHAR(100) NOT NULL UNIQUE -- اسم التخصص (مثل: أمراض القلب، طب الأطفال)
);
GO

-- جدول أنواع الزيارات
CREATE TABLE VisitTypes (
    VisitTypeID INT PRIMARY KEY IDENTITY(1,1),  -- المعرف الرقمي الفريد لنوع الزيارة (مفتاح أساسي)
    VisitTypeName NVARCHAR(100) NOT NULL UNIQUE -- اسم نوع الزيارة (مثل: كشف أولي، متابعة، استشارة)
);
GO

-- جدول حالات المواعيد
CREATE TABLE AppointmentStatus (
    AppointmentStatusID INT PRIMARY KEY IDENTITY(1,1), -- المعرف الرقمي لحالة الموعد (مفتاح أساسي)
    StatusName NVARCHAR(50) NOT NULL UNIQUE          -- اسم الحالة (مثل: مؤكد، مكتمل، ملغي)
);
GO

-- جدول حالات الفواتير
CREATE TABLE InvoiceStatus (
    InvoiceStatusID INT PRIMARY KEY IDENTITY(1,1), -- المعرف الرقمي لحالة الفاتورة (مفتاح أساسي)
    StatusName NVARCHAR(50) NOT NULL UNIQUE       -- اسم الحالة (مثل: مدفوعة، غير مدفوعة، معلقة)
);
GO

-- جدول أنواع الغرف
CREATE TABLE RoomTypes (
    RoomTypeID INT PRIMARY KEY IDENTITY(1,1),      -- المعرف الرقمي لنوع الغرفة (مفتاح أساسي)
    RoomTypeName NVARCHAR(100) NOT NULL,           -- اسم نوع الغرفة (مثل: غرفة خاصة، جناح، غرفة مشتركة)
    CostPerDay DECIMAL(10, 2) NOT NULL             -- تكلفة الإقامة في هذا النوع من الغرف لليلة الواحدة
);
GO

-- جدول الأقسام داخل المستشفى
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),    -- المعرف الرقمي للقسم (مفتاح أساسي)
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE  -- اسم القسم (مثل: قسم الجراحة، قسم الطوارئ)
);
GO

-- =================================================================
-- الخطوة 3: إنشاء الجداول الأساسية (Core Entities)
-- هذه الجداول تحتوي على الكيانات الرئيسية في النظام مثل المرضى والأطباء
-- =================================================================

-- جدول المرضى
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY IDENTITY(1,1),        -- المعرف الرقمي للمريض (مفتاح أساسي)
    FirstName NVARCHAR(50) NOT NULL,                -- الاسم الأول
    LastName NVARCHAR(50) NOT NULL,                 -- الاسم الأخير
    DateOfBirth DATE NOT NULL,                      -- تاريخ الميلاد
    Gender NVARCHAR(10),                            -- الجنس (ذكر/أنثى)
    PhoneNumber NVARCHAR(20) UNIQUE,                -- رقم الهاتف (يجب أن يكون فريداً)
    Email NVARCHAR(100) UNIQUE,                     -- البريد الإلكتروني (يجب أن يكون فريداً)
    Address NVARCHAR(255),                          -- عنوان السكن
    RegistrationDate DATETIME DEFAULT GETDATE()     -- تاريخ تسجيل المريض في النظام (القيمة الافتراضية هي تاريخ ووقت الإدخال)
);
GO

-- جدول الأطباء
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),         -- المعرف الرقمي للطبيب (مفتاح أساسي)
    FirstName NVARCHAR(50) NOT NULL,                -- الاسم الأول
    LastName NVARCHAR(50) NOT NULL,                 -- الاسم الأخير
    SpecialtyID INT,                                -- مفتاح خارجي يربط بجدول التخصصات
    DepartmentID INT,                               -- مفتاح خارجي يربط بجدول الأقسام
    PhoneNumber NVARCHAR(20) UNIQUE,                -- رقم الهاتف
    Email NVARCHAR(100) UNIQUE,                     -- البريد الإلكتروني
    HireDate DATE,                                  -- تاريخ التعيين
    -- تحديد المفاتيح الخارجية
    FOREIGN KEY (SpecialtyID) REFERENCES Specialties(SpecialtyID),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

-- جدول الممرضين (مثال إضافي)
CREATE TABLE Nurses (
    NurseID INT PRIMARY KEY IDENTITY(1,1),          -- المعرف الرقمي للممرض (مفتاح أساسي)
    FirstName NVARCHAR(50) NOT NULL,                -- الاسم الأول
    LastName NVARCHAR(50) NOT NULL,                 -- الاسم الأخير
    DepartmentID INT,                               -- القسم الذي يعمل به الممرض
    PhoneNumber NVARCHAR(20) UNIQUE,                -- رقم الهاتف
    HireDate DATE,                                  -- تاريخ التعيين
    -- تحديد المفتاح الخارجي
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

ALTER TABLE Patients ADD FullName NVARCHAR(101);
ALTER TABLE Doctors  ADD FullName NVARCHAR(101);
ALTER TABLE Nurses   ADD FullName NVARCHAR(101);


-- جدول الغرف
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY IDENTITY(1,1),           -- المعرف الرقمي للغرفة (مفتاح أساسي)
    RoomNumber NVARCHAR(20) NOT NULL UNIQUE,        -- رقم الغرفة (يجب أن يكون فريداً)
    RoomTypeID INT,                                 -- نوع الغرفة (مفتاح خارجي)
    DepartmentID INT,                               -- القسم التابعة له الغرفة
    -- تحديد المفاتيح الخارجية
    FOREIGN KEY (RoomTypeID) REFERENCES RoomTypes(RoomTypeID),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);
GO

-- جدول الأدوية
CREATE TABLE Drugs (
    DrugID INT PRIMARY KEY IDENTITY(1,1),           -- المعرف الرقمي للدواء (مفتاح أساسي)
    DrugName NVARCHAR(100) NOT NULL UNIQUE,         -- الاسم التجاري للدواء
    ScientificName NVARCHAR(100),                   -- الاسم العلمي
    Manufacturer NVARCHAR(100),                     -- الشركة المصنعة
    UnitPrice DECIMAL(10, 2) NOT NULL               -- سعر الوحدة من الدواء
);
GO

-- =================================================================
-- الخطوة 4: إنشاء جداول العمليات (Transactional Tables)
-- هذه الجداول تسجل الأحداث والعمليات التي تحدث في النظام
-- =================================================================

-- جدول المواعيد
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),    -- المعرف الرقمي للموعد (مفتاح أساسي)
    PatientID INT NOT NULL,                         -- المريض صاحب الموعد (مفتاح خارجي)
    DoctorID INT NOT NULL,                          -- الطبيب المحدد للموعد (مفتاح خارجي)
    AppointmentDateTime DATETIME NOT NULL,          -- تاريخ ووقت الموعد
    VisitTypeID INT,                                -- نوع الزيارة (مفتاح خارجي)
    AppointmentStatusID INT NOT NULL,               -- حالة الموعد (مفتاح خارجي)
    Notes NVARCHAR(500),                            -- ملاحظات حول الموعد
    -- تحديد المفاتيح الخارجية
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (VisitTypeID) REFERENCES VisitTypes(VisitTypeID),
    FOREIGN KEY (AppointmentStatusID) REFERENCES AppointmentStatus(AppointmentStatusID)
);
GO

-- جدول الزيارات الفعلية (السجل الطبي للمريض)
CREATE TABLE Encounters (
    EncounterID INT PRIMARY KEY IDENTITY(1,1),      -- المعرف الرقمي للزيارة (مفتاح أساسي)
    PatientID INT NOT NULL,                         -- المريض (مفتاح خارجي)
    DoctorID INT NOT NULL,                          -- الطبيب المعالج (مفتاح خارجي)
    AppointmentID INT UNIQUE,                       -- الموعد المرتبط بهذه الزيارة (اختياري وفريد)
    EncounterDateTime DATETIME NOT NULL,            -- تاريخ ووقت الزيارة الفعلي
    ChiefComplaint NVARCHAR(500),                   -- الشكوى الرئيسية للمريض
    -- تحديد المفاتيح الخارجية
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);
GO

-- جدول التشخيصات لكل زيارة
CREATE TABLE Diagnoses (
    DiagnosisID INT PRIMARY KEY IDENTITY(1,1),      -- المعرف الرقمي للتشخيص (مفتاح أساسي)
    EncounterID INT NOT NULL,                       -- الزيارة التي تم فيها التشخيص (مفتاح خارجي)
    DiagnosisCode NVARCHAR(20),                     -- كود التشخيص العالمي (مثل ICD-10)
    DiagnosisDescription NVARCHAR(500) NOT NULL,    -- وصف التشخيص
    IsChronic BIT DEFAULT 0,                        -- هل هو مرض مزمن؟ (0 = لا, 1 = نعم)
    -- تحديد المفتاح الخارجي
    FOREIGN KEY (EncounterID) REFERENCES Encounters(EncounterID)
);
GO

-- جدول الوصفات الطبية (رأس الوصفة)
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),   -- المعرف الرقمي للوصفة (مفتاح أساسي)
    EncounterID INT NOT NULL UNIQUE,                -- الزيارة المرتبطة بالوصفة (علاقة واحد لواحد)
    PrescriptionDate DATE NOT NULL,                 -- تاريخ تحرير الوصفة
    -- تحديد المفتاح الخارجي
    FOREIGN KEY (EncounterID) REFERENCES Encounters(EncounterID)
);
GO

-- جدول بنود الوصفة (الأدوية داخل الوصفة)
CREATE TABLE PrescriptionItems (
    PrescriptionItemID INT PRIMARY KEY IDENTITY(1,1), -- المعرف الرقمي للبند (مفتاح أساسي)
    PrescriptionID INT NOT NULL,                    -- الوصفة التي ينتمي إليها هذا البند (مفتاح خارجي)
    DrugID INT NOT NULL,                            -- الدواء الموصوف (مفتاح خارجي)
    Dosage NVARCHAR(100),                           -- الجرعة (مثال: 500mg)
    Frequency NVARCHAR(100),                        -- تكرار الاستخدام (مثال: مرتان يومياً)
    Duration NVARCHAR(100),                         -- مدة العلاج (مثال: 7 أيام)
    Quantity INT NOT NULL,                          -- الكمية المصروفة
    -- تحديد المفاتيح الخارجية
    FOREIGN KEY (PrescriptionID) REFERENCES Prescriptions(PrescriptionID),
    FOREIGN KEY (DrugID) REFERENCES Drugs(DrugID)
);
GO

-- جدول الفواتير
CREATE TABLE Invoices (
    InvoiceID INT PRIMARY KEY IDENTITY(1,1),        -- المعرف الرقمي للفاتورة (مفتاح أساسي)
    PatientID INT NOT NULL,                         -- المريض المرتبطة به الفاتورة (مفتاح خارجي)
    EncounterID INT,                                -- الزيارة المرتبطة بالفاتورة (اختياري)
    InvoiceDate DATE NOT NULL,                      -- تاريخ إصدار الفاتورة
    TotalAmount DECIMAL(10, 2) NOT NULL,            -- المبلغ الإجمالي للفاتورة
    AmountPaid DECIMAL(10, 2) DEFAULT 0.00,         -- المبلغ المدفوع حتى الآن
    InvoiceStatusID INT NOT NULL,                   -- حالة الفاتورة (مفتاح خارجي)
    -- تحديد المفاتيح الخارجية
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (EncounterID) REFERENCES Encounters(EncounterID),
    FOREIGN KEY (InvoiceStatusID) REFERENCES InvoiceStatus(InvoiceStatusID)
);
GO

-- جدول بنود الفاتورة (تفاصيل الخدمات والتكاليف)
CREATE TABLE InvoiceItems (
    InvoiceItemID INT PRIMARY KEY IDENTITY(1,1),    -- المعرف الرقمي للبند (مفتاح أساسي)
    InvoiceID INT NOT NULL,                         -- الفاتورة التي يتبع لها البند (مفتاح خارجي)
    ItemDescription NVARCHAR(255) NOT NULL,         -- وصف البند (مثال: كشف طبي، تحليل دم، تكلفة دواء)
    Quantity INT NOT NULL,                          -- الكمية
    UnitPrice DECIMAL(10, 2) NOT NULL,              -- سعر الوحدة
    TotalCost AS (Quantity * UnitPrice),            -- حقل محسوب للمجموع (اختياري لكنه مفيد)
    -- تحديد المفتاح الخارجي
    FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID)
);
GO

-- جدول المدفوعات
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),        -- المعرف الرقمي لعملية الدفع (مفتاح أساسي)
    InvoiceID INT NOT NULL,                         -- الفاتورة التي يتم سدادها (مفتاح خارجي)
    PaymentDate DATETIME NOT NULL,                  -- تاريخ ووقت الدفع
    Amount DECIMAL(10, 2) NOT NULL,                 -- المبلغ المدفوع في هذه العملية
    PaymentMethod NVARCHAR(50),                     -- طريقة الدفع (نقدي، بطاقة ائتمان)
    -- تحديد المفتاح الخارجي
    FOREIGN KEY (InvoiceID) REFERENCES Invoices(InvoiceID)
);
GO

-- جدول تسكين المرضى في الغرف (مثال إضافي لم أضعه في البداية لكنه مهم)
CREATE TABLE BedAssignments (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),     -- المعرف الرقمي لعملية التسكين
    PatientID INT NOT NULL,                         -- المريض الذي تم تسكينه
    RoomID INT NOT NULL,                            -- الغرفة التي تم تسكينه فيها
    AdmissionDate DATETIME NOT NULL,                -- تاريخ الدخول
    DischargeDate DATETIME,                         -- تاريخ الخروج (يكون NULL طالما المريض مقيم)
    -- تحديد المفاتيح الخارجية
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);
GO

-- جدول الإجراءات الطبية التي تتم خلال الزيارة
CREATE TABLE Procedures (
    ProcedureID INT PRIMARY KEY IDENTITY(1,1),      -- المعرف الرقمي للإجراء (مفتاح أساسي)
    EncounterID INT NOT NULL,                       -- الزيارة التي تم فيها الإجراء (مفتاح خارجي)
    ProcedureCode NVARCHAR(20),                     -- كود الإجراء الطبي (مثل CPT codes)
    ProcedureName NVARCHAR(255) NOT NULL,           -- اسم الإجراء (مثال: تخطيط قلب، صورة أشعة)
    ProcedureCost DECIMAL(10, 2) NOT NULL,          -- تكلفة الإجراء
    -- تحديد المفتاح الخارجي
    FOREIGN KEY (EncounterID) REFERENCES Encounters(EncounterID)
);
GO




PRINT 'تم إنشاء قاعدة البيانات HospitalDB وجميع الجداول بنجاح!';
GO

