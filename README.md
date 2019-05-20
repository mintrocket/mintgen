# mintgen
**mintgen** is an utility written in Swift for generating code for Xcode projects. Primarily it is designed to generate Swift classes but it is quite easy to customize it for generation of Objective-C classes and other.

---
### Installation
- _[Homebrew](https://brew.sh)_

```
brew tap mintrocket/tap https://github.com/mintrocket/homebrew-tap
brew install mintgen
```

---
### Usage
1)  Create `mintgen.json` file.
```
{
	"xcodeprojPath": "someProject.xcodeproj",
	"projectName": "someProjectName",
	"projectTarget": "someProjectTarget",
	"prefix": "MR",
	"projectFilePath": "someProject/Classes/Modules",
	"templatesPath": "templates",

	"company": "Mint Rocket LLC",
	...
	"myParam": "My awesome parameter"
}
```
Required params:
- xcodeprojPath - path to your \*.xcodeproj
- projectName - project for generated files
- projectTarget - target for include build phase
- prefix - for files
- projectFilePath - default path for generated files
- templatesPath - path to templates

You can include other custom parameters for use them in your templates.

2) Create templates.
- Templates language: 
 **mintgen** uses Stencil for code generation. 
 Resources for Stencil template authors to write Stencil templates:
	- [Language overview](http://stencil.fuller.li/en/latest/templates.html)
	- [Built-in template tags and filters](http://stencil.fuller.li/en/latest/builtins.html)
- Templates naming:
The template name is included to generation process and all templates should be ended with ".mint", e.g:
	- template: `ViewController.swift.mint`
	- generation result witn name 'Main' and prefix 'MR': `MRMainViewController.swift`

3) Run command `mintgen <name>`, e.g. `mintgen Main`.
Also you can include additional path for generated files, e.g. `mintgen Common/Main`
**Parametr `<name>` is case sensitive**

---

## Licence

This code and tool is under the MIT Licence. See the `LICENCE` file in this repository.

## Attributions

This tool is powered by

- [Stencil](https://github.com/stencilproject/Stencil)
- [xcodeproj](https://github.com/tuist/xcodeproj)
