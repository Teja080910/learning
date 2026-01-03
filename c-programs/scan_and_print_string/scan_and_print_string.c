#include <stdio.h>
#include <string.h>
int main()
{
    int i;
    int n = 4;
    // char string[n + 1];
    char string[n];
    char string1[n + 1];
    for (i = 0; i < n; i++)
    {
        printf("Enter for %d element :", i + 1);
        scanf(" %c", &string[i]);
    };

    for (i = 0; i < n; i++)
    {
        printf("%c", string[i]);
    };
    printf("\n");
    // string[n] = '\0';

    // printf("\nThis my string %s \n", string);
    printf("Length of string %ld \n", strlen(string));
    strcpy(string1, string);
    string1[n] = '\0';
    printf("This is copy string :: %s\n", string1);
    printf("These two strings are same :: %d\n", strcmp(string, string1));
    printf("Concat of two strings :: %s\n", strcat(string, string1));
    return 0;
}