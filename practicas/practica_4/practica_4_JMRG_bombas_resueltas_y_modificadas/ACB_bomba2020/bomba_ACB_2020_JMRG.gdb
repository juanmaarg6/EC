# Practica 4: Resolución y modificación de la bomba ACB_bomba2020
# Alumno:     Juan Manuel Rodríguez Gómez

# CONTRASEÑA: Homeomorfismo
# 	 PIN: 304

# MODIFICADA: desactivada
#	 PIN: 1234

# Describimos el proceso lógico seguido para:
# 1) Descubrir las claves
# 2) Cambiar las claves 

# Pensado para ejecutar mediante "source bomba_ACB_2020_JMRG.gdb"
# o desde la línea de comandos con gdb -q -x bomba_ACB_2020_JMRG.gdb

########################################################
###############   DESCUBRIR LAS CLAVES   ###############
########################################################

### Cargar el programa
    file ACB_bomba2020

### Útil para la sesion interactiva, no para source/gdb -q -x
#   layout asm
#   layout regs

### Establecemos un breakpoint en la función main() y
### arrancamos el programa, añadiendo una automatización
### para el momento en el que nos pidan teclear la contraseña 
### , las respuestas a las dos preguntas matemáticas y el pin
    br main
    run  < <(echo -e hola\\n1\\n180\\n123\\n)

### Avanzamos hasta justo antes de introducir la contraseña
#   0x401275 <main+63>      callq  0x4010e0                                                         
#   0x40127a <main+68>      lea    0x30(%rsp),%rdi                                                  
#   0x40127f <main+73>      mov    0x2e1a(%rip),%rdx   # 0x4040a0 <stdin@@GLIBC_2.2.5>         
#   0x401286 <main+80>      mov    $0x64,%esi                                                       
#   0x40128b <main+85>      callq  0x4010d0 
    br *main+85
    cont

### Avanzamos hasta justo el momento de introducir la
### contraseña
    ni

### Tras este último ni se nos pediría introducir la contraseña
### Nótese que junto a la orden run ya automatizamos el proceso
### de teclear "hola", por lo que no tendremos que teclear nada

### Vemos que tras introducir la contraseña, aparecen dos cuestiones
### sobre matemáticas, las cuales no influyen en nada acerca de la
### resolución de la bomba, es decir, aunque la respuesta a estas
### cuestiones sean incorrectas, la bomba no estallará. 
#   0x40129c <main+102>     callq  0x4010b0                                                         
#   0x4012a1 <main+107>     lea    0xc(%rsp),%rbx                                                   
#   0x4012a6 <main+112>     mov    %rbx,%rsi                                                        
#   0x4012a9 <main+115>     lea    0x13fe(%rip),%rdi   # 0x4026ae                              
#   0x4012b0 <main+122>     mov    $0x0,%eax                                                        
#   0x4012b5 <main+127>     callq  0x4010f0                                                         
#   0x4012ba <main+132>     addl   $0x1,0x2d9f(%rip)   # 0x404060 <clave>                      
#   0x4012c1 <main+139>     lea    0x12f0(%rip),%rdi   # 0x4025b8                              
#   0x4012c8 <main+146>     callq  0x4010b0                                                         
#   0x4012cd <main+151>     mov    %rbx,%rsi                                                        
#   0x4012d0 <main+154>     lea    0x13d7(%rip),%rdi   # 0x4026ae                              
#   0x4012d7 <main+161>     mov    $0x0,%eax                                                        
#   0x4012dc <main+166>     callq  0x4010f0                                                         
#   0x4012e1 <main+171>     addl   $0xb4,0x2d75(%rip)   # 0x404060 <clave>                     
#   0x4012eb <main+181>     lea    0x133e(%rip),%rsi   # 0x402630                              
#   0x4012f2 <main+188>     mov    $0x1,%edi                                                        
#   0x4012f7 <main+193>     mov    $0x0,%eax                                                        
#   0x4012fc <main+198>     callq  0x4010e0                

### Nótese que junto a la orden run ya automatizamos el proceso
### de teclear "1" y "180" como respuestas a dichas preguntas,
### por lo que no tendremos que teclear nada

### Observamos que la contraseña de la bomba se encuentra en
### la variable contrasenia3 (dirección de memoria 0x404068)
#   p(char[0xd]) contrasenia3
    p(char*) 0x404068

### Avanzamos hasta strncmp, dejamos que salga mal y 
### luego establecemos eax=0 para así saltar a *main+122
#   0x40130b <main+213>     lea    0x2d56(%rip),%rsi   # 0x404068 <contrasenia3>               
#   0x401312 <main+220>     callq  0x4010a0                                                        
#   0x401317 <main+225>     test   %eax,%eax                                                       
#   0x401319 <main+227>     je     0x401320 <main+234>                                              
#   0x40131b <main+229>     callq  0x4011f6 <boom> 
    br *main+220
    cont
    ni
    set $eax=0
    ni
    ni

### La siguiente llamada a boom() es por tiempo
### Avanzamos hasta cmp
#   0x401339 <main+259>     cmp    $0x3c,%rax                                                       
#   0x40133d <main+263>     jle    0x401344 <main+270>                                              
#   0x40133f <main+265>     callq  0x4011f6 <boom> 
    br *main+259
    cont

### Establecemos tiempo=0 por si acaso se ha tardado en teclear
### Para ello establecemos eax=0
    set $eax=0
    ni
    ni

### Avanzamos hasta justo antes de introducir el pin
#   0x40136b <main+309>     callq  0x4010f0                                                          
#   0x401370 <main+314>     mov    %eax,%ebx                                                         
#   0x401372 <main+316>     test   %eax,%eax                                                         
#   0x401374 <main+318>     jne    0x401387 <main+337>  
    br *main+309
    cont

### Observamos que el pin de la bomba se encuentra en
### la variable clave (dirección de memoria 0x404060)
#   p*(int*) 0x404060
    p(int) clave

### Cabe destacar que clave=123 al comienzo, pero luego
### se le suman las respuestas a las preguntas matemáticas,
### 1 y 180, respectivamente, y es por eso eso que
### clave=123+1+180=304. Se le suman dichos valores en
### las siguientes líneas:
#   0x4012ba <main+132>     addl   $0x1,0x2d9f(%rip)    # 0x404060 <clave>                      
#   0x4012e1 <main+171>     addl   $0xb4,0x2d75(%rip)   # 0x404060 <clave> 
                    
### Avanzamos hasta justo el momento de introducir el
### pin
    ni

### Tras este último ni se nos pediría introducir el pin
### Nótese que junto a la orden run ya automatizamos el proceso
### de teclear "123", por lo que no tendremos que teclear nada

### Avanzamos hasta cmp
#   0x401392 <main+348>     cmp    %eax,0x8(%rsp)                                                   
#   0x401396 <main+352>     je     0x40139d <main+359>                                              
#   0x401398 <main+354>     callq  0x4011f6 <boom>  
    br *main+348
    cont

### Establecemos eax=123 para que cmp salga bien
    set $eax=123
    ni
    ni

### La siguiente llamada a boom() es por tiempo
### Avanzamos hasta cmp
#   0x4013b6 <main+384>     cmp    $0x3c,%rax                                                       
#   0x4013ba <main+388>     jle    0x4013c1 <main+395>                                              
#   0x4013bc <main+390>     callq  0x4011f6 <boom>                                                  
#   0x4013c1 <main+395>     callq  0x401216 <defused>  
    br *main+384
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
    file ACB_bomba2020_modificado

### Realizar los cambios
    set {char[13]} 0x404068="desactivada\n"

### Recordemos que a la clave se le sumará 181 (suma de
### de las respuestas de ambas preguntas matemáticas). Por ello,
### si queremos que clave=1234, tenemos que establecer
### clave=1234-181=1053
    set {int} 0x404060=1053

### Comprobar las instrucciones cambiadas
    p(char[0xd]) contrasenia3
    p(int) clave

### Salir para desbloquear el ejecutable
    quit





