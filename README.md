# time24 kreait screen saver

A macOS screensaver with a rolling time sync as a side project at kreait.

![Screenshot](./screenshot.png)

## Idea

`time24` will show either an short default movie or you can select your own through the configuration panel.

**Rolling Time Sync**

The play time will be synced (in a rolling way) with your current day time!
If you select a movie running for 24 hours, the displayed time of the movie will be in sync with your current day time - that was the whole point of this experiment.

## Details

- just to test my aging Objective-C skills (and enjoy super short compile times as well as tiny executables), the project adheres to the Xcode template (but [Mike Hill](https://blog.viacom.tech/2016/06/27/making-a-macos-screen-saver-in-swift-with-scenekit/) found a way to set up a Screen Saver in Swift).

- the most annoying part was debugging because attaching an extension to the system Screen Saver is blocked by macOS security policies. `os_log` is not working nicely (at least in High Sierra) due to a lot of data being masked as *<private>* hence the good old `NSLog` (in conjunction with `log stream --process "System Preferences"`) still works fine.

- surprisingly adding a Screen Saver Icon/Image to be shown in the System Preferences was not documented anywhere, but the solution is simple: add `thumbnail.png` and `thumbnail@2x.png` to your project, make sure it will be copied in the build phase and disable `COMBINE_HIDPI_IMAGES` in the build settings. The repo contains a Screen Saver Photoshop template file for that purpose. There is no need to add anything to the `Info.plist` for that icon.

- I'm still learning macOS development, so be patient with my class setup - this is more or less a "beginners 1st project code style". Especially handling the configuration screen in an own class and moving to a storyboard would be next on my agenda.

- as expected but super important: `NSBundle.mainBundle` does not work as the Screen Saver is an extension running in the context of the System Preferences. Hence you have to move that to `[NSBundle bundleForClass:time24.class]` (which is giving nasty dependencies to that main class).

- the embedded movie is only 25 seconds long and will hence jump every now and then. Look for an 24 hours movie and have more fun!

- b2 was rebuild in Xcode 9 and support for macOS 10.12 was integrated as well (needed to wait/observe for URL being prepared)

## Installation

Build this project in Xcode (tested under Xcode 10), open the `Products` group and right-click on `time24.saver` to `Open with External Editor`. You may have to change Bundle Identifier to meet your setup.
