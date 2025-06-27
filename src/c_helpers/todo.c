#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

typedef struct
{
    char *id; // string ID
    char *text;
} TodoItem;

typedef struct
{
    TodoItem *items;
    int count;
    int capacity;
} TodoList;

static TodoList todo_list;

char *generate_random_id(int len)
{
    static const char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    char *id = malloc(len + 1);
    if (!id)
        return NULL;

    for (int i = 0; i < len; ++i)
    {
        int key = rand() % (int)(sizeof(charset) - 1);
        id[i] = charset[key];
    }
    id[len] = '\0';
    return id;
}

int id_exists(const char *id)
{
    for (int i = 0; i < todo_list.count; ++i)
    {
        if (strcmp(todo_list.items[i].id, id) == 0)
            return 1;
    }
    return 0;
}

char *generate_unique_random_id(int len)
{
    char *id = NULL;
    int tries = 0;
    do
    {
        if (id)
            free(id);
        id = generate_random_id(len);
        tries++;
        if (tries > 100)
        {
            free(id);
            return NULL; // fail safe
        }
    } while (id_exists(id));
    return id;
}

void todo_init()
{
    todo_list.capacity = 8;
    todo_list.count = 0;
    todo_list.items = malloc(sizeof(TodoItem) * todo_list.capacity);
}

void todo_free()
{
    for (int i = 0; i < todo_list.count; ++i)
    {
        free(todo_list.items[i].text);
        free(todo_list.items[i].id);
    }
    free(todo_list.items);
    todo_list.items = NULL;
    todo_list.count = todo_list.capacity = 0;
}

int todo_add(const char *text)
{
    if (todo_list.count >= todo_list.capacity)
    {
        todo_list.capacity *= 2;
        todo_list.items = realloc(todo_list.items, sizeof(TodoItem) * todo_list.capacity);
    }

    char *id = generate_unique_random_id(8);
    if (!id)
        return 0;

    todo_list.items[todo_list.count].id = id;
    todo_list.items[todo_list.count].text = strdup(text);
    todo_list.count++;
    return 1;
}

const char *todo_get(const char *id)
{
    for (int i = 0; i < todo_list.count; ++i)
    {
        if (strcmp(todo_list.items[i].id, id) == 0)
            return todo_list.items[i].text;
    }
    return NULL;
}

int todo_delete(const char *id)
{
    for (int i = 0; i < todo_list.count; ++i)
    {
        if (strcmp(todo_list.items[i].id, id) == 0)
        {
            free(todo_list.items[i].text);
            free(todo_list.items[i].id);
            for (int j = i; j < todo_list.count - 1; ++j)
                todo_list.items[j] = todo_list.items[j + 1];
            todo_list.count--;
            return 1;
        }
    }
    return 0;
}

int todo_update(const char *id, const char *text)
{
    for (int i = 0; i < todo_list.count; ++i)
    {
        if (strcmp(todo_list.items[i].id, id) == 0)
        {
            free(todo_list.items[i].text);
            todo_list.items[i].text = strdup(text);
            return 1;
        }
    }
    return 0;
}

int todo_total()
{
    return todo_list.count;
}

TodoItem **get_todos_array()
{
    if (todo_list.count == 0)
        return NULL;

    TodoItem **arr = malloc(sizeof(TodoItem *) * (todo_list.count + 1));
    if (!arr)
        return NULL;

    for (int i = 0; i < todo_list.count; ++i)
        arr[i] = &todo_list.items[i];

    arr[todo_list.count] = NULL;
    return arr;
}