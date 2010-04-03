# Build a release.

# Pull down the latest lesson source
svn export --force http://pushbuttonengine.googlecode.com/svn/trunk/lessons/ .

# Zip each folder up into individual folders 
zip -mr9 Lesson1FlashCS4.zip     Lesson1FlashCS4
zip -mr9 Lesson1FlashDevelop.zip Lesson1FlashDevelop
zip -mr9 Lesson1FlexBuilder.zip  Lesson1FlexBuilder
zip -mr9 Lesson2Base.zip         Lesson2Base
zip -mr9 Lesson2Final.zip        Lesson2Final
zip -mr9 Lesson3Base.zip         Lesson3Base
zip -mr9 Lesson3Final.zip        Lesson3Final
zip -mr9 Lesson4Base.zip         Lesson4Base
zip -mr9 Lesson4Final.zip        Lesson4Final
zip -mr9 Lesson5Base.zip         Lesson5Base
zip -mr9 Lesson5Final.zip        Lesson5Final

mv *.zip ../../docs/downloads/

# Check it in
svn commit ../../docs/downloads/*.zip -m "Automated packaging of Lesson Zips"