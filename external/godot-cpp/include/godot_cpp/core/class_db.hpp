#ifndef CLASS_DB_HPP
#define CLASS_DB_HPP

#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include <godot_cpp/classes/object.hpp>

namespace godot {

class ClassDB {
public:
	template <class T>
	static void register_class() {}

	template <class T, class... Args>
	static void bind_method(const char *p_name, Args... args) {}
};

}

#endif // CLASS_DB_HPP
