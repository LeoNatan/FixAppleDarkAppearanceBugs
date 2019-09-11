#!/bin/zsh

rm -fr /Applications/Music.app
cp -fR /System/Applications/Music.app /Applications/
codesign -d --entitlements :/tmp/music_ent.plist /Applications/Music.app/Contents/MacOS/Music
# Rename __RESTRICT and __restrict
perl -pe 's/\x{5F}\x{5F}\x{52}\x{45}\x{53}\x{54}\x{52}\x{49}\x{43}\x{54}/\x{5F}\x{5F}\x{4E}\x{45}\x{53}\x{54}\x{52}\x{49}\x{43}\x{54}/g;s/\x{5F}\x{5F}\x{72}\x{65}\x{73}\x{74}\x{72}\x{69}\x{63}\x{74}/\x{5F}\x{5F}\x{6E}\x{65}\x{73}\x{74}\x{72}\x{69}\x{63}\x{74}/g' < /Applications/Music.app/Contents/MacOS/Music > /Applications/Music.app/Contents/MacOS/Music2
mv -f /Applications/Music.app/Contents/MacOS/Music2 /Applications/Music.app/Contents/MacOS/Music
chmod +x /Applications/Music.app/Contents/MacOS/Music
codesign -f --entitlements /tmp/music_ent.plist -s - /Applications/Music.app/Contents/MacOS/Music