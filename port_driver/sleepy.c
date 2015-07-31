#include<unistd.h>
#include<stdio.h>

int sleep_x(int x) {
    sleep(10);
    return x+1;
}
