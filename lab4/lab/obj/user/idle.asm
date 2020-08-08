
obj/user/idle:     file format elf32-i386


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
  80003a:	c7 05 00 20 80 00 e0 	movl   $0x800fe0,0x802000
  800041:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 19 01 00 00       	call   800162 <sys_yield>
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
  80005a:	e8 e4 00 00 00       	call   800143 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006b:	c1 e0 07             	shl    $0x7,%eax
  80006e:	29 d0                	sub    %edx,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 07                	jle    800085 <libmain+0x39>
		binaryname = argv[0];
  80007e:	8b 03                	mov    (%ebx),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000

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
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 3f 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  800136:	e8 5d 02 00 00       	call   800398 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	83 c4 2c             	add    $0x2c,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 28                	jle    8001cd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  8001c8:	e8 cb 01 00 00       	call   800398 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cd:	83 c4 2c             	add    $0x2c,%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	7e 28                	jle    800220 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800203:	00 
  800204:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  80021b:	e8 78 01 00 00       	call   800398 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800220:	83 c4 2c             	add    $0x2c,%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	b8 06 00 00 00       	mov    $0x6,%eax
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	89 df                	mov    %ebx,%edi
  800243:	89 de                	mov    %ebx,%esi
  800245:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800247:	85 c0                	test   %eax,%eax
  800249:	7e 28                	jle    800273 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800256:	00 
  800257:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  80025e:	00 
  80025f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800266:	00 
  800267:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  80026e:	e8 25 01 00 00       	call   800398 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800273:	83 c4 2c             	add    $0x2c,%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 08 00 00 00       	mov    $0x8,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 28                	jle    8002c6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b9:	00 
  8002ba:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  8002c1:	e8 d2 00 00 00       	call   800398 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c6:	83 c4 2c             	add    $0x2c,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	89 df                	mov    %ebx,%edi
  8002e9:	89 de                	mov    %ebx,%esi
  8002eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ed:	85 c0                	test   %eax,%eax
  8002ef:	7e 28                	jle    800319 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  800304:	00 
  800305:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  800314:	e8 7f 00 00 00       	call   800398 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800319:	83 c4 2c             	add    $0x2c,%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800327:	be 00 00 00 00       	mov    $0x0,%esi
  80032c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800331:	8b 7d 14             	mov    0x14(%ebp),%edi
  800334:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033a:	8b 55 08             	mov    0x8(%ebp),%edx
  80033d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    

00800344 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	b8 0c 00 00 00       	mov    $0xc,%eax
  800357:	8b 55 08             	mov    0x8(%ebp),%edx
  80035a:	89 cb                	mov    %ecx,%ebx
  80035c:	89 cf                	mov    %ecx,%edi
  80035e:	89 ce                	mov    %ecx,%esi
  800360:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800362:	85 c0                	test   %eax,%eax
  800364:	7e 28                	jle    80038e <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800366:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 ef 0f 80 	movl   $0x800fef,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 0c 10 80 00 	movl   $0x80100c,(%esp)
  800389:	e8 0a 00 00 00       	call   800398 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038e:	83 c4 2c             	add    $0x2c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    
	...

00800398 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003a9:	e8 95 fd ff ff       	call   800143 <sys_getenvid>
  8003ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003cb:	e8 c0 00 00 00       	call   800490 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 50 00 00 00       	call   80042f <vcprintf>
	cprintf("\n");
  8003df:	c7 04 24 40 10 80 00 	movl   $0x801040,(%esp)
  8003e6:	e8 a5 00 00 00       	call   800490 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003eb:	cc                   	int3   
  8003ec:	eb fd                	jmp    8003eb <_panic+0x53>
	...

008003f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 14             	sub    $0x14,%esp
  8003f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003fa:	8b 03                	mov    (%ebx),%eax
  8003fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800403:	40                   	inc    %eax
  800404:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800406:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040b:	75 19                	jne    800426 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80040d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800414:	00 
  800415:	8d 43 08             	lea    0x8(%ebx),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 94 fc ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  800420:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800426:	ff 43 04             	incl   0x4(%ebx)
}
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800438:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043f:	00 00 00 
	b.cnt = 0;
  800442:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800449:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 f0 03 80 00 	movl   $0x8003f0,(%esp)
  80046b:	e8 82 01 00 00       	call   8005f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800470:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 2c fc ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  800488:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800496:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 87 ff ff ff       	call   80042f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    
	...

008004ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 3c             	sub    $0x3c,%esp
  8004b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b8:	89 d7                	mov    %edx,%edi
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	75 08                	jne    8004d8 <printnum+0x2c>
  8004d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004d6:	77 57                	ja     80052f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004dc:	4b                   	dec    %ebx
  8004dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f7:	00 
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	e8 76 08 00 00       	call   800d80 <__udivdi3>
  80050a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	89 54 24 04          	mov    %edx,0x4(%esp)
  800519:	89 fa                	mov    %edi,%edx
  80051b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051e:	e8 89 ff ff ff       	call   8004ac <printnum>
  800523:	eb 0f                	jmp    800534 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	89 34 24             	mov    %esi,(%esp)
  80052c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800534:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800538:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80053c:	8b 45 10             	mov    0x10(%ebp),%eax
  80053f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054a:	00 
  80054b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	e8 43 09 00 00       	call   800ea0 <__umoddi3>
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	0f be 80 42 10 80 00 	movsbl 0x801042(%eax),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056e:	83 c4 3c             	add    $0x3c,%esp
  800571:	5b                   	pop    %ebx
  800572:	5e                   	pop    %esi
  800573:	5f                   	pop    %edi
  800574:	5d                   	pop    %ebp
  800575:	c3                   	ret    

00800576 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800579:	83 fa 01             	cmp    $0x1,%edx
  80057c:	7e 0e                	jle    80058c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	8d 4a 08             	lea    0x8(%edx),%ecx
  800583:	89 08                	mov    %ecx,(%eax)
  800585:	8b 02                	mov    (%edx),%eax
  800587:	8b 52 04             	mov    0x4(%edx),%edx
  80058a:	eb 22                	jmp    8005ae <getuint+0x38>
	else if (lflag)
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 10                	je     8005a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
  80059e:	eb 0e                	jmp    8005ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a5:	89 08                	mov    %ecx,(%eax)
  8005a7:	8b 02                	mov    (%edx),%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005be:	73 08                	jae    8005c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c3:	88 0a                	mov    %cl,(%edx)
  8005c5:	42                   	inc    %edx
  8005c6:	89 10                	mov    %edx,(%eax)
}
  8005c8:	5d                   	pop    %ebp
  8005c9:	c3                   	ret    

008005ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	e8 02 00 00 00       	call   8005f2 <vprintfmt>
	va_end(ap);
}
  8005f0:	c9                   	leave  
  8005f1:	c3                   	ret    

008005f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	57                   	push   %edi
  8005f6:	56                   	push   %esi
  8005f7:	53                   	push   %ebx
  8005f8:	83 ec 4c             	sub    $0x4c,%esp
  8005fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800601:	eb 12                	jmp    800615 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800603:	85 c0                	test   %eax,%eax
  800605:	0f 84 8b 03 00 00    	je     800996 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800615:	0f b6 06             	movzbl (%esi),%eax
  800618:	46                   	inc    %esi
  800619:	83 f8 25             	cmp    $0x25,%eax
  80061c:	75 e5                	jne    800603 <vprintfmt+0x11>
  80061e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800622:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800629:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80062e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80063f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800643:	eb 1d                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800648:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80064c:	eb 14                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800651:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800658:	eb 08                	jmp    800662 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80065a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	0f b6 06             	movzbl (%esi),%eax
  800665:	8d 56 01             	lea    0x1(%esi),%edx
  800668:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80066b:	8a 16                	mov    (%esi),%dl
  80066d:	83 ea 23             	sub    $0x23,%edx
  800670:	80 fa 55             	cmp    $0x55,%dl
  800673:	0f 87 01 03 00 00    	ja     80097a <vprintfmt+0x388>
  800679:	0f b6 d2             	movzbl %dl,%edx
  80067c:	ff 24 95 00 11 80 00 	jmp    *0x801100(,%edx,4)
  800683:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800686:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80068b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80068e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800692:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800695:	8d 50 d0             	lea    -0x30(%eax),%edx
  800698:	83 fa 09             	cmp    $0x9,%edx
  80069b:	77 2a                	ja     8006c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80069d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80069e:	eb eb                	jmp    80068b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006ae:	eb 17                	jmp    8006c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b4:	78 98                	js     80064e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b9:	eb a7                	jmp    800662 <vprintfmt+0x70>
  8006bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006c5:	eb 9b                	jmp    800662 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cb:	79 95                	jns    800662 <vprintfmt+0x70>
  8006cd:	eb 8b                	jmp    80065a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006d3:	eb 8d                	jmp    800662 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ed:	e9 23 ff ff ff       	jmp    800615 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	79 02                	jns    800703 <vprintfmt+0x111>
  800701:	f7 d8                	neg    %eax
  800703:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800705:	83 f8 08             	cmp    $0x8,%eax
  800708:	7f 0b                	jg     800715 <vprintfmt+0x123>
  80070a:	8b 04 85 60 12 80 00 	mov    0x801260(,%eax,4),%eax
  800711:	85 c0                	test   %eax,%eax
  800713:	75 23                	jne    800738 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800715:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800719:	c7 44 24 08 5a 10 80 	movl   $0x80105a,0x8(%esp)
  800720:	00 
  800721:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 9a fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800733:	e9 dd fe ff ff       	jmp    800615 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800738:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073c:	c7 44 24 08 63 10 80 	movl   $0x801063,0x8(%esp)
  800743:	00 
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
  80074b:	89 14 24             	mov    %edx,(%esp)
  80074e:	e8 77 fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800753:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800756:	e9 ba fe ff ff       	jmp    800615 <vprintfmt+0x23>
  80075b:	89 f9                	mov    %edi,%ecx
  80075d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800760:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 30                	mov    (%eax),%esi
  80076e:	85 f6                	test   %esi,%esi
  800770:	75 05                	jne    800777 <vprintfmt+0x185>
				p = "(null)";
  800772:	be 53 10 80 00       	mov    $0x801053,%esi
			if (width > 0 && padc != '-')
  800777:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077b:	0f 8e 84 00 00 00    	jle    800805 <vprintfmt+0x213>
  800781:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800785:	74 7e                	je     800805 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800787:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078b:	89 34 24             	mov    %esi,(%esp)
  80078e:	e8 ab 02 00 00       	call   800a3e <strnlen>
  800793:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800796:	29 c2                	sub    %eax,%edx
  800798:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80079b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80079f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	89 d3                	mov    %edx,%ebx
  8007a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ab:	eb 0b                	jmp    8007b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b1:	89 3c 24             	mov    %edi,(%esp)
  8007b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b7:	4b                   	dec    %ebx
  8007b8:	85 db                	test   %ebx,%ebx
  8007ba:	7f f1                	jg     8007ad <vprintfmt+0x1bb>
  8007bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	79 05                	jns    8007d0 <vprintfmt+0x1de>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d3:	29 c2                	sub    %eax,%edx
  8007d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d8:	eb 2b                	jmp    800805 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007de:	74 18                	je     8007f8 <vprintfmt+0x206>
  8007e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007e3:	83 fa 5e             	cmp    $0x5e,%edx
  8007e6:	76 10                	jbe    8007f8 <vprintfmt+0x206>
					putch('?', putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
  8007f6:	eb 0a                	jmp    800802 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800802:	ff 4d e4             	decl   -0x1c(%ebp)
  800805:	0f be 06             	movsbl (%esi),%eax
  800808:	46                   	inc    %esi
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 21                	je     80082e <vprintfmt+0x23c>
  80080d:	85 ff                	test   %edi,%edi
  80080f:	78 c9                	js     8007da <vprintfmt+0x1e8>
  800811:	4f                   	dec    %edi
  800812:	79 c6                	jns    8007da <vprintfmt+0x1e8>
  800814:	8b 7d 08             	mov    0x8(%ebp),%edi
  800817:	89 de                	mov    %ebx,%esi
  800819:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80081c:	eb 18                	jmp    800836 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80081e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800822:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800829:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082b:	4b                   	dec    %ebx
  80082c:	eb 08                	jmp    800836 <vprintfmt+0x244>
  80082e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800831:	89 de                	mov    %ebx,%esi
  800833:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800836:	85 db                	test   %ebx,%ebx
  800838:	7f e4                	jg     80081e <vprintfmt+0x22c>
  80083a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80083d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800842:	e9 ce fd ff ff       	jmp    800615 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800847:	83 f9 01             	cmp    $0x1,%ecx
  80084a:	7e 10                	jle    80085c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 08             	lea    0x8(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 30                	mov    (%eax),%esi
  800857:	8b 78 04             	mov    0x4(%eax),%edi
  80085a:	eb 26                	jmp    800882 <vprintfmt+0x290>
	else if (lflag)
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 12                	je     800872 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 30                	mov    (%eax),%esi
  80086b:	89 f7                	mov    %esi,%edi
  80086d:	c1 ff 1f             	sar    $0x1f,%edi
  800870:	eb 10                	jmp    800882 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 30                	mov    (%eax),%esi
  80087d:	89 f7                	mov    %esi,%edi
  80087f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800882:	85 ff                	test   %edi,%edi
  800884:	78 0a                	js     800890 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800886:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088b:	e9 ac 00 00 00       	jmp    80093c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800890:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800894:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80089b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089e:	f7 de                	neg    %esi
  8008a0:	83 d7 00             	adc    $0x0,%edi
  8008a3:	f7 df                	neg    %edi
			}
			base = 10;
  8008a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008aa:	e9 8d 00 00 00       	jmp    80093c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008af:	89 ca                	mov    %ecx,%edx
  8008b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b4:	e8 bd fc ff ff       	call   800576 <getuint>
  8008b9:	89 c6                	mov    %eax,%esi
  8008bb:	89 d7                	mov    %edx,%edi
			base = 10;
  8008bd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008c2:	eb 78                	jmp    80093c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008c8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008cf:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008d6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008dd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8008e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008f1:	e9 1f fd ff ff       	jmp    800615 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8008f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800901:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800904:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800908:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80090f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8d 50 04             	lea    0x4(%eax),%edx
  800918:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80091b:	8b 30                	mov    (%eax),%esi
  80091d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800922:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800927:	eb 13                	jmp    80093c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800929:	89 ca                	mov    %ecx,%edx
  80092b:	8d 45 14             	lea    0x14(%ebp),%eax
  80092e:	e8 43 fc ff ff       	call   800576 <getuint>
  800933:	89 c6                	mov    %eax,%esi
  800935:	89 d7                	mov    %edx,%edi
			base = 16;
  800937:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80093c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800940:	89 54 24 10          	mov    %edx,0x10(%esp)
  800944:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800947:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80094b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094f:	89 34 24             	mov    %esi,(%esp)
  800952:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800956:	89 da                	mov    %ebx,%edx
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	e8 4c fb ff ff       	call   8004ac <printnum>
			break;
  800960:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800963:	e9 ad fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800968:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800972:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800975:	e9 9b fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80097a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80097e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800985:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800988:	eb 01                	jmp    80098b <vprintfmt+0x399>
  80098a:	4e                   	dec    %esi
  80098b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80098f:	75 f9                	jne    80098a <vprintfmt+0x398>
  800991:	e9 7f fc ff ff       	jmp    800615 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800996:	83 c4 4c             	add    $0x4c,%esp
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5f                   	pop    %edi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 28             	sub    $0x28,%esp
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009bb:	85 c0                	test   %eax,%eax
  8009bd:	74 30                	je     8009ef <vsnprintf+0x51>
  8009bf:	85 d2                	test   %edx,%edx
  8009c1:	7e 33                	jle    8009f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	c7 04 24 b0 05 80 00 	movl   $0x8005b0,(%esp)
  8009df:	e8 0e fc ff ff       	call   8005f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ed:	eb 0c                	jmp    8009fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f4:	eb 05                	jmp    8009fb <vsnprintf+0x5d>
  8009f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a03:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a0a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	89 04 24             	mov    %eax,(%esp)
  800a1e:	e8 7b ff ff ff       	call   80099e <vsnprintf>
	va_end(ap);

	return rc;
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    
  800a25:	00 00                	add    %al,(%eax)
	...

00800a28 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	eb 01                	jmp    800a36 <strlen+0xe>
		n++;
  800a35:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a36:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3a:	75 f9                	jne    800a35 <strlen+0xd>
		n++;
	return n;
}
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb 01                	jmp    800a4f <strnlen+0x11>
		n++;
  800a4e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	74 06                	je     800a59 <strnlen+0x1b>
  800a53:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a57:	75 f5                	jne    800a4e <strnlen+0x10>
		n++;
	return n;
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a70:	42                   	inc    %edx
  800a71:	84 c9                	test   %cl,%cl
  800a73:	75 f5                	jne    800a6a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a75:	5b                   	pop    %ebx
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	53                   	push   %ebx
  800a7c:	83 ec 08             	sub    $0x8,%esp
  800a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a82:	89 1c 24             	mov    %ebx,(%esp)
  800a85:	e8 9e ff ff ff       	call   800a28 <strlen>
	strcpy(dst + len, src);
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a91:	01 d8                	add    %ebx,%eax
  800a93:	89 04 24             	mov    %eax,(%esp)
  800a96:	e8 c0 ff ff ff       	call   800a5b <strcpy>
	return dst;
}
  800a9b:	89 d8                	mov    %ebx,%eax
  800a9d:	83 c4 08             	add    $0x8,%esp
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab6:	eb 0c                	jmp    800ac4 <strncpy+0x21>
		*dst++ = *src;
  800ab8:	8a 1a                	mov    (%edx),%bl
  800aba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abd:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac3:	41                   	inc    %ecx
  800ac4:	39 f1                	cmp    %esi,%ecx
  800ac6:	75 f0                	jne    800ab8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ada:	85 d2                	test   %edx,%edx
  800adc:	75 0a                	jne    800ae8 <strlcpy+0x1c>
  800ade:	89 f0                	mov    %esi,%eax
  800ae0:	eb 1a                	jmp    800afc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae2:	88 18                	mov    %bl,(%eax)
  800ae4:	40                   	inc    %eax
  800ae5:	41                   	inc    %ecx
  800ae6:	eb 02                	jmp    800aea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aea:	4a                   	dec    %edx
  800aeb:	74 0a                	je     800af7 <strlcpy+0x2b>
  800aed:	8a 19                	mov    (%ecx),%bl
  800aef:	84 db                	test   %bl,%bl
  800af1:	75 ef                	jne    800ae2 <strlcpy+0x16>
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	eb 02                	jmp    800af9 <strlcpy+0x2d>
  800af7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800af9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800afc:	29 f0                	sub    %esi,%eax
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b08:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b0b:	eb 02                	jmp    800b0f <strcmp+0xd>
		p++, q++;
  800b0d:	41                   	inc    %ecx
  800b0e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b0f:	8a 01                	mov    (%ecx),%al
  800b11:	84 c0                	test   %al,%al
  800b13:	74 04                	je     800b19 <strcmp+0x17>
  800b15:	3a 02                	cmp    (%edx),%al
  800b17:	74 f4                	je     800b0d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b19:	0f b6 c0             	movzbl %al,%eax
  800b1c:	0f b6 12             	movzbl (%edx),%edx
  800b1f:	29 d0                	sub    %edx,%eax
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	53                   	push   %ebx
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b30:	eb 03                	jmp    800b35 <strncmp+0x12>
		n--, p++, q++;
  800b32:	4a                   	dec    %edx
  800b33:	40                   	inc    %eax
  800b34:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b35:	85 d2                	test   %edx,%edx
  800b37:	74 14                	je     800b4d <strncmp+0x2a>
  800b39:	8a 18                	mov    (%eax),%bl
  800b3b:	84 db                	test   %bl,%bl
  800b3d:	74 04                	je     800b43 <strncmp+0x20>
  800b3f:	3a 19                	cmp    (%ecx),%bl
  800b41:	74 ef                	je     800b32 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b43:	0f b6 00             	movzbl (%eax),%eax
  800b46:	0f b6 11             	movzbl (%ecx),%edx
  800b49:	29 d0                	sub    %edx,%eax
  800b4b:	eb 05                	jmp    800b52 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5e:	eb 05                	jmp    800b65 <strchr+0x10>
		if (*s == c)
  800b60:	38 ca                	cmp    %cl,%dl
  800b62:	74 0c                	je     800b70 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b64:	40                   	inc    %eax
  800b65:	8a 10                	mov    (%eax),%dl
  800b67:	84 d2                	test   %dl,%dl
  800b69:	75 f5                	jne    800b60 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b7b:	eb 05                	jmp    800b82 <strfind+0x10>
		if (*s == c)
  800b7d:	38 ca                	cmp    %cl,%dl
  800b7f:	74 07                	je     800b88 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b81:	40                   	inc    %eax
  800b82:	8a 10                	mov    (%eax),%dl
  800b84:	84 d2                	test   %dl,%dl
  800b86:	75 f5                	jne    800b7d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b99:	85 c9                	test   %ecx,%ecx
  800b9b:	74 30                	je     800bcd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba3:	75 25                	jne    800bca <memset+0x40>
  800ba5:	f6 c1 03             	test   $0x3,%cl
  800ba8:	75 20                	jne    800bca <memset+0x40>
		c &= 0xFF;
  800baa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	c1 e3 08             	shl    $0x8,%ebx
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	c1 e6 18             	shl    $0x18,%esi
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	c1 e0 10             	shl    $0x10,%eax
  800bbc:	09 f0                	or     %esi,%eax
  800bbe:	09 d0                	or     %edx,%eax
  800bc0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bc5:	fc                   	cld    
  800bc6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc8:	eb 03                	jmp    800bcd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bca:	fc                   	cld    
  800bcb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bcd:	89 f8                	mov    %edi,%eax
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800be2:	39 c6                	cmp    %eax,%esi
  800be4:	73 34                	jae    800c1a <memmove+0x46>
  800be6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800be9:	39 d0                	cmp    %edx,%eax
  800beb:	73 2d                	jae    800c1a <memmove+0x46>
		s += n;
		d += n;
  800bed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf0:	f6 c2 03             	test   $0x3,%dl
  800bf3:	75 1b                	jne    800c10 <memmove+0x3c>
  800bf5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bfb:	75 13                	jne    800c10 <memmove+0x3c>
  800bfd:	f6 c1 03             	test   $0x3,%cl
  800c00:	75 0e                	jne    800c10 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c02:	83 ef 04             	sub    $0x4,%edi
  800c05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c0b:	fd                   	std    
  800c0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0e:	eb 07                	jmp    800c17 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c10:	4f                   	dec    %edi
  800c11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c14:	fd                   	std    
  800c15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c17:	fc                   	cld    
  800c18:	eb 20                	jmp    800c3a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c20:	75 13                	jne    800c35 <memmove+0x61>
  800c22:	a8 03                	test   $0x3,%al
  800c24:	75 0f                	jne    800c35 <memmove+0x61>
  800c26:	f6 c1 03             	test   $0x3,%cl
  800c29:	75 0a                	jne    800c35 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	fc                   	cld    
  800c31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c33:	eb 05                	jmp    800c3a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c35:	89 c7                	mov    %eax,%edi
  800c37:	fc                   	cld    
  800c38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c44:	8b 45 10             	mov    0x10(%ebp),%eax
  800c47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	89 04 24             	mov    %eax,(%esp)
  800c58:	e8 77 ff ff ff       	call   800bd4 <memmove>
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c73:	eb 16                	jmp    800c8b <memcmp+0x2c>
		if (*s1 != *s2)
  800c75:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c78:	42                   	inc    %edx
  800c79:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c7d:	38 c8                	cmp    %cl,%al
  800c7f:	74 0a                	je     800c8b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c81:	0f b6 c0             	movzbl %al,%eax
  800c84:	0f b6 c9             	movzbl %cl,%ecx
  800c87:	29 c8                	sub    %ecx,%eax
  800c89:	eb 09                	jmp    800c94 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8b:	39 da                	cmp    %ebx,%edx
  800c8d:	75 e6                	jne    800c75 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ca2:	89 c2                	mov    %eax,%edx
  800ca4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ca7:	eb 05                	jmp    800cae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca9:	38 08                	cmp    %cl,(%eax)
  800cab:	74 05                	je     800cb2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cad:	40                   	inc    %eax
  800cae:	39 d0                	cmp    %edx,%eax
  800cb0:	72 f7                	jb     800ca9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc0:	eb 01                	jmp    800cc3 <strtol+0xf>
		s++;
  800cc2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc3:	8a 02                	mov    (%edx),%al
  800cc5:	3c 20                	cmp    $0x20,%al
  800cc7:	74 f9                	je     800cc2 <strtol+0xe>
  800cc9:	3c 09                	cmp    $0x9,%al
  800ccb:	74 f5                	je     800cc2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ccd:	3c 2b                	cmp    $0x2b,%al
  800ccf:	75 08                	jne    800cd9 <strtol+0x25>
		s++;
  800cd1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd7:	eb 13                	jmp    800cec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cd9:	3c 2d                	cmp    $0x2d,%al
  800cdb:	75 0a                	jne    800ce7 <strtol+0x33>
		s++, neg = 1;
  800cdd:	8d 52 01             	lea    0x1(%edx),%edx
  800ce0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ce5:	eb 05                	jmp    800cec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cec:	85 db                	test   %ebx,%ebx
  800cee:	74 05                	je     800cf5 <strtol+0x41>
  800cf0:	83 fb 10             	cmp    $0x10,%ebx
  800cf3:	75 28                	jne    800d1d <strtol+0x69>
  800cf5:	8a 02                	mov    (%edx),%al
  800cf7:	3c 30                	cmp    $0x30,%al
  800cf9:	75 10                	jne    800d0b <strtol+0x57>
  800cfb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cff:	75 0a                	jne    800d0b <strtol+0x57>
		s += 2, base = 16;
  800d01:	83 c2 02             	add    $0x2,%edx
  800d04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d09:	eb 12                	jmp    800d1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d0b:	85 db                	test   %ebx,%ebx
  800d0d:	75 0e                	jne    800d1d <strtol+0x69>
  800d0f:	3c 30                	cmp    $0x30,%al
  800d11:	75 05                	jne    800d18 <strtol+0x64>
		s++, base = 8;
  800d13:	42                   	inc    %edx
  800d14:	b3 08                	mov    $0x8,%bl
  800d16:	eb 05                	jmp    800d1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d24:	8a 0a                	mov    (%edx),%cl
  800d26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d29:	80 fb 09             	cmp    $0x9,%bl
  800d2c:	77 08                	ja     800d36 <strtol+0x82>
			dig = *s - '0';
  800d2e:	0f be c9             	movsbl %cl,%ecx
  800d31:	83 e9 30             	sub    $0x30,%ecx
  800d34:	eb 1e                	jmp    800d54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d39:	80 fb 19             	cmp    $0x19,%bl
  800d3c:	77 08                	ja     800d46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d3e:	0f be c9             	movsbl %cl,%ecx
  800d41:	83 e9 57             	sub    $0x57,%ecx
  800d44:	eb 0e                	jmp    800d54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d49:	80 fb 19             	cmp    $0x19,%bl
  800d4c:	77 12                	ja     800d60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d4e:	0f be c9             	movsbl %cl,%ecx
  800d51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d54:	39 f1                	cmp    %esi,%ecx
  800d56:	7d 0c                	jge    800d64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d58:	42                   	inc    %edx
  800d59:	0f af c6             	imul   %esi,%eax
  800d5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d5e:	eb c4                	jmp    800d24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d60:	89 c1                	mov    %eax,%ecx
  800d62:	eb 02                	jmp    800d66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d6a:	74 05                	je     800d71 <strtol+0xbd>
		*endptr = (char *) s;
  800d6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d71:	85 ff                	test   %edi,%edi
  800d73:	74 04                	je     800d79 <strtol+0xc5>
  800d75:	89 c8                	mov    %ecx,%eax
  800d77:	f7 d8                	neg    %eax
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
	...

00800d80 <__udivdi3>:
  800d80:	55                   	push   %ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	83 ec 10             	sub    $0x10,%esp
  800d86:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d8a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800d8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d92:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800d96:	89 cd                	mov    %ecx,%ebp
  800d98:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	75 2c                	jne    800dcc <__udivdi3+0x4c>
  800da0:	39 f9                	cmp    %edi,%ecx
  800da2:	77 68                	ja     800e0c <__udivdi3+0x8c>
  800da4:	85 c9                	test   %ecx,%ecx
  800da6:	75 0b                	jne    800db3 <__udivdi3+0x33>
  800da8:	b8 01 00 00 00       	mov    $0x1,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	f7 f1                	div    %ecx
  800db1:	89 c1                	mov    %eax,%ecx
  800db3:	31 d2                	xor    %edx,%edx
  800db5:	89 f8                	mov    %edi,%eax
  800db7:	f7 f1                	div    %ecx
  800db9:	89 c7                	mov    %eax,%edi
  800dbb:	89 f0                	mov    %esi,%eax
  800dbd:	f7 f1                	div    %ecx
  800dbf:	89 c6                	mov    %eax,%esi
  800dc1:	89 f0                	mov    %esi,%eax
  800dc3:	89 fa                	mov    %edi,%edx
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
  800dcc:	39 f8                	cmp    %edi,%eax
  800dce:	77 2c                	ja     800dfc <__udivdi3+0x7c>
  800dd0:	0f bd f0             	bsr    %eax,%esi
  800dd3:	83 f6 1f             	xor    $0x1f,%esi
  800dd6:	75 4c                	jne    800e24 <__udivdi3+0xa4>
  800dd8:	39 f8                	cmp    %edi,%eax
  800dda:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddf:	72 0a                	jb     800deb <__udivdi3+0x6b>
  800de1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800de5:	0f 87 ad 00 00 00    	ja     800e98 <__udivdi3+0x118>
  800deb:	be 01 00 00 00       	mov    $0x1,%esi
  800df0:	89 f0                	mov    %esi,%eax
  800df2:	89 fa                	mov    %edi,%edx
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    
  800dfb:	90                   	nop
  800dfc:	31 ff                	xor    %edi,%edi
  800dfe:	31 f6                	xor    %esi,%esi
  800e00:	89 f0                	mov    %esi,%eax
  800e02:	89 fa                	mov    %edi,%edx
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
  800e0b:	90                   	nop
  800e0c:	89 fa                	mov    %edi,%edx
  800e0e:	89 f0                	mov    %esi,%eax
  800e10:	f7 f1                	div    %ecx
  800e12:	89 c6                	mov    %eax,%esi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    
  800e21:	8d 76 00             	lea    0x0(%esi),%esi
  800e24:	89 f1                	mov    %esi,%ecx
  800e26:	d3 e0                	shl    %cl,%eax
  800e28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e31:	29 f0                	sub    %esi,%eax
  800e33:	89 ea                	mov    %ebp,%edx
  800e35:	88 c1                	mov    %al,%cl
  800e37:	d3 ea                	shr    %cl,%edx
  800e39:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e3d:	09 ca                	or     %ecx,%edx
  800e3f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e43:	89 f1                	mov    %esi,%ecx
  800e45:	d3 e5                	shl    %cl,%ebp
  800e47:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800e4b:	89 fd                	mov    %edi,%ebp
  800e4d:	88 c1                	mov    %al,%cl
  800e4f:	d3 ed                	shr    %cl,%ebp
  800e51:	89 fa                	mov    %edi,%edx
  800e53:	89 f1                	mov    %esi,%ecx
  800e55:	d3 e2                	shl    %cl,%edx
  800e57:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e5b:	88 c1                	mov    %al,%cl
  800e5d:	d3 ef                	shr    %cl,%edi
  800e5f:	09 d7                	or     %edx,%edi
  800e61:	89 f8                	mov    %edi,%eax
  800e63:	89 ea                	mov    %ebp,%edx
  800e65:	f7 74 24 08          	divl   0x8(%esp)
  800e69:	89 d1                	mov    %edx,%ecx
  800e6b:	89 c7                	mov    %eax,%edi
  800e6d:	f7 64 24 0c          	mull   0xc(%esp)
  800e71:	39 d1                	cmp    %edx,%ecx
  800e73:	72 17                	jb     800e8c <__udivdi3+0x10c>
  800e75:	74 09                	je     800e80 <__udivdi3+0x100>
  800e77:	89 fe                	mov    %edi,%esi
  800e79:	31 ff                	xor    %edi,%edi
  800e7b:	e9 41 ff ff ff       	jmp    800dc1 <__udivdi3+0x41>
  800e80:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e84:	89 f1                	mov    %esi,%ecx
  800e86:	d3 e2                	shl    %cl,%edx
  800e88:	39 c2                	cmp    %eax,%edx
  800e8a:	73 eb                	jae    800e77 <__udivdi3+0xf7>
  800e8c:	8d 77 ff             	lea    -0x1(%edi),%esi
  800e8f:	31 ff                	xor    %edi,%edi
  800e91:	e9 2b ff ff ff       	jmp    800dc1 <__udivdi3+0x41>
  800e96:	66 90                	xchg   %ax,%ax
  800e98:	31 f6                	xor    %esi,%esi
  800e9a:	e9 22 ff ff ff       	jmp    800dc1 <__udivdi3+0x41>
	...

00800ea0 <__umoddi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	83 ec 20             	sub    $0x20,%esp
  800ea6:	8b 44 24 30          	mov    0x30(%esp),%eax
  800eaa:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800eae:	89 44 24 14          	mov    %eax,0x14(%esp)
  800eb2:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eb6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eba:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ebe:	89 c7                	mov    %eax,%edi
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	85 ed                	test   %ebp,%ebp
  800ec4:	75 16                	jne    800edc <__umoddi3+0x3c>
  800ec6:	39 f1                	cmp    %esi,%ecx
  800ec8:	0f 86 a6 00 00 00    	jbe    800f74 <__umoddi3+0xd4>
  800ece:	f7 f1                	div    %ecx
  800ed0:	89 d0                	mov    %edx,%eax
  800ed2:	31 d2                	xor    %edx,%edx
  800ed4:	83 c4 20             	add    $0x20,%esp
  800ed7:	5e                   	pop    %esi
  800ed8:	5f                   	pop    %edi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    
  800edb:	90                   	nop
  800edc:	39 f5                	cmp    %esi,%ebp
  800ede:	0f 87 ac 00 00 00    	ja     800f90 <__umoddi3+0xf0>
  800ee4:	0f bd c5             	bsr    %ebp,%eax
  800ee7:	83 f0 1f             	xor    $0x1f,%eax
  800eea:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eee:	0f 84 a8 00 00 00    	je     800f9c <__umoddi3+0xfc>
  800ef4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ef8:	d3 e5                	shl    %cl,%ebp
  800efa:	bf 20 00 00 00       	mov    $0x20,%edi
  800eff:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800f03:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f07:	89 f9                	mov    %edi,%ecx
  800f09:	d3 e8                	shr    %cl,%eax
  800f0b:	09 e8                	or     %ebp,%eax
  800f0d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800f11:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800f15:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f19:	d3 e0                	shl    %cl,%eax
  800f1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1f:	89 f2                	mov    %esi,%edx
  800f21:	d3 e2                	shl    %cl,%edx
  800f23:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f27:	d3 e0                	shl    %cl,%eax
  800f29:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800f2d:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	d3 e8                	shr    %cl,%eax
  800f35:	09 d0                	or     %edx,%eax
  800f37:	d3 ee                	shr    %cl,%esi
  800f39:	89 f2                	mov    %esi,%edx
  800f3b:	f7 74 24 18          	divl   0x18(%esp)
  800f3f:	89 d6                	mov    %edx,%esi
  800f41:	f7 64 24 0c          	mull   0xc(%esp)
  800f45:	89 c5                	mov    %eax,%ebp
  800f47:	89 d1                	mov    %edx,%ecx
  800f49:	39 d6                	cmp    %edx,%esi
  800f4b:	72 67                	jb     800fb4 <__umoddi3+0x114>
  800f4d:	74 75                	je     800fc4 <__umoddi3+0x124>
  800f4f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f53:	29 e8                	sub    %ebp,%eax
  800f55:	19 ce                	sbb    %ecx,%esi
  800f57:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f5b:	d3 e8                	shr    %cl,%eax
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	89 f9                	mov    %edi,%ecx
  800f61:	d3 e2                	shl    %cl,%edx
  800f63:	09 d0                	or     %edx,%eax
  800f65:	89 f2                	mov    %esi,%edx
  800f67:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	83 c4 20             	add    $0x20,%esp
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
  800f74:	85 c9                	test   %ecx,%ecx
  800f76:	75 0b                	jne    800f83 <__umoddi3+0xe3>
  800f78:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	f7 f1                	div    %ecx
  800f81:	89 c1                	mov    %eax,%ecx
  800f83:	89 f0                	mov    %esi,%eax
  800f85:	31 d2                	xor    %edx,%edx
  800f87:	f7 f1                	div    %ecx
  800f89:	89 f8                	mov    %edi,%eax
  800f8b:	e9 3e ff ff ff       	jmp    800ece <__umoddi3+0x2e>
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	83 c4 20             	add    $0x20,%esp
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    
  800f99:	8d 76 00             	lea    0x0(%esi),%esi
  800f9c:	39 f5                	cmp    %esi,%ebp
  800f9e:	72 04                	jb     800fa4 <__umoddi3+0x104>
  800fa0:	39 f9                	cmp    %edi,%ecx
  800fa2:	77 06                	ja     800faa <__umoddi3+0x10a>
  800fa4:	89 f2                	mov    %esi,%edx
  800fa6:	29 cf                	sub    %ecx,%edi
  800fa8:	19 ea                	sbb    %ebp,%edx
  800faa:	89 f8                	mov    %edi,%eax
  800fac:	83 c4 20             	add    $0x20,%esp
  800faf:	5e                   	pop    %esi
  800fb0:	5f                   	pop    %edi
  800fb1:	5d                   	pop    %ebp
  800fb2:	c3                   	ret    
  800fb3:	90                   	nop
  800fb4:	89 d1                	mov    %edx,%ecx
  800fb6:	89 c5                	mov    %eax,%ebp
  800fb8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fbc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fc0:	eb 8d                	jmp    800f4f <__umoddi3+0xaf>
  800fc2:	66 90                	xchg   %ax,%ax
  800fc4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fc8:	72 ea                	jb     800fb4 <__umoddi3+0x114>
  800fca:	89 f1                	mov    %esi,%ecx
  800fcc:	eb 81                	jmp    800f4f <__umoddi3+0xaf>
