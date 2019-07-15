## 0.1.3

* Moves plugin calls to the UIThread on Android.
* Updates the target SDK on Android to 28.
* Updates example app.

## 0.1.2+2

* Removes unnecessary dependency from `build.gradle`.


## 0.1.2

* Fixes an issue that were causing screens with big resolution to have big resolution PNG images. Now the PDF image file is capped at 2048 pixels max width.

## 0.1.1

* Fixes an issue on iOS that caused an error on the app launch because the temp directory was trying to be removed without existing. 
* Now all the platform calls are running in a thread on iOS. 

## 0.1.0

* **Initial release**: Create a PDF preview for the specified page as a PNG file (temporary cached).
