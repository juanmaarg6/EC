# Practica 4: Explicación de la bomba

# CONTRASEÑA: dgiimydgiiade
# 	 PIN: 1096

# MODIFICADA: desactivada
#	 PIN: 1234

# Describimos el proceso lógico seguido para:
# 1) Descubrir las claves
# 2) Cambiar las claves 

# Pensado para ejecutar mediante "source bomba_JMRG_2020.gdb"
# o desde la línea de comandos con gdb -q -x bomba_JMRG_2020.gdb

# Funciona sobre la bomba original, para recompilarla
# usar la orden gcc en la primera línea de bomba_JMRG_2020.c
# gcc -Og bomba_JMRG_2020.c -o bomba_JMRG_2020 -no-pie -fno-guess-branch-probability

########################################################
###############   DESCUBRIR LAS CLAVES   ###############
########################################################

### Cargar el programa
    file bomba_JMRG_2020

### Útil para la sesion interactiva, no para source/gdb -q -x
#   layout asm
#   layout regs

### Establecemos un breakpoint en la función main() y
### arrancamos el programa, añadiendo una automatización
### para el momento en el que nos pidan teclear la contraseña 
### y el pin
    br main
    run  < <(echo -e hola\\n123\\n)

### Hacemos ni hasta justo después de introducir la contraseña  
    ni
    ni
    ni
    ni
    ni
    ni
### Tras este último ni se mostraría el mensaje resultante 
### de la llamada a la función message()
    ni
    ni
    ni
    ni
### Tras este último ni se mostraría el mensaje para introducir 
### la contraseña ( resultado de la llamada a la función question1() )
    ni
    ni
    ni
    ni
### Tras este último ni se nos pediría introducir la contraseña
### Nótese que junto a la orden run ya automatizamos el proceso
### de teclear "hola", por lo que no tendremos que teclear nada

### Establecemos un breakpoint en la función check_password()
### y avanzamos hasta la llamada de dicha función
#   0x400862 <main+47>      callq  0x4007d9 <question1>                                             
#   0x400867 <main+52>      mov    0x200812(%rip),%rdx   # 0x601080 <stdin@@GLIBC_2.2.5>       
#   0x40086e <main+59>      mov    $0x64,%esi,%rdi                                                  
#   0x400873 <main+64>      lea    0x30(%rsp),%rdi   fday@plt>                                      
#   0x400878 <main+69>      callq  0x400610 <fgets@plt>                                             
#   0x40087d <main+74>      test   %rax,%rax                                                        
#   0x400880 <main+77>      je     0x400867 <main+52>                                               
#   0x400882 <main+79>      lea    0x30(%rsp),%rdi 
#   0x400887 <main+84>      callq  0x4007ff <check_password> 
    br check_password
    cont

### Nos encontramos en la función check_password()
#   0x4007ff <check_password>       sub    $0x8,%rsp                                                
#   0x400803 <check_password+4>     mov    $0xf,%edx                                                
#   0x400808 <check_password+9>     mov    $0x601070,%esi                                           
#   0x40080d <check_password+14>    callq  0x4005d0 <strncmp@plt>                                   
#   0x400812 <check_password+19>    test   %eax,%eax                                                
#   0x400814 <check_password+21>    je     0x40081b <check_password+28>                             
#   0x400816 <check_password+23>    callq  0x400746 <boom>                                          
#   0x40081b <check_password+28>    add    $0x8,%rsp                                                
#   0x40081f <check_password+32>    retq  
### Avanzamos hasta strncmp de la función check_password()
### para consultar los valores
    br *check_password+14
    cont

### Una vez nos encontremos en check_password+14,
### podemos imprimir la contraseña, la cual se encuentra en rsi
### (variable correct_password, dirección de memoria 0x601070)
#   p(char*) 0x601070
#   p(char*) $rsi
    p(char[0xd]) correct_password

### Establecemos eax=0 para evitar boom()
    ni
    set $eax=0
    ni
    ni
    ni
    ni

### Volvemos a la función main()
#   0x40088c <main+89>      mov    $0x0,%esi                                                        │
#   0x400891 <main+94>      lea    0x20(%rsp),%rdi                                                  │
#   0x400896 <main+99>      callq  0x4005f0 <gettimeofday@plt>                                      │
#   0x40089b <main+104>     mov    0x20(%rsp),%rax                                                  │
#   0x4008a0 <main+109>     sub    0x10(%rsp),%rax                                                  │
#   0x4008a5 <main+114>     cmp    $0x3c,%rax                                                       │
#   0x4008a9 <main+118>     jle    0x4008b0 <main+125>                                              │
#   0x4008ab <main+120>     callq  0x400746 <boom> 
### La siguiente llamada a boom() es por tiempo
### Avanzamos hasta cmp
    br *main+114
    cont
### Establecemos tiempo=0 por si acaso se ha tardado en teclear
### Para ello establecemos eax=0
    set $eax=0
    ni
    ni

### Hacemos ni hasta justo después de introducir el pin  
    ni
### Tras este último ni se mostraría el mensaje para introducir 
### el pin ( resultado de la llamada a la función question2() )
    ni
    ni
    ni
    ni
### Tras este último ni se nos pediría introducir el pin
### Nótese que junto a la orden run ya automatizamos el proceso
### de teclear "123", por lo que no tendremos que teclear nada

### Establecemos un breakpoint en la función check_pin()
### y avanzamos hasta la llamada de dicha función
#   0x4008b0 <main+125>     callq  0x4007ec <question2>                                             
#   0x4008b5 <main+130>     lea    0xc(%rsp),%rsi                                                   
#   0x4008ba <main+135>     mov    $0x400a0d,%edi                                                   
#   0x4008bf <main+140>     mov    $0x0,%eax                                                        
#   0x4008c4 <main+145>     callq  0x400620 <__isoc99_scanf@plt>                                    
#   0x4008c9 <main+150>     mov    %eax,%ebx                                                        
#   0x4008cb <main+152>     test   %eax,%eax                                                        
#   0x4008cd <main+154>     jne    0x4008de <main+171>                                              
#   0x4008cf <main+156>     mov    $0x400a10,%edi                                                   
#   0x4008d4 <main+161>     mov    $0x0,%eax                                                        
#   0x4008d9 <main+166>     callq  0x400620 <__isoc99_scanf@plt>                                    
#   0x4008de <main+171>     cmp    $0x1,%ebx                                                        
#   0x4008e1 <main+174>     jne    0x4008b5 <main+130>                                              
#   0x4008e3 <main+176>     mov    0xc(%rsp),%edi                                                   
#   0x4008e7 <main+180>     callq  0x400820 <check_pin>  
    br check_pin
    cont

### Nos encontramos en la función check_pin()
#   0x400820 <check_pin>    cmp    %edi,0x200842(%rip)   # 0x601068 <correct_pin>              
#   0x400826 <check_pin+6>  je     0x400831 <check_pin+17>                                          
#   0x400828 <check_pin+8>  sub    $0x8,%rsp                                                        
#   0x40082c <check_pin+12> callq  0x400746 <boom>                                                  
#   0x400831 <check_pin+17> repz retq
### Ya podemos imprimir el pin, el cual se encuentra en la 
### variable correct_pin (dirección de memoria 0x601068)
#   p*(int*) 0x601068
    p(int) correct_pin

### Establecemos edi=1096 para evitar boom()
    set $edi=1096
    ni
    ni
    ni

### Volvemos a la función main()
#   0x4008ec <main+185>     mov    $0x0,%esi                                                        
#   0x4008f1 <main+190>     lea    0x10(%rsp),%rdi                                                  
#   0x4008f6 <main+195>     callq  0x4005f0 <gettimeofday@plt>                                      
#   0x4008fb <main+200>     mov    0x10(%rsp),%rax                                                  
#   0x400900 <main+205>     sub    0x20(%rsp),%rax                                                  
#   0x400905 <main+210>     cmp    $0x3c,%rax                                                       
#   0x400909 <main+214>     jle    0x400910 <main+221>                                              
#   0x40090b <main+216>     callq  0x400746 <boom>                                                  
#   0x400910 <main+221>     callq  0x40077c <defused>    
### La siguiente llamada a boom() es por tiempo
### Avanzamos hasta cmp
    br *main+210
    cont
### Establecemos tiempo=0 por si acaso se ha tardado en teclear
### Para ello establecemos eax=0
    set $eax=0
    ni
    ni
    ni

### Tras este último ni se mostraría el mensaje de que la
### bomba ha sido desactivada ( resultado de la llamada a la 
### función defused() )
### Fin del programa

########################################################
################   CAMBIAR LAS CLAVES   ################
########################################################

### Permitir escribir en el ejecutable
    set write on

### Reabrir el ejecutable con permisos r/w
    file bomba_JMRG_2020

### Realizar los cambios
    set {char[13]} 0x601070="desactivada\n"
    set {int} 0x601068=1234

### Comprobar las instrucciones cambiadas
    p(char[0xd]) correct_password
    p(int) correct_pin

### Salir para desbloquear el ejecutable
    quit





