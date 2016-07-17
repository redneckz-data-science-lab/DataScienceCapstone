Smart Keyboard
========================================================
author: Alexander Alexandrov
date: Thursday, July 07, 2016
autosize: true

Smart keyboard makes it easier for people to type on their mobile devices. One cornerstone of smart keyboard is predictive text models.

When someone types: **I went to the**

The keyboard presents several options: **gym, store, restaurant**

Predictive Model / Data
========================================================

Training data is represented by "raw" text from blogs, news, and twitter:

|             | **Size** | **Message Count** | **Word Count** |
|-------------|----------|-------------------|----------------|
| **Blogs**   | 200 Mb   | 899.288           | 38.031.339     |
| **News**    | 196 Mb   | 77.259            | 2.643.972      |
| **Twitter** | 159 Mb   | 2.360.148         | 30.374.033     |

Data was cleaned from punctation, numbers, stop wrods, profanity words, swear words, URLs, emails, accounts. Because such stuff does not make sense in context of word prediction.

Algorithm is based on n-gram frequency dictionary. According to exploratory analysis dictionary has been cleaned from rare n-grams to reduce memory usage and increase performance.

Predictive Model / Algorithm
========================================================

1. Clean up provided query (the same way corpora has been cleaned up).
2. Tokenize and compute number of words.
3. Choose *n* (for *n-gram*) equals to number of words plus one word.
4. Search for appropriate *n-grams* and order results from common (high frequency, or high probability) to rare.
5. If nothing found (or less than some coefficient), remove first word from query, and go to the step 3.
6. Last words of found *n-grams* represent the prediciton result.

Shiny App
========================================================

[Shiny App](https://redneckz.shinyapps.io/DataScienceCapstone/)

Features:

1. **Result View Modes**.
2. **Kneser-Ney** smoothing.
3. **String Metrics** to deal with typos.

Manual:

1. Wait dictionary load in **~5 sec**.
2. Eneter some text and explore results in **< 1 sec**.

Thank You for Your Attention
========================================================

More information can be found in reports:

1. [Exploratory Data Analysis Report](http://rpubs.com/redneckz/smart-keyboard-exploratory-data-analysis).
2. [Basic Modeling Report](http://rpubs.com/redneckz/smart-keyboard-basic-modeling).
