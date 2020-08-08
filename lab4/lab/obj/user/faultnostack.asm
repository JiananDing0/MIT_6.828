
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 a8 03 80 	movl   $0x8003a8,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 90 02 00 00       	call   8002de <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80006a:	e8 e4 00 00 00       	call   800153 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x39>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800095:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800099:	89 34 24             	mov    %esi,(%esp)
  80009c:	e8 93 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bd:	e8 3f 00 00 00       	call   800101 <sys_env_destroy>
}
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7e 28                	jle    80014b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	89 44 24 10          	mov    %eax,0x10(%esp)
  800127:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800146:	e8 81 02 00 00       	call   8003cc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014b:	83 c4 2c             	add    $0x2c,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_yield>:

void
sys_yield(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	be 00 00 00 00       	mov    $0x0,%esi
  80019f:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	89 f7                	mov    %esi,%edi
  8001af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	7e 28                	jle    8001dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8001d8:	e8 ef 01 00 00       	call   8003cc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001dd:	83 c4 2c             	add    $0x2c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 28                	jle    800230 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800213:	00 
  800214:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  80021b:	00 
  80021c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800223:	00 
  800224:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  80022b:	e8 9c 01 00 00       	call   8003cc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800230:	83 c4 2c             	add    $0x2c,%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	b8 06 00 00 00       	mov    $0x6,%eax
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	89 df                	mov    %ebx,%edi
  800253:	89 de                	mov    %ebx,%esi
  800255:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800257:	85 c0                	test   %eax,%eax
  800259:	7e 28                	jle    800283 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800266:	00 
  800267:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  80027e:	e8 49 01 00 00       	call   8003cc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800283:	83 c4 2c             	add    $0x2c,%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 08 00 00 00       	mov    $0x8,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  8002d1:	e8 f6 00 00 00       	call   8003cc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d6:	83 c4 2c             	add    $0x2c,%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7e 28                	jle    800329 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	89 44 24 10          	mov    %eax,0x10(%esp)
  800305:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80030c:	00 
  80030d:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800314:	00 
  800315:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031c:	00 
  80031d:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800324:	e8 a3 00 00 00       	call   8003cc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800329:	83 c4 2c             	add    $0x2c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800337:	be 00 00 00 00       	mov    $0x0,%esi
  80033c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800341:	8b 7d 14             	mov    0x14(%ebp),%edi
  800344:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800347:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034a:	8b 55 08             	mov    0x8(%ebp),%edx
  80034d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	b8 0c 00 00 00       	mov    $0xc,%eax
  800367:	8b 55 08             	mov    0x8(%ebp),%edx
  80036a:	89 cb                	mov    %ecx,%ebx
  80036c:	89 cf                	mov    %ecx,%edi
  80036e:	89 ce                	mov    %ecx,%esi
  800370:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7e 28                	jle    80039e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800381:	00 
  800382:	c7 44 24 08 ca 10 80 	movl   $0x8010ca,0x8(%esp)
  800389:	00 
  80038a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800391:	00 
  800392:	c7 04 24 e7 10 80 00 	movl   $0x8010e7,(%esp)
  800399:	e8 2e 00 00 00       	call   8003cc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80039e:	83 c4 2c             	add    $0x2c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    
	...

008003a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003a9:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8003ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003b0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8003b3:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8003b7:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8003b9:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8003bc:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8003bd:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8003c0:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8003c2:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8003c5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8003c6:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8003c9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8003ca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8003cb:	c3                   	ret    

008003cc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003dd:	e8 71 fd ff ff       	call   800153 <sys_getenvid>
  8003e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f8:	c7 04 24 f8 10 80 00 	movl   $0x8010f8,(%esp)
  8003ff:	e8 c0 00 00 00       	call   8004c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800404:	89 74 24 04          	mov    %esi,0x4(%esp)
  800408:	8b 45 10             	mov    0x10(%ebp),%eax
  80040b:	89 04 24             	mov    %eax,(%esp)
  80040e:	e8 50 00 00 00       	call   800463 <vcprintf>
	cprintf("\n");
  800413:	c7 04 24 1b 11 80 00 	movl   $0x80111b,(%esp)
  80041a:	e8 a5 00 00 00       	call   8004c4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80041f:	cc                   	int3   
  800420:	eb fd                	jmp    80041f <_panic+0x53>
	...

00800424 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	53                   	push   %ebx
  800428:	83 ec 14             	sub    $0x14,%esp
  80042b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80042e:	8b 03                	mov    (%ebx),%eax
  800430:	8b 55 08             	mov    0x8(%ebp),%edx
  800433:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800437:	40                   	inc    %eax
  800438:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80043a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043f:	75 19                	jne    80045a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800441:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800448:	00 
  800449:	8d 43 08             	lea    0x8(%ebx),%eax
  80044c:	89 04 24             	mov    %eax,(%esp)
  80044f:	e8 70 fc ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  800454:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80045a:	ff 43 04             	incl   0x4(%ebx)
}
  80045d:	83 c4 14             	add    $0x14,%esp
  800460:	5b                   	pop    %ebx
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80046c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800473:	00 00 00 
	b.cnt = 0;
  800476:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80047d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800480:	8b 45 0c             	mov    0xc(%ebp),%eax
  800483:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800487:	8b 45 08             	mov    0x8(%ebp),%eax
  80048a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800494:	89 44 24 04          	mov    %eax,0x4(%esp)
  800498:	c7 04 24 24 04 80 00 	movl   $0x800424,(%esp)
  80049f:	e8 82 01 00 00       	call   800626 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	e8 08 fc ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  8004bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c2:	c9                   	leave  
  8004c3:	c3                   	ret    

008004c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d4:	89 04 24             	mov    %eax,(%esp)
  8004d7:	e8 87 ff ff ff       	call   800463 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    
	...

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 3c             	sub    $0x3c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004fd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800500:	85 c0                	test   %eax,%eax
  800502:	75 08                	jne    80050c <printnum+0x2c>
  800504:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800507:	39 45 10             	cmp    %eax,0x10(%ebp)
  80050a:	77 57                	ja     800563 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80050c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800510:	4b                   	dec    %ebx
  800511:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800515:	8b 45 10             	mov    0x10(%ebp),%eax
  800518:	89 44 24 08          	mov    %eax,0x8(%esp)
  80051c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800520:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800524:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80052b:	00 
  80052c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	89 44 24 04          	mov    %eax,0x4(%esp)
  800539:	e8 16 09 00 00       	call   800e54 <__udivdi3>
  80053e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800542:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800546:	89 04 24             	mov    %eax,(%esp)
  800549:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054d:	89 fa                	mov    %edi,%edx
  80054f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800552:	e8 89 ff ff ff       	call   8004e0 <printnum>
  800557:	eb 0f                	jmp    800568 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800559:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800563:	4b                   	dec    %ebx
  800564:	85 db                	test   %ebx,%ebx
  800566:	7f f1                	jg     800559 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800568:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800570:	8b 45 10             	mov    0x10(%ebp),%eax
  800573:	89 44 24 08          	mov    %eax,0x8(%esp)
  800577:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80057e:	00 
  80057f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800582:	89 04 24             	mov    %eax,(%esp)
  800585:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800588:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058c:	e8 e3 09 00 00       	call   800f74 <__umoddi3>
  800591:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800595:	0f be 80 1d 11 80 00 	movsbl 0x80111d(%eax),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005a2:	83 c4 3c             	add    $0x3c,%esp
  8005a5:	5b                   	pop    %ebx
  8005a6:	5e                   	pop    %esi
  8005a7:	5f                   	pop    %edi
  8005a8:	5d                   	pop    %ebp
  8005a9:	c3                   	ret    

008005aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005ad:	83 fa 01             	cmp    $0x1,%edx
  8005b0:	7e 0e                	jle    8005c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005b2:	8b 10                	mov    (%eax),%edx
  8005b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005b7:	89 08                	mov    %ecx,(%eax)
  8005b9:	8b 02                	mov    (%edx),%eax
  8005bb:	8b 52 04             	mov    0x4(%edx),%edx
  8005be:	eb 22                	jmp    8005e2 <getuint+0x38>
	else if (lflag)
  8005c0:	85 d2                	test   %edx,%edx
  8005c2:	74 10                	je     8005d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c9:	89 08                	mov    %ecx,(%eax)
  8005cb:	8b 02                	mov    (%edx),%eax
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d2:	eb 0e                	jmp    8005e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005d4:	8b 10                	mov    (%eax),%edx
  8005d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005d9:	89 08                	mov    %ecx,(%eax)
  8005db:	8b 02                	mov    (%edx),%eax
  8005dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005e2:	5d                   	pop    %ebp
  8005e3:	c3                   	ret    

008005e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005e4:	55                   	push   %ebp
  8005e5:	89 e5                	mov    %esp,%ebp
  8005e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ea:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005ed:	8b 10                	mov    (%eax),%edx
  8005ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8005f2:	73 08                	jae    8005fc <sprintputch+0x18>
		*b->buf++ = ch;
  8005f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005f7:	88 0a                	mov    %cl,(%edx)
  8005f9:	42                   	inc    %edx
  8005fa:	89 10                	mov    %edx,(%eax)
}
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800604:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800607:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060b:	8b 45 10             	mov    0x10(%ebp),%eax
  80060e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800612:	8b 45 0c             	mov    0xc(%ebp),%eax
  800615:	89 44 24 04          	mov    %eax,0x4(%esp)
  800619:	8b 45 08             	mov    0x8(%ebp),%eax
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	e8 02 00 00 00       	call   800626 <vprintfmt>
	va_end(ap);
}
  800624:	c9                   	leave  
  800625:	c3                   	ret    

00800626 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	57                   	push   %edi
  80062a:	56                   	push   %esi
  80062b:	53                   	push   %ebx
  80062c:	83 ec 4c             	sub    $0x4c,%esp
  80062f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800632:	8b 75 10             	mov    0x10(%ebp),%esi
  800635:	eb 12                	jmp    800649 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800637:	85 c0                	test   %eax,%eax
  800639:	0f 84 8b 03 00 00    	je     8009ca <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800649:	0f b6 06             	movzbl (%esi),%eax
  80064c:	46                   	inc    %esi
  80064d:	83 f8 25             	cmp    $0x25,%eax
  800650:	75 e5                	jne    800637 <vprintfmt+0x11>
  800652:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800656:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80065d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800662:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800669:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066e:	eb 26                	jmp    800696 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800673:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800677:	eb 1d                	jmp    800696 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80067c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800680:	eb 14                	jmp    800696 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800685:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80068c:	eb 08                	jmp    800696 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80068e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800691:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	0f b6 06             	movzbl (%esi),%eax
  800699:	8d 56 01             	lea    0x1(%esi),%edx
  80069c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80069f:	8a 16                	mov    (%esi),%dl
  8006a1:	83 ea 23             	sub    $0x23,%edx
  8006a4:	80 fa 55             	cmp    $0x55,%dl
  8006a7:	0f 87 01 03 00 00    	ja     8009ae <vprintfmt+0x388>
  8006ad:	0f b6 d2             	movzbl %dl,%edx
  8006b0:	ff 24 95 e0 11 80 00 	jmp    *0x8011e0(,%edx,4)
  8006b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ba:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006bf:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006c2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006c6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006c9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006cc:	83 fa 09             	cmp    $0x9,%edx
  8006cf:	77 2a                	ja     8006fb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006d1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006d2:	eb eb                	jmp    8006bf <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 50 04             	lea    0x4(%eax),%edx
  8006da:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006df:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006e2:	eb 17                	jmp    8006fb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006e8:	78 98                	js     800682 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ed:	eb a7                	jmp    800696 <vprintfmt+0x70>
  8006ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006f2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006f9:	eb 9b                	jmp    800696 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006ff:	79 95                	jns    800696 <vprintfmt+0x70>
  800701:	eb 8b                	jmp    80068e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800703:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800707:	eb 8d                	jmp    800696 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8d 50 04             	lea    0x4(%eax),%edx
  80070f:	89 55 14             	mov    %edx,0x14(%ebp)
  800712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800716:	8b 00                	mov    (%eax),%eax
  800718:	89 04 24             	mov    %eax,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800721:	e9 23 ff ff ff       	jmp    800649 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	85 c0                	test   %eax,%eax
  800733:	79 02                	jns    800737 <vprintfmt+0x111>
  800735:	f7 d8                	neg    %eax
  800737:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800739:	83 f8 08             	cmp    $0x8,%eax
  80073c:	7f 0b                	jg     800749 <vprintfmt+0x123>
  80073e:	8b 04 85 40 13 80 00 	mov    0x801340(,%eax,4),%eax
  800745:	85 c0                	test   %eax,%eax
  800747:	75 23                	jne    80076c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800749:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80074d:	c7 44 24 08 35 11 80 	movl   $0x801135,0x8(%esp)
  800754:	00 
  800755:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	89 04 24             	mov    %eax,(%esp)
  80075f:	e8 9a fe ff ff       	call   8005fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800764:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800767:	e9 dd fe ff ff       	jmp    800649 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80076c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800770:	c7 44 24 08 3e 11 80 	movl   $0x80113e,0x8(%esp)
  800777:	00 
  800778:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80077c:	8b 55 08             	mov    0x8(%ebp),%edx
  80077f:	89 14 24             	mov    %edx,(%esp)
  800782:	e8 77 fe ff ff       	call   8005fe <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800787:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80078a:	e9 ba fe ff ff       	jmp    800649 <vprintfmt+0x23>
  80078f:	89 f9                	mov    %edi,%ecx
  800791:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800794:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 30                	mov    (%eax),%esi
  8007a2:	85 f6                	test   %esi,%esi
  8007a4:	75 05                	jne    8007ab <vprintfmt+0x185>
				p = "(null)";
  8007a6:	be 2e 11 80 00       	mov    $0x80112e,%esi
			if (width > 0 && padc != '-')
  8007ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007af:	0f 8e 84 00 00 00    	jle    800839 <vprintfmt+0x213>
  8007b5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007b9:	74 7e                	je     800839 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007bf:	89 34 24             	mov    %esi,(%esp)
  8007c2:	e8 ab 02 00 00       	call   800a72 <strnlen>
  8007c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007ca:	29 c2                	sub    %eax,%edx
  8007cc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007cf:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007d3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007d6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007d9:	89 de                	mov    %ebx,%esi
  8007db:	89 d3                	mov    %edx,%ebx
  8007dd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007df:	eb 0b                	jmp    8007ec <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e5:	89 3c 24             	mov    %edi,(%esp)
  8007e8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007eb:	4b                   	dec    %ebx
  8007ec:	85 db                	test   %ebx,%ebx
  8007ee:	7f f1                	jg     8007e1 <vprintfmt+0x1bb>
  8007f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007f3:	89 f3                	mov    %esi,%ebx
  8007f5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007fb:	85 c0                	test   %eax,%eax
  8007fd:	79 05                	jns    800804 <vprintfmt+0x1de>
  8007ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800804:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800807:	29 c2                	sub    %eax,%edx
  800809:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80080c:	eb 2b                	jmp    800839 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80080e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800812:	74 18                	je     80082c <vprintfmt+0x206>
  800814:	8d 50 e0             	lea    -0x20(%eax),%edx
  800817:	83 fa 5e             	cmp    $0x5e,%edx
  80081a:	76 10                	jbe    80082c <vprintfmt+0x206>
					putch('?', putdat);
  80081c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800820:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800827:	ff 55 08             	call   *0x8(%ebp)
  80082a:	eb 0a                	jmp    800836 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80082c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800836:	ff 4d e4             	decl   -0x1c(%ebp)
  800839:	0f be 06             	movsbl (%esi),%eax
  80083c:	46                   	inc    %esi
  80083d:	85 c0                	test   %eax,%eax
  80083f:	74 21                	je     800862 <vprintfmt+0x23c>
  800841:	85 ff                	test   %edi,%edi
  800843:	78 c9                	js     80080e <vprintfmt+0x1e8>
  800845:	4f                   	dec    %edi
  800846:	79 c6                	jns    80080e <vprintfmt+0x1e8>
  800848:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084b:	89 de                	mov    %ebx,%esi
  80084d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800850:	eb 18                	jmp    80086a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800852:	89 74 24 04          	mov    %esi,0x4(%esp)
  800856:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80085d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80085f:	4b                   	dec    %ebx
  800860:	eb 08                	jmp    80086a <vprintfmt+0x244>
  800862:	8b 7d 08             	mov    0x8(%ebp),%edi
  800865:	89 de                	mov    %ebx,%esi
  800867:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80086a:	85 db                	test   %ebx,%ebx
  80086c:	7f e4                	jg     800852 <vprintfmt+0x22c>
  80086e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800871:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800873:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800876:	e9 ce fd ff ff       	jmp    800649 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80087b:	83 f9 01             	cmp    $0x1,%ecx
  80087e:	7e 10                	jle    800890 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8d 50 08             	lea    0x8(%eax),%edx
  800886:	89 55 14             	mov    %edx,0x14(%ebp)
  800889:	8b 30                	mov    (%eax),%esi
  80088b:	8b 78 04             	mov    0x4(%eax),%edi
  80088e:	eb 26                	jmp    8008b6 <vprintfmt+0x290>
	else if (lflag)
  800890:	85 c9                	test   %ecx,%ecx
  800892:	74 12                	je     8008a6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8d 50 04             	lea    0x4(%eax),%edx
  80089a:	89 55 14             	mov    %edx,0x14(%ebp)
  80089d:	8b 30                	mov    (%eax),%esi
  80089f:	89 f7                	mov    %esi,%edi
  8008a1:	c1 ff 1f             	sar    $0x1f,%edi
  8008a4:	eb 10                	jmp    8008b6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8d 50 04             	lea    0x4(%eax),%edx
  8008ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8008af:	8b 30                	mov    (%eax),%esi
  8008b1:	89 f7                	mov    %esi,%edi
  8008b3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008b6:	85 ff                	test   %edi,%edi
  8008b8:	78 0a                	js     8008c4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008bf:	e9 ac 00 00 00       	jmp    800970 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008d2:	f7 de                	neg    %esi
  8008d4:	83 d7 00             	adc    $0x0,%edi
  8008d7:	f7 df                	neg    %edi
			}
			base = 10;
  8008d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008de:	e9 8d 00 00 00       	jmp    800970 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008e3:	89 ca                	mov    %ecx,%edx
  8008e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e8:	e8 bd fc ff ff       	call   8005aa <getuint>
  8008ed:	89 c6                	mov    %eax,%esi
  8008ef:	89 d7                	mov    %edx,%edi
			base = 10;
  8008f1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008f6:	eb 78                	jmp    800970 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800903:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800906:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80090a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800911:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800914:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800918:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80091f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800922:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800925:	e9 1f fd ff ff       	jmp    800649 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80092a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80092e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800935:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800938:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80093c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800943:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8d 50 04             	lea    0x4(%eax),%edx
  80094c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80094f:	8b 30                	mov    (%eax),%esi
  800951:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800956:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80095b:	eb 13                	jmp    800970 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80095d:	89 ca                	mov    %ecx,%edx
  80095f:	8d 45 14             	lea    0x14(%ebp),%eax
  800962:	e8 43 fc ff ff       	call   8005aa <getuint>
  800967:	89 c6                	mov    %eax,%esi
  800969:	89 d7                	mov    %edx,%edi
			base = 16;
  80096b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800970:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800974:	89 54 24 10          	mov    %edx,0x10(%esp)
  800978:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80097b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80097f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800983:	89 34 24             	mov    %esi,(%esp)
  800986:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098a:	89 da                	mov    %ebx,%edx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	e8 4c fb ff ff       	call   8004e0 <printnum>
			break;
  800994:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800997:	e9 ad fc ff ff       	jmp    800649 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80099c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8009a9:	e9 9b fc ff ff       	jmp    800649 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009b9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009bc:	eb 01                	jmp    8009bf <vprintfmt+0x399>
  8009be:	4e                   	dec    %esi
  8009bf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8009c3:	75 f9                	jne    8009be <vprintfmt+0x398>
  8009c5:	e9 7f fc ff ff       	jmp    800649 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8009ca:	83 c4 4c             	add    $0x4c,%esp
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 28             	sub    $0x28,%esp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009de:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009e1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	74 30                	je     800a23 <vsnprintf+0x51>
  8009f3:	85 d2                	test   %edx,%edx
  8009f5:	7e 33                	jle    800a2a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800a01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a05:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a08:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0c:	c7 04 24 e4 05 80 00 	movl   $0x8005e4,(%esp)
  800a13:	e8 0e fc ff ff       	call   800626 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a21:	eb 0c                	jmp    800a2f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a28:	eb 05                	jmp    800a2f <vsnprintf+0x5d>
  800a2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a37:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a41:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	89 04 24             	mov    %eax,(%esp)
  800a52:	e8 7b ff ff ff       	call   8009d2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    
  800a59:	00 00                	add    %al,(%eax)
	...

00800a5c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	eb 01                	jmp    800a6a <strlen+0xe>
		n++;
  800a69:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a6a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a6e:	75 f9                	jne    800a69 <strlen+0xd>
		n++;
	return n;
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a78:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	eb 01                	jmp    800a83 <strnlen+0x11>
		n++;
  800a82:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a83:	39 d0                	cmp    %edx,%eax
  800a85:	74 06                	je     800a8d <strnlen+0x1b>
  800a87:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a8b:	75 f5                	jne    800a82 <strnlen+0x10>
		n++;
	return n;
}
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800aa1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800aa4:	42                   	inc    %edx
  800aa5:	84 c9                	test   %cl,%cl
  800aa7:	75 f5                	jne    800a9e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	53                   	push   %ebx
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab6:	89 1c 24             	mov    %ebx,(%esp)
  800ab9:	e8 9e ff ff ff       	call   800a5c <strlen>
	strcpy(dst + len, src);
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ac5:	01 d8                	add    %ebx,%eax
  800ac7:	89 04 24             	mov    %eax,(%esp)
  800aca:	e8 c0 ff ff ff       	call   800a8f <strcpy>
	return dst;
}
  800acf:	89 d8                	mov    %ebx,%eax
  800ad1:	83 c4 08             	add    $0x8,%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aea:	eb 0c                	jmp    800af8 <strncpy+0x21>
		*dst++ = *src;
  800aec:	8a 1a                	mov    (%edx),%bl
  800aee:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800af1:	80 3a 01             	cmpb   $0x1,(%edx)
  800af4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af7:	41                   	inc    %ecx
  800af8:	39 f1                	cmp    %esi,%ecx
  800afa:	75 f0                	jne    800aec <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 75 08             	mov    0x8(%ebp),%esi
  800b08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b0e:	85 d2                	test   %edx,%edx
  800b10:	75 0a                	jne    800b1c <strlcpy+0x1c>
  800b12:	89 f0                	mov    %esi,%eax
  800b14:	eb 1a                	jmp    800b30 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b16:	88 18                	mov    %bl,(%eax)
  800b18:	40                   	inc    %eax
  800b19:	41                   	inc    %ecx
  800b1a:	eb 02                	jmp    800b1e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b1e:	4a                   	dec    %edx
  800b1f:	74 0a                	je     800b2b <strlcpy+0x2b>
  800b21:	8a 19                	mov    (%ecx),%bl
  800b23:	84 db                	test   %bl,%bl
  800b25:	75 ef                	jne    800b16 <strlcpy+0x16>
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	eb 02                	jmp    800b2d <strlcpy+0x2d>
  800b2b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b2d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b30:	29 f0                	sub    %esi,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b3f:	eb 02                	jmp    800b43 <strcmp+0xd>
		p++, q++;
  800b41:	41                   	inc    %ecx
  800b42:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b43:	8a 01                	mov    (%ecx),%al
  800b45:	84 c0                	test   %al,%al
  800b47:	74 04                	je     800b4d <strcmp+0x17>
  800b49:	3a 02                	cmp    (%edx),%al
  800b4b:	74 f4                	je     800b41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4d:	0f b6 c0             	movzbl %al,%eax
  800b50:	0f b6 12             	movzbl (%edx),%edx
  800b53:	29 d0                	sub    %edx,%eax
}
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b61:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b64:	eb 03                	jmp    800b69 <strncmp+0x12>
		n--, p++, q++;
  800b66:	4a                   	dec    %edx
  800b67:	40                   	inc    %eax
  800b68:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b69:	85 d2                	test   %edx,%edx
  800b6b:	74 14                	je     800b81 <strncmp+0x2a>
  800b6d:	8a 18                	mov    (%eax),%bl
  800b6f:	84 db                	test   %bl,%bl
  800b71:	74 04                	je     800b77 <strncmp+0x20>
  800b73:	3a 19                	cmp    (%ecx),%bl
  800b75:	74 ef                	je     800b66 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b77:	0f b6 00             	movzbl (%eax),%eax
  800b7a:	0f b6 11             	movzbl (%ecx),%edx
  800b7d:	29 d0                	sub    %edx,%eax
  800b7f:	eb 05                	jmp    800b86 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b92:	eb 05                	jmp    800b99 <strchr+0x10>
		if (*s == c)
  800b94:	38 ca                	cmp    %cl,%dl
  800b96:	74 0c                	je     800ba4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b98:	40                   	inc    %eax
  800b99:	8a 10                	mov    (%eax),%dl
  800b9b:	84 d2                	test   %dl,%dl
  800b9d:	75 f5                	jne    800b94 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800baf:	eb 05                	jmp    800bb6 <strfind+0x10>
		if (*s == c)
  800bb1:	38 ca                	cmp    %cl,%dl
  800bb3:	74 07                	je     800bbc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bb5:	40                   	inc    %eax
  800bb6:	8a 10                	mov    (%eax),%dl
  800bb8:	84 d2                	test   %dl,%dl
  800bba:	75 f5                	jne    800bb1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bcd:	85 c9                	test   %ecx,%ecx
  800bcf:	74 30                	je     800c01 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd7:	75 25                	jne    800bfe <memset+0x40>
  800bd9:	f6 c1 03             	test   $0x3,%cl
  800bdc:	75 20                	jne    800bfe <memset+0x40>
		c &= 0xFF;
  800bde:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be1:	89 d3                	mov    %edx,%ebx
  800be3:	c1 e3 08             	shl    $0x8,%ebx
  800be6:	89 d6                	mov    %edx,%esi
  800be8:	c1 e6 18             	shl    $0x18,%esi
  800beb:	89 d0                	mov    %edx,%eax
  800bed:	c1 e0 10             	shl    $0x10,%eax
  800bf0:	09 f0                	or     %esi,%eax
  800bf2:	09 d0                	or     %edx,%eax
  800bf4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bf9:	fc                   	cld    
  800bfa:	f3 ab                	rep stos %eax,%es:(%edi)
  800bfc:	eb 03                	jmp    800c01 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bfe:	fc                   	cld    
  800bff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c01:	89 f8                	mov    %edi,%eax
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c16:	39 c6                	cmp    %eax,%esi
  800c18:	73 34                	jae    800c4e <memmove+0x46>
  800c1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c1d:	39 d0                	cmp    %edx,%eax
  800c1f:	73 2d                	jae    800c4e <memmove+0x46>
		s += n;
		d += n;
  800c21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c24:	f6 c2 03             	test   $0x3,%dl
  800c27:	75 1b                	jne    800c44 <memmove+0x3c>
  800c29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c2f:	75 13                	jne    800c44 <memmove+0x3c>
  800c31:	f6 c1 03             	test   $0x3,%cl
  800c34:	75 0e                	jne    800c44 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c36:	83 ef 04             	sub    $0x4,%edi
  800c39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c3f:	fd                   	std    
  800c40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c42:	eb 07                	jmp    800c4b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c44:	4f                   	dec    %edi
  800c45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c48:	fd                   	std    
  800c49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c4b:	fc                   	cld    
  800c4c:	eb 20                	jmp    800c6e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c54:	75 13                	jne    800c69 <memmove+0x61>
  800c56:	a8 03                	test   $0x3,%al
  800c58:	75 0f                	jne    800c69 <memmove+0x61>
  800c5a:	f6 c1 03             	test   $0x3,%cl
  800c5d:	75 0a                	jne    800c69 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c5f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c62:	89 c7                	mov    %eax,%edi
  800c64:	fc                   	cld    
  800c65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c67:	eb 05                	jmp    800c6e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c69:	89 c7                	mov    %eax,%edi
  800c6b:	fc                   	cld    
  800c6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c78:	8b 45 10             	mov    0x10(%ebp),%eax
  800c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	89 04 24             	mov    %eax,(%esp)
  800c8c:	e8 77 ff ff ff       	call   800c08 <memmove>
}
  800c91:	c9                   	leave  
  800c92:	c3                   	ret    

00800c93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca7:	eb 16                	jmp    800cbf <memcmp+0x2c>
		if (*s1 != *s2)
  800ca9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800cac:	42                   	inc    %edx
  800cad:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cb1:	38 c8                	cmp    %cl,%al
  800cb3:	74 0a                	je     800cbf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cb5:	0f b6 c0             	movzbl %al,%eax
  800cb8:	0f b6 c9             	movzbl %cl,%ecx
  800cbb:	29 c8                	sub    %ecx,%eax
  800cbd:	eb 09                	jmp    800cc8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbf:	39 da                	cmp    %ebx,%edx
  800cc1:	75 e6                	jne    800ca9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cdb:	eb 05                	jmp    800ce2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cdd:	38 08                	cmp    %cl,(%eax)
  800cdf:	74 05                	je     800ce6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ce1:	40                   	inc    %eax
  800ce2:	39 d0                	cmp    %edx,%eax
  800ce4:	72 f7                	jb     800cdd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf4:	eb 01                	jmp    800cf7 <strtol+0xf>
		s++;
  800cf6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cf7:	8a 02                	mov    (%edx),%al
  800cf9:	3c 20                	cmp    $0x20,%al
  800cfb:	74 f9                	je     800cf6 <strtol+0xe>
  800cfd:	3c 09                	cmp    $0x9,%al
  800cff:	74 f5                	je     800cf6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d01:	3c 2b                	cmp    $0x2b,%al
  800d03:	75 08                	jne    800d0d <strtol+0x25>
		s++;
  800d05:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d06:	bf 00 00 00 00       	mov    $0x0,%edi
  800d0b:	eb 13                	jmp    800d20 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d0d:	3c 2d                	cmp    $0x2d,%al
  800d0f:	75 0a                	jne    800d1b <strtol+0x33>
		s++, neg = 1;
  800d11:	8d 52 01             	lea    0x1(%edx),%edx
  800d14:	bf 01 00 00 00       	mov    $0x1,%edi
  800d19:	eb 05                	jmp    800d20 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d20:	85 db                	test   %ebx,%ebx
  800d22:	74 05                	je     800d29 <strtol+0x41>
  800d24:	83 fb 10             	cmp    $0x10,%ebx
  800d27:	75 28                	jne    800d51 <strtol+0x69>
  800d29:	8a 02                	mov    (%edx),%al
  800d2b:	3c 30                	cmp    $0x30,%al
  800d2d:	75 10                	jne    800d3f <strtol+0x57>
  800d2f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d33:	75 0a                	jne    800d3f <strtol+0x57>
		s += 2, base = 16;
  800d35:	83 c2 02             	add    $0x2,%edx
  800d38:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3d:	eb 12                	jmp    800d51 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d3f:	85 db                	test   %ebx,%ebx
  800d41:	75 0e                	jne    800d51 <strtol+0x69>
  800d43:	3c 30                	cmp    $0x30,%al
  800d45:	75 05                	jne    800d4c <strtol+0x64>
		s++, base = 8;
  800d47:	42                   	inc    %edx
  800d48:	b3 08                	mov    $0x8,%bl
  800d4a:	eb 05                	jmp    800d51 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d51:	b8 00 00 00 00       	mov    $0x0,%eax
  800d56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d58:	8a 0a                	mov    (%edx),%cl
  800d5a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d5d:	80 fb 09             	cmp    $0x9,%bl
  800d60:	77 08                	ja     800d6a <strtol+0x82>
			dig = *s - '0';
  800d62:	0f be c9             	movsbl %cl,%ecx
  800d65:	83 e9 30             	sub    $0x30,%ecx
  800d68:	eb 1e                	jmp    800d88 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d6a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d6d:	80 fb 19             	cmp    $0x19,%bl
  800d70:	77 08                	ja     800d7a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d72:	0f be c9             	movsbl %cl,%ecx
  800d75:	83 e9 57             	sub    $0x57,%ecx
  800d78:	eb 0e                	jmp    800d88 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d7a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d7d:	80 fb 19             	cmp    $0x19,%bl
  800d80:	77 12                	ja     800d94 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d82:	0f be c9             	movsbl %cl,%ecx
  800d85:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d88:	39 f1                	cmp    %esi,%ecx
  800d8a:	7d 0c                	jge    800d98 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d8c:	42                   	inc    %edx
  800d8d:	0f af c6             	imul   %esi,%eax
  800d90:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d92:	eb c4                	jmp    800d58 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d94:	89 c1                	mov    %eax,%ecx
  800d96:	eb 02                	jmp    800d9a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d98:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9e:	74 05                	je     800da5 <strtol+0xbd>
		*endptr = (char *) s;
  800da0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800da5:	85 ff                	test   %edi,%edi
  800da7:	74 04                	je     800dad <strtol+0xc5>
  800da9:	89 c8                	mov    %ecx,%eax
  800dab:	f7 d8                	neg    %eax
}
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
	...

00800db4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dba:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dc1:	0f 85 80 00 00 00    	jne    800e47 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  800dc7:	a1 04 20 80 00       	mov    0x802004,%eax
  800dcc:	8b 40 48             	mov    0x48(%eax),%eax
  800dcf:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800dde:	ee 
  800ddf:	89 04 24             	mov    %eax,(%esp)
  800de2:	e8 aa f3 ff ff       	call   800191 <sys_page_alloc>
  800de7:	85 c0                	test   %eax,%eax
  800de9:	79 20                	jns    800e0b <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  800deb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800def:	c7 44 24 08 64 13 80 	movl   $0x801364,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  800dfe:	00 
  800dff:	c7 04 24 c0 13 80 00 	movl   $0x8013c0,(%esp)
  800e06:	e8 c1 f5 ff ff       	call   8003cc <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  800e0b:	a1 04 20 80 00       	mov    0x802004,%eax
  800e10:	8b 40 48             	mov    0x48(%eax),%eax
  800e13:	c7 44 24 04 a8 03 80 	movl   $0x8003a8,0x4(%esp)
  800e1a:	00 
  800e1b:	89 04 24             	mov    %eax,(%esp)
  800e1e:	e8 bb f4 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
  800e23:	85 c0                	test   %eax,%eax
  800e25:	79 20                	jns    800e47 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  800e27:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2b:	c7 44 24 08 90 13 80 	movl   $0x801390,0x8(%esp)
  800e32:	00 
  800e33:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800e3a:	00 
  800e3b:	c7 04 24 c0 13 80 00 	movl   $0x8013c0,(%esp)
  800e42:	e8 85 f5 ff ff       	call   8003cc <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    
  800e51:	00 00                	add    %al,(%eax)
	...

00800e54 <__udivdi3>:
  800e54:	55                   	push   %ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	83 ec 10             	sub    $0x10,%esp
  800e5a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800e5e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800e62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e66:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800e6a:	89 cd                	mov    %ecx,%ebp
  800e6c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800e70:	85 c0                	test   %eax,%eax
  800e72:	75 2c                	jne    800ea0 <__udivdi3+0x4c>
  800e74:	39 f9                	cmp    %edi,%ecx
  800e76:	77 68                	ja     800ee0 <__udivdi3+0x8c>
  800e78:	85 c9                	test   %ecx,%ecx
  800e7a:	75 0b                	jne    800e87 <__udivdi3+0x33>
  800e7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e81:	31 d2                	xor    %edx,%edx
  800e83:	f7 f1                	div    %ecx
  800e85:	89 c1                	mov    %eax,%ecx
  800e87:	31 d2                	xor    %edx,%edx
  800e89:	89 f8                	mov    %edi,%eax
  800e8b:	f7 f1                	div    %ecx
  800e8d:	89 c7                	mov    %eax,%edi
  800e8f:	89 f0                	mov    %esi,%eax
  800e91:	f7 f1                	div    %ecx
  800e93:	89 c6                	mov    %eax,%esi
  800e95:	89 f0                	mov    %esi,%eax
  800e97:	89 fa                	mov    %edi,%edx
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    
  800ea0:	39 f8                	cmp    %edi,%eax
  800ea2:	77 2c                	ja     800ed0 <__udivdi3+0x7c>
  800ea4:	0f bd f0             	bsr    %eax,%esi
  800ea7:	83 f6 1f             	xor    $0x1f,%esi
  800eaa:	75 4c                	jne    800ef8 <__udivdi3+0xa4>
  800eac:	39 f8                	cmp    %edi,%eax
  800eae:	bf 00 00 00 00       	mov    $0x0,%edi
  800eb3:	72 0a                	jb     800ebf <__udivdi3+0x6b>
  800eb5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800eb9:	0f 87 ad 00 00 00    	ja     800f6c <__udivdi3+0x118>
  800ebf:	be 01 00 00 00       	mov    $0x1,%esi
  800ec4:	89 f0                	mov    %esi,%eax
  800ec6:	89 fa                	mov    %edi,%edx
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    
  800ecf:	90                   	nop
  800ed0:	31 ff                	xor    %edi,%edi
  800ed2:	31 f6                	xor    %esi,%esi
  800ed4:	89 f0                	mov    %esi,%eax
  800ed6:	89 fa                	mov    %edi,%edx
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    
  800edf:	90                   	nop
  800ee0:	89 fa                	mov    %edi,%edx
  800ee2:	89 f0                	mov    %esi,%eax
  800ee4:	f7 f1                	div    %ecx
  800ee6:	89 c6                	mov    %eax,%esi
  800ee8:	31 ff                	xor    %edi,%edi
  800eea:	89 f0                	mov    %esi,%eax
  800eec:	89 fa                	mov    %edi,%edx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	89 f1                	mov    %esi,%ecx
  800efa:	d3 e0                	shl    %cl,%eax
  800efc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f00:	b8 20 00 00 00       	mov    $0x20,%eax
  800f05:	29 f0                	sub    %esi,%eax
  800f07:	89 ea                	mov    %ebp,%edx
  800f09:	88 c1                	mov    %al,%cl
  800f0b:	d3 ea                	shr    %cl,%edx
  800f0d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800f11:	09 ca                	or     %ecx,%edx
  800f13:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f17:	89 f1                	mov    %esi,%ecx
  800f19:	d3 e5                	shl    %cl,%ebp
  800f1b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800f1f:	89 fd                	mov    %edi,%ebp
  800f21:	88 c1                	mov    %al,%cl
  800f23:	d3 ed                	shr    %cl,%ebp
  800f25:	89 fa                	mov    %edi,%edx
  800f27:	89 f1                	mov    %esi,%ecx
  800f29:	d3 e2                	shl    %cl,%edx
  800f2b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f2f:	88 c1                	mov    %al,%cl
  800f31:	d3 ef                	shr    %cl,%edi
  800f33:	09 d7                	or     %edx,%edi
  800f35:	89 f8                	mov    %edi,%eax
  800f37:	89 ea                	mov    %ebp,%edx
  800f39:	f7 74 24 08          	divl   0x8(%esp)
  800f3d:	89 d1                	mov    %edx,%ecx
  800f3f:	89 c7                	mov    %eax,%edi
  800f41:	f7 64 24 0c          	mull   0xc(%esp)
  800f45:	39 d1                	cmp    %edx,%ecx
  800f47:	72 17                	jb     800f60 <__udivdi3+0x10c>
  800f49:	74 09                	je     800f54 <__udivdi3+0x100>
  800f4b:	89 fe                	mov    %edi,%esi
  800f4d:	31 ff                	xor    %edi,%edi
  800f4f:	e9 41 ff ff ff       	jmp    800e95 <__udivdi3+0x41>
  800f54:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f58:	89 f1                	mov    %esi,%ecx
  800f5a:	d3 e2                	shl    %cl,%edx
  800f5c:	39 c2                	cmp    %eax,%edx
  800f5e:	73 eb                	jae    800f4b <__udivdi3+0xf7>
  800f60:	8d 77 ff             	lea    -0x1(%edi),%esi
  800f63:	31 ff                	xor    %edi,%edi
  800f65:	e9 2b ff ff ff       	jmp    800e95 <__udivdi3+0x41>
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	31 f6                	xor    %esi,%esi
  800f6e:	e9 22 ff ff ff       	jmp    800e95 <__udivdi3+0x41>
	...

00800f74 <__umoddi3>:
  800f74:	55                   	push   %ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	83 ec 20             	sub    $0x20,%esp
  800f7a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f7e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800f82:	89 44 24 14          	mov    %eax,0x14(%esp)
  800f86:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f8a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f8e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f92:	89 c7                	mov    %eax,%edi
  800f94:	89 f2                	mov    %esi,%edx
  800f96:	85 ed                	test   %ebp,%ebp
  800f98:	75 16                	jne    800fb0 <__umoddi3+0x3c>
  800f9a:	39 f1                	cmp    %esi,%ecx
  800f9c:	0f 86 a6 00 00 00    	jbe    801048 <__umoddi3+0xd4>
  800fa2:	f7 f1                	div    %ecx
  800fa4:	89 d0                	mov    %edx,%eax
  800fa6:	31 d2                	xor    %edx,%edx
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    
  800faf:	90                   	nop
  800fb0:	39 f5                	cmp    %esi,%ebp
  800fb2:	0f 87 ac 00 00 00    	ja     801064 <__umoddi3+0xf0>
  800fb8:	0f bd c5             	bsr    %ebp,%eax
  800fbb:	83 f0 1f             	xor    $0x1f,%eax
  800fbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc2:	0f 84 a8 00 00 00    	je     801070 <__umoddi3+0xfc>
  800fc8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fcc:	d3 e5                	shl    %cl,%ebp
  800fce:	bf 20 00 00 00       	mov    $0x20,%edi
  800fd3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800fd7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fdb:	89 f9                	mov    %edi,%ecx
  800fdd:	d3 e8                	shr    %cl,%eax
  800fdf:	09 e8                	or     %ebp,%eax
  800fe1:	89 44 24 18          	mov    %eax,0x18(%esp)
  800fe5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800fe9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800fed:	d3 e0                	shl    %cl,%eax
  800fef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	d3 e2                	shl    %cl,%edx
  800ff7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ffb:	d3 e0                	shl    %cl,%eax
  800ffd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  801001:	8b 44 24 14          	mov    0x14(%esp),%eax
  801005:	89 f9                	mov    %edi,%ecx
  801007:	d3 e8                	shr    %cl,%eax
  801009:	09 d0                	or     %edx,%eax
  80100b:	d3 ee                	shr    %cl,%esi
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	f7 74 24 18          	divl   0x18(%esp)
  801013:	89 d6                	mov    %edx,%esi
  801015:	f7 64 24 0c          	mull   0xc(%esp)
  801019:	89 c5                	mov    %eax,%ebp
  80101b:	89 d1                	mov    %edx,%ecx
  80101d:	39 d6                	cmp    %edx,%esi
  80101f:	72 67                	jb     801088 <__umoddi3+0x114>
  801021:	74 75                	je     801098 <__umoddi3+0x124>
  801023:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801027:	29 e8                	sub    %ebp,%eax
  801029:	19 ce                	sbb    %ecx,%esi
  80102b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80102f:	d3 e8                	shr    %cl,%eax
  801031:	89 f2                	mov    %esi,%edx
  801033:	89 f9                	mov    %edi,%ecx
  801035:	d3 e2                	shl    %cl,%edx
  801037:	09 d0                	or     %edx,%eax
  801039:	89 f2                	mov    %esi,%edx
  80103b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80103f:	d3 ea                	shr    %cl,%edx
  801041:	83 c4 20             	add    $0x20,%esp
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    
  801048:	85 c9                	test   %ecx,%ecx
  80104a:	75 0b                	jne    801057 <__umoddi3+0xe3>
  80104c:	b8 01 00 00 00       	mov    $0x1,%eax
  801051:	31 d2                	xor    %edx,%edx
  801053:	f7 f1                	div    %ecx
  801055:	89 c1                	mov    %eax,%ecx
  801057:	89 f0                	mov    %esi,%eax
  801059:	31 d2                	xor    %edx,%edx
  80105b:	f7 f1                	div    %ecx
  80105d:	89 f8                	mov    %edi,%eax
  80105f:	e9 3e ff ff ff       	jmp    800fa2 <__umoddi3+0x2e>
  801064:	89 f2                	mov    %esi,%edx
  801066:	83 c4 20             	add    $0x20,%esp
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    
  80106d:	8d 76 00             	lea    0x0(%esi),%esi
  801070:	39 f5                	cmp    %esi,%ebp
  801072:	72 04                	jb     801078 <__umoddi3+0x104>
  801074:	39 f9                	cmp    %edi,%ecx
  801076:	77 06                	ja     80107e <__umoddi3+0x10a>
  801078:	89 f2                	mov    %esi,%edx
  80107a:	29 cf                	sub    %ecx,%edi
  80107c:	19 ea                	sbb    %ebp,%edx
  80107e:	89 f8                	mov    %edi,%eax
  801080:	83 c4 20             	add    $0x20,%esp
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	90                   	nop
  801088:	89 d1                	mov    %edx,%ecx
  80108a:	89 c5                	mov    %eax,%ebp
  80108c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801090:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801094:	eb 8d                	jmp    801023 <__umoddi3+0xaf>
  801096:	66 90                	xchg   %ax,%ax
  801098:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80109c:	72 ea                	jb     801088 <__umoddi3+0x114>
  80109e:	89 f1                	mov    %esi,%ecx
  8010a0:	eb 81                	jmp    801023 <__umoddi3+0xaf>
