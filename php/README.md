# tollwerk/php
PHP-FPM 7.3 docker image ready for TYPO3 10.x projects

Including:

* [GraphicsMagick](http://www.graphicsmagick.org/)

and these additional tools (required by the [tw_base TYPO3 extension](https://github.com/tollwerk/TYPO3-ext-tw_base)):
 
* [mozjpeg](https://github.com/mozilla/mozjpeg) (available as `mozjpeg` binary)
* [WebP Converter](https://developers.google.com/speed/webp/) (available as `cwebp` binary)
* [SVGO](https://github.com/svg/svgo) (available as `svgo` binary)
* [primitive](https://github.com/fogleman/primitive) (available as `primitive` binary)

## Example commands for testing the additional tools

```bash
mozjpeg -outfile test.moz.jpg test.jpg
primitive -i test.jpg -o test.svg -n 16
svgo -q -i test.svg -o test.opt.svg
cwebp -q 80 -quiet test.jpg -o test.webp
```
