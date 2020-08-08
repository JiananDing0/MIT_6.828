
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 30 80 00 00 	movl   $0x801f00,0x803000
  800041:	1f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 21 01 00 00       	call   80016a <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	83 ec 10             	sub    $0x10,%esp
  800054:	8b 75 08             	mov    0x8(%ebp),%esi
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80005a:	e8 ec 00 00 00       	call   80014b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006b:	c1 e0 07             	shl    $0x7,%eax
  80006e:	29 d0                	sub    %edx,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 07                	jle    800085 <libmain+0x39>
		binaryname = argv[0];
  80007e:	8b 03                	mov    (%ebx),%eax
  800080:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800085:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800089:	89 34 24             	mov    %esi,(%esp)
  80008c:	e8 a3 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800091:	e8 0a 00 00 00       	call   8000a0 <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a6:	e8 30 05 00 00       	call   8005db <close_all>
	sys_env_destroy(0);
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 42 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    
  8000b9:	00 00                	add    %al,(%eax)
	...

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	b8 03 00 00 00       	mov    $0x3,%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800117:	85 c0                	test   %eax,%eax
  800119:	7e 28                	jle    800143 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800126:	00 
  800127:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  80013e:	e8 29 10 00 00       	call   80116c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800143:	83 c4 2c             	add    $0x2c,%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_yield>:

void
sys_yield(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 d3                	mov    %edx,%ebx
  80017e:	89 d7                	mov    %edx,%edi
  800180:	89 d6                	mov    %edx,%esi
  800182:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800192:	be 00 00 00 00       	mov    $0x0,%esi
  800197:	b8 04 00 00 00       	mov    $0x4,%eax
  80019c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	89 f7                	mov    %esi,%edi
  8001a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7e 28                	jle    8001d5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c8:	00 
  8001c9:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  8001d0:	e8 97 0f 00 00       	call   80116c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d5:	83 c4 2c             	add    $0x2c,%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5f                   	pop    %edi
  8001db:	5d                   	pop    %ebp
  8001dc:	c3                   	ret    

008001dd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7e 28                	jle    800228 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800200:	89 44 24 10          	mov    %eax,0x10(%esp)
  800204:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020b:	00 
  80020c:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  800213:	00 
  800214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  800223:	e8 44 0f 00 00       	call   80116c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800228:	83 c4 2c             	add    $0x2c,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	89 df                	mov    %ebx,%edi
  80024b:	89 de                	mov    %ebx,%esi
  80024d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024f:	85 c0                	test   %eax,%eax
  800251:	7e 28                	jle    80027b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800253:	89 44 24 10          	mov    %eax,0x10(%esp)
  800257:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025e:	00 
  80025f:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  800266:	00 
  800267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026e:	00 
  80026f:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  800276:	e8 f1 0e 00 00       	call   80116c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027b:	83 c4 2c             	add    $0x2c,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 08 00 00 00       	mov    $0x8,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	89 de                	mov    %ebx,%esi
  8002a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	7e 28                	jle    8002ce <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002aa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  8002c9:	e8 9e 0e 00 00       	call   80116c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ce:	83 c4 2c             	add    $0x2c,%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	89 df                	mov    %ebx,%edi
  8002f1:	89 de                	mov    %ebx,%esi
  8002f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 28                	jle    800321 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800304:	00 
  800305:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  80030c:	00 
  80030d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800314:	00 
  800315:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  80031c:	e8 4b 0e 00 00       	call   80116c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800321:	83 c4 2c             	add    $0x2c,%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	bb 00 00 00 00       	mov    $0x0,%ebx
  800337:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	89 df                	mov    %ebx,%edi
  800344:	89 de                	mov    %ebx,%esi
  800346:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800348:	85 c0                	test   %eax,%eax
  80034a:	7e 28                	jle    800374 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800350:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800357:	00 
  800358:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  80035f:	00 
  800360:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800367:	00 
  800368:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  80036f:	e8 f8 0d 00 00       	call   80116c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800374:	83 c4 2c             	add    $0x2c,%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800382:	be 00 00 00 00       	mov    $0x0,%esi
  800387:	b8 0c 00 00 00       	mov    $0xc,%eax
  80038c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039a:	5b                   	pop    %ebx
  80039b:	5e                   	pop    %esi
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	89 cb                	mov    %ecx,%ebx
  8003b7:	89 cf                	mov    %ecx,%edi
  8003b9:	89 ce                	mov    %ecx,%esi
  8003bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003bd:	85 c0                	test   %eax,%eax
  8003bf:	7e 28                	jle    8003e9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 08 0f 1f 80 	movl   $0x801f0f,0x8(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003dc:	00 
  8003dd:	c7 04 24 2c 1f 80 00 	movl   $0x801f2c,(%esp)
  8003e4:	e8 83 0d 00 00       	call   80116c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e9:	83 c4 2c             	add    $0x2c,%esp
  8003ec:	5b                   	pop    %ebx
  8003ed:	5e                   	pop    %esi
  8003ee:	5f                   	pop    %edi
  8003ef:	5d                   	pop    %ebp
  8003f0:	c3                   	ret    
  8003f1:	00 00                	add    %al,(%eax)
	...

008003f4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ff:	c1 e8 0c             	shr    $0xc,%eax
}
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
  80040d:	89 04 24             	mov    %eax,(%esp)
  800410:	e8 df ff ff ff       	call   8003f4 <fd2num>
  800415:	05 20 00 0d 00       	add    $0xd0020,%eax
  80041a:	c1 e0 0c             	shl    $0xc,%eax
}
  80041d:	c9                   	leave  
  80041e:	c3                   	ret    

0080041f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	53                   	push   %ebx
  800423:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800426:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80042b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	c1 ea 16             	shr    $0x16,%edx
  800432:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800439:	f6 c2 01             	test   $0x1,%dl
  80043c:	74 11                	je     80044f <fd_alloc+0x30>
  80043e:	89 c2                	mov    %eax,%edx
  800440:	c1 ea 0c             	shr    $0xc,%edx
  800443:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044a:	f6 c2 01             	test   $0x1,%dl
  80044d:	75 09                	jne    800458 <fd_alloc+0x39>
			*fd_store = fd;
  80044f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800451:	b8 00 00 00 00       	mov    $0x0,%eax
  800456:	eb 17                	jmp    80046f <fd_alloc+0x50>
  800458:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80045d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800462:	75 c7                	jne    80042b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800464:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80046a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80046f:	5b                   	pop    %ebx
  800470:	5d                   	pop    %ebp
  800471:	c3                   	ret    

00800472 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800478:	83 f8 1f             	cmp    $0x1f,%eax
  80047b:	77 36                	ja     8004b3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80047d:	05 00 00 0d 00       	add    $0xd0000,%eax
  800482:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800485:	89 c2                	mov    %eax,%edx
  800487:	c1 ea 16             	shr    $0x16,%edx
  80048a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800491:	f6 c2 01             	test   $0x1,%dl
  800494:	74 24                	je     8004ba <fd_lookup+0x48>
  800496:	89 c2                	mov    %eax,%edx
  800498:	c1 ea 0c             	shr    $0xc,%edx
  80049b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004a2:	f6 c2 01             	test   $0x1,%dl
  8004a5:	74 1a                	je     8004c1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004aa:	89 02                	mov    %eax,(%edx)
	return 0;
  8004ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b1:	eb 13                	jmp    8004c6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b8:	eb 0c                	jmp    8004c6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004bf:	eb 05                	jmp    8004c6 <fd_lookup+0x54>
  8004c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	53                   	push   %ebx
  8004cc:	83 ec 14             	sub    $0x14,%esp
  8004cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004da:	eb 0e                	jmp    8004ea <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004dc:	39 08                	cmp    %ecx,(%eax)
  8004de:	75 09                	jne    8004e9 <dev_lookup+0x21>
			*dev = devtab[i];
  8004e0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e7:	eb 33                	jmp    80051c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e9:	42                   	inc    %edx
  8004ea:	8b 04 95 b8 1f 80 00 	mov    0x801fb8(,%edx,4),%eax
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	75 e7                	jne    8004dc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8004fa:	8b 40 48             	mov    0x48(%eax),%eax
  8004fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	c7 04 24 3c 1f 80 00 	movl   $0x801f3c,(%esp)
  80050c:	e8 53 0d 00 00       	call   801264 <cprintf>
	*dev = 0;
  800511:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800517:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80051c:	83 c4 14             	add    $0x14,%esp
  80051f:	5b                   	pop    %ebx
  800520:	5d                   	pop    %ebp
  800521:	c3                   	ret    

00800522 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 30             	sub    $0x30,%esp
  80052a:	8b 75 08             	mov    0x8(%ebp),%esi
  80052d:	8a 45 0c             	mov    0xc(%ebp),%al
  800530:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800533:	89 34 24             	mov    %esi,(%esp)
  800536:	e8 b9 fe ff ff       	call   8003f4 <fd2num>
  80053b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80053e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	e8 28 ff ff ff       	call   800472 <fd_lookup>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	85 c0                	test   %eax,%eax
  80054e:	78 05                	js     800555 <fd_close+0x33>
	    || fd != fd2)
  800550:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800553:	74 0d                	je     800562 <fd_close+0x40>
		return (must_exist ? r : 0);
  800555:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800559:	75 46                	jne    8005a1 <fd_close+0x7f>
  80055b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800560:	eb 3f                	jmp    8005a1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800562:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800565:	89 44 24 04          	mov    %eax,0x4(%esp)
  800569:	8b 06                	mov    (%esi),%eax
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	e8 55 ff ff ff       	call   8004c8 <dev_lookup>
  800573:	89 c3                	mov    %eax,%ebx
  800575:	85 c0                	test   %eax,%eax
  800577:	78 18                	js     800591 <fd_close+0x6f>
		if (dev->dev_close)
  800579:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80057c:	8b 40 10             	mov    0x10(%eax),%eax
  80057f:	85 c0                	test   %eax,%eax
  800581:	74 09                	je     80058c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800583:	89 34 24             	mov    %esi,(%esp)
  800586:	ff d0                	call   *%eax
  800588:	89 c3                	mov    %eax,%ebx
  80058a:	eb 05                	jmp    800591 <fd_close+0x6f>
		else
			r = 0;
  80058c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800591:	89 74 24 04          	mov    %esi,0x4(%esp)
  800595:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80059c:	e8 8f fc ff ff       	call   800230 <sys_page_unmap>
	return r;
}
  8005a1:	89 d8                	mov    %ebx,%eax
  8005a3:	83 c4 30             	add    $0x30,%esp
  8005a6:	5b                   	pop    %ebx
  8005a7:	5e                   	pop    %esi
  8005a8:	5d                   	pop    %ebp
  8005a9:	c3                   	ret    

008005aa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
  8005ad:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	e8 b0 fe ff ff       	call   800472 <fd_lookup>
  8005c2:	85 c0                	test   %eax,%eax
  8005c4:	78 13                	js     8005d9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005cd:	00 
  8005ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005d1:	89 04 24             	mov    %eax,(%esp)
  8005d4:	e8 49 ff ff ff       	call   800522 <fd_close>
}
  8005d9:	c9                   	leave  
  8005da:	c3                   	ret    

008005db <close_all>:

void
close_all(void)
{
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	53                   	push   %ebx
  8005df:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005e7:	89 1c 24             	mov    %ebx,(%esp)
  8005ea:	e8 bb ff ff ff       	call   8005aa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ef:	43                   	inc    %ebx
  8005f0:	83 fb 20             	cmp    $0x20,%ebx
  8005f3:	75 f2                	jne    8005e7 <close_all+0xc>
		close(i);
}
  8005f5:	83 c4 14             	add    $0x14,%esp
  8005f8:	5b                   	pop    %ebx
  8005f9:	5d                   	pop    %ebp
  8005fa:	c3                   	ret    

008005fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005fb:	55                   	push   %ebp
  8005fc:	89 e5                	mov    %esp,%ebp
  8005fe:	57                   	push   %edi
  8005ff:	56                   	push   %esi
  800600:	53                   	push   %ebx
  800601:	83 ec 4c             	sub    $0x4c,%esp
  800604:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800607:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	8b 45 08             	mov    0x8(%ebp),%eax
  800611:	89 04 24             	mov    %eax,(%esp)
  800614:	e8 59 fe ff ff       	call   800472 <fd_lookup>
  800619:	89 c3                	mov    %eax,%ebx
  80061b:	85 c0                	test   %eax,%eax
  80061d:	0f 88 e1 00 00 00    	js     800704 <dup+0x109>
		return r;
	close(newfdnum);
  800623:	89 3c 24             	mov    %edi,(%esp)
  800626:	e8 7f ff ff ff       	call   8005aa <close>

	newfd = INDEX2FD(newfdnum);
  80062b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800631:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	e8 c5 fd ff ff       	call   800404 <fd2data>
  80063f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800641:	89 34 24             	mov    %esi,(%esp)
  800644:	e8 bb fd ff ff       	call   800404 <fd2data>
  800649:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80064c:	89 d8                	mov    %ebx,%eax
  80064e:	c1 e8 16             	shr    $0x16,%eax
  800651:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800658:	a8 01                	test   $0x1,%al
  80065a:	74 46                	je     8006a2 <dup+0xa7>
  80065c:	89 d8                	mov    %ebx,%eax
  80065e:	c1 e8 0c             	shr    $0xc,%eax
  800661:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800668:	f6 c2 01             	test   $0x1,%dl
  80066b:	74 35                	je     8006a2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80066d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800674:	25 07 0e 00 00       	and    $0xe07,%eax
  800679:	89 44 24 10          	mov    %eax,0x10(%esp)
  80067d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800680:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800684:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80068b:	00 
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800697:	e8 41 fb ff ff       	call   8001dd <sys_page_map>
  80069c:	89 c3                	mov    %eax,%ebx
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	78 3b                	js     8006dd <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	c1 ea 0c             	shr    $0xc,%edx
  8006aa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006b1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006b7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006bb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006c6:	00 
  8006c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006d2:	e8 06 fb ff ff       	call   8001dd <sys_page_map>
  8006d7:	89 c3                	mov    %eax,%ebx
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	79 25                	jns    800702 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e8:	e8 43 fb ff ff       	call   800230 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006fb:	e8 30 fb ff ff       	call   800230 <sys_page_unmap>
	return r;
  800700:	eb 02                	jmp    800704 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800702:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800704:	89 d8                	mov    %ebx,%eax
  800706:	83 c4 4c             	add    $0x4c,%esp
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	5f                   	pop    %edi
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	53                   	push   %ebx
  800712:	83 ec 24             	sub    $0x24,%esp
  800715:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800718:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071f:	89 1c 24             	mov    %ebx,(%esp)
  800722:	e8 4b fd ff ff       	call   800472 <fd_lookup>
  800727:	85 c0                	test   %eax,%eax
  800729:	78 6d                	js     800798 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 04 24             	mov    %eax,(%esp)
  80073a:	e8 89 fd ff ff       	call   8004c8 <dev_lookup>
  80073f:	85 c0                	test   %eax,%eax
  800741:	78 55                	js     800798 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800746:	8b 50 08             	mov    0x8(%eax),%edx
  800749:	83 e2 03             	and    $0x3,%edx
  80074c:	83 fa 01             	cmp    $0x1,%edx
  80074f:	75 23                	jne    800774 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800751:	a1 04 40 80 00       	mov    0x804004,%eax
  800756:	8b 40 48             	mov    0x48(%eax),%eax
  800759:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80075d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800761:	c7 04 24 7d 1f 80 00 	movl   $0x801f7d,(%esp)
  800768:	e8 f7 0a 00 00       	call   801264 <cprintf>
		return -E_INVAL;
  80076d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800772:	eb 24                	jmp    800798 <read+0x8a>
	}
	if (!dev->dev_read)
  800774:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800777:	8b 52 08             	mov    0x8(%edx),%edx
  80077a:	85 d2                	test   %edx,%edx
  80077c:	74 15                	je     800793 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80077e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800781:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800788:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078c:	89 04 24             	mov    %eax,(%esp)
  80078f:	ff d2                	call   *%edx
  800791:	eb 05                	jmp    800798 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800793:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800798:	83 c4 24             	add    $0x24,%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	57                   	push   %edi
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 1c             	sub    $0x1c,%esp
  8007a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b2:	eb 23                	jmp    8007d7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007b4:	89 f0                	mov    %esi,%eax
  8007b6:	29 d8                	sub    %ebx,%eax
  8007b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bf:	01 d8                	add    %ebx,%eax
  8007c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c5:	89 3c 24             	mov    %edi,(%esp)
  8007c8:	e8 41 ff ff ff       	call   80070e <read>
		if (m < 0)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 10                	js     8007e1 <readn+0x43>
			return m;
		if (m == 0)
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	74 0a                	je     8007df <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d5:	01 c3                	add    %eax,%ebx
  8007d7:	39 f3                	cmp    %esi,%ebx
  8007d9:	72 d9                	jb     8007b4 <readn+0x16>
  8007db:	89 d8                	mov    %ebx,%eax
  8007dd:	eb 02                	jmp    8007e1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007df:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007e1:	83 c4 1c             	add    $0x1c,%esp
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5f                   	pop    %edi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 24             	sub    $0x24,%esp
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fa:	89 1c 24             	mov    %ebx,(%esp)
  8007fd:	e8 70 fc ff ff       	call   800472 <fd_lookup>
  800802:	85 c0                	test   %eax,%eax
  800804:	78 68                	js     80086e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800810:	8b 00                	mov    (%eax),%eax
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 ae fc ff ff       	call   8004c8 <dev_lookup>
  80081a:	85 c0                	test   %eax,%eax
  80081c:	78 50                	js     80086e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800821:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800825:	75 23                	jne    80084a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800827:	a1 04 40 80 00       	mov    0x804004,%eax
  80082c:	8b 40 48             	mov    0x48(%eax),%eax
  80082f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800833:	89 44 24 04          	mov    %eax,0x4(%esp)
  800837:	c7 04 24 99 1f 80 00 	movl   $0x801f99,(%esp)
  80083e:	e8 21 0a 00 00       	call   801264 <cprintf>
		return -E_INVAL;
  800843:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800848:	eb 24                	jmp    80086e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80084a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084d:	8b 52 0c             	mov    0xc(%edx),%edx
  800850:	85 d2                	test   %edx,%edx
  800852:	74 15                	je     800869 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800854:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800857:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800862:	89 04 24             	mov    %eax,(%esp)
  800865:	ff d2                	call   *%edx
  800867:	eb 05                	jmp    80086e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800869:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80086e:	83 c4 24             	add    $0x24,%esp
  800871:	5b                   	pop    %ebx
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <seek>:

int
seek(int fdnum, off_t offset)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80087a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	89 04 24             	mov    %eax,(%esp)
  800887:	e8 e6 fb ff ff       	call   800472 <fd_lookup>
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 0e                	js     80089e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800890:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
  800896:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	53                   	push   %ebx
  8008a4:	83 ec 24             	sub    $0x24,%esp
  8008a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	89 1c 24             	mov    %ebx,(%esp)
  8008b4:	e8 b9 fb ff ff       	call   800472 <fd_lookup>
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	78 61                	js     80091e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c7:	8b 00                	mov    (%eax),%eax
  8008c9:	89 04 24             	mov    %eax,(%esp)
  8008cc:	e8 f7 fb ff ff       	call   8004c8 <dev_lookup>
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	78 49                	js     80091e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008dc:	75 23                	jne    800901 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008de:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008e3:	8b 40 48             	mov    0x48(%eax),%eax
  8008e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	c7 04 24 5c 1f 80 00 	movl   $0x801f5c,(%esp)
  8008f5:	e8 6a 09 00 00       	call   801264 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ff:	eb 1d                	jmp    80091e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800901:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800904:	8b 52 18             	mov    0x18(%edx),%edx
  800907:	85 d2                	test   %edx,%edx
  800909:	74 0e                	je     800919 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	ff d2                	call   *%edx
  800917:	eb 05                	jmp    80091e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80091e:	83 c4 24             	add    $0x24,%esp
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	83 ec 24             	sub    $0x24,%esp
  80092b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80092e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800931:	89 44 24 04          	mov    %eax,0x4(%esp)
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	89 04 24             	mov    %eax,(%esp)
  80093b:	e8 32 fb ff ff       	call   800472 <fd_lookup>
  800940:	85 c0                	test   %eax,%eax
  800942:	78 52                	js     800996 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80094e:	8b 00                	mov    (%eax),%eax
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	e8 70 fb ff ff       	call   8004c8 <dev_lookup>
  800958:	85 c0                	test   %eax,%eax
  80095a:	78 3a                	js     800996 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800963:	74 2c                	je     800991 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800965:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800968:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80096f:	00 00 00 
	stat->st_isdir = 0;
  800972:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800979:	00 00 00 
	stat->st_dev = dev;
  80097c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800982:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800986:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800989:	89 14 24             	mov    %edx,(%esp)
  80098c:	ff 50 14             	call   *0x14(%eax)
  80098f:	eb 05                	jmp    800996 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800991:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800996:	83 c4 24             	add    $0x24,%esp
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009ab:	00 
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	e8 fe 01 00 00       	call   800bb5 <open>
  8009b7:	89 c3                	mov    %eax,%ebx
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 1b                	js     8009d8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c4:	89 1c 24             	mov    %ebx,(%esp)
  8009c7:	e8 58 ff ff ff       	call   800924 <fstat>
  8009cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ce:	89 1c 24             	mov    %ebx,(%esp)
  8009d1:	e8 d4 fb ff ff       	call   8005aa <close>
	return r;
  8009d6:	89 f3                	mov    %esi,%ebx
}
  8009d8:	89 d8                	mov    %ebx,%eax
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    
  8009e1:	00 00                	add    %al,(%eax)
	...

008009e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 10             	sub    $0x10,%esp
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009f7:	75 11                	jne    800a0a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a00:	e8 20 12 00 00       	call   801c25 <ipc_find_env>
  800a05:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a0a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a11:	00 
  800a12:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a19:	00 
  800a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1e:	a1 00 40 80 00       	mov    0x804000,%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 90 11 00 00       	call   801bbb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a32:	00 
  800a33:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a3e:	e8 11 11 00 00       	call   801b54 <ipc_recv>
}
  800a43:	83 c4 10             	add    $0x10,%esp
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 40 0c             	mov    0xc(%eax),%eax
  800a56:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 02 00 00 00       	mov    $0x2,%eax
  800a6d:	e8 72 ff ff ff       	call   8009e4 <fsipc>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a80:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800a8f:	e8 50 ff ff ff       	call   8009e4 <fsipc>
}
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 14             	sub    $0x14,%esp
  800a9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ab5:	e8 2a ff ff ff       	call   8009e4 <fsipc>
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 2b                	js     800ae9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800abe:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ac5:	00 
  800ac6:	89 1c 24             	mov    %ebx,(%esp)
  800ac9:	e8 61 0d 00 00       	call   80182f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ace:	a1 80 50 80 00       	mov    0x805080,%eax
  800ad3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ad9:	a1 84 50 80 00       	mov    0x805084,%eax
  800ade:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae9:	83 c4 14             	add    $0x14,%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800af5:	c7 44 24 08 c8 1f 80 	movl   $0x801fc8,0x8(%esp)
  800afc:	00 
  800afd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800b04:	00 
  800b05:	c7 04 24 e6 1f 80 00 	movl   $0x801fe6,(%esp)
  800b0c:	e8 5b 06 00 00       	call   80116c <_panic>

00800b11 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
  800b16:	83 ec 10             	sub    $0x10,%esp
  800b19:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800b22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800b27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 03 00 00 00       	mov    $0x3,%eax
  800b37:	e8 a8 fe ff ff       	call   8009e4 <fsipc>
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	78 6a                	js     800bac <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800b42:	39 c6                	cmp    %eax,%esi
  800b44:	73 24                	jae    800b6a <devfile_read+0x59>
  800b46:	c7 44 24 0c f1 1f 80 	movl   $0x801ff1,0xc(%esp)
  800b4d:	00 
  800b4e:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  800b55:	00 
  800b56:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800b5d:	00 
  800b5e:	c7 04 24 e6 1f 80 00 	movl   $0x801fe6,(%esp)
  800b65:	e8 02 06 00 00       	call   80116c <_panic>
	assert(r <= PGSIZE);
  800b6a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b6f:	7e 24                	jle    800b95 <devfile_read+0x84>
  800b71:	c7 44 24 0c 0d 20 80 	movl   $0x80200d,0xc(%esp)
  800b78:	00 
  800b79:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  800b80:	00 
  800b81:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800b88:	00 
  800b89:	c7 04 24 e6 1f 80 00 	movl   $0x801fe6,(%esp)
  800b90:	e8 d7 05 00 00       	call   80116c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b99:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ba0:	00 
  800ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba4:	89 04 24             	mov    %eax,(%esp)
  800ba7:	e8 fc 0d 00 00       	call   8019a8 <memmove>
	return r;
}
  800bac:	89 d8                	mov    %ebx,%eax
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 20             	sub    $0x20,%esp
  800bbd:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800bc0:	89 34 24             	mov    %esi,(%esp)
  800bc3:	e8 34 0c 00 00       	call   8017fc <strlen>
  800bc8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800bcd:	7f 60                	jg     800c2f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800bcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd2:	89 04 24             	mov    %eax,(%esp)
  800bd5:	e8 45 f8 ff ff       	call   80041f <fd_alloc>
  800bda:	89 c3                	mov    %eax,%ebx
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	78 54                	js     800c34 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800be0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be4:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800beb:	e8 3f 0c 00 00       	call   80182f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800bf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bfb:	b8 01 00 00 00       	mov    $0x1,%eax
  800c00:	e8 df fd ff ff       	call   8009e4 <fsipc>
  800c05:	89 c3                	mov    %eax,%ebx
  800c07:	85 c0                	test   %eax,%eax
  800c09:	79 15                	jns    800c20 <open+0x6b>
		fd_close(fd, 0);
  800c0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c12:	00 
  800c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c16:	89 04 24             	mov    %eax,(%esp)
  800c19:	e8 04 f9 ff ff       	call   800522 <fd_close>
		return r;
  800c1e:	eb 14                	jmp    800c34 <open+0x7f>
	}

	return fd2num(fd);
  800c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c23:	89 04 24             	mov    %eax,(%esp)
  800c26:	e8 c9 f7 ff ff       	call   8003f4 <fd2num>
  800c2b:	89 c3                	mov    %eax,%ebx
  800c2d:	eb 05                	jmp    800c34 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800c2f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800c34:	89 d8                	mov    %ebx,%eax
  800c36:	83 c4 20             	add    $0x20,%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4d:	e8 92 fd ff ff       	call   8009e4 <fsipc>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 10             	sub    $0x10,%esp
  800c5c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c62:	89 04 24             	mov    %eax,(%esp)
  800c65:	e8 9a f7 ff ff       	call   800404 <fd2data>
  800c6a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800c6c:	c7 44 24 04 19 20 80 	movl   $0x802019,0x4(%esp)
  800c73:	00 
  800c74:	89 34 24             	mov    %esi,(%esp)
  800c77:	e8 b3 0b 00 00       	call   80182f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800c7c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7f:	2b 03                	sub    (%ebx),%eax
  800c81:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800c87:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800c8e:	00 00 00 
	stat->st_dev = &devpipe;
  800c91:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800c98:	30 80 00 
	return 0;
}
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca0:	83 c4 10             	add    $0x10,%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	53                   	push   %ebx
  800cab:	83 ec 14             	sub    $0x14,%esp
  800cae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800cb1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cbc:	e8 6f f5 ff ff       	call   800230 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800cc1:	89 1c 24             	mov    %ebx,(%esp)
  800cc4:	e8 3b f7 ff ff       	call   800404 <fd2data>
  800cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ccd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cd4:	e8 57 f5 ff ff       	call   800230 <sys_page_unmap>
}
  800cd9:	83 c4 14             	add    $0x14,%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 2c             	sub    $0x2c,%esp
  800ce8:	89 c7                	mov    %eax,%edi
  800cea:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800ced:	a1 04 40 80 00       	mov    0x804004,%eax
  800cf2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800cf5:	89 3c 24             	mov    %edi,(%esp)
  800cf8:	e8 6f 0f 00 00       	call   801c6c <pageref>
  800cfd:	89 c6                	mov    %eax,%esi
  800cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 62 0f 00 00       	call   801c6c <pageref>
  800d0a:	39 c6                	cmp    %eax,%esi
  800d0c:	0f 94 c0             	sete   %al
  800d0f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d12:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800d18:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800d1b:	39 cb                	cmp    %ecx,%ebx
  800d1d:	75 08                	jne    800d27 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800d1f:	83 c4 2c             	add    $0x2c,%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800d27:	83 f8 01             	cmp    $0x1,%eax
  800d2a:	75 c1                	jne    800ced <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800d2c:	8b 42 58             	mov    0x58(%edx),%eax
  800d2f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800d36:	00 
  800d37:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3f:	c7 04 24 20 20 80 00 	movl   $0x802020,(%esp)
  800d46:	e8 19 05 00 00       	call   801264 <cprintf>
  800d4b:	eb a0                	jmp    800ced <_pipeisclosed+0xe>

00800d4d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 1c             	sub    $0x1c,%esp
  800d56:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800d59:	89 34 24             	mov    %esi,(%esp)
  800d5c:	e8 a3 f6 ff ff       	call   800404 <fd2data>
  800d61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d63:	bf 00 00 00 00       	mov    $0x0,%edi
  800d68:	eb 3c                	jmp    800da6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800d6a:	89 da                	mov    %ebx,%edx
  800d6c:	89 f0                	mov    %esi,%eax
  800d6e:	e8 6c ff ff ff       	call   800cdf <_pipeisclosed>
  800d73:	85 c0                	test   %eax,%eax
  800d75:	75 38                	jne    800daf <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800d77:	e8 ee f3 ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800d7c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d7f:	8b 13                	mov    (%ebx),%edx
  800d81:	83 c2 20             	add    $0x20,%edx
  800d84:	39 d0                	cmp    %edx,%eax
  800d86:	73 e2                	jae    800d6a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800d88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800d96:	79 05                	jns    800d9d <devpipe_write+0x50>
  800d98:	4a                   	dec    %edx
  800d99:	83 ca e0             	or     $0xffffffe0,%edx
  800d9c:	42                   	inc    %edx
  800d9d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800da1:	40                   	inc    %eax
  800da2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800da5:	47                   	inc    %edi
  800da6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800da9:	75 d1                	jne    800d7c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800dab:	89 f8                	mov    %edi,%eax
  800dad:	eb 05                	jmp    800db4 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800db4:	83 c4 1c             	add    $0x1c,%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 1c             	sub    $0x1c,%esp
  800dc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800dc8:	89 3c 24             	mov    %edi,(%esp)
  800dcb:	e8 34 f6 ff ff       	call   800404 <fd2data>
  800dd0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800dd2:	be 00 00 00 00       	mov    $0x0,%esi
  800dd7:	eb 3a                	jmp    800e13 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800dd9:	85 f6                	test   %esi,%esi
  800ddb:	74 04                	je     800de1 <devpipe_read+0x25>
				return i;
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	eb 40                	jmp    800e21 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800de1:	89 da                	mov    %ebx,%edx
  800de3:	89 f8                	mov    %edi,%eax
  800de5:	e8 f5 fe ff ff       	call   800cdf <_pipeisclosed>
  800dea:	85 c0                	test   %eax,%eax
  800dec:	75 2e                	jne    800e1c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800dee:	e8 77 f3 ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800df3:	8b 03                	mov    (%ebx),%eax
  800df5:	3b 43 04             	cmp    0x4(%ebx),%eax
  800df8:	74 df                	je     800dd9 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800dfa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800dff:	79 05                	jns    800e06 <devpipe_read+0x4a>
  800e01:	48                   	dec    %eax
  800e02:	83 c8 e0             	or     $0xffffffe0,%eax
  800e05:	40                   	inc    %eax
  800e06:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e10:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e12:	46                   	inc    %esi
  800e13:	3b 75 10             	cmp    0x10(%ebp),%esi
  800e16:	75 db                	jne    800df3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800e18:	89 f0                	mov    %esi,%eax
  800e1a:	eb 05                	jmp    800e21 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800e21:	83 c4 1c             	add    $0x1c,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 3c             	sub    $0x3c,%esp
  800e32:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800e35:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e38:	89 04 24             	mov    %eax,(%esp)
  800e3b:	e8 df f5 ff ff       	call   80041f <fd_alloc>
  800e40:	89 c3                	mov    %eax,%ebx
  800e42:	85 c0                	test   %eax,%eax
  800e44:	0f 88 45 01 00 00    	js     800f8f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e4a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e51:	00 
  800e52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e60:	e8 24 f3 ff ff       	call   800189 <sys_page_alloc>
  800e65:	89 c3                	mov    %eax,%ebx
  800e67:	85 c0                	test   %eax,%eax
  800e69:	0f 88 20 01 00 00    	js     800f8f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800e6f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e72:	89 04 24             	mov    %eax,(%esp)
  800e75:	e8 a5 f5 ff ff       	call   80041f <fd_alloc>
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	0f 88 f8 00 00 00    	js     800f7c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e84:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e8b:	00 
  800e8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e9a:	e8 ea f2 ff ff       	call   800189 <sys_page_alloc>
  800e9f:	89 c3                	mov    %eax,%ebx
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	0f 88 d3 00 00 00    	js     800f7c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eac:	89 04 24             	mov    %eax,(%esp)
  800eaf:	e8 50 f5 ff ff       	call   800404 <fd2data>
  800eb4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eb6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ebd:	00 
  800ebe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec9:	e8 bb f2 ff ff       	call   800189 <sys_page_alloc>
  800ece:	89 c3                	mov    %eax,%ebx
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	0f 88 91 00 00 00    	js     800f69 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ed8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800edb:	89 04 24             	mov    %eax,(%esp)
  800ede:	e8 21 f5 ff ff       	call   800404 <fd2data>
  800ee3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800eea:	00 
  800eeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800eef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef6:	00 
  800ef7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f02:	e8 d6 f2 ff ff       	call   8001dd <sys_page_map>
  800f07:	89 c3                	mov    %eax,%ebx
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	78 4c                	js     800f59 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f16:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f1b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800f22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f2b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800f2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f3a:	89 04 24             	mov    %eax,(%esp)
  800f3d:	e8 b2 f4 ff ff       	call   8003f4 <fd2num>
  800f42:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800f44:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f47:	89 04 24             	mov    %eax,(%esp)
  800f4a:	e8 a5 f4 ff ff       	call   8003f4 <fd2num>
  800f4f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800f52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f57:	eb 36                	jmp    800f8f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800f59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f64:	e8 c7 f2 ff ff       	call   800230 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800f69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f77:	e8 b4 f2 ff ff       	call   800230 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  800f7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8a:	e8 a1 f2 ff ff       	call   800230 <sys_page_unmap>
    err:
	return r;
}
  800f8f:	89 d8                	mov    %ebx,%eax
  800f91:	83 c4 3c             	add    $0x3c,%esp
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	89 04 24             	mov    %eax,(%esp)
  800fac:	e8 c1 f4 ff ff       	call   800472 <fd_lookup>
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	78 15                	js     800fca <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb8:	89 04 24             	mov    %eax,(%esp)
  800fbb:	e8 44 f4 ff ff       	call   800404 <fd2data>
	return _pipeisclosed(fd, p);
  800fc0:	89 c2                	mov    %eax,%edx
  800fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc5:	e8 15 fd ff ff       	call   800cdf <_pipeisclosed>
}
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800fdc:	c7 44 24 04 38 20 80 	movl   $0x802038,0x4(%esp)
  800fe3:	00 
  800fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe7:	89 04 24             	mov    %eax,(%esp)
  800fea:	e8 40 08 00 00       	call   80182f <strcpy>
	return 0;
}
  800fef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801002:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801007:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80100d:	eb 30                	jmp    80103f <devcons_write+0x49>
		m = n - tot;
  80100f:	8b 75 10             	mov    0x10(%ebp),%esi
  801012:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801014:	83 fe 7f             	cmp    $0x7f,%esi
  801017:	76 05                	jbe    80101e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801019:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80101e:	89 74 24 08          	mov    %esi,0x8(%esp)
  801022:	03 45 0c             	add    0xc(%ebp),%eax
  801025:	89 44 24 04          	mov    %eax,0x4(%esp)
  801029:	89 3c 24             	mov    %edi,(%esp)
  80102c:	e8 77 09 00 00       	call   8019a8 <memmove>
		sys_cputs(buf, m);
  801031:	89 74 24 04          	mov    %esi,0x4(%esp)
  801035:	89 3c 24             	mov    %edi,(%esp)
  801038:	e8 7f f0 ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80103d:	01 f3                	add    %esi,%ebx
  80103f:	89 d8                	mov    %ebx,%eax
  801041:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801044:	72 c9                	jb     80100f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801046:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801057:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80105b:	75 07                	jne    801064 <devcons_read+0x13>
  80105d:	eb 25                	jmp    801084 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80105f:	e8 06 f1 ff ff       	call   80016a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801064:	e8 71 f0 ff ff       	call   8000da <sys_cgetc>
  801069:	85 c0                	test   %eax,%eax
  80106b:	74 f2                	je     80105f <devcons_read+0xe>
  80106d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 1d                	js     801090 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801073:	83 f8 04             	cmp    $0x4,%eax
  801076:	74 13                	je     80108b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107b:	88 10                	mov    %dl,(%eax)
	return 1;
  80107d:	b8 01 00 00 00       	mov    $0x1,%eax
  801082:	eb 0c                	jmp    801090 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801084:	b8 00 00 00 00       	mov    $0x0,%eax
  801089:	eb 05                	jmp    801090 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80108b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80109e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8010a5:	00 
  8010a6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010a9:	89 04 24             	mov    %eax,(%esp)
  8010ac:	e8 0b f0 ff ff       	call   8000bc <sys_cputs>
}
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    

008010b3 <getchar>:

int
getchar(void)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8010b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8010c0:	00 
  8010c1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8010c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cf:	e8 3a f6 ff ff       	call   80070e <read>
	if (r < 0)
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 0f                	js     8010e7 <getchar+0x34>
		return r;
	if (r < 1)
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	7e 06                	jle    8010e2 <getchar+0x2f>
		return -E_EOF;
	return c;
  8010dc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8010e0:	eb 05                	jmp    8010e7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8010e2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	89 04 24             	mov    %eax,(%esp)
  8010fc:	e8 71 f3 ff ff       	call   800472 <fd_lookup>
  801101:	85 c0                	test   %eax,%eax
  801103:	78 11                	js     801116 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801108:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80110e:	39 10                	cmp    %edx,(%eax)
  801110:	0f 94 c0             	sete   %al
  801113:	0f b6 c0             	movzbl %al,%eax
}
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <opencons>:

int
opencons(void)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80111e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801121:	89 04 24             	mov    %eax,(%esp)
  801124:	e8 f6 f2 ff ff       	call   80041f <fd_alloc>
  801129:	85 c0                	test   %eax,%eax
  80112b:	78 3c                	js     801169 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80112d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801134:	00 
  801135:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801138:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801143:	e8 41 f0 ff ff       	call   800189 <sys_page_alloc>
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 1d                	js     801169 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80114c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801152:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801155:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801161:	89 04 24             	mov    %eax,(%esp)
  801164:	e8 8b f2 ff ff       	call   8003f4 <fd2num>
}
  801169:	c9                   	leave  
  80116a:	c3                   	ret    
	...

0080116c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801174:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801177:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80117d:	e8 c9 ef ff ff       	call   80014b <sys_getenvid>
  801182:	8b 55 0c             	mov    0xc(%ebp),%edx
  801185:	89 54 24 10          	mov    %edx,0x10(%esp)
  801189:	8b 55 08             	mov    0x8(%ebp),%edx
  80118c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801190:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801194:	89 44 24 04          	mov    %eax,0x4(%esp)
  801198:	c7 04 24 44 20 80 00 	movl   $0x802044,(%esp)
  80119f:	e8 c0 00 00 00       	call   801264 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ab:	89 04 24             	mov    %eax,(%esp)
  8011ae:	e8 50 00 00 00       	call   801203 <vcprintf>
	cprintf("\n");
  8011b3:	c7 04 24 31 20 80 00 	movl   $0x802031,(%esp)
  8011ba:	e8 a5 00 00 00       	call   801264 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011bf:	cc                   	int3   
  8011c0:	eb fd                	jmp    8011bf <_panic+0x53>
	...

008011c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 14             	sub    $0x14,%esp
  8011cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8011ce:	8b 03                	mov    (%ebx),%eax
  8011d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8011d7:	40                   	inc    %eax
  8011d8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8011da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8011df:	75 19                	jne    8011fa <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8011e1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8011e8:	00 
  8011e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8011ec:	89 04 24             	mov    %eax,(%esp)
  8011ef:	e8 c8 ee ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  8011f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8011fa:	ff 43 04             	incl   0x4(%ebx)
}
  8011fd:	83 c4 14             	add    $0x14,%esp
  801200:	5b                   	pop    %ebx
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80120c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801213:	00 00 00 
	b.cnt = 0;
  801216:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80121d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801220:	8b 45 0c             	mov    0xc(%ebp),%eax
  801223:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801227:	8b 45 08             	mov    0x8(%ebp),%eax
  80122a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80122e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801234:	89 44 24 04          	mov    %eax,0x4(%esp)
  801238:	c7 04 24 c4 11 80 00 	movl   $0x8011c4,(%esp)
  80123f:	e8 82 01 00 00       	call   8013c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801244:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80124a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801254:	89 04 24             	mov    %eax,(%esp)
  801257:	e8 60 ee ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  80125c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80126a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80126d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	89 04 24             	mov    %eax,(%esp)
  801277:	e8 87 ff ff ff       	call   801203 <vcprintf>
	va_end(ap);

	return cnt;
}
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    
	...

00801280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	57                   	push   %edi
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 3c             	sub    $0x3c,%esp
  801289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80128c:	89 d7                	mov    %edx,%edi
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801294:	8b 45 0c             	mov    0xc(%ebp),%eax
  801297:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80129a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80129d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	75 08                	jne    8012ac <printnum+0x2c>
  8012a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8012aa:	77 57                	ja     801303 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8012ac:	89 74 24 10          	mov    %esi,0x10(%esp)
  8012b0:	4b                   	dec    %ebx
  8012b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012bc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8012c0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8012c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012cb:	00 
  8012cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012cf:	89 04 24             	mov    %eax,(%esp)
  8012d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d9:	e8 d2 09 00 00       	call   801cb0 <__udivdi3>
  8012de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012e2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012ed:	89 fa                	mov    %edi,%edx
  8012ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f2:	e8 89 ff ff ff       	call   801280 <printnum>
  8012f7:	eb 0f                	jmp    801308 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8012f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012fd:	89 34 24             	mov    %esi,(%esp)
  801300:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801303:	4b                   	dec    %ebx
  801304:	85 db                	test   %ebx,%ebx
  801306:	7f f1                	jg     8012f9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801308:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80130c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801310:	8b 45 10             	mov    0x10(%ebp),%eax
  801313:	89 44 24 08          	mov    %eax,0x8(%esp)
  801317:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80131e:	00 
  80131f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801322:	89 04 24             	mov    %eax,(%esp)
  801325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	e8 9f 0a 00 00       	call   801dd0 <__umoddi3>
  801331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801335:	0f be 80 67 20 80 00 	movsbl 0x802067(%eax),%eax
  80133c:	89 04 24             	mov    %eax,(%esp)
  80133f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801342:	83 c4 3c             	add    $0x3c,%esp
  801345:	5b                   	pop    %ebx
  801346:	5e                   	pop    %esi
  801347:	5f                   	pop    %edi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80134d:	83 fa 01             	cmp    $0x1,%edx
  801350:	7e 0e                	jle    801360 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801352:	8b 10                	mov    (%eax),%edx
  801354:	8d 4a 08             	lea    0x8(%edx),%ecx
  801357:	89 08                	mov    %ecx,(%eax)
  801359:	8b 02                	mov    (%edx),%eax
  80135b:	8b 52 04             	mov    0x4(%edx),%edx
  80135e:	eb 22                	jmp    801382 <getuint+0x38>
	else if (lflag)
  801360:	85 d2                	test   %edx,%edx
  801362:	74 10                	je     801374 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801364:	8b 10                	mov    (%eax),%edx
  801366:	8d 4a 04             	lea    0x4(%edx),%ecx
  801369:	89 08                	mov    %ecx,(%eax)
  80136b:	8b 02                	mov    (%edx),%eax
  80136d:	ba 00 00 00 00       	mov    $0x0,%edx
  801372:	eb 0e                	jmp    801382 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801374:	8b 10                	mov    (%eax),%edx
  801376:	8d 4a 04             	lea    0x4(%edx),%ecx
  801379:	89 08                	mov    %ecx,(%eax)
  80137b:	8b 02                	mov    (%edx),%eax
  80137d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80138a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80138d:	8b 10                	mov    (%eax),%edx
  80138f:	3b 50 04             	cmp    0x4(%eax),%edx
  801392:	73 08                	jae    80139c <sprintputch+0x18>
		*b->buf++ = ch;
  801394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801397:	88 0a                	mov    %cl,(%edx)
  801399:	42                   	inc    %edx
  80139a:	89 10                	mov    %edx,(%eax)
}
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8013a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8013a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 02 00 00 00       	call   8013c6 <vprintfmt>
	va_end(ap);
}
  8013c4:	c9                   	leave  
  8013c5:	c3                   	ret    

008013c6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	57                   	push   %edi
  8013ca:	56                   	push   %esi
  8013cb:	53                   	push   %ebx
  8013cc:	83 ec 4c             	sub    $0x4c,%esp
  8013cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013d2:	8b 75 10             	mov    0x10(%ebp),%esi
  8013d5:	eb 12                	jmp    8013e9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	0f 84 8b 03 00 00    	je     80176a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8013df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013e3:	89 04 24             	mov    %eax,(%esp)
  8013e6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8013e9:	0f b6 06             	movzbl (%esi),%eax
  8013ec:	46                   	inc    %esi
  8013ed:	83 f8 25             	cmp    $0x25,%eax
  8013f0:	75 e5                	jne    8013d7 <vprintfmt+0x11>
  8013f2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8013f6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8013fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801402:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80140e:	eb 26                	jmp    801436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801410:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801413:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801417:	eb 1d                	jmp    801436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801419:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80141c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801420:	eb 14                	jmp    801436 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801422:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801425:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80142c:	eb 08                	jmp    801436 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80142e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801431:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801436:	0f b6 06             	movzbl (%esi),%eax
  801439:	8d 56 01             	lea    0x1(%esi),%edx
  80143c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80143f:	8a 16                	mov    (%esi),%dl
  801441:	83 ea 23             	sub    $0x23,%edx
  801444:	80 fa 55             	cmp    $0x55,%dl
  801447:	0f 87 01 03 00 00    	ja     80174e <vprintfmt+0x388>
  80144d:	0f b6 d2             	movzbl %dl,%edx
  801450:	ff 24 95 a0 21 80 00 	jmp    *0x8021a0(,%edx,4)
  801457:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80145a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80145f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801462:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801466:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801469:	8d 50 d0             	lea    -0x30(%eax),%edx
  80146c:	83 fa 09             	cmp    $0x9,%edx
  80146f:	77 2a                	ja     80149b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801471:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801472:	eb eb                	jmp    80145f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801474:	8b 45 14             	mov    0x14(%ebp),%eax
  801477:	8d 50 04             	lea    0x4(%eax),%edx
  80147a:	89 55 14             	mov    %edx,0x14(%ebp)
  80147d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80147f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801482:	eb 17                	jmp    80149b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801484:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801488:	78 98                	js     801422 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80148a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80148d:	eb a7                	jmp    801436 <vprintfmt+0x70>
  80148f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801492:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801499:	eb 9b                	jmp    801436 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80149b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80149f:	79 95                	jns    801436 <vprintfmt+0x70>
  8014a1:	eb 8b                	jmp    80142e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8014a3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8014a7:	eb 8d                	jmp    801436 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8014a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ac:	8d 50 04             	lea    0x4(%eax),%edx
  8014af:	89 55 14             	mov    %edx,0x14(%ebp)
  8014b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014b6:	8b 00                	mov    (%eax),%eax
  8014b8:	89 04 24             	mov    %eax,(%esp)
  8014bb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014be:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8014c1:	e9 23 ff ff ff       	jmp    8013e9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8014c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c9:	8d 50 04             	lea    0x4(%eax),%edx
  8014cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8014cf:	8b 00                	mov    (%eax),%eax
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	79 02                	jns    8014d7 <vprintfmt+0x111>
  8014d5:	f7 d8                	neg    %eax
  8014d7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8014d9:	83 f8 0f             	cmp    $0xf,%eax
  8014dc:	7f 0b                	jg     8014e9 <vprintfmt+0x123>
  8014de:	8b 04 85 00 23 80 00 	mov    0x802300(,%eax,4),%eax
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	75 23                	jne    80150c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8014e9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014ed:	c7 44 24 08 7f 20 80 	movl   $0x80207f,0x8(%esp)
  8014f4:	00 
  8014f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fc:	89 04 24             	mov    %eax,(%esp)
  8014ff:	e8 9a fe ff ff       	call   80139e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801504:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801507:	e9 dd fe ff ff       	jmp    8013e9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80150c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801510:	c7 44 24 08 0a 20 80 	movl   $0x80200a,0x8(%esp)
  801517:	00 
  801518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80151c:	8b 55 08             	mov    0x8(%ebp),%edx
  80151f:	89 14 24             	mov    %edx,(%esp)
  801522:	e8 77 fe ff ff       	call   80139e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801527:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80152a:	e9 ba fe ff ff       	jmp    8013e9 <vprintfmt+0x23>
  80152f:	89 f9                	mov    %edi,%ecx
  801531:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801534:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801537:	8b 45 14             	mov    0x14(%ebp),%eax
  80153a:	8d 50 04             	lea    0x4(%eax),%edx
  80153d:	89 55 14             	mov    %edx,0x14(%ebp)
  801540:	8b 30                	mov    (%eax),%esi
  801542:	85 f6                	test   %esi,%esi
  801544:	75 05                	jne    80154b <vprintfmt+0x185>
				p = "(null)";
  801546:	be 78 20 80 00       	mov    $0x802078,%esi
			if (width > 0 && padc != '-')
  80154b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80154f:	0f 8e 84 00 00 00    	jle    8015d9 <vprintfmt+0x213>
  801555:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801559:	74 7e                	je     8015d9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80155b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80155f:	89 34 24             	mov    %esi,(%esp)
  801562:	e8 ab 02 00 00       	call   801812 <strnlen>
  801567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80156a:	29 c2                	sub    %eax,%edx
  80156c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80156f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801573:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801576:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801579:	89 de                	mov    %ebx,%esi
  80157b:	89 d3                	mov    %edx,%ebx
  80157d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80157f:	eb 0b                	jmp    80158c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801581:	89 74 24 04          	mov    %esi,0x4(%esp)
  801585:	89 3c 24             	mov    %edi,(%esp)
  801588:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80158b:	4b                   	dec    %ebx
  80158c:	85 db                	test   %ebx,%ebx
  80158e:	7f f1                	jg     801581 <vprintfmt+0x1bb>
  801590:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801593:	89 f3                	mov    %esi,%ebx
  801595:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801598:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159b:	85 c0                	test   %eax,%eax
  80159d:	79 05                	jns    8015a4 <vprintfmt+0x1de>
  80159f:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a7:	29 c2                	sub    %eax,%edx
  8015a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015ac:	eb 2b                	jmp    8015d9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8015ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015b2:	74 18                	je     8015cc <vprintfmt+0x206>
  8015b4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8015b7:	83 fa 5e             	cmp    $0x5e,%edx
  8015ba:	76 10                	jbe    8015cc <vprintfmt+0x206>
					putch('?', putdat);
  8015bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8015c7:	ff 55 08             	call   *0x8(%ebp)
  8015ca:	eb 0a                	jmp    8015d6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8015cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d0:	89 04 24             	mov    %eax,(%esp)
  8015d3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8015d6:	ff 4d e4             	decl   -0x1c(%ebp)
  8015d9:	0f be 06             	movsbl (%esi),%eax
  8015dc:	46                   	inc    %esi
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	74 21                	je     801602 <vprintfmt+0x23c>
  8015e1:	85 ff                	test   %edi,%edi
  8015e3:	78 c9                	js     8015ae <vprintfmt+0x1e8>
  8015e5:	4f                   	dec    %edi
  8015e6:	79 c6                	jns    8015ae <vprintfmt+0x1e8>
  8015e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015eb:	89 de                	mov    %ebx,%esi
  8015ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8015f0:	eb 18                	jmp    80160a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8015f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8015fd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8015ff:	4b                   	dec    %ebx
  801600:	eb 08                	jmp    80160a <vprintfmt+0x244>
  801602:	8b 7d 08             	mov    0x8(%ebp),%edi
  801605:	89 de                	mov    %ebx,%esi
  801607:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80160a:	85 db                	test   %ebx,%ebx
  80160c:	7f e4                	jg     8015f2 <vprintfmt+0x22c>
  80160e:	89 7d 08             	mov    %edi,0x8(%ebp)
  801611:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801613:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801616:	e9 ce fd ff ff       	jmp    8013e9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80161b:	83 f9 01             	cmp    $0x1,%ecx
  80161e:	7e 10                	jle    801630 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801620:	8b 45 14             	mov    0x14(%ebp),%eax
  801623:	8d 50 08             	lea    0x8(%eax),%edx
  801626:	89 55 14             	mov    %edx,0x14(%ebp)
  801629:	8b 30                	mov    (%eax),%esi
  80162b:	8b 78 04             	mov    0x4(%eax),%edi
  80162e:	eb 26                	jmp    801656 <vprintfmt+0x290>
	else if (lflag)
  801630:	85 c9                	test   %ecx,%ecx
  801632:	74 12                	je     801646 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801634:	8b 45 14             	mov    0x14(%ebp),%eax
  801637:	8d 50 04             	lea    0x4(%eax),%edx
  80163a:	89 55 14             	mov    %edx,0x14(%ebp)
  80163d:	8b 30                	mov    (%eax),%esi
  80163f:	89 f7                	mov    %esi,%edi
  801641:	c1 ff 1f             	sar    $0x1f,%edi
  801644:	eb 10                	jmp    801656 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801646:	8b 45 14             	mov    0x14(%ebp),%eax
  801649:	8d 50 04             	lea    0x4(%eax),%edx
  80164c:	89 55 14             	mov    %edx,0x14(%ebp)
  80164f:	8b 30                	mov    (%eax),%esi
  801651:	89 f7                	mov    %esi,%edi
  801653:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801656:	85 ff                	test   %edi,%edi
  801658:	78 0a                	js     801664 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80165a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80165f:	e9 ac 00 00 00       	jmp    801710 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801668:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80166f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801672:	f7 de                	neg    %esi
  801674:	83 d7 00             	adc    $0x0,%edi
  801677:	f7 df                	neg    %edi
			}
			base = 10;
  801679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80167e:	e9 8d 00 00 00       	jmp    801710 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801683:	89 ca                	mov    %ecx,%edx
  801685:	8d 45 14             	lea    0x14(%ebp),%eax
  801688:	e8 bd fc ff ff       	call   80134a <getuint>
  80168d:	89 c6                	mov    %eax,%esi
  80168f:	89 d7                	mov    %edx,%edi
			base = 10;
  801691:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801696:	eb 78                	jmp    801710 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801698:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80169c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016a3:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016aa:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016b1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8016b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8016bf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8016c5:	e9 1f fd ff ff       	jmp    8013e9 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8016ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8016d5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8016d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016dc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8016e3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8016e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e9:	8d 50 04             	lea    0x4(%eax),%edx
  8016ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8016ef:	8b 30                	mov    (%eax),%esi
  8016f1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8016f6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8016fb:	eb 13                	jmp    801710 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8016fd:	89 ca                	mov    %ecx,%edx
  8016ff:	8d 45 14             	lea    0x14(%ebp),%eax
  801702:	e8 43 fc ff ff       	call   80134a <getuint>
  801707:	89 c6                	mov    %eax,%esi
  801709:	89 d7                	mov    %edx,%edi
			base = 16;
  80170b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801710:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801714:	89 54 24 10          	mov    %edx,0x10(%esp)
  801718:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80171b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80171f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801723:	89 34 24             	mov    %esi,(%esp)
  801726:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80172a:	89 da                	mov    %ebx,%edx
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	e8 4c fb ff ff       	call   801280 <printnum>
			break;
  801734:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801737:	e9 ad fc ff ff       	jmp    8013e9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80173c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801740:	89 04 24             	mov    %eax,(%esp)
  801743:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801746:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801749:	e9 9b fc ff ff       	jmp    8013e9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80174e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801752:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801759:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80175c:	eb 01                	jmp    80175f <vprintfmt+0x399>
  80175e:	4e                   	dec    %esi
  80175f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801763:	75 f9                	jne    80175e <vprintfmt+0x398>
  801765:	e9 7f fc ff ff       	jmp    8013e9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80176a:	83 c4 4c             	add    $0x4c,%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5f                   	pop    %edi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	83 ec 28             	sub    $0x28,%esp
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80177e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801781:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801785:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801788:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80178f:	85 c0                	test   %eax,%eax
  801791:	74 30                	je     8017c3 <vsnprintf+0x51>
  801793:	85 d2                	test   %edx,%edx
  801795:	7e 33                	jle    8017ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801797:	8b 45 14             	mov    0x14(%ebp),%eax
  80179a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80179e:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8017a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ac:	c7 04 24 84 13 80 00 	movl   $0x801384,(%esp)
  8017b3:	e8 0e fc ff ff       	call   8013c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8017b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8017bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c1:	eb 0c                	jmp    8017cf <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8017c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c8:	eb 05                	jmp    8017cf <vsnprintf+0x5d>
  8017ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    

008017d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8017d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8017da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017de:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 7b ff ff ff       	call   801772 <vsnprintf>
	va_end(ap);

	return rc;
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    
  8017f9:	00 00                	add    %al,(%eax)
	...

008017fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
  801807:	eb 01                	jmp    80180a <strlen+0xe>
		n++;
  801809:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80180a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80180e:	75 f9                	jne    801809 <strlen+0xd>
		n++;
	return n;
}
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801818:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
  801820:	eb 01                	jmp    801823 <strnlen+0x11>
		n++;
  801822:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801823:	39 d0                	cmp    %edx,%eax
  801825:	74 06                	je     80182d <strnlen+0x1b>
  801827:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80182b:	75 f5                	jne    801822 <strnlen+0x10>
		n++;
	return n;
}
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	53                   	push   %ebx
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801839:	ba 00 00 00 00       	mov    $0x0,%edx
  80183e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801841:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801844:	42                   	inc    %edx
  801845:	84 c9                	test   %cl,%cl
  801847:	75 f5                	jne    80183e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801849:	5b                   	pop    %ebx
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801856:	89 1c 24             	mov    %ebx,(%esp)
  801859:	e8 9e ff ff ff       	call   8017fc <strlen>
	strcpy(dst + len, src);
  80185e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801861:	89 54 24 04          	mov    %edx,0x4(%esp)
  801865:	01 d8                	add    %ebx,%eax
  801867:	89 04 24             	mov    %eax,(%esp)
  80186a:	e8 c0 ff ff ff       	call   80182f <strcpy>
	return dst;
}
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	83 c4 08             	add    $0x8,%esp
  801874:	5b                   	pop    %ebx
  801875:	5d                   	pop    %ebp
  801876:	c3                   	ret    

00801877 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801877:	55                   	push   %ebp
  801878:	89 e5                	mov    %esp,%ebp
  80187a:	56                   	push   %esi
  80187b:	53                   	push   %ebx
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801882:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801885:	b9 00 00 00 00       	mov    $0x0,%ecx
  80188a:	eb 0c                	jmp    801898 <strncpy+0x21>
		*dst++ = *src;
  80188c:	8a 1a                	mov    (%edx),%bl
  80188e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801891:	80 3a 01             	cmpb   $0x1,(%edx)
  801894:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801897:	41                   	inc    %ecx
  801898:	39 f1                	cmp    %esi,%ecx
  80189a:	75 f0                	jne    80188c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80189c:	5b                   	pop    %ebx
  80189d:	5e                   	pop    %esi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	56                   	push   %esi
  8018a4:	53                   	push   %ebx
  8018a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8018a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ab:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018ae:	85 d2                	test   %edx,%edx
  8018b0:	75 0a                	jne    8018bc <strlcpy+0x1c>
  8018b2:	89 f0                	mov    %esi,%eax
  8018b4:	eb 1a                	jmp    8018d0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8018b6:	88 18                	mov    %bl,(%eax)
  8018b8:	40                   	inc    %eax
  8018b9:	41                   	inc    %ecx
  8018ba:	eb 02                	jmp    8018be <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8018bc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8018be:	4a                   	dec    %edx
  8018bf:	74 0a                	je     8018cb <strlcpy+0x2b>
  8018c1:	8a 19                	mov    (%ecx),%bl
  8018c3:	84 db                	test   %bl,%bl
  8018c5:	75 ef                	jne    8018b6 <strlcpy+0x16>
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	eb 02                	jmp    8018cd <strlcpy+0x2d>
  8018cb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8018cd:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8018d0:	29 f0                	sub    %esi,%eax
}
  8018d2:	5b                   	pop    %ebx
  8018d3:	5e                   	pop    %esi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8018df:	eb 02                	jmp    8018e3 <strcmp+0xd>
		p++, q++;
  8018e1:	41                   	inc    %ecx
  8018e2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8018e3:	8a 01                	mov    (%ecx),%al
  8018e5:	84 c0                	test   %al,%al
  8018e7:	74 04                	je     8018ed <strcmp+0x17>
  8018e9:	3a 02                	cmp    (%edx),%al
  8018eb:	74 f4                	je     8018e1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8018ed:	0f b6 c0             	movzbl %al,%eax
  8018f0:	0f b6 12             	movzbl (%edx),%edx
  8018f3:	29 d0                	sub    %edx,%eax
}
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801901:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801904:	eb 03                	jmp    801909 <strncmp+0x12>
		n--, p++, q++;
  801906:	4a                   	dec    %edx
  801907:	40                   	inc    %eax
  801908:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801909:	85 d2                	test   %edx,%edx
  80190b:	74 14                	je     801921 <strncmp+0x2a>
  80190d:	8a 18                	mov    (%eax),%bl
  80190f:	84 db                	test   %bl,%bl
  801911:	74 04                	je     801917 <strncmp+0x20>
  801913:	3a 19                	cmp    (%ecx),%bl
  801915:	74 ef                	je     801906 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801917:	0f b6 00             	movzbl (%eax),%eax
  80191a:	0f b6 11             	movzbl (%ecx),%edx
  80191d:	29 d0                	sub    %edx,%eax
  80191f:	eb 05                	jmp    801926 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801926:	5b                   	pop    %ebx
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	8b 45 08             	mov    0x8(%ebp),%eax
  80192f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801932:	eb 05                	jmp    801939 <strchr+0x10>
		if (*s == c)
  801934:	38 ca                	cmp    %cl,%dl
  801936:	74 0c                	je     801944 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801938:	40                   	inc    %eax
  801939:	8a 10                	mov    (%eax),%dl
  80193b:	84 d2                	test   %dl,%dl
  80193d:	75 f5                	jne    801934 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80193f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80194f:	eb 05                	jmp    801956 <strfind+0x10>
		if (*s == c)
  801951:	38 ca                	cmp    %cl,%dl
  801953:	74 07                	je     80195c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801955:	40                   	inc    %eax
  801956:	8a 10                	mov    (%eax),%dl
  801958:	84 d2                	test   %dl,%dl
  80195a:	75 f5                	jne    801951 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	57                   	push   %edi
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	8b 7d 08             	mov    0x8(%ebp),%edi
  801967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80196d:	85 c9                	test   %ecx,%ecx
  80196f:	74 30                	je     8019a1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801971:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801977:	75 25                	jne    80199e <memset+0x40>
  801979:	f6 c1 03             	test   $0x3,%cl
  80197c:	75 20                	jne    80199e <memset+0x40>
		c &= 0xFF;
  80197e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801981:	89 d3                	mov    %edx,%ebx
  801983:	c1 e3 08             	shl    $0x8,%ebx
  801986:	89 d6                	mov    %edx,%esi
  801988:	c1 e6 18             	shl    $0x18,%esi
  80198b:	89 d0                	mov    %edx,%eax
  80198d:	c1 e0 10             	shl    $0x10,%eax
  801990:	09 f0                	or     %esi,%eax
  801992:	09 d0                	or     %edx,%eax
  801994:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801996:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801999:	fc                   	cld    
  80199a:	f3 ab                	rep stos %eax,%es:(%edi)
  80199c:	eb 03                	jmp    8019a1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80199e:	fc                   	cld    
  80199f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8019a1:	89 f8                	mov    %edi,%eax
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	57                   	push   %edi
  8019ac:	56                   	push   %esi
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8019b6:	39 c6                	cmp    %eax,%esi
  8019b8:	73 34                	jae    8019ee <memmove+0x46>
  8019ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8019bd:	39 d0                	cmp    %edx,%eax
  8019bf:	73 2d                	jae    8019ee <memmove+0x46>
		s += n;
		d += n;
  8019c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019c4:	f6 c2 03             	test   $0x3,%dl
  8019c7:	75 1b                	jne    8019e4 <memmove+0x3c>
  8019c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019cf:	75 13                	jne    8019e4 <memmove+0x3c>
  8019d1:	f6 c1 03             	test   $0x3,%cl
  8019d4:	75 0e                	jne    8019e4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8019d6:	83 ef 04             	sub    $0x4,%edi
  8019d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8019dc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8019df:	fd                   	std    
  8019e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8019e2:	eb 07                	jmp    8019eb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8019e4:	4f                   	dec    %edi
  8019e5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8019e8:	fd                   	std    
  8019e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8019eb:	fc                   	cld    
  8019ec:	eb 20                	jmp    801a0e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8019ee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8019f4:	75 13                	jne    801a09 <memmove+0x61>
  8019f6:	a8 03                	test   $0x3,%al
  8019f8:	75 0f                	jne    801a09 <memmove+0x61>
  8019fa:	f6 c1 03             	test   $0x3,%cl
  8019fd:	75 0a                	jne    801a09 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8019ff:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a02:	89 c7                	mov    %eax,%edi
  801a04:	fc                   	cld    
  801a05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a07:	eb 05                	jmp    801a0e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a09:	89 c7                	mov    %eax,%edi
  801a0b:	fc                   	cld    
  801a0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a0e:	5e                   	pop    %esi
  801a0f:	5f                   	pop    %edi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a18:	8b 45 10             	mov    0x10(%ebp),%eax
  801a1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a26:	8b 45 08             	mov    0x8(%ebp),%eax
  801a29:	89 04 24             	mov    %eax,(%esp)
  801a2c:	e8 77 ff ff ff       	call   8019a8 <memmove>
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	57                   	push   %edi
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	eb 16                	jmp    801a5f <memcmp+0x2c>
		if (*s1 != *s2)
  801a49:	8a 04 17             	mov    (%edi,%edx,1),%al
  801a4c:	42                   	inc    %edx
  801a4d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801a51:	38 c8                	cmp    %cl,%al
  801a53:	74 0a                	je     801a5f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801a55:	0f b6 c0             	movzbl %al,%eax
  801a58:	0f b6 c9             	movzbl %cl,%ecx
  801a5b:	29 c8                	sub    %ecx,%eax
  801a5d:	eb 09                	jmp    801a68 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801a5f:	39 da                	cmp    %ebx,%edx
  801a61:	75 e6                	jne    801a49 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5f                   	pop    %edi
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    

00801a6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	8b 45 08             	mov    0x8(%ebp),%eax
  801a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801a7b:	eb 05                	jmp    801a82 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801a7d:	38 08                	cmp    %cl,(%eax)
  801a7f:	74 05                	je     801a86 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801a81:	40                   	inc    %eax
  801a82:	39 d0                	cmp    %edx,%eax
  801a84:	72 f7                	jb     801a7d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	57                   	push   %edi
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  801a91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a94:	eb 01                	jmp    801a97 <strtol+0xf>
		s++;
  801a96:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801a97:	8a 02                	mov    (%edx),%al
  801a99:	3c 20                	cmp    $0x20,%al
  801a9b:	74 f9                	je     801a96 <strtol+0xe>
  801a9d:	3c 09                	cmp    $0x9,%al
  801a9f:	74 f5                	je     801a96 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801aa1:	3c 2b                	cmp    $0x2b,%al
  801aa3:	75 08                	jne    801aad <strtol+0x25>
		s++;
  801aa5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801aa6:	bf 00 00 00 00       	mov    $0x0,%edi
  801aab:	eb 13                	jmp    801ac0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801aad:	3c 2d                	cmp    $0x2d,%al
  801aaf:	75 0a                	jne    801abb <strtol+0x33>
		s++, neg = 1;
  801ab1:	8d 52 01             	lea    0x1(%edx),%edx
  801ab4:	bf 01 00 00 00       	mov    $0x1,%edi
  801ab9:	eb 05                	jmp    801ac0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801abb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ac0:	85 db                	test   %ebx,%ebx
  801ac2:	74 05                	je     801ac9 <strtol+0x41>
  801ac4:	83 fb 10             	cmp    $0x10,%ebx
  801ac7:	75 28                	jne    801af1 <strtol+0x69>
  801ac9:	8a 02                	mov    (%edx),%al
  801acb:	3c 30                	cmp    $0x30,%al
  801acd:	75 10                	jne    801adf <strtol+0x57>
  801acf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801ad3:	75 0a                	jne    801adf <strtol+0x57>
		s += 2, base = 16;
  801ad5:	83 c2 02             	add    $0x2,%edx
  801ad8:	bb 10 00 00 00       	mov    $0x10,%ebx
  801add:	eb 12                	jmp    801af1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801adf:	85 db                	test   %ebx,%ebx
  801ae1:	75 0e                	jne    801af1 <strtol+0x69>
  801ae3:	3c 30                	cmp    $0x30,%al
  801ae5:	75 05                	jne    801aec <strtol+0x64>
		s++, base = 8;
  801ae7:	42                   	inc    %edx
  801ae8:	b3 08                	mov    $0x8,%bl
  801aea:	eb 05                	jmp    801af1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801aec:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801af1:	b8 00 00 00 00       	mov    $0x0,%eax
  801af6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801af8:	8a 0a                	mov    (%edx),%cl
  801afa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801afd:	80 fb 09             	cmp    $0x9,%bl
  801b00:	77 08                	ja     801b0a <strtol+0x82>
			dig = *s - '0';
  801b02:	0f be c9             	movsbl %cl,%ecx
  801b05:	83 e9 30             	sub    $0x30,%ecx
  801b08:	eb 1e                	jmp    801b28 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b0a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b0d:	80 fb 19             	cmp    $0x19,%bl
  801b10:	77 08                	ja     801b1a <strtol+0x92>
			dig = *s - 'a' + 10;
  801b12:	0f be c9             	movsbl %cl,%ecx
  801b15:	83 e9 57             	sub    $0x57,%ecx
  801b18:	eb 0e                	jmp    801b28 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b1a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b1d:	80 fb 19             	cmp    $0x19,%bl
  801b20:	77 12                	ja     801b34 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b22:	0f be c9             	movsbl %cl,%ecx
  801b25:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b28:	39 f1                	cmp    %esi,%ecx
  801b2a:	7d 0c                	jge    801b38 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b2c:	42                   	inc    %edx
  801b2d:	0f af c6             	imul   %esi,%eax
  801b30:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b32:	eb c4                	jmp    801af8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801b34:	89 c1                	mov    %eax,%ecx
  801b36:	eb 02                	jmp    801b3a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801b38:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801b3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b3e:	74 05                	je     801b45 <strtol+0xbd>
		*endptr = (char *) s;
  801b40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b43:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801b45:	85 ff                	test   %edi,%edi
  801b47:	74 04                	je     801b4d <strtol+0xc5>
  801b49:	89 c8                	mov    %ecx,%eax
  801b4b:	f7 d8                	neg    %eax
}
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5f                   	pop    %edi
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    
	...

00801b54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	83 ec 10             	sub    $0x10,%esp
  801b5c:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801b65:	85 c0                	test   %eax,%eax
  801b67:	75 05                	jne    801b6e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801b69:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801b6e:	89 04 24             	mov    %eax,(%esp)
  801b71:	e8 29 e8 ff ff       	call   80039f <sys_ipc_recv>
	if (!err) {
  801b76:	85 c0                	test   %eax,%eax
  801b78:	75 26                	jne    801ba0 <ipc_recv+0x4c>
		if (from_env_store) {
  801b7a:	85 f6                	test   %esi,%esi
  801b7c:	74 0a                	je     801b88 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801b7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b83:	8b 40 74             	mov    0x74(%eax),%eax
  801b86:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801b88:	85 db                	test   %ebx,%ebx
  801b8a:	74 0a                	je     801b96 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801b8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b91:	8b 40 78             	mov    0x78(%eax),%eax
  801b94:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801b96:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9b:	8b 40 70             	mov    0x70(%eax),%eax
  801b9e:	eb 14                	jmp    801bb4 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801ba0:	85 f6                	test   %esi,%esi
  801ba2:	74 06                	je     801baa <ipc_recv+0x56>
		*from_env_store = 0;
  801ba4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801baa:	85 db                	test   %ebx,%ebx
  801bac:	74 06                	je     801bb4 <ipc_recv+0x60>
		*perm_store = 0;
  801bae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5d                   	pop    %ebp
  801bba:	c3                   	ret    

00801bbb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	57                   	push   %edi
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 1c             	sub    $0x1c,%esp
  801bc4:	8b 75 10             	mov    0x10(%ebp),%esi
  801bc7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801bca:	85 f6                	test   %esi,%esi
  801bcc:	75 05                	jne    801bd3 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801bce:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801bd3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801bd7:	89 74 24 08          	mov    %esi,0x8(%esp)
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be2:	8b 45 08             	mov    0x8(%ebp),%eax
  801be5:	89 04 24             	mov    %eax,(%esp)
  801be8:	e8 8f e7 ff ff       	call   80037c <sys_ipc_try_send>
  801bed:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801bef:	e8 76 e5 ff ff       	call   80016a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801bf4:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801bf7:	74 da                	je     801bd3 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801bf9:	85 db                	test   %ebx,%ebx
  801bfb:	74 20                	je     801c1d <ipc_send+0x62>
		panic("send fail: %e", err);
  801bfd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c01:	c7 44 24 08 60 23 80 	movl   $0x802360,0x8(%esp)
  801c08:	00 
  801c09:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801c10:	00 
  801c11:	c7 04 24 6e 23 80 00 	movl   $0x80236e,(%esp)
  801c18:	e8 4f f5 ff ff       	call   80116c <_panic>
	}
	return;
}
  801c1d:	83 c4 1c             	add    $0x1c,%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c2c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c31:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	c1 e2 07             	shl    $0x7,%edx
  801c3d:	29 ca                	sub    %ecx,%edx
  801c3f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c45:	8b 52 50             	mov    0x50(%edx),%edx
  801c48:	39 da                	cmp    %ebx,%edx
  801c4a:	75 0f                	jne    801c5b <ipc_find_env+0x36>
			return envs[i].env_id;
  801c4c:	c1 e0 07             	shl    $0x7,%eax
  801c4f:	29 c8                	sub    %ecx,%eax
  801c51:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c56:	8b 40 40             	mov    0x40(%eax),%eax
  801c59:	eb 0c                	jmp    801c67 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c5b:	40                   	inc    %eax
  801c5c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c61:	75 ce                	jne    801c31 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c63:	66 b8 00 00          	mov    $0x0,%ax
}
  801c67:	5b                   	pop    %ebx
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    
	...

00801c6c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c72:	89 c2                	mov    %eax,%edx
  801c74:	c1 ea 16             	shr    $0x16,%edx
  801c77:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c7e:	f6 c2 01             	test   $0x1,%dl
  801c81:	74 1e                	je     801ca1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c83:	c1 e8 0c             	shr    $0xc,%eax
  801c86:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c8d:	a8 01                	test   $0x1,%al
  801c8f:	74 17                	je     801ca8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c91:	c1 e8 0c             	shr    $0xc,%eax
  801c94:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801c9b:	ef 
  801c9c:	0f b7 c0             	movzwl %ax,%eax
  801c9f:	eb 0c                	jmp    801cad <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca6:	eb 05                	jmp    801cad <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    
	...

00801cb0 <__udivdi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	83 ec 10             	sub    $0x10,%esp
  801cb6:	8b 74 24 20          	mov    0x20(%esp),%esi
  801cba:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cbe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cc2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801cc6:	89 cd                	mov    %ecx,%ebp
  801cc8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	75 2c                	jne    801cfc <__udivdi3+0x4c>
  801cd0:	39 f9                	cmp    %edi,%ecx
  801cd2:	77 68                	ja     801d3c <__udivdi3+0x8c>
  801cd4:	85 c9                	test   %ecx,%ecx
  801cd6:	75 0b                	jne    801ce3 <__udivdi3+0x33>
  801cd8:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdd:	31 d2                	xor    %edx,%edx
  801cdf:	f7 f1                	div    %ecx
  801ce1:	89 c1                	mov    %eax,%ecx
  801ce3:	31 d2                	xor    %edx,%edx
  801ce5:	89 f8                	mov    %edi,%eax
  801ce7:	f7 f1                	div    %ecx
  801ce9:	89 c7                	mov    %eax,%edi
  801ceb:	89 f0                	mov    %esi,%eax
  801ced:	f7 f1                	div    %ecx
  801cef:	89 c6                	mov    %eax,%esi
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	89 fa                	mov    %edi,%edx
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	5e                   	pop    %esi
  801cf9:	5f                   	pop    %edi
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    
  801cfc:	39 f8                	cmp    %edi,%eax
  801cfe:	77 2c                	ja     801d2c <__udivdi3+0x7c>
  801d00:	0f bd f0             	bsr    %eax,%esi
  801d03:	83 f6 1f             	xor    $0x1f,%esi
  801d06:	75 4c                	jne    801d54 <__udivdi3+0xa4>
  801d08:	39 f8                	cmp    %edi,%eax
  801d0a:	bf 00 00 00 00       	mov    $0x0,%edi
  801d0f:	72 0a                	jb     801d1b <__udivdi3+0x6b>
  801d11:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d15:	0f 87 ad 00 00 00    	ja     801dc8 <__udivdi3+0x118>
  801d1b:	be 01 00 00 00       	mov    $0x1,%esi
  801d20:	89 f0                	mov    %esi,%eax
  801d22:	89 fa                	mov    %edi,%edx
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
  801d2b:	90                   	nop
  801d2c:	31 ff                	xor    %edi,%edi
  801d2e:	31 f6                	xor    %esi,%esi
  801d30:	89 f0                	mov    %esi,%eax
  801d32:	89 fa                	mov    %edi,%edx
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    
  801d3b:	90                   	nop
  801d3c:	89 fa                	mov    %edi,%edx
  801d3e:	89 f0                	mov    %esi,%eax
  801d40:	f7 f1                	div    %ecx
  801d42:	89 c6                	mov    %eax,%esi
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 f0                	mov    %esi,%eax
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	5e                   	pop    %esi
  801d4e:	5f                   	pop    %edi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    
  801d51:	8d 76 00             	lea    0x0(%esi),%esi
  801d54:	89 f1                	mov    %esi,%ecx
  801d56:	d3 e0                	shl    %cl,%eax
  801d58:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d5c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d61:	29 f0                	sub    %esi,%eax
  801d63:	89 ea                	mov    %ebp,%edx
  801d65:	88 c1                	mov    %al,%cl
  801d67:	d3 ea                	shr    %cl,%edx
  801d69:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801d6d:	09 ca                	or     %ecx,%edx
  801d6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d73:	89 f1                	mov    %esi,%ecx
  801d75:	d3 e5                	shl    %cl,%ebp
  801d77:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801d7b:	89 fd                	mov    %edi,%ebp
  801d7d:	88 c1                	mov    %al,%cl
  801d7f:	d3 ed                	shr    %cl,%ebp
  801d81:	89 fa                	mov    %edi,%edx
  801d83:	89 f1                	mov    %esi,%ecx
  801d85:	d3 e2                	shl    %cl,%edx
  801d87:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d8b:	88 c1                	mov    %al,%cl
  801d8d:	d3 ef                	shr    %cl,%edi
  801d8f:	09 d7                	or     %edx,%edi
  801d91:	89 f8                	mov    %edi,%eax
  801d93:	89 ea                	mov    %ebp,%edx
  801d95:	f7 74 24 08          	divl   0x8(%esp)
  801d99:	89 d1                	mov    %edx,%ecx
  801d9b:	89 c7                	mov    %eax,%edi
  801d9d:	f7 64 24 0c          	mull   0xc(%esp)
  801da1:	39 d1                	cmp    %edx,%ecx
  801da3:	72 17                	jb     801dbc <__udivdi3+0x10c>
  801da5:	74 09                	je     801db0 <__udivdi3+0x100>
  801da7:	89 fe                	mov    %edi,%esi
  801da9:	31 ff                	xor    %edi,%edi
  801dab:	e9 41 ff ff ff       	jmp    801cf1 <__udivdi3+0x41>
  801db0:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db4:	89 f1                	mov    %esi,%ecx
  801db6:	d3 e2                	shl    %cl,%edx
  801db8:	39 c2                	cmp    %eax,%edx
  801dba:	73 eb                	jae    801da7 <__udivdi3+0xf7>
  801dbc:	8d 77 ff             	lea    -0x1(%edi),%esi
  801dbf:	31 ff                	xor    %edi,%edi
  801dc1:	e9 2b ff ff ff       	jmp    801cf1 <__udivdi3+0x41>
  801dc6:	66 90                	xchg   %ax,%ax
  801dc8:	31 f6                	xor    %esi,%esi
  801dca:	e9 22 ff ff ff       	jmp    801cf1 <__udivdi3+0x41>
	...

00801dd0 <__umoddi3>:
  801dd0:	55                   	push   %ebp
  801dd1:	57                   	push   %edi
  801dd2:	56                   	push   %esi
  801dd3:	83 ec 20             	sub    $0x20,%esp
  801dd6:	8b 44 24 30          	mov    0x30(%esp),%eax
  801dda:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801dde:	89 44 24 14          	mov    %eax,0x14(%esp)
  801de2:	8b 74 24 34          	mov    0x34(%esp),%esi
  801de6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dea:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801dee:	89 c7                	mov    %eax,%edi
  801df0:	89 f2                	mov    %esi,%edx
  801df2:	85 ed                	test   %ebp,%ebp
  801df4:	75 16                	jne    801e0c <__umoddi3+0x3c>
  801df6:	39 f1                	cmp    %esi,%ecx
  801df8:	0f 86 a6 00 00 00    	jbe    801ea4 <__umoddi3+0xd4>
  801dfe:	f7 f1                	div    %ecx
  801e00:	89 d0                	mov    %edx,%eax
  801e02:	31 d2                	xor    %edx,%edx
  801e04:	83 c4 20             	add    $0x20,%esp
  801e07:	5e                   	pop    %esi
  801e08:	5f                   	pop    %edi
  801e09:	5d                   	pop    %ebp
  801e0a:	c3                   	ret    
  801e0b:	90                   	nop
  801e0c:	39 f5                	cmp    %esi,%ebp
  801e0e:	0f 87 ac 00 00 00    	ja     801ec0 <__umoddi3+0xf0>
  801e14:	0f bd c5             	bsr    %ebp,%eax
  801e17:	83 f0 1f             	xor    $0x1f,%eax
  801e1a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e1e:	0f 84 a8 00 00 00    	je     801ecc <__umoddi3+0xfc>
  801e24:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e28:	d3 e5                	shl    %cl,%ebp
  801e2a:	bf 20 00 00 00       	mov    $0x20,%edi
  801e2f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801e33:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e37:	89 f9                	mov    %edi,%ecx
  801e39:	d3 e8                	shr    %cl,%eax
  801e3b:	09 e8                	or     %ebp,%eax
  801e3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801e41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801e45:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e49:	d3 e0                	shl    %cl,%eax
  801e4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e4f:	89 f2                	mov    %esi,%edx
  801e51:	d3 e2                	shl    %cl,%edx
  801e53:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e57:	d3 e0                	shl    %cl,%eax
  801e59:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801e5d:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	d3 e8                	shr    %cl,%eax
  801e65:	09 d0                	or     %edx,%eax
  801e67:	d3 ee                	shr    %cl,%esi
  801e69:	89 f2                	mov    %esi,%edx
  801e6b:	f7 74 24 18          	divl   0x18(%esp)
  801e6f:	89 d6                	mov    %edx,%esi
  801e71:	f7 64 24 0c          	mull   0xc(%esp)
  801e75:	89 c5                	mov    %eax,%ebp
  801e77:	89 d1                	mov    %edx,%ecx
  801e79:	39 d6                	cmp    %edx,%esi
  801e7b:	72 67                	jb     801ee4 <__umoddi3+0x114>
  801e7d:	74 75                	je     801ef4 <__umoddi3+0x124>
  801e7f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e83:	29 e8                	sub    %ebp,%eax
  801e85:	19 ce                	sbb    %ecx,%esi
  801e87:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e8b:	d3 e8                	shr    %cl,%eax
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	89 f9                	mov    %edi,%ecx
  801e91:	d3 e2                	shl    %cl,%edx
  801e93:	09 d0                	or     %edx,%eax
  801e95:	89 f2                	mov    %esi,%edx
  801e97:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e9b:	d3 ea                	shr    %cl,%edx
  801e9d:	83 c4 20             	add    $0x20,%esp
  801ea0:	5e                   	pop    %esi
  801ea1:	5f                   	pop    %edi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    
  801ea4:	85 c9                	test   %ecx,%ecx
  801ea6:	75 0b                	jne    801eb3 <__umoddi3+0xe3>
  801ea8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ead:	31 d2                	xor    %edx,%edx
  801eaf:	f7 f1                	div    %ecx
  801eb1:	89 c1                	mov    %eax,%ecx
  801eb3:	89 f0                	mov    %esi,%eax
  801eb5:	31 d2                	xor    %edx,%edx
  801eb7:	f7 f1                	div    %ecx
  801eb9:	89 f8                	mov    %edi,%eax
  801ebb:	e9 3e ff ff ff       	jmp    801dfe <__umoddi3+0x2e>
  801ec0:	89 f2                	mov    %esi,%edx
  801ec2:	83 c4 20             	add    $0x20,%esp
  801ec5:	5e                   	pop    %esi
  801ec6:	5f                   	pop    %edi
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    
  801ec9:	8d 76 00             	lea    0x0(%esi),%esi
  801ecc:	39 f5                	cmp    %esi,%ebp
  801ece:	72 04                	jb     801ed4 <__umoddi3+0x104>
  801ed0:	39 f9                	cmp    %edi,%ecx
  801ed2:	77 06                	ja     801eda <__umoddi3+0x10a>
  801ed4:	89 f2                	mov    %esi,%edx
  801ed6:	29 cf                	sub    %ecx,%edi
  801ed8:	19 ea                	sbb    %ebp,%edx
  801eda:	89 f8                	mov    %edi,%eax
  801edc:	83 c4 20             	add    $0x20,%esp
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    
  801ee3:	90                   	nop
  801ee4:	89 d1                	mov    %edx,%ecx
  801ee6:	89 c5                	mov    %eax,%ebp
  801ee8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801eec:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801ef0:	eb 8d                	jmp    801e7f <__umoddi3+0xaf>
  801ef2:	66 90                	xchg   %ax,%ax
  801ef4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801ef8:	72 ea                	jb     801ee4 <__umoddi3+0x114>
  801efa:	89 f1                	mov    %esi,%ecx
  801efc:	eb 81                	jmp    801e7f <__umoddi3+0xaf>
