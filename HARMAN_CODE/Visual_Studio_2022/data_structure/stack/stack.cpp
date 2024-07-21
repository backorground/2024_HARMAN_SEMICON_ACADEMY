#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

#define MAX_STACK_SIZE    100

typedef int element;

typedef struct stackType
{
    element data[MAX_STACK_SIZE];
    int top;    // 스택 상단 배열(스택)이 비어있으면 top는 -1 부터 시작
}stackType;

// 스택 초기화
void init_stack(stackType s)
{
    s->top = -1;
}

// 스택이 비어있는지 확인
bool is_empty(stackType s)
{
    return (s->top == -1);
}

// 스택이 가득 차 있는지 확인
bool is_full(stackType s)
{
    return (s->top == MAX_STACK_SIZE);
}

// 스택이 가득 차 있는지 확인후 삽입
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

// 스택이 비어있는지 확인후 삭제
int pop(stackType s)
{
    if (is_empty(s))
    {
        printf("Stack is Empty \n");
        exit(1);                    // 프로그램 전체 종료 함수 !!!
    }
    else
    {
        int data = s->data[(s->top)--];
        return data;
    }
}

//스택의 모든 요소 출력
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