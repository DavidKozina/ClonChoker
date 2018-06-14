# ClonChoker

ClonChoker batch script allows you to download and install __choco packages__ from __private Klondike server__.

For help use:
`ClonChoker -help`

## Usage
Samples:
``` 
ClonChoker install *sourceURL* --u *username* --p *password* [packages [-v version]] [-parameters]
ClonChoker install *sourceURL* --u *username* --p *password* --f *requirments file* [-parameters]
ClonChoker install https://chocolatey.org/packages winrar -v 5.50 firefox googlechrome -v 20.0.0.0
```

requirments file can look like this, requirments.txt:
```
winrar 5.50
firefox
googlechrome 20.0.0.0
```
*If you not specify version, script install the highest one.

## About
*Name ClonChoker is an anagram by merging words __Choco__ and __Klondike__*