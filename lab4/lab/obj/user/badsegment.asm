
obj/user/badsegment:     file format elf32-i386


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
  80004e:	e8 e4 00 00 00       	call   800137 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	29 d0                	sub    %edx,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x39>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 3f 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7e 28                	jle    80012f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800107:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800112:	00 
  800113:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  80012a:	e8 5d 02 00 00       	call   80038c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012f:	83 c4 2c             	add    $0x2c,%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 02 00 00 00       	mov    $0x2,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_yield>:

void
sys_yield(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 0a 00 00 00       	mov    $0xa,%eax
  800166:	89 d1                	mov    %edx,%ecx
  800168:	89 d3                	mov    %edx,%ebx
  80016a:	89 d7                	mov    %edx,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017e:	be 00 00 00 00       	mov    $0x0,%esi
  800183:	b8 04 00 00 00       	mov    $0x4,%eax
  800188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	89 f7                	mov    %esi,%edi
  800193:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800195:	85 c0                	test   %eax,%eax
  800197:	7e 28                	jle    8001c1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800199:	89 44 24 10          	mov    %eax,0x10(%esp)
  80019d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b4:	00 
  8001b5:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  8001bc:	e8 cb 01 00 00       	call   80038c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	83 c4 2c             	add    $0x2c,%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7e 28                	jle    800214 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8001ff:	00 
  800200:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800207:	00 
  800208:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  80020f:	e8 78 01 00 00       	call   80038c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800214:	83 c4 2c             	add    $0x2c,%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 06 00 00 00       	mov    $0x6,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 28                	jle    800267 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800243:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024a:	00 
  80024b:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  800252:	00 
  800253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025a:	00 
  80025b:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  800262:	e8 25 01 00 00       	call   80038c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800267:	83 c4 2c             	add    $0x2c,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 08 00 00 00       	mov    $0x8,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 28                	jle    8002ba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	89 44 24 10          	mov    %eax,0x10(%esp)
  800296:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80029d:	00 
  80029e:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ad:	00 
  8002ae:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  8002b5:	e8 d2 00 00 00       	call   80038c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ba:	83 c4 2c             	add    $0x2c,%esp
  8002bd:	5b                   	pop    %ebx
  8002be:	5e                   	pop    %esi
  8002bf:	5f                   	pop    %edi
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	57                   	push   %edi
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	89 df                	mov    %ebx,%edi
  8002dd:	89 de                	mov    %ebx,%esi
  8002df:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	7e 28                	jle    80030d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800300:	00 
  800301:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  800308:	e8 7f 00 00 00       	call   80038c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030d:	83 c4 2c             	add    $0x2c,%esp
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	b8 0b 00 00 00       	mov    $0xb,%eax
  800325:	8b 7d 14             	mov    0x14(%ebp),%edi
  800328:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
  80033e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
  800346:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034b:	8b 55 08             	mov    0x8(%ebp),%edx
  80034e:	89 cb                	mov    %ecx,%ebx
  800350:	89 cf                	mov    %ecx,%edi
  800352:	89 ce                	mov    %ecx,%esi
  800354:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800356:	85 c0                	test   %eax,%eax
  800358:	7e 28                	jle    800382 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800365:	00 
  800366:	c7 44 24 08 ea 0f 80 	movl   $0x800fea,0x8(%esp)
  80036d:	00 
  80036e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800375:	00 
  800376:	c7 04 24 07 10 80 00 	movl   $0x801007,(%esp)
  80037d:	e8 0a 00 00 00       	call   80038c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800382:	83 c4 2c             	add    $0x2c,%esp
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    
	...

0080038c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
  800391:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800394:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800397:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80039d:	e8 95 fd ff ff       	call   800137 <sys_getenvid>
  8003a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003a5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	c7 04 24 18 10 80 00 	movl   $0x801018,(%esp)
  8003bf:	e8 c0 00 00 00       	call   800484 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	e8 50 00 00 00       	call   800423 <vcprintf>
	cprintf("\n");
  8003d3:	c7 04 24 3c 10 80 00 	movl   $0x80103c,(%esp)
  8003da:	e8 a5 00 00 00       	call   800484 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003df:	cc                   	int3   
  8003e0:	eb fd                	jmp    8003df <_panic+0x53>
	...

008003e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	53                   	push   %ebx
  8003e8:	83 ec 14             	sub    $0x14,%esp
  8003eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ee:	8b 03                	mov    (%ebx),%eax
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003f7:	40                   	inc    %eax
  8003f8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ff:	75 19                	jne    80041a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800401:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800408:	00 
  800409:	8d 43 08             	lea    0x8(%ebx),%eax
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 94 fc ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80041a:	ff 43 04             	incl   0x4(%ebx)
}
  80041d:	83 c4 14             	add    $0x14,%esp
  800420:	5b                   	pop    %ebx
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80042c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800433:	00 00 00 
	b.cnt = 0;
  800436:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80043d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800440:	8b 45 0c             	mov    0xc(%ebp),%eax
  800443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80044e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800454:	89 44 24 04          	mov    %eax,0x4(%esp)
  800458:	c7 04 24 e4 03 80 00 	movl   $0x8003e4,(%esp)
  80045f:	e8 82 01 00 00       	call   8005e6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800464:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80046a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800474:	89 04 24             	mov    %eax,(%esp)
  800477:	e8 2c fc ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  80047c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80048a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	8b 45 08             	mov    0x8(%ebp),%eax
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	e8 87 ff ff ff       	call   800423 <vcprintf>
	va_end(ap);

	return cnt;
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
	...

008004a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 3c             	sub    $0x3c,%esp
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	89 d7                	mov    %edx,%edi
  8004ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004bd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	75 08                	jne    8004cc <printnum+0x2c>
  8004c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004ca:	77 57                	ja     800523 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004cc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004d0:	4b                   	dec    %ebx
  8004d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004dc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004e0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004eb:	00 
  8004ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f9:	e8 76 08 00 00       	call   800d74 <__udivdi3>
  8004fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800502:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	89 54 24 04          	mov    %edx,0x4(%esp)
  80050d:	89 fa                	mov    %edi,%edx
  80050f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800512:	e8 89 ff ff ff       	call   8004a0 <printnum>
  800517:	eb 0f                	jmp    800528 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800519:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80051d:	89 34 24             	mov    %esi,(%esp)
  800520:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800523:	4b                   	dec    %ebx
  800524:	85 db                	test   %ebx,%ebx
  800526:	7f f1                	jg     800519 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800528:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800530:	8b 45 10             	mov    0x10(%ebp),%eax
  800533:	89 44 24 08          	mov    %eax,0x8(%esp)
  800537:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80053e:	00 
  80053f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	e8 43 09 00 00       	call   800e94 <__umoddi3>
  800551:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800555:	0f be 80 3e 10 80 00 	movsbl 0x80103e(%eax),%eax
  80055c:	89 04 24             	mov    %eax,(%esp)
  80055f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800562:	83 c4 3c             	add    $0x3c,%esp
  800565:	5b                   	pop    %ebx
  800566:	5e                   	pop    %esi
  800567:	5f                   	pop    %edi
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    

0080056a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80056d:	83 fa 01             	cmp    $0x1,%edx
  800570:	7e 0e                	jle    800580 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800572:	8b 10                	mov    (%eax),%edx
  800574:	8d 4a 08             	lea    0x8(%edx),%ecx
  800577:	89 08                	mov    %ecx,(%eax)
  800579:	8b 02                	mov    (%edx),%eax
  80057b:	8b 52 04             	mov    0x4(%edx),%edx
  80057e:	eb 22                	jmp    8005a2 <getuint+0x38>
	else if (lflag)
  800580:	85 d2                	test   %edx,%edx
  800582:	74 10                	je     800594 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800584:	8b 10                	mov    (%eax),%edx
  800586:	8d 4a 04             	lea    0x4(%edx),%ecx
  800589:	89 08                	mov    %ecx,(%eax)
  80058b:	8b 02                	mov    (%edx),%eax
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	eb 0e                	jmp    8005a2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800594:	8b 10                	mov    (%eax),%edx
  800596:	8d 4a 04             	lea    0x4(%edx),%ecx
  800599:	89 08                	mov    %ecx,(%eax)
  80059b:	8b 02                	mov    (%edx),%eax
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005a2:	5d                   	pop    %ebp
  8005a3:	c3                   	ret    

008005a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005aa:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b2:	73 08                	jae    8005bc <sprintputch+0x18>
		*b->buf++ = ch;
  8005b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005b7:	88 0a                	mov    %cl,(%edx)
  8005b9:	42                   	inc    %edx
  8005ba:	89 10                	mov    %edx,(%eax)
}
  8005bc:	5d                   	pop    %ebp
  8005bd:	c3                   	ret    

008005be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
  8005c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	e8 02 00 00 00       	call   8005e6 <vprintfmt>
	va_end(ap);
}
  8005e4:	c9                   	leave  
  8005e5:	c3                   	ret    

008005e6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005e6:	55                   	push   %ebp
  8005e7:	89 e5                	mov    %esp,%ebp
  8005e9:	57                   	push   %edi
  8005ea:	56                   	push   %esi
  8005eb:	53                   	push   %ebx
  8005ec:	83 ec 4c             	sub    $0x4c,%esp
  8005ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f2:	8b 75 10             	mov    0x10(%ebp),%esi
  8005f5:	eb 12                	jmp    800609 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	0f 84 8b 03 00 00    	je     80098a <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  8005ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800609:	0f b6 06             	movzbl (%esi),%eax
  80060c:	46                   	inc    %esi
  80060d:	83 f8 25             	cmp    $0x25,%eax
  800610:	75 e5                	jne    8005f7 <vprintfmt+0x11>
  800612:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800616:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80061d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800622:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800629:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062e:	eb 26                	jmp    800656 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800633:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800637:	eb 1d                	jmp    800656 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80063c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800640:	eb 14                	jmp    800656 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800645:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80064c:	eb 08                	jmp    800656 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80064e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800651:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	0f b6 06             	movzbl (%esi),%eax
  800659:	8d 56 01             	lea    0x1(%esi),%edx
  80065c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80065f:	8a 16                	mov    (%esi),%dl
  800661:	83 ea 23             	sub    $0x23,%edx
  800664:	80 fa 55             	cmp    $0x55,%dl
  800667:	0f 87 01 03 00 00    	ja     80096e <vprintfmt+0x388>
  80066d:	0f b6 d2             	movzbl %dl,%edx
  800670:	ff 24 95 00 11 80 00 	jmp    *0x801100(,%edx,4)
  800677:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80067f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800682:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800686:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800689:	8d 50 d0             	lea    -0x30(%eax),%edx
  80068c:	83 fa 09             	cmp    $0x9,%edx
  80068f:	77 2a                	ja     8006bb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800691:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800692:	eb eb                	jmp    80067f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006a2:	eb 17                	jmp    8006bb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006a8:	78 98                	js     800642 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ad:	eb a7                	jmp    800656 <vprintfmt+0x70>
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006b2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006b9:	eb 9b                	jmp    800656 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006bf:	79 95                	jns    800656 <vprintfmt+0x70>
  8006c1:	eb 8b                	jmp    80064e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006c3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006c7:	eb 8d                	jmp    800656 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006de:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006e1:	e9 23 ff ff ff       	jmp    800609 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	79 02                	jns    8006f7 <vprintfmt+0x111>
  8006f5:	f7 d8                	neg    %eax
  8006f7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f9:	83 f8 08             	cmp    $0x8,%eax
  8006fc:	7f 0b                	jg     800709 <vprintfmt+0x123>
  8006fe:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  800705:	85 c0                	test   %eax,%eax
  800707:	75 23                	jne    80072c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800709:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80070d:	c7 44 24 08 56 10 80 	movl   $0x801056,0x8(%esp)
  800714:	00 
  800715:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	e8 9a fe ff ff       	call   8005be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800727:	e9 dd fe ff ff       	jmp    800609 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80072c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800730:	c7 44 24 08 5f 10 80 	movl   $0x80105f,0x8(%esp)
  800737:	00 
  800738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
  80073f:	89 14 24             	mov    %edx,(%esp)
  800742:	e8 77 fe ff ff       	call   8005be <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800747:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80074a:	e9 ba fe ff ff       	jmp    800609 <vprintfmt+0x23>
  80074f:	89 f9                	mov    %edi,%ecx
  800751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800754:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 50 04             	lea    0x4(%eax),%edx
  80075d:	89 55 14             	mov    %edx,0x14(%ebp)
  800760:	8b 30                	mov    (%eax),%esi
  800762:	85 f6                	test   %esi,%esi
  800764:	75 05                	jne    80076b <vprintfmt+0x185>
				p = "(null)";
  800766:	be 4f 10 80 00       	mov    $0x80104f,%esi
			if (width > 0 && padc != '-')
  80076b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80076f:	0f 8e 84 00 00 00    	jle    8007f9 <vprintfmt+0x213>
  800775:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800779:	74 7e                	je     8007f9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80077b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80077f:	89 34 24             	mov    %esi,(%esp)
  800782:	e8 ab 02 00 00       	call   800a32 <strnlen>
  800787:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80078a:	29 c2                	sub    %eax,%edx
  80078c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80078f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800793:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800796:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800799:	89 de                	mov    %ebx,%esi
  80079b:	89 d3                	mov    %edx,%ebx
  80079d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	eb 0b                	jmp    8007ac <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a5:	89 3c 24             	mov    %edi,(%esp)
  8007a8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ab:	4b                   	dec    %ebx
  8007ac:	85 db                	test   %ebx,%ebx
  8007ae:	7f f1                	jg     8007a1 <vprintfmt+0x1bb>
  8007b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007b3:	89 f3                	mov    %esi,%ebx
  8007b5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	79 05                	jns    8007c4 <vprintfmt+0x1de>
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c7:	29 c2                	sub    %eax,%edx
  8007c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007cc:	eb 2b                	jmp    8007f9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d2:	74 18                	je     8007ec <vprintfmt+0x206>
  8007d4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007d7:	83 fa 5e             	cmp    $0x5e,%edx
  8007da:	76 10                	jbe    8007ec <vprintfmt+0x206>
					putch('?', putdat);
  8007dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007e7:	ff 55 08             	call   *0x8(%ebp)
  8007ea:	eb 0a                	jmp    8007f6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f6:	ff 4d e4             	decl   -0x1c(%ebp)
  8007f9:	0f be 06             	movsbl (%esi),%eax
  8007fc:	46                   	inc    %esi
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 21                	je     800822 <vprintfmt+0x23c>
  800801:	85 ff                	test   %edi,%edi
  800803:	78 c9                	js     8007ce <vprintfmt+0x1e8>
  800805:	4f                   	dec    %edi
  800806:	79 c6                	jns    8007ce <vprintfmt+0x1e8>
  800808:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080b:	89 de                	mov    %ebx,%esi
  80080d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800810:	eb 18                	jmp    80082a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800812:	89 74 24 04          	mov    %esi,0x4(%esp)
  800816:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80081d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80081f:	4b                   	dec    %ebx
  800820:	eb 08                	jmp    80082a <vprintfmt+0x244>
  800822:	8b 7d 08             	mov    0x8(%ebp),%edi
  800825:	89 de                	mov    %ebx,%esi
  800827:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80082a:	85 db                	test   %ebx,%ebx
  80082c:	7f e4                	jg     800812 <vprintfmt+0x22c>
  80082e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800831:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800833:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800836:	e9 ce fd ff ff       	jmp    800609 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083b:	83 f9 01             	cmp    $0x1,%ecx
  80083e:	7e 10                	jle    800850 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	8d 50 08             	lea    0x8(%eax),%edx
  800846:	89 55 14             	mov    %edx,0x14(%ebp)
  800849:	8b 30                	mov    (%eax),%esi
  80084b:	8b 78 04             	mov    0x4(%eax),%edi
  80084e:	eb 26                	jmp    800876 <vprintfmt+0x290>
	else if (lflag)
  800850:	85 c9                	test   %ecx,%ecx
  800852:	74 12                	je     800866 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 30                	mov    (%eax),%esi
  80085f:	89 f7                	mov    %esi,%edi
  800861:	c1 ff 1f             	sar    $0x1f,%edi
  800864:	eb 10                	jmp    800876 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800866:	8b 45 14             	mov    0x14(%ebp),%eax
  800869:	8d 50 04             	lea    0x4(%eax),%edx
  80086c:	89 55 14             	mov    %edx,0x14(%ebp)
  80086f:	8b 30                	mov    (%eax),%esi
  800871:	89 f7                	mov    %esi,%edi
  800873:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800876:	85 ff                	test   %edi,%edi
  800878:	78 0a                	js     800884 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80087a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087f:	e9 ac 00 00 00       	jmp    800930 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800884:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800888:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800892:	f7 de                	neg    %esi
  800894:	83 d7 00             	adc    $0x0,%edi
  800897:	f7 df                	neg    %edi
			}
			base = 10;
  800899:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089e:	e9 8d 00 00 00       	jmp    800930 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008a3:	89 ca                	mov    %ecx,%edx
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a8:	e8 bd fc ff ff       	call   80056a <getuint>
  8008ad:	89 c6                	mov    %eax,%esi
  8008af:	89 d7                	mov    %edx,%edi
			base = 10;
  8008b1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008b6:	eb 78                	jmp    800930 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008c3:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ca:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008d1:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008df:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008e5:	e9 1f fd ff ff       	jmp    800609 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800903:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8d 50 04             	lea    0x4(%eax),%edx
  80090c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80090f:	8b 30                	mov    (%eax),%esi
  800911:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800916:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80091b:	eb 13                	jmp    800930 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80091d:	89 ca                	mov    %ecx,%edx
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 43 fc ff ff       	call   80056a <getuint>
  800927:	89 c6                	mov    %eax,%esi
  800929:	89 d7                	mov    %edx,%edi
			base = 16;
  80092b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800930:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800934:	89 54 24 10          	mov    %edx,0x10(%esp)
  800938:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80093b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80093f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800943:	89 34 24             	mov    %esi,(%esp)
  800946:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80094a:	89 da                	mov    %ebx,%edx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	e8 4c fb ff ff       	call   8004a0 <printnum>
			break;
  800954:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800957:	e9 ad fc ff ff       	jmp    800609 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80095c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800960:	89 04 24             	mov    %eax,(%esp)
  800963:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800969:	e9 9b fc ff ff       	jmp    800609 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800972:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800979:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80097c:	eb 01                	jmp    80097f <vprintfmt+0x399>
  80097e:	4e                   	dec    %esi
  80097f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800983:	75 f9                	jne    80097e <vprintfmt+0x398>
  800985:	e9 7f fc ff ff       	jmp    800609 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80098a:	83 c4 4c             	add    $0x4c,%esp
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 28             	sub    $0x28,%esp
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	74 30                	je     8009e3 <vsnprintf+0x51>
  8009b3:	85 d2                	test   %edx,%edx
  8009b5:	7e 33                	jle    8009ea <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009be:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cc:	c7 04 24 a4 05 80 00 	movl   $0x8005a4,(%esp)
  8009d3:	e8 0e fc ff ff       	call   8005e6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e1:	eb 0c                	jmp    8009ef <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e8:	eb 05                	jmp    8009ef <vsnprintf+0x5d>
  8009ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800a01:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	89 04 24             	mov    %eax,(%esp)
  800a12:	e8 7b ff ff ff       	call   800992 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    
  800a19:	00 00                	add    %al,(%eax)
	...

00800a1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	eb 01                	jmp    800a2a <strlen+0xe>
		n++;
  800a29:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a2e:	75 f9                	jne    800a29 <strlen+0xd>
		n++;
	return n;
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	eb 01                	jmp    800a43 <strnlen+0x11>
		n++;
  800a42:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a43:	39 d0                	cmp    %edx,%eax
  800a45:	74 06                	je     800a4d <strnlen+0x1b>
  800a47:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a4b:	75 f5                	jne    800a42 <strnlen+0x10>
		n++;
	return n;
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	53                   	push   %ebx
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a61:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a64:	42                   	inc    %edx
  800a65:	84 c9                	test   %cl,%cl
  800a67:	75 f5                	jne    800a5e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a69:	5b                   	pop    %ebx
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	83 ec 08             	sub    $0x8,%esp
  800a73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a76:	89 1c 24             	mov    %ebx,(%esp)
  800a79:	e8 9e ff ff ff       	call   800a1c <strlen>
	strcpy(dst + len, src);
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a85:	01 d8                	add    %ebx,%eax
  800a87:	89 04 24             	mov    %eax,(%esp)
  800a8a:	e8 c0 ff ff ff       	call   800a4f <strcpy>
	return dst;
}
  800a8f:	89 d8                	mov    %ebx,%eax
  800a91:	83 c4 08             	add    $0x8,%esp
  800a94:	5b                   	pop    %ebx
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaa:	eb 0c                	jmp    800ab8 <strncpy+0x21>
		*dst++ = *src;
  800aac:	8a 1a                	mov    (%edx),%bl
  800aae:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab1:	80 3a 01             	cmpb   $0x1,(%edx)
  800ab4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab7:	41                   	inc    %ecx
  800ab8:	39 f1                	cmp    %esi,%ecx
  800aba:	75 f0                	jne    800aac <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ace:	85 d2                	test   %edx,%edx
  800ad0:	75 0a                	jne    800adc <strlcpy+0x1c>
  800ad2:	89 f0                	mov    %esi,%eax
  800ad4:	eb 1a                	jmp    800af0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ad6:	88 18                	mov    %bl,(%eax)
  800ad8:	40                   	inc    %eax
  800ad9:	41                   	inc    %ecx
  800ada:	eb 02                	jmp    800ade <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800adc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ade:	4a                   	dec    %edx
  800adf:	74 0a                	je     800aeb <strlcpy+0x2b>
  800ae1:	8a 19                	mov    (%ecx),%bl
  800ae3:	84 db                	test   %bl,%bl
  800ae5:	75 ef                	jne    800ad6 <strlcpy+0x16>
  800ae7:	89 c2                	mov    %eax,%edx
  800ae9:	eb 02                	jmp    800aed <strlcpy+0x2d>
  800aeb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800aed:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800af0:	29 f0                	sub    %esi,%eax
}
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aff:	eb 02                	jmp    800b03 <strcmp+0xd>
		p++, q++;
  800b01:	41                   	inc    %ecx
  800b02:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b03:	8a 01                	mov    (%ecx),%al
  800b05:	84 c0                	test   %al,%al
  800b07:	74 04                	je     800b0d <strcmp+0x17>
  800b09:	3a 02                	cmp    (%edx),%al
  800b0b:	74 f4                	je     800b01 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0d:	0f b6 c0             	movzbl %al,%eax
  800b10:	0f b6 12             	movzbl (%edx),%edx
  800b13:	29 d0                	sub    %edx,%eax
}
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	53                   	push   %ebx
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b21:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b24:	eb 03                	jmp    800b29 <strncmp+0x12>
		n--, p++, q++;
  800b26:	4a                   	dec    %edx
  800b27:	40                   	inc    %eax
  800b28:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b29:	85 d2                	test   %edx,%edx
  800b2b:	74 14                	je     800b41 <strncmp+0x2a>
  800b2d:	8a 18                	mov    (%eax),%bl
  800b2f:	84 db                	test   %bl,%bl
  800b31:	74 04                	je     800b37 <strncmp+0x20>
  800b33:	3a 19                	cmp    (%ecx),%bl
  800b35:	74 ef                	je     800b26 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b37:	0f b6 00             	movzbl (%eax),%eax
  800b3a:	0f b6 11             	movzbl (%ecx),%edx
  800b3d:	29 d0                	sub    %edx,%eax
  800b3f:	eb 05                	jmp    800b46 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b46:	5b                   	pop    %ebx
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b52:	eb 05                	jmp    800b59 <strchr+0x10>
		if (*s == c)
  800b54:	38 ca                	cmp    %cl,%dl
  800b56:	74 0c                	je     800b64 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b58:	40                   	inc    %eax
  800b59:	8a 10                	mov    (%eax),%dl
  800b5b:	84 d2                	test   %dl,%dl
  800b5d:	75 f5                	jne    800b54 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b6f:	eb 05                	jmp    800b76 <strfind+0x10>
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 07                	je     800b7c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b75:	40                   	inc    %eax
  800b76:	8a 10                	mov    (%eax),%dl
  800b78:	84 d2                	test   %dl,%dl
  800b7a:	75 f5                	jne    800b71 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b8d:	85 c9                	test   %ecx,%ecx
  800b8f:	74 30                	je     800bc1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b97:	75 25                	jne    800bbe <memset+0x40>
  800b99:	f6 c1 03             	test   $0x3,%cl
  800b9c:	75 20                	jne    800bbe <memset+0x40>
		c &= 0xFF;
  800b9e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	c1 e3 08             	shl    $0x8,%ebx
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	c1 e6 18             	shl    $0x18,%esi
  800bab:	89 d0                	mov    %edx,%eax
  800bad:	c1 e0 10             	shl    $0x10,%eax
  800bb0:	09 f0                	or     %esi,%eax
  800bb2:	09 d0                	or     %edx,%eax
  800bb4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bb6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bb9:	fc                   	cld    
  800bba:	f3 ab                	rep stos %eax,%es:(%edi)
  800bbc:	eb 03                	jmp    800bc1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bbe:	fc                   	cld    
  800bbf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc1:	89 f8                	mov    %edi,%eax
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd6:	39 c6                	cmp    %eax,%esi
  800bd8:	73 34                	jae    800c0e <memmove+0x46>
  800bda:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	73 2d                	jae    800c0e <memmove+0x46>
		s += n;
		d += n;
  800be1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be4:	f6 c2 03             	test   $0x3,%dl
  800be7:	75 1b                	jne    800c04 <memmove+0x3c>
  800be9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bef:	75 13                	jne    800c04 <memmove+0x3c>
  800bf1:	f6 c1 03             	test   $0x3,%cl
  800bf4:	75 0e                	jne    800c04 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf6:	83 ef 04             	sub    $0x4,%edi
  800bf9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bfc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bff:	fd                   	std    
  800c00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c02:	eb 07                	jmp    800c0b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c04:	4f                   	dec    %edi
  800c05:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c08:	fd                   	std    
  800c09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c0b:	fc                   	cld    
  800c0c:	eb 20                	jmp    800c2e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c14:	75 13                	jne    800c29 <memmove+0x61>
  800c16:	a8 03                	test   $0x3,%al
  800c18:	75 0f                	jne    800c29 <memmove+0x61>
  800c1a:	f6 c1 03             	test   $0x3,%cl
  800c1d:	75 0a                	jne    800c29 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c22:	89 c7                	mov    %eax,%edi
  800c24:	fc                   	cld    
  800c25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c27:	eb 05                	jmp    800c2e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c29:	89 c7                	mov    %eax,%edi
  800c2b:	fc                   	cld    
  800c2c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c38:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	89 04 24             	mov    %eax,(%esp)
  800c4c:	e8 77 ff ff ff       	call   800bc8 <memmove>
}
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    

00800c53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c62:	ba 00 00 00 00       	mov    $0x0,%edx
  800c67:	eb 16                	jmp    800c7f <memcmp+0x2c>
		if (*s1 != *s2)
  800c69:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c6c:	42                   	inc    %edx
  800c6d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c71:	38 c8                	cmp    %cl,%al
  800c73:	74 0a                	je     800c7f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c75:	0f b6 c0             	movzbl %al,%eax
  800c78:	0f b6 c9             	movzbl %cl,%ecx
  800c7b:	29 c8                	sub    %ecx,%eax
  800c7d:	eb 09                	jmp    800c88 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7f:	39 da                	cmp    %ebx,%edx
  800c81:	75 e6                	jne    800c69 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c96:	89 c2                	mov    %eax,%edx
  800c98:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c9b:	eb 05                	jmp    800ca2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c9d:	38 08                	cmp    %cl,(%eax)
  800c9f:	74 05                	je     800ca6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca1:	40                   	inc    %eax
  800ca2:	39 d0                	cmp    %edx,%eax
  800ca4:	72 f7                	jb     800c9d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb4:	eb 01                	jmp    800cb7 <strtol+0xf>
		s++;
  800cb6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb7:	8a 02                	mov    (%edx),%al
  800cb9:	3c 20                	cmp    $0x20,%al
  800cbb:	74 f9                	je     800cb6 <strtol+0xe>
  800cbd:	3c 09                	cmp    $0x9,%al
  800cbf:	74 f5                	je     800cb6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc1:	3c 2b                	cmp    $0x2b,%al
  800cc3:	75 08                	jne    800ccd <strtol+0x25>
		s++;
  800cc5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800ccb:	eb 13                	jmp    800ce0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ccd:	3c 2d                	cmp    $0x2d,%al
  800ccf:	75 0a                	jne    800cdb <strtol+0x33>
		s++, neg = 1;
  800cd1:	8d 52 01             	lea    0x1(%edx),%edx
  800cd4:	bf 01 00 00 00       	mov    $0x1,%edi
  800cd9:	eb 05                	jmp    800ce0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cdb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce0:	85 db                	test   %ebx,%ebx
  800ce2:	74 05                	je     800ce9 <strtol+0x41>
  800ce4:	83 fb 10             	cmp    $0x10,%ebx
  800ce7:	75 28                	jne    800d11 <strtol+0x69>
  800ce9:	8a 02                	mov    (%edx),%al
  800ceb:	3c 30                	cmp    $0x30,%al
  800ced:	75 10                	jne    800cff <strtol+0x57>
  800cef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cf3:	75 0a                	jne    800cff <strtol+0x57>
		s += 2, base = 16;
  800cf5:	83 c2 02             	add    $0x2,%edx
  800cf8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cfd:	eb 12                	jmp    800d11 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	75 0e                	jne    800d11 <strtol+0x69>
  800d03:	3c 30                	cmp    $0x30,%al
  800d05:	75 05                	jne    800d0c <strtol+0x64>
		s++, base = 8;
  800d07:	42                   	inc    %edx
  800d08:	b3 08                	mov    $0x8,%bl
  800d0a:	eb 05                	jmp    800d11 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d0c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
  800d16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d18:	8a 0a                	mov    (%edx),%cl
  800d1a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d1d:	80 fb 09             	cmp    $0x9,%bl
  800d20:	77 08                	ja     800d2a <strtol+0x82>
			dig = *s - '0';
  800d22:	0f be c9             	movsbl %cl,%ecx
  800d25:	83 e9 30             	sub    $0x30,%ecx
  800d28:	eb 1e                	jmp    800d48 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d2a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d2d:	80 fb 19             	cmp    $0x19,%bl
  800d30:	77 08                	ja     800d3a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d32:	0f be c9             	movsbl %cl,%ecx
  800d35:	83 e9 57             	sub    $0x57,%ecx
  800d38:	eb 0e                	jmp    800d48 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d3a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d3d:	80 fb 19             	cmp    $0x19,%bl
  800d40:	77 12                	ja     800d54 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d42:	0f be c9             	movsbl %cl,%ecx
  800d45:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d48:	39 f1                	cmp    %esi,%ecx
  800d4a:	7d 0c                	jge    800d58 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d4c:	42                   	inc    %edx
  800d4d:	0f af c6             	imul   %esi,%eax
  800d50:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d52:	eb c4                	jmp    800d18 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d54:	89 c1                	mov    %eax,%ecx
  800d56:	eb 02                	jmp    800d5a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d58:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d5a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5e:	74 05                	je     800d65 <strtol+0xbd>
		*endptr = (char *) s;
  800d60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d63:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d65:	85 ff                	test   %edi,%edi
  800d67:	74 04                	je     800d6d <strtol+0xc5>
  800d69:	89 c8                	mov    %ecx,%eax
  800d6b:	f7 d8                	neg    %eax
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
	...

00800d74 <__udivdi3>:
  800d74:	55                   	push   %ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	83 ec 10             	sub    $0x10,%esp
  800d7a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d7e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d82:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d86:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d8a:	89 cd                	mov    %ecx,%ebp
  800d8c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d90:	85 c0                	test   %eax,%eax
  800d92:	75 2c                	jne    800dc0 <__udivdi3+0x4c>
  800d94:	39 f9                	cmp    %edi,%ecx
  800d96:	77 68                	ja     800e00 <__udivdi3+0x8c>
  800d98:	85 c9                	test   %ecx,%ecx
  800d9a:	75 0b                	jne    800da7 <__udivdi3+0x33>
  800d9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	f7 f1                	div    %ecx
  800da5:	89 c1                	mov    %eax,%ecx
  800da7:	31 d2                	xor    %edx,%edx
  800da9:	89 f8                	mov    %edi,%eax
  800dab:	f7 f1                	div    %ecx
  800dad:	89 c7                	mov    %eax,%edi
  800daf:	89 f0                	mov    %esi,%eax
  800db1:	f7 f1                	div    %ecx
  800db3:	89 c6                	mov    %eax,%esi
  800db5:	89 f0                	mov    %esi,%eax
  800db7:	89 fa                	mov    %edi,%edx
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    
  800dc0:	39 f8                	cmp    %edi,%eax
  800dc2:	77 2c                	ja     800df0 <__udivdi3+0x7c>
  800dc4:	0f bd f0             	bsr    %eax,%esi
  800dc7:	83 f6 1f             	xor    $0x1f,%esi
  800dca:	75 4c                	jne    800e18 <__udivdi3+0xa4>
  800dcc:	39 f8                	cmp    %edi,%eax
  800dce:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd3:	72 0a                	jb     800ddf <__udivdi3+0x6b>
  800dd5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dd9:	0f 87 ad 00 00 00    	ja     800e8c <__udivdi3+0x118>
  800ddf:	be 01 00 00 00       	mov    $0x1,%esi
  800de4:	89 f0                	mov    %esi,%eax
  800de6:	89 fa                	mov    %edi,%edx
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
  800def:	90                   	nop
  800df0:	31 ff                	xor    %edi,%edi
  800df2:	31 f6                	xor    %esi,%esi
  800df4:	89 f0                	mov    %esi,%eax
  800df6:	89 fa                	mov    %edi,%edx
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    
  800dff:	90                   	nop
  800e00:	89 fa                	mov    %edi,%edx
  800e02:	89 f0                	mov    %esi,%eax
  800e04:	f7 f1                	div    %ecx
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	31 ff                	xor    %edi,%edi
  800e0a:	89 f0                	mov    %esi,%eax
  800e0c:	89 fa                	mov    %edi,%edx
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
  800e18:	89 f1                	mov    %esi,%ecx
  800e1a:	d3 e0                	shl    %cl,%eax
  800e1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e20:	b8 20 00 00 00       	mov    $0x20,%eax
  800e25:	29 f0                	sub    %esi,%eax
  800e27:	89 ea                	mov    %ebp,%edx
  800e29:	88 c1                	mov    %al,%cl
  800e2b:	d3 ea                	shr    %cl,%edx
  800e2d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e31:	09 ca                	or     %ecx,%edx
  800e33:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e37:	89 f1                	mov    %esi,%ecx
  800e39:	d3 e5                	shl    %cl,%ebp
  800e3b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e3f:	89 fd                	mov    %edi,%ebp
  800e41:	88 c1                	mov    %al,%cl
  800e43:	d3 ed                	shr    %cl,%ebp
  800e45:	89 fa                	mov    %edi,%edx
  800e47:	89 f1                	mov    %esi,%ecx
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e4f:	88 c1                	mov    %al,%cl
  800e51:	d3 ef                	shr    %cl,%edi
  800e53:	09 d7                	or     %edx,%edi
  800e55:	89 f8                	mov    %edi,%eax
  800e57:	89 ea                	mov    %ebp,%edx
  800e59:	f7 74 24 08          	divl   0x8(%esp)
  800e5d:	89 d1                	mov    %edx,%ecx
  800e5f:	89 c7                	mov    %eax,%edi
  800e61:	f7 64 24 0c          	mull   0xc(%esp)
  800e65:	39 d1                	cmp    %edx,%ecx
  800e67:	72 17                	jb     800e80 <__udivdi3+0x10c>
  800e69:	74 09                	je     800e74 <__udivdi3+0x100>
  800e6b:	89 fe                	mov    %edi,%esi
  800e6d:	31 ff                	xor    %edi,%edi
  800e6f:	e9 41 ff ff ff       	jmp    800db5 <__udivdi3+0x41>
  800e74:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e78:	89 f1                	mov    %esi,%ecx
  800e7a:	d3 e2                	shl    %cl,%edx
  800e7c:	39 c2                	cmp    %eax,%edx
  800e7e:	73 eb                	jae    800e6b <__udivdi3+0xf7>
  800e80:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e83:	31 ff                	xor    %edi,%edi
  800e85:	e9 2b ff ff ff       	jmp    800db5 <__udivdi3+0x41>
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	31 f6                	xor    %esi,%esi
  800e8e:	e9 22 ff ff ff       	jmp    800db5 <__udivdi3+0x41>
	...

00800e94 <__umoddi3>:
  800e94:	55                   	push   %ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	83 ec 20             	sub    $0x20,%esp
  800e9a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e9e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800ea2:	89 44 24 14          	mov    %eax,0x14(%esp)
  800ea6:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eaa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eae:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800eb2:	89 c7                	mov    %eax,%edi
  800eb4:	89 f2                	mov    %esi,%edx
  800eb6:	85 ed                	test   %ebp,%ebp
  800eb8:	75 16                	jne    800ed0 <__umoddi3+0x3c>
  800eba:	39 f1                	cmp    %esi,%ecx
  800ebc:	0f 86 a6 00 00 00    	jbe    800f68 <__umoddi3+0xd4>
  800ec2:	f7 f1                	div    %ecx
  800ec4:	89 d0                	mov    %edx,%eax
  800ec6:	31 d2                	xor    %edx,%edx
  800ec8:	83 c4 20             	add    $0x20,%esp
  800ecb:	5e                   	pop    %esi
  800ecc:	5f                   	pop    %edi
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    
  800ecf:	90                   	nop
  800ed0:	39 f5                	cmp    %esi,%ebp
  800ed2:	0f 87 ac 00 00 00    	ja     800f84 <__umoddi3+0xf0>
  800ed8:	0f bd c5             	bsr    %ebp,%eax
  800edb:	83 f0 1f             	xor    $0x1f,%eax
  800ede:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee2:	0f 84 a8 00 00 00    	je     800f90 <__umoddi3+0xfc>
  800ee8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800eec:	d3 e5                	shl    %cl,%ebp
  800eee:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef3:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800ef7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	d3 e8                	shr    %cl,%eax
  800eff:	09 e8                	or     %ebp,%eax
  800f01:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f05:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f09:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f0d:	d3 e0                	shl    %cl,%eax
  800f0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f13:	89 f2                	mov    %esi,%edx
  800f15:	d3 e2                	shl    %cl,%edx
  800f17:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f1b:	d3 e0                	shl    %cl,%eax
  800f1d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f21:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f25:	89 f9                	mov    %edi,%ecx
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	09 d0                	or     %edx,%eax
  800f2b:	d3 ee                	shr    %cl,%esi
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	f7 74 24 18          	divl   0x18(%esp)
  800f33:	89 d6                	mov    %edx,%esi
  800f35:	f7 64 24 0c          	mull   0xc(%esp)
  800f39:	89 c5                	mov    %eax,%ebp
  800f3b:	89 d1                	mov    %edx,%ecx
  800f3d:	39 d6                	cmp    %edx,%esi
  800f3f:	72 67                	jb     800fa8 <__umoddi3+0x114>
  800f41:	74 75                	je     800fb8 <__umoddi3+0x124>
  800f43:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f47:	29 e8                	sub    %ebp,%eax
  800f49:	19 ce                	sbb    %ecx,%esi
  800f4b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4f:	d3 e8                	shr    %cl,%eax
  800f51:	89 f2                	mov    %esi,%edx
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	d3 e2                	shl    %cl,%edx
  800f57:	09 d0                	or     %edx,%eax
  800f59:	89 f2                	mov    %esi,%edx
  800f5b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f5f:	d3 ea                	shr    %cl,%edx
  800f61:	83 c4 20             	add    $0x20,%esp
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    
  800f68:	85 c9                	test   %ecx,%ecx
  800f6a:	75 0b                	jne    800f77 <__umoddi3+0xe3>
  800f6c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f71:	31 d2                	xor    %edx,%edx
  800f73:	f7 f1                	div    %ecx
  800f75:	89 c1                	mov    %eax,%ecx
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	31 d2                	xor    %edx,%edx
  800f7b:	f7 f1                	div    %ecx
  800f7d:	89 f8                	mov    %edi,%eax
  800f7f:	e9 3e ff ff ff       	jmp    800ec2 <__umoddi3+0x2e>
  800f84:	89 f2                	mov    %esi,%edx
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	39 f5                	cmp    %esi,%ebp
  800f92:	72 04                	jb     800f98 <__umoddi3+0x104>
  800f94:	39 f9                	cmp    %edi,%ecx
  800f96:	77 06                	ja     800f9e <__umoddi3+0x10a>
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	29 cf                	sub    %ecx,%edi
  800f9c:	19 ea                	sbb    %ebp,%edx
  800f9e:	89 f8                	mov    %edi,%eax
  800fa0:	83 c4 20             	add    $0x20,%esp
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    
  800fa7:	90                   	nop
  800fa8:	89 d1                	mov    %edx,%ecx
  800faa:	89 c5                	mov    %eax,%ebp
  800fac:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fb0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fb4:	eb 8d                	jmp    800f43 <__umoddi3+0xaf>
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fbc:	72 ea                	jb     800fa8 <__umoddi3+0x114>
  800fbe:	89 f1                	mov    %esi,%ecx
  800fc0:	eb 81                	jmp    800f43 <__umoddi3+0xaf>
