#XQuery4Humanists

We're going to explore some fundamental concepts of XQuery and then try out some applications. 

* [Session One](session-one.md) covers the fundamentals of XQuery.
* [Session Two](session-two.md) applies what we've learned about XQuery so far to the analysis of poetry and drama.
* [Session Three](session-three.md) provides an introduction to XML database and to converting between different formats like CSV and JSON.

##Installation Instructions

You've got three options for an XQuery processor. Personally, I'd recommend getting started with BaseX right at the beginning of our sessions. It's got a easy to user interface and is highly standards compliant. (You can tell that I'm a big BaseX fan!) But it's not necessary until our third session, when we'll be looking at using XQuery in the context of XML databases.

**BaseX**

[BaseX](http://basex.org/) is an open source XML database. I recommend using the [Windows installer](http://files.basex.org/releases/8.3/BaseX83.exe) if you're using Windows and using [Homebrew](http://brew.sh/) if you're on a Mac. The installation command is ```brew install basex```.

> Note: Installing BaseX may require that you update to Java 7. If so, install the [Java Runtime Environment (JRE)](https://java.com/en/download/) and try again.

![BaseX, an open source XML Database](http://i.imgur.com/twQUdGH.png)

**oXygen XML**
 If you're using the oXygen XML editor, we're assuming that you're using Saxon PE (professional edition) v. 9.5.1.7 or later and that you've turned on support for XQuery 3.0. Check your settings to make sure we'll all on the same page.

![Imgur](http://i.imgur.com/pAcmiju.png)

**Zorba**

If you cannot get oXygen or BaseX to work, don't worry! You can also execute these XQuery expressions using an hosted instance of [Zorba](http://try-zorba.28.io/queries/xquery), an open source XQuery and JSONiq processor. Just clear out the code and substitute the XQuery code you want to evaluate. This is a good option 



