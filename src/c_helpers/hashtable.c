#include <string.h>
#include <stdint.h>

#define TABLE_SIZE 32

typedef struct
{
    char method[8];         // "GET"
    char path[32];          // "/status"
    void (*func_ptr)(void); // handler
} RouteEntry;

RouteEntry table[TABLE_SIZE];

extern void get_todos_count(void);  // Declare external ASM handler
extern void get_todos(void);        // Declare external ASM handler
extern void post_todo_create(void); // Declare external ASM handler
extern void post_todo_update(void); // Declare external ASM handler
extern void post_todo_delete(void); // Declare external ASM handler

unsigned int hash(const char *method, const char *path)
{
    unsigned int sum = 0;
    while (*method)
        sum += *method++;
    while (*path)
        sum += *path++;
    return sum % TABLE_SIZE;
}

void insert(const char *method, const char *path, void (*func_ptr)(void))
{
    unsigned int index = hash(method, path);
    while (table[index].func_ptr)
    {
        index = (index + 1) % TABLE_SIZE;
    }
    strncpy(table[index].method, method, sizeof(table[index].method) - 1);
    strncpy(table[index].path, path, sizeof(table[index].path) - 1);
    table[index].func_ptr = func_ptr;
}

void *lookup(const char *method, const char *path)
{
    unsigned int index = hash(method, path);
    for (int i = 0; i < TABLE_SIZE; i++)
    {
        if (table[index].func_ptr &&
            strcmp(table[index].method, method) == 0 &&
            strcmp(table[index].path, path) == 0)
        {
            return (void *)table[index].func_ptr;
        }
        index = (index + 1) % TABLE_SIZE;
    }
    return NULL;
}

void register_routes()
{
    insert("GET", "/todos/count", get_todos_count);
    insert("GET", "/todos", get_todos);
    insert("POST", "/todos/create", post_todo_create);
    insert("POST", "/todos/update", post_todo_update);
    insert("POST", "/todos/delete", post_todo_delete);
}