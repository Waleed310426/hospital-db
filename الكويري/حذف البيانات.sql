
USE HospitalDB1;
SET NOCOUNT ON;

/* =============== اختيارية: تنظيف بيانات قديمة ================== */

DELETE FROM Payments;
DELETE FROM InvoiceItems;
DELETE FROM Invoices;
DELETE FROM PrescriptionItems;
DELETE FROM Prescriptions;
DELETE FROM Procedures;
DELETE FROM Diagnoses;
DELETE FROM Encounters;
DELETE FROM Appointments;
DELETE FROM BedAssignments;
DELETE FROM Drugs;
DELETE FROM Rooms;
DELETE FROM Nurses;
DELETE FROM Doctors;
DELETE FROM Patients;
DELETE FROM Departments;
DELETE FROM RoomTypes;
DELETE FROM InvoiceStatus;
DELETE FROM AppointmentStatus;
DELETE FROM VisitTypes;
DELETE FROM Specialties;

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
