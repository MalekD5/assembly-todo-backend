#include <string.h>

#define MAX_TODOS 64
#define MAX_LEN 128

char todo_list[MAX_TODOS][MAX_LEN];
int todo_count = 0;

void todo_add(const char *text)
{
    if (todo_count < MAX_TODOS)
    {
        strncpy(todo_list[todo_count], text, MAX_LEN - 1);
        todo_list[todo_count][MAX_LEN - 1] = 0; // null-terminate
        todo_count++;
    }
}

const char *todo_get(int index)
{
    if (index >= 0 && index < todo_count)
    {
        return todo_list[index];
    }
    return 0;
}

int todo_total()
{
    return todo_count;
}
