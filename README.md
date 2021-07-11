# Recording-Audio-with-Motion-Daemon

## These commands help to check system parameters

`ffmpeg -devices true -i /dev/video0 | more`

`v4l2-ctl --list-devices`

`v4l2-ctl -L`

`arecord -l`

`ffmpeg -sources pulse`


## Works for Audio
`ffmpeg -f pulse -i alsa_input.usb-SHENZHEN_AONI_ELECTRONIC_CO._LTD_Full_HD_webcam_AN99999999999-99.mono-fallback audio-recording-with-real-usb-cam-name.mp3`

`ffmpeg -f pulse -i alsa_input.usb-Sonix_Technology_Co._Ltd._USB_2.0_Camera_SN9999-99.iec999-stereo audio-recording-with-real-usb-cam-name.mp3`


### Make sure that the USB Mic is set as default in pulse audio
`ffmpeg -f pulse -i default Audio-MP3-File.mp3`

### If this command ends with "&" then it will run as a background process
`ffmpeg -f pulse -i default -c:a aac Audio-AAC-File.aac 2>&1 1>/dev/null`


## Work for both Audio and Video
`ffmpeg -f v4l2 -framerate 30 -video_size 640x480 -i /dev/video0 -f pulse -i alsa_input.usb-SHENZHEN_AONI_ELECTRONIC_CO._LTD_Full_HD_webcam_AN99999999999-99.mono-fallback -acodec aac -strict -2 -ac 2 output-av-both-working.mkv`

### Make sure that the USB Mic is set as default in pulse audio
`ffmpeg -f v4l2 -framerate 30 -video_size 640x480 -i /dev/video0 -f pulse -i default -acodec aac -strict -2 -ac 2 output-av-both-working.mkv`
