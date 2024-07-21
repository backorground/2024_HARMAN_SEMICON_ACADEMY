#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

#define MAX_STACK_SIZE    100

typedef int element;

typedef struct stackType
{
    element data[MAX_STACK_SIZE];
    int top;    // ���� ��� �迭(����)�� ��������� top�� -1 ���� ����
}stackType;

// ���� �ʱ�ȭ
void init_stack(stackType s)
{
    s->top = -1;
}

// ������ ����ִ��� Ȯ��
bool is_empty(stackType s)
{
    return (s->top == -1);
}

// ������ ���� �� �ִ��� Ȯ��
bool is_full(stackType s)
{
    return (s->top == MAX_STACK_SIZE);
}

// ������ ���� �� �ִ��� Ȯ���� ����
void push(stackType s, int data)
{
    if (is_full(s))
    {
        printf("Stack is Full \n");
    }
    else
    {
        s->data[++(s->top)] = data;
    }
}

// ������ ����ִ��� Ȯ���� ����
int pop(stackType s)
{
    if (is_empty(s))
    {
        printf("Stack is Empty \n");
        exit(1);                    // ���α׷� ��ü ���� �Լ� !!!
    }
    else
    {
        int data = s->data[(s->top)--];
        return data;
    }
}

//������ ��� ��� ���
void print_stack(stackType s)
{
    if (is_empty(s))
    {
        printf("Empty Stack \n");
    }
    else
    {
        printf("STACK :");
        for (int i = 0; i < s->top; i++)
        {
            printf(" %d | ", s->data[i]);
        }
        printf(" %d \n", s->data[s->top]);
    }
}



int main()
{
    stackType stack;

    init_stack(&stack);

    push(&stack, 7);
    print_stack(&stack);

    push(&stack, 8);
    print_stack(&stack);

    push(&stack, 9);
    print_stack(&stack);

    pop(&stack);
    print_stack(&stack);

    push(&stack, 10);
    print_stack(&stack);

    pop(&stack);
    print_stack(&stack);

    return 0;
}