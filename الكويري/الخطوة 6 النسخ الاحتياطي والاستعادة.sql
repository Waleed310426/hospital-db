USE master; 
BACKUP DATABASE HospitalDB1 
TO DISK = 'C:\Backups\HospitalDB1_Full.bak';

USE master; 
BACKUP DATABASE HospitalDB1 
TO DISK = 'C:\Backups\HospitalDB1_Diff.bak' 
WITH DIFFERENTIAL;

USE master; 
BACKUP LOG HospitalDB1 
TO DISK = 'C:\Backups\HospitalDB1_Log.trn';


USE master; 
RESTORE DATABASE [HospitalDB1] 
FROM DISK = 'C:\Backups\HospitalDB1_Full.bak' 
WITH REPLACE;

RESTORE DATABASE [HospitalDB1]   
FROM DISK = 'C:\Backups\HospitalDB1_Full.bak'   
WITH NORECOVERY; 
 
RESTORE DATABASE HospitalDB1   
FROM DISK = 'C:\Backups\HospitalDB1_Diff.bak'   
WITH RECOVERY;


RESTORE LOG HospitalDB1 
FROM DISK = 'C:\Backups\HospitalDB1_LOG.trn' 
WITH STOPAT = '2025-09-20T04:29:00', RECOVERY; 