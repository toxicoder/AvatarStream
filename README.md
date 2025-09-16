# AvatarStream: Virtual Camera for macOS

AvatarStream is a macOS application that creates a virtual camera capable of streaming a 3D avatar whose movements are controlled in real-time by your own body movements. Your webcam footage is used to track your pose, which is then mirrored by the avatar. This virtual camera can be used as a video source in various other applications, such as video conferencing software (e.g., Zoom, Google Meet) or streaming software (e.g., OBS).

## Features

*   **Virtual Camera Output**: Creates a system-level virtual camera on macOS that can be used in other applications.
*   **Real-time Body Tracking**: Utilizes MediaPipe to perform real-time pose estimation from your webcam feed.
*   **3D Avatar Animation**: Animates a 3D avatar in real-time based on the tracked body pose.
*   **Customizable Avatars**: Supports the use of custom avatars (as long as they are compatible with Godot).
*   **Adjustable Resolution**: Allows you to change the resolution of the virtual camera stream.

## How it Works

The project has a unique architecture that combines a Python script for body tracking with a Godot application for rendering the avatar and a C++ GDExtension for creating the virtual camera.

1.  **Pose Detection**: A Python script uses OpenCV to capture video from your webcam and MediaPipe to detect your body pose landmarks.
2.  **UDP Communication**: The detected pose landmarks are sent from the Python script to the Godot application over a UDP socket.
3.  **Avatar Animation**: The Godot application receives the landmark data and uses it to animate the bones of a 3D avatar model in real-time.
4.  **Virtual Camera**: A GDExtension written in C++ uses the macOS CoreMediaIO framework to create a virtual camera device.
5.  **Video Streaming**: The Godot application captures its viewport texture, which contains the rendered avatar, and sends it to the GDExtension. The GDExtension then pushes this image data as a video frame to the virtual camera, making it available to other applications.

## Dependencies

To build and run AvatarStream, you will need the following dependencies:

*   **Godot 4.x**: The Godot game engine is used for rendering the avatar and managing the application.
*   **Python 3.x**: Required to run the body tracking script.
*   **Python Libraries**:
    *   `opencv-python`: For capturing webcam footage.
    *   `mediapipe`: For pose estimation.
*   **CMake**: Used to build the C++ GDExtension.
*   **Xcode Command Line Tools**: Required for the C++ compiler and SDKs on macOS.

## Building the GDExtension

The C++ GDExtension that creates the virtual camera needs to be built before running the application.

1.  **Clone the repository with submodules**:
    ```bash
    git clone --recurse-submodules https://github.com/your-username/your-repository.git
    cd your-repository
    ```

2.  **Create a build directory**:
    ```bash
    cd gdextension_cmio
    mkdir build
    cd build
    ```

3.  **Run CMake and build the extension**:
    ```bash
    cmake ..
    make
    ```

    This will compile the GDExtension and place the necessary files in the correct directory for the Godot project to use.

## Running the Application

1.  **Install Python dependencies**:
    ```bash
    pip install opencv-python mediapipe
    ```

2.  **Open the Godot project**:
    *   Launch the Godot editor.
    *   Click "Import" and select the `project.godot` file located in the `game/AvatarStream` directory.

3.  **Run the project**:
    *   Once the project is open in the Godot editor, click the "Play" button (or press F5) to run the application.

## Usage

When you run the application, you will be greeted with the main interface.

*   **Start/Stop Virtual Camera**: Click the "Start Virtual Camera" button to activate the virtual camera. The button text will change to "Stop Virtual Camera".
*   **Select Resolution**: Choose the desired output resolution from the dropdown menu.
*   **Calibrate Avatar**: Click the "Calibrate" button to set the avatar to a T-pose, which can help in resetting its orientation.
*   **Select Camera in Other Apps**: Once the virtual camera is running, open your desired third-party application (e.g., Zoom) and select "AvatarStream Cam" as your video source.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
