##########################
# Homework 2
# Minhee Seo
##########################


# problem 1: find top unigrams and trigrams from the texts

import os
import re
import nltk
import urllib2
import csv
# set working directory

os.chdir("/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/WUSTL/HW/HW2/")

# set the folder directory
sessions = "/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/GrimmerData/raw/Sessions"
shelby = "/Users/minheeseo/Dropbox/2017_Classes/Text-Analysis/GrimmerData/raw/Shelby"
# create empty lists
pressReleases = {}
for i in [sessions, shelby]:  # loop over two folders
    for j in os.listdir(i):  # create lists for both folders
        pressReleases[j] = {}
        pressReleases[j]["day"] = j[:2]
        pressReleases[j]["month"] = j[2:5]
        pressReleases[j]["year"] = j[5:9]
        pressReleases[j]["author"] = re.sub("[0-9]+.txt", "", j[9:])
        with open(i + "/" + j, "r") as fileIn:
            pressReleases[j]["text"] = fileIn.read()

pressReleases  # check
# information is stored appropriarely

# since the url does not work, use the stopwords from nltk.
from nltk.corpus import stopwords
stopWords = stopwords.words('english')
Add = ["shelby", "sessions", "richard", "jeff", "email", "press", "room", "member", "senate"]
stopWords = stopWords + Add


# find 1000 most used unigrams and 500 most used trigrams
# create empty list
unigrams = {}
trigrams = {}
for pr in pressReleases:
    prtext = pressReleases[pr]["text"]
    # remove punctuation
    prtext = re.sub("\W", " ", prtext)
    # remove capitalization
    prtext = prtext.lower()
    # tokenize
    tokenWord = nltk.word_tokenize(prtext)
    # apply porter stem
    porter = nltk.stem.PorterStemmer()
    tokenWord = {porter.stem(x) for x in tokenWord}
    # discard all stemmed stop words
    stopWords = {porter.stem(x) for x in stopWords}
    tokenWord = [x for x in tokenWord if x not in stopWords]
    # find frequencies of unigram
    pressReleases[pr]["NUnigrams"] = len(tokenWord)
    pressReleases[pr]["FUnigrams"] = {}
    for i in set(tokenWord):
        count = tokenWord.count(i)
        pressReleases[pr]["FUnigrams"][i] = count
        if i in unigrams:
            unigrams[i] += count
        else:
            unigrams[i] = count
    trigramList = list(nltk.trigrams(tokenWord))
    pressReleases[pr]["NTrigrams"] = len(trigramList)
    pressReleases[pr]["FTrigrams"] = {}
    for j in set(trigramList):
        count = trigramList.count(j)
        pressReleases[pr]["FTrigrams"][j] = count
        if j in trigrams:
            trigrams[j] += count
        else:
            trigrams[j] = count


# sort by frequencies
unigrams_sort = sorted(unigrams, key=unigrams.get, reverse=True)
trigrams_sort = sorted(trigrams, key=trigrams.get, reverse=True)
# top 1000 unigrams and 500 trigrams
top_unigrams = unigrams_sort[:1000]
top_trigrams = trigrams_sort[:500]


# write a document-term matrix
# unigram
Unigram_header = ["file"] + ["speaker"] + top_unigrams
with open("unigrams1000.csv", "w") as f:
    w = csv.writer(f, delimiter=",")
    w.writerow(Unigram_header)
    for i in pressReleases:
        text_write = []
        text_write.append(i)
        text_write.append(pressReleases[i]["author"])
        for j in top_unigrams:
            if j in pressReleases[i]["FUnigrams"]:
                text_write.append(str(pressReleases[i]["FUnigrams"][j]))
            else:
                text_write.append(str(0))
        w.writerow(text_write)

# trigram

def Tuples(tuples):
    return ".".join(tuples)


trigramTuples = [Tuples(x) for x in top_trigrams]
trigramTuples  # check

Trigram_header = ["file"] + ["speaker"] + trigramTuples

with open("trigrams500.csv", "w") as f:
    w = csv.writer(f, delimiter=",")
    w.writerow(Trigram_header)
    for i in pressReleases:
        text_write = []
        text_write.append(i)
        text_write.append(pressReleases[i]["author"])
        for j in top_trigrams:
            if j in pressReleases[i]["FTrigrams"]:
                text_write.append(str(pressReleases[i]["FTrigrams"][j]))
            else:
                text_write.append(str(0))
        w.writerow(text_write)
