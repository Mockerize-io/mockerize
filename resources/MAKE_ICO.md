# Resource: https://graphicdesign.stackexchange.com/questions/77359/how-to-convert-a-square-svg-to-all-size-ico
## Also make 256

### Make image set
```
inkscape -w 16 -h 16 -o 16.png mockerize-final.inkscape.svg && inkscape -w 32 -h 32 -o 32.png mockerize-final.inkscape.svg && inkscape -w 48 -h 48 -o 48.png mockerize-final.inkscape.svg && inkscape -w 256 -h 256 -o 256.png mockerize-final.inkscape.svg
```

### Create icon
```
convert 16.png 32.png 48.png 256.png icon.ico 
```