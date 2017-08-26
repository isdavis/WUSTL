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
porter = nltk.stem.PorterStemmer()
snowball = nltk.stem.SnowballStemmer('english')
lancaster = nltk.stem.LancasterStemmer()
# porter: original
# snowball: computationally faster
# Lancaster: can be aggressive (=may not be intuitive, hugh trimming). Fastest algorithm.

# create dictionaries using stemmers above
# first use the following function to load types of words based on the types of stemmers

# create stem dictionary


def createDictionary(wordtype, stemmer):
    if wordtype == 'positive':
        if stemmer == 'porter':
            output = {porter.stem(w) for w in positive}
        elif stemmer == 'snowball':
            output = {snowball.stem(w) for w in positive}
        elif stemmer == 'lancaster':
            output = {lancaster.stem(w) for w in positive}
    else:
        if stemmer == 'porter':
            output = {porter.stem(w) for w in negative}
        elif stemmer == 'snowball':
            output = {snowball.stem(w) for w in negative}
        elif stemmer == 'lancaster':
            output = {lancaster.stem(w) for w in negative}
    return [output]


positivePorter = createDictionary('positive', 'porter')
negativePorter = createDictionary('positive', 'porter')
positiveSnowball = createDictionary('positive', 'snowball')
negativeSnowball = createDictionary('positive', 'snowball')
positiveLancaster = createDictionary('positive', 'lancaster')
negativeLancaster = createDictionary('positive', 'lancaster')

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
for i in statement:  # loop through all the statement
    print "Statement number = " + str(count)
    # create keys for each statement
    obs[i] = {}
    # 1) count is the statement number
    obs[i]["statementNumber"] = count
    # 2) speaker is capitalized
    obs[i]["speaker"] = re.search('^[A-Z]+', i).group()
    # remove punctuation,
    words = re.sub("\W", " ", i)
    # remove capitalization
    words2 = words.lower()
    # remove stop words - url doesn't work
    # tokenize the words using nltk
    words3 = nltk.word_tokenize(words2)  # = unigram
    # find number of unstemmed words present in each dictionary
    obs[i]["NumPositive"] = len([x for x in words3 if x in positive])
    obs[i]["NumNegative"] = len([x for x in words3 if x in negative])
    # find number of porter stemmed words in each dictionary
    porter_words = [porter.stem(w) for w in words3]
    obs[i]["NumPorterPositive"] = len([x for x in porter_words if x in positivePorter])
    obs[i]["NumPorterNegative"] = len([x for x in porter_words if x in negativePorter])
    # find number of snowball stemmed words in each dictionary
    snowball_words = [snowball.stem(w) for w in words3]
    obs[i]["NumSnowPositive"] = len([x for x in snowball_words if x in positiveSnowball])
    obs[i]["NumSnowNegative"] = len([x for x in snowball_words if x in negativeSnowball])
    # find number of snowball stemmed words in each dictionary
    lancaster_words = [lancaster.stem(w) for w in words3]
    obs[i]["NumLanPositive"] = len([x for x in lancaster_words if x in positiveLancaster])
    obs[i]["NumLanNegative"] = len([x for x in lancaster_words if x in negativeLancaster])
    # increase the count
    count += 1

# check the column names
colnames = obs[statement[0]].keys()
colnames  # check


# set a working directory where positive words and negative words are saved
os.chdir("/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW1/")
# write as a csv file
with open("HWdebate.csv", "w") as f:
    w = csv.DictWriter(f, delimiter=",", fieldnames=colnames)
    w.writeheader()
    for j in obs.keys():
        w.writerow(obs[j])

# Q. stem dictionaries do not seem to work? Not sure which part has an error
