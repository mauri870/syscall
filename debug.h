#ifndef DEBUG_H
#define DEBUG_H

#ifdef DEBUG
# define DEBUG_PRINT(fmt, ...) \
	do { fprintf(stderr, "%s:%d:%s(): " fmt, __FILE__, \
			__LINE__, __func__, __VA_ARGS__); } while (0)
#else
# define DEBUG_PRINT(fmt, ...) do {} while (0)
#endif

#endif
