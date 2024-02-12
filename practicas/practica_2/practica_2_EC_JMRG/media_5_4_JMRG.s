# Sección de datos

.section .data

	#ifndef TEST
	#define TEST 20
	#endif

	# Doble macro: lista definida por una linea0 y 3 lineas normales
	# En la mayoría de ejemplos linea0 = linea => lista tiene 4 lineas normales

		.macro linea

	#if   TEST==1
			.int 1, 2, 1, 2
	#elif TEST==2 			
			.int -1,-2,-1,-2
	#elif TEST==3 						
			.int 0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff
	#elif TEST==4 						
			.int 0x80000000, 0x80000000, 0x80000000, 0x80000000
	#elif TEST==5 						
			.int 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
	#elif TEST==6 						
			.int 2000000000, 2000000000, 2000000000, 2000000000
	#elif TEST==7 						
			.int 3000000000, 3000000000, 3000000000, 3000000000
	#elif TEST==8 						
			.int -2000000000, -2000000000, -2000000000, -2000000000
	#elif TEST==9 						
			.int -3000000000, -3000000000, -3000000000, -3000000000
	#elif TEST>=10 && TEST<=14
			.int 1, 1, 1, 1							# linea0 + 3lineas, casi todo a 1
	#elif TEST>=15 && TEST<=19
			.int -1,-1,-1,-1 						# linea0 + 3lineas, casi todo a -1
	#else
		.error "Definir TEST entre 1..19"
	#endif
		.endm



	# En la mayoría de ejemplos linea0 = linea => lista tiene 4 lineas normales

		.macro linea0 

	#if TEST>=1 && TEST<=9
			linea 
	#elif TEST==10 			
			.int 0, 2, 1, 1
	#elif TEST==11
			.int 1, 2, 1, 1
	#elif TEST==12
			.int 8, 2, 1, 1
	#elif TEST==13
			.int 15, 2, 1, 1
	#elif TEST==14
			.int 16, 2, 1, 1
	#elif TEST==15 			
			.int 0,-2,-1,-1
	#elif TEST==16 						
			.int -1,-2,-1,-1
	#elif TEST==17 						
			.int -8,-2,-1,-1
	#elif TEST==18 						
			.int -15,-2,-1,-1
	#elif TEST==19 				
			.int -16,-2,-1,-1
	#else
			.error "Definir TEST entre 1..19"
	#endif
		.endm

	# En la mayoría de ejemplos linea0 = linea => lista tiene 4 lineas normales

	lista: 	linea0									# Lista de números
			.irpc i,123
			      linea
			.endr

	longlista: 	.int (.-lista)/4  						# Longitud de la lista
	media: 		.int 0								# Media
	resto:		.int 0								# Resto

	formato: 	.ascii "media \t = %11d \t resto \t = %11d \n"			# Formato de la salida en la terminal del resultado
			.asciz "\t = 0x %08x \t \t = 0x %08x\n"

# Sección de código

.section .text

	main: .global main

		call trabajar
		call imprimir
		call acabar

	trabajar:

		mov  $lista, %rbx
		mov  longlista, %ecx
		call suma
		mov  $16, %r8d
		idiv %r8d				# Realizamos la división
		mov  %eax, media			# Cociente de la división
		mov  %edx, resto			# Resto de la división		

	imprimir: 		# requiere libC

		mov  $formato, %rdi
		mov  media, %esi
		mov  resto, %edx
		mov  $0, %eax
		call printf 				# == printf(formato, res, res);	

	acabar: 		# requiere libC

		mov  media, %edi
		call exit
		int  $0x80 

	# EDX:EAX

	suma: 

		mov %ecx,%esi  				# Guardamos la dirección de longlista en %ebp 
		mov %rbx,%rdi  				# Dirección donde comienza la lista de enteros
		mov $0, %ebx   				# Registro de la suma (lo inicializamos a 0)
		mov $0, %ecx				# Registro de la extensión de signo (lo inicializamos a 0).
							# Usamos estos 2 registros en lugar de %eax y %edx porque cdq utiliza %edx y %eax
		mov $0, %rdx				# Registro del acarreo (lo inicializamos a 0)
		mov $0, %ebp				# Registro del índice iterador del bucle (el bucle acaba cuando %ebp = %esi)

	bucle:

		mov (%rdi,%rbp,4),%eax    		# %rdi es la dirección donde comienza la lista de enteros
		cdq 					# Extensión de signo de edx:eax
		add %eax,%ebx
		adc %edx,%ecx
		inc %ebp
		
		cmp %ebp,%esi				# Comparamos si el índice actual de la lista es igual a la longitud de la lista
		jne bucle				# Si no es igual, saltamos al bucle de nuevo
		
		mov %ebx, %eax				# Una vez acabado el bucle, retornamos %eax y %edx
		mov %ecx, %edx
		ret
