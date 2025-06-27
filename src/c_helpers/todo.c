#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct
{
    char **items;
    int count;
    int capacity;
} TodoList;

static TodoList todo_list;

void todo_init()
{
    todo_list.capacity = 8;
    todo_list.count = 0;
    todo_list.items = malloc(sizeof(char *) * todo_list.capacity);
}

void todo_free()
{
    for (int i = 0; i < todo_list.count; ++i)
        free(todo_list.items[i]);
    free(todo_list.items);
    todo_list.items = NULL;
    todo_list.count = todo_list.capacity = 0;
}

void todo_add(const char *text)
{
    if (todo_list.count >= todo_list.capacity)
    {
        todo_list.capacity *= 2;
        todo_list.items = realloc(todo_list.items, sizeof(char *) * todo_list.capacity);
    }
    todo_list.items[todo_list.count++] = strdup(text);
}

const char *todo_get(int index)
{
    return (index >= 0 && index < todo_list.count) ? todo_list.items[index] : NULL;
}

void todo_delete(int index)
{
    if (index >= 0 && index < todo_list.count)
    {
        free(todo_list.items[index]);
        for (int i = index; i < todo_list.count - 1; ++i)
            todo_list.items[i] = todo_list.items[i + 1];
        todo_list.count--;
    }
}

void todo_update(int index, const char *text)
{
    if (index >= 0 && index < todo_list.count)
    {
        free(todo_list.items[index]);
        todo_list.items[index] = strdup(text);
    }
}

int todo_total()
{
    return todo_list.count;
}
