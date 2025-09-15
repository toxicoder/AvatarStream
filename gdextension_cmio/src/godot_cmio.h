#ifndef GODOT_CMIO_H
#define GODOT_CMIO_H

#include <godot_cpp/classes/node.hpp>
#include <CoreMediaIO/CMIO.h>

namespace godot {

class GodotCMIO : public Node {
  GDCLASS(GodotCMIO, Node)

private:
  CMIOObjectID m_device_id;
  CMIOStreamID m_stream_id;
  CMSimpleQueueRef m_queue;
  int m_width;
  int m_height;
  bool m_running;

protected:
  static void _bind_methods();

public:
  GodotCMIO();
  ~GodotCMIO();

  void _process(double delta) override;

  void start_virtual_camera();
  void stop_virtual_camera();
  void set_resolution(int width, int height);
  void send_frame(const PackedByteArray &frame);
};

} // namespace godot

#endif // GODOT_CMIO_H
