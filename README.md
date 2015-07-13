# What Is It?

Asset Generator is a Mac app which takes design assets and adds them to your Xcode project's [asset catalog](https://developer.apple.com/library/ios/recipes/xcode_help-image_catalog-1.0/Recipe.html#//apple_ref/doc/uid/TP40013303-CH1-SW1). Its goal is to bridge the gap between designers and developers: the former can pull project repositories and update assets (in a hopefully intuitive way) without bothering the latter.

# How to Use?

Simply drag a folder with images or multiple image files onto the left well, drag an Xcodeproject file onto the right well and hit **Build**.

![Asset Generator Screenshot](http://imgur.com/SPz0i7K.jpg "Asset Generator Screenshot")

# Download

[Grab the latest build here.](https://github.com/sourcebitsllc/Asset-Generator-Mac/releases)

# Features

- Automatically detects asset types based on [keywords](#keywords) and image metadata.
- Supports iOS and Mac assets (including icons, launch images, Spotlight and settings assets, and more).
- Merges new assets with existing catalog data so you can incrementally build assets as you go in a safe manner.
- Preserves content created through Xcode such as slicing information and size classes.
- Dynamically tracks location of both source and destinations when moved.

# Keywords

Keywords are tags added to the image filename that help the app determine the proper information of the image. The good news is, if you follow Apple's naming convention you're already done! If not, it's very simple. Asset Generator keywords take the following form:
`<ImageName><PixelDensity><Device>.<Extension>`

where:

- `<PixelDensity>` is either _@2x_, _@3x_ or blank for _@1x_.
- `<Device>`  specifies the target device which can be either _~iphone_, _~ipad_, _~mac_, or blank for universal.
- `<Extension>` are the support image extensions which are _png_, _jpg_ and _jpeg_. 

### App Icons

- For iOS icons, the `<ImageName>` must start with either _**"AppIcon"**_ or _**"Icon"**_ and Asset Generator takes care of the rest.
- Mac OS icons must start with ***"icon_"*** and must follow Apple's naming convention [found here](https://developer.apple.com/library/mac/documentation/UserExperience/Conceptual/OSXHIGuidelines/Designing.html).
- More information about iOS icons can be found [here](https://developer.apple.com/library/ios/qa/qa1686/_index.html) and [here](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/MobileHIG/IconMatrix.html#//apple_ref/doc/uid/TP40006556-CH27-SW2).

### Launch Images

- For launch images, the `<ImageName>` must start with either _**"Default"**_ or _**"LaunchImage"**_ and Asset Generator takes care of the rest.
- More information about launch images can be found [here](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/MobileHIG/LaunchImages.html#//apple_ref/doc/uid/TP40006556-CH22-SW1) and [here](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/MobileHIG/IconMatrix.html#//apple_ref/doc/uid/TP40006556-CH27-SW2).

### General Images

For all other assets, you need to provide all the keywords mentioned above and the app will parse the data as such. For example `Button@3x~iphone.png` is a @3x iPhone button image and `Spinner@2x.png` is a @2x universal spinner image.
  
# Notes

- Asset Generator does **not** scale or compress your assets. You need to prepare all different dimensions yourself.
- You need to have an asset catalog in your project to use Asset Generator.
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

The app was designed in Sketch and coded in Swift.

We would like to thank all Sourcebits developers and designers who helped us with feature ideas and relentless bug reports.

# License

Asset Generator is released under the MIT license. See [LICENSE](LICENSE) for details.
