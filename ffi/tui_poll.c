#include <lean/lean.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <poll.h>
#endif

/* Check if stdin has data available, with a timeout in milliseconds.
   Returns Bool: true if data ready, false on timeout or error. */
LEAN_EXPORT lean_obj_res lean_poll_stdin(uint32_t timeout_ms, lean_obj_arg world) {
#ifdef _WIN32
    HANDLE h = GetStdHandle(STD_INPUT_HANDLE);
    if (h == INVALID_HANDLE_VALUE) {
        return lean_io_result_mk_ok(lean_box(0));
    }
    DWORD result = WaitForSingleObject(h, (DWORD)timeout_ms);
    uint8_t has_data = (result == WAIT_OBJECT_0) ? 1 : 0;
#else
    struct pollfd fds[1];
    fds[0].fd = 0;
    fds[0].events = POLLIN;

    int ret = poll(fds, 1, (int)timeout_ms);
    uint8_t has_data = (ret > 0 && (fds[0].revents & POLLIN)) ? 1 : 0;
#endif
    return lean_io_result_mk_ok(lean_box(has_data));
}
