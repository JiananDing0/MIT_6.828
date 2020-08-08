
obj/user/badsegment.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80004e:	e8 ec 00 00 00       	call   80013f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	29 d0                	sub    %edx,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x39>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800079:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007d:	89 34 24             	mov    %esi,(%esp)
  800080:	e8 af ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    
  800091:	00 00                	add    %al,(%eax)
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009a:	e8 30 05 00 00       	call   8005cf <close_all>
	sys_env_destroy(0);
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 42 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 28                	jle    800137 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800113:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011a:	00 
  80011b:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  800132:	e8 29 10 00 00       	call   801160 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	83 c4 2c             	add    $0x2c,%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_yield>:

void
sys_yield(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016e:	89 d1                	mov    %edx,%ecx
  800170:	89 d3                	mov    %edx,%ebx
  800172:	89 d7                	mov    %edx,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800186:	be 00 00 00 00       	mov    $0x0,%esi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 f7                	mov    %esi,%edi
  80019b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80019d:	85 c0                	test   %eax,%eax
  80019f:	7e 28                	jle    8001c9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  8001c4:	e8 97 0f 00 00       	call   801160 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c9:	83 c4 2c             	add    $0x2c,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    

008001d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	7e 28                	jle    80021c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ff:	00 
  800200:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  800217:	e8 44 0f 00 00       	call   801160 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021c:	83 c4 2c             	add    $0x2c,%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5f                   	pop    %edi
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    

00800224 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	b8 06 00 00 00       	mov    $0x6,%eax
  800237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	89 df                	mov    %ebx,%edi
  80023f:	89 de                	mov    %ebx,%esi
  800241:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800243:	85 c0                	test   %eax,%eax
  800245:	7e 28                	jle    80026f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800252:	00 
  800253:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  80026a:	e8 f1 0e 00 00       	call   801160 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026f:	83 c4 2c             	add    $0x2c,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800280:	bb 00 00 00 00       	mov    $0x0,%ebx
  800285:	b8 08 00 00 00       	mov    $0x8,%eax
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	8b 55 08             	mov    0x8(%ebp),%edx
  800290:	89 df                	mov    %ebx,%edi
  800292:	89 de                	mov    %ebx,%esi
  800294:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800296:	85 c0                	test   %eax,%eax
  800298:	7e 28                	jle    8002c2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b5:	00 
  8002b6:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  8002bd:	e8 9e 0e 00 00       	call   801160 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c2:	83 c4 2c             	add    $0x2c,%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e3:	89 df                	mov    %ebx,%edi
  8002e5:	89 de                	mov    %ebx,%esi
  8002e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e9:	85 c0                	test   %eax,%eax
  8002eb:	7e 28                	jle    800315 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  800310:	e8 4b 0e 00 00       	call   801160 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800315:	83 c4 2c             	add    $0x2c,%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 df                	mov    %ebx,%edi
  800338:	89 de                	mov    %ebx,%esi
  80033a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033c:	85 c0                	test   %eax,%eax
  80033e:	7e 28                	jle    800368 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	89 44 24 10          	mov    %eax,0x10(%esp)
  800344:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034b:	00 
  80034c:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  800353:	00 
  800354:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035b:	00 
  80035c:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  800363:	e8 f8 0d 00 00       	call   801160 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800368:	83 c4 2c             	add    $0x2c,%esp
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5f                   	pop    %edi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800376:	be 00 00 00 00       	mov    $0x0,%esi
  80037b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800380:	8b 7d 14             	mov    0x14(%ebp),%edi
  800383:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	89 cb                	mov    %ecx,%ebx
  8003ab:	89 cf                	mov    %ecx,%edi
  8003ad:	89 ce                	mov    %ecx,%esi
  8003af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b1:	85 c0                	test   %eax,%eax
  8003b3:	7e 28                	jle    8003dd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 08 0a 1f 80 	movl   $0x801f0a,0x8(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d0:	00 
  8003d1:	c7 04 24 27 1f 80 00 	movl   $0x801f27,(%esp)
  8003d8:	e8 83 0d 00 00       	call   801160 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003dd:	83 c4 2c             	add    $0x2c,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5e                   	pop    %esi
  8003e2:	5f                   	pop    %edi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    
  8003e5:	00 00                	add    %al,(%eax)
	...

008003e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	e8 df ff ff ff       	call   8003e8 <fd2num>
  800409:	05 20 00 0d 00       	add    $0xd0020,%eax
  80040e:	c1 e0 0c             	shl    $0xc,%eax
}
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	53                   	push   %ebx
  800417:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80041a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80041f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 ea 16             	shr    $0x16,%edx
  800426:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042d:	f6 c2 01             	test   $0x1,%dl
  800430:	74 11                	je     800443 <fd_alloc+0x30>
  800432:	89 c2                	mov    %eax,%edx
  800434:	c1 ea 0c             	shr    $0xc,%edx
  800437:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043e:	f6 c2 01             	test   $0x1,%dl
  800441:	75 09                	jne    80044c <fd_alloc+0x39>
			*fd_store = fd;
  800443:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800445:	b8 00 00 00 00       	mov    $0x0,%eax
  80044a:	eb 17                	jmp    800463 <fd_alloc+0x50>
  80044c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800451:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800456:	75 c7                	jne    80041f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800458:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80045e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800463:	5b                   	pop    %ebx
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80046c:	83 f8 1f             	cmp    $0x1f,%eax
  80046f:	77 36                	ja     8004a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800471:	05 00 00 0d 00       	add    $0xd0000,%eax
  800476:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800479:	89 c2                	mov    %eax,%edx
  80047b:	c1 ea 16             	shr    $0x16,%edx
  80047e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800485:	f6 c2 01             	test   $0x1,%dl
  800488:	74 24                	je     8004ae <fd_lookup+0x48>
  80048a:	89 c2                	mov    %eax,%edx
  80048c:	c1 ea 0c             	shr    $0xc,%edx
  80048f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800496:	f6 c2 01             	test   $0x1,%dl
  800499:	74 1a                	je     8004b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80049b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049e:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	eb 13                	jmp    8004ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ac:	eb 0c                	jmp    8004ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b3:	eb 05                	jmp    8004ba <fd_lookup+0x54>
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	53                   	push   %ebx
  8004c0:	83 ec 14             	sub    $0x14,%esp
  8004c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ce:	eb 0e                	jmp    8004de <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004d0:	39 08                	cmp    %ecx,(%eax)
  8004d2:	75 09                	jne    8004dd <dev_lookup+0x21>
			*dev = devtab[i];
  8004d4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	eb 33                	jmp    800510 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004dd:	42                   	inc    %edx
  8004de:	8b 04 95 b4 1f 80 00 	mov    0x801fb4(,%edx,4),%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 e7                	jne    8004d0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8004ee:	8b 40 48             	mov    0x48(%eax),%eax
  8004f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f9:	c7 04 24 38 1f 80 00 	movl   $0x801f38,(%esp)
  800500:	e8 53 0d 00 00       	call   801258 <cprintf>
	*dev = 0;
  800505:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80050b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800510:	83 c4 14             	add    $0x14,%esp
  800513:	5b                   	pop    %ebx
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 30             	sub    $0x30,%esp
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8a 45 0c             	mov    0xc(%ebp),%al
  800524:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800527:	89 34 24             	mov    %esi,(%esp)
  80052a:	e8 b9 fe ff ff       	call   8003e8 <fd2num>
  80052f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800532:	89 54 24 04          	mov    %edx,0x4(%esp)
  800536:	89 04 24             	mov    %eax,(%esp)
  800539:	e8 28 ff ff ff       	call   800466 <fd_lookup>
  80053e:	89 c3                	mov    %eax,%ebx
  800540:	85 c0                	test   %eax,%eax
  800542:	78 05                	js     800549 <fd_close+0x33>
	    || fd != fd2)
  800544:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800547:	74 0d                	je     800556 <fd_close+0x40>
		return (must_exist ? r : 0);
  800549:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80054d:	75 46                	jne    800595 <fd_close+0x7f>
  80054f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800554:	eb 3f                	jmp    800595 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800556:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	8b 06                	mov    (%esi),%eax
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 55 ff ff ff       	call   8004bc <dev_lookup>
  800567:	89 c3                	mov    %eax,%ebx
  800569:	85 c0                	test   %eax,%eax
  80056b:	78 18                	js     800585 <fd_close+0x6f>
		if (dev->dev_close)
  80056d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800570:	8b 40 10             	mov    0x10(%eax),%eax
  800573:	85 c0                	test   %eax,%eax
  800575:	74 09                	je     800580 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800577:	89 34 24             	mov    %esi,(%esp)
  80057a:	ff d0                	call   *%eax
  80057c:	89 c3                	mov    %eax,%ebx
  80057e:	eb 05                	jmp    800585 <fd_close+0x6f>
		else
			r = 0;
  800580:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800585:	89 74 24 04          	mov    %esi,0x4(%esp)
  800589:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800590:	e8 8f fc ff ff       	call   800224 <sys_page_unmap>
	return r;
}
  800595:	89 d8                	mov    %ebx,%eax
  800597:	83 c4 30             	add    $0x30,%esp
  80059a:	5b                   	pop    %ebx
  80059b:	5e                   	pop    %esi
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    

0080059e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	e8 b0 fe ff ff       	call   800466 <fd_lookup>
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	78 13                	js     8005cd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005c1:	00 
  8005c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005c5:	89 04 24             	mov    %eax,(%esp)
  8005c8:	e8 49 ff ff ff       	call   800516 <fd_close>
}
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    

008005cf <close_all>:

void
close_all(void)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	53                   	push   %ebx
  8005d3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005db:	89 1c 24             	mov    %ebx,(%esp)
  8005de:	e8 bb ff ff ff       	call   80059e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e3:	43                   	inc    %ebx
  8005e4:	83 fb 20             	cmp    $0x20,%ebx
  8005e7:	75 f2                	jne    8005db <close_all+0xc>
		close(i);
}
  8005e9:	83 c4 14             	add    $0x14,%esp
  8005ec:	5b                   	pop    %ebx
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    

008005ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	57                   	push   %edi
  8005f3:	56                   	push   %esi
  8005f4:	53                   	push   %ebx
  8005f5:	83 ec 4c             	sub    $0x4c,%esp
  8005f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800602:	8b 45 08             	mov    0x8(%ebp),%eax
  800605:	89 04 24             	mov    %eax,(%esp)
  800608:	e8 59 fe ff ff       	call   800466 <fd_lookup>
  80060d:	89 c3                	mov    %eax,%ebx
  80060f:	85 c0                	test   %eax,%eax
  800611:	0f 88 e1 00 00 00    	js     8006f8 <dup+0x109>
		return r;
	close(newfdnum);
  800617:	89 3c 24             	mov    %edi,(%esp)
  80061a:	e8 7f ff ff ff       	call   80059e <close>

	newfd = INDEX2FD(newfdnum);
  80061f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800625:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	e8 c5 fd ff ff       	call   8003f8 <fd2data>
  800633:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800635:	89 34 24             	mov    %esi,(%esp)
  800638:	e8 bb fd ff ff       	call   8003f8 <fd2data>
  80063d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800640:	89 d8                	mov    %ebx,%eax
  800642:	c1 e8 16             	shr    $0x16,%eax
  800645:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80064c:	a8 01                	test   $0x1,%al
  80064e:	74 46                	je     800696 <dup+0xa7>
  800650:	89 d8                	mov    %ebx,%eax
  800652:	c1 e8 0c             	shr    $0xc,%eax
  800655:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80065c:	f6 c2 01             	test   $0x1,%dl
  80065f:	74 35                	je     800696 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800661:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800668:	25 07 0e 00 00       	and    $0xe07,%eax
  80066d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800671:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800674:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800678:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80067f:	00 
  800680:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800684:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80068b:	e8 41 fb ff ff       	call   8001d1 <sys_page_map>
  800690:	89 c3                	mov    %eax,%ebx
  800692:	85 c0                	test   %eax,%eax
  800694:	78 3b                	js     8006d1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800696:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800699:	89 c2                	mov    %eax,%edx
  80069b:	c1 ea 0c             	shr    $0xc,%edx
  80069e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006a5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006af:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006ba:	00 
  8006bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c6:	e8 06 fb ff ff       	call   8001d1 <sys_page_map>
  8006cb:	89 c3                	mov    %eax,%ebx
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	79 25                	jns    8006f6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006dc:	e8 43 fb ff ff       	call   800224 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ef:	e8 30 fb ff ff       	call   800224 <sys_page_unmap>
	return r;
  8006f4:	eb 02                	jmp    8006f8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8006f6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8006f8:	89 d8                	mov    %ebx,%eax
  8006fa:	83 c4 4c             	add    $0x4c,%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	53                   	push   %ebx
  800706:	83 ec 24             	sub    $0x24,%esp
  800709:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800713:	89 1c 24             	mov    %ebx,(%esp)
  800716:	e8 4b fd ff ff       	call   800466 <fd_lookup>
  80071b:	85 c0                	test   %eax,%eax
  80071d:	78 6d                	js     80078c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800722:	89 44 24 04          	mov    %eax,0x4(%esp)
  800726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	89 04 24             	mov    %eax,(%esp)
  80072e:	e8 89 fd ff ff       	call   8004bc <dev_lookup>
  800733:	85 c0                	test   %eax,%eax
  800735:	78 55                	js     80078c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073a:	8b 50 08             	mov    0x8(%eax),%edx
  80073d:	83 e2 03             	and    $0x3,%edx
  800740:	83 fa 01             	cmp    $0x1,%edx
  800743:	75 23                	jne    800768 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800745:	a1 04 40 80 00       	mov    0x804004,%eax
  80074a:	8b 40 48             	mov    0x48(%eax),%eax
  80074d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800751:	89 44 24 04          	mov    %eax,0x4(%esp)
  800755:	c7 04 24 79 1f 80 00 	movl   $0x801f79,(%esp)
  80075c:	e8 f7 0a 00 00       	call   801258 <cprintf>
		return -E_INVAL;
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800766:	eb 24                	jmp    80078c <read+0x8a>
	}
	if (!dev->dev_read)
  800768:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076b:	8b 52 08             	mov    0x8(%edx),%edx
  80076e:	85 d2                	test   %edx,%edx
  800770:	74 15                	je     800787 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800772:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800775:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	ff d2                	call   *%edx
  800785:	eb 05                	jmp    80078c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800787:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80078c:	83 c4 24             	add    $0x24,%esp
  80078f:	5b                   	pop    %ebx
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	57                   	push   %edi
  800796:	56                   	push   %esi
  800797:	53                   	push   %ebx
  800798:	83 ec 1c             	sub    $0x1c,%esp
  80079b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80079e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a6:	eb 23                	jmp    8007cb <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	29 d8                	sub    %ebx,%eax
  8007ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b3:	01 d8                	add    %ebx,%eax
  8007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b9:	89 3c 24             	mov    %edi,(%esp)
  8007bc:	e8 41 ff ff ff       	call   800702 <read>
		if (m < 0)
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	78 10                	js     8007d5 <readn+0x43>
			return m;
		if (m == 0)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	74 0a                	je     8007d3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007c9:	01 c3                	add    %eax,%ebx
  8007cb:	39 f3                	cmp    %esi,%ebx
  8007cd:	72 d9                	jb     8007a8 <readn+0x16>
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	eb 02                	jmp    8007d5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007d3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007d5:	83 c4 1c             	add    $0x1c,%esp
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5f                   	pop    %edi
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 24             	sub    $0x24,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ee:	89 1c 24             	mov    %ebx,(%esp)
  8007f1:	e8 70 fc ff ff       	call   800466 <fd_lookup>
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 68                	js     800862 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	8b 00                	mov    (%eax),%eax
  800806:	89 04 24             	mov    %eax,(%esp)
  800809:	e8 ae fc ff ff       	call   8004bc <dev_lookup>
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 50                	js     800862 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 23                	jne    80083e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	c7 04 24 95 1f 80 00 	movl   $0x801f95,(%esp)
  800832:	e8 21 0a 00 00       	call   801258 <cprintf>
		return -E_INVAL;
  800837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083c:	eb 24                	jmp    800862 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80083e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800841:	8b 52 0c             	mov    0xc(%edx),%edx
  800844:	85 d2                	test   %edx,%edx
  800846:	74 15                	je     80085d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800848:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80084b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	ff d2                	call   *%edx
  80085b:	eb 05                	jmp    800862 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80085d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800862:	83 c4 24             	add    $0x24,%esp
  800865:	5b                   	pop    %ebx
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <seek>:

int
seek(int fdnum, off_t offset)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80086e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800871:	89 44 24 04          	mov    %eax,0x4(%esp)
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	e8 e6 fb ff ff       	call   800466 <fd_lookup>
  800880:	85 c0                	test   %eax,%eax
  800882:	78 0e                	js     800892 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800884:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	83 ec 24             	sub    $0x24,%esp
  80089b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a5:	89 1c 24             	mov    %ebx,(%esp)
  8008a8:	e8 b9 fb ff ff       	call   800466 <fd_lookup>
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	78 61                	js     800912 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 04 24             	mov    %eax,(%esp)
  8008c0:	e8 f7 fb ff ff       	call   8004bc <dev_lookup>
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 49                	js     800912 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008cc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008d0:	75 23                	jne    8008f5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008d2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008d7:	8b 40 48             	mov    0x48(%eax),%eax
  8008da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e2:	c7 04 24 58 1f 80 00 	movl   $0x801f58,(%esp)
  8008e9:	e8 6a 09 00 00       	call   801258 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f3:	eb 1d                	jmp    800912 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8008f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008f8:	8b 52 18             	mov    0x18(%edx),%edx
  8008fb:	85 d2                	test   %edx,%edx
  8008fd:	74 0e                	je     80090d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800906:	89 04 24             	mov    %eax,(%esp)
  800909:	ff d2                	call   *%edx
  80090b:	eb 05                	jmp    800912 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80090d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800912:	83 c4 24             	add    $0x24,%esp
  800915:	5b                   	pop    %ebx
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	83 ec 24             	sub    $0x24,%esp
  80091f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800922:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	89 04 24             	mov    %eax,(%esp)
  80092f:	e8 32 fb ff ff       	call   800466 <fd_lookup>
  800934:	85 c0                	test   %eax,%eax
  800936:	78 52                	js     80098a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800938:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80093b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800942:	8b 00                	mov    (%eax),%eax
  800944:	89 04 24             	mov    %eax,(%esp)
  800947:	e8 70 fb ff ff       	call   8004bc <dev_lookup>
  80094c:	85 c0                	test   %eax,%eax
  80094e:	78 3a                	js     80098a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800953:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800957:	74 2c                	je     800985 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800959:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80095c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800963:	00 00 00 
	stat->st_isdir = 0;
  800966:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80096d:	00 00 00 
	stat->st_dev = dev;
  800970:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800976:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80097d:	89 14 24             	mov    %edx,(%esp)
  800980:	ff 50 14             	call   *0x14(%eax)
  800983:	eb 05                	jmp    80098a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800985:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80098a:	83 c4 24             	add    $0x24,%esp
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800998:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80099f:	00 
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	89 04 24             	mov    %eax,(%esp)
  8009a6:	e8 fe 01 00 00       	call   800ba9 <open>
  8009ab:	89 c3                	mov    %eax,%ebx
  8009ad:	85 c0                	test   %eax,%eax
  8009af:	78 1b                	js     8009cc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b8:	89 1c 24             	mov    %ebx,(%esp)
  8009bb:	e8 58 ff ff ff       	call   800918 <fstat>
  8009c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8009c2:	89 1c 24             	mov    %ebx,(%esp)
  8009c5:	e8 d4 fb ff ff       	call   80059e <close>
	return r;
  8009ca:	89 f3                	mov    %esi,%ebx
}
  8009cc:	89 d8                	mov    %ebx,%eax
  8009ce:	83 c4 10             	add    $0x10,%esp
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    
  8009d5:	00 00                	add    %al,(%eax)
	...

008009d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	83 ec 10             	sub    $0x10,%esp
  8009e0:	89 c3                	mov    %eax,%ebx
  8009e2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009e4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009eb:	75 11                	jne    8009fe <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009f4:	e8 20 12 00 00       	call   801c19 <ipc_find_env>
  8009f9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009fe:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a05:	00 
  800a06:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a0d:	00 
  800a0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a12:	a1 00 40 80 00       	mov    0x804000,%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 90 11 00 00       	call   801baf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a26:	00 
  800a27:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a32:	e8 11 11 00 00       	call   801b48 <ipc_recv>
}
  800a37:	83 c4 10             	add    $0x10,%esp
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a52:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a57:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a61:	e8 72 ff ff ff       	call   8009d8 <fsipc>
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	8b 40 0c             	mov    0xc(%eax),%eax
  800a74:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a79:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800a83:	e8 50 ff ff ff       	call   8009d8 <fsipc>
}
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	53                   	push   %ebx
  800a8e:	83 ec 14             	sub    $0x14,%esp
  800a91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa4:	b8 05 00 00 00       	mov    $0x5,%eax
  800aa9:	e8 2a ff ff ff       	call   8009d8 <fsipc>
  800aae:	85 c0                	test   %eax,%eax
  800ab0:	78 2b                	js     800add <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ab2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ab9:	00 
  800aba:	89 1c 24             	mov    %ebx,(%esp)
  800abd:	e8 61 0d 00 00       	call   801823 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ac2:	a1 80 50 80 00       	mov    0x805080,%eax
  800ac7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800acd:	a1 84 50 80 00       	mov    0x805084,%eax
  800ad2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800add:	83 c4 14             	add    $0x14,%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800ae9:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  800af0:	00 
  800af1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800af8:	00 
  800af9:	c7 04 24 e2 1f 80 00 	movl   $0x801fe2,(%esp)
  800b00:	e8 5b 06 00 00       	call   801160 <_panic>

00800b05 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 10             	sub    $0x10,%esp
  800b0d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 40 0c             	mov    0xc(%eax),%eax
  800b16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b1b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2b:	e8 a8 fe ff ff       	call   8009d8 <fsipc>
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	85 c0                	test   %eax,%eax
  800b34:	78 6a                	js     800ba0 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b36:	39 c6                	cmp    %eax,%esi
  800b38:	73 24                	jae    800b5e <devfile_read+0x59>
  800b3a:	c7 44 24 0c ed 1f 80 	movl   $0x801fed,0xc(%esp)
  800b41:	00 
  800b42:	c7 44 24 08 f4 1f 80 	movl   $0x801ff4,0x8(%esp)
  800b49:	00 
  800b4a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b51:	00 
  800b52:	c7 04 24 e2 1f 80 00 	movl   $0x801fe2,(%esp)
  800b59:	e8 02 06 00 00       	call   801160 <_panic>
	assert(r <= PGSIZE);
  800b5e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b63:	7e 24                	jle    800b89 <devfile_read+0x84>
  800b65:	c7 44 24 0c 09 20 80 	movl   $0x802009,0xc(%esp)
  800b6c:	00 
  800b6d:	c7 44 24 08 f4 1f 80 	movl   $0x801ff4,0x8(%esp)
  800b74:	00 
  800b75:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b7c:	00 
  800b7d:	c7 04 24 e2 1f 80 00 	movl   $0x801fe2,(%esp)
  800b84:	e8 d7 05 00 00       	call   801160 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b89:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b94:	00 
  800b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b98:	89 04 24             	mov    %eax,(%esp)
  800b9b:	e8 fc 0d 00 00       	call   80199c <memmove>
	return r;
}
  800ba0:	89 d8                	mov    %ebx,%eax
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 20             	sub    $0x20,%esp
  800bb1:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bb4:	89 34 24             	mov    %esi,(%esp)
  800bb7:	e8 34 0c 00 00       	call   8017f0 <strlen>
  800bbc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bc1:	7f 60                	jg     800c23 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc6:	89 04 24             	mov    %eax,(%esp)
  800bc9:	e8 45 f8 ff ff       	call   800413 <fd_alloc>
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	78 54                	js     800c28 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800bd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bd8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800bdf:	e8 3f 0c 00 00       	call   801823 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bef:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf4:	e8 df fd ff ff       	call   8009d8 <fsipc>
  800bf9:	89 c3                	mov    %eax,%ebx
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	79 15                	jns    800c14 <open+0x6b>
		fd_close(fd, 0);
  800bff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c06:	00 
  800c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0a:	89 04 24             	mov    %eax,(%esp)
  800c0d:	e8 04 f9 ff ff       	call   800516 <fd_close>
		return r;
  800c12:	eb 14                	jmp    800c28 <open+0x7f>
	}

	return fd2num(fd);
  800c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c17:	89 04 24             	mov    %eax,(%esp)
  800c1a:	e8 c9 f7 ff ff       	call   8003e8 <fd2num>
  800c1f:	89 c3                	mov    %eax,%ebx
  800c21:	eb 05                	jmp    800c28 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c23:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c28:	89 d8                	mov    %ebx,%eax
  800c2a:	83 c4 20             	add    $0x20,%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c41:	e8 92 fd ff ff       	call   8009d8 <fsipc>
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 10             	sub    $0x10,%esp
  800c50:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	89 04 24             	mov    %eax,(%esp)
  800c59:	e8 9a f7 ff ff       	call   8003f8 <fd2data>
  800c5e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800c60:	c7 44 24 04 15 20 80 	movl   $0x802015,0x4(%esp)
  800c67:	00 
  800c68:	89 34 24             	mov    %esi,(%esp)
  800c6b:	e8 b3 0b 00 00       	call   801823 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c70:	8b 43 04             	mov    0x4(%ebx),%eax
  800c73:	2b 03                	sub    (%ebx),%eax
  800c75:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800c7b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800c82:	00 00 00 
	stat->st_dev = &devpipe;
  800c85:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800c8c:	30 80 00 
	return 0;
}
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 14             	sub    $0x14,%esp
  800ca2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ca5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ca9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cb0:	e8 6f f5 ff ff       	call   800224 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cb5:	89 1c 24             	mov    %ebx,(%esp)
  800cb8:	e8 3b f7 ff ff       	call   8003f8 <fd2data>
  800cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cc8:	e8 57 f5 ff ff       	call   800224 <sys_page_unmap>
}
  800ccd:	83 c4 14             	add    $0x14,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 2c             	sub    $0x2c,%esp
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800ce1:	a1 04 40 80 00       	mov    0x804004,%eax
  800ce6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800ce9:	89 3c 24             	mov    %edi,(%esp)
  800cec:	e8 6f 0f 00 00       	call   801c60 <pageref>
  800cf1:	89 c6                	mov    %eax,%esi
  800cf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cf6:	89 04 24             	mov    %eax,(%esp)
  800cf9:	e8 62 0f 00 00       	call   801c60 <pageref>
  800cfe:	39 c6                	cmp    %eax,%esi
  800d00:	0f 94 c0             	sete   %al
  800d03:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d06:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d0c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d0f:	39 cb                	cmp    %ecx,%ebx
  800d11:	75 08                	jne    800d1b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d13:	83 c4 2c             	add    $0x2c,%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d1b:	83 f8 01             	cmp    $0x1,%eax
  800d1e:	75 c1                	jne    800ce1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d20:	8b 42 58             	mov    0x58(%edx),%eax
  800d23:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d2a:	00 
  800d2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d33:	c7 04 24 1c 20 80 00 	movl   $0x80201c,(%esp)
  800d3a:	e8 19 05 00 00       	call   801258 <cprintf>
  800d3f:	eb a0                	jmp    800ce1 <_pipeisclosed+0xe>

00800d41 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 1c             	sub    $0x1c,%esp
  800d4a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d4d:	89 34 24             	mov    %esi,(%esp)
  800d50:	e8 a3 f6 ff ff       	call   8003f8 <fd2data>
  800d55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d57:	bf 00 00 00 00       	mov    $0x0,%edi
  800d5c:	eb 3c                	jmp    800d9a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d5e:	89 da                	mov    %ebx,%edx
  800d60:	89 f0                	mov    %esi,%eax
  800d62:	e8 6c ff ff ff       	call   800cd3 <_pipeisclosed>
  800d67:	85 c0                	test   %eax,%eax
  800d69:	75 38                	jne    800da3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800d6b:	e8 ee f3 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d70:	8b 43 04             	mov    0x4(%ebx),%eax
  800d73:	8b 13                	mov    (%ebx),%edx
  800d75:	83 c2 20             	add    $0x20,%edx
  800d78:	39 d0                	cmp    %edx,%eax
  800d7a:	73 e2                	jae    800d5e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800d8a:	79 05                	jns    800d91 <devpipe_write+0x50>
  800d8c:	4a                   	dec    %edx
  800d8d:	83 ca e0             	or     $0xffffffe0,%edx
  800d90:	42                   	inc    %edx
  800d91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d95:	40                   	inc    %eax
  800d96:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d99:	47                   	inc    %edi
  800d9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d9d:	75 d1                	jne    800d70 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d9f:	89 f8                	mov    %edi,%eax
  800da1:	eb 05                	jmp    800da8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800da3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800da8:	83 c4 1c             	add    $0x1c,%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    

00800db0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 1c             	sub    $0x1c,%esp
  800db9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800dbc:	89 3c 24             	mov    %edi,(%esp)
  800dbf:	e8 34 f6 ff ff       	call   8003f8 <fd2data>
  800dc4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dc6:	be 00 00 00 00       	mov    $0x0,%esi
  800dcb:	eb 3a                	jmp    800e07 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800dcd:	85 f6                	test   %esi,%esi
  800dcf:	74 04                	je     800dd5 <devpipe_read+0x25>
				return i;
  800dd1:	89 f0                	mov    %esi,%eax
  800dd3:	eb 40                	jmp    800e15 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800dd5:	89 da                	mov    %ebx,%edx
  800dd7:	89 f8                	mov    %edi,%eax
  800dd9:	e8 f5 fe ff ff       	call   800cd3 <_pipeisclosed>
  800dde:	85 c0                	test   %eax,%eax
  800de0:	75 2e                	jne    800e10 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800de2:	e8 77 f3 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800de7:	8b 03                	mov    (%ebx),%eax
  800de9:	3b 43 04             	cmp    0x4(%ebx),%eax
  800dec:	74 df                	je     800dcd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dee:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800df3:	79 05                	jns    800dfa <devpipe_read+0x4a>
  800df5:	48                   	dec    %eax
  800df6:	83 c8 e0             	or     $0xffffffe0,%eax
  800df9:	40                   	inc    %eax
  800dfa:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800dfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e01:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e04:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e06:	46                   	inc    %esi
  800e07:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e0a:	75 db                	jne    800de7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	eb 05                	jmp    800e15 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e10:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e15:	83 c4 1c             	add    $0x1c,%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    

00800e1d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 3c             	sub    $0x3c,%esp
  800e26:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e29:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e2c:	89 04 24             	mov    %eax,(%esp)
  800e2f:	e8 df f5 ff ff       	call   800413 <fd_alloc>
  800e34:	89 c3                	mov    %eax,%ebx
  800e36:	85 c0                	test   %eax,%eax
  800e38:	0f 88 45 01 00 00    	js     800f83 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e45:	00 
  800e46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e54:	e8 24 f3 ff ff       	call   80017d <sys_page_alloc>
  800e59:	89 c3                	mov    %eax,%ebx
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	0f 88 20 01 00 00    	js     800f83 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800e63:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e66:	89 04 24             	mov    %eax,(%esp)
  800e69:	e8 a5 f5 ff ff       	call   800413 <fd_alloc>
  800e6e:	89 c3                	mov    %eax,%ebx
  800e70:	85 c0                	test   %eax,%eax
  800e72:	0f 88 f8 00 00 00    	js     800f70 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e78:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e7f:	00 
  800e80:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8e:	e8 ea f2 ff ff       	call   80017d <sys_page_alloc>
  800e93:	89 c3                	mov    %eax,%ebx
  800e95:	85 c0                	test   %eax,%eax
  800e97:	0f 88 d3 00 00 00    	js     800f70 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ea0:	89 04 24             	mov    %eax,(%esp)
  800ea3:	e8 50 f5 ff ff       	call   8003f8 <fd2data>
  800ea8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eaa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800eb1:	00 
  800eb2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ebd:	e8 bb f2 ff ff       	call   80017d <sys_page_alloc>
  800ec2:	89 c3                	mov    %eax,%ebx
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	0f 88 91 00 00 00    	js     800f5d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ecf:	89 04 24             	mov    %eax,(%esp)
  800ed2:	e8 21 f5 ff ff       	call   8003f8 <fd2data>
  800ed7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800ede:	00 
  800edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ee3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eea:	00 
  800eeb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef6:	e8 d6 f2 ff ff       	call   8001d1 <sys_page_map>
  800efb:	89 c3                	mov    %eax,%ebx
  800efd:	85 c0                	test   %eax,%eax
  800eff:	78 4c                	js     800f4d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f0a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f16:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f1f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f21:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f24:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f2e:	89 04 24             	mov    %eax,(%esp)
  800f31:	e8 b2 f4 ff ff       	call   8003e8 <fd2num>
  800f36:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f3b:	89 04 24             	mov    %eax,(%esp)
  800f3e:	e8 a5 f4 ff ff       	call   8003e8 <fd2num>
  800f43:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4b:	eb 36                	jmp    800f83 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f58:	e8 c7 f2 ff ff       	call   800224 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6b:	e8 b4 f2 ff ff       	call   800224 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800f70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7e:	e8 a1 f2 ff ff       	call   800224 <sys_page_unmap>
    err:
	return r;
}
  800f83:	89 d8                	mov    %ebx,%eax
  800f85:	83 c4 3c             	add    $0x3c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9d:	89 04 24             	mov    %eax,(%esp)
  800fa0:	e8 c1 f4 ff ff       	call   800466 <fd_lookup>
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 15                	js     800fbe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fac:	89 04 24             	mov    %eax,(%esp)
  800faf:	e8 44 f4 ff ff       	call   8003f8 <fd2data>
	return _pipeisclosed(fd, p);
  800fb4:	89 c2                	mov    %eax,%edx
  800fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb9:	e8 15 fd ff ff       	call   800cd3 <_pipeisclosed>
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fd0:	c7 44 24 04 34 20 80 	movl   $0x802034,0x4(%esp)
  800fd7:	00 
  800fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdb:	89 04 24             	mov    %eax,(%esp)
  800fde:	e8 40 08 00 00       	call   801823 <strcpy>
	return 0;
}
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
  800ff0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ffb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801001:	eb 30                	jmp    801033 <devcons_write+0x49>
		m = n - tot;
  801003:	8b 75 10             	mov    0x10(%ebp),%esi
  801006:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801008:	83 fe 7f             	cmp    $0x7f,%esi
  80100b:	76 05                	jbe    801012 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80100d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801012:	89 74 24 08          	mov    %esi,0x8(%esp)
  801016:	03 45 0c             	add    0xc(%ebp),%eax
  801019:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101d:	89 3c 24             	mov    %edi,(%esp)
  801020:	e8 77 09 00 00       	call   80199c <memmove>
		sys_cputs(buf, m);
  801025:	89 74 24 04          	mov    %esi,0x4(%esp)
  801029:	89 3c 24             	mov    %edi,(%esp)
  80102c:	e8 7f f0 ff ff       	call   8000b0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801031:	01 f3                	add    %esi,%ebx
  801033:	89 d8                	mov    %ebx,%eax
  801035:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801038:	72 c9                	jb     801003 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80103a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5f                   	pop    %edi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80104b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80104f:	75 07                	jne    801058 <devcons_read+0x13>
  801051:	eb 25                	jmp    801078 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801053:	e8 06 f1 ff ff       	call   80015e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801058:	e8 71 f0 ff ff       	call   8000ce <sys_cgetc>
  80105d:	85 c0                	test   %eax,%eax
  80105f:	74 f2                	je     801053 <devcons_read+0xe>
  801061:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801063:	85 c0                	test   %eax,%eax
  801065:	78 1d                	js     801084 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801067:	83 f8 04             	cmp    $0x4,%eax
  80106a:	74 13                	je     80107f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80106c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106f:	88 10                	mov    %dl,(%eax)
	return 1;
  801071:	b8 01 00 00 00       	mov    $0x1,%eax
  801076:	eb 0c                	jmp    801084 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
  80107d:	eb 05                	jmp    801084 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801099:	00 
  80109a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80109d:	89 04 24             	mov    %eax,(%esp)
  8010a0:	e8 0b f0 ff ff       	call   8000b0 <sys_cputs>
}
  8010a5:	c9                   	leave  
  8010a6:	c3                   	ret    

008010a7 <getchar>:

int
getchar(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010ad:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010b4:	00 
  8010b5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c3:	e8 3a f6 ff ff       	call   800702 <read>
	if (r < 0)
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 0f                	js     8010db <getchar+0x34>
		return r;
	if (r < 1)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	7e 06                	jle    8010d6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8010d0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010d4:	eb 05                	jmp    8010db <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8010d6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ed:	89 04 24             	mov    %eax,(%esp)
  8010f0:	e8 71 f3 ff ff       	call   800466 <fd_lookup>
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	78 11                	js     80110a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8010f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010fc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801102:	39 10                	cmp    %edx,(%eax)
  801104:	0f 94 c0             	sete   %al
  801107:	0f b6 c0             	movzbl %al,%eax
}
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <opencons>:

int
opencons(void)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801112:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801115:	89 04 24             	mov    %eax,(%esp)
  801118:	e8 f6 f2 ff ff       	call   800413 <fd_alloc>
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 3c                	js     80115d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801121:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801128:	00 
  801129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801137:	e8 41 f0 ff ff       	call   80017d <sys_page_alloc>
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 1d                	js     80115d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801140:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801146:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801149:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80114b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801155:	89 04 24             	mov    %eax,(%esp)
  801158:	e8 8b f2 ff ff       	call   8003e8 <fd2num>
}
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    
	...

00801160 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
  801165:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801168:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80116b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801171:	e8 c9 ef ff ff       	call   80013f <sys_getenvid>
  801176:	8b 55 0c             	mov    0xc(%ebp),%edx
  801179:	89 54 24 10          	mov    %edx,0x10(%esp)
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801184:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118c:	c7 04 24 40 20 80 00 	movl   $0x802040,(%esp)
  801193:	e8 c0 00 00 00       	call   801258 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801198:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119c:	8b 45 10             	mov    0x10(%ebp),%eax
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	e8 50 00 00 00       	call   8011f7 <vcprintf>
	cprintf("\n");
  8011a7:	c7 04 24 2d 20 80 00 	movl   $0x80202d,(%esp)
  8011ae:	e8 a5 00 00 00       	call   801258 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011b3:	cc                   	int3   
  8011b4:	eb fd                	jmp    8011b3 <_panic+0x53>
	...

008011b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 14             	sub    $0x14,%esp
  8011bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011c2:	8b 03                	mov    (%ebx),%eax
  8011c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8011cb:	40                   	inc    %eax
  8011cc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8011ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011d3:	75 19                	jne    8011ee <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8011d5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011dc:	00 
  8011dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8011e0:	89 04 24             	mov    %eax,(%esp)
  8011e3:	e8 c8 ee ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  8011e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011ee:	ff 43 04             	incl   0x4(%ebx)
}
  8011f1:	83 c4 14             	add    $0x14,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801207:	00 00 00 
	b.cnt = 0;
  80120a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801214:	8b 45 0c             	mov    0xc(%ebp),%eax
  801217:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801222:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122c:	c7 04 24 b8 11 80 00 	movl   $0x8011b8,(%esp)
  801233:	e8 82 01 00 00       	call   8013ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801238:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80123e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801242:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801248:	89 04 24             	mov    %eax,(%esp)
  80124b:	e8 60 ee ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  801250:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801256:	c9                   	leave  
  801257:	c3                   	ret    

00801258 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80125e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801261:	89 44 24 04          	mov    %eax,0x4(%esp)
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	89 04 24             	mov    %eax,(%esp)
  80126b:	e8 87 ff ff ff       	call   8011f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    
	...

00801274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
  80127a:	83 ec 3c             	sub    $0x3c,%esp
  80127d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801280:	89 d7                	mov    %edx,%edi
  801282:	8b 45 08             	mov    0x8(%ebp),%eax
  801285:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80128e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801291:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801294:	85 c0                	test   %eax,%eax
  801296:	75 08                	jne    8012a0 <printnum+0x2c>
  801298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80129b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80129e:	77 57                	ja     8012f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012a0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012a4:	4b                   	dec    %ebx
  8012a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012b4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012bf:	00 
  8012c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c3:	89 04 24             	mov    %eax,(%esp)
  8012c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cd:	e8 d2 09 00 00       	call   801ca4 <__udivdi3>
  8012d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012d6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012da:	89 04 24             	mov    %eax,(%esp)
  8012dd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012e1:	89 fa                	mov    %edi,%edx
  8012e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e6:	e8 89 ff ff ff       	call   801274 <printnum>
  8012eb:	eb 0f                	jmp    8012fc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8012ed:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012f1:	89 34 24             	mov    %esi,(%esp)
  8012f4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8012f7:	4b                   	dec    %ebx
  8012f8:	85 db                	test   %ebx,%ebx
  8012fa:	7f f1                	jg     8012ed <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8012fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801300:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801304:	8b 45 10             	mov    0x10(%ebp),%eax
  801307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801312:	00 
  801313:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801316:	89 04 24             	mov    %eax,(%esp)
  801319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80131c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801320:	e8 9f 0a 00 00       	call   801dc4 <__umoddi3>
  801325:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801329:	0f be 80 63 20 80 00 	movsbl 0x802063(%eax),%eax
  801330:	89 04 24             	mov    %eax,(%esp)
  801333:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801336:	83 c4 3c             	add    $0x3c,%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5f                   	pop    %edi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801341:	83 fa 01             	cmp    $0x1,%edx
  801344:	7e 0e                	jle    801354 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801346:	8b 10                	mov    (%eax),%edx
  801348:	8d 4a 08             	lea    0x8(%edx),%ecx
  80134b:	89 08                	mov    %ecx,(%eax)
  80134d:	8b 02                	mov    (%edx),%eax
  80134f:	8b 52 04             	mov    0x4(%edx),%edx
  801352:	eb 22                	jmp    801376 <getuint+0x38>
	else if (lflag)
  801354:	85 d2                	test   %edx,%edx
  801356:	74 10                	je     801368 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801358:	8b 10                	mov    (%eax),%edx
  80135a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80135d:	89 08                	mov    %ecx,(%eax)
  80135f:	8b 02                	mov    (%edx),%eax
  801361:	ba 00 00 00 00       	mov    $0x0,%edx
  801366:	eb 0e                	jmp    801376 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801368:	8b 10                	mov    (%eax),%edx
  80136a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80136d:	89 08                	mov    %ecx,(%eax)
  80136f:	8b 02                	mov    (%edx),%eax
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80137e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801381:	8b 10                	mov    (%eax),%edx
  801383:	3b 50 04             	cmp    0x4(%eax),%edx
  801386:	73 08                	jae    801390 <sprintputch+0x18>
		*b->buf++ = ch;
  801388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80138b:	88 0a                	mov    %cl,(%edx)
  80138d:	42                   	inc    %edx
  80138e:	89 10                	mov    %edx,(%eax)
}
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801398:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80139b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80139f:	8b 45 10             	mov    0x10(%ebp),%eax
  8013a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b0:	89 04 24             	mov    %eax,(%esp)
  8013b3:	e8 02 00 00 00       	call   8013ba <vprintfmt>
	va_end(ap);
}
  8013b8:	c9                   	leave  
  8013b9:	c3                   	ret    

008013ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	57                   	push   %edi
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 4c             	sub    $0x4c,%esp
  8013c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013c6:	8b 75 10             	mov    0x10(%ebp),%esi
  8013c9:	eb 12                	jmp    8013dd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	0f 84 8b 03 00 00    	je     80175e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8013d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013d7:	89 04 24             	mov    %eax,(%esp)
  8013da:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8013dd:	0f b6 06             	movzbl (%esi),%eax
  8013e0:	46                   	inc    %esi
  8013e1:	83 f8 25             	cmp    $0x25,%eax
  8013e4:	75 e5                	jne    8013cb <vprintfmt+0x11>
  8013e6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013ea:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8013f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8013f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8013fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801402:	eb 26                	jmp    80142a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801404:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801407:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80140b:	eb 1d                	jmp    80142a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80140d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801410:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801414:	eb 14                	jmp    80142a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801416:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801419:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801420:	eb 08                	jmp    80142a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801422:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801425:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80142a:	0f b6 06             	movzbl (%esi),%eax
  80142d:	8d 56 01             	lea    0x1(%esi),%edx
  801430:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801433:	8a 16                	mov    (%esi),%dl
  801435:	83 ea 23             	sub    $0x23,%edx
  801438:	80 fa 55             	cmp    $0x55,%dl
  80143b:	0f 87 01 03 00 00    	ja     801742 <vprintfmt+0x388>
  801441:	0f b6 d2             	movzbl %dl,%edx
  801444:	ff 24 95 a0 21 80 00 	jmp    *0x8021a0(,%edx,4)
  80144b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80144e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801453:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801456:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80145a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80145d:	8d 50 d0             	lea    -0x30(%eax),%edx
  801460:	83 fa 09             	cmp    $0x9,%edx
  801463:	77 2a                	ja     80148f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801465:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801466:	eb eb                	jmp    801453 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801468:	8b 45 14             	mov    0x14(%ebp),%eax
  80146b:	8d 50 04             	lea    0x4(%eax),%edx
  80146e:	89 55 14             	mov    %edx,0x14(%ebp)
  801471:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801473:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801476:	eb 17                	jmp    80148f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801478:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80147c:	78 98                	js     801416 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80147e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801481:	eb a7                	jmp    80142a <vprintfmt+0x70>
  801483:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801486:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80148d:	eb 9b                	jmp    80142a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80148f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801493:	79 95                	jns    80142a <vprintfmt+0x70>
  801495:	eb 8b                	jmp    801422 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801497:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801498:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80149b:	eb 8d                	jmp    80142a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80149d:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a0:	8d 50 04             	lea    0x4(%eax),%edx
  8014a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8014a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014aa:	8b 00                	mov    (%eax),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014b5:	e9 23 ff ff ff       	jmp    8013dd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bd:	8d 50 04             	lea    0x4(%eax),%edx
  8014c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8014c3:	8b 00                	mov    (%eax),%eax
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	79 02                	jns    8014cb <vprintfmt+0x111>
  8014c9:	f7 d8                	neg    %eax
  8014cb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014cd:	83 f8 0f             	cmp    $0xf,%eax
  8014d0:	7f 0b                	jg     8014dd <vprintfmt+0x123>
  8014d2:	8b 04 85 00 23 80 00 	mov    0x802300(,%eax,4),%eax
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	75 23                	jne    801500 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8014dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014e1:	c7 44 24 08 7b 20 80 	movl   $0x80207b,0x8(%esp)
  8014e8:	00 
  8014e9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f0:	89 04 24             	mov    %eax,(%esp)
  8014f3:	e8 9a fe ff ff       	call   801392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8014fb:	e9 dd fe ff ff       	jmp    8013dd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801500:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801504:	c7 44 24 08 06 20 80 	movl   $0x802006,0x8(%esp)
  80150b:	00 
  80150c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801510:	8b 55 08             	mov    0x8(%ebp),%edx
  801513:	89 14 24             	mov    %edx,(%esp)
  801516:	e8 77 fe ff ff       	call   801392 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80151b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80151e:	e9 ba fe ff ff       	jmp    8013dd <vprintfmt+0x23>
  801523:	89 f9                	mov    %edi,%ecx
  801525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801528:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80152b:	8b 45 14             	mov    0x14(%ebp),%eax
  80152e:	8d 50 04             	lea    0x4(%eax),%edx
  801531:	89 55 14             	mov    %edx,0x14(%ebp)
  801534:	8b 30                	mov    (%eax),%esi
  801536:	85 f6                	test   %esi,%esi
  801538:	75 05                	jne    80153f <vprintfmt+0x185>
				p = "(null)";
  80153a:	be 74 20 80 00       	mov    $0x802074,%esi
			if (width > 0 && padc != '-')
  80153f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801543:	0f 8e 84 00 00 00    	jle    8015cd <vprintfmt+0x213>
  801549:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80154d:	74 7e                	je     8015cd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80154f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801553:	89 34 24             	mov    %esi,(%esp)
  801556:	e8 ab 02 00 00       	call   801806 <strnlen>
  80155b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80155e:	29 c2                	sub    %eax,%edx
  801560:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801563:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801567:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80156a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80156d:	89 de                	mov    %ebx,%esi
  80156f:	89 d3                	mov    %edx,%ebx
  801571:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801573:	eb 0b                	jmp    801580 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801575:	89 74 24 04          	mov    %esi,0x4(%esp)
  801579:	89 3c 24             	mov    %edi,(%esp)
  80157c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80157f:	4b                   	dec    %ebx
  801580:	85 db                	test   %ebx,%ebx
  801582:	7f f1                	jg     801575 <vprintfmt+0x1bb>
  801584:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801587:	89 f3                	mov    %esi,%ebx
  801589:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80158c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80158f:	85 c0                	test   %eax,%eax
  801591:	79 05                	jns    801598 <vprintfmt+0x1de>
  801593:	b8 00 00 00 00       	mov    $0x0,%eax
  801598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159b:	29 c2                	sub    %eax,%edx
  80159d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015a0:	eb 2b                	jmp    8015cd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015a2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015a6:	74 18                	je     8015c0 <vprintfmt+0x206>
  8015a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015ab:	83 fa 5e             	cmp    $0x5e,%edx
  8015ae:	76 10                	jbe    8015c0 <vprintfmt+0x206>
					putch('?', putdat);
  8015b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015bb:	ff 55 08             	call   *0x8(%ebp)
  8015be:	eb 0a                	jmp    8015ca <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8015c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8015cd:	0f be 06             	movsbl (%esi),%eax
  8015d0:	46                   	inc    %esi
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	74 21                	je     8015f6 <vprintfmt+0x23c>
  8015d5:	85 ff                	test   %edi,%edi
  8015d7:	78 c9                	js     8015a2 <vprintfmt+0x1e8>
  8015d9:	4f                   	dec    %edi
  8015da:	79 c6                	jns    8015a2 <vprintfmt+0x1e8>
  8015dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015df:	89 de                	mov    %ebx,%esi
  8015e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015e4:	eb 18                	jmp    8015fe <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ea:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8015f1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015f3:	4b                   	dec    %ebx
  8015f4:	eb 08                	jmp    8015fe <vprintfmt+0x244>
  8015f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f9:	89 de                	mov    %ebx,%esi
  8015fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015fe:	85 db                	test   %ebx,%ebx
  801600:	7f e4                	jg     8015e6 <vprintfmt+0x22c>
  801602:	89 7d 08             	mov    %edi,0x8(%ebp)
  801605:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801607:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80160a:	e9 ce fd ff ff       	jmp    8013dd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80160f:	83 f9 01             	cmp    $0x1,%ecx
  801612:	7e 10                	jle    801624 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801614:	8b 45 14             	mov    0x14(%ebp),%eax
  801617:	8d 50 08             	lea    0x8(%eax),%edx
  80161a:	89 55 14             	mov    %edx,0x14(%ebp)
  80161d:	8b 30                	mov    (%eax),%esi
  80161f:	8b 78 04             	mov    0x4(%eax),%edi
  801622:	eb 26                	jmp    80164a <vprintfmt+0x290>
	else if (lflag)
  801624:	85 c9                	test   %ecx,%ecx
  801626:	74 12                	je     80163a <vprintfmt+0x280>
		return va_arg(*ap, long);
  801628:	8b 45 14             	mov    0x14(%ebp),%eax
  80162b:	8d 50 04             	lea    0x4(%eax),%edx
  80162e:	89 55 14             	mov    %edx,0x14(%ebp)
  801631:	8b 30                	mov    (%eax),%esi
  801633:	89 f7                	mov    %esi,%edi
  801635:	c1 ff 1f             	sar    $0x1f,%edi
  801638:	eb 10                	jmp    80164a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80163a:	8b 45 14             	mov    0x14(%ebp),%eax
  80163d:	8d 50 04             	lea    0x4(%eax),%edx
  801640:	89 55 14             	mov    %edx,0x14(%ebp)
  801643:	8b 30                	mov    (%eax),%esi
  801645:	89 f7                	mov    %esi,%edi
  801647:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80164a:	85 ff                	test   %edi,%edi
  80164c:	78 0a                	js     801658 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80164e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801653:	e9 ac 00 00 00       	jmp    801704 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80165c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801663:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801666:	f7 de                	neg    %esi
  801668:	83 d7 00             	adc    $0x0,%edi
  80166b:	f7 df                	neg    %edi
			}
			base = 10;
  80166d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801672:	e9 8d 00 00 00       	jmp    801704 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801677:	89 ca                	mov    %ecx,%edx
  801679:	8d 45 14             	lea    0x14(%ebp),%eax
  80167c:	e8 bd fc ff ff       	call   80133e <getuint>
  801681:	89 c6                	mov    %eax,%esi
  801683:	89 d7                	mov    %edx,%edi
			base = 10;
  801685:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80168a:	eb 78                	jmp    801704 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80168c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801690:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801697:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80169a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169e:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016a5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ac:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8016b9:	e9 1f fd ff ff       	jmp    8013dd <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8016be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016c9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016d7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016da:	8b 45 14             	mov    0x14(%ebp),%eax
  8016dd:	8d 50 04             	lea    0x4(%eax),%edx
  8016e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016e3:	8b 30                	mov    (%eax),%esi
  8016e5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016ea:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8016ef:	eb 13                	jmp    801704 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8016f1:	89 ca                	mov    %ecx,%edx
  8016f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8016f6:	e8 43 fc ff ff       	call   80133e <getuint>
  8016fb:	89 c6                	mov    %eax,%esi
  8016fd:	89 d7                	mov    %edx,%edi
			base = 16;
  8016ff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801704:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801708:	89 54 24 10          	mov    %edx,0x10(%esp)
  80170c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801713:	89 44 24 08          	mov    %eax,0x8(%esp)
  801717:	89 34 24             	mov    %esi,(%esp)
  80171a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80171e:	89 da                	mov    %ebx,%edx
  801720:	8b 45 08             	mov    0x8(%ebp),%eax
  801723:	e8 4c fb ff ff       	call   801274 <printnum>
			break;
  801728:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80172b:	e9 ad fc ff ff       	jmp    8013dd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801730:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801734:	89 04 24             	mov    %eax,(%esp)
  801737:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80173d:	e9 9b fc ff ff       	jmp    8013dd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801742:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801746:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80174d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801750:	eb 01                	jmp    801753 <vprintfmt+0x399>
  801752:	4e                   	dec    %esi
  801753:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801757:	75 f9                	jne    801752 <vprintfmt+0x398>
  801759:	e9 7f fc ff ff       	jmp    8013dd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80175e:	83 c4 4c             	add    $0x4c,%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5f                   	pop    %edi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	83 ec 28             	sub    $0x28,%esp
  80176c:	8b 45 08             	mov    0x8(%ebp),%eax
  80176f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80177c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801783:	85 c0                	test   %eax,%eax
  801785:	74 30                	je     8017b7 <vsnprintf+0x51>
  801787:	85 d2                	test   %edx,%edx
  801789:	7e 33                	jle    8017be <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80178b:	8b 45 14             	mov    0x14(%ebp),%eax
  80178e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801792:	8b 45 10             	mov    0x10(%ebp),%eax
  801795:	89 44 24 08          	mov    %eax,0x8(%esp)
  801799:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80179c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a0:	c7 04 24 78 13 80 00 	movl   $0x801378,(%esp)
  8017a7:	e8 0e fc ff ff       	call   8013ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017af:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b5:	eb 0c                	jmp    8017c3 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017bc:	eb 05                	jmp    8017c3 <vsnprintf+0x5d>
  8017be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	89 04 24             	mov    %eax,(%esp)
  8017e6:	e8 7b ff ff ff       	call   801766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    
  8017ed:	00 00                	add    %al,(%eax)
	...

008017f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8017f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fb:	eb 01                	jmp    8017fe <strlen+0xe>
		n++;
  8017fd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8017fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801802:	75 f9                	jne    8017fd <strlen+0xd>
		n++;
	return n;
}
  801804:	5d                   	pop    %ebp
  801805:	c3                   	ret    

00801806 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80180c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80180f:	b8 00 00 00 00       	mov    $0x0,%eax
  801814:	eb 01                	jmp    801817 <strnlen+0x11>
		n++;
  801816:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801817:	39 d0                	cmp    %edx,%eax
  801819:	74 06                	je     801821 <strnlen+0x1b>
  80181b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80181f:	75 f5                	jne    801816 <strnlen+0x10>
		n++;
	return n;
}
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80182d:	ba 00 00 00 00       	mov    $0x0,%edx
  801832:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801835:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801838:	42                   	inc    %edx
  801839:	84 c9                	test   %cl,%cl
  80183b:	75 f5                	jne    801832 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80183d:	5b                   	pop    %ebx
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80184a:	89 1c 24             	mov    %ebx,(%esp)
  80184d:	e8 9e ff ff ff       	call   8017f0 <strlen>
	strcpy(dst + len, src);
  801852:	8b 55 0c             	mov    0xc(%ebp),%edx
  801855:	89 54 24 04          	mov    %edx,0x4(%esp)
  801859:	01 d8                	add    %ebx,%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 c0 ff ff ff       	call   801823 <strcpy>
	return dst;
}
  801863:	89 d8                	mov    %ebx,%eax
  801865:	83 c4 08             	add    $0x8,%esp
  801868:	5b                   	pop    %ebx
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	56                   	push   %esi
  80186f:	53                   	push   %ebx
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	8b 55 0c             	mov    0xc(%ebp),%edx
  801876:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801879:	b9 00 00 00 00       	mov    $0x0,%ecx
  80187e:	eb 0c                	jmp    80188c <strncpy+0x21>
		*dst++ = *src;
  801880:	8a 1a                	mov    (%edx),%bl
  801882:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801885:	80 3a 01             	cmpb   $0x1,(%edx)
  801888:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80188b:	41                   	inc    %ecx
  80188c:	39 f1                	cmp    %esi,%ecx
  80188e:	75 f0                	jne    801880 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	8b 75 08             	mov    0x8(%ebp),%esi
  80189c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80189f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018a2:	85 d2                	test   %edx,%edx
  8018a4:	75 0a                	jne    8018b0 <strlcpy+0x1c>
  8018a6:	89 f0                	mov    %esi,%eax
  8018a8:	eb 1a                	jmp    8018c4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018aa:	88 18                	mov    %bl,(%eax)
  8018ac:	40                   	inc    %eax
  8018ad:	41                   	inc    %ecx
  8018ae:	eb 02                	jmp    8018b2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018b0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018b2:	4a                   	dec    %edx
  8018b3:	74 0a                	je     8018bf <strlcpy+0x2b>
  8018b5:	8a 19                	mov    (%ecx),%bl
  8018b7:	84 db                	test   %bl,%bl
  8018b9:	75 ef                	jne    8018aa <strlcpy+0x16>
  8018bb:	89 c2                	mov    %eax,%edx
  8018bd:	eb 02                	jmp    8018c1 <strlcpy+0x2d>
  8018bf:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018c1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018c4:	29 f0                	sub    %esi,%eax
}
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018d3:	eb 02                	jmp    8018d7 <strcmp+0xd>
		p++, q++;
  8018d5:	41                   	inc    %ecx
  8018d6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018d7:	8a 01                	mov    (%ecx),%al
  8018d9:	84 c0                	test   %al,%al
  8018db:	74 04                	je     8018e1 <strcmp+0x17>
  8018dd:	3a 02                	cmp    (%edx),%al
  8018df:	74 f4                	je     8018d5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018e1:	0f b6 c0             	movzbl %al,%eax
  8018e4:	0f b6 12             	movzbl (%edx),%edx
  8018e7:	29 d0                	sub    %edx,%eax
}
  8018e9:	5d                   	pop    %ebp
  8018ea:	c3                   	ret    

008018eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	53                   	push   %ebx
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018f5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8018f8:	eb 03                	jmp    8018fd <strncmp+0x12>
		n--, p++, q++;
  8018fa:	4a                   	dec    %edx
  8018fb:	40                   	inc    %eax
  8018fc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8018fd:	85 d2                	test   %edx,%edx
  8018ff:	74 14                	je     801915 <strncmp+0x2a>
  801901:	8a 18                	mov    (%eax),%bl
  801903:	84 db                	test   %bl,%bl
  801905:	74 04                	je     80190b <strncmp+0x20>
  801907:	3a 19                	cmp    (%ecx),%bl
  801909:	74 ef                	je     8018fa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80190b:	0f b6 00             	movzbl (%eax),%eax
  80190e:	0f b6 11             	movzbl (%ecx),%edx
  801911:	29 d0                	sub    %edx,%eax
  801913:	eb 05                	jmp    80191a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80191a:	5b                   	pop    %ebx
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801926:	eb 05                	jmp    80192d <strchr+0x10>
		if (*s == c)
  801928:	38 ca                	cmp    %cl,%dl
  80192a:	74 0c                	je     801938 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80192c:	40                   	inc    %eax
  80192d:	8a 10                	mov    (%eax),%dl
  80192f:	84 d2                	test   %dl,%dl
  801931:	75 f5                	jne    801928 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801938:	5d                   	pop    %ebp
  801939:	c3                   	ret    

0080193a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80193a:	55                   	push   %ebp
  80193b:	89 e5                	mov    %esp,%ebp
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801943:	eb 05                	jmp    80194a <strfind+0x10>
		if (*s == c)
  801945:	38 ca                	cmp    %cl,%dl
  801947:	74 07                	je     801950 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801949:	40                   	inc    %eax
  80194a:	8a 10                	mov    (%eax),%dl
  80194c:	84 d2                	test   %dl,%dl
  80194e:	75 f5                	jne    801945 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	57                   	push   %edi
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	8b 7d 08             	mov    0x8(%ebp),%edi
  80195b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801961:	85 c9                	test   %ecx,%ecx
  801963:	74 30                	je     801995 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801965:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80196b:	75 25                	jne    801992 <memset+0x40>
  80196d:	f6 c1 03             	test   $0x3,%cl
  801970:	75 20                	jne    801992 <memset+0x40>
		c &= 0xFF;
  801972:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801975:	89 d3                	mov    %edx,%ebx
  801977:	c1 e3 08             	shl    $0x8,%ebx
  80197a:	89 d6                	mov    %edx,%esi
  80197c:	c1 e6 18             	shl    $0x18,%esi
  80197f:	89 d0                	mov    %edx,%eax
  801981:	c1 e0 10             	shl    $0x10,%eax
  801984:	09 f0                	or     %esi,%eax
  801986:	09 d0                	or     %edx,%eax
  801988:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80198a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80198d:	fc                   	cld    
  80198e:	f3 ab                	rep stos %eax,%es:(%edi)
  801990:	eb 03                	jmp    801995 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801992:	fc                   	cld    
  801993:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801995:	89 f8                	mov    %edi,%eax
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5f                   	pop    %edi
  80199a:	5d                   	pop    %ebp
  80199b:	c3                   	ret    

0080199c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	57                   	push   %edi
  8019a0:	56                   	push   %esi
  8019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019aa:	39 c6                	cmp    %eax,%esi
  8019ac:	73 34                	jae    8019e2 <memmove+0x46>
  8019ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019b1:	39 d0                	cmp    %edx,%eax
  8019b3:	73 2d                	jae    8019e2 <memmove+0x46>
		s += n;
		d += n;
  8019b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019b8:	f6 c2 03             	test   $0x3,%dl
  8019bb:	75 1b                	jne    8019d8 <memmove+0x3c>
  8019bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019c3:	75 13                	jne    8019d8 <memmove+0x3c>
  8019c5:	f6 c1 03             	test   $0x3,%cl
  8019c8:	75 0e                	jne    8019d8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019ca:	83 ef 04             	sub    $0x4,%edi
  8019cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019d0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019d3:	fd                   	std    
  8019d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019d6:	eb 07                	jmp    8019df <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019d8:	4f                   	dec    %edi
  8019d9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8019dc:	fd                   	std    
  8019dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019df:	fc                   	cld    
  8019e0:	eb 20                	jmp    801a02 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019e2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019e8:	75 13                	jne    8019fd <memmove+0x61>
  8019ea:	a8 03                	test   $0x3,%al
  8019ec:	75 0f                	jne    8019fd <memmove+0x61>
  8019ee:	f6 c1 03             	test   $0x3,%cl
  8019f1:	75 0a                	jne    8019fd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019f3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8019f6:	89 c7                	mov    %eax,%edi
  8019f8:	fc                   	cld    
  8019f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019fb:	eb 05                	jmp    801a02 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8019fd:	89 c7                	mov    %eax,%edi
  8019ff:	fc                   	cld    
  801a00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a02:	5e                   	pop    %esi
  801a03:	5f                   	pop    %edi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1d:	89 04 24             	mov    %eax,(%esp)
  801a20:	e8 77 ff ff ff       	call   80199c <memmove>
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	57                   	push   %edi
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	eb 16                	jmp    801a53 <memcmp+0x2c>
		if (*s1 != *s2)
  801a3d:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a40:	42                   	inc    %edx
  801a41:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a45:	38 c8                	cmp    %cl,%al
  801a47:	74 0a                	je     801a53 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a49:	0f b6 c0             	movzbl %al,%eax
  801a4c:	0f b6 c9             	movzbl %cl,%ecx
  801a4f:	29 c8                	sub    %ecx,%eax
  801a51:	eb 09                	jmp    801a5c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a53:	39 da                	cmp    %ebx,%edx
  801a55:	75 e6                	jne    801a3d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5f                   	pop    %edi
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a6a:	89 c2                	mov    %eax,%edx
  801a6c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a6f:	eb 05                	jmp    801a76 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a71:	38 08                	cmp    %cl,(%eax)
  801a73:	74 05                	je     801a7a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a75:	40                   	inc    %eax
  801a76:	39 d0                	cmp    %edx,%eax
  801a78:	72 f7                	jb     801a71 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a7a:	5d                   	pop    %ebp
  801a7b:	c3                   	ret    

00801a7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a7c:	55                   	push   %ebp
  801a7d:	89 e5                	mov    %esp,%ebp
  801a7f:	57                   	push   %edi
  801a80:	56                   	push   %esi
  801a81:	53                   	push   %ebx
  801a82:	8b 55 08             	mov    0x8(%ebp),%edx
  801a85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a88:	eb 01                	jmp    801a8b <strtol+0xf>
		s++;
  801a8a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a8b:	8a 02                	mov    (%edx),%al
  801a8d:	3c 20                	cmp    $0x20,%al
  801a8f:	74 f9                	je     801a8a <strtol+0xe>
  801a91:	3c 09                	cmp    $0x9,%al
  801a93:	74 f5                	je     801a8a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801a95:	3c 2b                	cmp    $0x2b,%al
  801a97:	75 08                	jne    801aa1 <strtol+0x25>
		s++;
  801a99:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801a9a:	bf 00 00 00 00       	mov    $0x0,%edi
  801a9f:	eb 13                	jmp    801ab4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801aa1:	3c 2d                	cmp    $0x2d,%al
  801aa3:	75 0a                	jne    801aaf <strtol+0x33>
		s++, neg = 1;
  801aa5:	8d 52 01             	lea    0x1(%edx),%edx
  801aa8:	bf 01 00 00 00       	mov    $0x1,%edi
  801aad:	eb 05                	jmp    801ab4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801aaf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ab4:	85 db                	test   %ebx,%ebx
  801ab6:	74 05                	je     801abd <strtol+0x41>
  801ab8:	83 fb 10             	cmp    $0x10,%ebx
  801abb:	75 28                	jne    801ae5 <strtol+0x69>
  801abd:	8a 02                	mov    (%edx),%al
  801abf:	3c 30                	cmp    $0x30,%al
  801ac1:	75 10                	jne    801ad3 <strtol+0x57>
  801ac3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801ac7:	75 0a                	jne    801ad3 <strtol+0x57>
		s += 2, base = 16;
  801ac9:	83 c2 02             	add    $0x2,%edx
  801acc:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ad1:	eb 12                	jmp    801ae5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801ad3:	85 db                	test   %ebx,%ebx
  801ad5:	75 0e                	jne    801ae5 <strtol+0x69>
  801ad7:	3c 30                	cmp    $0x30,%al
  801ad9:	75 05                	jne    801ae0 <strtol+0x64>
		s++, base = 8;
  801adb:	42                   	inc    %edx
  801adc:	b3 08                	mov    $0x8,%bl
  801ade:	eb 05                	jmp    801ae5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801ae0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aea:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801aec:	8a 0a                	mov    (%edx),%cl
  801aee:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801af1:	80 fb 09             	cmp    $0x9,%bl
  801af4:	77 08                	ja     801afe <strtol+0x82>
			dig = *s - '0';
  801af6:	0f be c9             	movsbl %cl,%ecx
  801af9:	83 e9 30             	sub    $0x30,%ecx
  801afc:	eb 1e                	jmp    801b1c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801afe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b01:	80 fb 19             	cmp    $0x19,%bl
  801b04:	77 08                	ja     801b0e <strtol+0x92>
			dig = *s - 'a' + 10;
  801b06:	0f be c9             	movsbl %cl,%ecx
  801b09:	83 e9 57             	sub    $0x57,%ecx
  801b0c:	eb 0e                	jmp    801b1c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b0e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b11:	80 fb 19             	cmp    $0x19,%bl
  801b14:	77 12                	ja     801b28 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b16:	0f be c9             	movsbl %cl,%ecx
  801b19:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b1c:	39 f1                	cmp    %esi,%ecx
  801b1e:	7d 0c                	jge    801b2c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b20:	42                   	inc    %edx
  801b21:	0f af c6             	imul   %esi,%eax
  801b24:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b26:	eb c4                	jmp    801aec <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b28:	89 c1                	mov    %eax,%ecx
  801b2a:	eb 02                	jmp    801b2e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b2c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b32:	74 05                	je     801b39 <strtol+0xbd>
		*endptr = (char *) s;
  801b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b37:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b39:	85 ff                	test   %edi,%edi
  801b3b:	74 04                	je     801b41 <strtol+0xc5>
  801b3d:	89 c8                	mov    %ecx,%eax
  801b3f:	f7 d8                	neg    %eax
}
  801b41:	5b                   	pop    %ebx
  801b42:	5e                   	pop    %esi
  801b43:	5f                   	pop    %edi
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    
	...

00801b48 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	56                   	push   %esi
  801b4c:	53                   	push   %ebx
  801b4d:	83 ec 10             	sub    $0x10,%esp
  801b50:	8b 75 08             	mov    0x8(%ebp),%esi
  801b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	75 05                	jne    801b62 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b5d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b62:	89 04 24             	mov    %eax,(%esp)
  801b65:	e8 29 e8 ff ff       	call   800393 <sys_ipc_recv>
	if (!err) {
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	75 26                	jne    801b94 <ipc_recv+0x4c>
		if (from_env_store) {
  801b6e:	85 f6                	test   %esi,%esi
  801b70:	74 0a                	je     801b7c <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b72:	a1 04 40 80 00       	mov    0x804004,%eax
  801b77:	8b 40 74             	mov    0x74(%eax),%eax
  801b7a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b7c:	85 db                	test   %ebx,%ebx
  801b7e:	74 0a                	je     801b8a <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801b80:	a1 04 40 80 00       	mov    0x804004,%eax
  801b85:	8b 40 78             	mov    0x78(%eax),%eax
  801b88:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801b8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8f:	8b 40 70             	mov    0x70(%eax),%eax
  801b92:	eb 14                	jmp    801ba8 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801b94:	85 f6                	test   %esi,%esi
  801b96:	74 06                	je     801b9e <ipc_recv+0x56>
		*from_env_store = 0;
  801b98:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801b9e:	85 db                	test   %ebx,%ebx
  801ba0:	74 06                	je     801ba8 <ipc_recv+0x60>
		*perm_store = 0;
  801ba2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	5b                   	pop    %ebx
  801bac:	5e                   	pop    %esi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	57                   	push   %edi
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 1c             	sub    $0x1c,%esp
  801bb8:	8b 75 10             	mov    0x10(%ebp),%esi
  801bbb:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801bbe:	85 f6                	test   %esi,%esi
  801bc0:	75 05                	jne    801bc7 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801bc2:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801bc7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bcb:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd9:	89 04 24             	mov    %eax,(%esp)
  801bdc:	e8 8f e7 ff ff       	call   800370 <sys_ipc_try_send>
  801be1:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801be3:	e8 76 e5 ff ff       	call   80015e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801be8:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801beb:	74 da                	je     801bc7 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801bed:	85 db                	test   %ebx,%ebx
  801bef:	74 20                	je     801c11 <ipc_send+0x62>
		panic("send fail: %e", err);
  801bf1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bf5:	c7 44 24 08 60 23 80 	movl   $0x802360,0x8(%esp)
  801bfc:	00 
  801bfd:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c04:	00 
  801c05:	c7 04 24 6e 23 80 00 	movl   $0x80236e,(%esp)
  801c0c:	e8 4f f5 ff ff       	call   801160 <_panic>
	}
	return;
}
  801c11:	83 c4 1c             	add    $0x1c,%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	53                   	push   %ebx
  801c1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c20:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c25:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	c1 e2 07             	shl    $0x7,%edx
  801c31:	29 ca                	sub    %ecx,%edx
  801c33:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c39:	8b 52 50             	mov    0x50(%edx),%edx
  801c3c:	39 da                	cmp    %ebx,%edx
  801c3e:	75 0f                	jne    801c4f <ipc_find_env+0x36>
			return envs[i].env_id;
  801c40:	c1 e0 07             	shl    $0x7,%eax
  801c43:	29 c8                	sub    %ecx,%eax
  801c45:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c4a:	8b 40 40             	mov    0x40(%eax),%eax
  801c4d:	eb 0c                	jmp    801c5b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c4f:	40                   	inc    %eax
  801c50:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c55:	75 ce                	jne    801c25 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c57:	66 b8 00 00          	mov    $0x0,%ax
}
  801c5b:	5b                   	pop    %ebx
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    
	...

00801c60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c66:	89 c2                	mov    %eax,%edx
  801c68:	c1 ea 16             	shr    $0x16,%edx
  801c6b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c72:	f6 c2 01             	test   $0x1,%dl
  801c75:	74 1e                	je     801c95 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c77:	c1 e8 0c             	shr    $0xc,%eax
  801c7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c81:	a8 01                	test   $0x1,%al
  801c83:	74 17                	je     801c9c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c85:	c1 e8 0c             	shr    $0xc,%eax
  801c88:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c8f:	ef 
  801c90:	0f b7 c0             	movzwl %ax,%eax
  801c93:	eb 0c                	jmp    801ca1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9a:	eb 05                	jmp    801ca1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    
	...

00801ca4 <__udivdi3>:
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	83 ec 10             	sub    $0x10,%esp
  801caa:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cb2:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cb6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cba:	89 cd                	mov    %ecx,%ebp
  801cbc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	75 2c                	jne    801cf0 <__udivdi3+0x4c>
  801cc4:	39 f9                	cmp    %edi,%ecx
  801cc6:	77 68                	ja     801d30 <__udivdi3+0x8c>
  801cc8:	85 c9                	test   %ecx,%ecx
  801cca:	75 0b                	jne    801cd7 <__udivdi3+0x33>
  801ccc:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd1:	31 d2                	xor    %edx,%edx
  801cd3:	f7 f1                	div    %ecx
  801cd5:	89 c1                	mov    %eax,%ecx
  801cd7:	31 d2                	xor    %edx,%edx
  801cd9:	89 f8                	mov    %edi,%eax
  801cdb:	f7 f1                	div    %ecx
  801cdd:	89 c7                	mov    %eax,%edi
  801cdf:	89 f0                	mov    %esi,%eax
  801ce1:	f7 f1                	div    %ecx
  801ce3:	89 c6                	mov    %eax,%esi
  801ce5:	89 f0                	mov    %esi,%eax
  801ce7:	89 fa                	mov    %edi,%edx
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	5e                   	pop    %esi
  801ced:	5f                   	pop    %edi
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    
  801cf0:	39 f8                	cmp    %edi,%eax
  801cf2:	77 2c                	ja     801d20 <__udivdi3+0x7c>
  801cf4:	0f bd f0             	bsr    %eax,%esi
  801cf7:	83 f6 1f             	xor    $0x1f,%esi
  801cfa:	75 4c                	jne    801d48 <__udivdi3+0xa4>
  801cfc:	39 f8                	cmp    %edi,%eax
  801cfe:	bf 00 00 00 00       	mov    $0x0,%edi
  801d03:	72 0a                	jb     801d0f <__udivdi3+0x6b>
  801d05:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d09:	0f 87 ad 00 00 00    	ja     801dbc <__udivdi3+0x118>
  801d0f:	be 01 00 00 00       	mov    $0x1,%esi
  801d14:	89 f0                	mov    %esi,%eax
  801d16:	89 fa                	mov    %edi,%edx
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	5e                   	pop    %esi
  801d1c:	5f                   	pop    %edi
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    
  801d1f:	90                   	nop
  801d20:	31 ff                	xor    %edi,%edi
  801d22:	31 f6                	xor    %esi,%esi
  801d24:	89 f0                	mov    %esi,%eax
  801d26:	89 fa                	mov    %edi,%edx
  801d28:	83 c4 10             	add    $0x10,%esp
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    
  801d2f:	90                   	nop
  801d30:	89 fa                	mov    %edi,%edx
  801d32:	89 f0                	mov    %esi,%eax
  801d34:	f7 f1                	div    %ecx
  801d36:	89 c6                	mov    %eax,%esi
  801d38:	31 ff                	xor    %edi,%edi
  801d3a:	89 f0                	mov    %esi,%eax
  801d3c:	89 fa                	mov    %edi,%edx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    
  801d45:	8d 76 00             	lea    0x0(%esi),%esi
  801d48:	89 f1                	mov    %esi,%ecx
  801d4a:	d3 e0                	shl    %cl,%eax
  801d4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d50:	b8 20 00 00 00       	mov    $0x20,%eax
  801d55:	29 f0                	sub    %esi,%eax
  801d57:	89 ea                	mov    %ebp,%edx
  801d59:	88 c1                	mov    %al,%cl
  801d5b:	d3 ea                	shr    %cl,%edx
  801d5d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d61:	09 ca                	or     %ecx,%edx
  801d63:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d67:	89 f1                	mov    %esi,%ecx
  801d69:	d3 e5                	shl    %cl,%ebp
  801d6b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d6f:	89 fd                	mov    %edi,%ebp
  801d71:	88 c1                	mov    %al,%cl
  801d73:	d3 ed                	shr    %cl,%ebp
  801d75:	89 fa                	mov    %edi,%edx
  801d77:	89 f1                	mov    %esi,%ecx
  801d79:	d3 e2                	shl    %cl,%edx
  801d7b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d7f:	88 c1                	mov    %al,%cl
  801d81:	d3 ef                	shr    %cl,%edi
  801d83:	09 d7                	or     %edx,%edi
  801d85:	89 f8                	mov    %edi,%eax
  801d87:	89 ea                	mov    %ebp,%edx
  801d89:	f7 74 24 08          	divl   0x8(%esp)
  801d8d:	89 d1                	mov    %edx,%ecx
  801d8f:	89 c7                	mov    %eax,%edi
  801d91:	f7 64 24 0c          	mull   0xc(%esp)
  801d95:	39 d1                	cmp    %edx,%ecx
  801d97:	72 17                	jb     801db0 <__udivdi3+0x10c>
  801d99:	74 09                	je     801da4 <__udivdi3+0x100>
  801d9b:	89 fe                	mov    %edi,%esi
  801d9d:	31 ff                	xor    %edi,%edi
  801d9f:	e9 41 ff ff ff       	jmp    801ce5 <__udivdi3+0x41>
  801da4:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da8:	89 f1                	mov    %esi,%ecx
  801daa:	d3 e2                	shl    %cl,%edx
  801dac:	39 c2                	cmp    %eax,%edx
  801dae:	73 eb                	jae    801d9b <__udivdi3+0xf7>
  801db0:	8d 77 ff             	lea    -0x1(%edi),%esi
  801db3:	31 ff                	xor    %edi,%edi
  801db5:	e9 2b ff ff ff       	jmp    801ce5 <__udivdi3+0x41>
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	31 f6                	xor    %esi,%esi
  801dbe:	e9 22 ff ff ff       	jmp    801ce5 <__udivdi3+0x41>
	...

00801dc4 <__umoddi3>:
  801dc4:	55                   	push   %ebp
  801dc5:	57                   	push   %edi
  801dc6:	56                   	push   %esi
  801dc7:	83 ec 20             	sub    $0x20,%esp
  801dca:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dce:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801dd2:	89 44 24 14          	mov    %eax,0x14(%esp)
  801dd6:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dda:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dde:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801de2:	89 c7                	mov    %eax,%edi
  801de4:	89 f2                	mov    %esi,%edx
  801de6:	85 ed                	test   %ebp,%ebp
  801de8:	75 16                	jne    801e00 <__umoddi3+0x3c>
  801dea:	39 f1                	cmp    %esi,%ecx
  801dec:	0f 86 a6 00 00 00    	jbe    801e98 <__umoddi3+0xd4>
  801df2:	f7 f1                	div    %ecx
  801df4:	89 d0                	mov    %edx,%eax
  801df6:	31 d2                	xor    %edx,%edx
  801df8:	83 c4 20             	add    $0x20,%esp
  801dfb:	5e                   	pop    %esi
  801dfc:	5f                   	pop    %edi
  801dfd:	5d                   	pop    %ebp
  801dfe:	c3                   	ret    
  801dff:	90                   	nop
  801e00:	39 f5                	cmp    %esi,%ebp
  801e02:	0f 87 ac 00 00 00    	ja     801eb4 <__umoddi3+0xf0>
  801e08:	0f bd c5             	bsr    %ebp,%eax
  801e0b:	83 f0 1f             	xor    $0x1f,%eax
  801e0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e12:	0f 84 a8 00 00 00    	je     801ec0 <__umoddi3+0xfc>
  801e18:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e1c:	d3 e5                	shl    %cl,%ebp
  801e1e:	bf 20 00 00 00       	mov    $0x20,%edi
  801e23:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e27:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e2b:	89 f9                	mov    %edi,%ecx
  801e2d:	d3 e8                	shr    %cl,%eax
  801e2f:	09 e8                	or     %ebp,%eax
  801e31:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e35:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e39:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e3d:	d3 e0                	shl    %cl,%eax
  801e3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e43:	89 f2                	mov    %esi,%edx
  801e45:	d3 e2                	shl    %cl,%edx
  801e47:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e4b:	d3 e0                	shl    %cl,%eax
  801e4d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e51:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e55:	89 f9                	mov    %edi,%ecx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	09 d0                	or     %edx,%eax
  801e5b:	d3 ee                	shr    %cl,%esi
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	f7 74 24 18          	divl   0x18(%esp)
  801e63:	89 d6                	mov    %edx,%esi
  801e65:	f7 64 24 0c          	mull   0xc(%esp)
  801e69:	89 c5                	mov    %eax,%ebp
  801e6b:	89 d1                	mov    %edx,%ecx
  801e6d:	39 d6                	cmp    %edx,%esi
  801e6f:	72 67                	jb     801ed8 <__umoddi3+0x114>
  801e71:	74 75                	je     801ee8 <__umoddi3+0x124>
  801e73:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e77:	29 e8                	sub    %ebp,%eax
  801e79:	19 ce                	sbb    %ecx,%esi
  801e7b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e7f:	d3 e8                	shr    %cl,%eax
  801e81:	89 f2                	mov    %esi,%edx
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	d3 e2                	shl    %cl,%edx
  801e87:	09 d0                	or     %edx,%eax
  801e89:	89 f2                	mov    %esi,%edx
  801e8b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e8f:	d3 ea                	shr    %cl,%edx
  801e91:	83 c4 20             	add    $0x20,%esp
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    
  801e98:	85 c9                	test   %ecx,%ecx
  801e9a:	75 0b                	jne    801ea7 <__umoddi3+0xe3>
  801e9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea1:	31 d2                	xor    %edx,%edx
  801ea3:	f7 f1                	div    %ecx
  801ea5:	89 c1                	mov    %eax,%ecx
  801ea7:	89 f0                	mov    %esi,%eax
  801ea9:	31 d2                	xor    %edx,%edx
  801eab:	f7 f1                	div    %ecx
  801ead:	89 f8                	mov    %edi,%eax
  801eaf:	e9 3e ff ff ff       	jmp    801df2 <__umoddi3+0x2e>
  801eb4:	89 f2                	mov    %esi,%edx
  801eb6:	83 c4 20             	add    $0x20,%esp
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	39 f5                	cmp    %esi,%ebp
  801ec2:	72 04                	jb     801ec8 <__umoddi3+0x104>
  801ec4:	39 f9                	cmp    %edi,%ecx
  801ec6:	77 06                	ja     801ece <__umoddi3+0x10a>
  801ec8:	89 f2                	mov    %esi,%edx
  801eca:	29 cf                	sub    %ecx,%edi
  801ecc:	19 ea                	sbb    %ebp,%edx
  801ece:	89 f8                	mov    %edi,%eax
  801ed0:	83 c4 20             	add    $0x20,%esp
  801ed3:	5e                   	pop    %esi
  801ed4:	5f                   	pop    %edi
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    
  801ed7:	90                   	nop
  801ed8:	89 d1                	mov    %edx,%ecx
  801eda:	89 c5                	mov    %eax,%ebp
  801edc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801ee0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ee4:	eb 8d                	jmp    801e73 <__umoddi3+0xaf>
  801ee6:	66 90                	xchg   %ax,%ax
  801ee8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801eec:	72 ea                	jb     801ed8 <__umoddi3+0x114>
  801eee:	89 f1                	mov    %esi,%ecx
  801ef0:	eb 81                	jmp    801e73 <__umoddi3+0xaf>
