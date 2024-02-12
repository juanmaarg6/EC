# Sección de datos

.section .data

	#ifndef TEST
	#define TEST 9
	#endif
		.macro linea
	
	#if     TEST==1
			.int 1,1,1,1
	#elif   TEST==2
			.int 0x0fffffff, 0x0fffffff, 0x0fffffff, 0x0fffffff
	#elif   TEST==3
			.int 0x10000000, 0x10000000, 0x10000000, 0x10000000
	#elif   TEST==4
			.int 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
	#elif   TEST==5
			.int -1, -1, -1, -1
	#elif   TEST==6
			.int 200000000, 200000000, 200000000, 200000000
	#elif   TEST==7
			.int 300000000, 300000000, 300000000, 300000000
	#elif   TEST==8
			.int 5000000000, 5000000000, 5000000000, 5000000000
	#else 
		.error "DEFINIR TEST ENTRE 1...8"
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

	main: .global  main

		call trabajar				# Suma sin signo de los números de la lista
		call imprimir				# printf() de libC
		call acabar				# exit() de libC
		ret

	trabajar:

		mov  $lista, %rbx 			# Movemos el primer valor de lista al registro %rbx
		mov  longlista, %rcx 			# Movemos la longitud de la lista al registro %rcx
		call suma				# == suma(&lista, longlista);
		mov  %eax, resultado
		mov  %edx, resultado+4 

	imprimir:		# requiere libC

		mov   $formato, %rdi
		mov   resultado, %rsi
		mov   resultado, %rdx
		mov   resultado, %ecx
		mov   resultado, %r8d
		mov   $0, %eax				
		call  printf				# == printf(formato, res, res);

	acabar:			# requiere libC

		movl $1, %eax
		xor  %ebx, %ebx
		int  $0x80 				# En caso de que %eax valga 1, terminamos la ejecución y retornamos %ebx
	
	# EDX:EAX 

	suma:

		mov  $0, %eax 				# Registro de la suma (lo inicializamos a 0)
		mov  $0, %edx 				# Registro del acarreo (lo inicializamos a 0)
		mov  $0, %rsi 				# Registro del índice iterador del bucle (lo inicializamos a 0)

	bucle:
	
		add (%rbx,%rsi,4), %eax 		# Acumulamos las sumas de cada elemento de lista
		adc $0, %edx 				# Sumamos el acarreo
		inc %rsi 				# Incrementamos el índice del bucle
		cmp %rsi, %rcx 				# Comparamos si el índice actual de la lista es igual a la longitud de la lista
		jne bucle 				# Si no es igual, saltamos al bucle de nuevo

		ret

