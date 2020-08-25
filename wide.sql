.mode csv
.import LiverMRIProjectData/datakeyANON.csv  imaging
.import LiverMRIProjectData/LiverMRIAnonymizationKey.csv  datekey
.headers on
create table hccimaging  as
select dk.Status,im.StudyDate,dk.HCCDate,
       julianday(replace(dk.HCCDate, rtrim(dk.HCCDate, replace(dk.HCCDate, '/', '')), '')  || '-' || printf('%02d', cast(substr(dk.HCCDate, 0, instr(dk.HCCDate,'/')) as int)) || '-' || printf('%02d', cast(substr(substr(dk.HCCDate, instr(dk.HCCDate,'/')+1), 0, instr(substr(dk.HCCDate, instr(dk.HCCDate,'/')+1),'/')) as int) )) - julianday(substr(im.StudyDate, 1, 4) || '-' || substr(im.StudyDate, 5,2) || '-' || substr(im.StudyDate, 7,2)) diagnosticinterval,
       im.StudyNumber,im.PatientNumber,im.SeriesDescription,
CASE WHEN (im.seriesDescription like "t1_vibe_fs%Pre"   or im.seriesDescription like '3D_Thr_Pre')   THEN 'Pre'
     WHEN (im.seriesDescription like "t1_vibe_fs%Art%"  or im.seriesDescription like '3D_Thr_Art')   THEN 'Art'
     WHEN (im.seriesDescription like "t1_vibe_fs%30%"   or im.seriesDescription like '3D_Thr_Ven')   THEN 'Ven'
     WHEN (im.seriesDescription like "t1_vibe_fs%60%"   or im.seriesDescription like '3D_Thr_Del%')  THEN 'Del'
     WHEN (im.seriesDescription like "t1_vibe_fs%Post%" or im.seriesDescription like '3D_Thr_Port')  THEN 'Pst'
     ELSE NULL END AS ImageType,
       im.SeriesModality,im.seriesanonuid,im.niftifile 
from datekey dk join imaging im on  dk.slicerID = im.PatientNumber ;


-- select count(Status) from datekey   where Status == 'case';
-- select count(status) from hccimaging where Status == 'case' group by patientnumber, studynumber;
-- FIXME - missing - select * from hccimaging   where patientnumber = 9;
-- FIXME - missing - select * from hccimaging   where patientnumber = 12;

.output LiverMRIProjectData/wideanon.csv 
SELECT   printf('BCM%04d%03d', cast(PatientNumber as int) , cast(StudyNumber as int) ) UID, Status, ifnull(diagnosticinterval,"inf") diagnosticinterval,
            max(CASE WHEN ImageType = 'Pre' THEN seriesanonuid ELSE NULL END)  Pre,
            max(CASE WHEN ImageType = 'Art' THEN seriesanonuid ELSE NULL END)  Art,
            max(CASE WHEN ImageType = 'Ven' THEN seriesanonuid ELSE NULL END)  Ven,
            max(CASE WHEN ImageType = 'Del' THEN seriesanonuid ELSE NULL END)  Del,
            max(CASE WHEN ImageType = 'Pst' THEN seriesanonuid ELSE NULL END)  Post 
FROM        hccimaging
where       ImageType is not null 
GROUP BY    PatientNumber, StudyNumber
ORDER BY    cast(PatientNumber as int) ASC, cast(StudyNumber as int) ASC;

-- select   printf('BCM%04d%03d', cast(PatientNumber as int) , cast(StudyNumber as int) ) UID,  PatientNumber, StudyNumber from imaging GROUP BY    PatientNumber, StudyNumber;
.quit
