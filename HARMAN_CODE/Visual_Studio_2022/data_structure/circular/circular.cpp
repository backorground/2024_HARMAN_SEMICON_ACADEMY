#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

#define MAX_CIRCULAR_SIZE    5

typedef struct Circular
{
    int data[MAX_CIRCULAR_SIZE];
    int head, tail;
}Circular;

void init_circular(Circular c)
{
    c->head = c->tail = 0;
}

bool is_empty(Circular c)
{
    return (c->head == c->tail);
}

bool is_full(Circular c)
{
    // 큐가 가득 있으면 tail+1에서 큐사이즈로 나눈값 head 같다
    return (c->head == ((c->tail + 1) % MAX_CIRCULAR_SIZE));
}

void enqueue(Circular c, int data)
{
    if (is_full(c))
    {
        printf("Circular is full\n");
    }
    else
    {
        c->tail = (c->tail + 1) % MAX_CIRCULAR_SIZE;
        c->data[c->tail] = data;
    }
}

int dequeue(Circular c)
{
    if (is_empty(c))
    {
        printf("Circular is empty \n");
        exit(1);
    }
    else
    {
        c->head = (c->head + 1) % MAX_CIRCULAR_SIZE;
        int data = c->data[c->head];
        return data;
    }
}

void print_circular(Circular c)
{
    if (is_empty(c))
    {
        printf("Empty Circular \n");
    }
    else
    {
        printf("Circular :");
        if (!is_empty(c))
        {
            int i = c->head;
            do {
                i = (i + 1) % MAX_CIRCULAR_SIZE;
                printf(" %d |", c->data[i]);
                if (i == c->tail)
                    break;
            } while (i != c->head);
            printf("\n");
        }
    }
}

int main()
{
    Circular circular;

    int item = 0;
    init_circular(&circular);

    enqueue(&circular, 3);
    print_circular(&circular);

    enqueue(&circular, 4);
    print_circular(&circular);

    enqueue(&circular, 5);
    print_circular(&circular);

    item = dequeue(&circular);
    print_circular(&circular);

    enqueue(&circular, 6);
    print_circular(&circular);

    enqueue(&circular, 7);
    print_circular(&circular);

    item = dequeue(&circular);
    print_circular(&circular);


    return 0;
}