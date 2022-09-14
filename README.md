
Sweet - POC for a cross-platform graphic library
================================================

Rational
--------

Because I can... Or not ?-) Seriously, it is just a POC !
The idea is to create a multi-window user interface with all bell & whistles...
Although true cross-platform involves a lot of complexity (and maybe one should separate
the frontend from the backend / renderer). Dealing with virtual devices is also tricky
(mouse, keyboard, fingers, ...). So here, everything is at least C callable, so multi-languages.

Source of inspirations
----------------------

Qt (https://www.qt.io/)

Solution folders
----------------

ProjectGroup.groupproj : Hold both Delphi projets  
README.md : this very file :)

SweetDemo.dpr : Delphi demo program source code  
SweetDemo.dproj : Delphi project  

Sweet.dpr:  Delphi library source code  
Sweet.dproj : Delphi project  

SweetWrapper.pas : Used by SweetDemo.dpr to reach the library  
SweetWrapper.h : Sample include for a C project  
SweetWrapper.hpp : Sample include for a C++ project  

Sweet.Common.pas : Shared between both Delphi projects  
Sweet.Widget.pas : Hold the widgets logic  

Quick start
-----------

In the Win32\Debug folder

HelloWorld.json : One example file written in json format holding the definition of
a simple window with a single button.

External libraries
------------------

Although finally not used :(

A replacement for the native JSON parser : 

https://github.com/ahausladen/JsonDataObjects

An alternative to TTimer component

http://delphi.cjcsoft.net//viewthread.php?tid=47384 & http://www.gtdelphicomponents.gr

Roadmap
-------

Fix all the issues linked to dll hell ?

Achievements
------------

Made in one day !

License
-------

Smileware

Miscelleanous
-------------

Made with Delphi 10.4 (Sydney)

Greetings
---------

My wife and children for not react when I scream

````
That's all folks ! (this project has started the 14 of September 2022 / mderie@gmail.com / Coded by Sam Le Pirate [TFL-TDV])
````
