# What Is It?

Asset Generator is a Mac app which takes design assets and adds them to your Xcode project's [asset catalog](https://developer.apple.com/library/ios/recipes/xcode_help-image_catalog-1.0/Recipe.html#//apple_ref/doc/uid/TP40013303-CH1-SW1). Its goal is to bridge the gap between designers and developers: the former can pull project repositories and update assets (in a hopefully intutive way) without bothering the latter.

# How to Use?

Simply drag a folder with images or multiple image files onto the left well, drag an Xcodeproject file onto the right well and hit **Build**.

![Asset Generator Screenshot](http://imgur.com/SPz0i7K.jpg "Asset Generator Screenshot")

# Download

[Grab the latest build here.](https://github.com/sourcebitsllc/Asset-Generator-Mac/releases)

# Features

- Automatically detects asset types based on keywords and image metadata.
- Supports iOS and Mac assets.
- Merges new assets with existing catalog data so you can incrementally build assets as you go in a safe manner.
- Preserves content created through Xcode such as slicing information and size classes.
- Dynamically tracks location of both source and destinations when moved.

# Notes

- It does **not** scale or compress your assets. You need to prepare all different dimensions yourself.
- You need to have an asset catalog in your project to use AG.
- If you have multiple catalogs in your project, Asset Generator will use the first one (alphabetically).

# How to Build

1. Clone the repo into your machine.
2. To build the project dependencies, install [Carthage](http://github.com/Carthage/Carthage/) with [Homebrew](http://brew.sh/) as follows:

	```bash
	$ brew update
	$ brew install carthage
	```
3. Run `carthage update` to setup the dependencies.

# About

Asset Generator is a collaboration between [Bader Alabdulrazzaq](https://twitter.com/BHAlRezzaga), iOS and Mac OS engineer who graciously greeted Sourcebits for an internship in late 2014, and Sourcebits' Chief Innovation Officer [Piotr Gajos](https://twitter.com/Pe8er). App icon was designed by Sourcebits' senior interaction designer, Rick Patrick.

The app was designed in Sketch, written in Swift and released under the [GNU GPL](http://www.gnu.org/licenses/gpl.html) license.

We would like to thank all Sourcebits developers and designers who helped us with feature ideas and relentless bug reports.
