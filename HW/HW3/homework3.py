##########################
# Homework 3
# Minhee Seo
##########################

import os
import re
import nltk
import urllib2
import csv
import json

# problem 1

# a, b
os.chdir("/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/WUSTL/")
with open('nyt_ac.json') as json_data:
    dat = json.load(json_data)
    print(dat)  # check

type(dat)  # list

dat[1]  # check
# data is organized in two parts. 1) Body=text  2) Meta=title, correction date, publicatino date, etc.
len(dat)  # length is 288
dat[1].keys()  # [u'body', u'meta']

# c.
os.chdir("/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW3/")

# Title in front of text
for i in range(0, 288):
    with open(str(i + 1) + '.txt', 'w') as text_file:  # w for txt file
        text_file.write(json.dumps(dat[i]['body']))


# d, e
# porter stemmer
porter = nltk.stem.PorterStemmer()
# load stopwords
from nltk.corpus import stopwords  # use the stopwords from nltk.
stopWords = stopwords.words('english')
stopWords = {porter.stem(x) for x in stopWords}
# clean text data
for i in range(0, 288):
    dat[i]['body']['unigram'] = []  # include a key that will contain unigram
    # lower case (for only body text, not the title)
    textbody = dat[i]['body']['body_text'].lower()
    # remove punctuation
    textbody = re.sub("\W", " ", textbody)
    # tokenized each story
    textbody = nltk.word_tokenize(textbody)
    # apply porter stemmer
    textbody = {porter.stem(x) for x in textbody}
    # remove stop words
    textbody = [x for x in textbody if x not in stopWords]
    # then append unigram tokens
    dat[i]['body']['unigram'] = textbody

# then, construct a matrix of unigram with its frequencies so that we would know 1000 most used words.
# create empty list
unigramList = {}
for i in range(0, 288):  # for each story
    for j in dat[i]['body']['unigram']:  # add unigram words to the empty list
        if j not in unigramList:
            unigramList[j] = 1  # if there is already a word in the list, increment it by 1. If not, record the frequency as 1.
        else:
            unigramList[j] += 1

unigramList  # check the list and the frequencies

# sort by frequencies
unigrams_sort = sorted(unigramList, key=unigramList.get, reverse=True)
# top 1000 unigrams
top_unigrams = unigrams_sort[:1000]

top_unigrams  # check

# construct Document Term Matrix
with open('DTM_NYTimes.csv', 'wb') as my_text:  # wb for csv file.
    writer = csv.writer(my_text)
    DTMHeader = top_unigrams  # first column is dsk as the following line shows. Other lines are in the order of 1000 most used words
    DTMHeader.insert(0, 'dsk')  # include desk from which the story originated
    writer.writerow(DTMHeader)
    for i in range(0, 288):  # loop over each document and count the number of words that are matched with words in "unigram"
        rowentry = []
        for j in top_unigrams:
            rowentry.append(dat[i]['body']['unigram'].count(j))
        rowentry.insert(0, dat[i]['meta']['dsk'])  # insert desk from which the sotry originated
        writer.writerow(rowentry)

# rest of part in problem 1 is in R file.


# problem 2
