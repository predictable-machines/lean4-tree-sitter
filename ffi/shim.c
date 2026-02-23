#include <lean/lean.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tree_sitter/api.h>

/* --- Forward declarations for language grammars --- */

extern const TSLanguage *tree_sitter_java(void);
extern const TSLanguage *tree_sitter_python(void);
extern const TSLanguage *tree_sitter_kotlin(void);

/* --- Helpers --- */

static void noop_foreach(void *data, b_lean_obj_arg arg) {
    (void)data;
    (void)arg;
}

/* --- External class: TSParser --- */

static lean_external_class *g_ts_parser_class = NULL;

static void ts_parser_finalizer(void *ptr) {
    ts_parser_delete((TSParser *)ptr);
}

static lean_external_class *get_ts_parser_class(void) {
    if (!g_ts_parser_class) {
        g_ts_parser_class =
            lean_register_external_class(&ts_parser_finalizer, &noop_foreach);
    }
    return g_ts_parser_class;
}

/* --- External class: TSTree --- */

static lean_external_class *g_ts_tree_class = NULL;

static void ts_tree_finalizer(void *ptr) {
    ts_tree_delete((TSTree *)ptr);
}

static lean_external_class *get_ts_tree_class(void) {
    if (!g_ts_tree_class) {
        g_ts_tree_class = lean_register_external_class(&ts_tree_finalizer, &noop_foreach);
    }
    return g_ts_tree_class;
}

/* --- External class: TSQuery --- */

static lean_external_class *g_ts_query_class = NULL;

static void ts_query_finalizer(void *ptr) {
    ts_query_delete((TSQuery *)ptr);
}

static lean_external_class *get_ts_query_class(void) {
    if (!g_ts_query_class) {
        g_ts_query_class =
            lean_register_external_class(&ts_query_finalizer, &noop_foreach);
    }
    return g_ts_query_class;
}

/* --- External class: TSQueryCursor (also holds the tree ref for captured nodes) --- */

typedef struct {
    TSQueryCursor *cursor;
    lean_object *tree_ref; /* set by exec, used by next_match to keep tree alive */
} BoxedTSQueryCursor;

static lean_external_class *g_ts_query_cursor_class = NULL;

static void ts_query_cursor_finalizer(void *ptr) {
    BoxedTSQueryCursor *bc = (BoxedTSQueryCursor *)ptr;
    ts_query_cursor_delete(bc->cursor);
    if (bc->tree_ref) {
        lean_dec(bc->tree_ref);
    }
    free(bc);
}

static lean_external_class *get_ts_query_cursor_class(void) {
    if (!g_ts_query_cursor_class) {
        g_ts_query_cursor_class =
            lean_register_external_class(&ts_query_cursor_finalizer, &noop_foreach);
    }
    return g_ts_query_cursor_class;
}

/* --- External class: TSLanguage (static, no finalizer) --- */

static lean_external_class *g_ts_language_class = NULL;

static void noop_finalizer(void *ptr) {
    (void)ptr;
}

static lean_external_class *get_ts_language_class(void) {
    if (!g_ts_language_class) {
        g_ts_language_class =
            lean_register_external_class(&noop_finalizer, &noop_foreach);
    }
    return g_ts_language_class;
}

/* --- External class: Boxed TSNode (heap-allocated copy of the value-type struct) --- */
/* TSNode contains an internal pointer to TSTree; we must prevent Lean from
   garbage-collecting the tree while any node referencing it is still alive. */

typedef struct {
    TSNode node;
    lean_object *tree_ref; /* prevents GC of the Lean-wrapped TSTree */
} BoxedTSNode;

static lean_external_class *g_ts_node_class = NULL;

static void ts_node_finalizer(void *ptr) {
    BoxedTSNode *boxed = (BoxedTSNode *)ptr;
    if (boxed->tree_ref) {
        lean_dec(boxed->tree_ref);
    }
    free(boxed);
}

static lean_external_class *get_ts_node_class(void) {
    if (!g_ts_node_class) {
        g_ts_node_class = lean_register_external_class(&ts_node_finalizer, &noop_foreach);
    }
    return g_ts_node_class;
}

static lean_obj_res box_ts_node(TSNode node, lean_object *tree_ref) {
    BoxedTSNode *boxed = (BoxedTSNode *)malloc(sizeof(BoxedTSNode));
    if (!boxed) {
        return lean_io_result_mk_error(
            lean_mk_io_user_error(lean_mk_string("box_ts_node: malloc failed")));
    }
    boxed->node = node;
    boxed->tree_ref = tree_ref;
    if (tree_ref) {
        lean_inc(tree_ref);
    }
    return lean_alloc_external(get_ts_node_class(), boxed);
}

static TSNode unbox_ts_node(b_lean_obj_arg obj) {
    return ((BoxedTSNode *)lean_get_external_data(obj))->node;
}

static lean_object *node_tree_ref(b_lean_obj_arg obj) {
    return ((BoxedTSNode *)lean_get_external_data(obj))->tree_ref;
}

/* ===================== */
/* Parser functions      */
/* ===================== */

LEAN_EXPORT lean_obj_res lean_ts_parser_new(lean_obj_arg world) {
    TSParser *p = ts_parser_new();
    if (!p) {
        return lean_io_result_mk_error(
            lean_mk_io_user_error(lean_mk_string("ts_parser_new failed")));
    }
    return lean_io_result_mk_ok(lean_alloc_external(get_ts_parser_class(), p));
}

LEAN_EXPORT lean_obj_res lean_ts_parser_set_language(b_lean_obj_arg parser,
                                                     b_lean_obj_arg lang,
                                                     lean_obj_arg world) {
    TSParser *p = (TSParser *)lean_get_external_data(parser);
    const TSLanguage *l = (const TSLanguage *)lean_get_external_data(lang);
    bool ok = ts_parser_set_language(p, l);
    return lean_io_result_mk_ok(lean_box(ok ? 1 : 0));
}

LEAN_EXPORT lean_obj_res lean_ts_parser_parse_string(b_lean_obj_arg parser,
                                                     b_lean_obj_arg source,
                                                     lean_obj_arg world) {
    TSParser *p = (TSParser *)lean_get_external_data(parser);
    const char *src = lean_string_cstr(source);
    size_t len = lean_string_size(source) - 1;
    TSTree *tree = ts_parser_parse_string(p, NULL, src, (uint32_t)len);
    if (!tree) {
        return lean_io_result_mk_error(
            lean_mk_io_user_error(lean_mk_string("ts_parser_parse_string failed")));
    }
    return lean_io_result_mk_ok(lean_alloc_external(get_ts_tree_class(), tree));
}

/* ===================== */
/* Language accessors    */
/* ===================== */

LEAN_EXPORT lean_obj_res lean_tree_sitter_java(lean_obj_arg world) {
    return lean_io_result_mk_ok(
        lean_alloc_external(get_ts_language_class(), (void *)tree_sitter_java()));
}

LEAN_EXPORT lean_obj_res lean_tree_sitter_python(lean_obj_arg world) {
    return lean_io_result_mk_ok(
        lean_alloc_external(get_ts_language_class(), (void *)tree_sitter_python()));
}

LEAN_EXPORT lean_obj_res lean_tree_sitter_kotlin(lean_obj_arg world) {
    return lean_io_result_mk_ok(
        lean_alloc_external(get_ts_language_class(), (void *)tree_sitter_kotlin()));
}

/* ===================== */
/* Tree functions        */
/* ===================== */

LEAN_EXPORT lean_obj_res lean_ts_tree_root_node(b_lean_obj_arg tree, lean_obj_arg world) {
    TSTree *t = (TSTree *)lean_get_external_data(tree);
    TSNode root = ts_tree_root_node(t);
    return lean_io_result_mk_ok(box_ts_node(root, (lean_object *)tree));
}

/* ===================== */
/* Node functions        */
/* ===================== */

LEAN_EXPORT lean_obj_res lean_ts_node_type(b_lean_obj_arg node, lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    const char *type_str = ts_node_type(n);
    return lean_io_result_mk_ok(lean_mk_string(type_str));
}

LEAN_EXPORT lean_obj_res lean_ts_node_child_count(b_lean_obj_arg node,
                                                  lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    uint32_t count = ts_node_child_count(n);
    return lean_io_result_mk_ok(lean_box_uint32(count));
}

LEAN_EXPORT lean_obj_res lean_ts_node_named_child_count(b_lean_obj_arg node,
                                                        lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    uint32_t count = ts_node_named_child_count(n);
    return lean_io_result_mk_ok(lean_box_uint32(count));
}

LEAN_EXPORT lean_obj_res lean_ts_node_child(b_lean_obj_arg node, uint32_t index,
                                            lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    TSNode child = ts_node_child(n, index);
    return lean_io_result_mk_ok(box_ts_node(child, node_tree_ref(node)));
}

LEAN_EXPORT lean_obj_res lean_ts_node_named_child(b_lean_obj_arg node, uint32_t index,
                                                  lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    TSNode child = ts_node_named_child(n, index);
    return lean_io_result_mk_ok(box_ts_node(child, node_tree_ref(node)));
}

LEAN_EXPORT lean_obj_res lean_ts_node_start_row(b_lean_obj_arg node, lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    TSPoint p = ts_node_start_point(n);
    return lean_io_result_mk_ok(lean_box_uint32(p.row));
}

LEAN_EXPORT lean_obj_res lean_ts_node_start_column(b_lean_obj_arg node,
                                                   lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    TSPoint p = ts_node_start_point(n);
    return lean_io_result_mk_ok(lean_box_uint32(p.column));
}

LEAN_EXPORT lean_obj_res lean_ts_node_end_row(b_lean_obj_arg node, lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    TSPoint p = ts_node_end_point(n);
    return lean_io_result_mk_ok(lean_box_uint32(p.row));
}

LEAN_EXPORT lean_obj_res lean_ts_node_end_column(b_lean_obj_arg node,
                                                 lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    TSPoint p = ts_node_end_point(n);
    return lean_io_result_mk_ok(lean_box_uint32(p.column));
}

LEAN_EXPORT lean_obj_res lean_ts_node_start_byte(b_lean_obj_arg node,
                                                 lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    uint32_t byte = ts_node_start_byte(n);
    return lean_io_result_mk_ok(lean_box_uint32(byte));
}

LEAN_EXPORT lean_obj_res lean_ts_node_end_byte(b_lean_obj_arg node, lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    uint32_t byte = ts_node_end_byte(n);
    return lean_io_result_mk_ok(lean_box_uint32(byte));
}

LEAN_EXPORT lean_obj_res lean_ts_node_string(b_lean_obj_arg node, lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    char *s = ts_node_string(n);
    lean_obj_res result = lean_mk_string(s);
    free(s);
    return lean_io_result_mk_ok(result);
}

LEAN_EXPORT lean_obj_res lean_ts_node_is_null(b_lean_obj_arg node, lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    return lean_io_result_mk_ok(lean_box(ts_node_is_null(n) ? 1 : 0));
}

LEAN_EXPORT lean_obj_res lean_ts_node_is_named(b_lean_obj_arg node, lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    return lean_io_result_mk_ok(lean_box(ts_node_is_named(n) ? 1 : 0));
}

LEAN_EXPORT lean_obj_res lean_ts_node_child_by_field_name(b_lean_obj_arg node,
                                                          b_lean_obj_arg field_name,
                                                          lean_obj_arg world) {
    TSNode n = unbox_ts_node(node);
    const char *name = lean_string_cstr(field_name);
    uint32_t len = (uint32_t)(lean_string_size(field_name) - 1);
    TSNode child = ts_node_child_by_field_name(n, name, len);
    return lean_io_result_mk_ok(box_ts_node(child, node_tree_ref(node)));
}

/* ===================== */
/* Query functions       */
/* ===================== */

LEAN_EXPORT lean_obj_res lean_ts_query_new(b_lean_obj_arg lang, b_lean_obj_arg source,
                                           lean_obj_arg world) {
    const TSLanguage *l = (const TSLanguage *)lean_get_external_data(lang);
    const char *src = lean_string_cstr(source);
    uint32_t error_offset;
    TSQueryError error_type;
    TSQuery *q = ts_query_new(l, src, (uint32_t)(lean_string_size(source) - 1),
                              &error_offset, &error_type);
    if (!q) {
        char buf[256];
        snprintf(buf, sizeof(buf), "Query error at offset %u (type %d)", error_offset,
                 (int)error_type);
        return lean_io_result_mk_error(lean_mk_io_user_error(lean_mk_string(buf)));
    }
    return lean_io_result_mk_ok(lean_alloc_external(get_ts_query_class(), q));
}

LEAN_EXPORT lean_obj_res lean_ts_query_cursor_new(lean_obj_arg world) {
    TSQueryCursor *c = ts_query_cursor_new();
    if (!c) {
        return lean_io_result_mk_error(
            lean_mk_io_user_error(lean_mk_string("ts_query_cursor_new failed")));
    }
    BoxedTSQueryCursor *bc = (BoxedTSQueryCursor *)malloc(sizeof(BoxedTSQueryCursor));
    if (!bc) {
        ts_query_cursor_delete(c);
        return lean_io_result_mk_error(
            lean_mk_io_user_error(lean_mk_string("ts_query_cursor_new: malloc failed")));
    }
    bc->cursor = c;
    bc->tree_ref = NULL;
    return lean_io_result_mk_ok(lean_alloc_external(get_ts_query_cursor_class(), bc));
}

LEAN_EXPORT lean_obj_res lean_ts_query_cursor_exec(b_lean_obj_arg cursor,
                                                   b_lean_obj_arg query,
                                                   b_lean_obj_arg node,
                                                   lean_obj_arg world) {
    BoxedTSQueryCursor *bc = (BoxedTSQueryCursor *)lean_get_external_data(cursor);
    TSQuery *q = (TSQuery *)lean_get_external_data(query);
    TSNode n = unbox_ts_node(node);
    /* Store tree reference so next_match can keep nodes alive */
    lean_object *tref = node_tree_ref(node);
    if (bc->tree_ref) {
        lean_dec(bc->tree_ref);
    }
    bc->tree_ref = tref;
    if (tref) {
        lean_inc(tref);
    }
    ts_query_cursor_exec(bc->cursor, q, n);
    return lean_io_result_mk_ok(lean_box(0));
}

LEAN_EXPORT lean_obj_res lean_ts_query_cursor_next_match(b_lean_obj_arg cursor,
                                                         lean_obj_arg world) {
    BoxedTSQueryCursor *bc = (BoxedTSQueryCursor *)lean_get_external_data(cursor);
    TSQueryMatch match;
    if (!ts_query_cursor_next_match(bc->cursor, &match)) {
        return lean_io_result_mk_ok(lean_box(0)); /* Option.none */
    }

    /* Build Array of (UInt32 × TSNode) pairs for captures */
    lean_obj_res arr = lean_mk_empty_array();
    for (uint16_t i = 0; i < match.capture_count; i++) {
        lean_obj_res pair = lean_alloc_ctor(0, 2, 0);
        lean_ctor_set(pair, 0, lean_box_uint32(match.captures[i].index));
        lean_ctor_set(pair, 1, box_ts_node(match.captures[i].node, bc->tree_ref));
        arr = lean_array_push(arr, pair);
    }

    /* Build (UInt32 × UInt32 × Array (UInt32 × TSNode)) */
    lean_obj_res inner = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(inner, 0, lean_box_uint32((uint32_t)match.pattern_index));
    lean_ctor_set(inner, 1, arr);

    lean_obj_res result = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(result, 0, lean_box_uint32(match.id));
    lean_ctor_set(result, 1, inner);

    /* Option.some result */
    lean_obj_res some = lean_alloc_ctor(1, 1, 0);
    lean_ctor_set(some, 0, result);

    return lean_io_result_mk_ok(some);
}

LEAN_EXPORT lean_obj_res lean_ts_query_capture_name(b_lean_obj_arg query, uint32_t index,
                                                    lean_obj_arg world) {
    TSQuery *q = (TSQuery *)lean_get_external_data(query);
    uint32_t length;
    const char *name = ts_query_capture_name_for_id(q, index, &length);
    if (!name) {
        return lean_io_result_mk_ok(lean_mk_string(""));
    }
    return lean_io_result_mk_ok(lean_mk_string_from_bytes(name, length));
}
