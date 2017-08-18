##########################
# Homework 1
# Minhee Seo
##########################

import os
import re
import csv
#from urllib.request import urlopen - when running with IDLE
import urllib2
import nltk
from bs4 import BeautifulSoup

# set working directory
os.chdir("/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/WUSTL/")

# Exercise 1

# read debate text data
with open("Debate1.html", "r") as f:
    text = f.read()
# find p using beautiful soup
soup = BeautifulSoup(text)
ps = soup.find_all("p")

# drop unnecessary texts
ps = ps[6:477]

speeches = []  # create empty list
previous = ""

# this loop finds tag in the document and append when the labels are matching
# if the label (speaker) is not matched, the documents are splited.
# also check whether there is appluase or crosstalk; if there is appended to previous statements
for tag in ps:
    statement = tag.get_text()
    m = re.search('^[A-Z]+:', statement)
    if m:
        if m.group() != previous:
            speeches.append(statement)
            previous = m.group(0)
        else:
            last = speeches.pop()
            speeches.append(last + " " + statement)
    else:
        if re.search('\([A-Z]+\)', statement) == None:
            last = speeches.pop()
            speeches.append(last + " " + statement)


# Exercise 2

#import stemmers
porter = nltk.stem.PorterStemmer()
snowball = nltk.stem.SnowballStemmer('english')
lancaster = nltk.stem.LancasterStemmer()

#import dictionaries
pos = urllib2.urlopen("http://www.unc.edu/~ncaren/haphazard/positive.txt").read().split("\n")
neg = urllib2.urlopen("http://www.unc.edu/~ncaren/haphazard/negative.txt").read().split("\n")
stop_words = urllib2.urlopen('http://jmlr.org/papers/volume5/lewis04a/a11-smart-stop-list/english.stop').read().split('\n')

# create sets of dictionaries.
# note: we use sets because the dictionaries, especially once stemmed, contain many duplicates, and we only need
# to test for membership. sets are the most efficient data strcuture for this task. Note the set comprehension
# syntax, which is the same as list comprehension but surrounded by curly brackets instead of square brackets.

posPorter = {porter.stem(w) for w in pos}
posSnowball = {snowball.stem(w) for w in pos}
posLancaster = {lancaster.stem(w) for w in pos}
negPorter = {porter.stem(w) for w in neg}
negSnowball = {snowball.stem(w) for w in neg}
negLancaster = {lancaster.stem(w) for w in neg}
stop_words = set(stop_words)
pos = set(pos)
neg = set(neg)

# loop over statements list to create dictionary with each statement as a key with
# attributes we want as nested dictionaries

obs = {}
count = 1
for i in statements:
    print "count = " + str(count)
    obs[i] = {}
    obs[i]["statementNumber"] = count
    # record first all caps word in statement as speaker
    obs[i]["speaker"] = re.search('^[A-Z]+', i).group()
    # remove punctuation, capitalization, and tokenize statement
    words = re.sub("\W", " ", i)
    words = words.lower()
    words = nltk.word_tokenize(words)
    # find number of unstemmed words present in each dictionary
    obs[i]["numNonStop"] = len([x for x in words if x not in stop_words])
    obs[i]["numPositive"] = len([x for x in words if x in pos])
    obs[i]["numNegative"] = len([x for x in words if x in neg])
    # find number of lancaster stemmed words in each dictionary
    words_lan = [lancaster.stem(w) for w in words]
    obs[i]["numLancasterPos"] = len([x for x in words_lan if x in posLancaster])
    obs[i]["numLancasterNeg"] = len([x for x in words_lan if x in negLancaster])
    # find number of porter stemmed words in each dictionary
    words_port = [porter.stem(w) for w in words]
    obs[i]["numPorterPos"] = len([x for x in words_port if x in posPorter])
    obs[i]["numPorterNeg"] = len([x for x in words_port if x in negPorter])
    # find number of snowball stemmed words in each dictionary
    words_snow = [snowball.stem(w) for w in words]
    obs[i]["numSnowballPos"] = len([x for x in words_snow if x in posSnowball])
    obs[i]["numSnowballNeg"] = len([x for x in words_snow if x in negSnowball])
    # increment count variable to keep track of statement numbers
    count += 1


###
len(statements) == len(obs)  # False. What's missing?
allstatements = range(0, len(statements))
inDict = []
for i in obs:
    inDict.append(obs[i]["statementNumber"])

missing = [x for x in allstatements if x not in inDict]
ms = [statements[x - 1] for x in missing]
# this is missing observations for counts: 10, 14, 18, 48, 60, 70, 93, 98, 139.
# lookd at them and they aren't substantively interesting so I'm not going to worry about it.


# these will be the column names
colnames = obs[statements[0]].keys()

# write dictionary to CSV
with open("debate.csv", "w") as csvfile:
    writer = csv.DictWriter(csvfile, delimiter=",", fieldnames=colnames)
    writer.writeheader()
    for s in obs.keys():
        writer.writerow(obs[s])
