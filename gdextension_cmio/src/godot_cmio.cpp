#include "godot_cmio.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

GodotCMIO::GodotCMIO() {
  m_device_id = kCMIOObjectUnknown;
  m_stream_id = kCMIOObjectUnknown;
  m_queue = nullptr;
  m_width = 1280;
  m_height = 720;
  m_running = false;
}

GodotCMIO::~GodotCMIO() {
  if (m_running) {
    stop_virtual_camera();
  }
}

void GodotCMIO::_bind_methods() {
  ClassDB::bind_method(D_METHOD("start_virtual_camera"), &GodotCMIO::start_virtual_camera);
  ClassDB::bind_method(D_METHOD("stop_virtual_camera"), &GodotCMIO::stop_virtual_camera);
  ClassDB::bind_method(D_METHOD("set_resolution", "width", "height"), &GodotCMIO::set_resolution);
  ClassDB::bind_method(D_METHOD("send_frame", "frame"), &GodotCMIO::send_frame);
}

void GodotCMIO::_process(double delta) {
  // Called every frame
}

void GodotCMIO::start_virtual_camera() {
  if (m_running) {
    return;
  }

  // Create a CMIO assistant
  CMIOAssistant *assistant = new CMIOAssistant();

  // Create a device
  OSStatus status = CMIOObjectCreate(kCMIOObjectSystemObject, kCMIODeviceClassID, &m_device_id);
  if (status != noErr) {
    return;
  }

  // Set the device properties
  CMIOObjectSetPropertyData(m_device_id, &kCMIOObjectPropertyName, 0, nullptr, sizeof("AvatarStream Cam"), "AvatarStream Cam");
  CMIOObjectSetPropertyData(m_device_id, &kCMIODevicePropertyDeviceUID, 0, nullptr, sizeof("AvatarStreamCam"), "AvatarStreamCam");
  CMIOObjectSetPropertyData(m_device_id, &kCMIODevicePropertyModelUID, 0, nullptr, sizeof("AvatarStream Cam"), "AvatarStream Cam");
  CMIOObjectSetPropertyData(m_device_id, &kCMIODevicePropertyTransportType, 0, nullptr, sizeof(kIOAudioDeviceTransportTypeVirtual), &kIOAudioDeviceTransportTypeVirtual);
  CMIOObjectSetPropertyData(m_device_id, &kCMIODevicePropertyDeviceIsAlive, 0, nullptr, sizeof(UInt32), new UInt32(1));
  CMIOObjectSetPropertyData(m_device_id, &kCMIODevicePropertyDeviceIsRunningSomewhere, 0, nullptr, sizeof(UInt32), new UInt32(1));

  // Publish the device
  CMIOObjectsPublishedAndDied(kCMIOObjectSystemObject, 1, &m_device_id, 0, nullptr);

  // Create a stream
  CMIOObjectCreate(m_device_id, kCMIOStreamClassID, &m_stream_id);

  // Set the stream properties
  CMIOObjectSetPropertyData(m_stream_id, &kCMIOStreamPropertyDirection, 0, nullptr, sizeof(UInt32), new UInt32(0));
  CMIOObjectSetPropertyData(m_stream_id, &kCMIOStreamPropertyTerminalType, 0, nullptr, sizeof(UInt32), new UInt32(kCMIOStreamTerminalTypeVirtual));

  // Publish the stream
  CMIOObjectsPublishedAndDied(m_device_id, 1, &m_stream_id, 0, nullptr);

  // Create a queue
  CMSimpleQueueCreate(kCFAllocatorDefault, 30, &m_queue);

  m_running = true;
}

void GodotCMIO::stop_virtual_camera() {
  if (!m_running) {
    return;
  }

  // Unpublish the stream
  CMIOObjectsPublishedAndDied(m_device_id, 0, nullptr, 1, &m_stream_id);

  // Unpublish the device
  CMIOObjectsPublishedAndDied(kCMIOObjectSystemObject, 0, nullptr, 1, &m_device_id);

  // Release the queue
  if (m_queue) {
    CFRelease(m_queue);
    m_queue = nullptr;
  }

  // Release the device and stream
  CMIOObjectRemove(m_stream_id);
  CMIOObjectRemove(m_device_id);

  m_running = false;
}

void GodotCMIO::set_resolution(int width, int height) {
  m_width = width;
  m_height = height;
}

void GodotCMIO::send_frame(const PackedByteArray &frame) {
  // TODO: Implement this
}
