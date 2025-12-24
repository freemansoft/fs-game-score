# Files supporting App Store submission

This directory should contain information used to support the app store information and previews

## Screen shots

[developer app store connect screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications)

### IPhone

Requires 6.5" display.  Screen shots taken of simulator with iphone 13 Pro Max.

Screen shots for store submission in iphone directory.

App Preview captured in simulator landscape mode using simulator.

IPhone app preview recordings must be resized to 1920x886 and a blank audio track added using ffmpeg installed with `brew install ffmpeg`

- `ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -i Freemans\ Game\ Score\ -\ iPhone\ 13\ Pro\ Max\ -\ 2025-12-03\ at\ 18.26.22\ -\ landscape.mov -vf scale=1920:886 -shortest -c:a aac output.mov`

Iphone app preview recordings must be less than 30 seconds.  They can be trimmed using the QuickTime Player.

### IPad

Requires 13" display.  Screen shots taken with ipad air 13"

Screen shots for store submission in ipad directory.

### MacOS

Screen Shots must be 1280x800 or other standard sizes.

Screen shots for store submission are in the macos directory.

## App previews

None yet

## Promotional Text

None yet
