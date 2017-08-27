##########################
# Homework 1
# Minhee Seo
##########################


# problem 1: load the data and parse the content


# a) load the data
import os
import re
import csv
# from urllib.request import urlopen  # when running with IDLE
import urllib2
import nltk
from bs4 import BeautifulSoup

# set working directory
os.chdir("/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/WUSTL/")

# read debate text data
with open("Debate1.html", "r") as source:
    text = source.read()
text  # check
type(text)  # str

# we can use p to identify the statement
# find p by using beautiful soup
soupText = BeautifulSoup(text).find_all("p")
soupText  # check
# Not all the statements contain information about the speaker. In order to clean this text data, first, drop unnecessary HTML section
len(soupText)  # 480
# mannually went through some lines to find the irrelevant part of the text.
# speech starts from soupText[6] to soupText[476]
# Q. is there more efficient way?
soupText = soupText[6:476]

# next, in order to create uninterrupted speech by each speaker, run the following loop. The speech is only interrupted when a different speaker has begun.

# create empty list
statement = []
# create empty str
previous = ""

# this loop finds tag in the document and append when the labels are matching (when speaker is continously speaking)
# if the label is not matched, the documents are splited. (when the next speaker is speaking)
# also check whether there is applause or crosstalk

for tag in soupText:  # find tag in the document
    speechText = tag.get_text()  # find speech by tag in the document
    debateLabel = re.search('^[A-Z]+:', speechText)  # for each speech, find whether there are capitalized words in the beginning; ^[A-Z] and with : symbol +: Capitalized words indecate speakers. Assign it to debateLabel null list.
    if debateLabel:
        present = debateLabel.group()  # assign it as a present speaker
        if present != previous:  # if present speaker label is not the same as previous speaker
            statement.append(speechText)  # add a speech to a present speaker name
            previous = debateLabel.group(0)  # store the first element of capitalized letters (which is a speaker name) as a previous one.
        else:  # if present speaker label is the same as previous speaker label
            last = statement.pop()  # remove the name and add speeches to the previous speaker label.
            statement.append(last + " " + speechText)
    else:  # if there is no speaker name -- when the speaker is continously speaking
        if re.search('\([A-Z]+\)', speechText) == None:  # if speaker label cannot be found, add the speech to the last statement
            last = statement.pop()
            statement.append(last + " " + speechText)

statement  # check if speeches are parsed well. It looks good.
statement[1]
statement[20]

# Q. do I need to go through this mannually? Or is there more efficient way to check ?

# problem 2: load and use dictionaries

# import positive and negative words
positive = urllib2.urlopen("http://www.unc.edu/~ncaren/haphazard/positive.txt").read().split("\n")
negative = urllib2.urlopen("http://www.unc.edu/~ncaren/haphazard/negative.txt").read().split("\n")
positive  # check
negative  # check

# use various stemmers from the nltk package
from nltk.stem.porter import *
porter = nltk.stem.PorterStemmer()
snowball = nltk.stem.SnowballStemmer('english')
lancaster = nltk.stem.LancasterStemmer()
# porter: original
# snowball: computationally faster
# Lancaster: can be aggressive (=may not be intuitive, hugh trimming). Fastest algorithm.

# create dictionaries using stemmers above
# first use the following function to load types of words based on the types of stemmers

# create stem dictionary


negativePorter = [porter.stem(w) for w in negative]
positivePorter = [porter.stem(w) for w in positive]
negativeSnowball = [snowball.stem(w) for w in negative]
positiveSnowball = [snowball.stem(w) for w in positive]
negativeLancaster = [lancaster.stem(w) for w in negative]
positiveLancaster = [lancaster.stem(w) for w in positive]

# create original dictionary
positive = set(positive)
negative = set(negative)

# create statement by statement data set of the speech
len(statement)  # check the length
# 167
# create empty list
obs = {}
# start with 0. count tracks the statement number
count = 0
for i in range(0, 167):  # loop through all the statement
    print "Statement number = " + str(count)
    # create keys for each statement
    obs[i] = {}
    # 1) count is the statement number
    obs[i]["statementNumber"] = count
    # 2) speaker is capitalized
    obs[i]["speaker"] = re.search('^[A-Z]+', statement[i]).group()
    # remove punctuation,
    words = re.sub("\W", " ", statement[i])
    # remove capitalization
    words = words.lower()
    # remove stop words - url doesn't work
    # tokenize the words using nltk
    words = nltk.word_tokenize(words)  # = unigram
    # find number of unstemmed words present in each dictionary
    obs[i]["NumPositive"] = len([x for x in words if x in positive])
    obs[i]["NumNegative"] = len([x for x in words if x in negative])
    # find number of porter stemmed words in each dictionary
    porterstem = [porter.stem(w) for w in words]
    obs[i]["NumPorterPositive"] = len([x for x in porterstem if x in positivePorter])
    obs[i]["NumPorterNegative"] = len([x for x in porterstem if x in negativePorter])
    # find number of snowball stemmed words in each dictionary
    snowstem = [snowball.stem(w) for w in words]
    obs[i]["NumSnowPositive"] = len([x for x in snowstem if x in positiveSnowball])
    obs[i]["NumSnowNegative"] = len([x for x in snowstem if x in negativeSnowball])
    # find number of snowball stemmed words in each dictionary
    lanstem = [lancaster.stem(w) for w in words]
    obs[i]["NumLanPositive"] = len([x for x in lanstem if x in positiveLancaster])
    obs[i]["NumLanNegative"] = len([x for x in lanstem if x in negativeLancaster])
    # increase the count
    count += 1


# set a working directory where positive words and negative words are saved
os.chdir("/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW1/")
# write as a csv file
with open("HWdebate.csv", "w") as f:
    w = csv.DictWriter(f, delimiter=",", fieldnames=["NumLanNegative", "NumLanPositive", "NumNegative", "NumPorterNegative", "NumPorterPositive", "NumPositive", "NumSnowNegative", "NumSnowPositive", "speaker", "statementNumber"])
    w.writeheader()
    for j in obs.keys():
        w.writerow(obs[j])

# Q. stem dictionaries do not seem to work? Not sure which part has an error - previous function was not working. Fixed.
