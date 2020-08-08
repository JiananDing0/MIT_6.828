
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 6d 00 00 00       	call   8000bc <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800062:	e8 e4 00 00 00       	call   80014b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 3f 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

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
  800127:	c7 44 24 08 f8 0f 80 	movl   $0x800ff8,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 15 10 80 00 	movl   $0x801015,(%esp)
  80013e:	e8 5d 02 00 00       	call   8003a0 <_panic>

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
  800175:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  8001b9:	c7 44 24 08 f8 0f 80 	movl   $0x800ff8,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c8:	00 
  8001c9:	c7 04 24 15 10 80 00 	movl   $0x801015,(%esp)
  8001d0:	e8 cb 01 00 00       	call   8003a0 <_panic>

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
  80020c:	c7 44 24 08 f8 0f 80 	movl   $0x800ff8,0x8(%esp)
  800213:	00 
  800214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 15 10 80 00 	movl   $0x801015,(%esp)
  800223:	e8 78 01 00 00       	call   8003a0 <_panic>

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
  80025f:	c7 44 24 08 f8 0f 80 	movl   $0x800ff8,0x8(%esp)
  800266:	00 
  800267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026e:	00 
  80026f:	c7 04 24 15 10 80 00 	movl   $0x801015,(%esp)
  800276:	e8 25 01 00 00       	call   8003a0 <_panic>

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
  8002b2:	c7 44 24 08 f8 0f 80 	movl   $0x800ff8,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 15 10 80 00 	movl   $0x801015,(%esp)
  8002c9:	e8 d2 00 00 00       	call   8003a0 <_panic>

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

008002d6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  8002f7:	7e 28                	jle    800321 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800304:	00 
  800305:	c7 44 24 08 f8 0f 80 	movl   $0x800ff8,0x8(%esp)
  80030c:	00 
  80030d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800314:	00 
  800315:	c7 04 24 15 10 80 00 	movl   $0x801015,(%esp)
  80031c:	e8 7f 00 00 00       	call   8003a0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800321:	83 c4 2c             	add    $0x2c,%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032f:	be 00 00 00 00       	mov    $0x0,%esi
  800334:	b8 0b 00 00 00       	mov    $0xb,%eax
  800339:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800342:	8b 55 08             	mov    0x8(%ebp),%edx
  800345:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800347:	5b                   	pop    %ebx
  800348:	5e                   	pop    %esi
  800349:	5f                   	pop    %edi
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80035f:	8b 55 08             	mov    0x8(%ebp),%edx
  800362:	89 cb                	mov    %ecx,%ebx
  800364:	89 cf                	mov    %ecx,%edi
  800366:	89 ce                	mov    %ecx,%esi
  800368:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80036a:	85 c0                	test   %eax,%eax
  80036c:	7e 28                	jle    800396 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800372:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800379:	00 
  80037a:	c7 44 24 08 f8 0f 80 	movl   $0x800ff8,0x8(%esp)
  800381:	00 
  800382:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800389:	00 
  80038a:	c7 04 24 15 10 80 00 	movl   $0x801015,(%esp)
  800391:	e8 0a 00 00 00       	call   8003a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800396:	83 c4 2c             	add    $0x2c,%esp
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    
	...

008003a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003ab:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8003b1:	e8 95 fd ff ff       	call   80014b <sys_getenvid>
  8003b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003cc:	c7 04 24 24 10 80 00 	movl   $0x801024,(%esp)
  8003d3:	e8 c0 00 00 00       	call   800498 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003df:	89 04 24             	mov    %eax,(%esp)
  8003e2:	e8 50 00 00 00       	call   800437 <vcprintf>
	cprintf("\n");
  8003e7:	c7 04 24 ec 0f 80 00 	movl   $0x800fec,(%esp)
  8003ee:	e8 a5 00 00 00       	call   800498 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003f3:	cc                   	int3   
  8003f4:	eb fd                	jmp    8003f3 <_panic+0x53>
	...

008003f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	53                   	push   %ebx
  8003fc:	83 ec 14             	sub    $0x14,%esp
  8003ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800402:	8b 03                	mov    (%ebx),%eax
  800404:	8b 55 08             	mov    0x8(%ebp),%edx
  800407:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80040b:	40                   	inc    %eax
  80040c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80040e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800413:	75 19                	jne    80042e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800415:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80041c:	00 
  80041d:	8d 43 08             	lea    0x8(%ebx),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	e8 94 fc ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800428:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80042e:	ff 43 04             	incl   0x4(%ebx)
}
  800431:	83 c4 14             	add    $0x14,%esp
  800434:	5b                   	pop    %ebx
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800440:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800447:	00 00 00 
	b.cnt = 0;
  80044a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800451:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800462:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800468:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046c:	c7 04 24 f8 03 80 00 	movl   $0x8003f8,(%esp)
  800473:	e8 82 01 00 00       	call   8005fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800478:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80047e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800482:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	e8 2c fc ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  800490:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800496:	c9                   	leave  
  800497:	c3                   	ret    

00800498 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
  80049b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80049e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	e8 87 ff ff ff       	call   800437 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    
	...

008004b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	57                   	push   %edi
  8004b8:	56                   	push   %esi
  8004b9:	53                   	push   %ebx
  8004ba:	83 ec 3c             	sub    $0x3c,%esp
  8004bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c0:	89 d7                	mov    %edx,%edi
  8004c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004d1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	75 08                	jne    8004e0 <printnum+0x2c>
  8004d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004de:	77 57                	ja     800537 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004e0:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004e4:	4b                   	dec    %ebx
  8004e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004f0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004f4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ff:	00 
  800500:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800503:	89 04 24             	mov    %eax,(%esp)
  800506:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050d:	e8 76 08 00 00       	call   800d88 <__udivdi3>
  800512:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800516:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800521:	89 fa                	mov    %edi,%edx
  800523:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800526:	e8 89 ff ff ff       	call   8004b4 <printnum>
  80052b:	eb 0f                	jmp    80053c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80052d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800531:	89 34 24             	mov    %esi,(%esp)
  800534:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800537:	4b                   	dec    %ebx
  800538:	85 db                	test   %ebx,%ebx
  80053a:	7f f1                	jg     80052d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80053c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800540:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800544:	8b 45 10             	mov    0x10(%ebp),%eax
  800547:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800552:	00 
  800553:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800556:	89 04 24             	mov    %eax,(%esp)
  800559:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800560:	e8 43 09 00 00       	call   800ea8 <__umoddi3>
  800565:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800569:	0f be 80 48 10 80 00 	movsbl 0x801048(%eax),%eax
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800576:	83 c4 3c             	add    $0x3c,%esp
  800579:	5b                   	pop    %ebx
  80057a:	5e                   	pop    %esi
  80057b:	5f                   	pop    %edi
  80057c:	5d                   	pop    %ebp
  80057d:	c3                   	ret    

0080057e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800581:	83 fa 01             	cmp    $0x1,%edx
  800584:	7e 0e                	jle    800594 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800586:	8b 10                	mov    (%eax),%edx
  800588:	8d 4a 08             	lea    0x8(%edx),%ecx
  80058b:	89 08                	mov    %ecx,(%eax)
  80058d:	8b 02                	mov    (%edx),%eax
  80058f:	8b 52 04             	mov    0x4(%edx),%edx
  800592:	eb 22                	jmp    8005b6 <getuint+0x38>
	else if (lflag)
  800594:	85 d2                	test   %edx,%edx
  800596:	74 10                	je     8005a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800598:	8b 10                	mov    (%eax),%edx
  80059a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80059d:	89 08                	mov    %ecx,(%eax)
  80059f:	8b 02                	mov    (%edx),%eax
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a6:	eb 0e                	jmp    8005b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ad:	89 08                	mov    %ecx,(%eax)
  8005af:	8b 02                	mov    (%edx),%eax
  8005b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005be:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c6:	73 08                	jae    8005d0 <sprintputch+0x18>
		*b->buf++ = ch;
  8005c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005cb:	88 0a                	mov    %cl,(%edx)
  8005cd:	42                   	inc    %edx
  8005ce:	89 10                	mov    %edx,(%eax)
}
  8005d0:	5d                   	pop    %ebp
  8005d1:	c3                   	ret    

008005d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005d2:	55                   	push   %ebp
  8005d3:	89 e5                	mov    %esp,%ebp
  8005d5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005df:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	e8 02 00 00 00       	call   8005fa <vprintfmt>
	va_end(ap);
}
  8005f8:	c9                   	leave  
  8005f9:	c3                   	ret    

008005fa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005fa:	55                   	push   %ebp
  8005fb:	89 e5                	mov    %esp,%ebp
  8005fd:	57                   	push   %edi
  8005fe:	56                   	push   %esi
  8005ff:	53                   	push   %ebx
  800600:	83 ec 4c             	sub    $0x4c,%esp
  800603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800606:	8b 75 10             	mov    0x10(%ebp),%esi
  800609:	eb 12                	jmp    80061d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80060b:	85 c0                	test   %eax,%eax
  80060d:	0f 84 8b 03 00 00    	je     80099e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800613:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80061d:	0f b6 06             	movzbl (%esi),%eax
  800620:	46                   	inc    %esi
  800621:	83 f8 25             	cmp    $0x25,%eax
  800624:	75 e5                	jne    80060b <vprintfmt+0x11>
  800626:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80062a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800631:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800636:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	eb 26                	jmp    80066a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800647:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80064b:	eb 1d                	jmp    80066a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800650:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800654:	eb 14                	jmp    80066a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800659:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800660:	eb 08                	jmp    80066a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800662:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800665:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066a:	0f b6 06             	movzbl (%esi),%eax
  80066d:	8d 56 01             	lea    0x1(%esi),%edx
  800670:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800673:	8a 16                	mov    (%esi),%dl
  800675:	83 ea 23             	sub    $0x23,%edx
  800678:	80 fa 55             	cmp    $0x55,%dl
  80067b:	0f 87 01 03 00 00    	ja     800982 <vprintfmt+0x388>
  800681:	0f b6 d2             	movzbl %dl,%edx
  800684:	ff 24 95 00 11 80 00 	jmp    *0x801100(,%edx,4)
  80068b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800693:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800696:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80069a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80069d:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006a0:	83 fa 09             	cmp    $0x9,%edx
  8006a3:	77 2a                	ja     8006cf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006a6:	eb eb                	jmp    800693 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006b6:	eb 17                	jmp    8006cf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bc:	78 98                	js     800656 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006c1:	eb a7                	jmp    80066a <vprintfmt+0x70>
  8006c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006cd:	eb 9b                	jmp    80066a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006d3:	79 95                	jns    80066a <vprintfmt+0x70>
  8006d5:	eb 8b                	jmp    800662 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006db:	eb 8d                	jmp    80066a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f5:	e9 23 ff ff ff       	jmp    80061d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 04             	lea    0x4(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 00                	mov    (%eax),%eax
  800705:	85 c0                	test   %eax,%eax
  800707:	79 02                	jns    80070b <vprintfmt+0x111>
  800709:	f7 d8                	neg    %eax
  80070b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80070d:	83 f8 08             	cmp    $0x8,%eax
  800710:	7f 0b                	jg     80071d <vprintfmt+0x123>
  800712:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  800719:	85 c0                	test   %eax,%eax
  80071b:	75 23                	jne    800740 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80071d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800721:	c7 44 24 08 60 10 80 	movl   $0x801060,0x8(%esp)
  800728:	00 
  800729:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	89 04 24             	mov    %eax,(%esp)
  800733:	e8 9a fe ff ff       	call   8005d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800738:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80073b:	e9 dd fe ff ff       	jmp    80061d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800740:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800744:	c7 44 24 08 69 10 80 	movl   $0x801069,0x8(%esp)
  80074b:	00 
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	8b 55 08             	mov    0x8(%ebp),%edx
  800753:	89 14 24             	mov    %edx,(%esp)
  800756:	e8 77 fe ff ff       	call   8005d2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80075e:	e9 ba fe ff ff       	jmp    80061d <vprintfmt+0x23>
  800763:	89 f9                	mov    %edi,%ecx
  800765:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800768:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	89 55 14             	mov    %edx,0x14(%ebp)
  800774:	8b 30                	mov    (%eax),%esi
  800776:	85 f6                	test   %esi,%esi
  800778:	75 05                	jne    80077f <vprintfmt+0x185>
				p = "(null)";
  80077a:	be 59 10 80 00       	mov    $0x801059,%esi
			if (width > 0 && padc != '-')
  80077f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800783:	0f 8e 84 00 00 00    	jle    80080d <vprintfmt+0x213>
  800789:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80078d:	74 7e                	je     80080d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80078f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800793:	89 34 24             	mov    %esi,(%esp)
  800796:	e8 ab 02 00 00       	call   800a46 <strnlen>
  80079b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80079e:	29 c2                	sub    %eax,%edx
  8007a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007ad:	89 de                	mov    %ebx,%esi
  8007af:	89 d3                	mov    %edx,%ebx
  8007b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b3:	eb 0b                	jmp    8007c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	89 3c 24             	mov    %edi,(%esp)
  8007bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bf:	4b                   	dec    %ebx
  8007c0:	85 db                	test   %ebx,%ebx
  8007c2:	7f f1                	jg     8007b5 <vprintfmt+0x1bb>
  8007c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007c7:	89 f3                	mov    %esi,%ebx
  8007c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	79 05                	jns    8007d8 <vprintfmt+0x1de>
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007db:	29 c2                	sub    %eax,%edx
  8007dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007e0:	eb 2b                	jmp    80080d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e6:	74 18                	je     800800 <vprintfmt+0x206>
  8007e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007eb:	83 fa 5e             	cmp    $0x5e,%edx
  8007ee:	76 10                	jbe    800800 <vprintfmt+0x206>
					putch('?', putdat);
  8007f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007fb:	ff 55 08             	call   *0x8(%ebp)
  8007fe:	eb 0a                	jmp    80080a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80080a:	ff 4d e4             	decl   -0x1c(%ebp)
  80080d:	0f be 06             	movsbl (%esi),%eax
  800810:	46                   	inc    %esi
  800811:	85 c0                	test   %eax,%eax
  800813:	74 21                	je     800836 <vprintfmt+0x23c>
  800815:	85 ff                	test   %edi,%edi
  800817:	78 c9                	js     8007e2 <vprintfmt+0x1e8>
  800819:	4f                   	dec    %edi
  80081a:	79 c6                	jns    8007e2 <vprintfmt+0x1e8>
  80081c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081f:	89 de                	mov    %ebx,%esi
  800821:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800824:	eb 18                	jmp    80083e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800831:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800833:	4b                   	dec    %ebx
  800834:	eb 08                	jmp    80083e <vprintfmt+0x244>
  800836:	8b 7d 08             	mov    0x8(%ebp),%edi
  800839:	89 de                	mov    %ebx,%esi
  80083b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80083e:	85 db                	test   %ebx,%ebx
  800840:	7f e4                	jg     800826 <vprintfmt+0x22c>
  800842:	89 7d 08             	mov    %edi,0x8(%ebp)
  800845:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800847:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80084a:	e9 ce fd ff ff       	jmp    80061d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80084f:	83 f9 01             	cmp    $0x1,%ecx
  800852:	7e 10                	jle    800864 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 08             	lea    0x8(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 30                	mov    (%eax),%esi
  80085f:	8b 78 04             	mov    0x4(%eax),%edi
  800862:	eb 26                	jmp    80088a <vprintfmt+0x290>
	else if (lflag)
  800864:	85 c9                	test   %ecx,%ecx
  800866:	74 12                	je     80087a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8d 50 04             	lea    0x4(%eax),%edx
  80086e:	89 55 14             	mov    %edx,0x14(%ebp)
  800871:	8b 30                	mov    (%eax),%esi
  800873:	89 f7                	mov    %esi,%edi
  800875:	c1 ff 1f             	sar    $0x1f,%edi
  800878:	eb 10                	jmp    80088a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 50 04             	lea    0x4(%eax),%edx
  800880:	89 55 14             	mov    %edx,0x14(%ebp)
  800883:	8b 30                	mov    (%eax),%esi
  800885:	89 f7                	mov    %esi,%edi
  800887:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80088a:	85 ff                	test   %edi,%edi
  80088c:	78 0a                	js     800898 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80088e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800893:	e9 ac 00 00 00       	jmp    800944 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800898:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008a6:	f7 de                	neg    %esi
  8008a8:	83 d7 00             	adc    $0x0,%edi
  8008ab:	f7 df                	neg    %edi
			}
			base = 10;
  8008ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008b2:	e9 8d 00 00 00       	jmp    800944 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008b7:	89 ca                	mov    %ecx,%edx
  8008b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008bc:	e8 bd fc ff ff       	call   80057e <getuint>
  8008c1:	89 c6                	mov    %eax,%esi
  8008c3:	89 d7                	mov    %edx,%edi
			base = 10;
  8008c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008ca:	eb 78                	jmp    800944 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008d7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008de:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008e5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008f9:	e9 1f fd ff ff       	jmp    80061d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8008fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800902:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800909:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80090c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800910:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800917:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8d 50 04             	lea    0x4(%eax),%edx
  800920:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800923:	8b 30                	mov    (%eax),%esi
  800925:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80092a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80092f:	eb 13                	jmp    800944 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800931:	89 ca                	mov    %ecx,%edx
  800933:	8d 45 14             	lea    0x14(%ebp),%eax
  800936:	e8 43 fc ff ff       	call   80057e <getuint>
  80093b:	89 c6                	mov    %eax,%esi
  80093d:	89 d7                	mov    %edx,%edi
			base = 16;
  80093f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800944:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800948:	89 54 24 10          	mov    %edx,0x10(%esp)
  80094c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80094f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800953:	89 44 24 08          	mov    %eax,0x8(%esp)
  800957:	89 34 24             	mov    %esi,(%esp)
  80095a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095e:	89 da                	mov    %ebx,%edx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	e8 4c fb ff ff       	call   8004b4 <printnum>
			break;
  800968:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80096b:	e9 ad fc ff ff       	jmp    80061d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800970:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80097d:	e9 9b fc ff ff       	jmp    80061d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800982:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800986:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80098d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800990:	eb 01                	jmp    800993 <vprintfmt+0x399>
  800992:	4e                   	dec    %esi
  800993:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800997:	75 f9                	jne    800992 <vprintfmt+0x398>
  800999:	e9 7f fc ff ff       	jmp    80061d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80099e:	83 c4 4c             	add    $0x4c,%esp
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 28             	sub    $0x28,%esp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009c3:	85 c0                	test   %eax,%eax
  8009c5:	74 30                	je     8009f7 <vsnprintf+0x51>
  8009c7:	85 d2                	test   %edx,%edx
  8009c9:	7e 33                	jle    8009fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e0:	c7 04 24 b8 05 80 00 	movl   $0x8005b8,(%esp)
  8009e7:	e8 0e fc ff ff       	call   8005fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f5:	eb 0c                	jmp    800a03 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009fc:	eb 05                	jmp    800a03 <vsnprintf+0x5d>
  8009fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a12:	8b 45 10             	mov    0x10(%ebp),%eax
  800a15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 7b ff ff ff       	call   8009a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    
  800a2d:	00 00                	add    %al,(%eax)
	...

00800a30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 01                	jmp    800a3e <strlen+0xe>
		n++;
  800a3d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a42:	75 f9                	jne    800a3d <strlen+0xd>
		n++;
	return n;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	eb 01                	jmp    800a57 <strnlen+0x11>
		n++;
  800a56:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	74 06                	je     800a61 <strnlen+0x1b>
  800a5b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a5f:	75 f5                	jne    800a56 <strnlen+0x10>
		n++;
	return n;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	53                   	push   %ebx
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a75:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a78:	42                   	inc    %edx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	75 f5                	jne    800a72 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8a:	89 1c 24             	mov    %ebx,(%esp)
  800a8d:	e8 9e ff ff ff       	call   800a30 <strlen>
	strcpy(dst + len, src);
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a95:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a99:	01 d8                	add    %ebx,%eax
  800a9b:	89 04 24             	mov    %eax,(%esp)
  800a9e:	e8 c0 ff ff ff       	call   800a63 <strcpy>
	return dst;
}
  800aa3:	89 d8                	mov    %ebx,%eax
  800aa5:	83 c4 08             	add    $0x8,%esp
  800aa8:	5b                   	pop    %ebx
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abe:	eb 0c                	jmp    800acc <strncpy+0x21>
		*dst++ = *src;
  800ac0:	8a 1a                	mov    (%edx),%bl
  800ac2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acb:	41                   	inc    %ecx
  800acc:	39 f1                	cmp    %esi,%ecx
  800ace:	75 f0                	jne    800ac0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800adf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae2:	85 d2                	test   %edx,%edx
  800ae4:	75 0a                	jne    800af0 <strlcpy+0x1c>
  800ae6:	89 f0                	mov    %esi,%eax
  800ae8:	eb 1a                	jmp    800b04 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aea:	88 18                	mov    %bl,(%eax)
  800aec:	40                   	inc    %eax
  800aed:	41                   	inc    %ecx
  800aee:	eb 02                	jmp    800af2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800af2:	4a                   	dec    %edx
  800af3:	74 0a                	je     800aff <strlcpy+0x2b>
  800af5:	8a 19                	mov    (%ecx),%bl
  800af7:	84 db                	test   %bl,%bl
  800af9:	75 ef                	jne    800aea <strlcpy+0x16>
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	eb 02                	jmp    800b01 <strlcpy+0x2d>
  800aff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b01:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b04:	29 f0                	sub    %esi,%eax
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b10:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b13:	eb 02                	jmp    800b17 <strcmp+0xd>
		p++, q++;
  800b15:	41                   	inc    %ecx
  800b16:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b17:	8a 01                	mov    (%ecx),%al
  800b19:	84 c0                	test   %al,%al
  800b1b:	74 04                	je     800b21 <strcmp+0x17>
  800b1d:	3a 02                	cmp    (%edx),%al
  800b1f:	74 f4                	je     800b15 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b21:	0f b6 c0             	movzbl %al,%eax
  800b24:	0f b6 12             	movzbl (%edx),%edx
  800b27:	29 d0                	sub    %edx,%eax
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b38:	eb 03                	jmp    800b3d <strncmp+0x12>
		n--, p++, q++;
  800b3a:	4a                   	dec    %edx
  800b3b:	40                   	inc    %eax
  800b3c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b3d:	85 d2                	test   %edx,%edx
  800b3f:	74 14                	je     800b55 <strncmp+0x2a>
  800b41:	8a 18                	mov    (%eax),%bl
  800b43:	84 db                	test   %bl,%bl
  800b45:	74 04                	je     800b4b <strncmp+0x20>
  800b47:	3a 19                	cmp    (%ecx),%bl
  800b49:	74 ef                	je     800b3a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4b:	0f b6 00             	movzbl (%eax),%eax
  800b4e:	0f b6 11             	movzbl (%ecx),%edx
  800b51:	29 d0                	sub    %edx,%eax
  800b53:	eb 05                	jmp    800b5a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b66:	eb 05                	jmp    800b6d <strchr+0x10>
		if (*s == c)
  800b68:	38 ca                	cmp    %cl,%dl
  800b6a:	74 0c                	je     800b78 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b6c:	40                   	inc    %eax
  800b6d:	8a 10                	mov    (%eax),%dl
  800b6f:	84 d2                	test   %dl,%dl
  800b71:	75 f5                	jne    800b68 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b83:	eb 05                	jmp    800b8a <strfind+0x10>
		if (*s == c)
  800b85:	38 ca                	cmp    %cl,%dl
  800b87:	74 07                	je     800b90 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b89:	40                   	inc    %eax
  800b8a:	8a 10                	mov    (%eax),%dl
  800b8c:	84 d2                	test   %dl,%dl
  800b8e:	75 f5                	jne    800b85 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba1:	85 c9                	test   %ecx,%ecx
  800ba3:	74 30                	je     800bd5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bab:	75 25                	jne    800bd2 <memset+0x40>
  800bad:	f6 c1 03             	test   $0x3,%cl
  800bb0:	75 20                	jne    800bd2 <memset+0x40>
		c &= 0xFF;
  800bb2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	c1 e3 08             	shl    $0x8,%ebx
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	c1 e6 18             	shl    $0x18,%esi
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	c1 e0 10             	shl    $0x10,%eax
  800bc4:	09 f0                	or     %esi,%eax
  800bc6:	09 d0                	or     %edx,%eax
  800bc8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bcd:	fc                   	cld    
  800bce:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd0:	eb 03                	jmp    800bd5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd2:	fc                   	cld    
  800bd3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd5:	89 f8                	mov    %edi,%eax
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	8b 45 08             	mov    0x8(%ebp),%eax
  800be4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bea:	39 c6                	cmp    %eax,%esi
  800bec:	73 34                	jae    800c22 <memmove+0x46>
  800bee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf1:	39 d0                	cmp    %edx,%eax
  800bf3:	73 2d                	jae    800c22 <memmove+0x46>
		s += n;
		d += n;
  800bf5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf8:	f6 c2 03             	test   $0x3,%dl
  800bfb:	75 1b                	jne    800c18 <memmove+0x3c>
  800bfd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c03:	75 13                	jne    800c18 <memmove+0x3c>
  800c05:	f6 c1 03             	test   $0x3,%cl
  800c08:	75 0e                	jne    800c18 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c0a:	83 ef 04             	sub    $0x4,%edi
  800c0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c13:	fd                   	std    
  800c14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c16:	eb 07                	jmp    800c1f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c18:	4f                   	dec    %edi
  800c19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c1c:	fd                   	std    
  800c1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c1f:	fc                   	cld    
  800c20:	eb 20                	jmp    800c42 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c28:	75 13                	jne    800c3d <memmove+0x61>
  800c2a:	a8 03                	test   $0x3,%al
  800c2c:	75 0f                	jne    800c3d <memmove+0x61>
  800c2e:	f6 c1 03             	test   $0x3,%cl
  800c31:	75 0a                	jne    800c3d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	fc                   	cld    
  800c39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3b:	eb 05                	jmp    800c42 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c3d:	89 c7                	mov    %eax,%edi
  800c3f:	fc                   	cld    
  800c40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	89 04 24             	mov    %eax,(%esp)
  800c60:	e8 77 ff ff ff       	call   800bdc <memmove>
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7b:	eb 16                	jmp    800c93 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c80:	42                   	inc    %edx
  800c81:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c85:	38 c8                	cmp    %cl,%al
  800c87:	74 0a                	je     800c93 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c89:	0f b6 c0             	movzbl %al,%eax
  800c8c:	0f b6 c9             	movzbl %cl,%ecx
  800c8f:	29 c8                	sub    %ecx,%eax
  800c91:	eb 09                	jmp    800c9c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c93:	39 da                	cmp    %ebx,%edx
  800c95:	75 e6                	jne    800c7d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800caa:	89 c2                	mov    %eax,%edx
  800cac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800caf:	eb 05                	jmp    800cb6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb1:	38 08                	cmp    %cl,(%eax)
  800cb3:	74 05                	je     800cba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb5:	40                   	inc    %eax
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	72 f7                	jb     800cb1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc8:	eb 01                	jmp    800ccb <strtol+0xf>
		s++;
  800cca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccb:	8a 02                	mov    (%edx),%al
  800ccd:	3c 20                	cmp    $0x20,%al
  800ccf:	74 f9                	je     800cca <strtol+0xe>
  800cd1:	3c 09                	cmp    $0x9,%al
  800cd3:	74 f5                	je     800cca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cd5:	3c 2b                	cmp    $0x2b,%al
  800cd7:	75 08                	jne    800ce1 <strtol+0x25>
		s++;
  800cd9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cda:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdf:	eb 13                	jmp    800cf4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ce1:	3c 2d                	cmp    $0x2d,%al
  800ce3:	75 0a                	jne    800cef <strtol+0x33>
		s++, neg = 1;
  800ce5:	8d 52 01             	lea    0x1(%edx),%edx
  800ce8:	bf 01 00 00 00       	mov    $0x1,%edi
  800ced:	eb 05                	jmp    800cf4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf4:	85 db                	test   %ebx,%ebx
  800cf6:	74 05                	je     800cfd <strtol+0x41>
  800cf8:	83 fb 10             	cmp    $0x10,%ebx
  800cfb:	75 28                	jne    800d25 <strtol+0x69>
  800cfd:	8a 02                	mov    (%edx),%al
  800cff:	3c 30                	cmp    $0x30,%al
  800d01:	75 10                	jne    800d13 <strtol+0x57>
  800d03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d07:	75 0a                	jne    800d13 <strtol+0x57>
		s += 2, base = 16;
  800d09:	83 c2 02             	add    $0x2,%edx
  800d0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d11:	eb 12                	jmp    800d25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d13:	85 db                	test   %ebx,%ebx
  800d15:	75 0e                	jne    800d25 <strtol+0x69>
  800d17:	3c 30                	cmp    $0x30,%al
  800d19:	75 05                	jne    800d20 <strtol+0x64>
		s++, base = 8;
  800d1b:	42                   	inc    %edx
  800d1c:	b3 08                	mov    $0x8,%bl
  800d1e:	eb 05                	jmp    800d25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d2c:	8a 0a                	mov    (%edx),%cl
  800d2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d31:	80 fb 09             	cmp    $0x9,%bl
  800d34:	77 08                	ja     800d3e <strtol+0x82>
			dig = *s - '0';
  800d36:	0f be c9             	movsbl %cl,%ecx
  800d39:	83 e9 30             	sub    $0x30,%ecx
  800d3c:	eb 1e                	jmp    800d5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d41:	80 fb 19             	cmp    $0x19,%bl
  800d44:	77 08                	ja     800d4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d46:	0f be c9             	movsbl %cl,%ecx
  800d49:	83 e9 57             	sub    $0x57,%ecx
  800d4c:	eb 0e                	jmp    800d5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d51:	80 fb 19             	cmp    $0x19,%bl
  800d54:	77 12                	ja     800d68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d56:	0f be c9             	movsbl %cl,%ecx
  800d59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d5c:	39 f1                	cmp    %esi,%ecx
  800d5e:	7d 0c                	jge    800d6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d60:	42                   	inc    %edx
  800d61:	0f af c6             	imul   %esi,%eax
  800d64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d66:	eb c4                	jmp    800d2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d68:	89 c1                	mov    %eax,%ecx
  800d6a:	eb 02                	jmp    800d6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d72:	74 05                	je     800d79 <strtol+0xbd>
		*endptr = (char *) s;
  800d74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d79:	85 ff                	test   %edi,%edi
  800d7b:	74 04                	je     800d81 <strtol+0xc5>
  800d7d:	89 c8                	mov    %ecx,%eax
  800d7f:	f7 d8                	neg    %eax
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
	...

00800d88 <__udivdi3>:
  800d88:	55                   	push   %ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	83 ec 10             	sub    $0x10,%esp
  800d8e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d92:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d9a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d9e:	89 cd                	mov    %ecx,%ebp
  800da0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800da4:	85 c0                	test   %eax,%eax
  800da6:	75 2c                	jne    800dd4 <__udivdi3+0x4c>
  800da8:	39 f9                	cmp    %edi,%ecx
  800daa:	77 68                	ja     800e14 <__udivdi3+0x8c>
  800dac:	85 c9                	test   %ecx,%ecx
  800dae:	75 0b                	jne    800dbb <__udivdi3+0x33>
  800db0:	b8 01 00 00 00       	mov    $0x1,%eax
  800db5:	31 d2                	xor    %edx,%edx
  800db7:	f7 f1                	div    %ecx
  800db9:	89 c1                	mov    %eax,%ecx
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	89 f8                	mov    %edi,%eax
  800dbf:	f7 f1                	div    %ecx
  800dc1:	89 c7                	mov    %eax,%edi
  800dc3:	89 f0                	mov    %esi,%eax
  800dc5:	f7 f1                	div    %ecx
  800dc7:	89 c6                	mov    %eax,%esi
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
  800dd4:	39 f8                	cmp    %edi,%eax
  800dd6:	77 2c                	ja     800e04 <__udivdi3+0x7c>
  800dd8:	0f bd f0             	bsr    %eax,%esi
  800ddb:	83 f6 1f             	xor    $0x1f,%esi
  800dde:	75 4c                	jne    800e2c <__udivdi3+0xa4>
  800de0:	39 f8                	cmp    %edi,%eax
  800de2:	bf 00 00 00 00       	mov    $0x0,%edi
  800de7:	72 0a                	jb     800df3 <__udivdi3+0x6b>
  800de9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800ded:	0f 87 ad 00 00 00    	ja     800ea0 <__udivdi3+0x118>
  800df3:	be 01 00 00 00       	mov    $0x1,%esi
  800df8:	89 f0                	mov    %esi,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	31 f6                	xor    %esi,%esi
  800e08:	89 f0                	mov    %esi,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	89 fa                	mov    %edi,%edx
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	f7 f1                	div    %ecx
  800e1a:	89 c6                	mov    %eax,%esi
  800e1c:	31 ff                	xor    %edi,%edi
  800e1e:	89 f0                	mov    %esi,%eax
  800e20:	89 fa                	mov    %edi,%edx
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    
  800e29:	8d 76 00             	lea    0x0(%esi),%esi
  800e2c:	89 f1                	mov    %esi,%ecx
  800e2e:	d3 e0                	shl    %cl,%eax
  800e30:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e34:	b8 20 00 00 00       	mov    $0x20,%eax
  800e39:	29 f0                	sub    %esi,%eax
  800e3b:	89 ea                	mov    %ebp,%edx
  800e3d:	88 c1                	mov    %al,%cl
  800e3f:	d3 ea                	shr    %cl,%edx
  800e41:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e45:	09 ca                	or     %ecx,%edx
  800e47:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4b:	89 f1                	mov    %esi,%ecx
  800e4d:	d3 e5                	shl    %cl,%ebp
  800e4f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e53:	89 fd                	mov    %edi,%ebp
  800e55:	88 c1                	mov    %al,%cl
  800e57:	d3 ed                	shr    %cl,%ebp
  800e59:	89 fa                	mov    %edi,%edx
  800e5b:	89 f1                	mov    %esi,%ecx
  800e5d:	d3 e2                	shl    %cl,%edx
  800e5f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e63:	88 c1                	mov    %al,%cl
  800e65:	d3 ef                	shr    %cl,%edi
  800e67:	09 d7                	or     %edx,%edi
  800e69:	89 f8                	mov    %edi,%eax
  800e6b:	89 ea                	mov    %ebp,%edx
  800e6d:	f7 74 24 08          	divl   0x8(%esp)
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 c7                	mov    %eax,%edi
  800e75:	f7 64 24 0c          	mull   0xc(%esp)
  800e79:	39 d1                	cmp    %edx,%ecx
  800e7b:	72 17                	jb     800e94 <__udivdi3+0x10c>
  800e7d:	74 09                	je     800e88 <__udivdi3+0x100>
  800e7f:	89 fe                	mov    %edi,%esi
  800e81:	31 ff                	xor    %edi,%edi
  800e83:	e9 41 ff ff ff       	jmp    800dc9 <__udivdi3+0x41>
  800e88:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e8c:	89 f1                	mov    %esi,%ecx
  800e8e:	d3 e2                	shl    %cl,%edx
  800e90:	39 c2                	cmp    %eax,%edx
  800e92:	73 eb                	jae    800e7f <__udivdi3+0xf7>
  800e94:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e97:	31 ff                	xor    %edi,%edi
  800e99:	e9 2b ff ff ff       	jmp    800dc9 <__udivdi3+0x41>
  800e9e:	66 90                	xchg   %ax,%ax
  800ea0:	31 f6                	xor    %esi,%esi
  800ea2:	e9 22 ff ff ff       	jmp    800dc9 <__udivdi3+0x41>
	...

00800ea8 <__umoddi3>:
  800ea8:	55                   	push   %ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	83 ec 20             	sub    $0x20,%esp
  800eae:	8b 44 24 30          	mov    0x30(%esp),%eax
  800eb2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800eb6:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eba:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ebe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ec2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ec6:	89 c7                	mov    %eax,%edi
  800ec8:	89 f2                	mov    %esi,%edx
  800eca:	85 ed                	test   %ebp,%ebp
  800ecc:	75 16                	jne    800ee4 <__umoddi3+0x3c>
  800ece:	39 f1                	cmp    %esi,%ecx
  800ed0:	0f 86 a6 00 00 00    	jbe    800f7c <__umoddi3+0xd4>
  800ed6:	f7 f1                	div    %ecx
  800ed8:	89 d0                	mov    %edx,%eax
  800eda:	31 d2                	xor    %edx,%edx
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
  800ee3:	90                   	nop
  800ee4:	39 f5                	cmp    %esi,%ebp
  800ee6:	0f 87 ac 00 00 00    	ja     800f98 <__umoddi3+0xf0>
  800eec:	0f bd c5             	bsr    %ebp,%eax
  800eef:	83 f0 1f             	xor    $0x1f,%eax
  800ef2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef6:	0f 84 a8 00 00 00    	je     800fa4 <__umoddi3+0xfc>
  800efc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f00:	d3 e5                	shl    %cl,%ebp
  800f02:	bf 20 00 00 00       	mov    $0x20,%edi
  800f07:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f0f:	89 f9                	mov    %edi,%ecx
  800f11:	d3 e8                	shr    %cl,%eax
  800f13:	09 e8                	or     %ebp,%eax
  800f15:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f19:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f1d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f21:	d3 e0                	shl    %cl,%eax
  800f23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f27:	89 f2                	mov    %esi,%edx
  800f29:	d3 e2                	shl    %cl,%edx
  800f2b:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f2f:	d3 e0                	shl    %cl,%eax
  800f31:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f35:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f39:	89 f9                	mov    %edi,%ecx
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	09 d0                	or     %edx,%eax
  800f3f:	d3 ee                	shr    %cl,%esi
  800f41:	89 f2                	mov    %esi,%edx
  800f43:	f7 74 24 18          	divl   0x18(%esp)
  800f47:	89 d6                	mov    %edx,%esi
  800f49:	f7 64 24 0c          	mull   0xc(%esp)
  800f4d:	89 c5                	mov    %eax,%ebp
  800f4f:	89 d1                	mov    %edx,%ecx
  800f51:	39 d6                	cmp    %edx,%esi
  800f53:	72 67                	jb     800fbc <__umoddi3+0x114>
  800f55:	74 75                	je     800fcc <__umoddi3+0x124>
  800f57:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f5b:	29 e8                	sub    %ebp,%eax
  800f5d:	19 ce                	sbb    %ecx,%esi
  800f5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f63:	d3 e8                	shr    %cl,%eax
  800f65:	89 f2                	mov    %esi,%edx
  800f67:	89 f9                	mov    %edi,%ecx
  800f69:	d3 e2                	shl    %cl,%edx
  800f6b:	09 d0                	or     %edx,%eax
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f73:	d3 ea                	shr    %cl,%edx
  800f75:	83 c4 20             	add    $0x20,%esp
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
  800f7c:	85 c9                	test   %ecx,%ecx
  800f7e:	75 0b                	jne    800f8b <__umoddi3+0xe3>
  800f80:	b8 01 00 00 00       	mov    $0x1,%eax
  800f85:	31 d2                	xor    %edx,%edx
  800f87:	f7 f1                	div    %ecx
  800f89:	89 c1                	mov    %eax,%ecx
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	31 d2                	xor    %edx,%edx
  800f8f:	f7 f1                	div    %ecx
  800f91:	89 f8                	mov    %edi,%eax
  800f93:	e9 3e ff ff ff       	jmp    800ed6 <__umoddi3+0x2e>
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	83 c4 20             	add    $0x20,%esp
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    
  800fa1:	8d 76 00             	lea    0x0(%esi),%esi
  800fa4:	39 f5                	cmp    %esi,%ebp
  800fa6:	72 04                	jb     800fac <__umoddi3+0x104>
  800fa8:	39 f9                	cmp    %edi,%ecx
  800faa:	77 06                	ja     800fb2 <__umoddi3+0x10a>
  800fac:	89 f2                	mov    %esi,%edx
  800fae:	29 cf                	sub    %ecx,%edi
  800fb0:	19 ea                	sbb    %ebp,%edx
  800fb2:	89 f8                	mov    %edi,%eax
  800fb4:	83 c4 20             	add    $0x20,%esp
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    
  800fbb:	90                   	nop
  800fbc:	89 d1                	mov    %edx,%ecx
  800fbe:	89 c5                	mov    %eax,%ebp
  800fc0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fc4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fc8:	eb 8d                	jmp    800f57 <__umoddi3+0xaf>
  800fca:	66 90                	xchg   %ax,%ax
  800fcc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fd0:	72 ea                	jb     800fbc <__umoddi3+0x114>
  800fd2:	89 f1                	mov    %esi,%ecx
  800fd4:	eb 81                	jmp    800f57 <__umoddi3+0xaf>
