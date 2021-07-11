#!/usr/bin/env bash

# Set variables
operation=$1
motion_thread_id=$2
file_path=$3
camera_name=$4
camera_id=$2

echo "Camera name" $camera_name
echo "Camera ID" $camera_id

motion_config_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
motion_camera_conf="${motion_config_dir}/camera${camera_id}.conf"
#motion_camera_conf="${motion_config_dir}/camera3-dist.conf"
# Below line was a temporary fix replacing camera ID with camera name due to cameraID/thread mismatch - motion_thread_id should fix this
# motion_camera_conf="$( egrep -l \^camera_name.${camera_name} ${motion_config_dir}/*.conf)"
#netcam="$(if grep -q 'netcam_highres' ${motion_camera_conf};then echo 'netcam_highres'; else echo 'netcam_url'; fi)"
netcam="$(if grep -q 'netcam_highres' ${motion_camera_conf};then echo 'netcam_highres'; else if grep -q 'netcam_url' ${motion_camera_conf};then echo 'netcam_url';else echo 'USB_Cam_mic';fi;fi)"

echo "File path" $file_path
echo "Net Cam" $netcam

extension="$(echo ${file_path} | sed 's/^/./' | rev | cut -d. -f1  | rev)"



case ${operation} in
    start)
        if [ $netcam == "USB_Cam_mic" ];
        then 
            echo "Executing ffmpeg for USB_Cam_mic"
            default_mic="$(ffmpeg -sources pulse | grep *"

            ffmpeg -f pulse -i default -c:a aac ${file_path}.aac 2>&1 1>/dev/null &
        else 
            echo "Executing ffmpeg for network camera"
            credentials="$(grep netcam_userpass ${motion_camera_conf} | sed -e 's/netcam_userpass.//')"
            stream="$(grep ${netcam} ${motion_camera_conf} | sed -e "s/${netcam}.//")"
	    echo "Stream " $stream
            full_stream="$(echo ${stream} | sed -e "s/\/\//\/\/${credentials}@/")"
            echo "Full Stream" $full_stream
            ffmpeg -y -i "${full_stream}" -c:a aac ${file_path}.aac 2>&1 1>/dev/null &
        fi
        ffmpeg_pid=$!
        #This temp file just stores the process ID to kill when motion has stopped
        echo ${ffmpeg_pid} > /tmp/motion-audio-ffmpeg-camera-${camera_id}
        # echo ${ffmpeg_pid} > /tmp/motion-audio-ffmpeg-camera-${camera_name}
        ;;

    stop)
        # Kill the ffmpeg audio recording for the clip
        kill $(cat /tmp/motion-audio-ffmpeg-camera-${camera_id})
        rm -rf $(cat /tmp/motion-audio-ffmpeg-camera-${camera_id})
        ls -ltr /dev/video*        # kill $(cat /tmp/motion-audio-ffmpeg-camera-${camera_name})
        # rm -rf $(cat /tmp/motion-audio-ffmpeg-camera-${camera_name})

        # Merge the video and audio to a single file, and replace the original video file
        ffmpeg -y -i ${file_path} -i ${file_path}.aac -c:v copy -c:a copy ${file_path}.temp.${extension};
        mv -f ${file_path}.temp.${extension} ${file_path};

        # Remove audio file after merging
        # rm -f ${file_path}.aac;
        ;;

    *)
        echo "Usage ./get-audio.sh start <camera-id> <full-path-to-moviefile>"
        # echo "Usage ./get-audio.sh start <camera-name> <full-path-to-moviefile>"
        exit 1
esac
