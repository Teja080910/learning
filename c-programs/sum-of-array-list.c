#include <stdio.h>
int main()
{
    int array[] = {1, 2, 3, 4, 5, 6};
    int *p = array;
    int sum = 0;
    int i;
    for (i = 0; i < sizeof(array) / sizeof(array[0]); i++)
    {
        printf("%d\n", *p);
        sum = sum + *p;
        p++;
    }
    printf("Sum is :: %d\n", sum);
}