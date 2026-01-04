import pytest
from unittest.mock import MagicMock, patch
import socket
import json
import cv2
import numpy as np

# Adjust path to import holistic_tracker
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from holistic_tracker import HolisticTracker

@pytest.fixture
def mock_socket():
    return MagicMock(spec=socket.socket)

@pytest.fixture
def tracker(mock_socket):
    with patch('holistic_tracker.mp') as MockMP:
        # Mock the Holistic model
        # The code uses:
        # self.mp_holistic = mp.solutions.holistic
        # self.holistic = self.mp_holistic.Holistic(...)

        # By mocking 'holistic_tracker.mp', MockMP becomes the 'mp' module in holistic_tracker.
        # MockMP.solutions.holistic.Holistic will be the class constructor.

        # We can configure the return value if needed, but the default MagicMock behavior is usually sufficient
        # to prevent errors and verify calls.

        tracker = HolisticTracker(sock=mock_socket, no_mirror=True) # no_mirror=True to skip flip logic
        yield tracker

def test_initialization(tracker, mock_socket):
    assert tracker.camera_idx == 0
    assert tracker.udp_ip == "127.0.0.1"
    assert tracker.udp_port == 5005
    assert tracker.sock == mock_socket

def test_process_frame(tracker):
    # Create a dummy image
    dummy_image = np.zeros((100, 100, 3), dtype=np.uint8)

    # Mock the return value of holistic.process
    mock_results = MagicMock()
    mock_results.pose_landmarks = None
    tracker.holistic.process.return_value = mock_results

    results = tracker.process_frame(dummy_image)

    assert results == mock_results
    tracker.holistic.process.assert_called_once()

def test_extract_landmarks_empty(tracker):
    mock_results = MagicMock()
    mock_results.pose_landmarks = None

    landmarks = tracker.extract_landmarks(mock_results)
    assert landmarks == []

def test_extract_landmarks_with_data(tracker):
    mock_results = MagicMock()
    mock_landmark = MagicMock()
    mock_landmark.x = 0.1
    mock_landmark.y = 0.2
    mock_landmark.z = 0.3
    mock_landmark.visibility = 0.9

    mock_results.pose_landmarks.landmark = [mock_landmark]

    landmarks = tracker.extract_landmarks(mock_results)
    assert len(landmarks) == 1
    assert landmarks[0]['x'] == 0.1
    assert landmarks[0]['y'] == 0.2
    assert landmarks[0]['z'] == 0.3
    assert landmarks[0]['visibility'] == 0.9

def test_send_data(tracker, mock_socket):
    landmarks_data = [{'x': 0.1, 'y': 0.2, 'z': 0.3, 'visibility': 0.9}]

    success = tracker.send_data(landmarks_data)

    assert success is True
    mock_socket.sendto.assert_called_once()

    # Verify the sent data
    args, _ = mock_socket.sendto.call_args
    sent_data = json.loads(args[0].decode('utf-8'))
    assert 'pose_landmarks' in sent_data
    assert sent_data['pose_landmarks'][0]['x'] == 0.1

def test_send_data_empty(tracker, mock_socket):
    success = tracker.send_data([])
    assert success is False
    mock_socket.sendto.assert_not_called()

def test_send_data_error(tracker, mock_socket):
    mock_socket.sendto.side_effect = Exception("UDP Error")
    landmarks_data = [{'x': 0.1}]

    success = tracker.send_data(landmarks_data)
    assert success is False
