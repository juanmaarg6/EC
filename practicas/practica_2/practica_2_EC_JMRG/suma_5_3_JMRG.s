# Sección de datos

.section .data

	#ifndef TEST
	#define TEST 20
	#endif
		.macro linea
	
	#if     TEST==1
			.int -1, -1, -1, -1
	#elif   TEST==2
			.int 0x04000000, 0x04000000, 0x04000000, 0x04000000
	#elif   TEST==3
			.int 0x08000000, 0x08000000, 0x08000000, 0x08000000
	#elif   TEST==4
			.int 0x10000000, 0x10000000, 0x10000000, 0x10000000
	#elif   TEST==5
			.int 0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff
	#elif   TEST==6
			.int 0x80000000, 0x80000000, 0x80000000, 0x80000000
	#elif   TEST==7
			.int 0xf0000000, 0xf0000000, 0xf0000000, 0xf0000000
	#elif   TEST==8
			.int 0xf8000000, 0xf8000000, 0xf8000000, 0xf8000000
	#elif   TEST==9
			.int 0xf7ffffff, 0xf7ffffff, 0xf7ffffff, 0xf7ffffff
	#elif   TEST==10
			.int 100000000, 100000000, 100000000, 100000000
	#elif   TEST==11
			.int 200000000, 200000000, 200000000, 200000000
	#elif   TEST==12
			.int 300000000, 300000000, 300000000, 300000000
	#elif   TEST==13
			.int 2000000000, 2000000000, 2000000000, 2000000000
	#elif   TEST==14
			.int 3000000000, 3000000000, 3000000000, 3000000000
	#elif   TEST==15
			.int -100000000, -100000000, -100000000, -100000000
	#elif   TEST==16
			.int -200000000, -200000000, -200000000, -200000000
	#elif   TEST==17
			.int -300000000, -300000000, -300000000, -300000000
	#elif   TEST==18
			.int -2000000000, -2000000000, -2000000000, -2000000000
	#elif   TEST==19
			.int -3000000000, -3000000000, -3000000000, -3000000000
	#else 
		.error "DEFINIR TEST ENTRE 1...19"
	#endif
		.endm

	lista: 		.irpc i,1234						# Lista de números
		      	       linea
	       		.endr

	longlista: 	.int (.-lista)/4 					# Longitud de la lista
	resultado:	.quad 0 						# Resultado de la suma

	formato:   	.ascii "resultado \t =    %18ld (sgn)\n"		# Formato de la salida en la terminal del resultado
		   		.ascii          "\t\t = 0x%18lx (hex)\n"
		   		.asciz          "\t\t = 0x %08x %08x \n"

# Sección de código

.section .text

	main: .global main

		call  trabajar				# Suma con signo de los números de la lista
		call  imprimir				# printf() de libC
		call  acabar				# exit() de libC
		ret

	trabajar:

		mov   $lista, %rdi 			# Movemos el primer valor de lista al registro %rbx
		mov   longlista, %rsi 			# Movemos la longitud de la lista al registro %rcx
		call  suma				# == suma(&lista, longlista);
		mov   %eax, resultado
		mov   %edx, resultado+4 

	imprimir:   		# requiere libC

		mov   $formato, %rdi
		mov   resultado, %rsi
		mov   %edx, %ecx 			# Cambiamos de posición para que no se pierda el valor de %edx
		mov   resultado, %rdx
		movsx %eax, %r8
		xor   %eax, %eax
		call  printf				# == printf(formato, res, res);	
		
	acabar:			# requiere libC

		movl  $1, %eax
		xor   %ebx, %ebx
		int   $0x80 				# En caso de que %eax valga 1, terminamos la ejecución y retornamos %ebx

	# EDX:EAX

	suma:

		mov $0, %ebx 				# Registro de la suma (lo inicializamos a 0)
		mov $0, %ecx 				# Registro de la extensión de signo (lo inicializamos a 0) 
		mov $0, %ebp 				# Registro del índice iterador del bucle (lo inicializamos a 0)

	bucle:

	    	mov (%rdi,%rbp,4), %eax 		# eax = lista[i]
	    	cdq 					# Extensión de signo de edx:eax
		
	    	add %eax, %ebx
	    	adc %edx, %ecx

	    	inc %ebp 				# Incrementamos el índice del bucle
	    	cmp %ebp, %esi 				# Comparamos si el índice actual de la lista es igual a la longitud de la lista
	    	jne bucle 				# Si no es igual, saltamos al bucle de nuevo
	
	    	mov %ecx, %edx 				# Una vez acabado el bucle, retornamos %eax y %edx
	    	mov %ebx, %eax
	    
	    	ret
