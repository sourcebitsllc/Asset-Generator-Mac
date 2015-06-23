# What Is It?

Asset Generator is a Mac app which takes design assets and adds them to your Xcode project's Xcassets library. Its goal is to bridge the gap between designers and developers: the former can pull project repositories and update assets (in a hopefully intutive way) without bothering the latter.

# How to Use?

Simply drag a folder with images or multiple image files onto the left well, drag an Xcodeproject file onto the right well and hit **Build**.

![Asset Generator Screenshot](http://i.imgur.com/pLNIH0l.jpg "Asset Generator Screenshot")

# Download

[Grab the latest build here.](https://github.com/sourcebitsllc/Asset-Generator-Mac/releases)

# Features

- AG takes any image file type supported by iOS or Mac OS, adds JSON metadata and packages into an Xcassets library, ready for push to your repo.
- If you modify images in the source folder, AG detects it and you can build again right away.
- When you build again, AG appends new assets to the library.
- Dynamically tracks location of both source and destinations when moved.
- Partial support for Mac OS assets.

# Notes

- It does **not** scale or compress your assets. You need to prepare all different dimensions yourself.
- You need to create Images.xcassets library in Xcode before you use AG.
- If you have multiple *.xcassets libraries in your project, Asset Generator will use the first one (alphabetically).

# About

Asset Generator is a collaboration between [Bader Alabdulrazzaq](https://twitter.com/BHAlRezzaga), iOS engineer who graciously greeted Sourcebits for an internship in late 2014, and Sourcebits' Chief Innovation Officer [Piotr Gajos](https://twitter.com/Pe8er). App icon was designed by Sourcebits' senior interaction designer, Rick Patrick.

The app was designed in Sketch, written in Swift and released under the [GNU GPL](http://www.gnu.org/licenses/gpl.html) license.

We would like to thank all Sourcebits developers and designers who helped us with feature ideas and relentless bug reports.
