// gcc -Og bomba_JMRG_2020.c -o bomba_JMRG_2020 -no-pie -fno-guess-branch-probability

#include <stdio.h>	// para printf(), fgets(), scanf()
#include <stdlib.h>	// para exit()
#include <string.h>	// para strncmp()
#include <sys/time.h>	// para gettimeofday(), struct timeval

#define SIZE 100
#define TLIM 60

char correct_password[] = "dgiimydgiiade\n";
int correct_pin = 1096;

void boom(void) {
    printf("\n");
    printf("**************************\n");
    printf("********** BOOM **********\n");
    printf("**************************\n");
    exit(-1);
}

void defused(void) {
    printf("\n");
    printf("·························\n");
    printf("··· BOMBA DESACTIVADA ···\n");
    printf("·························\n");
    exit(0);
}

void message() {
    printf("===============================================\n");
    printf("BOMBA REALIZADA POR JUAN MANUEL RODRIGUEZ GOMEZ\n");
    printf("===============================================\n\n");
}

void question1(void) {
    printf("\n\nIntroduzca la contraseña: \n");
}

void question2(void) {
    printf("\nIntroduzca el pin: \n");
}

void check_password(char p[]) {
    if( strncmp(p, correct_password, sizeof(correct_password)) )
        boom();
}

void check_pin(int p) {
    if(p != correct_pin)
        boom();
}

int main() {

    char pass[SIZE];
    int pin, n;

    struct timeval tv1,tv2; // gettimeofday() secs-usecs

    message();
    gettimeofday(&tv1, NULL);

    question1();
    while( fgets(pass, SIZE, stdin) == NULL );

    check_password(pass);
 
    gettimeofday(&tv2,NULL);

    if( (tv2.tv_sec - tv1.tv_sec) > TLIM )
        boom();
 
    question2();
    do {
        if( (n = scanf("%i",&pin) ) == 0 )
	    scanf("%*s")    ==1;        
    }while( n != 1 );

    check_pin(pin);
 
    gettimeofday(&tv1,NULL);

    if( (tv1.tv_sec - tv2.tv_sec) > TLIM )
        boom();
 
    defused();
}
