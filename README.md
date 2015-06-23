# What Is It?

Asset Generator is a Mac app which takes design assets and adds them to your Xcode project's Xcassets library. Its goal is to bridge the gap between designers and developers: the former can pull project repositories and update assets (in a hopefully intutive way) without bothering the latter.

# How to Use?

Simply drag a folder with images or multiple image files onto the left well, drag an Xcodeproject file onto the right well and hit **Build**. If you modify images in the source folder, the app detects it and you can build again without hassle.

![Asset Generator Screenshot](http://i.imgur.com/pLNIH0l.jpg "Asset Generator Screenshot")

# Download

[Grab the latest build here.](https://github.com/sourcebitsllc/Asset-Generator-Mac/releases)

# Features

- Generates iOS assets.
- Partial support for Mac OS assets.
- Accepts any image file type supported by iOS or Mac OS.

# Notes

- It does **not** scale or compress your assets. You need to prepare all different sizes yourself.
- You need to create Images.xcassets library in Xcode beforehand.
- If you have multiple *.xcassets libraries in your project, Asset Generator will use the first one (alphabetically).

# About

Asset Generator is a collaboration between [Bader Alabdulrazzaq](https://twitter.com/BHAlRezzaga), iOS engineer who graciously greeted Sourcebits for an internship in late 2014, and Sourcebits' Chief Innovation Officer [Piotr Gajos](https://twitter.com/Pe8er). App icon was designed by Sourcebits' senior interaction designer, Rick Patrick.

The app was designed in Sketch, written in Swift and released under the [GNU GPL](http://www.gnu.org/licenses/gpl.html) license.

We would like to thank all Sourcebits developers and designers who helped us with feature ideas and relentless bug reports.
