# -*- coding: utf-8 -*-
"""
Created on Thu Jun 18 21:26:20 2020

@author: Kelsey
"""

#%%
#https://stackoverflow.com/questions/51567750/extract-specific-pages-of-pdf-and-save-it-with-python

#information = [(filename1,startpage1,endpage1), (filename2, startpage2, endpage2), ...,(filename19,startpage19,endpage19)].
import PyPDF2  
#import os

year = '2019'
year_short = '19'

# missouri
state = 'missouri'
#startpage = 149
#endpage = 157
startpage = 151
endpage = 159
filenames = [
             #'01' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             #'02' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             #'03' + year_short + '-family-support-mohealthnet-report' + '.pdf',
             #'04' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             #'05' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             #'06' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             '07' + year_short + '-family-support-mohealthnet-report' + '.pdf',
             '08' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             '09' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             '10' + year_short + '-family-support-mohealthnet-report' + '.pdf', 
             '11' + year_short + '-family-support-mohealthnet-report' + '.pdf',
             '12' + year_short + '-family-support-mohealthnet-report' + '.pdf' 
             ]

# newmexico
state = 'newmexico'
startpage = 21
endpage = 21
filenames = [
             #'MSR_' + 'January_' + year + '.pdf', 
             #'MSR_' + 'February_' + year + '.pdf', 
             #'MSR_' + 'March_' + year + '.pdf',
             #'MSR_' + 'April_' + year + '.pdf', 
             'MSR_' + 'May_' + year + '.pdf', 
             'MSR_' + 'June_' + year + '.pdf', 
             'MSR_' + 'July_' + year + '.pdf',
             'MSR_' + 'August_' + year + '.pdf', 
             'MSR_' + 'September_' + year + '.pdf', 
             'MSR_' + 'October_' + year + '.pdf', 
             'MSR_' + 'November_' + year + '.pdf',
             'MSR_' + 'December_' + year + '.pdf' 
             ]

# oregon
state = 'oregon'
startpage = 21
endpage = 21
filenames = [
             #'SNAP Flash figures ' + 'January ' + year + '.pdf', 
             #'SNAP Flash figures ' + 'February ' + year + '.pdf', 
             #'SNAP Flash figures ' + 'March ' + year + '.pdf',
             #'SNAP Flash figures ' + 'April ' + year + '.pdf', 
             #'SNAP Flash figures ' + 'May ' + year + '.pdf', 
             #'SNAP Flash figures ' + 'June ' + year + '.pdf', 
             #'SNAP Flash figures ' + 'July ' + year + '.pdf',
             #'SNAP Flash figures ' + 'August ' + year + '.pdf', 
             'SNAP Flash figures ' + 'September ' + year + '.pdf', 
             'SNAP Flash figures ' + 'October ' + year + '.pdf', 
             'SNAP Flash figures ' + 'November ' + year + '.pdf',
             'SNAP Flash figures ' + 'December ' + year + '.pdf' 
             ]


directory = 'C:\\Users\\Kelsey\\Google Drive\\Harvard\\research\\time_limits\\data\\state_data\\' + state + '\\pdfs\\' + year + '\\'
directory_short = 'C:\\Users\\Kelsey\\Google Drive\\Harvard\\research\\time_limits\\data\\state_data\\' + state + '\\pdfs_short\\' + year + '\\'


print(filenames)
#%%

for filename in filenames:
    pdfFileObj = open(directory + filename, 'rb')
    pdfReader = PyPDF2.PdfFileReader(pdfFileObj)
    pdf_writer = PyPDF2.PdfFileWriter()
    start = startpage
    end = endpage
    while start<=end:
        pdf_writer.addPage(pdfReader.getPage(start-1))
        start+=1
  #  if not os.path.exists(savepath):
   #     os.makedirs(savepath)
    #output_filename = '{}_{}_page_{}.pdf'.format(filename,startpage,endpage)
    output_filename = '{}{}_short.pdf'.format(directory_short,filename)
    with open(output_filename,'wb') as out:
        pdf_writer.write(out)
      #  pdf_writer.write(directory + out)
        
  #%%
