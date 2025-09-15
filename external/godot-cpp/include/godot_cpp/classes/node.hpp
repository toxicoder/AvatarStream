#ifndef NODE_HPP
#define NODE_HPP

#include <godot_cpp/classes/object.hpp>

namespace godot {

class Node : public Object {
	GDCLASS(Node, Object)

protected:
	static void _bind_methods() {}

public:
	virtual void _process(double delta);
};

}

#endif // NODE_HPP
