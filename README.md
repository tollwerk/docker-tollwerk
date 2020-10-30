# docker-tollwerk
An experimental set of docker images ready for tollwerk TYPO3 projects

* [tollwerk/adoc2pdfua](adoc2pdfua/README.md): AsciiDoc to PDF/UA converter, including the tollwerk document theme
* [tollwerk/ant](ant/README.md): OpenJDK + Ant for building Java projects 
* [tollwerk/base](base/README.md): Apache HTTP + PHP 7.3 (CLI) base image for web projects
* [tollwerk/php](php/README.md): PHP-FPM 7.3 docker image ready for TYPO3 10.x projects
* [tollwerk/php-ci](php-ci/README.md): Based on `tollwerk/php`, particularly prepared for being used in Gitlab CI / CD pipelines
* [tollwerk/solr-ci](solr-ci/README.md): Based on the official Apache Solr image, particularly prepared for being used in Gitlab CI / CD pipelines
* [tollwerk/typo3](typo3/README.md): Based on `tollwerk/base`, configured for and including TYPO3 v10.x 
* [tollwerk/web](web/README.md): Based on `tollwerk/base`, a simple container for web projects without particular requirements 
