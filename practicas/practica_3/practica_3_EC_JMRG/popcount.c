// Autor: Juan Manuel Rodriguez Gomez
// Asignatura: Estructura de Computadores
// Curso 2020-2021

// Práctica 3

// gcc popcount.c -o popcount -Og -g -D TEST=1

/*
=== TESTS === ____________________________________
for i in 0 g 1 2; do
	printf "__OPTIM%1c__%48s\n" $i "" | tr " " "="
	for j in $(seq 1 4); do
		printf "__TEST%02d__%48s\n" $j "" | tr " " "-"
		gcc popcount.c -o popcount -O$i -D TEST=$j -g
		./popcount
	done
	rm popcount
done

=== CRONOS === ____________________________________
for i in 0 g 1 2; do
	printf "__OPTIM%1c__%48s\n" $i "" | tr " " "="
	gcc popcount.c -o popcount -O$i -D TEST=0
	for j in $(seq 0 10); do
		echo $j; ./popcount
	done | pr -11 -l 22 -w 80
	rm popcount
done
___________________________________________________
*/

#include <stdio.h>	    // para printf()
#include <stdlib.h>	    // para exit()
#include <sys/time.h>	    // para gettimeofday(), struct timeval
#include <math.h>

#define WSIZE 8*sizeof(int)

int resultado=0;

#ifndef TEST
	#define TEST 5
#endif

#if TEST==1
    #define SIZE 4
    unsigned lista[SIZE]={0x80000000, 0x00400000, 0x00000200, 0x00000001};
    #define RESULT 4

#elif TEST==2
    #define SIZE 8
    unsigned lista[SIZE]={0x7fffffff, 0xffbfffff, 0xfffffdff, 0xfffffffe,
                          0x01000023, 0x00456700, 0x8900ab00, 0x00cd00ef};
    #define RESULT 156

#elif TEST==3
    #define SIZE 8
    unsigned lista[SIZE]={0x0       , 0x01020408, 0x35906a0c, 0x70b0d0e0,
                          0xffffffff, 0x12345678, 0x9abcdef0, 0xdeadbeef};
    #define RESULT 116

#elif TEST==4 || TEST==0
    #define NBITS 20
    #define SIZE (1<<NBITS)
    unsigned lista[SIZE];
    #define RESULT ( ? * ( ? << ?-1 ) )

#else
    #error "Definir TEST entre 0..4"
#endif

// Primera version
int popcount1(unsigned* array, size_t len) {

    size_t i, j;
    int result = 0;

    for(i = 0; i < len; i++)
	for (j = 0; j < WSIZE; j++) {
		unsigned mask = 0x1 << j;
		result += (array[i] & mask) != 0;
	}

    return result;
}


// Segunda version
int popcount2(unsigned* array, size_t len) {
    
    size_t i;
    int result = 0;

    for(i = 0; i < len; i++) {

	unsigned x = array[i];
	while(x) {
		result += x & 0x1;
		x >>= 1;
	}
    }
  
    return result;
}

// Tercera version
int popcount3(unsigned* array, size_t len) {

    size_t i;
    int result = 0;

    for(i = 0; i < len; i++) {

	unsigned x = array[i];
	asm("\n                        "
            "ini3:		   \n\t"
            "    shr %[x]          \n\t"
	    "    adc $0, %[r]      \n\t"
	    "    test %[x], %[x]   \n\t"
            "	 jne ini3          \n\t"

            : [r] "+r" (result)
            : [x] "r"  (x) 
	);
    }
  
    return result;
}

// Cuarta version
int popcount4(unsigned* array, size_t len){

    size_t i;
    int result = 0;

    for(i = 0;i<len; i++) {

    	unsigned x=array[i];
	asm("\n                        "
            "clc		   \n\t"
	    "ini4:		   \n\t"	
	    "    adc $0, %[r]	   \n\t"
	    "    shr %[x]	   \n\t"
	    "    jnz ini4	   \n\t"
	    "    adc $0, %[r]	   \n\t"

	    : [r] "+r" (result)
	    : [x] "r" (x)	    
        );
    }

    return result;
}

// Quinta version
int popcount5(unsigned* array, size_t len) {

    size_t i, j;
    int result = 0;

    for(i = 0; i < len; i++) {
        
        int val = 0;
	unsigned x = array[i];

	for(j = 0; j < 8; j++) {				
	    val += x & 0x01010101; 				
	    x >>= 1;
	}

	val += (val >> 16);							
	val += (val >> 8);
        result += (val & 0xff);								
    }

    return result;					
}

// Sexta version
int popcount6(unsigned* array, size_t len) {

    size_t i;
    int result = 0;

    for(i = 0; i < len; i++) {

	unsigned x = array[i];

        x = (x & 0x55555555) + ((x >> 1)  & 0x55555555);
        x = (x & 0x33333333) + ((x >> 2)  & 0x33333333);
        x = (x & 0x0f0f0f0f) + ((x >> 4)  & 0x0f0f0f0f);
        x = (x & 0x00ff00ff) + ((x >> 8)  & 0x00ff00ff);
        x = (x & 0x0000ffff) + ((x >> 16) & 0x0000ffff);

        result += x;
    }

    return result;
}

// Septima version
int popcount7(unsigned* array, size_t len) {

    size_t  i;
    int result = 0;

    for(i = 0; i < len; i+=2) {

	unsigned x1 = *(unsigned*) &array[i];
	unsigned x2 = *(unsigned*) &array[i+1];

        x1 = (x1 & 0x55555555) + ((x1 >> 1)  & 0x55555555);
        x1 = (x1 & 0x33333333) + ((x1 >> 2)  & 0x33333333);
        x1 = (x1 & 0x0f0f0f0f) + ((x1 >> 4)  & 0x0f0f0f0f);
        x1 = (x1 & 0x00ff00ff) + ((x1 >> 8)  & 0x00ff00ff);
        x1 = (x1 & 0x0000ffff) + ((x1 >> 16) & 0x0000ffff);

        x2 = (x2 & 0x55555555) + ((x2 >> 1)  & 0x55555555);
        x2 = (x2 & 0x33333333) + ((x2 >> 2)  & 0x33333333);
        x2 = (x2 & 0x0f0f0f0f) + ((x2 >> 4)  & 0x0f0f0f0f);
        x2 = (x2 & 0x00ff00ff) + ((x2 >> 8)  & 0x00ff00ff);
        x2 = (x2 & 0x0000ffff) + ((x2 >> 16) & 0x0000ffff);

        result += x1 + x2;
    }

    return result;
}

// Octava version
int popcount8(unsigned* array, size_t len) {

    size_t i;
    int val, result = 0;
    int SSE_mask[] = {0x0f0f0f0f, 0x0f0f0f0f, 0x0f0f0f0f, 0x0f0f0f0f};
    int SSE_LUTb[] = {0x02010100, 0x03020201, 0x03020201, 0x04030302};
                     // 3 2 1 0      7 6 5 4     1110 9 8    15141312

    if (len & 0x3) printf("leyendo 128b pero len no múltiplo de 4\n");
    for (i=0; i<len; i+=4) {
    	asm("movdqu    %[x]  , %%xmm0 \n\t"
            "movdqa   %%xmm0 , %%xmm1 \n\t" // x: two copies xmm0-1
            "movdqu    %[m]  , %%xmm6 \n\t" // mask: xmm6
            "psrlw     $4    , %%xmm1 \n\t"
            "pand     %%xmm6 , %%xmm0 \n\t" //; xmm0 – lower nibbles
            "pand     %%xmm6 , %%xmm1 \n\t" //; xmm1 – higher nibbles

            "movdqu    %[l]  , %%xmm2 \n\t" //; since instruction pshufb modifies LUT
            "movdqa   %%xmm2 , %%xmm3 \n\t" //; we need 2 copies
            "pshufb   %%xmm0 , %%xmm2 \n\t" //; xmm2 = vector of popcount lower nibbles
            "pshufb   %%xmm1 , %%xmm3 \n\t" //; xmm3 = vector of popcount upper nibbles

	    "paddb    %%xmm2 , %%xmm3 \n\t" //; xmm3 - vector of popcount for bytes
            "pxor     %%xmm0 , %%xmm0 \n\t" //; xmm0 = 0,0,0,0
            "psadbw   %%xmm0 , %%xmm3 \n\t" //; xmm3 = [pcnt bytes0..7|pcnt bytes8..15]
	    "movhlps  %%xmm3 , %%xmm0 \n\t" //; xmm0 = [      0       |pcnt bytes0..7 ]
            "paddd    %%xmm3 , %%xmm0 \n\t" //; xmm0 = [  not needed  |pcnt bytes0..15]

            "movd     %%xmm0 , %[val]     "
            : [val] "=r" (val)
            : [x]    "m" (array[i]),
              [m]    "m" (SSE_mask[0]),
              [l]    "m" (SSE_LUTb[0])
    	);

    	result += val;
    }

    return result;
}

// Novena version
int popcount9(unsigned* array, size_t len) {

    size_t i;
    unsigned x;
    int val, result = 0;

    for(i = 0; i < len; i++) {
    	
    	x = array[i];
        asm("popcnt %[x], %[val]"

            : [val] "=r" (val)
	    :   [x]  "r" (x)

    	);

        result += val;
    }

    return result;
}

// Decima version
int popcount10(unsigned* array, size_t len){
    size_t i;     
    unsigned long x1,x2;     
    long val; 
    int result=0;     

    if (len & 0x3) printf( "leyendo 128b pero len no múltiplo de 4\n");     

    for (i=0; i<len; i+=4){       
    	x1 = *(unsigned long*) &array[ i ];       
	x2 = *(unsigned long*) &array[i+2];     
  
	asm("popcnt %[x1], %[val] \n\t"
	    "popcnt %[x2], %%r10  \n\t"    
	    "add    %%r10, %[val] \n\t" 
	
            : [val] "=&r"   (val) 
	    :  [x1]   "r" (x1),    
	       [x2]   "r" (x2)
	);       
	
	result += val;     
    }    

    return result; 
}

// Funcion para calcular el tiempo de ejecucion 
// de las funciones popcount en microsegundos
void crono(int (*func)(), char* msg) {

    struct timeval tv1,tv2;	// gettimeofday() secs-usecs
    long           tv_usecs;	// y sus cuentas

    gettimeofday(&tv1,NULL);
    resultado = func(lista, SIZE);
    gettimeofday(&tv2,NULL);

    tv_usecs=(tv2.tv_sec -tv1.tv_sec )*1E6+
             (tv2.tv_usec-tv1.tv_usec);

    #if TEST==0
    	printf( "%ld" "\n", tv_usecs);
    #else
    	printf("resultado = %d\t", resultado);
    	printf("%s:%9ld us\n", msg, tv_usecs);
    #endif
}

// Funcion principal
int main() {

    #if TEST==0 || TEST==4
    	size_t i;
    	for(i=0; i<SIZE; i++)
            lista[i]=i;
    #endif

    crono(popcount1 , "popcount1 (lenguaje C -       for)");
    crono(popcount2 , "popcount2 (lenguaje C -     while)");
    crono(popcount3 , "popcount3 (leng.ASM-body while 4i)");
    crono(popcount4 , "popcount4 (leng.ASM-body while 3i)");
    crono(popcount5 , "popcount5 (CS:APP2e 3.49-group 8b)");
    crono(popcount6 , "popcount6 (Wikipedia- naive - 32b)");
    crono(popcount7 , "popcount7 (Wikipedia- naive -128b)");
    crono(popcount8 , "popcount8 (asm SSE3 - pshufb 128b)");
    crono(popcount9 , "popcount9 (asm SSE4- popcount 32b)");
    crono(popcount10, "popcount10(asm SSE4- popcount128b)");

    #if TEST != 0
    	printf("calculado = %d\n", RESULT);
    #endif

    exit(0);
}
