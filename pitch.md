Smart Keyboard
========================================================
author: Alexander Alexandrov
date: Thursday, July 07, 2016
autosize: true

Introduction
========================================================

Around the world, people are spending an increasing amount of time on their mobile devices for email, social networking, and etc. Smart keyboard makes it easier for people to type on their mobile devices. One cornerstone of smart keyboard is predictive text models.

When someone types:

**I went to the**

the keyboard presents several options for what the next word might be. For example:

**gym, store, restaurant**

This project is aimed on building predictive text models like those used by **SwiftKey**.

Predictive Model / Training Data
========================================================

Training data is represented by "raw" text from blogs, news, and twitter:

|             | **Size** | **Message Count** | **Word Count** |
|-------------|----------|-------------------|----------------|
| **Blogs**   | 200 Mb   | 899.288           | 38.031.339     |
| **News**    | 196 Mb   | 77.259            | 2.643.972      |
| **Twitter** | 159 Mb   | 2.360.148         | 30.374.033     |

Data was cleaned from punctation, numbers, stop wrods, profanity words, swear words, URLs, emails, accounts. Because such stuff does not make sense in context of word prediction.

And after **exploratory analysis** following conclusions was done:

1. Significant part of dictionary consists of very rare words. So dictionary can be reduced.
2. For about **6 thousand words** is enough to cover **80%** of corpora.
3. Most efficient model could cover only **71%** of the language.
4. Stemming can help to increase coverage. But this is complicated technique.

Predictive Model / Algorithm
========================================================

Different algorithms have been treated. The most simple wins:

1. Clean up provided query (the same way corpora has been cleaned up).
2. Tokenize and compute number of words.
3. Choose *n* (for *n-gram*) equals to number of words plus one word.
4. Search for appropriate *n-grams* and order results from common (high frequency, or high probability) to rare.
5. If nothing found (or less than some coefficient), remove first word from query, and go to the step 3.
6. Last words of found *n-grams* represent the prediciton result.

Performance
========================================================

Because of huge amount of very rare n-grams, the **dictionary size** has been reduced to **~150 Mb**.

And the **response time** (thanks to *data.table*) of the predictor is **< 1 sec**

Shiny App
========================================================



Thank You for Your Attention
========================================================

I've found following links useful while working on this project.

Theory:

1. [N-gram](https://en.wikipedia.org/wiki/N-gram)
2. [Knser-Ney Smoothing](https://en.wikipedia.org/wiki/Kneser%E2%80%93Ney_smoothing)
3. [Good Turing Smoothing](https://en.wikipedia.org/wiki/Good%E2%80%93Turing_frequency_estimation)
4. [Katz's back-off model](https://en.wikipedia.org/wiki/Katz%27s_back-off_model)

R Packages:

1. Fast and efficient data.frame extension -  [data.table](https://cran.r-project.org/web/packages/data.table/index.html)
2. Text mining package - [tm](https://cran.r-project.org/web/packages/tm/index.html)
3. Collection of machine learning algorithms -  [RWeka](https://cran.r-project.org/web/packages/RWeka/index.html)
4. String processing facilities - [stringi](https://cran.r-project.org/web/packages/stringi/index.html)
