#include <stdio.h>
int main()
{
    int array[] = {1, 2, 3, 4, 5, 6};
    int i, n;
    int sum = 0;
    for (i = 0; i < sizeof(array) / sizeof(array[0]); i++)
    {
        sum = sum + array[i];
    }
    printf("This is sum of N natural numbers %d\n", sum);

    printf("Enter how many numbers you want ::");
    scanf("%d", &n);
    // for (i = 0; i < n; i++)
    // {
    //     printf("Enter %d st element", i + 1);
    //     scanf("%d", &array[i]);
    //     if (array[i] == 0)
    //     {
    //         printf("Dont accept zeros");
    //         break;
    //     }
    // }

    int sum1 = 0;

    for (i = 0; i < n; i++)
    {
        sum1 = sum1 + (i + 1);
    }

    printf("This is sum of N natural numbers %d\n", sum1);
}