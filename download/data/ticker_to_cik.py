import re
from requests import get
 
TICKERS = []
URL = 'http://www.sec.gov/cgi-bin/browse-edgar?CIK={}&Find=Search&owner=exclude&action=getcompany'
CIK_REGEX = re.compile(r'.*CIK=(\d{10}).*')

my_tickers = open('my_tickers.txt', 'r')
for line in my_tickers:
  TICKERS.append(line)
my_tickers.close
 
cik_dict = {}
for ticker in TICKERS:
    results = CIK_REGEX.findall(get(URL.format(ticker)).content)
    if len(results):
        cik_dict[str(ticker).lower()] = str(results[0])
    else:
      print "CIK not found for: " + ticker


my_ciks = open('my_ciks.txt', 'w')
for key, val in cik_dict.items():
  my_ciks.write(val + "\n")
my_ciks.close()

print "\nNumber of CIKs found :" + str(len(cik_dict)) + "\n"