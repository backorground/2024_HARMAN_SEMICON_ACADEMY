#include <stdio.h>
#include <stdbool.h>

#define MAX_QUEUE_SIZE    5

typedef struct QueueType {
    int data[MAX_QUEUE_SIZE];
    int front, rear;
}QueueType;

// queue init
void init_queue(QueueType q)
{
    q->front = q->rear = -1;    // 배열이니까 -1임
}

bool is_empty(QueueType q)
{
    return (q->front == q->rear);    // queue가 비어있으면 front == rear
}

bool is_full(QueueType q)
{
    return (q->rear == MAX_QUEUE_SIZE - 1);
}

//큐가 가득차 있는지 확인 후 삽입
void enqueue(QueueType q, int data)
{
    if (is_full(q))
    {
        printf("Queue is full \n");
    }
    else
    {
        q->data[++(q->rear)] = data;
    }
}

// 비어있는지
int dequeue(QueueType q)
{
    if (is_empty(q))
    {
        printf("Queue is empty \n");
        exit(1);
    }
    else
    {
        int data = q->data[++(q->front)];
        return data;
    }
}

void print_queue(QueueType q)
{
    if (is_empty(q))
    {
        printf("Empty Queue\n");
    }
    else
    {
        printf("Queue : ");
        for (int i = 0; i < MAX_QUEUE_SIZE; i++)
        {
            if (i <= q->front || i > q->rear)
                printf("   |");
            else
                printf(" %d |", q->data[i]);
        }
        printf("\n");
    }
}

int main()
{
    QueueType queue;

    int item = 0;
    init_queue(&queue);

    enqueue(&queue, 3);
    print_queue(&queue);

    enqueue(&queue, 4);
    print_queue(&queue);

    enqueue(&queue, 5);
    print_queue(&queue);

    item = dequeue(&queue);
    print_queue(&queue);

    enqueue(&queue, 6);
    print_queue(&queue);

    item = dequeue(&queue);
    print_queue(&queue);

    return 0;
}