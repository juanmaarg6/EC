# Practica 4: Resolución y modificación de la bomba MCG_bomba2020
# Alumno:     Juan Manuel Rodríguez Gómez

# CONTRASEÑA: bombatactica
# 	 PIN: 1123581321

# MODIFICADA: desactivada
#	 PIN: 1234

# Describimos el proceso lógico seguido para:
# 1) Descubrir las claves
# 2) Cambiar las claves 

# Pensado para ejecutar mediante "source bomba_MCG_JMRG.gdb"
# o desde la línea de comandos con gdb -q -x bomba_MCG_2020_JMRG.gdb

########################################################
###############   DESCUBRIR LAS CLAVES   ###############
########################################################

### Cargar el programa
    file MCG_bomba2020

### Útil para la sesion interactiva, no para source/gdb -q -x
#   layout asm
#   layout regs

### Notemos que la alumna ha realizado diversas funciones para
### despistar ( booom() o no_entres() ), pero no nos hace
### falta entrar en dichas funciones para obtener la contraseña
### y el pin de la bomba

### Establecemos un breakpoint en la función main() y
### arrancamos el programa, añadiendo una automatización
### para el momento en el que nos pidan teclear la contraseña 
### y el pin
    br main
    run  < <(echo -e hola\\n123\\n)

### Avanzamos hasta justo antes de introducir la contraseña
#   0x4007ca <main+59>      callq  0x400610 <__printf_chk@plt>                                      
#   0x4007cf <main+64>      lea    0x30(%rsp),%rdi                                                  
#   0x4007d4 <main+69>      mov    0x2008c5(%rip),%rdx   # 0x6010a0 <stdin@@GLIBC_2.2.5>       
#   0x4007db <main+76>      mov    $0x64,%esi                                                       
#   0x4007e0 <main+81>      callq  0x400600 <fgets@plt>  
    br *main+81
    cont

### Vemos que hay tres contraseñas posibles, de las cuales
### solo una es la correcta: password53 (dirección de
### memoria 0x601078), password26 (dirección de memoria
### 0x601068), password33 (dirección de memoria 0x601088)
### Tras probar cada una de ellas, vemos que la correcta
### es password33, luego, ya tenemos la contraseña de la
### bomba
#   0x4007f4 <main+101>     lea    0x20087d(%rip),%rsi   # 0x601078 <password53> 
#   0x400813 <main+132>     lea    0x20084e(%rip),%rsi   # 0x601068 <password26>  
#   0x400832 <main+163>     lea    0x20084f(%rip),%rsi   # 0x601088 <password33> 
#   p(char[0xd]) password33
    p(char*) 0x601088

### Avanzamos hasta justo el momento de introducir la
### contraseña
    ni

### Tras este último ni se nos pediría introducir la contraseña
### Nótese que junto a la orden run ya automatizamos el proceso
### de teclear "hola", por lo que no tendremos que teclear nada

### Vemos que hay dos strncmp antes del strncmp de la contraseña
### correcta, así que vamos avanzando uno a uno y vamos 
### estableciendo eax=0 para evitar boom() 
#   0x4007f4 <main+101>     lea    0x20087d(%rip),%rsi   # 0x601078 <password53>               
#   0x4007fb <main+108>     callq  0x4005d0 <strncmp@plt>                                           
#   0x400800 <main+113>     test   %eax,%eax                                                        
#   0x400802 <main+115>     jne    0x400809 <main+122>                                              
#   0x400804 <main+117>     callq  0x400727 <boom> 
    br *main+108
    cont
    set $eax=0
    ni
    ni
    ni
#   0x400813 <main+132>     lea    0x20084e(%rip),%rsi   # 0x601068 <password26>               
#   0x40081a <main+139>     callq  0x4005d0 <strncmp@plt>                                           
#   0x40081f <main+144>     test   %eax,%eax                                                        
#   0x400821 <main+146>     jne    0x400828 <main+153>                                              
#   0x400823 <main+148>     callq  0x400727 <boom>  
    br *main+139
    cont
    set $eax=0
    ni
    ni
    ni

### Avanzamos hasta el strncmp de la contraseña correcta,
### dejamos que salga mal y luego establecemos eax=0 para
### así saltar a *main+225
#   0x400832 <main+163>     lea    0x20084f(%rip),%rsi   # 0x601088 <password33>               
#   0x400839 <main+170>     callq  0x4005d0 <strncmp@plt>                                           
#   0x40083e <main+175>     test   %eax,%eax                                                        
#   0x400840 <main+177>     je     0x400870 <main+225> 
    br *main+170
    cont
    ni
    set $eax=0
    ni
    ni

### La siguiente llamada a boom() es por tiempo
### Avanzamos hasta cmp
#   0x40085b <main+204>     cmp    $0x3c,%rax                                                       
#   0x40085f <main+208>     jle    0x400866 <main+215>                                              
#   0x400861 <main+210>     callq  0x400727 <boom>  
    br *main+265
    cont

### Establecemos tiempo=0 por si acaso se ha tardado en teclear
### Para ello establecemos eax=0
    set $eax=0
    ni
    ni

### Avanzamos hasta justo antes de introducir el pin
#   0x4008ca <main+315>     callq  0x400620 <__isoc99_scanf@plt>                                    
#   0x4008cf <main+320>     mov    %eax,%ebx                                                        
#   0x4008d1 <main+322>     test   %eax,%eax                                                        
#   0x4008d3 <main+324>     jne    0x4008e6 <main+343> 
    br *main+315
    cont

### Vemos que el pin correcto está almacenado en la 
### variable passcode (dirección de memoria 0x601060), 
### luego, ya tenemos el pin de la bomba
#   0x4008eb <main+348>     mov    0x20076f(%rip),%eax   # 0x601060 <passcode>   
#   p*(int*) 0x601060
    p(int) passcode

### Avanzamos hasta justo el momento de introducir el
### pin
    ni

### Tras este último ni se nos pediría introducir el pin
### Nótese que junto a la orden run ya automatizamos el proceso
### de teclear "123", por lo que no tendremos que teclear nada

### Avanzamos hasta cmp
#   0x4008f1 <main+354>     cmp    %eax,0xc(%rsp)                                                   
#   0x4008f5 <main+358>     je     0x4008fc <main+365>                                              
#   0x4008f7 <main+360>     callq  0x400727 <boom>   
    br *main+354
    cont

### Establecemos eax=123 para que cmp salga bien
    set $eax=123
    ni
    ni

### La siguiente llamada a boom() es por tiempo
### Avanzamos hasta cmp
#   0x400915 <main+390>     cmp    $0x3c,%rax                                                       
#   0x400919 <main+394>     jle    0x400920 <main+401>                                              
#   0x40091b <main+396>     callq  0x400727 <boom>                                                  
#   0x400920 <main+401>     callq  0x400741 <defused> 
    br *main+390
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
    file MCG_bomba2020_modificado

### Realizar los cambios
    set {char[13]} 0x601088="desactivada\n"
    set {int} 0x601060=1234

### Comprobar las instrucciones cambiadas
    p(char[0xd]) password33
    p(int) passcode

### Salir para desbloquear el ejecutable
    quit





