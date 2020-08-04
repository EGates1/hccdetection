from __main__ import slicer
import os
from datetime import datetime
import uuid
import csv


def days_between(d1, d2):
    d1 = datetime.strptime(d1, "%Y%m%d")
    d2 = datetime.strptime(d2, "%Y%m%d")
    return abs((d2 - d1).days)


tags = {}
tags['seriesInstanceUID'] = "0020,000E"
tags['seriesDescription'] = "0008,103E"
tags['seriesModality'] = "0008,0060"
tags['studyInstanceUID'] = "0020,000D"
tags['studyDescription'] = "0008,1030"
tags['studyDate'] = "0008,0020"
tags['studyTime'] = "0008,0030"
tags['patientID'] = "0010,0020"
tags['patientName'] = "0010,0010"
tags['patientSex'] = "0010,0040"
tags['patientBirthDate'] = "0010,0030"


db = slicer.dicomDatabase
print(db.databaseFilename)


with open('datakey.csv', 'w') as csvfile:
  csvwrite = csv.writer(csvfile, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)

  for patientnumber in db.patients():
    for study in db.studiesForPatient(patientnumber):
      for series in db.seriesForStudy(study):
        serieslist = [myfile for myfile in db.filesForSeries(series)]
        seriesDescription = slicer.dicomDatabase.fileValue(serieslist[0],tags['seriesDescription'])
        patientID = slicer.dicomDatabase.fileValue(serieslist[0],tags['patientID'])
        seriesModality= slicer.dicomDatabase.fileValue(serieslist[0],tags['seriesModality'])
        studyDate= slicer.dicomDatabase.fileValue(serieslist[0],tags['studyDate'])
        diagnosistimedifference = days_between('20000101',studyDate )
        seriesanonuid = uuid.uuid4()
        print(patientID,study,studyDate,series,patientnumber,seriesDescription,seriesModality,diagnosistimedifference,seriesanonuid  )
        csvwrite.writerow( [patientID,study,studyDate,series,patientnumber,seriesDescription,seriesModality,diagnosistimedifference,seriesanonuid  ])
        if ( seriesModality == 'MR'):
          node=slicer.util.loadVolume(serieslist[0],returnNode=True);
          # TODO - note full path output directory
          outputdir = '/rsrch2/ip/dtfuentes/github/hccdetection/tmpconvert/BCM_%04d/%05d/' % (int(patientnumber) , diagnosistimedifference )
          print( outputdir )
          os.system('mkdir -p %s ' % outputdir  )
          slicer.util.saveNode(node[1], '%s/%s.nii.gz' % (outputdir,seriesanonuid )  )


exit()
