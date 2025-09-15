import cv2
import mediapipe as mp
import socket
import json
import time

# UDP settings
UDP_IP = "127.0.0.1"
UDP_PORT = 5005

# MediaPipe setup
mp_holistic = mp.solutions.holistic
holistic = mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5)
mp_drawing = mp.solutions.drawing_utils

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Error: Could not open webcam.")
        return

    try:
        while cap.isOpened():
            success, image = cap.read()
            if not success:
                print("Ignoring empty camera frame.")
                continue

            # Flip the image horizontally for a later selfie-view display, and convert
            # the BGR image to RGB.
            image = cv2.cvtColor(cv2.flip(image, 1), cv2.COLOR_BGR2RGB)
            # To improve performance, optionally mark the image as not writeable to
            # pass by reference.
            image.flags.setflags(write=False)
            results = holistic.process(image)

            landmarks_data = []
            if results.pose_landmarks:
                for landmark in results.pose_landmarks.landmark:
                    landmarks_data.append({
                        'x': landmark.x,
                        'y': landmark.y,
                        'z': landmark.z,
                        'visibility': landmark.visibility,
                    })

            if landmarks_data:
                message = json.dumps({"pose_landmarks": landmarks_data}).encode('utf-8')
                sock.sendto(message, (UDP_IP, UDP_PORT))

            # A small delay to prevent overwhelming the network and CPU
            time.sleep(0.01)

    finally:
        print("Closing resources.")
        holistic.close()
        cap.release()
        sock.close()

if __name__ == "__main__":
    main()
